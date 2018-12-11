import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Button from './Button';
import { CircularProgress } from './Progress';

class DownloadButton extends Component {
  constructor(props) {
    super(props);
    this.state = {
      status: 'READY',
    };
  }

  handleClick = () => {
    if (this.state.status === 'READY') {
      this.setState({
        status: 'PENDING',
      }, () => {
        Promise.resolve(this.props.contentFunc()).then(
          (content) => {
            (this.props.fileSaveFunc || this.defaultFileSaveFunc)(content);
            this.setState({
              status: 'READY',
            });
          }
        ).catch(() => {
          this.setState({
            status: 'READY',
          });
        });
      });
    }
  }

  defaultRenderer = (props) => (
    <Button variant="contained" {...props}>
      {props.children || 'Download'}
      {this.state.status === 'PENDING' ? <CircularProgress /> : null}
    </Button>
  )

  defaultFileSaveFunc = (content) => {
    import('file-saver').then((module) => {
      const {saveAs} = module;
      const blob = new Blob([content], {type: "text/plain;charset=utf-8"});
      saveAs(blob, this.props.fileName || 'download.txt');
    });
  }

  render() {
    const {renderer,
           fileName,
           contentFunc,
           fileSaveFunc,
           ...restProps} = this.props;
    const Renderer = renderer || this.defaultRenderer;
    return (
      <Renderer
        onClick={this.handleClick}
        {...restProps}
      />
    );
  }
}

DownloadButton.defaultProps = {
};

DownloadButton.propTypes = {
  fileName: PropTypes.string,
  contentFunc: PropTypes.func.isRequired,
  fileSaveFunc: PropTypes.func,
  renderer: PropTypes.oneOfType([
    PropTypes.func,
    PropTypes.element,
  ]),
};

export default DownloadButton;