import React from 'react'
import Expressed from '../Expressed'
import { expression_widget } from '../../../../../.storybook/target'

export default {
  component: Expressed,
  title: 'Table|Widgets/Expression/subcellular_localization',
}

// This table for daf8 doesn't exist

// export const daf8 = () => (
//   <Expressed
//     WBid={expression_widget.WBid.daf8}
//     tableType={expression_widget.tableType.subcellularLocalization}
//   />
// )

export const daf16 = () => (
  <Expressed
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.subcellularLocalization}
  />
)
export const mig2 = () => (
  <Expressed
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.subcellularLocalization}
  />
)
