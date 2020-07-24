export default function flattenRecursive(data, prefix = [], result = {}) {
  if (Object(data) !== data) {
    if (data) {
      result[prefix.join('.')] = data
    }
    return result
  } else {
    Object.keys(data).forEach((key) => {
      flattenRecursive(data[key], [...prefix, key], result)
    })
    return result
  }
}
