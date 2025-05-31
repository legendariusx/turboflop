import { useEffect, useState } from 'react';
import { DbConnection, EventContext, PersonalBest } from '../module_bindings';

const usePersonalBests = (conn: DbConnection | null, trackId: number): Map<string, PersonalBest> => {
    const [personalBests, setPersonalBests] = useState<Map<string, PersonalBest>>(new Map());
    // spacetimedb does not export the SubscriptionHandleImpl type necessary to give this the correct type...
    let subscription: any = null;

    useEffect(() => {
        if (!conn) return;

        subscription = conn?.subscriptionBuilder().subscribe([`SELECT * FROM personal_best WHERE track_id=${trackId}`]);

        const onInsert = (_ctx: EventContext, personalBest: PersonalBest) => {
            setPersonalBests((prev) => new Map(prev.set(personalBest.identity.toHexString(), personalBest)));
        };
        conn.db.personalBest.onInsert(onInsert);

        const onUpdate = (_ctx: EventContext, oldPersonalBest: PersonalBest, newPersonalBest: PersonalBest) => {
            setPersonalBests((prev) => {
                prev.delete(oldPersonalBest.identity.toHexString());
                return new Map(prev.set(newPersonalBest.identity.toHexString(), newPersonalBest));
            });
        };
        conn.db.personalBest.onUpdate(onUpdate);

        const onDelete = (_ctx: EventContext, personalBest: PersonalBest) => {
            setPersonalBests((prev) => {
                prev.delete(personalBest.identity.toHexString());
                return new Map(prev);
            });
        };
        conn.db.personalBest.onDelete(onDelete);

        return () => {
            conn.db.personalBest.removeOnInsert(onInsert);
            conn.db.personalBest.removeOnUpdate(onUpdate);
            conn.db.personalBest.removeOnDelete(onDelete);
            subscription?.unsubscribe();
        };
    }, [conn]);

    return personalBests;
};

export default usePersonalBests;
