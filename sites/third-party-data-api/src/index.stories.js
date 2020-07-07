import React from 'react';

import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { HttpLink } from 'apollo-link-http';
import gql from 'graphql-tag';

const cache = new InMemoryCache();
const link = new HttpLink({
  uri: 'https://rrmvef187j.execute-api.us-east-1.amazonaws.com/dev/graphql'
});

const client = new ApolloClient({
  cache,
  link
});

client.query({
  query: gql`
    query ReactomePathways {
      getReactomePathwayByGene(id: "WBGene00006791") {
        displayName
        stId
      }
    }
  `
}).then(result => console.log(JSON.stringify(result, null, 2)));

export default { title: 'Reactome' };

export const example = () => 'test';
