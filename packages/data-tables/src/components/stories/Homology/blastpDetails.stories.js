import React from 'react';
import { homology_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_blastp_details';
const order = [
  'evalue',
  'taxonomy',
  'hit',
  'description',
  'percentage',
  'target_range',
  'source_range',
];
const columnsHeader = {
  evalue: 'BLAST e-value',
  taxonomy: 'Species',
  hit: 'Hit',
  description: 'Description',
  percentage: '% Length',
  target_range: 'Target range',
  source_range: 'Source range',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Homology/blastp_details',
};

export const daf8 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf8}
    tableType={homology_widget.tableType.blastpDetails}
    {...{ id, order, columnsHeader }}
  />
);
