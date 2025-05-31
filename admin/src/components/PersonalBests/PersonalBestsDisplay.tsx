import { Tab, Tabs } from '@mui/material';
import { groupBy } from 'lodash';
import { memo, useEffect, useState } from 'react';

import usePersonalBests from '../../hooks/usePersonalBests';
import { PersonalBest, User } from '../../module_bindings';
import { useAppSelector } from '../../redux/hooks';
import SectionTitle from '../SectionTitle/SectionTitle';
import PersonalBestTrackDisplay from './PersonalBestTrackDisplay';

interface Props {
    users: Map<string, User>;
}
const PersonalBestsDisplay = ({ users }: Props) => {
    const [selectedTab, setSelectedTab] = useState('1');

    const { conn } = useAppSelector((state) => state.spacetime);

    const personalBests = usePersonalBests(conn);

    useEffect(() => {
        const trackIds: number[] = []
        for (const pb of personalBests.values()) {
            if (!trackIds.includes(Number(pb.trackId))) trackIds.push(Number(pb.trackId))
        }

        if (personalBests.size > 0 && !trackIds.includes(parseInt(selectedTab))) {
            setSelectedTab(Math.min(...trackIds).toString())
        } 
    }, [personalBests])

    const groupedPersonalBests: { [key: string]: PersonalBest[] } = groupBy(
        [...personalBests.values()].map((p) => ({ ...p, trackId: Number(p.trackId) })),
        'trackId'
    );

    return (
        <div>
            <SectionTitle title='Personal Bests' />

            <Tabs value={selectedTab} onChange={(_, newValue) => setSelectedTab(newValue)}>
                {Object.entries(groupedPersonalBests).map((g) => (
                    <Tab key={g[0]} value={g[0]} label={`Track ${g[0]}`} />
                ))}
            </Tabs>

            {Object.entries(groupedPersonalBests).map((g) => (
                <PersonalBestTrackDisplay
                    key={g[0]}
                    hidden={g[0].toString() !== selectedTab}
                    personalBests={g[1]}
                    users={users}
                />
            ))}
        </div>
    );
};

export default memo(PersonalBestsDisplay);
