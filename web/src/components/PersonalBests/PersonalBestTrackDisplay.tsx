import { DeleteForever } from '@mui/icons-material';
import { IconButton, Tooltip } from '@mui/material';
import { DataGrid, GridColDef, GridComparatorFn, GridSortDirection } from '@mui/x-data-grid';
import { memo, useMemo } from 'react';

import { formatIdentity, formatTime } from '../../lib/helpers';
import { PersonalBest, User } from '../../module_bindings';
import { useAppSelector } from '../../redux/hooks';

const getPersonalBestSort = (sortDirection: GridSortDirection): GridComparatorFn => {
    if (sortDirection == 'desc') return (a: bigint, b: bigint) => Number(b) - Number(a);
    else return (a: bigint, b: bigint) => Number(a) - Number(b);
};

interface Props {
    hidden: boolean;
    personalBests: PersonalBest[];
    users: Map<string, User>;
}

const PersonalBestTrackDisplay = ({ hidden, personalBests, users }: Props) => {
    const { conn } = useAppSelector((state) => state.spacetime);

    const currentUser = conn?.identity ? users.get(conn?.identity.toHexString()) : null;

    const columns: GridColDef<{ placement: number } & User & PersonalBest>[] = [
        {
            field: 'placement',
            headerName: '#',
            flex: 1,
            align: 'center',
            headerAlign: 'center',
        },
        {
            field: 'identity',
            headerName: 'Identity',
            flex: 2,
            valueGetter: formatIdentity,
        },
        {
            field: 'name',
            headerName: 'Name',
            flex: 6,
        },
        {
            field: 'time',
            headerName: 'Time',
            flex: 4,
            valueFormatter: formatTime,
            getSortComparator: (sortDirection) => getPersonalBestSort(sortDirection),
            sortingOrder: ['asc', 'desc'],
        },
        {
            field: 'actions',
            headerName: 'Actions',
            flex: 1,
            headerAlign: 'center',
            align: 'center',
            renderCell: (params) => (
                <Tooltip title="Delete Personal Best" placement="top">
                    <span>
                        <IconButton
                            onClick={() => conn?.reducers.deletePersonalBest(params.row.id)}
                            disabled={!currentUser?.admin}
                        >
                            <DeleteForever />
                        </IconButton>
                    </span>
                </Tooltip>
            ),
        },
    ];

    const sortedPersonalBests = useMemo(
        () => [...personalBests].sort((a, b) => Number(a.time) - Number(b.time)),
        [personalBests]
    );

    const mappedPersonalBests: ({ placement: number } & User & PersonalBest)[] = sortedPersonalBests.reduce(
        (acc: ({ placement: number } & User & PersonalBest)[], pb, index) => {
            const user = users.get(pb.identity.toHexString());
            if (user) acc.push({ placement: index + 1, ...pb, ...user });
            return acc;
        },
        []
    );

    if (hidden) return null;

    return (
        <div>
            <DataGrid
                columns={columns}
                rows={mappedPersonalBests}
                disableRowSelectionOnClick={true}
                getRowId={(row) => row.identity.toHexString()}
                initialState={{
                    sorting: {
                        sortModel: [{ field: 'time', sort: 'asc' }],
                    },
                }}
            />
        </div>
    );
};

export default memo(PersonalBestTrackDisplay);
