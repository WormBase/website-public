import React from 'react';
import useSingleCell from './useEmbryoCell';
import EmbryoCellChart from "./EmbryoCellChart";
import { CircularProgress } from '../Progress';


export default function({ geneId }) {
    const { loading, error, data } = useSingleCell(geneId);

    if (error) {
        throw error;
    }

    return loading ? <CircularProgress /> : <EmbryoCellChart data={data} />;
}