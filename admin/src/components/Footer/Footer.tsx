import { Paper, Typography } from '@mui/material';
import { memo } from 'react';

import env from '../../lib/env';

import './Footer.scss';

const Footer = () => {

    return (
        <Paper square component={'footer'} className={'footer'}>
            {env.VERSION && (
                <Typography
                    className="footer__item"
                    sx={{
                        fontFamily: 'monospace',
                        fontWeight: 500,
                        fontSize: '0.875rem',
                    }}
                >
                    VERSION {env.VERSION}
                </Typography>
            )}
            <Typography
                className="footer__item"
                sx={{
                    fontFamily: 'monospace',
                    fontWeight: 500,
                    fontSize: '0.875rem',
                }}
            >
                <a href="https://github.com/legendariusx/turboflop" target='_blank'>GitHub</a>
            </Typography>
        </Paper>
    );
};

export default memo(Footer);
