import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class InteractionGraph extends Component {
  static propTypes = {
    interactions: PropTypes.arrayOf(
      PropTypes.shape({
        type: PropTypes.string
      })
    )
  };

  resetSelectedTypes = () => {
    const defaultExcludes = new Set(['predicted', 'does-not-regulate', 'gi-module-three:neutral']);
    const availableTypes = [... new Set(this.props.interactions.map((interaction) => interaction.type))];
    this.setState({
      interactionTypeSelected: availableTypes.filter(
        (t) => !defaultExcludes.has(t)
      )
    })
  }

  componentWillMount() {
    this.resetSelectedTypes();
  }

  componentWillReceiveProps() {
    this.resetSelectedTypes();
  }

  getInferredTypes = (type) => {
    const inferredTypes = [type, 'all'];
    inferredTypes.push(type.split(":")[0]);
    if (type.match(/gi-module-.+/)) {
      inferredTypes.push("genetic");
    }
    return inferredTypes;
  }

  getDescentTypes = (type) => {
    const interactionTypes = [... new Set(this.props.interactions.map((interaction) => interaction.type))];
    if (type === 'all') {
      return interactionTypes;
    } else if (type === 'genetic') {
      return interactionTypes.filter((t) => t.match(/gi-module-.+/));
    } else {
      return interactionTypes.filter((t) => t.indexOf(type) !== -1);
    }
  }

  isInteractionTypeSelected = (type) => {
    return this.state.interactionTypeSelected.indexOf(type) !== -1;
  }

  handleInteractionTypeSelection = (type) => {
    this.setState((prevState) => {
      const inferredTypes = this.getInferredTypes(type);
      const descendentTypes = this.getDescentTypes(type);
      if (this.isInteractionTypeSelected(type)) {
        // de-select
        return {
          interactionTypeSelected: type === 'all' ? [] : prevState.interactionTypeSelected.filter(
            (prevType) => {
              return (
                inferredTypes.indexOf(prevType) === -1 &&  // prevType is not a inferredType
                descendentTypes.indexOf(prevType) === -1  // prevType is not a descendent type
              );
            }
          )
        };
      } else {
        return {
          interactionTypeSelected: [...prevState.interactionTypeSelected, ...descendentTypes, type]
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
