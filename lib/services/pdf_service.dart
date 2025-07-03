import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../models/alert_model.dart';
import '../models/user_model.dart';

class PDFService {
  static Future<File> generateAlertReport(
    AlertModel alert,
    UserModel? createdByUser,
    UserModel? assignedToUser,
    UserModel? closedByUser,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'WHO EBOLA RESPONSE ALERT REPORT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Democratic Republic of Congo',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Divider(thickness: 2, color: PdfColors.blue900),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Alert Information
            pw.Text(
              'ALERT INFORMATION',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),

            _buildInfoTable([
              ['Alert ID:', alert.id],
              ['Title:', alert.title],
              ['Category:', alert.categoryDisplayName],
              ['Status:', alert.statusDisplayName],
              [
                'Created Date:',
                DateFormat('dd/MM/yyyy HH:mm').format(alert.createdAt)
              ],
              if (alert.assignedAt != null)
                [
                  'Assigned Date:',
                  DateFormat('dd/MM/yyyy HH:mm').format(alert.assignedAt!)
                ],
              if (alert.closedAt != null)
                [
                  'Closed Date:',
                  DateFormat('dd/MM/yyyy HH:mm').format(alert.closedAt!)
                ],
            ]),

            pw.SizedBox(height: 20),

            // Description
            pw.Text(
              'DESCRIPTION',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                alert.description,
                style: pw.TextStyle(fontSize: 12),
              ),
            ),

            pw.SizedBox(height: 20),

            // Location
            pw.Text(
              'LOCATION',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildInfoTable([
              ['Address:', alert.location.address],
              ['Latitude:', alert.location.latitude.toString()],
              ['Longitude:', alert.location.longitude.toString()],
            ]),

            pw.SizedBox(height: 20),

            // Personnel Information
            pw.Text(
              'PERSONNEL',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildInfoTable([
              ['Created by:', createdByUser?.fullName ?? 'Unknown'],
              ['Created by Email:', createdByUser?.email ?? 'Unknown'],
              if (assignedToUser != null) ...[
                ['Assigned to:', assignedToUser.fullName],
                ['Assigned to Email:', assignedToUser.email],
              ],
              if (closedByUser != null) ...[
                ['Closed by:', closedByUser.fullName],
                ['Closed by Email:', closedByUser.email],
              ],
            ]),

            pw.SizedBox(height: 20),

            // Media Information
            if (alert.imageUrls.isNotEmpty || alert.videoUrls.isNotEmpty) ...[
              pw.Text(
                'MEDIA ATTACHMENTS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 10),
              if (alert.imageUrls.isNotEmpty) ...[
                pw.Text('Images:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ...alert.imageUrls.asMap().entries.map(
                      (entry) => pw.Text('${entry.key + 1}. ${entry.value}',
                          style: pw.TextStyle(fontSize: 10)),
                    ),
                pw.SizedBox(height: 10),
              ],
              if (alert.videoUrls.isNotEmpty) ...[
                pw.Text('Videos:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ...alert.videoUrls.asMap().entries.map(
                      (entry) => pw.Text('${entry.key + 1}. ${entry.value}',
                          style: pw.TextStyle(fontSize: 10)),
                    ),
                pw.SizedBox(height: 10),
              ],
            ],

            // Closure Notes
            if (alert.notes != null && alert.notes!.isNotEmpty) ...[
              pw.Text(
                'CLOSURE NOTES',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  alert.notes!,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
            ],

            pw.SizedBox(height: 30),

            // Footer
            pw.Container(
              padding: pw.EdgeInsets.symmetric(vertical: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Report generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'WHO Ebola Response System - Democratic Republic of Congo',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Save PDF to device
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/alert_report_${alert.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildInfoTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: data.map((row) {
        return pw.TableRow(
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                row[0],
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                row[1],
                style: pw.TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  static Future<void> openPDF(File file) async {
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening PDF: $e');
      throw Exception('Unable to open PDF file');
    }
  }

  // Generate summary report for admin dashboard
  static Future<File> generateSummaryReport(
    Map<String, int> alertStats,
    Map<String, int> userStats,
    List<AlertModel> recentAlerts,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'WHO EBOLA RESPONSE SUMMARY REPORT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Democratic Republic of Congo',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Report Period: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Divider(thickness: 2, color: PdfColors.blue900),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Alert Statistics
            pw.Text(
              'ALERT STATISTICS',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildInfoTable([
              ['Total Alerts:', alertStats['total'].toString()],
              ['Open Alerts:', alertStats['open'].toString()],
              ['Assigned Alerts:', alertStats['assigned'].toString()],
              ['In Progress Alerts:', alertStats['inProgress'].toString()],
              ['Closed Alerts:', alertStats['closed'].toString()],
            ]),

            pw.SizedBox(height: 20),

            // User Statistics
            pw.Text(
              'USER STATISTICS',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildInfoTable([
              ['Total Users:', userStats['total'].toString()],
              ['Admin Users:', userStats['admin'].toString()],
              ['Medical Team:', userStats['medicalTeam'].toString()],
              ['Pending Approval:', userStats['pending'].toString()],
            ]),

            pw.SizedBox(height: 20),

            // Recent Alerts
            pw.Text(
              'RECENT ALERTS',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),

            if (recentAlerts.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Date',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Title',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Category',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Status',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                  ...recentAlerts
                      .take(10)
                      .map((alert) => pw.TableRow(
                            children: [
                              pw.Container(
                                padding: pw.EdgeInsets.all(8),
                                child: pw.Text(
                                    DateFormat('dd/MM/yy')
                                        .format(alert.createdAt),
                                    style: pw.TextStyle(fontSize: 9)),
                              ),
                              pw.Container(
                                padding: pw.EdgeInsets.all(8),
                                child: pw.Text(
                                    alert.title.length > 30
                                        ? '${alert.title.substring(0, 30)}...'
                                        : alert.title,
                                    style: pw.TextStyle(fontSize: 9)),
                              ),
                              pw.Container(
                                padding: pw.EdgeInsets.all(8),
                                child: pw.Text(alert.categoryDisplayName,
                                    style: pw.TextStyle(fontSize: 9)),
                              ),
                              pw.Container(
                                padding: pw.EdgeInsets.all(8),
                                child: pw.Text(alert.statusDisplayName,
                                    style: pw.TextStyle(fontSize: 9)),
                              ),
                            ],
                          ))
                      .toList(),
                ],
              ),
            ] else ...[
              pw.Text('No recent alerts found.',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            ],

            pw.SizedBox(height: 30),

            // Footer
            pw.Container(
              padding: pw.EdgeInsets.symmetric(vertical: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Report generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'WHO Ebola Response System - Democratic Republic of Congo',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Save PDF to device
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/summary_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
