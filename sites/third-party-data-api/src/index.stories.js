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
  query ReactomePathways {
    getReactomePathwayByGene(id: "WBGene00006791") {
      displayName
      stId
    }
  }
`;

const PathwayList = () => {
  const { data, loading, error } = useQuery(GET_REACTOME_PATHWAYS);

  if (loading) {
    return <p>Loading...</p>;
  } else if (error) {
    return <p>{error.message}</p>;
  } else {
    return (
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
    );
  }
};

export default { title: 'Reactome' };

export const normal = () => (
  <ApolloProvider client={client}>
    <PathwayList />
  </ApolloProvider>
);
