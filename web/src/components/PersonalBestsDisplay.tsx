import { memo, useMemo } from 'react';
import { DataGrid, GridColDef, GridComparatorFn, GridSortDirection } from '@mui/x-data-grid';
import { Identity } from '@clockworklabs/spacetimedb-sdk';
import { Typography } from '@mui/material';

import { PersonalBest, User } from '../module_bindings';
import { formatTime } from '../lib/helpers';

const getPersonalBestSort = (sortDirection: GridSortDirection): GridComparatorFn => {
    if (sortDirection == 'desc') return (a: bigint, b: bigint) => Number(b) - Number(a);
    else return (a: bigint, b: bigint) => Number(a) - Number(b);
};

interface Props {
    trackId: number;
    personalBests: PersonalBest[];
    users: Map<string, User>;
}

const PersonalBestsDisplay = ({ trackId, personalBests, users }: Props) => {
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
            valueGetter: (value: Identity) => value.toHexString().substring(0, 8),
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

    return (
        <div>
            <Typography>Track {trackId}</Typography>
            <DataGrid
                columns={columns}
                rows={mappedPersonalBests}
                disableRowSelectionOnClick={true}
                getRowId={(row) => row.identity.toHexString()}
            />
        </div>
    );
};

export default memo(PersonalBestsDisplay);
