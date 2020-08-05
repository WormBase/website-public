// export function buildUrl(id, clas, data) {
export function buildUrl(tag, data) {
  const { id } = tag
  const someClass = tag.class
  if (data.has(someClass)) {
    return `/search/${someClass}/${id}`
  } else {
    return `/species/all/${someClass}/${id}`
  }
}
