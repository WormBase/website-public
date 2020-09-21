import React from 'react';
import Wrapper from '../../Wrapper';
import DelimitedCell from '../../DelimitedCell';
import SmartCell from '../../SmartCell';

const id = 'table_multi_pt_data';
const order = ['genotype', 'result', 'mapper', 'date', 'comment'];
const columnsHeader = {
  result: 'Result',
  genotype: 'Genotype',
  mapper: 'Mapper',
  comment: 'Comment',
  date: 'Date',
};

const tableConfig = ({ columns, ...otherOptions }) => {
  const [resultColumn] = columns.filter(
    (column) => column.accessor === 'result'
  );
  const resultColumnIndex = columns.indexOf(resultColumn);
  const newColumns = [...columns];
  newColumns[resultColumnIndex] = {
    ...resultColumn,
    Cell: ({ value }) => (
      <DelimitedCell
        data={value}
        render={({ elementData }) => <SmartCell data={elementData} />}
      />
    ),
  };
  return {
    columns: newColumns,
    ...otherOptions,
  };
};

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Mapping/multi_pt_data',
};

export const daf8 = () => (
  <Wrapper
    WBid="WBGene00000904"
    tableType="multi_pt_data"
    {...{ id, order, columnsHeader, tableConfig }}
  />
);
