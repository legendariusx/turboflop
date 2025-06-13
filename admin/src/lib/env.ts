/* eslint-disable @typescript-eslint/ban-ts-comment */
import { getSpacetimeDBUrl } from "./helpers";

// @ts-ignore
const PROJECT_NAME = import.meta.env.VITE_PROJECT_NAME ?? 'unknown';
// @ts-ignore
const VERSION = import.meta.env.VITE_VERSION ?? 'unknown';
// @ts-ignore
const DEFAULT_HOST = import.meta.env.VITE_DEFAULT_HOST ?? 'unknown';

const SPACETIMEDB_BASE_URL = getSpacetimeDBUrl(DEFAULT_HOST);

const env = {
    VERSION,
    DEFAULT_HOST,
    PROJECT_NAME,
    SPACETIMEDB_BASE_URL
};

export default env;
