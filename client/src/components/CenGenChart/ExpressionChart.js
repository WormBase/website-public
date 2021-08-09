import React, { useRef, useEffect } from 'react';
import Highcharts from 'highcharts';
import Exporting from 'highcharts/modules/exporting';
Exporting(Highcharts);

function ExpressionChart({ data }) {
  const chartRef = useRef(null);

  useEffect(() => {
    if (data && data.length && chartRef.current) {
      const categories = data.map(({ cell_type }) => cell_type);

      Highcharts.setOptions({
        lang: {
          thousandsSep: ',',
        },
      });

      const chartOptions = {
        chart: {
          type: 'column',
          scrollablePlotArea: {
            minWidth: categories.length * 20,
            // scrollPositionX: 0,
          },
          colorCount: 2,
        },
        exporting: {
          sourceWidth: Math.max(600, categories.length * 20),
        },
        title: {
          text: '',
        },
        subtitle: {
          text: 'Source: <a href="http://www.cengen.org/">CeNGEN</a>',
        },
        tooltip: {
          shared: true,
          valueDecimals: 2,
        },
        xAxis: {
          title: {
            text: 'Cell type',
          },
          categories: categories,
          crosshair: true,
        },
        yAxis: [
          {
            title: {
              text: 'Transcripts Per Kilobase Million (TPM)',
              style: {
                color: Highcharts.getOptions().colors[0],
              },
            },
            labels: {
              style: {
                color: Highcharts.getOptions().colors[0],
              },
            },
          },
          {
            title: {
              text: 'Cells (%) expressing',
              style: {
                color: Highcharts.getOptions().colors[1],
              },
            },
            labels: {
              enabled: true,
              style: {
                color: Highcharts.getOptions().colors[1],
              },
            },
            tooltip: {
              valueSuffix: ' %',
            },
            min: 0,
            max: 100,
            // opposite: true,
          },
        ],
        plotOptions: {},
        series: [
          {
            name: 'TPM',
            data: data.map(({ tpm }) => tpm),
            yAxis: 0,
          },
          {
            name: 'Cells (%)',
            data: data.map(({ proportion }) => proportion),
            yAxis: 1,
            /*             dataLabels: {
              enabled: true,
              formatter: function() {
                if (this.y > 0) {
                  // round to 1 decimal places
                  return `${Math.round(this.y * 10) / 10}%`;
                }
              },
            }, */
          },
        ],
      };
      Highcharts.chart(chartRef.current, chartOptions);
    }
  }, [data, chartRef]);
  return (
    <div>
      <div ref={chartRef} />
      {data && data.length ? null : (
        <span className="fade">No data available.</span>
      )}
    </div>
  );
}

export default ExpressionChart;
