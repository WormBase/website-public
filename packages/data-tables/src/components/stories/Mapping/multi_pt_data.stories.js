import React from 'react';
import Wrapper from '../../Wrapper';

const id = 'table_multi_pt_data';
const order = ['genotype', 'result', 'mapper', 'date', 'comment'];
const columnsHeader = {
  result: 'Result',
  genotype: 'Genotype',
  mapper: 'Mapper',
  comment: 'Comment',
  date: 'Date',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Mapping/multi_pt_data',
};

export const daf8 = () => (
  <Wrapper
    WBid="WBGene00000904"
    tableType="multi_pt_data"
    {...{ id, order, columnsHeader }}
  />
);
