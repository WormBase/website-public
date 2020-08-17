const compareBasic = (a, b) => {
  return a === b ? 0 : a > b ? 1 : -1;
};

const getRowValueByColumnID = (row, columnId) => row.values[columnId];

const numberWithScientificNotation = (rowA, rowB, columnId) => {
  const a = Number(getRowValueByColumnID(rowA, columnId));
  const b = Number(getRowValueByColumnID(rowB, columnId));
  return compareBasic(a, b);
};

const sortBySpecies = (rowA, rowB, columnId) => {
  const a = `${getRowValueByColumnID(rowA, columnId).genus}${
    getRowValueByColumnID(rowA, columnId).species
  }`;
  const b = `${getRowValueByColumnID(rowB, columnId).genus}${
    getRowValueByColumnID(rowB, columnId).species
  }`;
  return compareBasic(a, b);
};

const sortByText = (rowA, rowB, columnId) => {
  const a = getRowValueByColumnID(rowA, columnId).text;
  const b = getRowValueByColumnID(rowB, columnId).text;
  if (!isNaN(Number(a))) {
    return compareBasic(a, b);
  }
  return compareBasic(a.toLowerCase(), b.toLowerCase());
};

const sortByEvidence = (rowA, rowB, columnId) => {
  const a = Object.values(getRowValueByColumnID(rowA, columnId))[0].text.label;
  const b = Object.values(getRowValueByColumnID(rowB, columnId))[0].text.label;
  return compareBasic(a.toLowerCase(), b.toLowerCase());
};

const sortByTextLabel = (rowA, rowB, columnId) => {
  const a = getRowValueByColumnID(rowA, columnId).text.label;
  const b = getRowValueByColumnID(rowB, columnId).text.label;
  return compareBasic(a.toLowerCase(), b.toLowerCase());
};

const sortByTagData = (rowA, rowB, columnId) => {
  const a = rowA.values[columnId].label;
  const b = rowB.values[columnId].label;
  return compareBasic(a.toLowerCase(), b.toLowerCase());
};

const sortByArrayValue = (rowA, rowB, columnId) => {
  const aa = getRowValueByColumnID(rowA, columnId);
  const a = aa === undefined || aa.length === 0 ? null : aa[0];
  const bb = getRowValueByColumnID(rowB, columnId);
  const b = bb === undefined || bb.length === 0 ? null : bb[0];
  return compareBasic(a.toLowerCase(), b.toLowerCase());
};

const caseInsensitiveAlphaNumeric = (rowA, rowB, columnId) => {
  const getRowValueByColumnID = (row, columnId) => row.values[columnId];

  const toString = (a) => {
    if (typeof a === 'number') {
      if (isNaN(a) || a === Infinity || a === -Infinity) {
        return '';
      }
      return String(a);
    }
    if (typeof a === 'string') {
      return a;
    }
    return '';
  };
  const reSplitAlphaNumeric = /([0-9]+)/gm;

  let a = getRowValueByColumnID(rowA, columnId);
  let b = getRowValueByColumnID(rowB, columnId);
  // Force to strings (or "" for unsupported types)
  // And lowercase to accomplish insensitive sort
  a = toString(a).toLowerCase();
  b = toString(b).toLowerCase();

  // Split on number groups, but keep the delimiter
  // Then remove falsey split values
  a = a.split(reSplitAlphaNumeric).filter(Boolean);
  b = b.split(reSplitAlphaNumeric).filter(Boolean);

  // While
  while (a.length && b.length) {
    let aa = a.shift();
    let bb = b.shift();

    const an = parseInt(aa, 10);
    const bn = parseInt(bb, 10);

    const combo = [an, bn].sort();

    // Both are string
    if (isNaN(combo[0])) {
      if (aa > bb) {
        return 1;
      }
      if (bb > aa) {
        return -1;
      }
      continue;
    }

    // One is a string, one is a number
    if (isNaN(combo[1])) {
      return isNaN(an) ? -1 : 1;
    }

    // Both are numbers
    if (an > bn) {
      return 1;
    }
    if (bn > an) {
      return -1;
    }
  }

  return a.length - b.length;
};

const decideSortType = (rowA, rowB, columnId) => {
  const rowVal = getRowValueByColumnID(rowA, columnId);

  if (rowVal) {
    if (Array.isArray(rowVal) && typeof rowVal[0] !== 'object') {
      return sortByArrayValue(rowA, rowB, columnId);
    }
    if (rowVal.species) {
      return sortBySpecies(rowA, rowB, columnId);
    }
    if (!isNaN(Number(rowVal))) {
      return numberWithScientificNotation(rowA, rowB, columnId);
    }
    if (rowVal.evidence && rowVal.text) {
      if (rowVal.text.label) {
        return sortByTextLabel(rowA, rowB, columnId);
      }
      return sortByText(rowA, rowB, columnId);
    }
    if (rowVal.class && rowVal.label) {
      return sortByTagData(rowA, rowB, columnId);
    }
    const objValOfRowVal = Object.values(rowVal);
    if (
      Object.keys(...objValOfRowVal).includes('evidence') &&
      Object.keys(...objValOfRowVal).includes('text')
    ) {
      return sortByEvidence(rowA, rowB, columnId);
    }
  }
  return caseInsensitiveAlphaNumeric(rowA, rowB, columnId);
};

export { decideSortType };
