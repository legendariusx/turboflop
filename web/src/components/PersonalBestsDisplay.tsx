import { memo, useMemo } from 'react';
import { DataGrid, GridColDef, GridComparatorFn, GridSortDirection } from '@mui/x-data-grid';
import { Identity } from '@clockworklabs/spacetimedb-sdk';
import { SortDirection, Typography } from '@mui/material';

import useUsers from '../hooks/useUsers';
import usePersonalBests from '../hooks/usePersonalBests';

import { useAppSelector } from '../redux/hooks';
import { PersonalBest, User } from '../module_bindings';
import { formatTime } from '../lib/helpers';

interface Props {
    trackId: number;
}

const getPersonalBestSort = (sortDirection: GridSortDirection): GridComparatorFn => {
    if (sortDirection == 'desc') return (a: bigint, b: bigint) => Number(b) - Number(a);
    else return (a: bigint, b: bigint) => Number(a) - Number(b);
};

const PersonalBestsDisplay = ({ trackId }: Props) => {
    const { conn } = useAppSelector((state) => state.spacetime);
    const users = useUsers(conn);
    const personalBests = usePersonalBests(conn, trackId);

    const columns: GridColDef<{ placement: number } & User & PersonalBest>[] = [
        {
            field: 'placement',
            headerName: '#',
        },
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
            field: 'time',
            headerName: 'Time',
            flex: 1,
            valueFormatter: formatTime,
            getSortComparator: (sortDirection) => getPersonalBestSort(sortDirection),
            sortingOrder: ['asc', 'desc'],
        },
    ];

    const sortedPersonalBests = useMemo(() => [...personalBests.values()].sort((a,b) => Number(a.time) - Number(b.time)), [personalBests])

    const mappedPersonalBests: ({ placement: number } & User & PersonalBest)[] = sortedPersonalBests
        .values()
        .reduce((acc: ({ placement: number } & User & PersonalBest)[], pb, index) => {
            const user = users.get(pb.identity.toHexString());
            if (user) acc.push({ placement: index + 1, ...pb, ...user });
            return acc;
        }, []);

    return (
        <div>
            <Typography variant="h4">Personal Bests</Typography>
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
