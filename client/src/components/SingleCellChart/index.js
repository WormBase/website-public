import React from 'react';
import useSingleCell from './useSingleCellEmbryo';
import SingleCellChart from './SingleCellChart';
import { CircularProgress } from '../Progress';

export default function({ geneId }) {
  const { loading, error, data } = useSingleCell(geneId);

  if (error) {
    throw error;
  }

  return loading ? <CircularProgress /> : <SingleCellChart data={data} />;
}
