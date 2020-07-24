import React, { useState, useEffect } from 'react'
import Blastp from '../Blastp'
import loadData from '../../../../services/loadData'
import { homology_widget } from '../../../../../.storybook/target'

const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data.hits)
    })
  }, [WBid, tableType])

  const id = 'table_best_blastp_matches'
  const columnsHeader = {
    evalue: 'BLAST e-value',
    taxonomy: 'Species',
    hit: 'Hit',
    description: 'Description',
    percent: '% Length',
  }

  return <Blastp data={data} id={id} columnsHeader={columnsHeader} />
}

export default {
  component: Wrapper,
  title: 'Table|Widgets/Homology/best_blastp_matches',
}

export const daf8 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf8}
    tableType={homology_widget.tableType.bestBlastpMatches}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf16}
    tableType={homology_widget.tableType.bestBlastpMatches}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={homology_widget.WBid.mig2}
    tableType={homology_widget.tableType.bestBlastpMatches}
  />
)
