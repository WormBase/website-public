import React, { useState, useEffect } from 'react'
import AggregateExpressionEstimates from '../AggregateExpressionEstimates'
import loadData from '../../../../services/loadData'
import { expression_widget } from '../../../../../.storybook/target'
const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data.controls)
    })
  }, [WBid, tableType])

  const id = 'table_fpkm_expression_summary_ls'
  const columnsHeader = {
    life_stage: 'Life stage',
    'control median': 'Median',
    'control mean': 'Mean',
  }

  return (
    <AggregateExpressionEstimates
      data={data}
      id={id}
      columnsHeader={columnsHeader}
    />
  )
}
export default {
  component: Wrapper,
  title: 'Table|Widgets/Expression/fpkm_expression_summary_ls/data__controls',
}

export const daf8 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf8}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.fpkmExpressionSummaryLs}
  />
)
