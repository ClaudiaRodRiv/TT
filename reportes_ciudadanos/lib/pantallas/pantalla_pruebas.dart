import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Prueba extends StatefulWidget {
  const Prueba({super.key});

  @override
  State<Prueba> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<Prueba> {
  late Future<List<String>> _debugFuture;

  @override
  void initState() {
    super.initState();
    _debugFuture = cargarDebug();
  }

  Future<List<String>> cargarDebug() async {
    try {
      final String data = await rootBundle.loadString('recursos/cdmx_alcaldias.json');
      final jsonResult = jsonDecode(data);
      List<List<LatLng>> poligonos = [];
      for (var feature in jsonResult['features']) {
        final geometry = feature['geometry'];
        if (geometry['type'] != 'Polygon') continue;
        final coords = geometry['coordinates'][0];
        poligonos.add(coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList());
      }

      final todosLosReportes = await ApiService.getReportes();

      bool puntoEnPoligono(LatLng punto, List<LatLng> poligono) {
        int j = poligono.length - 1;
        bool dentro = false;
        for (int i = 0; i < poligono.length; i++) {
          final xi = poligono[i].longitude;
          final yi = poligono[i].latitude;
          final xj = poligono[j].longitude;
          final yj = poligono[j].latitude;
          final intersecta = ((xi > punto.longitude) != (xj > punto.longitude)) &&
              (punto.latitude < (yj - yi) * (punto.longitude - xi) / (xj - xi + 0.0000001) + yi);
          if (intersecta) dentro = !dentro;
          j = i;
        }
        return dentro;
      }

      List<String> logs = [];
      for (var r in todosLosReportes) {
        final lat = double.tryParse(r['Latitud'].toString());
        final lng = double.tryParse(r['Longitud'].toString());
        if (lat == null || lng == null) {
          logs.add('Reporte inválido: ${r['Latitud']}, ${r['Longitud']}');
          continue;
        }
        bool dentro = poligonos.any((poly) => puntoEnPoligono(LatLng(lat, lng), poly));
        logs.add('Reporte $lat,$lng dentro de algún polígono? $dentro');
      }

      return logs;
    } catch (e) {
      return ['Error al cargar debug: $e'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Reportes')),
      body: FutureBuilder<List<String>>(
        future: _debugFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) return const Center(child: Text('No hay reportes'));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: logs.length,
                  itemBuilder: (_, i) => Card(
                    child: ListTile(
                      title: Text(logs[i]),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}