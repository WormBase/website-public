import React, { useState, useMemo } from 'react'
import get from 'lodash/get'
import flattenRecursive from '../../utils/flattenRecursive'

export default function useWormBaseTableFilter(data = []) {
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
                return Object.values(dataFlat[index]).reduce((any, value = '') => {
                  return any || new RegExp(filterValue, 'i').test(value)
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

  const tableOptions = React.useMemo(
    () => ({
      filterTypes,
      globalFilter: 'testGlobalFilter',
      initialState: {
        globalFilter: 'testGlobalFilter',
      },
    }),
    [filterTypes]
  )

  return {
    filters,
    setFilters,
    options, // options for the combobox
    tableOptions,
  }
}
