import { Paper } from '@mui/material';
import { useEffect } from 'react';

import Header from './components/Header/Header';
import Home from './pages/Home';
import { useAppDispatch, useAppSelector } from './redux/hooks';
import { RootState } from './redux/store';
import { initSpacetimeConnection } from './redux/thunks/spacetimeThunk';

import './App.scss';
import LoadingSpinner from './components/LoadingSpinner/LoadingSpinner';

const App = () => {
    const dispatch = useAppDispatch();
    const { isConnected, error, conn } = useAppSelector((state: RootState) => state.spacetime);

    useEffect(() => {
        dispatch(initSpacetimeConnection());
    }, [dispatch]);

    if (error) throw error;

    return (
        <Paper square className={'layout'}>
            <Header />
            <main className={'layout__main'}>
                {isConnected ? <Home /> : <LoadingSpinner message="Connecting..." />}
            </main>
            {/* <Footer {...footerProps} /> */}
        </Paper>
    );
};

export default App;
