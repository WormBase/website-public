const loadData = async (targetUrl) => {
  const proxyUrl = 'https://calm-reaches-60051.herokuapp.com/'
  const res = await fetch(proxyUrl + targetUrl)
  const json = await res.json()
  return json
}

export default loadData
