import React from 'react'
import Expressed from './Expressed'
import { expression_widget } from '../../../../.storybook/target'

export default {
  component: Expressed,
  title: 'Table|Widgets/Expression/expressed_during',
}

export const daf8 = () => (
  <Expressed
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressedDuring}
  />
)
export const daf16 = () => (
  <Expressed
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressedDuring}
  />
)
export const mig2 = () => (
  <Expressed
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressedDuring}
  />
)
