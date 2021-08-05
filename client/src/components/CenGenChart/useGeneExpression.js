import React, { useEffect, useState } from 'react';

export default function useGeneExpression(geneId) {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [data, setData] = useState([]);

  useEffect(() => {
    fetch(
      `https://22rx59z6c7.execute-api.us-east-1.amazonaws.com/dev/items/${geneId}`
    )
      .then((response) => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then((data) => {
        setData(data);
        setLoading(false);
      })
      .catch((error) => {
        setError(error);
        setLoading(false);
      });
  }, [setLoading, setError, setData, geneId]);

  return {
    data,
  };
}
