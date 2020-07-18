import React from 'react'
import TableFilterComboBox from './index';

export default {
  title: 'Misc/Table Filter Combo Box',
};

export const mock = () => (
  <TableFilterComboBox options={{
    food: ['bread', 'egg', 'lettuce', 'tomato'],
    drinks: ['water', 'soda', 'milk'],
  }} />
);
