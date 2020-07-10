import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import gql from 'graphql-tag';
window.React2 = require('react');
const GET_REACTOME_PATHWAYS = gql`
  query ReactomePathways($geneId: String!) {
    getReactomePathwayByGene(id: $geneId) {
      displayName
      stId
    }
  }
`;

const ReactomePathwayList = ({
  geneId = '',
}) => {
  const { data, loading, error } = useQuery(GET_REACTOME_PATHWAYS, {
    variables: {
      geneId,
    },
  });

  if (loading) {
    return <p>Loading...</p>;
  } else if (error) {
    return <p>{error.message}</p>;
  } else {
    return (
      <div>
        <p>Computationally inferred pathways provided by{' '}
          <a href="https://reactome.org/documentation/inferred-events" target="_blank">Reactome</a>.
        </p>
        <ul>
          {
            data.getReactomePathwayByGene.map(({stId, displayName}) => (
              <li key={stId}>
                <a href={`https://reactome.org/content/detail/${stId}`} target="_blank">
                  {displayName}
                </a>
              </li>
            ))
          }
        </ul>
      </div>
    );
  }
};

export default ReactomePathwayList;
