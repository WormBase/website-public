import React, { useState, useEffect, useMemo } from 'react'
import { useTable } from 'react-table'
import Allele from './Allele'

const Phenotype = () => {
  const [data, setData] = useState([])

  const proxyUrl = 'https://calm-reaches-60051.herokuapp.com/'
  const targetUrl =
    'http://rest.wormbase.org/rest/field/gene/WBGene00000904/phenotype'

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    const res = await fetch(proxyUrl + targetUrl)
    const json = await res.json()
    console.log(json.phenotype.data)
    setData(json.phenotype.data)
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
        Cell: ({ cell: { value } }) => (value === null ? 'N/A' : value),
      },
      {
        Header: 'Supporting Evidence',
        accessor: 'evidence.Allele',
        Cell: ({ cell: { value } }) => <Allele values={value} />,
      },
    ],
    []
  )

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = useTable({ columns, data })

  return (
    <div>
      <table {...getTableProps()}>
        <thead>
          {headerGroups.map((headerGroup) => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map((column) => (
                <th {...column.getHeaderProps()}>{column.render('Header')}</th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()}>
          {rows.map((row) => {
            prepareRow(row)
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map((cell) => {
                  console.log(cell.render('Cell'))
                  return <td {...cell.getCellProps()}>{cell.render('Cell')}</td>
                })}
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

export default Phenotype
