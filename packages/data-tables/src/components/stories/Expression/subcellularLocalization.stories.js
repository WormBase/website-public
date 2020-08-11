import React from 'react';
import { expression_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_subcellular_localization';
const order = ['ontology_term', 'details'];
const columnsHeader = {
  ontology_term: 'Cellular component',
  details: 'Supporting Evidence',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Expression/subcellular_localization',
};

// This table for daf8 doesn't exist

// export const daf8 = () => (
//   <Wrapper
//     WBid={expression_widget.WBid.daf8}
//     tableType={expression_widget.tableType.subcellularLocalization}
//     {...{ id, order, columnsHeader }}
//   />
// );

export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.subcellularLocalization}
    {...{ id, order, columnsHeader }}
  />
);

export const mig2 = () => (
  <Wrapper
    WBid={expression_widget.WBid.mig2}
    tableType={expression_widget.tableType.subcellularLocalization}
    {...{ id, order, columnsHeader }}
  />
);
