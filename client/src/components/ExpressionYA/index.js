import React from 'react';
import useSingleCell from './useExpressionYA';
import ExpressionYAChart from "./ExpressionYAChart";
import { CircularProgress } from '../Progress';


export default function({ geneId }) {
  const { loading, error, data } = useSingleCell(geneId);

  if (error) {
    throw error;
  }

  return loading ? <CircularProgress /> : <ExpressionYAChart data={data} />;
}
