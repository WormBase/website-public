import React from 'react';
import Wrapper from '../../Wrapper';

const id = 'table_table_detailed_disease_model';
const order = [
  'disease_term',
  'genetic_entity',
  'genotype',
  'evidence_code',
  'experimental_condition',
  'modifier',
  'description',
  'reference',
];

const columnsHeader = {
  disease_term: 'Disease',
  genetic_entity: 'Genetic entity',
  genotype: 'Genotype',
  association_type: 'Association type',
  evidence_code: 'Evidence code',
  experimental_condition: 'Inducer',
  modifier: 'Modifier',
  modifier_association_type: 'Modifier association type',
  description: 'Description',
  reference: 'Reference',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Diseases/detailed_disease_model',
};

export const nlg1 = () => (
  <Wrapper
    WBid="WBGene00006412"
    tableType="detailed_disease_model"
    {...{ id, order, columnsHeader }}
  />
);

export const dys1 = () => (
  <Wrapper
    WBid="WBGene00001131"
    tableType="detailed_disease_model"
    {...{ id, order, columnsHeader }}
  />
);
