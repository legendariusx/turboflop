import { Vector3 } from "../module_bindings";

export const isLocalhost = (): boolean => {
    return window.location.host.includes('localhost') || window.location.host.includes('127.0.0.1');
};

export const formatVector3 = (vector3: Vector3): string => `(${vector3.x.toFixed(2)}, ${vector3.y.toFixed(2)}, ${vector3.z.toFixed(2)})`