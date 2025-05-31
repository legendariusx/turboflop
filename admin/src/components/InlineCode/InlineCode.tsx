import { memo } from 'react';
import { Typography } from '@mui/material';

import './InlineCode.scss';
interface Props {
    children: string;
    color?: 'primary';
    fontWeight?: number;
}

const InlineCode = ({ children, color, fontWeight }: Props) => {
    return (
        <Typography
            className={'inline_code'}
            component={'span'}
            color={color}
            sx={{
                fontFamily: 'monospace',
                fontSize: '0.8rem',
                fontWeight,
            }}
        >
            {children}
        </Typography>
    );
};

export default memo(InlineCode);
