import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import SaveIcon from '@material-ui/icons/Save';
//import CopyIcon from '@material-ui/icons/FileCopy';
import ExpandMoreIcon from '@material-ui/icons/ArrowRight';
import ExpandLessIcon from '@material-ui/icons/ArrowDropDown';
import Sequence from './Sequence';
import DownloadButton from '../DownloadButton';
import { IconButton } from '../Button';
import CardActionArea from '../CardActionArea';
import Tooltip from '../Tooltip';


class SequenceCard extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      expand: true,
    };
  }

  handleExpandToggle = () => {
    this.setState((prevState) => ({
      expand: !prevState.expand,
    }));
  }

  render() {
    const {
      classes,
      sequence = '',
      title = 'Sequence',
      downloadFileName = 'sequence.fasta',
      ...sequenceProps,
    } = this.props;
    const {expand} = this.state;
    return sequence ? (
      <Card elevation={0}>
        <CardActions className={classes.actions}>
          <Tooltip title={expand ? 'Collapse' : 'Expand'}>
            <CardActionArea className={classes.expandToggleAction} onClick={this.handleExpandToggle}>

              {
                expand ? <ExpandLessIcon /> : <ExpandMoreIcon />
              }

              <h5 className={classes.title}>{title}</h5>
            </CardActionArea>
          </Tooltip>
          <Tooltip title="Save to file">
            <DownloadButton
              fileName={downloadFileName}
              renderer={(props) => (
                <IconButton {...props}>
                  <SaveIcon />
                </IconButton>
              )}
              contentFunc={() => `> ${title}\r\n${sequence}` }
            />
          </Tooltip>
          {/* <Tooltip title="Copy to clipboard">
              <IconButton >
              <CopyIcon />
              </IconButton>
              </Tooltip> */}
        </CardActions>
        {
          expand ? <Sequence title={title} sequence={sequence} {...sequenceProps} /> : null
        }
      </Card>
    ) : null;
  }
}

SequenceCard.propTypes = {
  classes: PropTypes.object.isRequired,
  title: PropTypes.string,
  downloadFileName: PropTypes.string,
};

const styles = (theme) => ({
  actions: {
    alignItems: 'stretch',
  },
  expandToggleAction: {
    display: 'flex',
    width: 'initial',
    paddingRight: theme.spacing.unit,
  },
  title: {
  },
});

export default withStyles(styles)(SequenceCard);
