import pluralize from 'pluralize';
export { pluralize };

export function capitalize(word) {
  if (word) {
    return word.replace(/^(\w)/, function(match) {
      return match[0].toUpperCase();
    });
  } else {
    return word;
  }
}
