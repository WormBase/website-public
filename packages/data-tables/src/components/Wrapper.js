import React, { useState, useEffect } from 'react';
import Generic from './Generic';
import loadData from '../services/loadData';

const handleData = (data, tableType) => {
  if (tableType === 'best_blastp_matches') {
    return data.hits;
  }
  return data;
};

const hasGroupedRow = (tableType) => {
  if (tableType === 'phenotype_flat') {
    return true;
  }
  return false;
};

const Wrapper = ({ WBid, tableType, id, order, columnsHeader }) => {
  const [data, setData] = useState([]);

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(handleData(json.data, tableType));
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
    />
  );
};

export default Wrapper;
