import React from 'react';
import useSingleCell from './useExpressionSmith';
import ExpressionSmith from "./ExpressionSmithChart";
import { CircularProgress } from '../Progress';


export default function({ geneId }) {
  const { loading, error, data } = useSingleCell(geneId);

  if (error) {
    throw error;
  }

  return loading ? <CircularProgress /> : <ExpressionSmith data={data} />;
}
