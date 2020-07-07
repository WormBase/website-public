import React from 'react';

import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { HttpLink } from 'apollo-link-http';
import gql from 'graphql-tag';
import { ApolloProvider, useQuery } from "@apollo/react-hooks";

const cache = new InMemoryCache();
const link = new HttpLink({
  uri: 'https://rrmvef187j.execute-api.us-east-1.amazonaws.com/dev/graphql'
});

const client = new ApolloClient({
  cache,
  link
});

const GET_REACTOME_PATHWAYS = gql`
  query ReactomePathways($geneId: String!) {
    getReactomePathwayByGene(id: $geneId) {
      displayName
      stId
    }
  }
`;

const PathwayList = ({
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
        <p>Computationally inferred pathways provided by <a href="https://reactome.org/documentation/inferred-events" target="_blank">Reactome</a>.</p>
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

export default { title: 'Reactome' };

export const unc57 = () => (
  <ApolloProvider client={client}>
    <PathwayList geneId="WBGene00006791" />
  </ApolloProvider>
);

export const daf8 = () => (
  <ApolloProvider client={client}>
    <PathwayList geneId="WBGene00000904" />
  </ApolloProvider>
);

export const NonExistent = () => (
  <ApolloProvider client={client}>
    <PathwayList />
  </ApolloProvider>
);
