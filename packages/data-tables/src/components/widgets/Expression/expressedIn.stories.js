import React from 'react'
import ExpressedIn from './ExpressedIn'
import { expression_widget } from '../../../../.storybook/target'

export default {
  component: ExpressedIn,
  title: 'Table|Widgets/Expression/expressed_in',
}

export const daf8 = () => (
  <ExpressedIn
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressedIn}
  />
)
export const daf16 = () => (
  <ExpressedIn
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressedIn}
  />
)
export const mig2 = () => (
  <ExpressedIn
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressedIn}
  />
)
