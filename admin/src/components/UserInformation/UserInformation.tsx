import { Button, TextField, Typography } from '@mui/material';
import { memo, useState } from 'react';

import { formatIdentity } from '../../lib/helpers';
import { User } from '../../module_bindings';
import { useAppSelector } from '../../redux/hooks';
import { RootState } from '../../redux/store';
import SectionTitle from '../SectionTitle/SectionTitle';

import './UserInformation.scss';

interface Props {
    users: Map<string, User>;
}

const UserInformation = ({ users }: Props) => {
    const [adminToken, setAdminToken] = useState('');

    const { identity, conn } = useAppSelector((state: RootState) => state.spacetime);

    const isAdmin = identity && users.get(identity.toHexString())?.admin;

    const onSubmitAdminToken = () => {
        conn?.reducers.authenticateAdmin(adminToken);
    };
    return (
        <div className="user-information">
            <SectionTitle title="User Information" />
            <div className="user-information__content">
                <Typography>Connected as: {formatIdentity(identity)}</Typography>
                <Typography>Admin: {isAdmin ? 'Yes' : 'No'}</Typography>
                {!isAdmin && (
                    <div className="user-information__content__admin-token">
                        <TextField
                            label="Admin token"
                            value={adminToken}
                            onChange={(event) => setAdminToken(event.target.value)}
                        />
                        <Button variant="contained" onClick={() => onSubmitAdminToken()}>
                            Submit
                        </Button>
                    </div>
                )}
            </div>
        </div>
    );
};

export default memo(UserInformation);
