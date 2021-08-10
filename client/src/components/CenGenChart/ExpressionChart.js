import React, { useRef, useEffect } from 'react';
import Highcharts from 'highcharts';
import HighchartsMore from 'highcharts/highcharts-more';
import Exporting from 'highcharts/modules/exporting';
HighchartsMore(Highcharts);
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
          type: 'bubble',
          scrollablePlotArea: {
            minWidth: categories.length * 30,
            // scrollPositionX: 0,
          },
          colorCount: 2,
        },
        exporting: {
          sourceWidth: Math.max(600, categories.length * 30),
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
        ],
        plotOptions: {},
        series: [
          {
            name: 'TPM',
            data: data.map(({ tpm, proportion, cell_type }) => {
              return {
                y: tpm,
                z: proportion,
                name: cell_type,
              };
            }),
            dataLabels: {
              enabled: true,
              formatter: function() {
                return this.point.z === 0
                  ? ''
                  : `${Highcharts.numberFormat(this.point.z, 0)}%`;
              },
            },
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
