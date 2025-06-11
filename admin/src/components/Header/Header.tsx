import { AppBar, Toolbar, Typography } from '@mui/material';
import { memo } from 'react';

import './Header.scss';

const Header = () => {
    return (
        <AppBar className='header__root'>
            <Toolbar disableGutters className='header'>
                <Typography variant='h5' fontFamily={'monospace'} fontWeight={700} letterSpacing={'0.2rem'}>TurboFlop</Typography>
            </Toolbar>
        </AppBar>
    );
};

export default memo(Header);