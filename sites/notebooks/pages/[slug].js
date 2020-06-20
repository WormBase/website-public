import { getJsonPreviewProps } from '../utils/getJsonPreviewProps';
import { fileToUrl } from '../utils/fileToUrl';

const NoteBookTemplate = ({
  preview,
  file,
}) => {
  return 'zzz' + preview;
}

export default NoteBookTemplate;

export async function getStaticProps(context) {
  const {
    preview,
    previewData
  } = context;

  const { slug } = context.params;

  // get files from Github or locally
  const jsonProps = await getJsonPreviewProps(
    `content/notebooks/${slug}.ipynb`,
    preview,
    previewData,
  );

  if ((jsonProps.props.error && jsonProps.props.error.code) === 'ENOENT') {
    return { props: {} } // will render the 404 error
  }

  return {
    props: {
      ...jsonProps.props,
    },
  }
}

export async function getStaticPaths() {
  // fetch all notebooks
  const fg = require('fast-glob');
  const notebooks = await fg('./content/notebooks/**/*.ipynb');

  return {
    paths: notebooks.map(file => {
      const slug = fileToUrl(file, 'notebooks')
      return { params: { slug } }
    }),
    fallback: true,
  };
}
