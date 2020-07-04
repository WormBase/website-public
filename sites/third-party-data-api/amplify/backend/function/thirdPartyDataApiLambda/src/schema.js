const { gql } = require('apollo-server-lambda');

const typeDefs = gql`

type Query {
  getReactomePathwayByGene(id: String!): [ReactomePathway!]
}

type ReactomePathway {
  stId: String!
  displayName: String!
}
`;

module.exports = typeDefs;
