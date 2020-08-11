import React from 'react';
import { expression_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_expression_profiling_graphs';
const order = ['expression_pattern', 'type', 'description', 'database'];
const columnsHeader = {
  expression_pattern: 'Pattern',
  type: 'Type',
  description: 'Description',
  database: 'Database',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Expression/expression_profiling_graphs',
};

export const daf8 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
    {...{ id, order, columnsHeader }}
  />
);

export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
    {...{ id, order, columnsHeader }}
  />
);

export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
    {...{ id, order, columnsHeader }}
  />
);
