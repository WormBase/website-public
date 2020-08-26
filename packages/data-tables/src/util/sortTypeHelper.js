const compareBasic = (a, b) => {
  return a === b ? 0 : a > b ? 1 : -1;
};

const getRowValueByColumnID = (row, columnId) => row.values[columnId];

const decideSortType = (rowA, rowB, columnId) => {
  const convertInvalidValueToEmptyString = (cellValue) => {
    if (cellValue === null || cellValue === undefined) {
      return '';
    }
    if (Array.isArray(cellValue)) {
      if (cellValue.length === 0) {
        return '';
      }
      return cellValue[0];
    }
    return cellValue;
  };

  const extractValueToBeSorted = (values) => {
    if (values.species) {
      return `${values.genus}${values.species}`;
    }
    if (values.class && values.label) {
      return values.label;
    }
    if (values.evidence && values.text) {
      if (values.text.class && values.text.label) {
        return values.text.label;
      }
      return values.text;
    }
    return values;
  };

  const convertToNumOrLowerCaseStr = (toBeSorted) => {
    if (!isNaN(Number(toBeSorted)) && toBeSorted !== '') {
      return Number(toBeSorted);
    }
    if (typeof toBeSorted === 'string') {
      // check if it contains HTML elements
      if (/<\/?[a-z][\s\S]*>/i.test(toBeSorted)) {
        // extract content from HTML string, and make it lower case
        return toBeSorted.replace(/<[^>]+>/g, '').toLowerCase();
      }
      return toBeSorted.toLowerCase();
    }

    console.error(toBeSorted);
    throw new Error(
      'It is not possible to sort by a value that is neither number nor string'
    );
  };

  const matchType = (x, y) => {
    if (typeof x !== typeof y) {
      return [x.toString(), y.toString()];
    }
    return [x, y];
  };

  const a = getRowValueByColumnID(rowA, columnId);
  const b = getRowValueByColumnID(rowB, columnId);

  const ax = convertToNumOrLowerCaseStr(
    extractValueToBeSorted(convertInvalidValueToEmptyString(a))
  );
  const bx = convertToNumOrLowerCaseStr(
    extractValueToBeSorted(convertInvalidValueToEmptyString(b))
  );

  return compareBasic(...matchType(ax, bx));
};

export { decideSortType };
