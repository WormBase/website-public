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
    console.log('SingleCellChart received data:', data);
    if (data && data.length && chartRef.current) {
      console.log('Rendering chart with data:', data);
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
        title: {
          text: `Expression of ${data[0].gene_name}`,
        },
        subtitle: {
          text: 'Source: Single-cell RNA-seq data',
        },
        xAxis: {
          title: {
            text: 'Cells (%) Expressing',
          },
          max: 100,
        },
        yAxis: {
          title: {
            text: 'Transcripts Per Million (TPM)',
          },
        },
        tooltip: {
          formatter: function() {
            return `<b>${this.point.cell_type}</b><br/>` +
                `Cells Expressing: ${this.x.toFixed(2)}%<br/>` +
                `TPM: ${this.y.toFixed(2)}`;
          }
        },
        series: [{
          name: 'Cell Types',
          data: data.map(item => ({
            x: item.fraction * 100, // Convert to percentage
            y: item.tpm,
            cell_type: item.cell_type,
          })),
        }],
      };

      console.log('Chart options:', chartOptions);
      Highcharts.chart(chartRef.current, chartOptions);
    } else {
      console.log('Not rendering chart. Data:', data, 'ChartRef:', chartRef.current);
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