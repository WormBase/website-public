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
                return item.xAxis.axisTitle.textStr;
              } else if (key === 'y') {
                return item.yAxis.axisTitle.textStr;
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
          text: 'Source: Ghaddar et al 2023<br/><br/>Tip: To zoom in on the chart, click and drag to select a region.',
        },
        legend: {
          enabled: false,
        },
        xAxis: {
          title: {
            text: 'Cells (%) Expressing',
          },
          crosshair: true,
          max: 100,
        },
        yAxis: {
          title: {
            text: 'Transcripts Per Million (TPM)',
          },
          crosshair: true,
        },
        tooltip: {
          shared: true,
          valueDecimals: 2,
          headerFormat: '<b>{point.key}</b><br>',
          pointFormat: '{point.y} TPM<br>{point.x:.1f}% Cells',
        },
        plotOptions: {
          scatter: {
            marker: {
              radius: 5,
              states: {
                hover: {
                  enabled: true,
                  lineColor: 'rgb(100,100,100)'
                }
              }
            },
            states: {
              hover: {
                marker: {
                  enabled: false
                }
              }
            }
          }
        },
        series: [{
          name: 'Cell Types',
          color: 'rgba(0, 120, 200, 0.7)',  // Blue color with some transparency
          data: data.map(item => ({
            x: item.fraction * 100,
            y: item.tpm,
            name: item.cell_type,
          })),
          dataLabels: {
            enabled: true,
            formatter: function() {
              return this.point.x === 0 ? '' : this.point.name;
            },
            color: 'black',
            style: {
              textOutline: 'none',
              fontWeight: 'normal'
            }
          },
        }],
      };

      Highcharts.chart(chartRef.current, chartOptions);
    }
  }, [data]);

  return (
      <div>
        <div ref={chartRef} style={{ width: '100%', height: '400px' }} />
        {(!data || data.length === 0) && (
            <span className="fade">No data available.</span>
        )}
      </div>
  );
}

export default SingleCellChart;