import { useEffect } from 'react';
import { groupBy } from 'lodash';
import { Container, Typography } from '@mui/material';

import { RootState } from './redux/store';
import { useAppDispatch, useAppSelector } from './redux/hooks';
import { initSpacetimeConnection } from './redux/thunks/spacetimeThunk';

import UsersDisplay from './components/UsersDisplay';
import PersonalBestsDisplay from './components/PersonalBestsDisplay';
import usePersonalBests from './hooks/usePersonalBests';
import { PersonalBest } from './module_bindings';
import useUsers from './hooks/useUsers';

const App = () => {
    const dispatch = useAppDispatch();
    const { isConnected, identity, error, conn } = useAppSelector((state: RootState) => state.spacetime);

    const users = useUsers(conn);
    const personalBests = usePersonalBests(conn);

    useEffect(() => {
        dispatch(initSpacetimeConnection());
    }, [dispatch]);

    if (!isConnected) return <div>Connecting...</div>;
    else if (error) return <div>An error occurred... try refreshing the page</div>;

    const groupedPersonalBests: { [key: string]: PersonalBest[] } = groupBy(
        [...personalBests.values()].map((p) => ({ ...p, trackId: Number(p.trackId) })),
        'trackId'
    );

    return (
        <Container>
            <Typography variant="h4">TurboFlop Web</Typography>
            <Typography>Connected as: {identity?.toHexString()}</Typography>
            <UsersDisplay users={users} />
            <div>
                <Typography variant="h4">Personal Bests</Typography>
                {Object.entries(groupedPersonalBests).map((g) => (
                    <PersonalBestsDisplay key={g[0]} trackId={parseInt(g[0])} personalBests={g[1]} users={users} />
                ))}
            </div>
        </Container>
    );
};

export default App;
