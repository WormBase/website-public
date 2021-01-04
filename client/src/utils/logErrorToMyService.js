export default function logErrorToMyService(error, info) {
  const message = `
An error occurred at ${document.location.href}
${error.message}
${info ? 'Component stack: ' + info.componentStack : ''}
`;
  if (process.env.NODE_ENV === 'production') {
    fetch(`/tools/log-error-to-server?Message=${encodeURIComponent(message)}`, {
      method: 'post',
    });
  } else {
    console.log(message);
  }
}
