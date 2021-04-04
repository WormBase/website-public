const generateHeaders = (labelAndKeyArr) =>
  labelAndKeyArr.map((lk) => {
    return {
      label: lk,
      key: lk,
    }
  })

const generateDerivedHeaders = (commonPart, changeablePartsArr) =>
  changeablePartsArr.map((changeablePart) => {
    const dotNotationToBeHeader = `${commonPart}.${changeablePart}`
    return {
      label: dotNotationToBeHeader,
      key: dotNotationToBeHeader,
    }
  })

export { generateHeaders, generateDerivedHeaders }
