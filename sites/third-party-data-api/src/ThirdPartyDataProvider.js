import React from 'react';

import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { HttpLink } from 'apollo-link-http';
import { ApolloProvider } from "@apollo/react-hooks";

const cache = new InMemoryCache();
const link = new HttpLink({
  uri: 'https://rrmvef187j.execute-api.us-east-1.amazonaws.com/dev/graphql'
});

const client = new ApolloClient({
  cache,
  link
});

const ThirdPartyDataProvider = (props = {}) => (
  <ApolloProvider client={client} {...props} />
);

export default ThirdPartyDataProvider;
