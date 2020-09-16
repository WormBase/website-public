import React from 'react';
import { homology_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_alleles';
const order = [
  'variation',
  'molecular_change',
  'locations',
  'effects',
  'composite_change',
  'isoform',
  'phen_count',
  'sources',
  'strain',
];
const columnsHeader = {
  variation: 'Allele',
  type: 'Type',
  molecular_change: 'Molecular<br /> change',
  effects: 'Protein<br /> effects',
  locations: 'Locations',
  phen_count: '# of<br /> Phenotypes',
  composite_change: 'Protein<br />change',
  isoform: 'Isoform',
  sources: 'Source',
  strain: 'Strain',
  gene: 'Gene',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Genetics/alleles',
};

export const daf8 = () => (
  <Wrapper
    WBid="WBGene00000904"
    tableType="alleles"
    {...{ id, order, columnsHeader }}
  />
);
