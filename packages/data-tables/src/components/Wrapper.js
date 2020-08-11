import React, { useState, useEffect } from 'react';
import Generic from './Generic';
import loadData from '../services/loadData';
import get from 'lodash/get';
import unwind from 'javascript-unwind';

const hasGroupedRow = (tableType) => {
  const groupedRowTables = [
    'phenotype_flat',
    'phenotype_not_observed_flat',
    'drives_overexpression_flat',
  ];
  if (groupedRowTables.includes(tableType)) {
    return true;
  }
  return false;
};

const getDataForTsv = (tableType, data) => {
  const tablesNeedUnwind4Tsv = [
    'expressed_in',
    'expressed_during',
    'subcellular_localization',
  ];
  if (tablesNeedUnwind4Tsv.includes(tableType)) {
    return data.length === 0 ? null : unwind(data, 'details');
  }
  return null;
};

const Wrapper = ({
  WBid,
  tableType,
  id,
  order,
  columnsHeader,
  additionalKey = '',
}) => {
  const [data, setData] = useState([]);

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(additionalKey ? get(json.data, additionalKey) : json.data);
    });
  }, [WBid, tableType]);

  console.log(data);

  return (
    <Generic
      data={data}
      id={id}
      order={order}
      columnsHeader={columnsHeader}
      hasGroupedRow={hasGroupedRow(tableType)}
      dataForTsv={getDataForTsv(tableType, data)}
    />
  );
};

export default Wrapper;
