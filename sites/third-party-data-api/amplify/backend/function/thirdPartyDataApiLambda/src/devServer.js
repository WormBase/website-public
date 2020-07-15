const { ApolloServer } = require('apollo-server');
const typeDefs = require('./schema');
const resolvers = require('./resolvers');
const ReactomeAPI = require('./ReactomeAPI');

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
