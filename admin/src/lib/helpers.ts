import dayjs from 'dayjs';
import utc from 'dayjs/plugin/utc';
import { Vector3 } from '../module_bindings';
import { Identity } from '@clockworklabs/spacetimedb-sdk';

export const isLocalhost = (): boolean => {
    return window.location.host.includes('localhost') || window.location.host.includes('127.0.0.1');
};

export const formatVector3 = (vector3: Vector3): string =>
    `(${vector3.x.toFixed(2)}, ${vector3.y.toFixed(2)}, ${vector3.z.toFixed(2)})`;

export const formatTime = (value: bigint) => {
    dayjs.extend(utc);
    const time = dayjs(Number(value)).utc();
    let outStr = '';
    if (time.hour() > 0) outStr += time.hour().toString().padStart(2, '0') + ':';
    if (time.minute() > 0) outStr += time.minute().toString().padStart(2, '0') + ':';
    return outStr + time.second().toString().padStart(2, '0') + '.' + time.millisecond().toString().padStart(3, '0');
};

export const formatIdentity = (identity: Identity | null): string => {
    return identity?.toHexString().substring(0, 10) ?? ""
}

// FIXME: names should be stored on and fetched from the server
export const convertCarIdToName = (carId: number): string => {
    switch (carId) {
        case 0:
            return "None"
        case 1:
            return "City Car"
        case 2:
            return "Truck"
        default:
            return carId.toString()
    }
}