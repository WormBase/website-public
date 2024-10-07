import React from 'react';
import useSingleCell from './useExpressionRoux';
import ExpressionRoux from "./ExpressionRouxChart";
import { CircularProgress } from '../Progress';


export default function({ geneId }) {
  const { loading, error, data } = useSingleCell(geneId);

  if (error) {
    throw error;
  }

  return loading ? <CircularProgress /> : <ExpressionRoux data={data} />;
}
