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
import { buildUrl } from '../Link';
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
        type: PropTypes.string.isRequired,
      })
    ),
    interactorMap: PropTypes.objectOf(
      PropTypes.shape({
        id: PropTypes.string.isRequired,
        label: PropTypes.string.isRequired,
        main: PropTypes.any,
        "class": PropTypes.string,
      })
    ),
    classes: PropTypes.object.isRequired,
  };

  resetSelectedTypes = () => {
    const defaultExcludes = this.props.interactions.length < 100 ?
                            new Set(['predicted', 'regulatory:does not regulate', 'gi-module-three:neutral']) :
                            new Set(['predicted', 'regulatory', 'genetic']);
    console.log(defaultExcludes);
    const availableTypes = new Set(this.props.interactions.map((interaction) => interaction.type));
    this.setState({
      interactionTypeSelected: [...availableTypes].filter(
        (t) => {
          const inferredTypes = this.getInferredTypes(t);
          return inferredTypes.filter(
            (tx) => defaultExcludes.has(tx)
          ).length === 0;
        }
      )
    })
  }

  componentWillMount() {
    this.resetSelectedTypes();
  }

  componentDidMount() {
    this.setupCytoscape();
    this.updateCytoscape();
  }

  componentWillReceiveProps() {
    this.resetSelectedTypes();
    this.setupCytoscape();
  }

  componentDidUpdate() {
    this.updateCytoscape();
  }

  componentWillUnmount() {
    this._cy.destroy();
  }

  edgeId = (interaction) => {
    const {effector, affected, type} = interaction;
    const source = effector.id;
    const target = affected.id;
    return `${source}|${target}|${type}`;
  }

  subset = () => {
    const interactionTypeSelected = new Set(this.state.interactionTypeSelected);
    const edgesSubset = this.props.interactions.filter(
      (edge) => {
        return interactionTypeSelected.has(edge.type) &&
               (this.state.includeNearbyInteraction || !parseInt(edge.nearby));
      }
    );

    return new Set([
      ...edgesSubset.map((edge) => edge.effector.id),
      ...edgesSubset.map((edge) => edge.affected.id),
      ...edgesSubset.map((interaction) => this.edgeId(interaction))
    ]);

  }

  setupCytoscape = () => {
    const edges = this.props.interactions.map(
      (interaction) => {
        const {effector, affected, direction, type, citations} = interaction;
        const source = effector.id;
        const target = affected.id;
        return {
          group: 'edges',
          data: {
            id: this.edgeId(interaction),
            source: source,
            target: target,
            color: this.getEdgeColor(type),
            directioned: direction !== "non-directional",
            weight: Math.min((citations || []).length, 10),
            type: type,
            visibility: 'hidden',
          }
        };
      }
    );

    const nodes = Object.keys(this.props.interactorMap).map(
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
            main: rest.main,
            shape: getShape(rest.class),
            visibility: 'hidden',
          }
        };
      }
    );

    const elements = [...nodes, ...edges];
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
          'visibility': 'data(visibility)',
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
          'visibility': 'data(visibility)',
          'width': 'data(weight)',
          'opacity':0.6,
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
        .selector('node[?main]')
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

    this._cy.on('tap', 'node', (event) => {
      const nodeId = event.target.id();
      const data = this.props.interactorMap[nodeId];
      window.open(buildUrl({...data}));
    });
  }

  updateCytoscape = () => {
    const subset = this.subset();
    this._cy.filter('*').forEach(
      (ele, i, eles) => ele.data('visibility', subset.has(ele.id()) ? 'visible' : 'hidden')
    );
  }

  subsetRedraw = () => {
    const subset = this.subset();
    this._cy.filter(
      (ele) => subset.has(ele.id())
    ).layout({
      name: 'cola'
    }).run();
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

  getEdgeColor = (type) => {
    const colorScheme = [
      "#33a02c",  //"#0A6314",  // green
      "#6a3d9a",  //"#69088A",  // dark purple
      "#ff7f00",  //"#FF8000",  // orange
      "#1f78b4",  //"#08298A",  // blue
      "#00E300",  // bright green
      "#05C1F0",  // light blue
      "#8000FF",  // purple
      "#B40431",  // red
      "#B58904",
      "#E02D8A",
      "#FFFC2E",
    ];
    const inferredTypes = new Set(this.getInferredTypes(type));
    const tests = [
      () => inferredTypes.has('physical'),
      () => inferredTypes.has('genetic'),
      () => inferredTypes.has('regulatory:positively regulates'),
      () => inferredTypes.has('regulatory:negatively regulates'),
    ];
    const colorIndex = tests.findIndex((test, index) => test());;
    return colorIndex === -1 ? 'gray' : colorScheme[colorIndex];
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
          style={{color: this.getEdgeColor(interactionType)}}
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
      <div className={classes.buttonWrapper}>
        <Button
          className={classes.button}
          raised
          dense
          onClick={() => this.subsetRedraw() }
        >
          Redraw
        </Button>
        <Button
          className={classNames([classes.button, classes.sidebarToggleButton])}
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
             label: 'All interaction types'
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
                ['one', 'two', 'three'].map((giModuleNumber) => {
                  const giModule = `gi-module-${giModuleNumber}`;
                  const descendentTypes = this.getDescentTypes(giModule);
                  return (
                    <CompactList key={giModule}>
                      {this.renderInteractionTypeSelect(giModule, {label: `module ${giModuleNumber}`})}
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
      minHeight: 360,
      minWidth: 360,
      height: '70vh',
      width: '100%',
      border: 'solid 1px gray',
      overflow: 'hidden',
    },
    graphToolbar: {
    },
    buttonWrapper: {
      margin: `${theme.spacing.unit / 2}px`,
    },
    button: {
      margin: `${theme.spacing.unit / 2}px`,
    },
    sidebarToggleButton: {
      [theme.breakpoints.up('md')]: {
        display: 'none',
      },
    },
    graphSidebar: {
      padding: `${theme.spacing.unit * 3}px ${theme.spacing.unit}px`,
    },
    graphSidebarCheckbox: {
      width: 24,
      height: 30,
    },
    graphSidebarText: {
      fontStyle: 'italic',
      marginLeft: '-0.5em',
      textTransform: 'capitalize',
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
