import { memo } from 'react';
import { Checkbox, Typography } from '@mui/material';
import { DataGrid, GridColDef } from '@mui/x-data-grid';
import { Identity } from '@clockworklabs/spacetimedb-sdk';

import useUsers from '../hooks/useUsers';
import useUserData from '../hooks/useUserData';

import { formatVector3 } from '../lib/helpers';
import { useAppSelector } from '../redux/hooks';
import { User, UserData } from '../module_bindings';

const UsersDisplay = () => {
    const { conn } = useAppSelector((state) => state.spacetime);
    const users = useUsers(conn);
    const userData = useUserData(conn);

    const columns: GridColDef<User & UserData>[] = [
        {
            field: 'identity',
            headerName: 'Identity',
            flex: 1,
            valueGetter: (value: Identity) => value.toHexString().substring(0, 8),
        },
        {
            field: 'name',
            headerName: 'Name',
            flex: 2,
        },
        {
            field: 'online',
            headerName: 'Online',
            flex: 1,
            renderCell: (params) => <Checkbox checked={params.row.online} disabled />,
        },
        {
            field: 'isActive',
            headerName: 'Active',
            flex: 1,
            renderCell: (params) => <Checkbox checked={params.row.isActive} disabled />,
        },
        {
            field: 'trackId',
            headerName: 'Track ID',
            flex: 1,
        },
        {
            field: 'position',
            headerName: 'Position',
            flex: 3,
            valueGetter: formatVector3
        },
    ];

    const mappedUsers: (User & UserData)[] = users.values().reduce((acc: (User & UserData)[], user) => {
        const data = userData.get(user.identity.toHexString())
        if (data) acc.push({ ...user, ...data })
        return acc
    }, [])

    return (
        <div>
            <Typography variant="h4">Users</Typography>
            <DataGrid
                columns={columns}
                rows={mappedUsers}
                disableRowSelectionOnClick={true}
                getRowId={(row) => row.identity.toHexString()}
            />
        </div>
    );
};

export default memo(UsersDisplay);