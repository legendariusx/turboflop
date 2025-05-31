/* eslint-disable @typescript-eslint/ban-ts-comment */
// @ts-ignore
const PROJECT_NAME = import.meta.env.VITE_PROJECT_NAME ?? 'unknown';
// @ts-ignore
const VERSION = import.meta.env.VITE_VERSION ?? 'unknown';
// @ts-ignore
const BASE_URL = import.meta.env.VITE_BASE_URL ?? 'unknown';

const env = {
    PROJECT_NAME,
    VERSION,
    BASE_URL,
};

export default env;
