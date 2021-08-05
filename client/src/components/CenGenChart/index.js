import React from 'react';
import useGeneExpression from './useGeneExpression';

export default function({ geneId }) {
  const { loading, error, data } = useGeneExpression(geneId);
  return <pre>{JSON.stringify(data, null, 2)}</pre>;
}
