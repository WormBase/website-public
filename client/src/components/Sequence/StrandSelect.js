import React from 'react';
import PropTypes from 'prop-types';
import { createMuiTheme, MuiThemeProvider, withStyles } from '@material-ui/core/styles';
import pink from '@material-ui/core/colors/pink';
import teal from '@material-ui/core/colors/blue';
import Tab from '../Tab';
import Tabs from '../Tabs';

const strandTheme = createMuiTheme({
  palette: {
    primary: teal,
    secondary: pink,
  },
});

class StrandSelect extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      strand: props.initialStrand,
    };
  }

  valueToStrand = (value) => {
    return value === 0 ? '+' : '-';
  }

  strandToValue = (strand) => {
    return strand === '+' ? 0 : 1;
  }

  handleChange = (event, value) => {
    this.setState({
      strand: this.valueToStrand(value),
    });
  }

  render() {
    const {strand} = this.state;
    const {classes} = this.props;
    return (
      <div>
        <MuiThemeProvider theme={strandTheme}>
          <Tabs
            value={this.strandToValue(strand)}
            indicatorColor={strand === '+' ? "secondary" : "primary"}
            textColor={strand === '+' ? "secondary" : "primary"}
            onChange={this.handleChange}
          >
            <Tab label="(+) strand" />
            <Tab label="(-) strand" />
          </Tabs>
        </MuiThemeProvider>
        <div className={classes[strand === '+' ? 'positiveStrand' : 'negativeStrand']}>
          {
            this.props.children({
              strand: strand,
            })
          }
        </div>
      </div>
    );
  }
}

StrandSelect.defaultProps = {
  initialStrand: '+',
};

StrandSelect.propTypes = {
  initialStrand: PropTypes.oneOf(['+', '-']),
  children: PropTypes.func.isRequired,
  classes: PropTypes.object.isRequired,
};

const styles = (theme) => ({
  'positiveStrand': {
    borderLeft: `solid ${strandTheme.palette.secondary.light} ${1}px`,
  },
  'negativeStrand': {
    borderLeft: `solid ${strandTheme.palette.primary.light} ${1}px`,
  },
});

export default withStyles(styles)(StrandSelect);
