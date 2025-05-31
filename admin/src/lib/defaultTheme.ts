import { createTheme } from '@mui/material';

const defaultTheme = createTheme({
    cssVariables: {
        colorSchemeSelector: 'class',
    },
    colorSchemes: {
        dark: {
            palette: {
                mode: 'dark',
                common: {
                    background: '#121212',
                },
                primary: {
                    main: '#ff31fbff',
                    dark: '#b223ae',
                },
                secondary: {
                    main: '#fff',
                },
                divider: '#181818',
                TableCell: {
                    border: '#181818',
                },
            },
        },
        light: {
            palette: {
                mode: 'light',
                primary: {
                    main: '#ff31fbff',
                    dark: '#b223ae',
                },
                secondary: {
                    main: '#f4f4f4',
                },
                divider: '#eee',
                TableCell: {
                    border: '#eee',
                },
            },
        },
    },
    typography: {
        fontFamily:
            '"IBM Plex Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol"',
    },
    shape: {
        borderRadius: 3,
    },
    defaultColorScheme: 'dark',
});

export default defaultTheme;