import React, { useState, useMemo } from 'react';

// Inspired by the document representation of Elasticsearch,
// flatten the keys using dot notation to remove nestedness, and
// make the leaf node an array to accommodate any cardinality

function flattenLossyRecursive(data, prefix = [], result = {}) {
  if (Object(data) !== data) {
    if (data || data === 0) {
      const key = prefix.join('.');
      result[key] = result[key] || [];
      result[key].push(data);
    }
    return result;
  } else if (data.id && data.label && data.class) {
    // consider a leaf node
    const key = prefix.join('.');
    result[key] = result[key] || [];
    result[key].push(`${data.label} [${data.id}]`);
    return result;
  } else {
    Object.keys(data).forEach((key) => {
      if (key === 'text' || parseInt(key) >= 0) {
        flattenLossyRecursive(data[key], prefix, result); // same prefix
      } else {
        flattenLossyRecursive(data[key], [...prefix, key], result);
      }
    });
    return result;
  }
}

export default function useWormBaseTableFilter(data = []) {
  const dataFlat = useMemo(() => {
    return data.map((item) => {
      return flattenLossyRecursive(item);
    }, {});
  }, [data]);

  const options = useMemo(() => {
    return dataFlat.reduce((result, itemflat) => {
      Object.keys(itemflat).forEach((key, i) => {
        if (!result[key]) {
          result[key] = ['(non-empty)', '(empty)'];
        }
        itemflat[key].forEach((item, i) => {
          if (result[key].indexOf(item) === -1) {
            result[key].push(item);
          }
        });
      });
      return result;
    }, {});
  }, [dataFlat]);

  const [filters, setFilters] = useState([]);

  const filterTypes = React.useMemo(
    () => ({
      testGlobalFilter: (rows, b, c) => {
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
        return rows.filter(({ index }) => {
          const isContent = (value) => {
            return value && Object.keys(value).length;
          };
          return filters.reduce((isMatchSoFar, { key, value: filterValue }) => {
            if (isMatchSoFar) {
              if (key === 'search') {
                return Object.values(dataFlat[index]).reduce(
                  (any, value = '') => {
                    return any || new RegExp(filterValue, 'i').test(value);
                  },
                  false
                );
              } else {
                const valuesFlat = dataFlat[index][key] || [];
                return (
                  (filterValue === '(empty)' && !isContent(valuesFlat)) ||
                  (filterValue === '(non-empty)' && isContent(valuesFlat)) ||
                  valuesFlat.reduce((any, value) => {
                    return any || value === filterValue;
                  }, false)
                );
              }
            } else {
              return false;
            }
          }, true);
        });
      },
    }),
    [filters, dataFlat]
  );

  const tableOptions = React.useMemo(
    () => ({
      filterTypes,
      globalFilter: 'testGlobalFilter',
      initialState: {
        globalFilter: 'testGlobalFilter',
      },
    }),
    [filterTypes]
  );

  return {
    filters,
    setFilters,
    options, // options for the combobox
    tableOptions,
  };
}
