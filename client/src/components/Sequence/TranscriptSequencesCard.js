import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import SequenceCard from './SequenceCard';
import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';

function resolveStrand(sequenceContext = {}) {
  const strandName = {
    '-': 'negative',
    '+': 'positive',
  };
  if (sequenceContext.strand) {
    return sequenceContext[`${strandName[sequenceContext.strand]}_strand`];
  }
  return null;
}

function rewriteFeatures(features = []) {
  let exonCount = 0;
  return [...features]
    .sort((a, b) => {
      return a.start - b.start;
    })
    .reduce((result, feature) => {
      if (feature.type === 'exon') {
        // put exons in the beginning of the array
        result.unshift({
          ...feature,
          type: `exon_${exonCount % 2}`,
        });
        exonCount++;
      } else if (
        feature.type === 'three_prime_UTR' ||
        feature.type === 'five_prime_UTR'
      ) {
        // ensure UTR is inserted after exons
        result.push({
          ...feature,
          type: `UTR`,
        });
      } else {
        result.push(feature);
      }
      return result;
    }, []);
}

const TranscriptSequenceCard = (props) => {
  const {
    classes,
    wbId,
    proteinSequence,
    cdsSequence: cdsSequenceRaw,
    sequenceContext: sequenceContextRaw,
    splicedSequenceContext: splicedSequenceContextRaw,
    unsplicedSequenceContext: unsplicedSequenceContextRaw,
    unsplicedSequenceContextWithPadding: unsplicedSequenceContextWithPaddingRaw,
  } = props;

  const [sequenceKeySelected, setSequenceKeySelected] = useState('hidden');

  const sequenceOptions = [];

  if (splicedSequenceContextRaw) {
    const data = resolveStrand(splicedSequenceContextRaw);
    sequenceOptions.push({
      ...data,
      key: 'spliced+UTR',
      label: `Spliced + UTR (${data.sequence.length}bp)`,
    });
  }

  if (unsplicedSequenceContextRaw) {
    const data = resolveStrand(unsplicedSequenceContextRaw);
    sequenceOptions.push({
      ...data,
      key: 'unspliced+UTR',
      label: `Unspliced + UTR (${data.sequence.length}bp)`,
    });
  }

  if (unsplicedSequenceContextWithPaddingRaw) {
    const data = resolveStrand(unsplicedSequenceContextWithPaddingRaw);
    sequenceOptions.push({
      ...data,
      key: 'unspliced+UTR+upstream+downstream',
      label: `Unspliced + UTR + upstream + downstream (${
        data.sequence.length
      }bp)`,
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

  if (sequenceContextRaw) {
    const data = resolveStrand(sequenceContextRaw);
    sequenceOptions.push({
      ...data,
      key: 'sequence',
      label: `Sequence (${data.sequence.length}bp)`,
    });
  }

  const sequenceSelected = sequenceOptions.filter(
    ({ key }) => key === sequenceKeySelected
  )[0];

  return (
    <div>
      {sequenceOptions.map(({ key, label, ...data }) => (
        <SequenceCard
          key={key}
          className={classes.card}
          title={label}
          downloadFileName={`${key}TranscriptSequence_${wbId}.fasta`}
          sequence={data.sequence}
          initialExpand={false}
          features={rewriteFeatures(data.features)}
          featureLabelMap={{
            exon_0: 'Exon',
            exon_1: 'Exon',
            intron: 'Intron',
            padding: 'Upstream / downstream',
          }}
        />
      ))}
      {proteinSequence ? (
        <SequenceCard
          className={classes.card}
          title={`Conceptual translation ${proteinSequence.sequence.length}aa`}
          downloadFileName={`conceptual_translation_${wbId}.fasta`}
          sequence={proteinSequence.sequence}
        />
      ) : null}
    </div>
  );
};

const SequencePropType = PropTypes.shape({
  features: PropTypes.any,
  sequence: PropTypes.any,
});

const SequenceContextPropTypes = PropTypes.shape({
  positive_strand: SequencePropType,
  negative_strand: SequencePropType,
  strand: PropTypes.string,
});

TranscriptSequenceCard.propTypes = {
  classes: PropTypes.object.isRequired,
  splicedSequenceContext: SequenceContextPropTypes,
  unsplicedSequenceContext: SequenceContextPropTypes,
  unsplicedSequenceContextWithPadding: SequenceContextPropTypes,
  proteinSequence: SequencePropType,
  wbId: PropTypes.string.isRequired,
};

const styles = (theme) => ({
  card: {
    borderLeft: `1px solid ${theme.palette.text.hint}`,
    borderRadius: 0,
    padding: 0,
    marginBottom: theme.spacing.unit * 2,
  },
});

export default withStyles(styles)(TranscriptSequenceCard);
