function buildUrl(tag) {
  const {id} = tag;
  return `/species/all/${tag.class}/${id}`;
}

export {
  buildUrl
}
