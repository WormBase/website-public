import React from 'react';
import PropTypes from 'prop-types';
import MuiList, { ListItem as MuiListItem, ListItemIcon, ListItemText, ListItemSecondaryAction } from 'material-ui/List';

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
  ListItemSecondaryAction,
  CompactList,
};
