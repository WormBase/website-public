import React from 'react'

const Entity = ({ eObj }) => {
  return (
    <div>
      {Object.values(eObj)[0].map((e, idx) => {
        return (
          <div key={idx}>
            <b>{e.pato_evidence.entity_type}: </b>
            <span>{e.pato_evidence.entity_term.label}, </span>
            <span>{e.pato_evidence.pato_term}</span>
          </div>
        )
      })}
    </div>
  )
}

export default Entity
