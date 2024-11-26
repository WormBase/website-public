import React from 'react';
import useSingleCell from './useExpressionSmith';
import ExpressionSmith from "./ExpressionSmithChart";
import { CircularProgress } from '../Progress';


export default function({ geneId }) {
  const { loading, error, data } = useSingleCell(geneId);

  if (loading) {
    return <CircularProgress />;
  }

  if (error) {
    return <div className="error">Error loading expression data: {error.message}</div>;
  }

  if (!data || data.length === 0) {
    return <div className="fade">No expression data available for this gene.</div>;
  }

  return <ExpressionSmith data={data} />;
}
