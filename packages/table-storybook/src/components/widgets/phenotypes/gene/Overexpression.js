import React from 'react'
import { makeStyles } from '@material-ui/core/styles'

const Overexpression = ({ values }) => {
  const useStyles = makeStyles({
    cell: {
      '& .overexpression:not(:last-child)': {
        marginBottom: '20px',
      },
    },
  })

  const classes = useStyles()

  const displayEvidence = (key, value) => {
    switch (key) {
      case 'Affected_by_molecule':
        return (
          <>
            <b>Affected by molecule: </b>
            {value[0].label}
          </>
        )
      case 'Caused_by_gene':
        return (
          <>
            <b>Caused by gene: </b>
            {value[0].label}
          </>
        )
      case 'Curator':
        return (
          <>
            <b>Curator: </b>
            {value[0].label}
          </>
        )
      case 'Paper_evidence':
        return (
          <>
            <b>Paper evidence: </b>
            {value[0].label}
          </>
        )
      case 'Remark':
        return (
          <>
            <b>Remark: </b>
            {value[0]}
          </>
        )
      case 'Temperature':
        return (
          <>
            <b>Temperature: </b>
            {value[0]}
          </>
        )
      case 'Treatment':
        return (
          <>
            <b>Treatment: </b>
            {value}
          </>
        )
      case 'Variation_effect':
        return (
          <>
            <b>Variation effect: </b>
            {value.map((v, idx) => (
              <span key={idx}>{v.label}; </span>
            ))}
          </>
        )
      default:
        console.error(key)
        console.error(value)
        return null
    }
  }

  return (
    <div className={classes.cell}>
      {values.map((detail, idx1) => (
        <div key={idx1} className='overexpression'>
          <div>{detail.text.label}</div>
          {Object.entries(detail.evidence).map(([key, value], idx2) => (
            <div key={idx2}>{displayEvidence(key, value)}</div>
          ))}
        </div>
      ))}
    </div>
  )
}

export default Overexpression
