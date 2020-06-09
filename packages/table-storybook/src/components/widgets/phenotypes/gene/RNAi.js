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

  const showData = (title, detail) => {
    switch (title) {
      case 'Affected by molecule':
        if (detail.evidence?.Affected_by_molecule) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence?.Affected_by_molecule[0].label}
            </div>
          )
        }
        break
      case 'Genotype':
        if (detail.evidence?.Genotype) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence?.Genotype}
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
      case 'Strain':
        if (detail.evidence?.Strain) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence.Strain.label}
            </div>
          )
        }
        break
      case 'Penetrance-range':
        if (detail.evidence?.['Penetrance-range']) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence['Penetrance-range']}
            </div>
          )
        }
        break
      case 'paper':
        if (detail.evidence?.paper) {
          return (
            <div>
              <b>{title}: </b>
              {detail.evidence.paper.label}
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
        return (
          <div key={idx} className='rnai'>
            <div>
              <b>RNAi: </b>
              {detail.text.label}
            </div>
            {showData('Affected by molecule', detail)}
            {showData('Genotype', detail)}
            {showData('Remark', detail)}
            {showData('Strain', detail)}
            {showData('Penetrance-range', detail)}
            {showData('paper', detail)}
          </div>
        )
      })}
    </div>
  )
}

export default RNAi
