import React, { useState, useEffect } from 'react'
import BlastpDetails from '../BlastpDetails'
import loadData from '../../../../services/loadData'
import { homology_widget } from '../../../../../.storybook/target'

const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const id = 'table_blastp_details'
  const columnsHeader = {
    evalue: 'BLAST e-value',
    taxonomy: 'Species',
    hit: 'Hit',
    description: 'Description',
    percentage: '% Length',
    target_range: 'Target range',
    source_range: 'Source range',
  }

  return <BlastpDetails data={data} id={id} columnsHeader={columnsHeader} />
}

export default {
  component: Wrapper,
  title: 'Table/Widgets/Homology/blastp_details',
}

export const daf8 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf8}
    tableType={homology_widget.tableType.blastpDetails}
  />
)
