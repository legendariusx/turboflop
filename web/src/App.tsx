import { useEffect } from 'react';
import { Container, Typography } from '@mui/material';

import { RootState } from './redux/store';
import { useAppDispatch, useAppSelector } from './redux/hooks';
import { initSpacetimeConnection } from './redux/thunks/spacetimeThunk';
import UsersDisplay from './components/UsersDisplay';
import PersonalBestsDisplay from './components/PersonalBestsDisplay';

const App = () => {
    const dispatch = useAppDispatch();
    const { isConnected, identity, error } = useAppSelector((state: RootState) => state.spacetime);

    useEffect(() => {
        dispatch(initSpacetimeConnection());
    }, [dispatch]);

    if (!isConnected) return <div>Connecting...</div>;
    else if (error) return <div>An error occurred... try refreshing the page</div>

    return (
        <Container>
            <Typography variant="h4">TurboFlop Web</Typography>
            <Typography>Connected as: {identity?.toHexString()}</Typography>
            <UsersDisplay />
            <PersonalBestsDisplay trackId={3} />
        </Container>
    );
};

export default App;
