import { memo } from 'react';

import PersonalBestsDisplay from '../components/PersonalBests/PersonalBestsDisplay';
import UserInformation from '../components/UserInformation/UserInformation';
import UsersDisplay from '../components/UsersDisplay/UsersDisplay';
import useUsers from '../hooks/useUsers';
import { useAppSelector } from '../redux/hooks';
import { RootState } from '../redux/store';

const Home = () => {
    const { conn } = useAppSelector((state: RootState) => state.spacetime);

    const users = useUsers(conn);

    return (
        <>
            <UserInformation users={users} />
            <UsersDisplay users={users} />
            <PersonalBestsDisplay users={users} />
        </>
    );
};

export default memo(Home);
