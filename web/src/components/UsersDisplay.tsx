import { memo } from 'react';
import { PersonRemove } from '@mui/icons-material';
import { DataGrid, GridColDef } from '@mui/x-data-grid';
import { Identity } from '@clockworklabs/spacetimedb-sdk';
import { Checkbox, IconButton, Tooltip, Typography } from '@mui/material';

import useUserData from '../hooks/useUserData';

import { formatVector3 } from '../lib/helpers';
import { useAppSelector } from '../redux/hooks';
import { User, UserData } from '../module_bindings';

interface Props {
    users: Map<string, User>;
}

const UsersDisplay = ({ users }: Props) => {
    const { conn } = useAppSelector((state) => state.spacetime);
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
            flex: 2,
            valueGetter: formatVector3,
        },
        {
            field: 'actions',
            headerName: 'Actions',
            flex: 1,
            headerAlign: 'center',
            align: 'center',
            renderCell: (params) => (
                <Tooltip title="Kick Player" placement="top">
                    <span>
                        <IconButton
                            onClick={() => conn?.reducers.kickPlayer(params.row.identity)}
                            disabled={!params.row.online}
                        >
                            <PersonRemove />
                        </IconButton>
                    </span>
                </Tooltip>
            ),
        },
    ];

    const mappedUsers: (User & UserData)[] = users.values().reduce((acc: (User & UserData)[], user) => {
        const data = userData.get(user.identity.toHexString());
        if (data) acc.push({ ...user, ...data });
        return acc;
    }, []);

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
