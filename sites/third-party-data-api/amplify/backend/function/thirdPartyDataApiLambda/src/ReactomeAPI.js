const { RESTDataSource } = require('apollo-datasource-rest');

class ReactomeAPI extends RESTDataSource {
  constructor() {
    super();
    this.baseURL = 'https://reactome.org/ContentService/';
  }

  async searchProteins(query) {
    const data = await this.get('/search/query', {
      query: query,
    });
    const [{entries = []}] = data.results || [];
    return entries.filter(({exactType}) => 'ReferenceGeneProduct').map(
      ({stId, name}) => ({stId, name})
    );
  }

  async getPathwaysByProteinId(stId) {
    const data = await this.get(`/data/pathways/low/entity/${stId}/allForms`);
    return data.map(({stId, displayName}) => ({
      stId,
      displayName,
    }));
  }


}

module.exports = ReactomeAPI;
