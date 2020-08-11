import React from 'react';
import { phenotype_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_drives_overexpression';
const order = ['phenotype', 'entity', 'evidence'];
const columnsHeader = {
  phenotype: 'Phenotype',
  entity: 'Entities Affected',
  evidence: 'Supporting Evidence',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Phenotypes/drives_overexpression',
};

export const daf8 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.daf8}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
    {...{ id, order, columnsHeader }}
  />
);
export const daf16 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.daf16}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
    {...{ id, order, columnsHeader }}
  />
);
export const mig2 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.mig2}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
    {...{ id, order, columnsHeader }}
  />
);
