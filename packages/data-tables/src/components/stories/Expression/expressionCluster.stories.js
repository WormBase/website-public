import React from 'react';
import { expression_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_expression_cluster';
const order = ['expression_cluster', 'description'];
const columnsHeader = {
  expression_cluster: 'Expression clusters',
  description: 'Description',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Expression/expression_cluster',
};

export const daf8 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressionCluster}
    {...{ id, order, columnsHeader }}
  />
);

export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressionCluster}
    {...{ id, order, columnsHeader }}
  />
);

export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressionCluster}
    {...{ id, order, columnsHeader }}
  />
);
