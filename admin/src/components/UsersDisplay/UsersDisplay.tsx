import { Block, Check, PersonRemove } from '@mui/icons-material';
import { Checkbox, IconButton, Tooltip } from '@mui/material';
import { DataGrid, GridColDef, GridFilterInputBoolean, GridFilterInputValue, GridRowModel } from '@mui/x-data-grid';
import { memo } from 'react';

import useUserData from '../../hooks/useUserData';
import createGridFilterOperator from '../../lib/createGridFilterOperator';
import { formatIdentity, formatVector3 } from '../../lib/helpers';
import { User, UserData } from '../../module_bindings';
import { useAppSelector } from '../../redux/hooks';
import SectionTitle from '../SectionTitle/SectionTitle';

interface Props {
    users: Map<string, User>;
}

const UsersDisplay = ({ users }: Props) => {
    const { conn } = useAppSelector((state) => state.spacetime);
    const userData = useUserData(conn);

    const currentUser = conn?.identity ? users.get(conn?.identity.toHexString()) : null;

    const columns: GridColDef<User & UserData>[] = [
        {
            field: 'identity',
            headerName: 'Identity',
            flex: 1,
            valueGetter: formatIdentity,
            hideable: false,
            filterable: false,
        },
        {
            field: 'name',
            headerName: 'Name',
            flex: 2,
            editable: currentUser?.admin,
            hideable: false,
            filterOperators: [
                createGridFilterOperator(GridFilterInputValue),
                createGridFilterOperator<string>(
                    GridFilterInputValue,
                    'Includes',
                    'includes',
                    (value, filterValue) => !filterValue || value.includes(filterValue)
                ),
            ],
        },
        {
            field: 'online',
            headerName: 'Online',
            flex: 1,
            renderCell: (params) => <Checkbox checked={params.row.online} disabled />,
            filterOperators: [createGridFilterOperator(GridFilterInputBoolean)],
            sortable: false,
            hideable: false,
        },
        {
            field: 'isActive',
            headerName: 'Active',
            flex: 1,
            renderCell: (params) => <Checkbox checked={params.row.isActive} disabled />,
            filterOperators: [createGridFilterOperator(GridFilterInputBoolean)],
            sortable: false,
            hideable: false,
        },
        {
            field: 'banned',
            headerName: 'Banned',
            flex: 1,
            renderCell: (params) => <Checkbox checked={params.row.banned} disabled />,
            filterOperators: [createGridFilterOperator(GridFilterInputBoolean)],
            sortable: false,
            hideable: false,
        },
        {
            field: 'trackId',
            headerName: 'Track ID',
            flex: 1,
            filterOperators: [createGridFilterOperator(GridFilterInputValue)],
            hideable: false,
        },
        {
            field: 'position',
            headerName: 'Position',
            flex: 2,
            valueGetter: formatVector3,
            hideable: false,
            sortable: false,
            filterable: false,
            disableColumnMenu: true,
        },
        {
            field: 'actions',
            headerName: 'Actions',
            flex: 1,
            headerAlign: 'center',
            align: 'center',
            hideable: false,
            sortable: false,
            filterable: false,
            disableColumnMenu: true,
            renderCell: (params) => (
                <div>
                    <Tooltip title="Kick Player" placement="top">
                        <span>
                            <IconButton
                                onClick={() => conn?.reducers.kickPlayer(params.row.identity)}
                                disabled={!params.row.online || !currentUser?.admin}
                            >
                                <PersonRemove />
                            </IconButton>
                        </span>
                    </Tooltip>
                    <Tooltip title={params.row.banned ? 'Unban Player' : 'Ban Player'} placement="top">
                        <span>
                            <IconButton
                                onClick={() => conn?.reducers.setPlayerBanned(params.row.identity, !params.row.banned)}
                                disabled={!currentUser?.admin}
                            >
                                {params.row.banned ? <Check /> : <Block />}
                            </IconButton>
                        </span>
                    </Tooltip>
                </div>
            ),
        },
    ];

    const processRowUpdate = (newRow: GridRowModel<User & UserData>) => {
        conn?.reducers.setNameFor(newRow.identity, newRow.name);
        return newRow;
    };

    const mappedUsers: (User & UserData)[] = users.values().reduce((acc: (User & UserData)[], user) => {
        const data = userData.get(user.identity.toHexString());
        if (data) acc.push({ ...user, ...data });
        return acc;
    }, []);

    return (
        <div>
            <SectionTitle title="Users" />
            <DataGrid
                columns={columns}
                rows={mappedUsers}
                disableRowSelectionOnClick={true}
                getRowId={(row) => row.identity.toHexString()}
                processRowUpdate={processRowUpdate}
                initialState={{
                    sorting: {
                        sortModel: [{ field: 'identity', sort: 'asc' }],
                    },
                    pagination: { paginationModel: { pageSize: 10 } },
                }}
                hideFooter={mappedUsers.length < 10}
                pageSizeOptions={[10]}
            />
        </div>
    );
};

export default memo(UsersDisplay);
