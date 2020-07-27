import React, { useState, useEffect } from 'react'
import Orthologs from '../Orthologs'
import loadData from '../../../../services/loadData'
import { homology_widget } from '../../../../../.storybook/target'

const Wrapper = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const id = 'table_nematode_orthologs'
  const columnsHeader = {
    species: 'Species',
    ortholog: 'Ortholog',
    method: 'Method',
  }

  return <Orthologs data={data} id={id} columnsHeader={columnsHeader} />
}

export default {
  component: Wrapper,
  title: 'Table/Widgets/Homology/other_orthologs',
}

export const daf8 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf8}
    tableType={homology_widget.tableType.otherOrthologs}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf16}
    tableType={homology_widget.tableType.otherOrthologs}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={homology_widget.WBid.mig2}
    tableType={homology_widget.tableType.otherOrthologs}
  />
)
