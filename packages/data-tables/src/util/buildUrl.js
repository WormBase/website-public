// export function buildUrl(id, clas, resourcePages) {

const resourcePages = new Set([
  'analysis',
  'author',
  'gene_class',
  'laboratory',
  'molecule',
  'motif',
  'paper',
  'person',
  'reagents',
  'disease',
  'transposon_family',
  'wbprocess',
]);

export function buildUrl(tag) {
  const { id } = tag;
  const someClass = tag.class;
  if (resourcePages.has(someClass)) {
    return `/resources/${someClass}/${id}`;
  } else {
    return `/species/all/${someClass}/${id}`;
  }
}
