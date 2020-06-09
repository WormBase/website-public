import React from 'react'

const Entity = ({ values }) => {
  return (
    <div>
      {values.map((detail, idx) => {
        return (
          <div key={idx}>
            <b>{detail.pato_evidence.entity_type}: </b>
            <span>{detail.pato_evidence.entity_term.label}, </span>
            <span>{detail.pato_evidence.pato_term}</span>
          </div>
        )
      })}
    </div>
  )
}

export default Entity
