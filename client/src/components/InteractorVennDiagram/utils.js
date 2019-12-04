export function combination([...list] = [], n) {
  if (list.length < n) {
    throw new Error(
      `Cannot pick ${n} items from a list of length ${list.length}`
    );
  } else if (n <= 0) {
    return [];
  } else if (n === 1) {
    return list.map((item) => [item]);
  } else if (n === list.length) {
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

export function subsets([...list] = [], minSize = 1, maxSize = list.length) {
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
// console.log(subsets(['physical', 'genetic', 'regulatory']));

export function isSuperSet(list1, list2) {
  // is list1 a super set of list2
  const set1 = new Set(list1);
  return list2.every((item) => set1.has(item));
}

// console.log(isSuperSet([1, 2, 3], [2, 3]));
