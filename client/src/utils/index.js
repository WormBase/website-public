export function pluralize(word, count) {
  return count > 1 ? `${word}s` : word;
}

export function capitalize(word) {
  if (word) {
    return word.replace(/^(\w)/, function(match) {
      return match[0].toUpperCase();
    });
  } else {
    return word;
  }
}
