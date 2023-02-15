import React from 'react';
import useSingleCell from './useEmbryoLineage';
import EmbryoLineageChart from "./EmbryoLineageChart";
import { CircularProgress } from '../Progress';


export default function({ geneId }) {
  const { loading, error, data } = useSingleCell(geneId);

  if (error) {
    throw error;
  }

  return loading ? <CircularProgress /> : <EmbryoLineageChart data={data} />;
}
