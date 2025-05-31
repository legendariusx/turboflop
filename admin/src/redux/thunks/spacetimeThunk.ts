import { Identity } from '@clockworklabs/spacetimedb-sdk';

import env from '../../lib/env';
import { AppThunk } from '../store';
import { DbConnection, ErrorContext } from '../../module_bindings';
import { spacetimeActions } from '../reducers/spacetimeReducer';

export const initSpacetimeConnection = (): AppThunk<void> => (dispatch) => {
    const subscribeToQueries = (conn: DbConnection, queries: string[]) => {
        conn?.subscriptionBuilder()
            .subscribe(queries);
    };

    const onConnect = (conn: DbConnection, identity: Identity, token: string) => {
        localStorage.setItem('auth_token', token);
        subscribeToQueries(conn, ['SELECT * FROM user', 'SELECT * FROM user_data']);
        dispatch(spacetimeActions.setConnected({ conn, identity }));
    };

    const onDisconnect = () => {
        dispatch(spacetimeActions.setDisconnected());
    };

    const onConnectError = (_ctx: ErrorContext, err: Error) => {
        dispatch(spacetimeActions.setError(err.message));
    };

    const conn = DbConnection.builder()
        .withUri(env.BASE_URL)
        .withModuleName(env.PROJECT_NAME)
        .withToken(localStorage.getItem('auth_token') || '')
        .onConnect(onConnect)
        .onDisconnect(onDisconnect)
        .onConnectError(onConnectError)
        .build();

    return conn;
};
