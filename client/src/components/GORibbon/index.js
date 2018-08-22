import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Card, { CardContent } from 'material-ui/Card';
import { tagType } from '../customPropTypes';
import { scaleSequential } from 'd3-scale';
import { interpolateBlues } from 'd3-scale-chromatic';
import { RibbonBase } from '@geneontology/ribbon';
import '../../../node_modules/@geneontology/ribbon/lib/index.css';
import './style.css';

export default class GORibbon extends Component {

  constructor(props) {
    super(props);
    this.state = {
      selectedSlim: null,
    };
  }

  handleSlimEnter = (currentGoId) => {
    this.setState({
      selectedSlimId: currentGoId,
    });
  }

  handleSlimLeave = () => {
    this.setState({
      selectedSlimId: null,
    });
  }

  render() {
    const colorScale = scaleSequential(interpolateBlues).domain([0, 9]);

    const dataWithCounts = this.props.data.map((item) => {
      const annotationCount = item.terms.reduce(
        (count, term) => count + term.annotation_count,
        0
      );
      return {
        ...item,
        count: annotationCount,
      };
    });

    // reformat data as required by RibbonBase
    const slimDataSimple = dataWithCounts.map((item) => {
      return {
        id: item.slim.id,
        label: item.slim.label,
        aspect: item.aspect,
        count: item.count,
        color: colorScale(item.count),
      };
    });

    const [hoverSlimItem] = dataWithCounts.filter((item) => {
      return item.slim.id === this.state.selectedSlimId;
    });
    console.log(this.state.selectedSlimId);
    console.log(hoverSlimItem);

    return (
      <div style={{position: 'relative'}}>
        <RibbonBase
          groups={[
            {
              label: 'Molecular function',
              data: slimDataSimple.filter((slim) => slim.aspect === 'Molecular function'),
            },
            {
              label: 'Biological process',
              data: slimDataSimple.filter((slim) => slim.aspect === 'Biological process'),
            },
            {
              label: 'Cellular component',
              data: slimDataSimple.filter((slim) => slim.aspect === 'Cellular component'),
            },
          ]}
          onSlimSelect={() => null}
          onSlimEnter={this.handleSlimEnter}
          onSlimLeave={this.handleSlimLeave}
          onDomainEnter={() => null}
          onDomainLeave={() => null}
        />
        {
          hoverSlimItem ?  (
            <Card style={{position: 'absolute', top: 0, width: '100%'}}>
              <CardContent>
                <strong><p>{hoverSlimItem.count} associations to <em>"{hoverSlimItem.slim.label}"</em></p></strong>
                <p><strong>Term definition:</strong> {hoverSlimItem.slim.definition}</p>
              </CardContent>
            </Card>
          ) : null
  }
      </div>
    );
  }
}

GORibbon.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      slim: tagType.isRequired,
      aspect: PropTypes.string.isRequired,
      terms: PropTypes.arrayOf(
        PropTypes.shape({
          term: tagType.isRequired,
          annotation_count: PropTypes.number.isRequired,
          aspect: PropTypes.string,
        }),
      ),
    })
  ),
}
