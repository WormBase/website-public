import React, { useState } from 'react';
import PropTypes from 'prop-types';
import SequenceCard from './SequenceCard';
import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';

function resolveStrand(sequenceContext = {}) {
  const strandName = {
    '-': 'negative',
    '+': 'positive',
  };
  if (sequenceContext.sequence_strand) {
    return sequenceContext[`${strandName[sequenceContext.sequence_strand]}-strand`];
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

const TranscriptSequenceCard = (props) => {
  const {
    wbId,
    proteinSequence,
    cdsSequence: cdsSequenceRaw,
    splicedSequenceContext: splicedSequenceContextRaw,
    unsplicedSequenceContext: unsplicedSequenceContextRaw,
  } = props;

  const [sequenceKeySelected, setSequenceKeySelected] = useState('hidden');

  const sequenceOptions = [];

  if (splicedSequenceContextRaw) {
    const data = resolveStrand(splicedSequenceContextRaw);
    sequenceOptions.push({
      ...data,
      key: 'spliced',
      label: `Spliced (${data.sequence.length}bp)`,
    });
  }

  if (unsplicedSequenceContextRaw) {
    const data = resolveStrand(unsplicedSequenceContextRaw);
    sequenceOptions.push({
      ...data,
      key: 'unspliced',
      label: `Unspliced (${data.sequence.length}bp)`,
    });
  }

  if (cdsSequenceRaw) {
    const data = resolveStrand(cdsSequenceRaw);
    sequenceOptions.push({
      ...data,
      key: 'cds',
      label: `Coding sequence (${data.sequence.length}bp)`,
    });
  }

  if (sequenceOptions.length > 0) {
    sequenceOptions.unshift({
      key: 'hidden',
      label: 'Hide sequence',
    });
  }

  const sequenceSelected = sequenceOptions.filter(({key}) => (key === sequenceKeySelected))[0];

  return (
    <div>
      <RadioGroup
        aria-label="select sequence"
        name="select-sequence"
        row
        value={sequenceKeySelected}
        onChange={(event) => setSequenceKeySelected(event.target.value)}
      >
        {
          sequenceOptions.map(({key, label}) => (
            <FormControlLabel value={key} control={<Radio />} label={label} />
          ))
        }
      </RadioGroup>
      {
        sequenceKeySelected === 'hidden' ? null : (
          <SequenceCard
            title={`Spliced ${sequenceSelected.sequence.length}aa`}
            downloadFileName={`${sequenceKeySelected}TranscriptSequence_${wbId}.fasta`}
            sequence={sequenceSelected.sequence}
            features={rewriteFeatures(sequenceSelected.features)}
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
