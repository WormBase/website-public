const loadData = async (WBid, tableType, entityType = 'gene') => {
  const proxyUrl = 'https://calm-reaches-60051.herokuapp.com/';

  let targetUrl;

  switch (tableType) {
    case 'blastp_details':
      targetUrl = `http://wormbase.org/rest/field/protein/CE06236/${tableType}`;
      break;

    case 'phenotype_flat':
    case 'phenotype_not_observed_flat':
    case 'drives_overexpression_flat':
      targetUrl = `http://staging.wormbase.org/rest/field/${entityType}/${WBid}/${tableType}`;
      break;

    default:
      targetUrl = `http://wormbase.org/rest/field/${entityType}/${WBid}/${tableType}`;
  }

  const res = await fetch(proxyUrl + targetUrl);
  const json = await res.json();
  const jsonSpecific = await json[`${tableType}`];
  return jsonSpecific;
};

export default loadData;
