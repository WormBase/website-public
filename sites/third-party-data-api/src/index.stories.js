import React from 'react';
import { ThirdPartyDataProvider, ReactomePathwayList } from './index';

export default { title: 'Reactome' };

export const unc57 = () => (
  <ThirdPartyDataProvider>
    <ReactomePathwayList geneId="WBGene00006791" />
  </ThirdPartyDataProvider>
);

export const daf8 = () => (
  <ThirdPartyDataProvider>
    <ReactomePathwayList geneId="WBGene00000904" />
  </ThirdPartyDataProvider>
);

export const NonExistent = () => (
  <ThirdPartyDataProvider>
    <ReactomePathwayList />
  </ThirdPartyDataProvider>
);
