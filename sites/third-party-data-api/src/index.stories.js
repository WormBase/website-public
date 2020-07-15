import React from 'react';
import { ThirdPartyDataProvider, ReactomePathwayList } from './index';
import { LegacyDataField } from '@wormbase/design-system';

export default { title: 'Reactome' };

export const unc57 = () => (
  <ThirdPartyDataProvider>
    <LegacyDataField title={'zzz'}>
      <ReactomePathwayList geneId="WBGene00006791" />
    </LegacyDataField>
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
