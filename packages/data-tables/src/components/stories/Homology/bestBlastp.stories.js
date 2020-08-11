import React from 'react';
import { homology_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_best_blastp_matches';
const order = ['evalue', 'taxonomy', 'hit', 'description', 'percent'];
const columnsHeader = {
  evalue: 'BLAST e-value',
  taxonomy: 'Species',
  hit: 'Hit',
  description: 'Description',
  percent: '% Length',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Homology/best_blastp_matches',
};

export const daf8 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf8}
    tableType={homology_widget.tableType.bestBlastpMatches}
    {...{ id, order, columnsHeader }}
  />
);
export const daf16 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf16}
    tableType={homology_widget.tableType.bestBlastpMatches}
    {...{ id, order, columnsHeader }}
  />
);
export const mig2 = () => (
  <Wrapper
    WBid={homology_widget.WBid.mig2}
    tableType={homology_widget.tableType.bestBlastpMatches}
    {...{ id, order, columnsHeader }}
  />
);
