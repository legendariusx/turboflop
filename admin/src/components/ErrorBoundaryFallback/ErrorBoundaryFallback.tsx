import { memo } from 'react';
import { Button, Paper, Typography } from '@mui/material';
import { ReportOutlined } from '@mui/icons-material';

import './ErrorBoundaryFallback.scss';
import InlineCode from '../InlineCode/InlineCode';

interface Props {
    error: Error;
}

const ErrorBoundaryFallback = ({ error }: Props) => {
    return (
        <div className={'error_boundary_fallback'}>
            <Paper elevation={3} component={'article'} className={'error_boundary_fallback__info'}>
                <ReportOutlined fontSize={'large'} className={'error_boundary_fallback__info__icon'} color={'error'} />
                <Typography
                    sx={{
                        fontWeight: 600,
                        fontSize: '1.25rem',
                        lineHeight: '1.5',
                        letterSpacing: '0px',
                        textAlign: 'center',
                    }}
                    component={'h6'}
                >
                    Something went wrong :(
                </Typography>
                <Typography
                    sx={{
                        fontSize: '1rem',
                        lineHeight: '1.25',
                        letterSpacing: '0px',
                        textAlign: 'center',
                    }}
                >
                    An unrecoverable exception occurred.
                    <br />
                    The following error caused this behavior:
                </Typography>
                <InlineCode fontWeight={700}>{error.message}</InlineCode>
                <Button color={'secondary'} variant={'outlined'} onClick={() => window.location.reload()}>
                    Refresh page
                </Button>
            </Paper>
        </div>
    );
};

export default memo(ErrorBoundaryFallback);