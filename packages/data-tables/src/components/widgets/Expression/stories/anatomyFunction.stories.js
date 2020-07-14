import React from 'react'
import AnatomyFunction from '../AnatomyFunction'
import { expression_widget } from '../../../../../.storybook/target'

export default {
  component: AnatomyFunction,
  title: 'Table|Widgets/Expression/anatomy_function',
}

// This table for daf8 doesn't exist

// export const daf8 = () => (
//   <AnatomyFunction
//     WBid={expression_widget.WBid.daf8}
//     tableType={expression_widget.tableType.anatomyFunction}
//   />
// )

export const daf16 = () => (
  <AnatomyFunction
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.anatomyFunction}
  />
)

// This table for mig2 doesn't exist

// export const mig2 = () => (
//   <AnatomyFunction
//     WBid={expression_widget.WBid.mig2}
//     tableType={expression_widget.tableType.anatomyFunction}
//   />
// )
