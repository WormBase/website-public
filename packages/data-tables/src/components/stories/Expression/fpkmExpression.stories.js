import React from 'react';
import { expression_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_analysis';
const order = ['label', 'project_info', 'life_stage', 'value'];
const columnsHeader = {
  label: 'Name',
  project_info: 'Project',
  life_stage: 'Life stage',
  value: ' FPKM value',
};
const additionalKey = 'table.fpkm.data';

export default {
  component: Wrapper,
  title:
    'Table/Generic/Widgets/Expression/fpkm_expression_summary_ls/data__table__fpkm__data',
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
