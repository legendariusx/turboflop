import { useState, useEffect } from 'react';
import { DbConnection, EventContext, UserData } from '../module_bindings';

const useUserData = (conn: DbConnection | null): Map<string, UserData> => {
    const [userData, setUserData] = useState<Map<string, UserData>>(new Map());

    useEffect(() => {
        if (!conn) return;
        const onInsert = (_ctx: EventContext, userData: UserData) => {
            setUserData((prev) => new Map(prev.set(userData.identity.toHexString(), userData)));
        };
        conn.db.userData.onInsert(onInsert);

        const onUpdate = (_ctx: EventContext, oldUserData: UserData, newUserData: UserData) => {
            setUserData((prev) => {
                prev.delete(oldUserData.identity.toHexString());
                return new Map(prev.set(newUserData.identity.toHexString(), newUserData));
            });
        };
        conn.db.userData.onUpdate(onUpdate);

        const onDelete = (_ctx: EventContext, userData: UserData) => {
            setUserData((prev) => {
                prev.delete(userData.identity.toHexString());
                return new Map(prev);
            });
        };
        conn.db.userData.onDelete(onDelete);

        return () => {
            conn.db.userData.removeOnInsert(onInsert);
            conn.db.userData.removeOnUpdate(onUpdate);
            conn.db.userData.removeOnDelete(onDelete);
        };
    }, [conn]);

    return userData;
}

export default useUserData;
