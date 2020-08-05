import React from 'react'
import PropTypes from 'prop-types'
import { hasContent } from '../util/hasContent'
//import SimpleCell from './SimpleCell';

const HashCell = ({ data, render }) => {
  return (
    <ul>
      {Object.keys(data)
        .filter((key) => hasContent(data[key]))
        .map((key) => (
          <li key={key}>
            {key.replace(/_+/g, ' ')}:
            <br />
            {render({ elementValue: data[key] })}
          </li>
        ))}
    </ul>
  )
}

HashCell.propTypes = {
  data: PropTypes.object,
  render: PropTypes.func.isRequired,
}

export default HashCell
