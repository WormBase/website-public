import React from 'react';
import PropTypes from 'prop-types';
import SequenceCard from './SequenceCard';

function resolveStrand(sequenceContext = {}) {
  if (sequenceContext.sequence_strand) {
    return sequenceContext[`${sequenceContext.sequence_strand}-strand`];
  } else {
    return null;
  };
}

function TranscriptSequenceCard(props) {
  const {
    wbId,
    proteinSequence,
    splicedSequenceContext: splicedSequenceContextRaw,
    unsplicedSequenceContext: unsplicedSequenceContextRaw,
  } = props;
  const splicedSequenceContext = resolveStrand(splicedSequenceContextRaw);
  const unsplicedSequenceContext = resolveStrand(unsplicedSequenceContextRaw);
  return (
    <div>
      <SequenceCard
        title={`Spliced ${splicedSequenceContext.sequence.length}aa`}
        downloadFileName={`conceptual_translation_${wbId}.fasta`}
        sequence={splicedSequenceContext.sequence}
        features={[]}
      />
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
