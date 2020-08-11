import React from 'react';
import { expression_widget } from '../../../../.storybook/target';
import Wrapper from '../../Wrapper';

const id = 'table_anatomy_function';
const order = ['bp_inv', 'assay', 'phenotype', 'reference'];
const columnsHeader = {
  bp_inv: 'Anatomical Sites',
  assay: 'Assay',
  phenotype: 'Phenotype',
  reference: 'Reference',
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Expression/anatomy_function',
};

// This table for daf8 doesn't exist

// export const daf8 = () => (
//   <Wrapper
//     WBid={expression_widget.WBid.daf8}
//     tableType={expression_widget.tableType.anatomyFunction}
//     {...{ id, order, columnsHeader }}
//   />
// );

export const daf16 = () => (
  <Wrapper
    WBid={expression_widget.WBid.daf16}
    tableType={expression_widget.tableType.anatomyFunction}
    {...{ id, order, columnsHeader }}
  />
);

// This table for daf8 doesn't exist

// export const mig2 = () => (
//   <Wrapper
//     WBid={expression_widget.WBid.mig2}
//     tableType={expression_widget.tableType.anatomyFunction}
//     {...{ id, order, columnsHeader }}
//   />
// );
