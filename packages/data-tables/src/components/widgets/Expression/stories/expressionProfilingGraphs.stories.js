import React, { useState, useEffect } from 'react'
import Epg from '../ExpressionProfilingGraphs'
import loadData from '../../../../services/loadData'
import { expression_widget } from '../../../../../.storybook/target'
const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const id = 'table_expression_profiling_graphs'
  const columnsHeader = {
    expression_pattern: 'Pattern',
    'type[0]': 'Type',
    description: 'Description',
    database: 'Database',
  }

  return <Epg data={data} id={id} columnsHeader={columnsHeader} />
}
export default {
  component: Wrapper,
  title: 'Table|Widgets/Expression/expression_profiling_graphs',
}

export const daf8 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.expressionProfilingGraphs}
  />
)
