import React, { useState, useMemo } from 'react'
import get from 'lodash/get'

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

export function useWormBaseTableFilter(data) {
  const dataFlat = useMemo(() => {
    return data.map((item) => {
      return flattenRecursive(item)
    }, {})
  }, [data])

  const options = useMemo(() => {
    return dataFlat.reduce((result, itemflat) => {
      Object.keys(itemflat).forEach((key, i) => {
        if (!result[key]) {
          result[key] = ['(non-empty)', '(empty)']
        }
        if (result[key].indexOf(itemflat[key]) === -1) {
          result[key].push(itemflat[key])
        }
      })
      return result;
    }, {})
  }, [dataFlat])

  const [filters, setFilters] = useState([])

  const filterTypes = React.useMemo(
    () => ({
      testGlobalFilter: (rows,b,c) => {
        // const filters = [
        //   {
        //     key: 'evidence.RNAi.text.id',
        //     value: 'WBRNAi00073492',
        //   },
        //   {
        //     key: 'phenotype.id',
        //     value: 'WBPhenotype:0000688',
        //   },
        // ]
        return rows.filter(({values, index}) => {
          const isEmpty = (value) => {
            return (
              !value && value !== 0
            )
          }
          return filters.reduce((isMatchSoFar, { key, value: filterValue }) => {
            if (isMatchSoFar) {
              if (key === 'search') {
                return Object.values(dataFlat[index]).reduce((any, value) => {
                  return any || value === filterValue
                }, false)
              } else {
                const value = get(values, key.split('.'));
                return (
                  value === filterValue ||
                  (filterValue === '(empty)' && isEmpty(value)) ||
                  (filterValue === '(non-empty)' && !isEmpty(value))
                )
              }
            } else {
              return false;
            }
          }, true)
        });
      }
    }),
    [filters, dataFlat]
  )

  return {
    filters,
    setFilters,
    filterTypes,
    globalFilter: 'testGlobalFilter',
    options,
  }
}
