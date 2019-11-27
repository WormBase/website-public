import React, { useState, useCallback } from 'react';
import DialogTitle from '@material-ui/core/DialogTitle';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import Divider from '@material-ui/core/Divider';
import LaunchIcon from '@material-ui/icons/Launch';
import Button from '../Button';
import CopyButton from '../CopyButton';
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

  const toTSV = useCallback(
    () => collection.map(({ id, label }) => `${label}\t${id}`).join('\n'),
    [collection]
  );

  const toCSV = useCallback(
    () => collection.map(({ id, label }) => `${label},${id}`).join('\n'),
    [collection]
  );

  const toWormMine = useCallback(() => {
    // modiied from code from SGD https://github.com/yeastgenome/SGDFrontend
    function post_to_wormmine(bioent_ids) {
      // The rest of this code assumes you are not using a library.
      // It can be made less wordy if you use one.
      const form = document.createElement('form');
      form.setAttribute('method', 'post');
      form.setAttribute(
        'action',
        'http://intermine.wormbase.org/tools/wormmine/buildBag.do'
      );

      const cinp = document.createElement('input');
      cinp.setAttribute('type', 'hidden');
      cinp.setAttribute('name', 'type');
      cinp.setAttribute('value', 'Gene');
      form.appendChild(cinp);

      const vinp = document.createElement('input');
      vinp.setAttribute('type', 'hidden');
      vinp.setAttribute('name', 'extraFieldValue');
      vinp.setAttribute('value', 'C. elegans');
      form.appendChild(vinp);

      const hiddenField = document.createElement('input');
      hiddenField.setAttribute('type', 'hidden');
      hiddenField.setAttribute('name', 'text');
      hiddenField.setAttribute('value', bioent_ids);
      hiddenField.id = 'data';
      form.appendChild(hiddenField);

      document.body.appendChild(form);
      form.submit();
    }
    post_to_wormmine(collection.map(({ id }) => id));
  }, [collection]);

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
        <Divider />
        <DialogContent>
          <DialogContentText>
            <ul>
              {collection.map((item) => (
                <li key={item.id}>{renderItem(item)}</li>
              ))}
            </ul>
          </DialogContentText>
        </DialogContent>
        <Divider />
        <DialogActions>
          <Button variant="text" onClick={handleToggle}>
            Cancel
          </Button>
          <CopyButton textFunc={toTSV} />
          <DownloadButton contentFunc={toCSV} fileName={`${title}.csv`}>
            CSV
          </DownloadButton>
          <DownloadButton contentFunc={toTSV} fileName={`${title}.txt`}>
            TSV
          </DownloadButton>
          <Button onClick={toWormMine}>
            WormMine <LaunchIcon />
          </Button>
        </DialogActions>
      </Dialog>
    </React.Fragment>
  );
}
