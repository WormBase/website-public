import React from 'react';
import useSingleCell from './useExpressionL2';
import ExpressionL2Chart from "./ExpressionL2Chart";
import { CircularProgress } from '../Progress';
import ExpressionL2 from "./index";


export default function({ geneId }) {
  const { loading, error, data } = useSingleCell(geneId);

  if (error) {
    throw error;
  }

  return loading ? <CircularProgress /> : <ExpressionL2Chart data={data} />;
}
