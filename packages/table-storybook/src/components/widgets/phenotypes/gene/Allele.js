import React from 'react'
import { makeStyles } from '@material-ui/core/styles'

const Allele = ({ values }) => {
  const useStyles = makeStyles({
    cell: {
      '& .allele:not(:last-child)': {
        marginBottom: '20px',
      },
      '& .allele div:not(:first-child)': {
        paddingLeft: '50px',
      },
      '& .allele .bold': {
        fontWeight: 'bold',
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
            {value[0].label}
          </>
        )
      case 'Person_evidence':
        return (
          <>
            <b>Person evidence: </b>
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
            {value[0].label}
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
      default:
        console.error(key)
        console.error(value)
        return null
    }
  }

  return (
    <div className={classes.cell}>
      {values.map((detail, idx1) => (
        <div key={idx1} className='allele'>
          <div>
            <b>Allele: </b>
            <i className={detail.text.style !== 0 ? 'bold' : ''}>
              {detail.text.label}
            </i>
          </div>
          {Object.entries(detail.evidence).map(([key, value], idx2) => (
            <div key={idx2}>{displayAllele(key, value)}</div>
          ))}
        </div>
      ))}
    </div>
  )
}

export default Allele
