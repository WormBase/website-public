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

module.exports = resolvers;
