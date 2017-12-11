import React, { Component } from 'react';
import PropTypes from 'prop-types';
import List, { ListItem as MuiListItem, ListItemIcon, ListItemText } from 'material-ui/List';

const ListItem = ({level, indentUnitWidth, style, ...props}) => {
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
ListItem.propTypes = {
  level: PropTypes.number,
  indentUnitWidth: PropTypes.number,
};

const CompactList = (props) => (<List disablePadding {...props} />);

export default List;

export {
  ListItem,
  ListItemIcon,
  ListItemText,
  CompactList,
};
