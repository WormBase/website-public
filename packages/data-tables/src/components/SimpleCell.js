import React from 'react';
import PropTypes from 'prop-types';
import Link from './Link';
import { makeStyles } from '@material-ui/core/styles';
import ReactHtmlParser from 'react-html-parser';

const useStyles = makeStyles((theme) => ({
  root: {
    margin: `${theme.spacing(0.75)}px 0`,
    overflowWrap: 'anywhere',
  },
}));

const SimpleCell = ({ data, children }) => {
  const classes = useStyles();
  let content;

  if (children) {
    content = children;
  } else if (data !== null && typeof data === 'object') {
    if (data.text && typeof data.text !== 'object') {
      content = data.text;
    } else if (data.class) {
      content = <Link {...data} />;
    } else {
      content = JSON.stringify(data);
    }
  } else {
    content = data;
  }

  return (
    <div className={classes.root}>
      {typeof content === 'string'
        ? ReactHtmlParser(content, {
            transform: (node) => {
              if (node.attribs?.onclick) {
                return (
                  <div dangerouslySetInnerHTML={{ __html: content }}></div>
                );
              }
              return undefined;
            },
          })
        : content}
    </div>
  );
};

SimpleCell.propTypes = {
  data: PropTypes.any,
};

export default SimpleCell;
