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
  const comparisonStandardOfRowA = rowA.values[
    columnId
  ][0].text.label.toLowerCase();
  const comparisonStandardOfRowB = rowB.values[
    columnId
  ][0].text.label.toLowerCase();
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
};
