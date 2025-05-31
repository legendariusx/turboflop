import React from 'react';
import { createRoot } from 'react-dom/client';
import { Provider } from 'react-redux';
import { ToastContainer } from 'react-toastify';
import { ThemeProvider } from '@mui/material';
import { BrowserRouter } from 'react-router-dom';
import 'react-toastify/dist/ReactToastify.css';

import './index.scss';
import { store } from './redux/store';
import App from './App';
import defaultTheme from './lib/defaultTheme';
import { ErrorBoundary } from 'react-error-boundary';
import ErrorBoundaryFallback from './components/ErrorBoundaryFallback/ErrorBoundaryFallback';

const Root = () => (
    <React.StrictMode>
        <Provider store={store}>
            <ThemeProvider theme={defaultTheme}>
                <BrowserRouter>
                    <ToastContainer autoClose={3000} theme="colored" />
                    <ErrorBoundary FallbackComponent={ErrorBoundaryFallback}>
                        <App />
                    </ErrorBoundary>
                </BrowserRouter>
            </ThemeProvider>
        </Provider>
    </React.StrictMode>
);

const rootElement = document.getElementById('root');
if (!rootElement) throw Error('No root element. Check index.html.');

createRoot(rootElement).render(<Root />);
