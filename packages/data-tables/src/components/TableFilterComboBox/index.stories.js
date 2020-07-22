import React, { useState, useEffect, useMemo } from 'react'
import TableFilterComboBox from './index';
import loadData from '../../services/loadData';

export default {
  title: 'Misc/Table Filter Combo Box',
};

export const mock = () => (
  <TableFilterComboBox options={{
    food: ['bread', 'egg', 'lettuce', 'tomato'],
    drinks: ['water', 'soda', 'milk'],
  }} />
);

function flattenRecursive(data, prefix = [], result = {}) {
  if (Object(data) !== data) {
    if (data) {
      result[prefix.join('.')] = data
    }
    return result
  } else {
    Object.keys(data).forEach((key) => {
      flattenRecursive(data[key], [...prefix, key], result)
    })
    return result
  }
}

export const PhenotypeByInteraction = () => {
  const [data, setData] = useState([])
  const wbId = 'WBGene00015146'
  const tableType = 'phenotype_by_interaction'

  useEffect(() => {
    loadData(wbId, tableType).then((json) => {
      setData(json.data)
    })
  }, [wbId, tableType])

  const attributeKeysAll = []
  console.log(flattenRecursive({a: 1}));
  console.log(flattenRecursive({a: [2, 4]}));
  console.log(flattenRecursive({a: [2, null]}));
  console.log(data[0]);
  console.log(flattenRecursive(data[0]));

  const options = useMemo(() => {
    return data.reduce((result, item) => {
      const itemflat = flattenRecursive(item)
      Object.keys(itemflat).forEach((key, i) => {
        if (!result[key]) {
          result[key] = []
        }
        if (result[key].indexOf(itemflat[key]) === -1) {
          result[key].push(itemflat[key])
        }
      })
      return result;
    }, {})
  }, [data])

  console.log(options);

  return (
    <TableFilterComboBox options={options} />
  )
}
