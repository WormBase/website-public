import { usePlugin } from 'tinacms';
import {
  useGithubJsonForm,
  useGithubToolbarPlugins,
} from 'react-tinacms-github';
import { InlineForm, InlineTextField, InlineTextarea } from 'react-tinacms-inline';
import { getJsonPreviewProps } from '../utils/getJsonPreviewProps';
import { fileToUrl } from '../utils/fileToUrl';

const NoteBookTemplate = ({
  preview,
  file,
  slug,
}) => {
  const [data, form] = useGithubJsonForm(file, formOptions)
  usePlugin(form);
  useGithubToolbarPlugins();

  return (
    <InlineForm form={form}>
      <main>
        <h2>
          <InlineTextField name="metadata.wormbase.title" />
        </h2>
        <div>Edit metadata for {slug}.ipynb</div>
        <section>
          <InlineTextarea name="metadata.wormbase.shortDescription" />
        </section>
        <pre>{JSON.stringify(data, null, 2)}</pre>
      </main>
    </InlineForm>
  );
}

export default NoteBookTemplate;

const formOptions = {
  label: 'Jupyter Notebook',
  fields: [
    {
      name: 'metadata.wormbase.title',
      label: 'Name',
      component: 'text',
      placeholder: '...',
    },
    {
      name: 'metadata.wormbase.shortDescription',
      label: 'Short description',
      component: 'textarea',
      placeholder: 'Please enter a short description'
    },
  ],
};

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
      slug: slug,
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
