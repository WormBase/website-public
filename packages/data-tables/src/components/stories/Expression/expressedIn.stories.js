import React from 'react';
import { expression_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_expressed_in';
const order = ['ontology_term', 'details'];
const columnsHeader = {
  ontology_term: 'Anatomy term',
  details: 'Supporting Evidence',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Expression/expressed_in',
};

export const daf8 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressedIn}
    {...{ id, order, columnsHeader }}
  />
);

export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressedIn}
    {...{ id, order, columnsHeader }}
  />
);

export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressedIn}
    {...{ id, order, columnsHeader }}
  />
);
