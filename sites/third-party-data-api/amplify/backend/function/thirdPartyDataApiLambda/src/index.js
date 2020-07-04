const { ApolloServer } = require('apollo-server-lambda')
const typeDefs = require('./schema');
const resolvers = require('./resolvers');
const ReactomeAPI = require('./ReactomeAPI');

const server = new ApolloServer({
    typeDefs,
    resolvers,
    dataSources: () => ({
      reactomeAPI: new ReactomeAPI(),
    }),
    context: ({ event, context }) => ({
      headers: event.headers,
      functionName: context.functionName,
      event,
      context,
    }),
    playground: {
      endpoint: "/dev/graphql"
    },
  })

exports.handler = server.createHandler({
  cors: {
    origin: '*',
    credentials: true,
  },
})
