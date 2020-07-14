import React from 'react'
import Epg from '../ExpressionProfilingGraphs'
import { expression_widget } from '../../../../../.storybook/target'

export default {
  component: Epg,
  title: 'Table|Widgets/Expression/expression_profiling_graphs',
}

export const daf8 = () => (
  <Epg
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
  />
)
export const daf16 = () => (
  <Epg
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
  />
)
export const mig2 = () => (
  <Epg
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
  />
)
