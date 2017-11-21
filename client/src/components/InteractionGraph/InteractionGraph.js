import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cytoscape from 'cytoscape';

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
    this.setupCytoscape();
  }

  componentWillReceiveProps() {
    this.resetSelectedTypes();
  }

  setupCytoscape = () => {
    console.log(cytoscape);
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
    const interactionTypes = [
      'predicted',
      'physical',
      'regulatory',
      'genetic',
      'gi-module-one',
      'gi-module-two',
      'gi-module-three',
      ... new Set(this.props.interactions.map((interaction) => interaction.type))
    ];
    if (type === 'all') {
      return interactionTypes;
    } else if (type === 'genetic') {
      return interactionTypes.filter((t) => t.match(/gi-module-.+/));
    } else {
      return interactionTypes.filter((t) => t.indexOf(type) !== -1 && t !== type);
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
      <label>
        <input
          type="checkbox"
          onChange={() => this.handleInteractionTypeSelection(interactionType)}
          checked={this.isInteractionTypeSelected(interactionType)}
        />
        {this.getInteractionTypeName(interactionType)}
      </label>
    );
  }

  render() {
    const interactionTypes = [... new Set(this.props.interactions.map((interaction) => interaction.type))];
    return (
      <div>
        <div ref={(c) => this._cytoscapeContainer = c } />
        <h4>Interaction types:</h4>
        {this.renderInteractionTypeSelect('all')}
        <ul>
          <li>
            {this.renderInteractionTypeSelect('predicted')}
          </li>
          <li>
            {this.renderInteractionTypeSelect('physical')}
            <ul>
              {
                this.getDescentTypes('physical').map((t) => {
                  return (<li key={t}>{this.renderInteractionTypeSelect(t)}</li>)
                })
              }
            </ul>
          </li>
          <li>
            {this.renderInteractionTypeSelect('regulatory')}
            <ul>
              {
                this.getDescentTypes('regulatory').map((t) => {
                  return (<li key={t}>{this.renderInteractionTypeSelect(t)}</li>)
                })
              }
            </ul>
          </li>
          <li>
            {this.renderInteractionTypeSelect('genetic')}
            <ul>
              {
                ['gi-module-one', 'gi-module-two', 'gi-module-three'].map((giModule) => {
                  const descendentTypes = this.getDescentTypes(giModule);
                  return (
                    <li key={giModule}>
                      {this.renderInteractionTypeSelect(giModule)}
                      <ul>
                        {
                          descendentTypes.map((t) => (
                            <li key={t}>
                              {this.renderInteractionTypeSelect(t)}
                            </li>
                          ))
                        }
                      </ul>
                    </li>
                  );
                })
              }
            </ul>
          </li>
        </ul>
        <ul>
        </ul>
        <h4>Interactor types</h4>
        <ul>

        </ul>
      </div>
    );
  }
}
