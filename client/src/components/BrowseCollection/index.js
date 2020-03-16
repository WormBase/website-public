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
import SaveIcon from '@material-ui/icons/SaveAlt';
import Link from '../Link';

export default function BrowseCollection({
  collection = [],
  renderItem = (props) => <Link {...props} />,
  renderButton = (props) => <Button {...props} />,
  title = 'Browse collection',
  type = 'gene',
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

  // const toWormMine = useCallback(() => {
  //   // modiied from code from SGD https://github.com/yeastgenome/SGDFrontend
  //   function post_to_wormmine(bioent_ids) {
  //     // The rest of this code assumes you are not using a library.
  //     // It can be made less wordy if you use one.
  //     const form = document.createElement('form');
  //     form.setAttribute('method', 'post');
  //     form.setAttribute('target', '_blank');
  //     form.setAttribute(
  //       'action',
  //       'http://intermine.wormbase.org/tools/wormmine/buildBag.do'
  //     );

  //     const cinp = document.createElement('input');
  //     cinp.setAttribute('type', 'hidden');
  //     cinp.setAttribute('name', 'type');
  //     cinp.setAttribute('value', 'Gene');
  //     form.appendChild(cinp);

  //     const vinp = document.createElement('input');
  //     vinp.setAttribute('type', 'hidden');
  //     vinp.setAttribute('name', 'extraFieldValue');
  //     vinp.setAttribute('value', 'C. elegans');
  //     form.appendChild(vinp);

  //     const hiddenField = document.createElement('input');
  //     hiddenField.setAttribute('type', 'hidden');
  //     hiddenField.setAttribute('name', 'text');
  //     hiddenField.setAttribute('value', bioent_ids);
  //     hiddenField.id = 'data';
  //     form.appendChild(hiddenField);

  //     document.body.appendChild(form);
  //     form.submit();
  //   }
  //   post_to_wormmine(collection.map(({ id }) => id));
  // }, [collection]);

  const toSimpleMine = useCallback(() => {
    // modiied from code from SGD https://github.com/yeastgenome/SGDFrontend
    function post(geneIds) {
      // The rest of this code assumes you are not using a library.
      // It can be made less wordy if you use one.
      const form = document.createElement('form');
      form.setAttribute('method', 'post');
      form.setAttribute(
        'action',
        'https://wormbase.org/tools/mine/simplemine.cgi'
      );
      form.setAttribute('target', '_blank');
      form.setAttribute('enctype', 'multipart/form-data');

      const geneListInput = document.createElement('textarea');
      geneListInput.setAttribute('type', 'hidden');
      geneListInput.setAttribute('name', 'geneInput');
      geneListInput.value = geneIds.join(' ');
      form.appendChild(geneListInput);

      const columnHeaders = [
        'WormBase Gene ID',
        'Public Name',
        'WormBase Status',
        'Sequence Name',
        'Other Name',
        'Transcript',
        'Operon',
        'WormPep',
        'Protein Domain',
        'Uniprot',
        'Reference Uniprot ID',
        'TreeFam',
        'RefSeq_mRNA',
        'RefSeq_protein',
        'Genetic Map Position',
        'RNAi Phenotype Observed',
        'Allele Phenotype Observed',
        'Sequenced Allele',
        'Interacting Gene',
        'Expr_pattern Tissue',
        'Genomic Study Tissue',
        'Expr_pattern LifeStage',
        'Genomic Study LifeStage',
        'Disease Info',
        'Human Ortholog',
        'Reference',
        'Concise Description',
        'Automated Description',
        'Expression Cluster Summary',
      ];

      const options = [
        { name: 'outputFormat', value: 'html' },
        { name: 'duplicatesToggle', value: 'merge' },
        { name: 'headers', value: columnHeaders.join('\t') },
      ].concat(
        columnHeaders.map((name) => ({
          name,
        }))
      );

      options.forEach(({ name, value, checked = 'checked' }) => {
        const optionInput = document.createElement('input');
        optionInput.setAttribute('type', 'checkbox');
        optionInput.setAttribute('name', name);
        optionInput.setAttribute('value', value || name);
        optionInput.setAttribute('checked', checked);
        form.appendChild(optionInput);
      });

      const submitInput = document.createElement('input');
      submitInput.setAttribute('name', 'action');
      submitInput.setAttribute('type', 'submit');
      submitInput.setAttribute('value', 'query list');
      form.appendChild(submitInput);

      document.body.appendChild(form);
      submitInput.click();
    }
    post(collection.map(({ id }) => id));
  }, [collection]);

  const toEnrichmentAnalysisTool = useCallback(() => {
    // modiied from code from SGD https://github.com/yeastgenome/SGDFrontend
    function post(geneIds) {
      // The rest of this code assumes you are not using a library.
      // It can be made less wordy if you use one.
      const form = document.createElement('form');
      form.setAttribute('method', 'post');
      form.setAttribute(
        'action',
        'https://wormbase.org/tools/enrichment/tea/tea.cgi'
      );
      form.setAttribute('target', '_blank');
      form.setAttribute('enctype', 'multipart/form-data');

      const geneListInput = document.createElement('textarea');
      geneListInput.setAttribute('type', 'hidden');
      geneListInput.setAttribute('name', 'genelist');
      geneListInput.value = geneIds.join(' ');
      form.appendChild(geneListInput);

      const qvalueThresholdInput = document.createElement('input');
      qvalueThresholdInput.setAttribute('type', 'hidden');
      qvalueThresholdInput.setAttribute('name', 'qvalueThreshold');
      qvalueThresholdInput.setAttribute('value', '0.1');
      qvalueThresholdInput.id = 'qvalueThreshold';
      form.appendChild(qvalueThresholdInput);

      const submitInput = document.createElement('input');
      submitInput.setAttribute('name', 'action');
      submitInput.setAttribute('type', 'submit');
      submitInput.setAttribute('value', 'Analyze List');
      form.appendChild(submitInput);

      document.body.appendChild(form);
      submitInput.click();
    }
    post(collection.map(({ id }) => id));
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
          <DialogActions>
            <CopyButton textFunc={toTSV} />
            <DownloadButton contentFunc={toCSV} fileName={`${title}.csv`}>
              CSV <SaveIcon />
            </DownloadButton>
            <DownloadButton contentFunc={toTSV} fileName={`${title}.txt`}>
              TSV <SaveIcon />
            </DownloadButton>
            {type === 'gene' ? (
              <Button onClick={toSimpleMine}>
                SimpleMine <LaunchIcon />
              </Button>
            ) : null}
            {type === 'gene' && collection.length > 1 ? (
              <Button onClick={toEnrichmentAnalysisTool}>
                Enrichment Analysis <LaunchIcon />
              </Button>
            ) : null}
            {/* <Button onClick={toWormMine}> */}
            {/*   WormMine <LaunchIcon /> */}
            {/* </Button> */}
          </DialogActions>
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
        </DialogActions>
      </Dialog>
    </React.Fragment>
  );
}
