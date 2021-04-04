import React from 'react'
import ExpressionCluster from '../ExpressionCluster'
import { expression_widget } from '../../../../../.storybook/target'

export default {
  component: ExpressionCluster,
  title: 'Table|Widgets/Expression/expression_cluster',
}

export const daf8 = () => (
  <ExpressionCluster
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressionCluster}
  />
)
export const daf16 = () => (
  <ExpressionCluster
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressionCluster}
  />
)
export const mig2 = () => (
  <ExpressionCluster
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressionCluster}
  />
)
