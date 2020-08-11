import React from 'react';
import { expression_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_fpkm_expression_summary_ls';
const order = ['life_stage', 'control median', 'control mean'];
const columnsHeader = {
  life_stage: 'Life stage',
  'control median': 'Median',
  'control mean': 'Mean',
};
const additionalKey = 'controls';

export default {
  component: Wrapper,
  title:
    'Table/Generic/Widgets/Expression/fpkm_expression_summary_ls/data_controls',
};

export const daf8 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
    {...{ id, order, columnsHeader, additionalKey }}
  />
);
export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
    {...{ id, order, columnsHeader, additionalKey }}
  />
);
export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
    {...{ id, order, columnsHeader, additionalKey }}
  />
);
