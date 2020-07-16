import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import gql from 'graphql-tag';
import { LegacyDataField } from '@wormbase/design-system';

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
  } else if (data && data.getReactomePathwayByGene && data.getReactomePathwayByGene.length) {
    return (
      <LegacyDataField title="Inferred pathway">
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
      </LegacyDataField>
    );
  } else {
    return <p />;
  }
};

export default ReactomePathwayList;
