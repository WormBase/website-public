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
    },
  })

  const classes = useStyles()

  const showData = (title, detail) => {
    switch (title) {
      case 'Curator':
        return (
          <div>
            <b>{title}: </b>
            {detail.evidence.Curator[0].label}
          </div>
        )
      case 'Paper evidence':
        if (detail.evidence?.Paper_evidence) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence?.Paper_evidence[0].label}
            </div>
          )
        }
        break
      case 'Remark':
        if (detail.evidence?.Remark) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence.Remark[0]}
            </div>
          )
        }
        break
      case 'Temperature sensitive':
        if (detail.evidence?.Temperature_sensitive) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence.Temperature_sensitive.label}
            </div>
          )
        }
        break
      case 'Temperature':
        if (detail.evidence?.Temperature) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence.Temperature}
            </div>
          )
        }
        break
      case 'Variation effect':
        if (detail.evidence?.Variation_effect) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence.Variation_effect[0].label}
            </div>
          )
        }
        break
      case 'Person evidence':
        if (detail.evidence?.Person_evidence) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence.Person_evidence[0].label}
            </div>
          )
        }
        break
      case 'Ease of scoring':
        if (detail.evidence?.Ease_of_scoring) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence.Ease_of_scoring.label}
            </div>
          )
        }
        break
      default:
        return ''
    }
  }
  return (
    <div className={classes.cell}>
      {values.map((detail, idx) => {
        console.log(detail)
        return (
          <div key={idx} className='allele'>
            <div>
              <b>Allele: </b>
              {detail.text.label}
            </div>
            {showData('Curator', detail)}
            {showData('Paper evidence', detail)}
            {showData('Remark', detail)}
            {showData('Temperature sensitive', detail)}
            {showData('Temperature', detail)}
            {showData('Variation effect', detail)}
            {showData('Person evidence', detail)}
            {showData('Ease of scoring', detail)}
          </div>
        )
      })}
    </div>
  )
}

export default Allele
