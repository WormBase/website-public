import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cytoscape from 'cytoscape';
import cytoscapecola from 'cytoscape-cola';
import { withStyles } from '@material-ui/core/styles';
import classNames from 'classnames';
import ResponsiveDrawer from '../ResponsiveDrawer';
import Button from '../Button';
import Switch from '../Switch';
import Checkbox from '../Checkbox';
import {
  ListItemByLevel as ListItem,
  ListItemText,
  CompactList,
} from '../List';
import { buildUrl } from '../Link';
import { FormControlLabel } from '../Form';
import ThemeProvider from '../ThemeProvider';

cytoscape.use(cytoscapecola);

class InteractionGraph extends Component {
  constructor(props) {
    super(props);
    this.state = {
      includeNearbyInteraction: true,
      includeHighThroughput: false,
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
        class: PropTypes.string,
      })
    ),
    focusNodeId: PropTypes.string,
    classes: PropTypes.object.isRequired,
  };

  resetSelectedTypes = () => {
    const defaultInclude = ['physical'];
    const defaultExcludes =
      this.props.interactions.length < 100
        ? new Set([
            'predicted',
            'regulatory:does not regulate',
            'gi-module-three:neutral',
            'genetic:other',
          ])
        : new Set(['predicted', 'regulatory:does not regulate', 'genetic']);
    const availableTypes = new Set([
      ...defaultInclude,
      ...this.props.interactions.map((interaction) => interaction.type),
    ]);
    this.setState({
      interactionTypeSelected: [...availableTypes].filter((t) => {
        const inferredTypes = this.getInferredTypes(t);
        return (
          inferredTypes.filter((tx) => defaultExcludes.has(tx)).length === 0
        );
      }),
    });
  };

  componentWillMount() {
    this.resetSelectedTypes();
  }

  componentDidMount() {
    this.setupCytoscape();
    this.updateCytoscape();
    this.subsetRedraw();
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
    const { effector, affected, direction, type } = interaction;
    let source = effector.id;
    let target = affected.id;
    if (direction === 'non-directional') {
      [source, target] = [source, target].sort();
    }
    return `${source}|${target}|${direction}|${type}`;
  };

  subset = () => {
    const interactionTypeSelected = new Set(this.state.interactionTypeSelected);

    // edges based on un-filtered list of annotations
    const edgesAll = Object.values(
      this.props.interactions.reduce((result, annotation) => {
        const edgeKey = this.edgeId(annotation);
        const { effector, affected, direction, type } = annotation;
        if (!result[edgeKey]) {
          result[edgeKey] = {
            effector,
            affected,
            direction,
            type,
          };
        }
        return result;
      }, {})
    );

    // annotations based on filtering criteria
    const annotationsSubset = this.props.interactions.filter(
      ({ type, nearby, throughput }) => {
        return (
          interactionTypeSelected.has(type) &&
          (this.state.includeNearbyInteraction || !nearby) &&
          (this.state.includeHighThroughput || throughput !== 'High throughput')
        );
      }
    );

    // collect citations based on annotations matching the filtering criteria
    const edgesSubset = annotationsSubset.reduce((result, annotation) => {
      const edgeKey = this.edgeId(annotation);
      const { citation } = annotation;
      if (!result[edgeKey]) {
        result[edgeKey] = new Set();
      }
      if (citation) {
        result[edgeKey].add(citation.id);
      }
      return result;
    }, {});

    const visibleSet = new Set([
      ...annotationsSubset.map((edge) => edge.effector.id),
      ...annotationsSubset.map((edge) => edge.affected.id),
      ...annotationsSubset.map((edge) => this.edgeId(edge)),
    ]);
    return {
      edgesAll: [...edgesAll],
      getEdgeWeight: (edgeKey) =>
        edgesSubset[edgeKey] && edgesSubset[edgeKey].size,
      isVisible: (elementId) => visibleSet.has(elementId),
    };
  };

  setupCytoscape = () => {
    const { edgesAll } = this.subset();
    const edges = edgesAll.map((interaction) => {
      const { effector, affected, direction, type } = interaction;
      const source = effector.id;
      const target = affected.id;
      return {
        group: 'edges',
        data: {
          id: this.edgeId(interaction),
          source: source,
          target: target,
          color: this.getEdgeColor(type),
          directioned: direction !== 'non-directional',
          type: type,
          visibility: 'hidden',
        },
      };
    });

    const nodes = Object.keys(this.props.interactorMap).map((interactorId) => {
      const { label, ...rest } = this.props.interactorMap[interactorId];
      const getShape = (type) => {
        const type2shape = {
          rearrangement: 'hexagon',
          molecule: 'triangle',
          feature: 'rectangle',
        };
        return type2shape[type] || 'ellipse';
      };

      return {
        group: 'nodes',
        data: {
          id: interactorId,
          label: label,
          color: 'gray',
          main: interactorId === this.props.focusNodeId,
          shape: getShape(rest.class),
          visibility: 'hidden',
        },
      };
    });

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
          label: 'data(label)',
          visibility: 'data(visibility)',
          opacity: 0.9,
          'border-width': 0,
          shape: 'data(shape)',
          height: 15,
          width: 15,
          'font-size': 10,
          'text-valign': 'center',
          color: 'black',
          'text-outline-color': 'white',
          'text-outline-width': 1,
        })
        .selector('edge')
        .css({
          visibility: 'data(visibility)',
          width: 'data(weight)',
          opacity: 0.6,
          'line-color': 'data(color)',
          'line-style': 'solid',
          'curve-style': 'bezier',
        })
        .selector('edge[type="predicted"]')
        .css({
          'line-style': 'dotted',
        })
        .selector('edge[?directioned]')
        .css({
          'target-arrow-shape': 'triangle',
          'target-arrow-color': 'data(color)',
          'source-arrow-color': 'data(color)',
        })
        .selector('node[?main]')
        .css({
          height: '40px',
          width: '40px',
          'background-color': 'red',
        })
        .selector(':selected')
        .css({
          opacity: 1,
          'border-color': 'black',
          'border-width': 1,
        }),

      layout: this.getLayoutSetting(),
    });

    this._cy.userZoomingEnabled(false);

    this._cy.on('tap', 'node', (event) => {
      const nodeId = event.target.id();
      const data = this.props.interactorMap[nodeId];
      window.open(buildUrl({ ...data }));
    });
  };

  getLayoutSetting = () => {
    return {
      name: 'cola',
      fit: false,
      ready: () => {
        this._cy.userZoomingEnabled(true);
      },
      stop: () => {
        this._cy.userZoomingEnabled(true);
      },
    };
  };

  updateCytoscape = () => {
    const { isVisible, getEdgeWeight } = this.subset();
    this._cy.filter('*').forEach((ele, i, eles) => {
      ele.data('visibility', isVisible(ele.id()) ? 'visible' : 'hidden');
      ele.data('weight', getEdgeWeight(ele.id()));
    });
  };

  subsetRedraw = () => {
    const { isVisible } = this.subset();
    this._cy.userZoomingEnabled(false);
    this._cy
      .filter((ele) => isVisible(ele.id()))
      .layout(this.getLayoutSetting())
      .run();
  };

  getInferredTypes = (type) => {
    const inferredTypes = new Set([type, 'all']);
    inferredTypes.add(type.split(':')[0]);
    if (type.match(/gi-module-.+/)) {
      inferredTypes.add('genetic');
    }
    return [...inferredTypes];
  };

  getDescentTypes = (type) => {
    const availableTypes = new Set(
      this.props.interactions.map((interaction) => interaction.type)
    );
    const interactionTypes = [
      'predicted',
      'physical',
      'regulatory',
      'genetic',
      'gi-module-one',
      'gi-module-two',
      'gi-module-three',
      ...availableTypes,
    ];
    if (type === 'all') {
      return interactionTypes;
    } else if (type === 'genetic') {
      return interactionTypes.filter(
        (t) => t.match(/gi-module-.+/) || t === 'genetic:other'
      );
    } else {
      return interactionTypes.filter(
        (t) => t.indexOf(type) !== -1 && t !== type
      );
    }
  };

  isInteractionTypeSelected = (type) => {
    return this.state.interactionTypeSelected.indexOf(type) !== -1;
  };

  countInteractionsOfType = (type) => {
    const subtypes = new Set([type, ...this.getDescentTypes(type)]);
    const interactionsSet = this.props.interactions.reduce(
      (result, interaction) => {
        if (
          subtypes.has(interaction.type) &&
          (this.state.includeNearbyInteraction || !interaction.nearby) &&
          (this.state.includeHighThroughput ||
            interaction.throughput !== 'High throughput')
        ) {
          const edgeKey = this.edgeId(interaction);
          result.add(edgeKey);
        }
        return result;
      },
      new Set([])
    );
    return interactionsSet.size;
  };

  handleInteractionTypeSelection = (type) => {
    this.setState((prevState) => {
      const inferredTypes = this.getInferredTypes(type);
      const descendentTypes = this.getDescentTypes(type);
      if (this.isInteractionTypeSelected(type)) {
        // de-select
        return {
          interactionTypeSelected:
            type === 'all'
              ? []
              : prevState.interactionTypeSelected.filter((prevType) => {
                  return (
                    inferredTypes.indexOf(prevType) === -1 && // prevType is not a inferredType
                    descendentTypes.indexOf(prevType) === -1 // prevType is not a descendent type
                  );
                }),
        };
      } else {
        return {
          interactionTypeSelected: [
            ...prevState.interactionTypeSelected,
            ...descendentTypes,
            type,
          ],
        };
      }
    });
  };

  getInteractionTypeName = (interactionType) => {
    const parts = ('' || interactionType).split(':');
    return parts[parts.length - 1];
  };

  getEdgeColor = (type) => {
    const colorScheme = [
      '#33a02c', //"#0A6314",  // green
      '#6a3d9a', //"#69088A",  // dark purple
      '#ff7f00', //"#FF8000",  // orange
      '#1f78b4', //"#08298A",  // blue
      '#00E300', // bright green
      '#05C1F0', // light blue
      '#8000FF', // purple
      '#B40431', // red
      '#B58904',
      '#E02D8A',
      '#FFFC2E',
    ];
    const inferredTypes = new Set(this.getInferredTypes(type));
    const tests = [
      () => inferredTypes.has('physical'),
      () => inferredTypes.has('genetic'),
      () => inferredTypes.has('regulatory'),
    ];
    const colorIndex = tests.reduce(
      (result, test, index) =>
        result === -1 ? (test() ? index : result) : result,
      -1
    );
    return colorIndex === -1 ? 'gray' : colorScheme[colorIndex];
  };

  renderInteractionTypeSelect = (interactionType, { label } = {}) => {
    let level = this.getInferredTypes(interactionType).length - 1;
    level = Math.max(0, level);
    level = Math.min(2, level);
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
          style={{ color: this.getEdgeColor(interactionType) }}
          disableRipple
          classes={{
            root: this.props.classes.graphSidebarCheckbox,
          }}
          checked={this.isInteractionTypeSelected(interactionType)}
        />
        <ListItemText
          primary={label || this.getInteractionTypeName(interactionType)}
          classes={{
            primary: classNames([
              this.props.classes.graphSidebarText,
              this.props.classes[`graphSidebarTextLevel${level}`],
            ]),
          }}
        />
        <span className={this.props.classes.graphSidebarCount}>
          {this.countInteractionsOfType(interactionType)}
        </span>
      </ListItem>
    );
  };

  render() {
    const { classes } = this.props;

    const graphView = (
      <div
        ref={(c) => (this._cytoscapeContainer = c)}
        className={classes.cytoscapeContainer}
      />
    );

    const graphToolbar = (
      <div className={classes.buttonWrapper}>
        <Button
          className={classes.button}
          variant="contained"
          size="small"
          onClick={() => this.subsetRedraw()}
        >
          Re-position
        </Button>
        <Button
          className={classNames([classes.button, classes.sidebarToggleButton])}
          variant="contained"
          size="small"
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
            label: 'All interaction types',
          })}
          <CompactList>
            {this.renderInteractionTypeSelect('predicted')}
            {this.renderInteractionTypeSelect('physical')}
            <CompactList>
              {this.getDescentTypes('physical').map((t) => {
                return this.renderInteractionTypeSelect(t);
              })}
            </CompactList>
            {this.renderInteractionTypeSelect('regulatory')}
            <CompactList>
              {this.getDescentTypes('regulatory').map((t) => {
                return this.renderInteractionTypeSelect(t);
              })}
            </CompactList>
            {this.renderInteractionTypeSelect('genetic')}
            <CompactList>
              {this.getDescentTypes('gi-module-two').map((t) =>
                this.renderInteractionTypeSelect(t)
              )}
              {this.getDescentTypes('gi-module-three').map((t) =>
                this.renderInteractionTypeSelect(t)
              )}
              {this.renderInteractionTypeSelect('genetic:other')}
            </CompactList>
          </CompactList>
        </CompactList>
        <FormControlLabel
          classes={{
            label: classNames([
              this.props.classes.graphSidebarText,
              this.props.classes.graphSidebarTextLevel0,
            ]),
          }}
          control={
            <Switch
              color="primary"
              checked={this.state.includeHighThroughput}
              onChange={(event, checked) =>
                this.setState({ includeHighThroughput: checked })
              }
            />
          }
          label="High-throughput"
        />
        <FormControlLabel
          classes={{
            label: classNames([
              this.props.classes.graphSidebarText,
              this.props.classes.graphSidebarTextLevel0,
            ]),
          }}
          control={
            <Switch
              color="primary"
              checked={this.state.includeNearbyInteraction}
              onChange={(event, checked) =>
                this.setState({ includeNearbyInteraction: checked })
              }
            />
          }
          label="Nearby interaction"
        />
      </div>
    );

    return (
      <ThemeProvider>
        <ResponsiveDrawer
          innerRef={(c) => (this._drawerComponent = c)}
          anchor="right"
          drawerContent={graphSidebar}
          mainContent={graphView}
          mainHeader={graphToolbar}
        />
      </ThemeProvider>
    );
  }
}

const styles = (theme) => {
  return {
    cytoscapeContainer: {
      minHeight: 360,
      minWidth: 360,
      height: '100%',
      width: '100%',
      overflow: 'hidden',
    },
    graphToolbar: {},
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
      padding: `${theme.spacing.unit / 4}px 0`,
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
    graphSidebarCount: {
      color: theme.palette.text.secondary,
      fontWeight: 'normal',
    },
  };
};
export default withStyles(styles, { withTheme: true })(InteractionGraph);
