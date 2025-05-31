import { useState, useEffect } from 'react';
import { DbConnection, EventContext, User } from '../module_bindings';

const useUsers = (conn: DbConnection | null): Map<string, User> => {
    const [users, setUsers] = useState<Map<string, User>>(new Map());

    useEffect(() => {
        if (!conn) return;
        const onInsert = (_ctx: EventContext, user: User) => {
            setUsers((prev) => new Map(prev.set(user.identity.toHexString(), user)));
        };
        conn.db.user.onInsert(onInsert);

        const onUpdate = (_ctx: EventContext, oldUser: User, newUser: User) => {
            setUsers((prev) => {
                prev.delete(oldUser.identity.toHexString());
                return new Map(prev.set(newUser.identity.toHexString(), newUser));
            });
        };
        conn.db.user.onUpdate(onUpdate);

        const onDelete = (_ctx: EventContext, user: User) => {
            setUsers((prev) => {
                prev.delete(user.identity.toHexString());
                return new Map(prev);
            });
        };
        conn.db.user.onDelete(onDelete);

        return () => {
            conn.db.user.removeOnInsert(onInsert);
            conn.db.user.removeOnUpdate(onUpdate);
            conn.db.user.removeOnDelete(onDelete);
        };
    }, [conn]);

    return users;
}

export default useUsers;
