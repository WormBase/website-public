const numberWithScientificNotation = (rowA, rowB, columnId) => {
  const NumberdEValueOfRowA = Number(rowA.values[columnId]);
  const NumberdEValueOfRowB = Number(rowB.values[columnId]);
  if (NumberdEValueOfRowA < NumberdEValueOfRowB) {
    return -1;
  } else if (NumberdEValueOfRowA > NumberdEValueOfRowB) {
    return 1;
  } else return 0;
};

const sortBySpecies = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = `${rowA.values[columnId].genus}${rowA.values[columnId].species}`;
  const comparisonStandardOfRowB = `${rowB.values[columnId].genus}${rowB.values[columnId].species}`;
  return comparisonStandardOfRowA > comparisonStandardOfRowB
    ? 1
    : comparisonStandardOfRowA < comparisonStandardOfRowB
    ? -1
    : 0;
};

const sortByMethods = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = rowA.values[columnId][0].label;
  const comparisonStandardOfRowB = rowB.values[columnId][0].label;
  return comparisonStandardOfRowA > comparisonStandardOfRowB
    ? 1
    : comparisonStandardOfRowA < comparisonStandardOfRowB
    ? -1
    : 0;
};

const sortByInteractions = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = rowA.values[columnId][0].label;
  const lowerCasedComparisonStandardOfRowA = comparisonStandardOfRowA.toLowerCase();

  const comparisonStandardOfRowB = rowB.values[columnId][0].label;
  const lowerCasedComparisonStandardOfRowB = comparisonStandardOfRowB.toLowerCase();

  return lowerCasedComparisonStandardOfRowA > lowerCasedComparisonStandardOfRowB
    ? 1
    : lowerCasedComparisonStandardOfRowA < lowerCasedComparisonStandardOfRowB
    ? -1
    : 0;
};

const sortByCitations = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = rowA.values[columnId][0][0]?.label || '';
  const lowerCasedComparisonStandardOfRowA = comparisonStandardOfRowA.toLowerCase();

  const comparisonStandardOfRowB = rowB.values[columnId][0][0]?.label || '';
  const lowerCasedComparisonStandardOfRowB = comparisonStandardOfRowB.toLowerCase();

  return lowerCasedComparisonStandardOfRowA > lowerCasedComparisonStandardOfRowB
    ? 1
    : lowerCasedComparisonStandardOfRowA < lowerCasedComparisonStandardOfRowB
    ? -1
    : 0;
};

const sortByDescriptionType0 = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = rowA.values[columnId].text.toLowerCase();
  const comparisonStandardOfRowB = rowB.values[columnId].text.toLowerCase();
  return comparisonStandardOfRowA > comparisonStandardOfRowB
    ? 1
    : comparisonStandardOfRowA < comparisonStandardOfRowB
    ? -1
    : 0;
};
const sortByDescriptionType1 = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = rowA.values[columnId][0].toLowerCase();
  const comparisonStandardOfRowB = rowB.values[columnId][0].toLowerCase();
  return comparisonStandardOfRowA > comparisonStandardOfRowB
    ? 1
    : comparisonStandardOfRowA < comparisonStandardOfRowB
    ? -1
    : 0;
};
const sortByEvidence = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = Object.values(
    rowA.values[columnId]
  )[0].text.label.toLowerCase();
  const comparisonStandardOfRowB = Object.values(
    rowB.values[columnId]
  )[0].text.label.toLowerCase();
  return comparisonStandardOfRowA > comparisonStandardOfRowB
    ? 1
    : comparisonStandardOfRowA < comparisonStandardOfRowB
    ? -1
    : 0;
};
const sortByDatabase = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = rowA.values[columnId]
    ? rowA.values[columnId][0].label.toLowerCase()
    : '';
  const comparisonStandardOfRowB = rowB.values[columnId]
    ? rowB.values[columnId][0].label.toLowerCase()
    : '';
  return comparisonStandardOfRowA > comparisonStandardOfRowB
    ? 1
    : comparisonStandardOfRowA < comparisonStandardOfRowB
    ? -1
    : 0;
};
const sortByAnatomicalSites = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = rowA.values[
    columnId
  ].text.label.toLowerCase();
  const comparisonStandardOfRowB = rowB.values[
    columnId
  ].text.label.toLowerCase();
  return comparisonStandardOfRowA > comparisonStandardOfRowB
    ? 1
    : comparisonStandardOfRowA < comparisonStandardOfRowB
    ? -1
    : 0;
};
const sortByMedianOrMean = (rowA, rowB, columnId) => {
  const comparisonStandardOfRowA = rowA.values[columnId].text;
  const comparisonStandardOfRowB = rowB.values[columnId].text;
  return comparisonStandardOfRowA > comparisonStandardOfRowB
    ? 1
    : comparisonStandardOfRowA < comparisonStandardOfRowB
    ? -1
    : 0;
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
  const rowVal = rowA.values[columnId];
  if (rowVal) {
    if (rowVal.species) {
      return sortBySpecies(rowA, rowB, columnId);
    }
    if (!isNaN(Number(rowVal))) {
      return numberWithScientificNotation(rowA, rowB, columnId);
    }
    if (rowVal.evidence && rowVal.text) {
      if (rowVal.text.label) {
        return sortByAnatomicalSites(rowA, rowB, columnId);
      }
      return sortByDescriptionType0(rowA, rowB, columnId);
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

export {
  numberWithScientificNotation,
  sortBySpecies,
  sortByMethods,
  sortByInteractions,
  sortByCitations,
  sortByDescriptionType0,
  sortByDescriptionType1,
  sortByEvidence,
  sortByDatabase,
  sortByAnatomicalSites,
  sortByMedianOrMean,
  caseInsensitiveAlphaNumeric,
  decideSortType,
};
