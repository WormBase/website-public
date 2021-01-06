import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import { CircularProgress } from './Progress';
import withInnerHtmlFromUrl from './withInnerHtmlFromUrl';
import Breadcrumb from './Breadcrumb';

class SingleWidgetPage extends React.Component {
  renderProgress = () => {
    return (
      <div className={this.props.classes.spinner}>
        <CircularProgress color="inherit" />
      </div>
    );
  };

  render() {
    const Widget = withInnerHtmlFromUrl(
      'div',
      this.props.widgetUrl,
      this.renderProgress()
    );
    return (
      <div className={this.props.classes.page}>
        <div className={this.props.classes.pageTitleWrapper}>
          <div className={this.props.classes.breadcrumbs}>
            {this.props.section === 'species' ? (
              <Breadcrumb
                trail={[
                  { label: 'Species', url: '/species/all' },
                  this.props.object.taxonomy
                    ? {
                        label: this.props.species.title,
                        url: `/species/${this.props.object.taxonomy}`,
                      }
                    : null,
                  {
                    label: this.props.classConf.title,
                    url: `/species/${this.props.object.taxonomy || 'all'}/${
                      this.props.object.class
                    }`,
                  },
                ]}
              />
            ) : this.props.section === 'resources' ? (
              <Breadcrumb
                trail={[
                  { label: 'Resources', url: '/resources/all' },
                  {
                    label: this.props.classConf.title,
                    url: `/resources/${this.props.object.class}`,
                  },
                ]}
              />
            ) : null}
          </div>
          <div className={this.props.classes.pageTitle}>
            <h2>
              {
                <Breadcrumb
                  trail={[
                    this.props.object,
                    { label: this.props.widgetConf.title },
                  ]}
                />
              }
            </h2>
          </div>
        </div>
        <div className={this.props.classes.pageMain}>
          <Widget
            id={`${this.props.widgetConf.name}-content`}
            className="content"
            style={{ paddingTop: '2em' }}
          />
        </div>
      </div>
    );
  }
}

SingleWidgetPage.propTypes = {
  classes: PropTypes.object.isRequired,
  widgetUrl: PropTypes.string.isRequired,
  section: PropTypes.string,
  classConf: PropTypes.shape({
    title: PropTypes.string.isRequired,
  }),
  widgetConf: PropTypes.shape({
    title: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
  }),
  object: PropTypes.shape({
    class: PropTypes.string.isRequired,
    taxonomy: PropTypes.string,
  }),
  species: PropTypes.shape({
    title: PropTypes.string.isRequired,
  }),
};

SingleWidgetPage.displayName = 'SingleWidgetPage';

const styles = (theme) => ({
  page: {
    position: 'relative',
  },
  pageTitleWrapper: {
    margin: '-1em -2em 0',
    padding: `0.5em 2em`,
    backgroundColor: '#C2D1DF',
  },
  breadcrumbs: {
    fontSize: `0.9em`,
  },
  pageTitle: {
    width: '60%',
  },
  pageMain: {
    width: '100%',
    [theme.breakpoints.up('lg')]: {
      width: '80%',
      marginLeft: '10%',
    },
  },
  spinner: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    minHeight: 300,
  },
});

export default withStyles(styles)(SingleWidgetPage);
