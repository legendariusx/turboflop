import { Action, Middleware, ThunkAction, configureStore } from '@reduxjs/toolkit';
import logger from 'redux-logger';

import rootReducer from './reducers/rootReducer';
import { isLocalhost } from '../lib/helpers';
import { spacetimeActions } from './reducers/spacetimeReducer';

const getMiddleware = (): Middleware[] => {
    return isLocalhost() ? [logger] : [];
};

export const store = configureStore({
    reducer: rootReducer,
    middleware(getDefaultMiddleware) {
        return [
            ...getDefaultMiddleware({
                serializableCheck: {
                    ignoredActions: [spacetimeActions.setConnected.type, spacetimeActions.setError.type],
                },
            }),
            ...getMiddleware(),
        ];
    },
});

export type AppDispatch = typeof store.dispatch;
export type RootState = ReturnType<typeof store.getState>;
export type AppThunk<ReturnType = void> = ThunkAction<ReturnType, RootState, unknown, Action<string>>;
