import React from 'react'
import { makeStyles } from '@material-ui/core/styles'

const Allele = ({ aObj }) => {
  const useStyles = makeStyles({
    cell: {
      '& div:not(:first-child)': {
        paddingLeft: 50,
      },
    },
  })

  const classes = useStyles()

  const displayAllele = (key, value) => {
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
      case 'Ease_of_scoring':
        return (
          <>
            <b>Ease of scoring: </b>
            {value.label}
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
      case 'Person_evidence':
        return (
          <>
            <b>Person evidence: </b>
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
      case 'Temperature_sensitive':
        return (
          <>
            <b>Temperature sensitive: </b>
            {value.label}
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
      case 'Recessive':
        return (
          <>
            <b>Recessive: </b>
            {value}
          </>
        )
      case 'Penetrance':
        return (
          <>
            <b>Penetrance: </b>
            {value}
          </>
        )
      case 'Penetrance-range':
        return (
          <>
            <b>Penetrance-range: </b>
            {value}
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
      <div>
        <b>Allele: </b>
        {aObj.text.label}
      </div>
      {Object.entries(aObj.evidence).map(([key, value], idx) => (
        <div key={idx}>{displayAllele(key, value)}</div>
      ))}
    </div>
  )
}

export default Allele
