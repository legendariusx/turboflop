import { Typography } from '@mui/material';

const SectionTitle = ({ title }: { title: string }) => {
    return <Typography variant="h4" sx={{marginBottom: '0.5rem'}}>{title}</Typography>;
};

export default SectionTitle;
