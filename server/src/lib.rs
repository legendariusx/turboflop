pub mod types;

use spacetimedb::{Identity, ReducerContext, Table, reducer, table};
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
    if let Some(user_data) = ctx.db.user_data().identity().find(ctx.sender) {
        ctx.db.user_data().identity().update(UserData {
            is_active: false,
            ..user_data
        });
    }
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

/// Takes a name and checks if it's acceptable as a user's name.
fn validate_name(name: String) -> Result<String, String> {
    if name.is_empty() {
        Err("Names must not be empty".to_string())
    } else {
        Ok(name)
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
) {
    if let Some(user_data) = ctx.db.user_data().identity().find(ctx.sender) {
        ctx.db.user_data().identity().update(UserData {
            position: position,
            rotation: rotation,
            linear_velocity: linear_velocity,
            angular_velocity: angular_velocity,
            is_active: is_active,
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
        });
    }
}
