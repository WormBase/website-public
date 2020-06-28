import React from 'react'
import { makeStyles } from '@material-ui/core/styles'

const Overexpression = ({ oObj }) => {
  const useStyles = makeStyles({
    cell: {
      '& .overexpression:not(:last-child)': {
        marginBottom: '20px',
      },
    },
  })

  const classes = useStyles()

  const displayEvidence = (key, value) => {
    console.log(key, value)
    switch (key) {
      case 'Affected_by_molecule':
        return (
          <>
            <b>Affected by molecule: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
          </>
        )
      case 'Caused_by_gene':
        return (
          <>
            <b>Caused by gene: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
          </>
        )
      case 'Curator':
        return (
          <>
            <b>Curator: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
          </>
        )
      case 'Paper_evidence':
        return (
          <>
            <b>Paper evidence: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
          </>
        )
      case 'Remark':
        return (
          <>
            <b>Remark: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v}</span>
              ) : (
                <span key={idx}>{v}; </span>
              )
            )}
          </>
        )
      case 'Temperature':
        return (
          <>
            <b>Temperature: </b>
            {value}
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
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
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
      <div>{oObj.text.label}</div>
      {Object.entries(oObj.evidence).map(([key, value], idx) => (
        <div key={idx}>{displayEvidence(key, value)}</div>
      ))}
    </div>
  )
}

export default Overexpression
