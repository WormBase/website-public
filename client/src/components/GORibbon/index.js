import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { tagType } from '../customPropTypes';
import { RibbonBase } from '@geneontology/ribbon';
import '../../../node_modules/@geneontology/ribbon/lib/index.css';
import './style.css';

export default class GORibbon extends Component {
  render() {

    const slimDataSimple = this.props.data.map((slimData) => {
      const slimCount = slimData.terms.reduce(
        (count, term) => count + term.annotation_count,
        0
      );
      return {
        id: slimData.slim.id,
        label: slimData.slim.label,
        aspect: slimData.aspect,
        count: slimCount,
        color: slimCount ? 'grey' : 'white',
      }
    });

    return (
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
        onDomainEnter={() => null}
        onDomainLeave={() => null}
      />
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
