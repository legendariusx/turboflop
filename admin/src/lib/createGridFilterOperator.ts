import { GridFilterInputValueProps, GridFilterOperator } from '@mui/x-data-grid';
import { JSXElementConstructor } from 'react';

const createGridFilterOperator = <T>(
    component: JSXElementConstructor<GridFilterInputValueProps> | undefined,
    label = 'Equals',
    value = 'equals',
    comparator?: (value: T, filterValue: any) => boolean
): GridFilterOperator => {
    return {
        label,
        value,
        getApplyFilterFn: (filterItem) => {
            if (comparator) return (value) => comparator(value, filterItem.value);
            return (value) => {
                return !filterItem.value || value == filterItem.value;
            };
        },
        InputComponent: component,
    };
};

export default createGridFilterOperator;
