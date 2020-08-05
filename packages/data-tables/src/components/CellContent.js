import React from 'react';

const listCellContent = (cell) => {
  if (cell.length < 2) {
    return cell.map((c, idx) => <CellContent key={idx} cell={c} />);
  }
  return cell.map((c, idx) => {
    return (
      <ul key={idx}>
        <li>
          <CellContent cell={c} />
        </li>
      </ul>
    );
  });
};

const CellContent = ({ cell }) => {
  // return 'yayyay!!'
  if (Array.isArray(cell)) {
    return listCellContent(cell);
    // return 'yay!'
  }
  if (typeof cell === 'object' && cell !== null) {
    if (cell.species) {
      return (
        <span className="species">
          {cell.genus}. {cell.species}
        </span>
      );
    }
    if (cell.class) {
      if (cell.label) {
        return cell.label; // Should add link like tag2link
      }
    }
    console.log(cell);
    return 'hohoho!';
  }
  return cell;
};

export default CellContent;
