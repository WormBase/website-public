export function fileToUrl(filepath, base = null) {
  if (base) {
    filepath = filepath.split(`/${base}/`)[1]
  }
  return filepath
    .replace(/ /g, '-')
    .replace(/\.(\w+?)$/, '')
    .trim()
}
