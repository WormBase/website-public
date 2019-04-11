import React, { useState } from 'react';
import PropTypes from 'prop-types';
import SequenceCard from './SequenceCard';
import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';

function resolveStrand(sequenceContext = {}) {
  if (sequenceContext.sequence_strand) {
    return sequenceContext[`${sequenceContext.sequence_strand}-strand`];
  }
  return null;
}

function rewriteFeatures(features = []) {
  let exonCount = 0;
  return features.reduce((result, feature) => {
    if (feature.type === 'exon') {
      // put exons in the beginning of the array
      result.unshift({
        ...feature,
        type: `exon_${exonCount % 2}`
      });
      exonCount++;
    } else if (feature.type === 'three_prime_UTR' || feature.type === 'five_prime_UTR') {
      // ensure UTR is inserted after exons
      result.push({
        ...feature,
        type: `UTR`
      });
    } else {
      result.push(feature);
    }
    return result;
  }, []);
}

function TranscriptSequenceCard(props) {
  const {
    wbId,
    proteinSequence,
    splicedSequenceContext: splicedSequenceContextRaw,
    unsplicedSequenceContext: unsplicedSequenceContextRaw,
  } = props;
  const sequenceOptions = {
    spliced: resolveStrand(splicedSequenceContextRaw),
    unspliced: resolveStrand(unsplicedSequenceContextRaw)
  };

  const [sequenceSelected, setSequenceSelected] = useState('hidden');

  return (
    <div>
      <RadioGroup
        aria-label="select sequence"
        name="select-sequence"
        row
        value={sequenceSelected}
        onChange={(event) => setSequenceSelected(event.target.value)}
      >
        <FormControlLabel value="hidden" control={<Radio />} label="Hide transcript sequence" />
        <FormControlLabel value="spliced" control={<Radio />} label={`Spliced (${sequenceOptions.spliced.sequence.length}bp)`} />
        <FormControlLabel value="unspliced" control={<Radio />} label={`Unspliced (${sequenceOptions.unspliced.sequence.length}bp)`} />
      </RadioGroup>
      {
        sequenceSelected === 'hidden' ? null : (
          <SequenceCard
            title={`Spliced ${sequenceOptions[sequenceSelected].sequence.length}aa`}
            downloadFileName={`${sequenceSelected}TranscriptSequence_${wbId}.fasta`}
            sequence={sequenceOptions[sequenceSelected].sequence}
            features={rewriteFeatures(sequenceOptions[sequenceSelected].features)}
            featureLabelMap={{
              exon_0: 'Exon',
              exon_1: 'Exon',
            }}
          />
        )
      }
      {
        proteinSequence ?
          <SequenceCard
            title={`Conceptual translation ${proteinSequence.sequence.length}aa`}
            downloadFileName={`conceptual_translation_${wbId}.fasta`}
            sequence={proteinSequence.sequence}
          /> : null
      }

    </div>
  );
};

const SequencePropType = PropTypes.shape({
  features: PropTypes.any,
  sequence: PropTypes.any,
});

const SequenceContextPropTypes = PropTypes.shape({
  "positive-strand": SequencePropType,
  "negative-strand": SequencePropType,
  "sequence_strand": PropTypes.string,
});

TranscriptSequenceCard.propTypes = {
  splicedSequenceContext: SequenceContextPropTypes,
  unsplicedSequenceContext: SequenceContextPropTypes,
  proteinSequence: SequencePropType,
  wbId: PropTypes.string.isRequired,
};

export default TranscriptSequenceCard;
