import React, { useMemo } from 'react';
import ErrorMessage from '../ErrorMessage';
import useData from '../useData';

export default function InteractionGraphDataProvider({ dataUrl, children }) {
  // console.log(this.props.data);
  const { data: responseJson, error, isLoading } = useData({ url: dataUrl });

  const { interactorMap, interactions } = useMemo(() => {
    const { interaction_details } = responseJson || {};
    const { data } = interaction_details || {};
    let { edges_all: edges, nodes } = data || {};
    edges = edges || [];
    nodes =
      nodes ||
      edges.reduce((result, edge) => {
        result[edge.affected.id] = edge.affected;
        result[edge.effector.id] = edge.effector;
        return result;
      }, {});
    return {
      interactorMap: nodes,
      interactions: edges,
    };
  }, [responseJson]);

  return isLoading ? (
    <span>Loading...</span>
  ) : error ? (
    <ErrorMessage title={error} />
  ) : (
    children({
      interactorMap,
      interactions,
    })
  );
}

InteractionGraphDataProvider.displayName = 'InteractionGraphDataProvider';
