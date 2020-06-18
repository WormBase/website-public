import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import Allele from './Allele'
import RNAi from './RNAi'
import Entity from './Entity'
import Overexpression from './Overexpression'
import loadData from '../../../../services/loadData'

const Phenotype = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => setData(json.data))
  }, [WBid, tableType])

  const showEntities = (value) => {
    if (value === null) {
      return 'N/A'
    } else {
      return <Entity values={value} />
    }
  }

  const showEvidence = (value) => {
    if (value.Allele && value.RNAi) {
      return (
        <>
          <div
            style={{
              marginBottom: '20px',
            }}
          >
            <Allele values={value.Allele} />
          </div>
          <RNAi values={value.RNAi} />
        </>
      )
    } else if (value.Allele) {
      return <Allele values={value.Allele} />
    } else if (value.RNAi) {
      return <RNAi values={value.RNAi} />
    } else {
      return <Overexpression values={value} />
    }
  }

  const columns = useMemo(
    () => [
      {
        Header: 'Phenotype',
        accessor: 'phenotype.label',
      },
      {
        Header: 'Entities Affected',
        accessor: 'entity',
        Cell: ({ cell: { value } }) => showEntities(value),
        disableFilters: true,
        sortType: 'sortByEntity',
      },
      {
        Header: 'Supporting Evidence',
        accessor: 'evidence',
        Cell: ({ cell: { value } }) => showEvidence(value),
        disableSortBy: true,
        filter: 'evidenceFilter',
        minWidth: 240,
        width: 540,
      },
    ],
    []
  )

  return (
    <>
      <Table columns={columns} data={data} tableType={tableType} />
    </>
  )
}

export default Phenotype
