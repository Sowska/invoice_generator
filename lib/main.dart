import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());

  // Add this code below

  doWhenWindowReady(() {
    const initialSize = const Size(600, 700);
    appWindow.minSize = initialSize;
    appWindow.maxSize = Size(800, 900);
    appWindow.size = initialSize;
    appWindow.show();
  });
}

var buttonColors = WindowButtonColors(
    iconNormal: const Color.fromARGB(255, 255, 255, 255),
    mouseOver: const Color.fromARGB(255, 145, 220, 243),
    mouseDown: const Color.fromARGB(255, 145, 220, 243),
    iconMouseOver: const Color.fromARGB(255, 255, 255, 255),
    iconMouseDown: const Color.fromARGB(255, 255, 255, 255));

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: buttonColors)
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generar Presupuesto',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const MyHomePage(title: 'Jorge Silva - Chapa y Pintura'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController clientController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController vehicleController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController licensePlateController = TextEditingController();
  TextEditingController totalCostController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  late Directory? documentsDir;
  final String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();

    getApplicationDocumentsDirectory().then((dir) {
      setState(() {
        documentsDir = dir;
      });
    });
  }

  double parseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }

  Future<Uint8List> _buildPdf() async {
    // Create a PDF document.
    final pdf = pw.Document();
    final detalle = detailController.text;

    final imagen1 =
        (await rootBundle.load('assets/img/logo.jpg')).buffer.asUint8List();
    final imagen2 =
        (await rootBundle.load('assets/img/mapa.jpg')).buffer.asUint8List();

    // Add page to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header with two images
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(pw.MemoryImage(imagen1), width: 200),
              pw.Image(pw.MemoryImage(imagen2), width: 300),
            ],
          ),
          // Custom header "PRESUPUESTO"
          pw.Container(
            height: 18,
            color: PdfColors.black,
            alignment: pw.Alignment.center,
            child: pw.Text(
              'PRESUPUESTO',
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          // Row with two containers
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('San Luis: $formattedDate'),
                      pw.SizedBox(height: 5),
                      pw.Text('Señor/a/es: ${clientController.text}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Dirección: ${addressController.text}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Vehiculo: ${vehicleController.text}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Modelo: ${modelController.text}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Dominio: ${licensePlateController.text}'),
                      pw.SizedBox(height: 5)
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.Container(
            height: 18,
            color: PdfColors.black,
            alignment: pw.Alignment.center,
            child: pw.Text(
              'DETALLE',
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(detailController.text)),
          pw.SizedBox(width: 10),
          pw.Divider(),
          // Footer row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  children: [
                    pw.Text("____________________"),
                    pw.Text("FIRMA",
                        style: const pw.TextStyle(
                            color: PdfColors.black, fontSize: 14)),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  children: [
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Costo Total\nChapa y Pintura: ",
                              style: const pw.TextStyle(
                                  color: PdfColors.black, fontSize: 14)),
                          pw.SizedBox(width: 10),
                          pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                ),
                              ),
                              child: pw.Text(
                                  "\$${double.parse(totalCostController.text).toStringAsFixed(2)}",
                                  style: const pw.TextStyle(
                                      color: PdfColors.black, fontSize: 14)))
                        ]),
                    pw.SizedBox(height: 5),
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('TOTAL: ',
                              style: const pw.TextStyle(
                                  color: PdfColors.black, fontSize: 16)),
                          pw.SizedBox(width: 40),
                          pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black, // Color del borde
                                ),
                              ),
                              child: pw.Text(
                                  "\$${double.parse(totalController.text).toStringAsFixed(2)}",
                                  style: const pw.TextStyle(
                                      color: PdfColors.black, fontSize: 16)))
                        ]),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> _generateAndSavePDF() async {

    final Map<String, TextEditingController> checkFields = {
    'Cliente': clientController,
    'Dirección': addressController,
    'Vehiculo': vehicleController,
    'Modelo' : modelController,
    'Dominio' : licensePlateController,
    'Detalle' : detailController,
    'Subtotal': totalCostController,
    'Total': totalController
  };

  String missingFields = '';

  checkFields.forEach((clave, controller) {
   if(controller.text.isEmpty || controller.text.trim().isEmpty){
    missingFields += '$clave\n';
   }
  });

  if(missingFields.isNotEmpty){
        showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Presupuesto Incompleto'),
          content: Text(
            textAlign: TextAlign.center,
              'Los siguientes campos no fueron completados:\n\n$missingFields'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

  } else {

    final pdfBytes = await _buildPdf();
    final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

    final pdfFileName = '${clientController.text}_$timestamp.pdf';
    final pdfFilePath = '${documentsDir?.path}/$pdfFileName';

    final pdfFile = File(pdfFilePath);
    await pdfFile.writeAsBytes(pdfBytes);

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('PDF Creado con Éxito'),
          content: const Text(
              'El PDF se ha creado y guardado exitosamente en "Documentos".'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    checkFields.forEach((clave, controller) {
      controller.clear();
    });
  }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade200
            ],
          ),
        ),
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Row(children: [
                Expanded(
                  child: MoveWindow(),
                ),
                const WindowButtons()
              ]),
            ),
            Card(
              color: Colors.blueGrey.shade50,
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Fecha:$formattedDate',
                    ),
                    TextField(
                      controller: clientController,
                      decoration: const InputDecoration(labelText: 'Cliente'),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                    ),
                    TextField(
                      controller: vehicleController,
                      decoration: const InputDecoration(labelText: 'Vehículo'),
                    ),
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                    ),
                    TextField(
                      controller: licensePlateController,
                      decoration: const InputDecoration(labelText: 'Dominio'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: detailController,
                      maxLines: 20,
                      decoration: InputDecoration(
                        hintText: 'Escribe aquí...',
                        filled: true,
                        fillColor: Colors.blueGrey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .blueGrey.shade50, // Color del fondo del Container
                      borderRadius:
                          BorderRadius.circular(10.0), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Total Chapa y Pintura:'),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: totalCostController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Total:'),
                            const SizedBox(width: 110),
                            Expanded(
                              child: TextField(
                                controller: totalController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _generateAndSavePDF,
                      child: const Text('Generar PDF'),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
