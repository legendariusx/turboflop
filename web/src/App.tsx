import { Button, Container, TextField, Typography } from '@mui/material';
import { groupBy } from 'lodash';
import { useEffect, useState } from 'react';

import { useAppDispatch, useAppSelector } from './redux/hooks';
import { RootState } from './redux/store';
import { initSpacetimeConnection } from './redux/thunks/spacetimeThunk';

import PersonalBestsDisplay from './components/PersonalBestsDisplay';
import UsersDisplay from './components/UsersDisplay';
import usePersonalBests from './hooks/usePersonalBests';
import useUsers from './hooks/useUsers';
import { PersonalBest } from './module_bindings';
import defaultTheme from './lib/defaultTheme';

const App = () => {
    const [adminToken, setAdminToken] = useState('');

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

    const isAdmin = conn?.identity && users.get(conn.identity.toHexString())?.admin;

    const onSubmitAdminToken = () => {
        conn?.reducers.authenticateAdmin(adminToken);
    };

    return (
        <Container>
            <Typography variant="h4">TurboFlop Web</Typography>

            <Typography>Connected as: {identity?.toHexString().substring(0, 8)}</Typography>
            <div>
                <Typography>Admin: {isAdmin ? 'Yes' : 'No'}</Typography>
                {!isAdmin && (
                    <Container sx={{ display: 'flex', gap: '1rem', ml: 0, paddingLeft: 0 }}>
                        <TextField
                            label="Admin token"
                            value={adminToken}
                            onChange={(event) => setAdminToken(event.target.value)}
                        />
                        <Button variant="contained" onClick={() => onSubmitAdminToken()}>
                            Submit
                        </Button>
                    </Container>
                )}
            </div>
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
