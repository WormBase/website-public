const { gql, ApolloServer } = require('apollo-server');
const ReactomeAPI = require('./ReactomeAPI');

const typeDefs = gql`

type Query {
  getReactomePathwayByGene(id: String!): [ReactomePathway!]
}

type ReactomePathway {
  stId: String!
  displayName: String!
}
`;

const resolvers = {
  Query: {
    getReactomePathwayByGene: async (_, {id}, { dataSources }) => {
      const proteins = await dataSources.reactomeAPI.searchProteins(id);
      if (proteins && proteins[0]) {
	const proteinId = proteins[0] && proteins[0].stId;
	return await dataSources.reactomeAPI.getPathwaysByProteinId(proteinId);
      } else {
	return [];
      }
    },
  },
  ReactomePathway: {},
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
  dataSources: () => ({
    reactomeAPI: new ReactomeAPI(),
  })
});

server.listen(9004).then(({url}) => {
  console.log(`Server ready at ${url}`);
});
