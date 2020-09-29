import React from 'react';
import { CSVLink } from 'react-csv';
import get from 'lodash/get';

const Tsv = ({ data, id, order, ...otherProps }) => {
  const isTag = (x) => {
    return x.class !== undefined && x.label !== undefined;
  };

  const update = (result, path, value) => {
    const key = path.join('.');
    if (result[key]) {
      result[key] += ` ${value}`;
    } else {
      result[key] = value;
    }
  };

  const flattenRecursiveForTsv = (data, prefix = [], result = {}) => {
    // data: scalar
    if (Object(data) !== data) {
      if (data === null) {
        update(result, prefix, '');
      } else {
        // check if it contains HTML elements
        if (/<\/?[a-z][\s\S]*>/i.test(data)) {
          // extract content from HTML string on the right side
          update(result, prefix, data.replace(/<[^>]+>/g, ''));
        } else {
          update(result, prefix, data);
        }
      }
      return result;
    }

    // data: {Tag}
    if (isTag(data)) {
      update(result, prefix, `${data.label}[${data.id}]`);
      return result;
    }

    // data: {Species}
    if (data.species !== undefined && data.genus !== undefined) {
      update(result, prefix, `${data.genus}. ${data.species}`);
      return result;
    }

    // data: {Pato}
    if (data.pato_evidence && data.pato_evidence.entity_term) {
      update(
        result,
        prefix,
        `${data.pato_evidence.entity_term.label}[${data.pato_evidence.entity_term.id}] ${data.pato_evidence.pato_term}`
      );
      return result;
    }

    // data: [Any]
    if (Array.isArray(data)) {
      Object.keys(data).forEach((key) => {
        flattenRecursiveForTsv(data[key], [...prefix], result);
      });
      return result;
    }

    Object.keys(data).forEach((key) => {
      flattenRecursiveForTsv(data[key], [...prefix, key], result);
    });
    return result;
  };

  const flattenedData = data.map((dat) => flattenRecursiveForTsv(dat));

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
