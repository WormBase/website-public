import React from 'react'
import AggregateExpressionEstimates from '../AggregateExpressionEstimates'
import { expression_widget } from '../../../../../.storybook/target'

export default {
  component: AggregateExpressionEstimates,
  title: 'Table|Widgets/Expression/fpkm_expression_summary_ls',
}

export const daf8 = () => (
  <AggregateExpressionEstimates
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
export const daf16 = () => (
  <AggregateExpressionEstimates
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
export const mig2 = () => (
  <AggregateExpressionEstimates
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
