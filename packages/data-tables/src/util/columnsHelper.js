const decideHeader = (id, columnsHeader) => {
  const i = /\.label$/.test(id) ? id.slice(0, -6) : id
  return columnsHeader[i]
}

export { decideHeader }
