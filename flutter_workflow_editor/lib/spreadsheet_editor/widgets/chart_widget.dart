/// Chart widget using Syncfusion Charts
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Chart data model
class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint(this.label, this.value);
}

/// Chart types supported
enum SpreadsheetChartType {
  column,
  bar,
  line,
  pie,
  area,
}

class ChartWidget extends StatelessWidget {
  final String title;
  final List<ChartDataPoint> data;
  final SpreadsheetChartType chartType;

  const ChartWidget({
    super.key,
    required this.title,
    required this.data,
    this.chartType = SpreadsheetChartType.column,
  });

  @override
  Widget build(BuildContext context) {
    switch (chartType) {
      case SpreadsheetChartType.column:
        return _buildColumnChart();
      case SpreadsheetChartType.bar:
        return _buildBarChart();
      case SpreadsheetChartType.line:
        return _buildLineChart();
      case SpreadsheetChartType.pie:
        return _buildPieChart();
      case SpreadsheetChartType.area:
        return _buildAreaChart();
    }
  }

  Widget _buildColumnChart() {
    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ColumnSeries<ChartDataPoint, String>(
          dataSource: data,
          xValueMapper: (ChartDataPoint point, _) => point.label,
          yValueMapper: (ChartDataPoint point, _) => point.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        BarSeries<ChartDataPoint, String>(
          dataSource: data,
          xValueMapper: (ChartDataPoint point, _) => point.label,
          yValueMapper: (ChartDataPoint point, _) => point.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        LineSeries<ChartDataPoint, String>(
          dataSource: data,
          xValueMapper: (ChartDataPoint point, _) => point.label,
          yValueMapper: (ChartDataPoint point, _) => point.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          markerSettings: const MarkerSettings(isVisible: true),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      title: ChartTitle(text: title),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        PieSeries<ChartDataPoint, String>(
          dataSource: data,
          xValueMapper: (ChartDataPoint point, _) => point.label,
          yValueMapper: (ChartDataPoint point, _) => point.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildAreaChart() {
    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        AreaSeries<ChartDataPoint, String>(
          dataSource: data,
          xValueMapper: (ChartDataPoint point, _) => point.label,
          yValueMapper: (ChartDataPoint point, _) => point.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          color: Colors.orange.withOpacity(0.6),
        ),
      ],
    );
  }
}

/// Chart dialog to show chart in full screen
class ChartDialog extends StatelessWidget {
  final String title;
  final List<ChartDataPoint> data;
  final SpreadsheetChartType chartType;

  const ChartDialog({
    super.key,
    required this.title,
    required this.data,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 600,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ChartWidget(
                title: '',
                data: data,
                chartType: chartType,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show chart dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<ChartDataPoint> data,
    required SpreadsheetChartType chartType,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ChartDialog(
        title: title,
        data: data,
        chartType: chartType,
      ),
    );
  }
}
