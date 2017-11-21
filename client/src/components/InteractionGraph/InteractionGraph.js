import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cytoscape from 'cytoscape';

export default class InteractionGraph extends Component {
  static propTypes = {
    interactions: PropTypes.arrayOf(
      PropTypes.shape({
        type: PropTypes.string
      })
    ),
    interactorMap: PropTypes.objectOf(
      PropTypes.shape({
        id: PropTypes.string.isRequired,
        label: PropTypes.string.isRequired
      })
    )
  };

  resetSelectedTypes = () => {
    const defaultExcludes = new Set(['predicted', 'does-not-regulate', 'gi-module-three:neutral']);
    const availableTypes = new Set(this.props.interactions.map((interaction) => interaction.type));
    this.setState({
      interactionTypeSelected: [...availableTypes].filter(
        (t) => !defaultExcludes.has(t)
      )
    })
  }

  componentWillMount() {
    this.resetSelectedTypes();
  }

  componentDidMount() {
    this.setupCytoscape();
  }

  componentWillReceiveProps() {
    this.resetSelectedTypes();
  }

  componentWillUnmount() {
    this._cy.destroy();
  }

  setupCytoscape = () => {
    const nodes = Object.keys(this.props.interactorMap).map((interactorId) => {
      const {label} = this.props.interactorMap[interactorId];
      return {
        group: 'nodes',
        data: {
          id: interactorId,
          label: label,
          color: 'gray',
          shape: 'ellipse'
        }
      };
    });
    const edges = this.props.interactions.map(({effector, affected, direction, type, citations}) => {
      const source = effector.id;
      const target = affected.id;
      return {
        group: 'edges',
        data: {
          id: `${source}|${target}|${type}`,
          source: source,
          target: target,
          color: 'gray',
          directioned: direction !== "non-directional",
          width: Math.min(citations.length, 10),
          type: type,
        }
      };
    });
    const elements = [...nodes, ...edges];
    console.log(elements);
    this._cy = cytoscape({
      container: this._cytoscapeContainer,
      elements: elements,
      style: cytoscape
        .stylesheet()
        .selector('node')
        .css({
          'label': 'data(label)',
          'opacity': 0.9,
          'border-width': 0,
          'shape': 'data(shape)',
          'height': 10,
          'width': 10,
          'font-size': 4,
          'text-valign': 'center',
          'color': 'black',
          'text-outline-color': 'white',
          'text-outline-width': 1,
        })
        .selector('edge')
        .css({
          'width': 'data(width)',
          'opacity':0.4,
          'line-color': 'data(color)',
          'line-style': 'solid',
          'curve-style': 'bezier'

        })
        .selector('edge[type="predicted"]')
        .css({
          'line-style': 'dotted'
        })
        .selector('edge[?directioned]')
        .css({
          'target-arrow-shape': 'triangle',
          'target-arrow-color': 'data(color)',
          'source-arrow-color': 'data(color)'
        })
        .selector('node[mainNode]')
        .css({
          'height': '40px',
          'width': '40px',
          'background-color': 'red'
        })
        .selector(':selected')
        .css({
          'opacity': 1,
          'border-color': 'black',
          'border-width': 1,
        }),

      layout: {
        name: 'cose'
      }

    });
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
    const availableTypes = new Set(this.props.interactions.map((interaction) => interaction.type));
    const interactionTypes = [
      'predicted',
      'physical',
      'regulatory',
      'genetic',
      'gi-module-one',
      'gi-module-two',
      'gi-module-three',
      ...availableTypes
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
    return (
      <div>
        <div
          ref={(c) => this._cytoscapeContainer = c }
          style={{
            height: 750,
            width: 750,
            border: 'solid 1px black',
          }}
        />
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
