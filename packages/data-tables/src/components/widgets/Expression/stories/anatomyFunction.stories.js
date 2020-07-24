import React, { useState, useEffect } from 'react'
import AnatomyFunction from '../AnatomyFunction'
import loadData from '../../../../services/loadData'
import { expression_widget } from '../../../../../.storybook/target'
const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const id = 'table_anatomy_function'
  const columnsHeader = {
    bp_inv: 'Anatomical Sites',
    assay: 'Assay',
    phenotype: 'Phenotype',
    reference: 'Reference',
  }

  return <AnatomyFunction data={data} id={id} columnsHeader={columnsHeader} />
}
export default {
  component: Wrapper,
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
  <Wrapper
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
