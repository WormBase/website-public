export default function logErrorToMyService(error, info) {
  const message = `
${document.location.href}
${error.stack}
${info ? 'Component stack: ' + info.componentStack : ''}
`;
  if (process.env.NODE_ENV === 'production') {
    fetch(`/tools/log-error-to-server?Message=${encodeURIComponent(message)}`, {
      method: 'post',
    });
  }
}
