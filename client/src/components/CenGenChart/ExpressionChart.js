import React, { useRef, useEffect } from 'react';
import Highcharts from 'highcharts';

function ExpressionChart({ data }) {
  const chartRef = useRef(null);

  useEffect(() => {
    if (data && data.length && chartRef.current) {
      const categories = data.map(({ cell_type }) => cell_type);
      const chartOptions = {
        chart: {
          type: 'column',
          scrollablePlotArea: {
            minWidth: categories.length * 20,
            // scrollPositionX: 0,
          },
        },
        title: {
          text: '',
        },
        subtitle: {
          text: 'Some additional information',
        },
        xAxis: {
          title: {
            text: 'Cell type',
          },
          categories: categories,
        },
        yAxis: {
          title: {
            text: 'TPM',
          },
        },
        series: [
          {
            data: data.map(({ tpm }) => tpm),
            showInLegend: false,
          },
        ],
      };
      Highcharts.chart(chartRef.current, chartOptions);
    }
  }, [data, chartRef]);
  return <div ref={chartRef} />;
}

export default ExpressionChart;
