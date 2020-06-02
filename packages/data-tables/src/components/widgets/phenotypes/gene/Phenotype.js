import React, { useState, useEffect } from 'react'

const Phenotype = () => {
  const [tableData, setTableData] = useState([])

  const proxyUrl = 'https://calm-reaches-60051.herokuapp.com/'
  const targetUrl =
    'http://rest.wormbase.org/rest/widget/gene/WBGene00000904/phenotype'

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    const res = await fetch(proxyUrl + targetUrl)
    const data = await res.json()
    setTableData(JSON.stringify(data))
  }

  return (
    <div>
      <h2>data from {targetUrl}</h2>
      {tableData}
    </div>
  )
}

export default Phenotype
