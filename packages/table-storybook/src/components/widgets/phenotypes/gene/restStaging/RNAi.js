import React from 'react'
import { makeStyles } from '@material-ui/core/styles'

const RNAi = ({ rObj }) => {
  const useStyles = makeStyles({
    cell: {
      '& div:not(:first-child)': {
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
            {value[0].label}
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
      case 'Paper_evidence':
        return (
          <>
            <b>Paper evidence: </b>
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
            {value[0]}
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
      <div>
        <b>RNAi: </b>
        {rObj.text.label}
      </div>
      {Object.entries(rObj.evidence).map(([key, value], idx) => (
        <div key={idx}>{displayRNAi(key, value)}</div>
      ))}
    </div>
  )
}

export default RNAi
