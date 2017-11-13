import { Component } from 'react';
export default class InteractionGraphDataProvider extends Component {
  render() {
    return this.props.children({
      interactions: [
        {type: "gi-module-one"},
        {type: "gi-module-one:a-phenotypic"},
        {type: "gi-module-two:semi-suppressing"}
      ]
    });
  }
}
