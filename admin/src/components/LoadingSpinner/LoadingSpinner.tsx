import { memo } from 'react';
import { CircularProgress, Typography } from '@mui/material';

import './LoadingSpinner.scss';

interface Props {
    message?: string;
}

const LoadingSpinner = ({ message }: Props) => {
    return (
        <div className={'loading_spinner'}>
            <CircularProgress color={'primary'} />
            <Typography
                sx={{
                    fontWeight: 600,
                    fontSize: '1.125rem',
                    lineHeight: '1.5',
                    letterSpacing: '1px',
                }}
            >
                {message}
            </Typography>
        </div>
    );
};

export default memo(LoadingSpinner);