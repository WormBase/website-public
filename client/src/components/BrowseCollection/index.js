import React, { useState, useCallback } from 'react';
import DialogTitle from '@material-ui/core/DialogTitle';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import Button from '../Button';
import DownloadButton from '../DownloadButton';
import Link from '../Link';

export default function BrowseCollection({
  collection = [],
  renderItem = (props) => <Link {...props} />,
  renderButton = (props) => <Button {...props} />,
  title = 'Browse collection',
}) {
  const [isOpen, setOpen] = useState(false);
  const handleToggle = () => setOpen((prevIsOpen) => !prevIsOpen);
  const toText = useCallback(
    () => collection.map(({ id, label }) => `${label}\t${id}`).join('\n'),
    [collection]
  );
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
        <div>
          <DownloadButton contentFunc={toText} />
          <Button variant={'outlined'}>Analyze</Button>
        </div>
        <DialogContent>
          <ul>
            {collection.map((item) => (
              <li key={item.id}>{renderItem(item)}</li>
            ))}
          </ul>
        </DialogContent>
      </Dialog>
    </React.Fragment>
  );
}
