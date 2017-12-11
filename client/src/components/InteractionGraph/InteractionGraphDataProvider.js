import React, { Component } from 'react';

export default class InteractionGraphDataProvider extends Component {

  render() {
    console.log(this.props.data);
    const data = this.props.data;
    const error = this.props.error;
    return (
      <div>
        {
          error || (
            data ? this.props.children({
              interactorMap: data.data.nodes,
              interactions: data.data.edges_all || data.data.edges
            }) : <span>Loading...</span>
          )
        }
      </div>
    );
  }
}
