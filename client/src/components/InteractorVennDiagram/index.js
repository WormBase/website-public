import React from 'react';
import PropTypes from 'prop-types';

function combination(list = [], n) {
  if (n <= 0) {
    return [];
  } else if (list.length <= n) {
    return [list];
  } else {
    const [item, ...rest] = list;
    return [
      ...combination(rest, n - 1).map((subCombo) => {
        return [item, ...subCombo];
      }),
      ...combination(rest, n),
    ];
  }
}

function subsets(list, minSize = 1, maxSize = list.length) {
  let results = [];
  for (let i = minSize; i <= maxSize; i++) {
    results = [...results, ...combination(list, i)];
  }
  return results;
}

// console.log(combination([1, 2, 3, 4], 4));
// console.log(combination([1, 2, 3, 4], 3));
// console.log(combination([1, 2, 3, 4], 2));
// console.log(combination([1, 2, 3, 4], 1));
// console.log(combination([1, 2, 3, 4], 0));
// console.log(subsets([1, 2, 3, 4]));
console.log(subsets(['physical', 'genetic', 'regulatory']));

export default function InteractorVennDiagram({ data = [] }) {
  return <div>Place holder for venn diagram </div>;
}

InteractorVennDiagram.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      type: PropTypes.string,
      interactor: PropTypes.shape({
        id: PropTypes.string,
      }),
    })
  ),
};
