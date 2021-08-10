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
          type: 'scatter',
          zoomType: 'xy',
        },
        exporting: {},
        title: {
          text: '',
        },
        subtitle: {
          text: 'Source: <a href="http://www.cengen.org/">CeNGEN</a>',
        },
        legend: {
          enabled: false,
        },
        tooltip: {
          shared: true,
          valueDecimals: 2,
          headerFormat: '<b>{point.key}</b><br>',
          pointFormat: '{point.y} TPM<br>{point.x:.1f}% Cells',
        },
        xAxis: {
          title: {
            text: 'Cells (%) Expressing',
          },
          crosshair: true,
          max: 100,
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
            crosshair: true,
          },
        ],
        plotOptions: {},
        series: [
          {
            name: 'TPM',
            data: data.map(({ tpm, proportion, cell_type }) => {
              return {
                x: proportion,
                y: tpm,
                name: cell_type,
              };
            }),
            dataLabels: {
              enabled: true,
              formatter: function() {
                return this.point.x === 0 ? '' : this.point.name;
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
