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
    const inferredTypes = [type, 'all'];
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
            (prevType) => {
              return (
                inferredTypes.indexOf(prevType) === -1 &&
                prevType.indexOf(type) === -1 &&
                type !== 'all'
              );
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

  getInteractionTypeName = (interactionType) => {
    const parts = ('' || interactionType).split(':');
    return parts[parts.length - 1];
  }

  renderInteractionTypeSelect = (interactionType) => {
    return (
      <span>
        <input
          type="checkbox"
          onChange={() => this.handleInteractionTypeSelection(interactionType)}
          checked={this.isInteractionTypeSelected(interactionType)}
        />
        {this.getInteractionTypeName(interactionType)}
      </span>
    );
  }

  render() {
    const interactionTypes = [... new Set(this.props.interactions.map((interaction) => interaction.type))];
    return (
      <div>
        {this.renderInteractionTypeSelect('all')}
        <ul>
          {
            interactionTypes.map((interactionType) => {
              return (
                <li>
                  {this.renderInteractionTypeSelect(interactionType)}
                </li>
              );
            })
          }
        </ul>
      </div>
    );
  }
}
