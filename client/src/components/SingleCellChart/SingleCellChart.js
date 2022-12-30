import React, { useRef, useEffect } from 'react';
import Highcharts from 'highcharts';
import HighchartsMore from 'highcharts/highcharts-more';
import Exporting from 'highcharts/modules/exporting';
import ExportData from 'highcharts/modules/export-data';
import OfflineExporting from 'highcharts/modules/offline-exporting';
HighchartsMore(Highcharts);
Exporting(Highcharts);
ExportData(Highcharts);
OfflineExporting(Highcharts);

function SingleCellChart({ data }) {
  const chartRef = useRef(null);

  useEffect(() => {
    if (data && data.length && chartRef.current) {
      Highcharts.setOptions({
        lang: {
          thousandsSep: ',',
        },
      });

      const chartOptions = {
        chart: {
          type: 'scatter',
          zoomType: 'xy',

          events: {
            load: function() {
              this.chartBackground.htmlCss({ cursor: 'crosshair' });
            },
          },
        },
        exporting: {
          csv: {
            columnHeaderFormatter: (item, key) => {
              if (key === 'x') {
                return item.xAxis.axisTitle.textStr; // x axis label
              } else if (key === 'y') {
                return item.yAxis.axisTitle.textStr; // y axis label
              } else {
                return 'Cell type';
              }
            },
          },
          buttons: {
            contextButton: {
              menuItems: [
                'viewFullscreen',
                'printChart',
                'separator',
                'downloadPNG',
                'downloadJPEG',
                'downloadSVG',
                'separator',
                'downloadCSV',
                'downloadXLS',
                'viewData',
              ],
            },
          },
          tableCaption: false,
          sourceWidth: chartRef.current.clientWidth,
          sourceHeight: chartRef.current.clientHeight,
          fallbackToExportServer: false,
        },
        title: {
          text: '',
        },
        subtitle: {
          text:
            'Source: <a href="http://www.cengen.org/">CeNGEN</a><br/><br/>Tip: To zoom in on the chart, click and drag to select a region.',
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
              text: 'Transcripts Per Million (TPM)',
            },
            crosshair: true,
          },
        ],
        plotOptions: {},
        series: [
          {
            name: 'Expression',
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

export default SingleCellChart;
