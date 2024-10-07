import { useEffect, useState } from 'react';

const transformData = (data) => {
    return data.map(item => ({
        ...item,
        fraction: parseFloat(item.fraction),
        tpm: parseFloat(item.tpm)
    }));
};

export default function useSingleCell(geneId) {
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [data, setData] = useState([]);

    useEffect(() => {
        fetch(`https://dq1u9ioohb.execute-api.us-east-1.amazonaws.com/prod/api/proxy?table_name=expression-roux&gene_id=${geneId}`)
            .then(response => response.json())
            .then(responseData => {
                const transformedData = transformData(responseData);
                setData(transformedData);
                setLoading(false);
            })
            .catch(error => {
                console.error('Fetch error:', error);
                setError(error);
                setLoading(false);
            });
    }, [geneId]);

    return { data, loading, error };
}