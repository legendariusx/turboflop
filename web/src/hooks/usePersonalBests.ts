import { useEffect, useState } from 'react';
import { DbConnection, EventContext, PersonalBest } from '../module_bindings';

const usePersonalBests = (conn: DbConnection | null): Map<string, PersonalBest> => {
    const [personalBests, setPersonalBests] = useState<Map<string, PersonalBest>>(new Map());
    // spacetimedb does not export the SubscriptionHandleImpl type necessary to give this the correct type...
    let subscription: any = null;

    useEffect(() => {
        if (!conn) return;

        let queryString = `SELECT * FROM personal_best`
        subscription = conn?.subscriptionBuilder().subscribe([queryString]);

        const onInsert = (_ctx: EventContext, personalBest: PersonalBest) => {
            setPersonalBests((prev) => new Map(prev.set(personalBest.id.toString(), personalBest)));
        };
        conn.db.personalBest.onInsert(onInsert);

        const onUpdate = (_ctx: EventContext, oldPersonalBest: PersonalBest, newPersonalBest: PersonalBest) => {
            setPersonalBests((prev) => {
                prev.delete(oldPersonalBest.id.toString());
                return new Map(prev.set(newPersonalBest.id.toString(), newPersonalBest));
            });
        };
        conn.db.personalBest.onUpdate(onUpdate);

        const onDelete = (_ctx: EventContext, personalBest: PersonalBest) => {
            setPersonalBests((prev) => {
                prev.delete(personalBest.id.toString());
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
