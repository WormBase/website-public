import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class InteractionGraph extends Component {
  static propTypes = {
    interactions: PropTypes.arrayOf(
      PropTypes.shape({
        type: PropTypes.string
      })
    ),
    initialInteractionTypesSelected: PropTypes.arrayOf(PropTypes.string)
  };

  static defaultProps = {
    initialInteractionTypesSelected: [
      "gi-module-one"
    ]
  }

  constructor(props) {
    super(props);
    this.state = {
      interactionTypeSelected: props.initialInteractionTypesSelected
    };
  }

  getInferredTypes = (type) => {
    const inferredTypes = [type];
    inferredTypes.push(type.split(":")[0]);
    if (type.match(/gi-module-.+/)) {
      inferredTypes.push("genetic");
    }
    return inferredTypes;
  }

  isInteractionTypeSelected = (type) => {
    const selectedSet = new Set(this.state.interactionTypeSelected);
    return this.getInferredTypes(type).some((inferredType) => {
      return selectedSet.has(inferredType);
    });
  }

  handleInteractionTypeSelection = (type) => {
    this.setState((prevState) => {
      const inferredTypes = this.getInferredTypes(type);
      if (this.isInteractionTypeSelected(type)) {
        return {
          interactionTypeSelected: prevState.interactionTypeSelected.filter(
            (type) => {
              return inferredTypes.indexOf(type) === -1;
            }
          )
        };
      } else {
        return {
          interactionTypeSelected: [...prevState.interactionTypeSelected, type]
        };
      }

    });
  }

  render() {
    const interactionTypes = [... new Set(this.props.interactions.map((interaction) => interaction.type))];
    return (
      <div>
        <div>
        {
          interactionTypes.map((interactionType) => {
            return (
              <p key={interactionType}>
                <input
                  type="checkbox"
                  onChange={() => this.handleInteractionTypeSelection(interactionType)}
                  checked={this.isInteractionTypeSelected(interactionType)}
                />
                {interactionType}
              </p>
            );
          })
        }
        </div>
      </div>
    );
  }
}
