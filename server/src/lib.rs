pub mod types;
pub mod validation;

use spacetimedb::{DbContext, Identity, ReducerContext, Table, Timestamp, reducer, table};
use types::vector3::Vector3;
use validation::admin::is_admin;
use validation::name::validate_name;

#[table(name = user, public)]
pub struct User {
    #[primary_key]
    identity: Identity,
    name: String,
    online: bool,
    admin: bool,
    banned: bool,
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

#[table(name = setting)]
pub struct Setting {
    #[primary_key]
    key: String,
    value: String,
}

const ADMIN_TOKEN_SETTING_KEY: &str = "ADMIN_TOKEN";

#[reducer(init)]
pub fn init(ctx: &ReducerContext) {
    let new_admin_token = generate_secure_token(ctx);

    match ctx
        .db
        .setting()
        .key()
        .find(ADMIN_TOKEN_SETTING_KEY.to_string())
    {
        Some(existing_setting) => {
            ctx.db.setting().key().update(Setting {
                value: new_admin_token.clone(),
                ..existing_setting
            });
        }
        None => {
            ctx.db.setting().insert(Setting {
                key: ADMIN_TOKEN_SETTING_KEY.to_string(),
                value: new_admin_token.clone(),
            });
        }
    }

    log::info!("New admin token: {}", new_admin_token);
}

fn generate_secure_token(ctx: &ReducerContext) -> String {
    use spacetimedb::rand::Rng;
    let mut rng = ctx.rng();

    (0..32)
        .map(|_| {
            let n = rng.gen_range(0..36);
            if n < 10 {
                (b'0' + n) as char
            } else {
                (b'A' + n - 10) as char
            }
        })
        .collect()
}

#[reducer(client_connected)]
// Called when a client connects to a SpacetimeDB database server
pub fn client_connected(ctx: &ReducerContext) -> Result<(), String> {
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        if user.banned {
            return Err("User is banned.".to_string());
        }

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
            admin: false,
            banned: false,
        });
    }
    Ok(())
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
pub fn authenticate_admin(ctx: &ReducerContext, token: String) -> Result<(), String> {
    // search admin token setting
    match ctx
        .db
        .setting()
        .key()
        .find(ADMIN_TOKEN_SETTING_KEY.to_string())
    {
        Some(admin_token_setting) => {
            // check if tokens match
            if admin_token_setting.value == token {
                // if yes, find user in database and update admin state
                match ctx.db.user().identity().find(ctx.sender) {
                    Some(user) => {
                        ctx.db.user().identity().update(User {
                            admin: true,
                            ..user
                        });
                        Ok(())
                    }
                    // return error if user not found, should not be possible
                    None => {
                        log::error!("User not found in database!");
                        return Err("Unknown exception occurred".to_string());
                    }
                }
            }
            // return error if token does not match
            else {
                return Err("Invalid admin token".to_string());
            }
        }
        // return error if no setting was found
        None => {
            log::error!("No admin token set!");
            return Err("Unknown exception occurred".to_string());
        }
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

#[reducer]
/// Clients invoke this reducer to set another users name.
pub fn set_name_for(ctx: &ReducerContext, identity: Identity, name: String) -> Result<(), String> {
    is_admin(ctx)?;

    let name = validate_name(name)?;
    if let Some(user) = ctx.db.user().identity().find(identity) {
        ctx.db.user().identity().update(User { name: name, ..user });
        Ok(())
    } else {
        Err("Cannot set name for unknown user".to_string())
    }
}

#[reducer]
pub fn kick_player(ctx: &ReducerContext, identity: Identity) -> Result<(), String> {
    is_admin(ctx)?;

    if let Some(user) = ctx.db.user().identity().find(identity) {
        ctx.db.user().identity().update(User {
            online: false,
            ..user
        });
    }

    reset_user_data(ctx, identity);
    Ok(())
}

#[reducer]
pub fn set_player_banned(
    ctx: &ReducerContext,
    identity: Identity,
    banned: bool,
) -> Result<(), String> {
    is_admin(ctx)?;

    if let Some(user) = ctx.db.user().identity().find(identity) {
        ctx.db.user().identity().update(User {
            online: false,
            banned: banned,
            ..user
        });
    }

    reset_user_data(ctx, identity);
    Ok(())
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

#[reducer]
pub fn delete_personal_best(ctx: &ReducerContext, id: u64) -> Result<(), String> {
    is_admin(ctx)?;

    let res = ctx.db.personal_best().id().delete(id);
    if res {
        Ok(())
    } else {
        Err("Personal best not found".to_string())
    }
}
