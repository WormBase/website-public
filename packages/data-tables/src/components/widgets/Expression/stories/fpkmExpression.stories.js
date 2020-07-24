import React, { useState, useEffect } from 'react'
import FpkmExpression from '../FpkmExpression'
import loadData from '../../../../services/loadData'
import { expression_widget } from '../../../../../.storybook/target'
const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data.table.fpkm.data)
    })
  }, [WBid, tableType])

  const id = 'table_fpkm_expression_summary_ls'
  const columnsHeader = {
    label: 'Name',
    project_info: 'Project',
    life_stage: 'Life stage',
    value: ' FPKM value',
  }

  return <FpkmExpression data={data} id={id} columnsHeader={columnsHeader} />
}
export default {
  component: Wrapper,
  title:
    'Table|Widgets/Expression/fpkm_expression_summary_ls/data__table__fpkm__data',
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
