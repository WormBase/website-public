import React, { useState, useEffect } from 'react'
import Pheno from '../Phenotype'
import { phenotype_widget } from '../../../../../.storybook/target'
import loadData from '../../../../services/loadData'

const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const id = 'table_drives_overexpression'
  const columnsHeader = {
    phenotype: 'Phenotype',
    entity: 'Entities Affected',
    evidence: 'Supporting Evidence',
  }

  return <Pheno data={data} id={id} columnsHeader={columnsHeader} />
}

export default {
  component: Wrapper,
  title: 'Table|Widgets/Phenotypes/drives_overexpression',
}

export const daf8 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.daf8}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.daf16}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.mig2}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
  />
)
