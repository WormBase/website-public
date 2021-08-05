import React, { useRef, useEffect } from 'react';
import useGeneExpression from './useGeneExpression';
import ExpressionChart from './ExpressionChart';

export default function({ geneId }) {
  const { loading, error, data } = useGeneExpression(geneId);
  return <ExpressionChart data={data} />;
}
