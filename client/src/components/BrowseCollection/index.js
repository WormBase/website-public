import React, { useState } from 'react';
import DialogTitle from '@material-ui/core/DialogTitle';
import Dialog from '@material-ui/core/Dialog';
import Button from '../Button';

export default function BrowseCollection({
  collection = [],
  renderItem = ({ label }) => label,
  renderButton = (props) => <Button {...props} />,
  title = 'Browse collection',
}) {
  const [isOpen, setOpen] = useState(false);
  const handleToggle = () => setOpen((prevIsOpen) => !prevIsOpen);
  return (
    <React.Fragment>
      {renderButton({
        variant: 'outlined',
        onClick: handleToggle,
        disabled: !collection.length,
        children: 'Browse collection',
      })}
      <Dialog scroll="paper" open={isOpen} onClose={handleToggle}>
        <DialogTitle>{title}</DialogTitle>
        <ul>
          {collection.map((item) => (
            <li>{renderItem(item)}</li>
          ))}
        </ul>
      </Dialog>
    </React.Fragment>
  );
}
