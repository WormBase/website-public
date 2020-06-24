import React from 'react'
import { makeStyles } from '@material-ui/core/styles'

const RNAi = ({ values }) => {
  const useStyles = makeStyles({
    cell: {
      '& .rnai:not(:last-child)': {
        marginBottom: '20px',
      },
      '& .rnai div:not(:first-child)': {
        paddingLeft: '50px',
      },
    },
  })

  const classes = useStyles()

  const displayRNAi = (key, value) => {
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
      case 'Genotype':
        return (
          <>
            <b>Genotype: </b>
            {value}
          </>
        )
      case 'paper':
        return (
          <>
            <b>paper: </b>
            {value.label}
          </>
        )
      case 'Penetrance-range':
        return (
          <>
            <b>Penetrance-range: </b>
            {value}
          </>
        )
      case 'Quantity_description':
        return null
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
      case 'Strain':
        return (
          <>
            <b>Strain: </b>
            {value.label}
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
      {values.map((detail, idx) => (
        <div key={idx} className='rnai'>
          <div>
            <b>RNAi: </b>
            {detail.text.label}
          </div>
          {Object.entries(detail.evidence).map(([key, value], idx2) => (
            <div key={idx2}>{displayRNAi(key, value)}</div>
          ))}
        </div>
      ))}
    </div>
  )
}

export default RNAi
