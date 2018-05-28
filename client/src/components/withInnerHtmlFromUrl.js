import React from 'react';
import { CircularProgress } from './Progress';


export default function withInnerHtmlFromUrl(WrappedComponent, url, spinnerElement) {
  class WithInnerHtml extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        html: null,
      };
    }

    componentDidMount() {
      fetch(url).then((response) => {
        return response.text();
      }).then((htmlRaw) => {
        const re = /<script.*?>((.|\n|\r)+?)<\/script>/gi;
        const scripts = [];
        const html = htmlRaw;
        var match = re.exec(html);

        while (match) {
          scripts.push(match[1]);
          match = re.exec(html);
        }

        this.setState({
          html: html,
        }, () => {
          scripts.forEach((script) => {
            window.eval(script);
          });
        });
      });
    }

    render() {
      return (
        this.state.html ?
        <WrappedComponent
          dangerouslySetInnerHTML={{__html: this.state.html}}
          {...this.props} /> :
        spinnerElement
      );
    }
  }


  return WithInnerHtml;
};