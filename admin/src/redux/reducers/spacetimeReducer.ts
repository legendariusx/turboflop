import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { Identity } from '@clockworklabs/spacetimedb-sdk';

import { DbConnection } from '../../module_bindings';

interface SpacetimeState {
    conn: DbConnection | null;
    identity: Identity | null;
    isConnected: boolean;
    error: string | null;
}

const initialState: SpacetimeState = {
    conn: null,
    identity: null,
    isConnected: false,
    error: null,
};

export const spacetimeSlice = createSlice({
    name: 'spacetime',
    initialState,
    reducers: {
        setConnected: (
            state,
            action: PayloadAction<{
                conn: DbConnection;
                identity: Identity;
            }>
        ) => {
            state.conn = action.payload.conn;
            state.identity = action.payload.identity;
            state.isConnected = true;
            state.error = null;
        },
        setDisconnected: (state) => {
            state.conn = null;
            state.identity = null;
            state.isConnected = false;
        },
        setError: (state, action: PayloadAction<string>) => {
            state.error = action.payload;
        },
    },
});

export const spacetimeActions = spacetimeSlice.actions;
export default spacetimeSlice.reducer;
