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

  const id = 'table_expressed_in'
  const columnsHeader = {
    ontology_term: 'Anatomy term',
    details: 'Supporting Evidence',
  }

  return <Expressed data={data} id={id} columnsHeader={columnsHeader} />
}
export default {
  component: Wrapper,
  title: 'Table|Widgets/Expression/expressed_in',
}

export const daf8 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressedIn}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressedIn}
  />
)
export const mig2 = () => (
  <Wrapper
    Expressed
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressedIn}
  />
)
