import React, { useRef, useEffect } from 'react';
import useGeneExpression from './useGeneExpression';
import ExpressionChart from './ExpressionChart';
import { CircularProgress } from '../Progress';

export default function({ geneId }) {
  const { loading, error, data } = useGeneExpression(geneId);

  if (error) {
    throw error;
  }

  return loading ? <CircularProgress /> : <ExpressionChart data={data} />;
}
