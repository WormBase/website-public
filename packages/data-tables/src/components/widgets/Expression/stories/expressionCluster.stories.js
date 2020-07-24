import React, { useState, useEffect } from 'react'
import ExpressionCluster from '../ExpressionCluster'
import loadData from '../../../../services/loadData'
import { expression_widget } from '../../../../../.storybook/target'
const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const id = 'table_expression_cluster'
  const columnsHeader = {
    expression_cluster: 'Expression clusters',
    description: 'Description',
  }

  return <ExpressionCluster data={data} id={id} columnsHeader={columnsHeader} />
}
export default {
  component: Wrapper,
  title: 'Table|Widgets/Expression/expression_cluster',
}

export const daf8 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressionCluster}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressionCluster}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressionCluster}
  />
)
