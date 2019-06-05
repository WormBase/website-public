import React, { Component } from 'react';

export default class InteractionGraphDataProvider extends Component {
  render() {
    // console.log(this.props.data);
    const data = this.props.data;
    const error = this.props.error;
    const edges = data.data.edges_all;
    const nodes =
      data.data.nodes ||
      edges.reduce((result, edge) => {
        result[edge.affected.id] = edge.affected;
        result[edge.effector.id] = edge.effector;
        return result;
      }, {});
    return (
      <div>
        {error ||
          (data ? (
            this.props.children({
              interactorMap: nodes,
              interactions: edges,
            })
          ) : (
            <span>Loading...</span>
          ))}
      </div>
    );
  }
}
