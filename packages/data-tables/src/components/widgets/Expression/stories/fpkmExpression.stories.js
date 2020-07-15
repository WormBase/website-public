import React from 'react'
import FpkmExpression from '../FpkmExpression'
import { expression_widget } from '../../../../../.storybook/target'

export default {
  component: FpkmExpression,
  title:
    'Table|Widgets/Expression/fpkm_expression_summary_ls/data__table__fpkm__data',
}

export const daf8 = () => (
  <FpkmExpression
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
export const daf16 = () => (
  <FpkmExpression
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
export const mig2 = () => (
  <FpkmExpression
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
