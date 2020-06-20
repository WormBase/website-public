var fs = require('fs')

export const readFile = async (filePath) => {
  return new Promise((resolve, reject) => {
    fs.readFile(filePath, 'utf8', function(err, data) {
      if (err) {
        reject(err)
      }
      resolve(data)
    })
  })
}
