import React from 'react'

const Evidence = ({ evidences }) => {
  const displayEvidence = (key, value) => {
    switch (key) {
      case 'Description':
        if (Array.isArray(value)) {
          return (
            <>
              <b>Description: </b>
              {value.map((v, idx) =>
                idx === value.length - 1 ? (
                  <span key={idx}>{v}</span>
                ) : (
                  <span key={idx}>{v}; </span>
                )
              )}
            </>
          )
        }
        return (
          <>
            <b>Description: </b>
            {value}
          </>
        )

      case 'Citation':
        return (
          <>
            <b>Citation: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
          </>
        )
      case 'Algorithm':
        return (
          <>
            <b>Algorithm: </b>
            {value}
          </>
        )
      case 'Method_of_isolation':
        return (
          <>
            <b>Method of isolation: </b>
            {value}
          </>
        )
      case 'Type':
        return (
          <>
            <b>Type: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v}</span>
              ) : (
                <span key={idx}>{v}; </span>
              )
            )}
          </>
        )
      case 'Reagents':
        return (
          <>
            <b>Reagents: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
          </>
        )
      case 'Paper':
        return (
          <>
            <b>Paper: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
          </>
        )
      case 'Method of analysis, Microarray':
        return (
          <>
            <b>Method of analysis, Microarray: </b>
            {value.map((v, idx) =>
              idx === value.length - 1 ? (
                <span key={idx}>{v.label}</span>
              ) : (
                <span key={idx}>{v.label}; </span>
              )
            )}
          </>
        )
      case 'Expressed_during':
        return (
          <>
            <b>Expressed during: </b>
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

  return evidences.map((e, idx1) => (
    <ul key={idx1}>
      <li>
        <div>{e.text.label}</div>
        {Object.entries(e.evidence).map(([key, value], idx2) => (
          <div key={idx2}>{displayEvidence(key, value)}</div>
        ))}
      </li>
    </ul>
  ))
}

export default Evidence
