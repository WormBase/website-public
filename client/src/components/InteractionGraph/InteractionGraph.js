import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cytoscape from 'cytoscape';
import cytoscapecola from 'cytoscape-cola';
import { withStyles } from 'material-ui/styles';
import classNames from 'classnames';
import ResponsiveDrawer from '../ResponsiveDrawer';
import Button from '../Button';
import Switch from '../Switch';
import Checkbox from '../Checkbox';
import List, { ListItem, ListItemText, CompactList } from '../List';
import { FormControlLabel } from '../Form';
import ThemeProvider from '../ThemeProvider';

cytoscape.use(cytoscapecola);

class InteractionGraph extends Component {
  constructor(props) {
    super(props);
    this.state = {
      includeNearbyInteraction: true,
    };
  }

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
    ),
    classes: PropTypes.object.isRequired,
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

  componentDidUpdate() {
    this.setupCytoscape();
  }

  componentWillUnmount() {
    this._cy.destroy();
  }

  setupCytoscape = () => {
    const interactionTypeSelected = new Set(this.state.interactionTypeSelected);
    console.log(interactionTypeSelected);
    const getEdgeColor = (type) => {
      const colorScheme = ["#0A6314", "#08298A","#B40431","#FF8000", "#00E300","#05C1F0", "#8000FF", "#69088A", "#B58904", "#E02D8A", "#FFFC2E" ];
      const inferredTypes = new Set(this.getInferredTypes(type));
      const tests = [
        () => inferredTypes.has('physical'),
        () => inferredTypes.has('genetic'),
      ];
      const colorIndex = tests.findIndex((test, index) => test());;
      return colorIndex === -1 ? 'gray' : colorScheme[colorIndex];
    }

    const edges = this.props.interactions.filter(
      (edge) => {
        return interactionTypeSelected.has(edge.type) &&
               (this.state.includeNearbyInteraction || !parseInt(edge.nearby));
      }
    ).map(
      ({effector, affected, direction, type, citations}) => {
        const source = effector.id;
        const target = affected.id;
        return {
          group: 'edges',
          data: {
            id: `${source}|${target}|${type}`,
            source: source,
            target: target,
            color: getEdgeColor(type),
            directioned: direction !== "non-directional",
            weight: Math.min(citations.length, 10),
            type: type
          }
        };
      }
    );

    const participatingNodes = new Set([
      ...edges.map((edge) => edge.data.source),
      ...edges.map((edge) => edge.data.target)
    ]);
    const nodes = Object.keys(this.props.interactorMap).filter(
      (interactorId) => participatingNodes.has(interactorId)
    ).map(
      (interactorId) => {
        const {label, ...rest} = this.props.interactorMap[interactorId];
        const getShape = (type) => {
          const type2shape = {
            rearrangement: "hexagon",
            molecule: "triangle",
            feature: "rectangle",
          };
          return type2shape[type] || 'ellipse';
        };

        return {
          group: 'nodes',
          data: {
            id: interactorId,
            label: label,
            color: 'gray',
            shape: getShape(rest.class)
          }
        };
      }
    );

    const elements = [...nodes, ...edges];
    console.log(elements);
    if (this._cy) {
      this._cy.destroy();
    }
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
          'height': 15,
          'width': 15,
          'font-size': 10,
          'text-valign': 'center',
          'color': 'black',
          'text-outline-color': 'white',
          'text-outline-width': 1,
        })
        .selector('edge')
        .css({
          'width': 'data(weight)',
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
        name: 'cola',
        //        name: 'cose',
        //        fit: false,

        // Node repulsion (non overlapping) multiplier
        //        nodeRepulsion: function( node ){ return 1024; },
        // Ideal edge (non nested) length
        //        idealEdgeLength: function( edge ){ return 4; },

        // Divisor to compute edge forces
        // edgeElasticity: function( edge ){ return 320 / edge._private.data.weight; },
      }

    });
  }

  getInferredTypes = (type) => {
    const inferredTypes = new Set([type, 'all']);
    inferredTypes.add(type.split(":")[0]);
    if (type.match(/gi-module-.+/)) {
      inferredTypes.add("genetic");
    }
    return [...inferredTypes];
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

  renderInteractionTypeSelect = (interactionType, {label} = {}) => {
    const level = Math.max(0, this.getInferredTypes(interactionType).length - 1);
    return (
      <ListItem
        button
        level={level}
        key={interactionType}
        indentUnitWidth={24}
        onClick={() => this.handleInteractionTypeSelection(interactionType)}
      >
        <Checkbox
          type="checkbox"
          disableRipple
          classes={{
            default: this.props.classes.graphSidebarCheckbox,
          }}
          checked={this.isInteractionTypeSelected(interactionType)}
        />
        <ListItemText
          primary={label || this.getInteractionTypeName(interactionType)}
          classes={{
            text: classNames([this.props.classes.graphSidebarText, this.props.classes[`graphSidebarTextLevel${level}`]])
          }}
        />
      </ListItem>
        );
  }

  render() {
    const {classes} = this.props;

    const graphView = (
      <div
        ref={(c) => this._cytoscapeContainer = c }
        className={classes.cytoscapeContainer}
      />
    );

    const graphToolbar = (
      <div className={classes.graphToolbar}>
        <Button
          raised
          dense
          onClick={() => this._drawerComponent.handleDrawerToggle()}
        >
          Legends
        </Button>
      </div>
    );

    const graphSidebar = (
      <div className={classes.graphSidebar}>
        <CompactList>
          {this.renderInteractionTypeSelect('all', {
             label: <h4>All interaction types</h4>
          })}
          <CompactList>
            {this.renderInteractionTypeSelect('predicted')}
            {this.renderInteractionTypeSelect('physical')}
            <CompactList>
              {
                this.getDescentTypes('physical').map((t) => {
                  return this.renderInteractionTypeSelect(t)
                })
              }
            </CompactList>
            {this.renderInteractionTypeSelect('regulatory')}
            <CompactList>
              {
                this.getDescentTypes('regulatory').map((t) => {
                  return this.renderInteractionTypeSelect(t)
                })
              }
            </CompactList>
            {this.renderInteractionTypeSelect('genetic')}
            <CompactList>
              {
                ['gi-module-one', 'gi-module-two', 'gi-module-three'].map((giModule) => {
                  const descendentTypes = this.getDescentTypes(giModule);
                  return (
                    <CompactList key={giModule}>
                      {this.renderInteractionTypeSelect(giModule)}
                      <CompactList>
                        {
                          descendentTypes.map((t) => (
                            this.renderInteractionTypeSelect(t)
                          ))
                        }
                      </CompactList>
                    </CompactList>
                  );
                })
              }
            </CompactList>
          </CompactList>
        </CompactList>
        <FormControlLabel
          classes={{
            label: classNames([this.props.classes.graphSidebarText, this.props.classes.graphSidebarTextLevel0])
          }}
          control={
            <Switch checked={this.state.includeNearbyInteraction} onChange={(event, checked) => this.setState({includeNearbyInteraction: checked})} />
          }
          label="Nearby interaction"
        />
      </div>
    );

    return (
      <ThemeProvider>
        <div>
          <ResponsiveDrawer
            innerRef={(c) => this._drawerComponent = c}
            anchor="right"
            drawerContent={graphSidebar}
            mainContent={graphView}
            mainHeader={graphToolbar}
          />
        </div>
      </ThemeProvider>
    );
  }
}

const styles = (theme) => {
  const toolbarHeight = 35;
  return {
    cytoscapeContainer: {
      height: '70vh',
      width: '100%',
      border: 'solid 1px gray',
      overflow: 'hidden',
      marginTop: toolbarHeight,
    },
    graphToolbar: {
      [theme.breakpoints.up('md')]: {
        display: 'none',
      },
    },
    graphSidebar: {
      margin: `${toolbarHeight}px 0 0 ${theme.spacing.unit * 3}px`,
    },
    graphSidebarCheckbox: {
      width: 24,
      height: 30,
    },
    graphSidebarText: {
      fontStyle: 'italic',
      marginLeft: '-0.5em',
    },
    graphSidebarTextLevel0: {
      fontWeight: 'bold',
      fontStyle: 'normal',
      fontSize: '0.9em',
      textTransform: 'uppercase',
    },
    graphSidebarTextLevel1: {
      fontWeight: 'bold',
      fontStyle: 'normal',
    },
    graphSidebarTextLevel2: {
      fontStyle: 'normal',
    },
  };
};
export default withStyles(styles, {withTheme: true})(InteractionGraph);
