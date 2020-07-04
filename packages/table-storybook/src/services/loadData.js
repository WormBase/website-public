const loadData = async (WBid, tableType) => {
  const proxyUrl = 'https://calm-reaches-60051.herokuapp.com/'
  const targetUrl = `http://rest.wormbase.org/rest/field/gene/${WBid}/${tableType}`
  const res = await fetch(proxyUrl + targetUrl)
  const json = await res.json()
  const jsonSpecific = await json[`${tableType}`]
  return jsonSpecific
}

export default loadData
