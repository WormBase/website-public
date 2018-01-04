import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import { fade } from 'material-ui/styles/colorManipulator';
import classNames from 'classnames';
import CancelIcon from 'material-ui-icons/Cancel';
import List, { ListItem, ListItemText, ListItemSecondaryAction, ListSubheader } from '../../../List';
import { IconButton } from '../../../Button';
import Fit from '../../../Fit';
import ReferenceList from './ReferenceList';
import ReferenceItem from './ReferenceItem';

class References extends Component {
  static propTypes = {
    data: PropTypes.arrayOf(
      PropTypes.shape({
        year: PropTypes.any,
      }),
    ).isRequired,
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
  }

  filterData = (data) => {
    return data.filter((row) => true);
  };

  compareYear = (rowA, rowB) => {
    const parseRowYear = (row) => {
      return parseInt(row.year, 10) || -1;
    }
    return parseRowYear(rowB) - parseRowYear(rowA);
  }

  countsByPaperTypes = (rows) => {
    return rows.reduce((counts, row) => {
      const ptype = row.ptype;
      counts[ptype] = counts[ptype] ? counts[ptype] + 1 : 1;
      return counts;
    }, {});
  }

  render() {
    const data = this.filterData(this.props.data).sort(this.compareYear);
    const counts = this.countsByPaperTypes(data);
    const {classes} = this.props;
    return (
      <div className={classes.root}>
        <div className={classes.sidebar}>
          <List dense subheader={<ListSubheader>Filter by article type</ListSubheader>}>
            {
              Object.keys(counts).sort().map(
                (paperType) => {
                  const isSelected = this.state.paperType && this.state.paperType === paperType;
                  // console.log(isSelected);
                  return (
                    <ListItem
                      button
                      dense
                      key={paperType}
                      classes={{ button: classNames({[classes.selected]: isSelected})}}
                      onClick={() => this.handlePaperTypeUpdate(paperType)}
                      >
                      <ListItemText primary={paperType} secondary={counts[paperType]} />
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
                  )
                })
            }
          </List>
        </div>
        <div className={classes.content}>
          <Fit><ListSubheader component="div">aaaa</ListSubheader></Fit>
          <ReferenceList
            data={data.filter((row) => !this.state.paperType || row.ptype === this.state.paperType )}
          >
            {
              (pageData) => pageData.map(
                (itemData) => <ReferenceItem key={itemData.name.id} data={itemData} />
              )
            }
          </ReferenceList>
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
      width: `calc(100% + ${4 * theme.spacing.unit}px)`,
      margin: `0 ${-2 * theme.spacing.unit}px`,
      [theme.breakpoints.up('md')]: {
        width: sidebarWidth,
        height: 200,
      },
    },
    selected: {
      backgroundColor: fade(theme.palette.text.primary, 0.12),
    },
  };
};

export default withStyles(styles, {withTheme: true})(References);
