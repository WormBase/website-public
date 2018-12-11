import React from 'react';
import PropTypes from 'prop-types';
import MuiList from '@material-ui/core/List';
import MuiListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListSubheader from '@material-ui/core/ListSubheader';

const ListItemByLevel = ({level, indentUnitWidth, style, ...props}) => {
  const newStyle = {
    padding: 0,
    paddingLeft: (level || 0) * indentUnitWidth,
    ...style
  };
  return (
    <MuiListItem
      style={newStyle}
      disableRipple
      {...props}
    />
  );
};
ListItemByLevel.propTypes = {
  level: PropTypes.number,
  indentUnitWidth: PropTypes.number,
};

const CompactList = (props) => (<List disablePadding {...props} />);

const List = MuiList;

const ListItem = (props) => <MuiListItem disableRipple {...props} />;

export default List;

export {
  ListItem,
  ListItemByLevel,
  ListItemIcon,
  ListItemText,
  ListSubheader,
  ListItemSecondaryAction,
  CompactList,
};
