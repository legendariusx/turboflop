pub mod types;

use spacetimedb::{DbContext, Identity, ReducerContext, Table, Timestamp, reducer, table};
use types::vector3::Vector3;

#[table(name = user, public)]
pub struct User {
    #[primary_key]
    identity: Identity,
    name: String,
    online: bool,
}

#[table(name = user_data, public)]
pub struct UserData {
    #[primary_key]
    identity: Identity,
    position: Vector3,
    rotation: Vector3,
    linear_velocity: Vector3,
    angular_velocity: Vector3,
    is_active: bool,
    track_id: u8,
}

#[table(
    name = personal_best,
    public
)]
pub struct PersonalBest {
    // id primary key is necessary for client SDK
    #[auto_inc]
    #[primary_key]
    id: u64,
    identity: Identity,
    #[index(btree)]
    track_id: u64,
    time: u64,
    checkpoint_times: Vec<u64>,
    date: Timestamp,
}

#[reducer(client_connected)]
// Called when a client connects to a SpacetimeDB database server
pub fn client_connected(ctx: &ReducerContext) {
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        // If this is a returning user, i.e. we already have a `User` with this `Identity`,
        // set `online: true`, but leave `name` and `identity` unchanged.
        ctx.db.user().identity().update(User {
            online: true,
            ..user
        });
    } else {
        // If this is a new user, create a `User` row for the `Identity`,
        // which is online, but hasn't set a name.
        ctx.db.user().insert(User {
            identity: ctx.sender,
            name: String::from(""),
            online: true,
        });
    }
}

#[reducer(client_disconnected)]
// Called when a client disconnects from SpacetimeDB database server
pub fn identity_disconnected(ctx: &ReducerContext) {
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        ctx.db.user().identity().update(User {
            online: false,
            ..user
        });
    } else {
        // This branch should be unreachable,
        // as it doesn't make sense for a client to disconnect without connecting first.
        log::warn!(
            "Disconnect event for unknown user with identity {:?}",
            ctx.sender
        );
    }

    // set user inactive
    reset_user_data(ctx, ctx.sender);
}

#[reducer]
/// Clients invoke this reducer to set their user names.
pub fn set_name(ctx: &ReducerContext, name: String) -> Result<(), String> {
    let name = validate_name(name)?;
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        ctx.db.user().identity().update(User { name: name, ..user });
        Ok(())
    } else {
        Err("Cannot set name for unknown user".to_string())
    }
}

#[reducer]
/// Clients invoke this reducer to set another users name.
pub fn set_name_for(ctx: &ReducerContext, identity: Identity, name: String) -> Result<(), String> {
    let name = validate_name(name)?;
    if let Some(user) = ctx.db.user().identity().find(identity) {
        ctx.db.user().identity().update(User { name: name, ..user });
        Ok(())
    } else {
        Err("Cannot set name for unknown user".to_string())
    }
}

/// Takes a name and checks if it's acceptable as a user's name.
fn validate_name(name: String) -> Result<String, String> {
    if name.is_empty() {
        Err("Names must not be empty".to_string())
    } else {
        Ok(name)
    }
}

#[reducer]
pub fn kick_player(ctx: &ReducerContext, identity: Identity) {
    if let Some(user) = ctx.db.user().identity().find(identity) {
        ctx.db.user().identity().update(User {
            online: false,
            ..user
        });
    }

    reset_user_data(ctx, identity);
}

pub fn reset_user_data(ctx: &ReducerContext, identity: Identity) {
    if let Some(user_data) = ctx.db.user_data().identity().find(identity) {
        ctx.db.user_data().identity().update(UserData {
            position: Vector3::ZERO,
            rotation: Vector3::ZERO,
            linear_velocity: Vector3::ZERO,
            angular_velocity: Vector3::ZERO,
            is_active: false,
            track_id: 0,
            ..user_data
        });
    }
}

// Updates user data
// TODO: could probably be split up to reduce size of individual calls
#[reducer]
pub fn set_user_data(
    ctx: &ReducerContext,
    position: Vector3,
    rotation: Vector3,
    linear_velocity: Vector3,
    angular_velocity: Vector3,
    is_active: bool,
    track_id: u8,
) -> Result<(), String> {
    match ctx.db().user().identity().find(ctx.sender) {
        Some(user) if user.online => user,
        Some(_) => return Err("Disconnected user cannot update user data".to_string()),
        None => return Err("User not found".to_string()),
    };

    if let Some(user_data) = ctx.db.user_data().identity().find(ctx.sender) {
        ctx.db.user_data().identity().update(UserData {
            position: position,
            rotation: rotation,
            linear_velocity: linear_velocity,
            angular_velocity: angular_velocity,
            is_active: is_active,
            track_id: track_id,
            ..user_data
        });
    } else {
        ctx.db.user_data().insert(UserData {
            identity: ctx.sender,
            position: position,
            rotation: rotation,
            linear_velocity: linear_velocity,
            angular_velocity: angular_velocity,
            is_active: is_active,
            track_id: track_id,
        });
    }

    Ok(())
}

#[reducer]
pub fn update_personal_best(
    ctx: &ReducerContext,
    track_id: u64,
    time: u64,
    checkpoint_times: Vec<u64>,
) {
    // filter personal bests on track_id to find user identity
    // (unfortunately spacetimedb does not allow find with multiple properties)
    if let Some(personal_best) = ctx
        .db
        .personal_best()
        .track_id()
        .filter(track_id)
        .find(|personal_best| personal_best.identity == ctx.sender)
    {
        // update only if new time is better
        if personal_best.time < time {
            return;
        }

        ctx.db.personal_best().id().update(PersonalBest {
            time: time,
            date: ctx.timestamp,
            checkpoint_times,
            ..personal_best
        });
    } else {
        ctx.db.personal_best().insert(PersonalBest {
            id: 0,
            identity: ctx.sender,
            track_id: track_id,
            time: time,
            date: ctx.timestamp,
            checkpoint_times,
        });
    }
}
