import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import { fade } from '@material-ui/core/styles/colorManipulator';
import classNames from 'classnames';
import CancelIcon from '@material-ui/icons/Cancel';
import List, {
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  ListSubheader,
} from '../../../List';
import { IconButton } from '../../../Button';
import { fitComponent } from '../../../styles';
import { pluralize } from '../../../../utils';
import ReferenceList from './ReferenceList';
import ReferenceItem from './ReferenceItem';
import DownloadReference from './DownloadReference';

const TEXTPRESSO_TYPE_SET = new Set([
  'strain',
  'gene',
  'gariation',
  'transgene',
  'construct',
  'anatomy_term',
  'clone',
  'life_stage',
  'rearrangement',
  'molecule',
  'process',
]);

class References extends Component {
  static propTypes = {
    data: PropTypes.arrayOf(
      PropTypes.shape({
        year: PropTypes.any,
      })
    ).isRequired,
    pageInfo: PropTypes.shape({
      name: PropTypes.string,
      other_names: PropTypes.arrayOf(PropTypes.string),
    }).isRequired,
    classes: PropTypes.object.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = {
      paperType: null,
    };
  }

  handlePaperTypeUpdate = (paperType) => {
    this.setState((prevState) => ({
      paperType: paperType === prevState.paperType ? null : paperType,
    }));
  };

  filterData = (data) => {
    return data.filter(
      (row) => !this.state.paperType || row.ptype === this.state.paperType
    );
  };

  compareYear = (rowA, rowB) => {
    const parseRowYear = (row) => {
      return parseInt(row.year, 10) || -1;
    };
    return parseRowYear(rowB) - parseRowYear(rowA);
  };

  countsByPaperTypes = (rows) => {
    return rows.reduce((counts, row) => {
      const ptype = row.ptype;
      counts[ptype] = counts[ptype] ? counts[ptype] + 1 : 1;
      return counts;
    }, {});
  };

  render() {
    const counts = this.countsByPaperTypes(this.props.data);
    const { classes, pageInfo } = this.props;

    const data = this.filterData(this.props.data).sort(this.compareYear);

    const FittedListSubheader = fitComponent(ListSubheader);

    return (
      <div className={classes.root}>
        <div className={classes.sidebar}>
          <List
            dense
            subheader={<ListSubheader>Filter by article type</ListSubheader>}
          >
            {Object.keys(counts)
              .sort()
              .map((paperType) => {
                const isSelected =
                  this.state.paperType && this.state.paperType === paperType;
                // console.log(isSelected);
                return (
                  <ListItem
                    button
                    dense
                    key={paperType}
                    classes={{
                      button: classNames({ [classes.selected]: isSelected }),
                    }}
                    onClick={() => this.handlePaperTypeUpdate(paperType)}
                  >
                    <ListItemText
                      primary={paperType}
                      secondary={counts[paperType]}
                    />
                    {isSelected ? (
                      <ListItemSecondaryAction>
                        <IconButton
                          onClick={() => this.handlePaperTypeUpdate(paperType)}
                          aria-label="Cancel filter"
                        >
                          <CancelIcon />
                        </IconButton>
                      </ListItemSecondaryAction>
                    ) : null}
                  </ListItem>
                );
              })}
          </List>
        </div>
        <div className={classes.content}>
          <FittedListSubheader widthOnly component="div">
            <div>
              {this.state.paperType ? (
                <span>
                  {data.length} / {this.props.data.length}{' '}
                  {pluralize('reference', data.length)} found matching your
                  filter
                </span>
              ) : (
                <span>
                  {data.length} {pluralize('reference', data.length)} found
                </span>
              )}
            </div>
          </FittedListSubheader>
          <ReferenceList data={data}>
            {(pageData) =>
              pageData.map((itemData) => (
                <ReferenceItem key={itemData.name.id} data={itemData} />
              ))
            }
          </ReferenceList>
          <DownloadReference
            data={data}
            fileName={`${pageInfo.name}_references.csv`}
          >
            Download all references
          </DownloadReference>

          {TEXTPRESSO_TYPE_SET.has(pageInfo.class) ? (
            <section className={classes.textpressoSection}>
              <h4>Looking for more references? </h4>
              <p>
                Find references identified using machine learning on{' '}
                <a
                  className="wb-ext"
                  href={`https://www.textpressocentral.org/tpc/search?keyword=${[
                    pageInfo.name,
                    ...pageInfo.other_names,
                  ].join(' OR ')}&scope=document&literature=C. elegans`}
                  target="_blank"
                >
                  Textpresso
                </a>
              </p>
            </section>
          ) : null}
        </div>
      </div>
    );
  }
}

const styles = (theme) => {
  const sidebarWidth = 200;
  const grooveWidth = 0;
  return {
    root: {
      display: 'flex',
      flexWrap: 'wrap',
      justifyContent: 'space-between',
      flexDirection: 'row-reverse',
    },
    content: {
      [theme.breakpoints.up('md')]: {
        width: `calc(100% - ${sidebarWidth + grooveWidth}px)`,
      },
    },
    sidebar: {
      width: `calc(100% + ${2 * theme.spacing.unit}px)`,
      margin: `0 ${-2 * theme.spacing.unit}px`,
      [theme.breakpoints.up('md')]: {
        width: sidebarWidth,
        minHeight: 200,
      },
    },
    selected: {
      backgroundColor: fade(theme.palette.text.primary, 0.12),
    },
    textpressoSection: {
      margin: `${theme.spacing.unit * 5}px 0`,
      textAlign: 'center',
      '& p': {
        margin: `${theme.spacing.unit}px 0`,
      },
    },
  };
};

export default withStyles(styles, { withTheme: true })(References);
