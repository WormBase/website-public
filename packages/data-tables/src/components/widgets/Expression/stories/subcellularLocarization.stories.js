import React, { useState, useEffect } from 'react'
import Expressed from '../Expressed'
import loadData from '../../../../services/loadData'
import { expression_widget } from '../../../../../.storybook/target'
const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const id = 'table_subcellular_localization'
  const columnsHeader = {
    ontology_term: 'Cellular component',
    details: 'Supporting Evidence',
  }

  return <Expressed data={data} id={id} columnsHeader={columnsHeader} />
}
export default {
  component: Wrapper,
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
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.subcellularLocalization}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.subcellularLocalization}
  />
)
