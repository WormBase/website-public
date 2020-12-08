export default function logErrorToMyService(error, info) {
  if (process.env.NODE_ENV === 'production') {
    fetch(
      `/tools/log-error-to-server?Message=${encodeURIComponent(
        document.location.href
      )} ${encodeURIComponent(error)} ${encodeURIComponent(
        JSON.stringify(info)
      )}`,
      {
        method: 'post',
      }
    );
  }
}
