use spacetimedb::ReducerContext;

use crate::user;

pub fn is_admin(ctx: &ReducerContext) -> Result<(), String> {
    match ctx.db.user().identity().find(ctx.sender) {
        Some(user) => {
            if user.admin {
                Ok(())
            } else {
                Err("user is not admin".to_string())
            }
        }
        None => Err("user not found".to_string()),
    }
}
