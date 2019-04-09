import React from 'react';
import PropTypes from 'prop-types';
import SequenceCard from './SequenceCard';

const TranscriptSequenceCard = (props) => {
  const {
    wbId,
    proteinSequence,
  } = props;
  return (
    <div>
      <SequenceCard
        title={`Conceptual translation ${proteinSequence.sequence.length}aa`}
        downloadFileName={`conceptual_translation_${wbId}.fasta`}
        sequence={proteinSequence.sequence}
        />
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
