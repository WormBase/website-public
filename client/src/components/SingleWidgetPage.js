import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import withInnerHtmlFromUrl from './withInnerHtmlFromUrl';
import Breadcrumb from './Breadcrumb';

class SingleWidgetPage extends React.Component {
  render() {
    const Widget = withInnerHtmlFromUrl('div', this.props.widgetUrl);
    return (
      <div>
        <div id="page-title-wrapper" className={`${this.props.section}-bg`}>
          <div id="page-title">
            {
              this.props.section === 'species' ?
              <Breadcrumb trail={[
                {label: 'Species', url: '/species/all'},
                this.props.object.taxonomy ? {label: this.props.species.title, url: `/species/${this.props.object.taxonomy}`} : null,
                {label: this.props.classConf.title, url: `/species/${this.props.object.taxonomy || 'all'}/${this.props.object.class}`},
              ]} /> :
              this.props.section === 'resources' ?
              <Breadcrumb trail={[
                {label: 'Resources', url: '/resources/all'},
                {label: this.props.classConf.title, url: `/resources/${this.props.object.class}`},
              ]} /> :
              null
            }
                <h2>
                  {
                    <Breadcrumb trail={[
                      this.props.object,
                      {label: this.props.widgetConf.title},
                    ]} />
                  }
                </h2>
          </div>
      </div>
      <Widget id={`${this.props.widgetConf.name}-content`} className="content" style={{position: "relative", paddingTop: '2em',}} />
      </div>
    );
  }
}

SingleWidgetPage.propTypes = {
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
    "class": PropTypes.string.isRequired,
    taxonomy: PropTypes.string,
  }),
  species: PropTypes.shape({
    title: PropTypes.string.isRequired,
  }),
};

const styles = (theme) => ({
  pageTitleWrapper: {

  },
  pageTitle: {
  },
});

export default SingleWidgetPage;