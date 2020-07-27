import React, { useState, useEffect } from 'react'
import PhenotypeByInteraction from '../PhenotypeByInteraction'
import loadData from '../../../../services/loadData'
import { phenotype_widget } from '../../../../../.storybook/target'

const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const id = 'table_phenotype_by_interaction'
  // const order = ['phenotype', 'interactions', 'interaction_type', 'citations']
  const columnsHeader = {
    interaction_type: 'Interaction Type',
    citations: 'Citations',
    phenotype: 'Phenotype',
    interactions: 'Interactions',
  }

  return (
    <PhenotypeByInteraction
      data={data}
      id={id}
      // order={order}
      columnsHeader={columnsHeader}
    />
  )
}

export default {
  component: Wrapper,
  title: 'Table/Widgets/Phenotypes/phenotype_by_interaction',
}

export const daf8 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.daf8}
    tableType={phenotype_widget.tableType.phenotypeByInteraction}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.daf16}
    tableType={phenotype_widget.tableType.phenotypeByInteraction}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.mig2}
    tableType={phenotype_widget.tableType.phenotypeByInteraction}
  />
)
