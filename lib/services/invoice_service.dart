import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cart_item.dart';

class InvoiceService {
  static Future<void> generateInvoice(List<CartItem> items, double total) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (pw.Context c) => pw.Column(children: [
        pw.Text("INVOICE", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.Table.fromTextArray(data: <List<String>>[<String>['Item', 'Qty', 'Price'], ...items.map((i) => [i.product.title, i.quantity.toString(), "\$${i.total}"]),]),
        pw.Divider(),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Total: \$${total.toStringAsFixed(2)}"))
      ])));
    await Printing.layoutPdf(onLayout: (f) async => doc.save());
  }
}