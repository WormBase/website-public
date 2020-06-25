import Head from 'next/head'
import { getGithubPreviewProps, parseJson, getFiles as getGithubFiles } from 'next-tinacms-github'
import {
  useGithubJsonForm,
  useGithubToolbarPlugins,
} from 'react-tinacms-github'
import { usePlugin } from 'tinacms'
import { getJsonPreviewProps } from '../utils/getJsonPreviewProps';
import { fileToUrl } from '../utils/fileToUrl';


export default function Home({ file, notebooks }) {
  const formOptions = {
    label: 'Home Page',
    fields: [
      { name: 'title', component: 'text' },
      { name: 'tagline', component: 'text' },
    ],
  }

  const [data, form] = useGithubJsonForm(file, formOptions)
  usePlugin(form);
  useGithubToolbarPlugins()

  return (
    <div className="container">
      <Head>
        <title>Create Next App</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main>
        <h1 className="title">
          {data.title}
        </h1>

        <p className="description">
          {data.tagline}
        </p>

        <div className="grid">
          {
            notebooks.map((notebook = {}) => {
              const { title, shortDescription, dateLastUpdated } = (notebook.metadata && notebook.metadata.wormbase) || {};
              const authors = (notebook.metadata && notebook.metadata.authors) || [];

              return (
                <a key={notebook.id} href={`/${notebook.slug}`} className="card" target="_blank" rel="noopener noreferrer">
                  <h3>{title} &rarr;</h3>
                  <p>{authors.map(({name}) => name)}</p>
                </a>
              );
            })
          }
        </div>
      </main>

      <footer>
        Powered by WormBase
      </footer>

      <style jsx>{`
        .container {
          min-height: 100vh;
          padding: 0 0.5rem;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
        }

        main {
          padding: 5rem 0;
          flex: 1;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
        }

        footer {
          width: 100%;
          height: 100px;
          border-top: 1px solid #eaeaea;
          display: flex;
          justify-content: center;
          align-items: center;
        }

        footer img {
          margin-left: 0.5rem;
        }

        footer a {
          display: flex;
          justify-content: center;
          align-items: center;
        }

        a {
          color: inherit;
          text-decoration: none;
        }

        .title a {
          color: #0070f3;
          text-decoration: none;
        }

        .title a:hover,
        .title a:focus,
        .title a:active {
          text-decoration: underline;
        }

        .title {
          margin: 0;
          line-height: 1.15;
          font-size: 4rem;
        }

        .title,
        .description {
          text-align: center;
        }

        .description {
          line-height: 1.5;
          font-size: 1.5rem;
        }

        code {
          background: #fafafa;
          border-radius: 5px;
          padding: 0.75rem;
          font-size: 1.1rem;
          font-family: Menlo, Monaco, Lucida Console, Liberation Mono,
            DejaVu Sans Mono, Bitstream Vera Sans Mono, Courier New, monospace;
        }

        .grid {
          display: flex;
          align-items: center;
          justify-content: center;
          flex-wrap: wrap;

          max-width: 800px;
          margin-top: 3rem;
        }

        .card {
          margin: 1rem;
          flex-basis: 45%;
          flex: 0 0 auto;
          padding: 1.5rem;
          text-align: left;
          color: inherit;
          text-decoration: none;
          border: 1px solid #eaeaea;
          border-radius: 10px;
          transition: color 0.15s ease, border-color 0.15s ease;
        }

        .card:hover,
        .card:focus,
        .card:active {
          color: #0070f3;
          border-color: #0070f3;
        }

        .card h3 {
          margin: 0 0 1rem 0;
          font-size: 1.5rem;
        }

        .card p {
          margin: 0;
          font-size: 1.25rem;
          line-height: 1.5;
        }

        .logo {
          height: 1em;
        }

        @media (max-width: 600px) {
          .grid {
            width: 100%;
            flex-direction: column;
          }
        }
      `}</style>

      <style jsx global>{`
        html,
        body {
          padding: 0;
          margin: 0;
          font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto,
            Oxygen, Ubuntu, Cantarell, Fira Sans, Droid Sans, Helvetica Neue,
            sans-serif;
        }

        * {
          box-sizing: border-box;
        }
      `}</style>
    </div>
  )
}

/**
 * Fetch data with getStaticProps based on 'preview' mode
 */
export const getStaticProps = async function({
  preview,
  previewData,
 }) {
   const fg = require('fast-glob');

   try {
     const files = preview
       ? await getGithubFiles(
           'sites/notebooks/content/notebooks',
           previewData.working_repo_full_name,
           previewData.head_branch,
           previewData.github_access_token
         )
       : await fg('./content/notebooks/**/*.ipynb');

     const notebooks = await Promise.all(
       files.map(async file => {
         const notebook = (await getJsonPreviewProps(file, preview, previewData))
           .props.file

         const slug = fileToUrl(file, 'content/notebooks');

         return {...notebook.data, slug };
       })
     )

     const jsonPreviewPropsHome = await getJsonPreviewProps(
       preview ? 'sites/notebooks/content/home.json' : 'content/home.json',
       preview,
       previewData,
     );

     return {
       props: {
         ...jsonPreviewPropsHome.props,
         notebooks: notebooks,
         preview: !!preview,
       },
     }
   } catch (e) {
     return {
       props: {
         notebooks: [],
         error: { ...e },
       },
     }
   }
}
