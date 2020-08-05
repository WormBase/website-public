export function hasContent(obj) {
  if (typeof obj === 'object') {
    return obj !== null && Object.keys(obj).length > 0
  } else {
    return typeof obj !== 'undefined'
  }
}
