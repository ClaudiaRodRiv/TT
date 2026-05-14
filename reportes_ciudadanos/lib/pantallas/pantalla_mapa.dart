import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'pantalla_reporte.dart';
import 'pantalla_detalle_reporte.dart';
import 'pantalla_filtros.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final MapController _mapController = MapController();

  List<dynamic> reportesCorrupcion = [];
  List<dynamic> reportesNarcomenudeo = [];
  List<dynamic> reportesViolenciaGenero = [];
  List<dynamic> reportesRoboAsalto = [];
  List<dynamic> reportesServiciosPublicos = [];
   List<dynamic> reportesGenerales = [];
  List<dynamic> todosLosReportes = [];

  List<Polygon> poligonos = [];
  Polygon? poligonoSeleccionado;
  String? coloniaSeleccionadaActual;
  String? alcaldiaSeleccionadaActual;
  Map<String, bool> tiposSeleccionadosActual = {
    'corrupcion': false,
    'narcomenudeo': false,
    'violencia': false,
    'robo': false,
    'servicios': false,
    'general': false,
  };

  double zoomActual = 12;
  LatLng? ubicacionSeleccionada;
  bool ubicacionLista = false;

  final LatLngBounds limitesCDMX = LatLngBounds(
    LatLng(19.00, -99.40),
    LatLng(19.65, -98.85),
  );

  final Map<String, List<dynamic>> categoriaIconosColores = {
    'Servicios Públicos': [Icons.construction, Colors.blue.shade800],
    'Robo o Asalto': [Icons.lock_open, Colors.purple.shade400],
    'Corrupción u omisión de servidor público': [Icons.account_balance, Colors.pink.shade800],
    'Violencia de Género': [Icons.female, Colors.pinkAccent],
    'Narcomenudeo': [Icons.local_police, Colors.cyan.shade400],
    'Reporte General': [Icons.description, Colors.deepOrangeAccent],
  };

  @override
  void initState() {
    super.initState();
    obtenerReportesCorrupcion();
    obtenerReportesNarcomenudeo();
    obtenerTodosLosReportes();
    obtenerReportesViolenciaGenero();
    obtenerReportesRoboAsalto();
    obtenerReportesServiciosPublicos();
    obtenerReportesGenerales();
    cargarPoligonos();
  }

  Future<void> obtenerReportesCorrupcion() async {
    try {
      final data = await ApiService.getReportesCorrupcion();
      setState(() {
        reportesCorrupcion = data;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> obtenerReportesNarcomenudeo() async {
    try {
      final data = await ApiService.getReportesNarcomenudeo();
      setState(() {
        reportesNarcomenudeo = data;
      });
    } catch (e) {
      print(e);
    }
  }

    Future<void> obtenerReportesViolenciaGenero() async {
    try {
      final data = await ApiService.getReportesViolenciaGenero();
      setState(() {
        reportesViolenciaGenero = data;
      });
    } catch (e) {
      print(e);
    }
  }

      Future<void> obtenerReportesRoboAsalto() async {
    try {
      final data = await ApiService.getReportesRoboAsalto();
      setState(() {
        reportesRoboAsalto = data;
      });
    } catch (e) {
      print(e);
    }
  }

      Future<void> obtenerReportesServiciosPublicos() async {
    try {
      final data = await ApiService.getReportesServiciosPublicos();
      setState(() {
        reportesServiciosPublicos = data;
      });
    } catch (e) {
      print(e);
    }
  }

        Future<void> obtenerReportesGenerales() async {
    try {
      final data = await ApiService.getReportesGenerales();
      setState(() {
        reportesGenerales = data;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> obtenerTodosLosReportes() async {
    try {
      final data = await ApiService.getReportes();
      setState(() {
        todosLosReportes = data;
      });
      await cargarPoligonos();
    } catch (e) {
      print(e);
    }
  }

  Future<void> irAMiUbicacion() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();

    if (!servicioHabilitado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activa la ubicación del dispositivo'),
        ),
      );
      return;
    }

    permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();

      if (permiso == LocationPermission.denied) {
        return;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return;
    }

    final posicion = await Geolocator.getCurrentPosition();

    final miUbicacion = LatLng(
      posicion.latitude,
      posicion.longitude,
    );

    _mapController.move(miUbicacion, 17);

    setState(() {
      ubicacionSeleccionada = miUbicacion;
      ubicacionLista = true;
    });
  }

  Future<void> cargarPoligonos() async {
    final String data =
        await rootBundle.loadString('recursos/cdmx_alcaldias.json');

    final jsonResult = jsonDecode(data);

    List<Polygon> nuevosPoligonos = [];

    for (var feature in jsonResult['features']) {
      final geometry = feature['geometry'];
      final coordinates = geometry['coordinates'];

      if (geometry['type'] == 'Polygon') {
        List<LatLng> puntos = [];

        for (var coord in coordinates[0]) {
          final lng = coord[0];
          final lat = coord[1];
          puntos.add(LatLng(lat, lng));
        }

        final total = contarReportesEnPoligono(puntos);
        final color = obtenerColor(total);

        nuevosPoligonos.add(
          Polygon(
            points: puntos,
            color: color.withValues(alpha: 0.25),
            borderColor: color,
            borderStrokeWidth: 2.5,
            isFilled: true,
          ),
        );
      }
    }

    setState(() {
      poligonos = nuevosPoligonos;
    });
  }

  bool puntoEnPoligono(LatLng punto, List<LatLng> poligono) {
    int i, j = poligono.length - 1;
    bool dentro = false;

    for (i = 0; i < poligono.length; i++) {
      final xi = poligono[i].longitude;
      final yi = poligono[i].latitude;
      final xj = poligono[j].longitude;
      final yj = poligono[j].latitude;

      final intersecta =
          ((xi > punto.longitude) != (xj > punto.longitude)) &&
          (punto.latitude < (yj - yi) * (punto.longitude - xi) / (xj - xi + 0.0000001) + yi);

      if (intersecta) dentro = !dentro;
      j = i;
    }

    return dentro;
  }

  int contarReportesEnPoligono(List<LatLng> poligono) {
    int total = 0;

    for (var reporte in todosLosReportes) {
      final lat = double.tryParse(reporte['latitud'].toString());
      final lng = double.tryParse(reporte['longitud'].toString());

      if (lat == null || lng == null) continue;

      if (puntoEnPoligono(LatLng(lat, lng), poligono)) {
        total++;
      }
    }

    return total;
  }

  Color obtenerColor(int total) {
    if (total < 800) return Colors.green;
    if (total < 1200) return Colors.orange;
    return Colors.red;
  }

  LatLng obtenerCentro(List coords) {
  double lat = 0;
  double lng = 0;
  int total = 0;

  for (var punto in coords[0]) {
    lng += punto[0];
    lat += punto[1];
    total++;
  }

  return LatLng(lat / total, lng / total);
}

void aplicarFiltroColonia(Map filtros) {
  final geometry = filtros['geometry'];
  if (geometry == null) {
    print("No hay geometry para aplicar filtro");
    return;
  }

  final coords = geometry['coordinates'];

  final centro = obtenerCentro(coords);
  _mapController.move(centro, 16);

  List<LatLng> puntos = [];

  for (var c in coords[0]) {
    puntos.add(LatLng(c[1], c[0]));
  }

  setState(() {
    poligonoSeleccionado = Polygon(
      points: puntos,
      color: Colors.blue.withValues(alpha: 0.2),
      borderColor: Colors.blue,
      borderStrokeWidth: 3,
      isFilled: true,
    );
  });
}

  Marker crearMarker({
    required double lat,
    required double lng,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Marker(
      point: LatLng(lat, lng),
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icono, size: 36, color: color),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color azulApp = theme.colorScheme.primary;

    bool mostrar(String key) {
      // si ninguno está seleccionado, mostrar todo
      if (!tiposSeleccionadosActual.containsValue(true)) return true;
      return tiposSeleccionadosActual[key] == true;
    }

    final categoriaCorrupcion = 'Corrupción u omisión de servidor público';
    final iconoCorrupcion = categoriaIconosColores[categoriaCorrupcion]![0] as IconData;
    final colorCorrupcion = categoriaIconosColores[categoriaCorrupcion]![1] as Color;

    final categoriaNarcomenudeo = 'Narcomenudeo';
    final iconoNarcomenudeo = categoriaIconosColores[categoriaNarcomenudeo]![0] as IconData;
    final colorNarcomenudeo = categoriaIconosColores[categoriaNarcomenudeo]![1] as Color;

    final categoriaViolenciaGenero = 'Violencia de Género';
    final iconoViolenciaGenero = categoriaIconosColores[categoriaViolenciaGenero]![0] as IconData;
    final colorViolenciaGenero = categoriaIconosColores[categoriaViolenciaGenero]![1] as Color;

    final categoriaRoboAsalto = 'Robo o Asalto';
    final iconoRoboAsalto = categoriaIconosColores[categoriaRoboAsalto]![0] as IconData;
    final colorRoboAsalto = categoriaIconosColores[categoriaRoboAsalto]![1] as Color;

    final categoriaServiciosPublicos = 'Servicios Públicos';
    final iconoServiciosPublicos = categoriaIconosColores[categoriaServiciosPublicos]![0] as IconData;
    final colorServiciosPublicos = categoriaIconosColores[categoriaServiciosPublicos]![1] as Color;

    final categoriaGeneral = 'Reporte General';
    final iconoGeneral = categoriaIconosColores[categoriaGeneral]![0] as IconData;
    final colorGeneral = categoriaIconosColores[categoriaGeneral]![1] as Color;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa de Reportes',
          style:
              theme.textTheme.headlineSmall?.copyWith(color: Colors.white70),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(19.4326, -99.1332),
                  initialZoom: 12,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: limitesCDMX,
                  ),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onPositionChanged: (position, hasGesture) {
                    final nuevoZoom = position.zoom ?? 12;

                    if (nuevoZoom != zoomActual) {
                      setState(() {
                        zoomActual = nuevoZoom;
                      });
                    }
                  },
                  onTap: (tapPosition, point) {
                    setState(() {
                      ubicacionSeleccionada = point;
                      ubicacionLista = true;
                    });
                  },
                ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.reportes_ciudadanos',
                ),

                PolygonLayer(
                  polygons: [
                    ...poligonos,
                    if (poligonoSeleccionado != null) poligonoSeleccionado!,
                  ],
                ),

                if (zoomActual >= 14)
                  MarkerLayer(
                    key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                    markers: [
                      if (ubicacionSeleccionada != null)
                        Marker(
                          point: ubicacionSeleccionada!,
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 27,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ...reportesCorrupcion
                        .where((_) => mostrar('corrupcion'))
                        .map((reporte) {
                        final lat = double.tryParse(
                            reporte['latitud'].toString());
                        final lng = double.tryParse(
                            reporte['longitud'].toString());

                        if (lat == null || lng == null) return null;

                        return crearMarker(
                          lat: lat,
                          lng: lng,
                          icono: iconoCorrupcion,
                          color: colorCorrupcion,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleReporte(
                                  reporte: reporte,
                                  tipo: 'Corrupción u omisión de servidor público',
                                ),
                              ),
                            );
                            await obtenerTodosLosReportes();
                            await obtenerReportesCorrupcion();
                            await obtenerReportesNarcomenudeo();
                            await obtenerReportesViolenciaGenero();
                            await obtenerReportesRoboAsalto();
                            await obtenerReportesServiciosPublicos();
                            await obtenerReportesGenerales();
                            await cargarPoligonos();
                          },
                        );
                      }).whereType<Marker>(),

                      ...reportesNarcomenudeo
                        .where((_) => mostrar('narcomenudeo'))
                        .map((reporte) {
                        final lat = double.tryParse(
                            reporte['latitud'].toString());
                        final lng = double.tryParse(
                            reporte['longitud'].toString());

                        if (lat == null || lng == null) return null;

                        return crearMarker(
                          lat: lat,
                          lng: lng,
                          icono: iconoNarcomenudeo,
                          color: colorNarcomenudeo,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleReporte(
                                  reporte: reporte,
                                  tipo: 'Narcomenudeo',
                                ),
                              ),
                            );
                            await obtenerTodosLosReportes();
                            await obtenerReportesCorrupcion();
                            await obtenerReportesNarcomenudeo();
                            await obtenerReportesViolenciaGenero();
                            await obtenerReportesRoboAsalto();
                            await obtenerReportesServiciosPublicos();
                            await obtenerReportesGenerales();
                            await cargarPoligonos();
                          },
                        );
                      }).whereType<Marker>(),

                      ...reportesViolenciaGenero
                        .where((_) => mostrar('violencia'))
                        .map((reporte) {
                        final lat = double.tryParse(
                            reporte['latitud'].toString());
                        final lng = double.tryParse(
                            reporte['longitud'].toString());

                        if (lat == null || lng == null) return null;

                        return crearMarker(
                          lat: lat,
                          lng: lng,
                          icono: iconoViolenciaGenero,
                          color: colorViolenciaGenero,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleReporte(
                                  reporte: reporte,
                                  tipo: 'Violencia de Género',
                                ),
                              ),
                            );
                            await obtenerTodosLosReportes();
                            await obtenerReportesCorrupcion();
                            await obtenerReportesNarcomenudeo();
                            await obtenerReportesViolenciaGenero();
                            await obtenerReportesRoboAsalto();
                            await obtenerReportesServiciosPublicos();
                            await obtenerReportesGenerales();
                            await cargarPoligonos();
                          },
                        );
                      }).whereType<Marker>(),

                      ...reportesRoboAsalto
                        .where((_) => mostrar('robo'))
                        .map((reporte) {
                        final lat = double.tryParse(
                            reporte['latitud'].toString());
                        final lng = double.tryParse(
                            reporte['longitud'].toString());

                        if (lat == null || lng == null) return null;

                        return crearMarker(
                          lat: lat,
                          lng: lng,
                          icono: iconoRoboAsalto,
                          color: colorRoboAsalto,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleReporte(
                                  reporte: reporte,
                                  tipo: 'Robo o Asalto',
                                ),
                              ),
                            );
                            await obtenerTodosLosReportes();
                            await obtenerReportesCorrupcion();
                            await obtenerReportesNarcomenudeo();
                            await obtenerReportesViolenciaGenero();
                            await obtenerReportesRoboAsalto();
                            await obtenerReportesServiciosPublicos();
                            await obtenerReportesGenerales();
                            await cargarPoligonos();
                          },
                        );
                      }).whereType<Marker>(),

                      ...reportesServiciosPublicos
                        .where((_) => mostrar('servicios'))
                        .map((reporte) {
                        final lat = double.tryParse(
                            reporte['latitud'].toString());
                        final lng = double.tryParse(
                            reporte['longitud'].toString());

                        if (lat == null || lng == null) return null;

                        return crearMarker(
                          lat: lat,
                          lng: lng,
                          icono: iconoServiciosPublicos,
                          color: colorServiciosPublicos,
                          onTap: () async {
                           await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleReporte(
                                  reporte: reporte,
                                  tipo: 'Servicios Públicos',
                                ),
                              ),
                            );
                            await obtenerTodosLosReportes();
                            await obtenerReportesCorrupcion();
                            await obtenerReportesNarcomenudeo();
                            await obtenerReportesViolenciaGenero();
                            await obtenerReportesRoboAsalto();
                            await obtenerReportesServiciosPublicos();
                            await obtenerReportesGenerales();
                            await cargarPoligonos();
                          },
                        );
                      }).whereType<Marker>(),

                      ...reportesGenerales
                        .where((_) => mostrar('general'))
                        .map((reporte) {
                        final lat = double.tryParse(
                            reporte['latitud'].toString());
                        final lng = double.tryParse(
                            reporte['longitud'].toString());

                        if (lat == null || lng == null) return null;

                        return crearMarker(
                          lat: lat,
                          lng: lng,
                          icono: iconoGeneral,
                          color: colorGeneral,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleReporte(
                                  reporte: reporte,
                                  tipo: 'Reporte General',
                                ),
                              ),
                            );
                            await obtenerTodosLosReportes();
                            await obtenerReportesCorrupcion();
                            await obtenerReportesNarcomenudeo();
                            await obtenerReportesViolenciaGenero();
                            await obtenerReportesRoboAsalto();
                            await obtenerReportesServiciosPublicos();
                            await obtenerReportesGenerales();
                            await cargarPoligonos();
                          },
                        );
                      }).whereType<Marker>(),
                    ],
                  ),
              ],
            ),
          ),

          Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _chip(Icons.warning, 'Alta', Colors.redAccent),
                  _chip(Icons.error_outline, 'Media', Colors.orangeAccent),
                  _chip(Icons.check_circle, 'Baja', Colors.green),
                ],
              ),
            ),

            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                onPressed: ubicacionLista
                    ? () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaReporte(
                              latitud: ubicacionSeleccionada!.latitude,
                              longitud: ubicacionSeleccionada!.longitude,
                            ),
                          ),
                        );

                        setState(() {
                          ubicacionSeleccionada = null;
                          ubicacionLista = false;
                        });

                        await obtenerTodosLosReportes();
                        await obtenerReportesCorrupcion();
                        await obtenerReportesNarcomenudeo();
                        await obtenerReportesViolenciaGenero();
                        await obtenerReportesRoboAsalto();
                        await obtenerReportesServiciosPublicos();
                        await obtenerReportesGenerales();
                        await cargarPoligonos();
                      }
                    : null,

                backgroundColor: ubicacionLista ? azulApp : Colors.grey,

                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),

            Positioned(
              bottom: 30,
              left: 30,
              child: FloatingActionButton(
                heroTag: 'filtrosBtn',
                onPressed: () async {
                  final filtros = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaFiltros(
                        filtrosIniciales: {
                          'colonia': coloniaSeleccionadaActual,
                          'alcaldia': alcaldiaSeleccionadaActual,
                          'tipos': tiposSeleccionadosActual,
                        },
                      ),
                    ),
                  );
                  if (filtros == null) {
                    
                  setState(() {
                    poligonoSeleccionado = null;
                    coloniaSeleccionadaActual = null;
                    alcaldiaSeleccionadaActual = null;
                    tiposSeleccionadosActual = {
                      'corrupcion': false,
                      'narcomenudeo': false,
                      'violencia': false,
                      'robo': false,
                      'servicios': false,
                      'general': false,
                    };
                  });

                    await obtenerTodosLosReportes();
                    await obtenerReportesCorrupcion();
                    await obtenerReportesNarcomenudeo();
                    await obtenerReportesViolenciaGenero();
                    await obtenerReportesRoboAsalto();
                    await obtenerReportesServiciosPublicos();
                    await obtenerReportesGenerales();
                    await cargarPoligonos();
                  } 
                    else {
                      setState(() {
                        coloniaSeleccionadaActual = filtros['colonia'];
                        alcaldiaSeleccionadaActual = filtros['alcaldia'];

                        final tipos = filtros['tipos'];
                        tiposSeleccionadosActual = {
                          'corrupcion': tipos?['corrupcion'] ?? false,
                          'narcomenudeo': tipos?['narcomenudeo'] ?? false,
                          'violencia': tipos?['violencia'] ?? false,
                          'robo': tipos?['robo'] ?? false,
                          'servicios': tipos?['servicios'] ?? false,
                          'general': tipos?['general'] ?? false,
                        };
                      });

                      aplicarFiltroColonia(filtros);
                    }
                },
                backgroundColor: azulApp,
                child: const Icon(Icons.filter_list, color: Colors.white),
              ),
            ),

            Positioned(
              bottom: 100,
              left: 30,
              child: FloatingActionButton(
                heroTag: 'ubicacionBtn',
                onPressed: irAMiUbicacion,
                backgroundColor: azulApp,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

    Widget _chip(IconData icon, String label, Color color) => Chip(
        avatar: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      );
}