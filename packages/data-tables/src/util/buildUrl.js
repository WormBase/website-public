// export function buildUrl(id, clas, resourcePages) {

const ACE2WB = {
  do_term: 'disease',
};

function ace2wb(aceClass) {
  if (aceClass) {
    const aceClassLowercase = aceClass.toLowerCase();
    return ACE2WB[aceClassLowercase] || aceClassLowercase;
  }
}

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
  const someClass = ace2wb(tag.class);
  if (resourcePages.has(someClass)) {
    return `/resources/${someClass}/${id}`;
  } else {
    return `/species/all/${someClass}/${id}`;
  }
}
