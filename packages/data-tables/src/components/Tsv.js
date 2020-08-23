import React from 'react';
import { CSVLink } from 'react-csv';
import get from 'lodash/get';

const Tsv = ({ data, id, order, ...otherProps }) => {
  const flattenRecursiveForTsv = (data, prefix = [], result = {}) => {
    if (Object(data) !== data) {
      if (data) {
        result[prefix.join('.')] = data;
      }
      return result;
    }

    // data: [~]
    if (Array.isArray(data)) {
      // data: [[~],[~],...]
      if (Array.isArray(data[0])) {
        // data: [[],[],...]
        if (data.flat().length === 0) {
          result[prefix.join('.')] = '';
          return result;
        }
        // data: [[{Tag}],[{Tag}],[],[{Tag}],...]
        if (
          data.flat()[0].class !== undefined &&
          data.flat()[0].id !== undefined &&
          data.flat()[0].label !== undefined
        ) {
          const tagTypeDataArr = data.map((da) => {
            if (da.length === 0) {
              return '';
            }
            return da.map((d) => {
              return `${d.label}[${d.id}]`;
            });
          });
          result[prefix.join('.')] = tagTypeDataArr.join(';');
          return result;
        }

        console.error(data);
        throw new Error(
          'Data is surely array of array. But it is not Tag type one.'
        );
      }

      // data: [{~},{~},...]
      if (typeof data[0] === 'object') {
        // data: [{Tag},{Tag},...]
        if (
          data[0].class !== undefined &&
          data[0].id !== undefined &&
          data[0].label !== undefined
        ) {
          const tagTypeDataArr = data.map((d) => `${d.label}[${d.id}]`);
          result[prefix.join('.')] = tagTypeDataArr.join(';');
          return result;
        }

        // data: [{Pato},{Pato},...]
        if (data[0].pato_evidence) {
          const patoTypeDataArr = data.map(
            (d) =>
              `${d.pato_evidence.entity_term.label}[${d.pato_evidence.entity_term.id}] ${d.pato_evidence.pato_term}`
          );
          result['entity'] = patoTypeDataArr.join(';');
          return result;
        }

        console.error(data);
        throw new Error(
          'Data is surely array of object. But it is neigher Tag type one nor Pato type one.'
        );
      }

      // data: [~,~,...]
      result[prefix.join('.')] = data.join(';');
      return result;
    }

    // data: {Tag}
    if (
      data.class !== undefined &&
      data.id !== undefined &&
      data.label !== undefined
    ) {
      result[prefix.join('.')] = `${data.label}[${data.id}]`;
      return result;
    }

    // data: {Species}
    if (data.species !== undefined && data.genus !== undefined) {
      result['species'] = `${data.genus}. ${data.species}`;
      return result;
    }

    Object.keys(data).forEach((key) => {
      flattenRecursiveForTsv(data[key], [...prefix, key], result);
    });
    return result;
  };

  const flattenedData = data.map((d) => flattenRecursiveForTsv(d));

  const uniqueKeys = Object.keys(
    flattenedData.reduce((result, obj) => {
      return Object.assign(result, obj);
    }, {})
  );

  const uniqueKeysSortedByColumnOrder = order.map((ord) => {
    const filterFunc = (fi) => {
      const regex = new RegExp(`^${ord}\\..+`);
      if (fi === ord || regex.test(fi)) {
        return true;
      }
      return false;
    };

    return uniqueKeys.filter((u) => filterFunc(u)).sort();
  });

  const sortByKey = (array, key) => {
    const checkAndModify = (data) => {
      if (data === undefined) {
        return null;
      }
      if (!isNaN(Number(data))) {
        return Number(data);
      }
      return data.toLowerCase();
    };

    return array.sort((a, b) => {
      const ax = checkAndModify(get(a, key));
      const bx = checkAndModify(get(b, key));
      return ax === bx ? 0 : ax > bx ? 1 : -1;
    });
  };

  const getKeyUsedByDefaultColumnSort = (keys) => {
    if (keys[0].length === 1) {
      return keys[0];
    }

    const regex = new RegExp(`.+\\.text$`);
    const found = keys[0].find((k) => regex.test(k));
    if (found) {
      return found;
    }

    console.error(keys);
    throw new Error(
      'It is not possible to determine which key in the data is used for the default sorting'
    );
  };

  return (
    <CSVLink
      data={sortByKey(
        flattenedData,
        getKeyUsedByDefaultColumnSort(uniqueKeysSortedByColumnOrder)
      )}
      headers={uniqueKeysSortedByColumnOrder.flat()}
      separator={','}
      filename={`${id}.csv`}
      {...otherProps}
    >
      Download CSV
    </CSVLink>
  );
};

export default Tsv;
