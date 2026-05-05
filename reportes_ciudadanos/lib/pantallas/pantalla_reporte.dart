import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantallaReporte extends StatefulWidget {
  final double latitud;
  final double longitud;

  const PantallaReporte({
    super.key,
    required this.latitud,
    required this.longitud,
  });

  @override
  State<PantallaReporte> createState() => _PantallaReporteState();
}

class _PantallaReporteState extends State<PantallaReporte> {

  final supabase = Supabase.instance.client;

  final ImagePicker _picker = ImagePicker();
  String? evidenciaNombre;

  double get latitud => widget.latitud;
  double get longitud => widget.longitud;

  String tipoReporteSeleccionado = 'Servicios Públicos';
  final Map<String, List<Map<String, dynamic>>> camposPorTipo = {};
  final Map<String, dynamic> valores = {};

  static const paddingCard = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  @override
  void initState() {
    super.initState();
    camposPorTipo.addAll({
      'Servicios Públicos': _camposServiciosPublicos(),
      'Robo o Asalto': _camposRoboAsalto(),
      'Corrupción u omisión de servidor público': _camposCorrupcion(),
      'Violencia de Género': _camposViolenciaGenero(),
      'Narcomenudeo': _camposNarcomenudeo(),
      'Reporte General': _camposReporteGeneral(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nuevo Reporte',
          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white70),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dropdownTipo(theme),
              const SizedBox(height: 24),
              _cabeceraReporte(tipoReporteSeleccionado, theme),
              const SizedBox(height: 16),
              ...camposPorTipo[tipoReporteSeleccionado]!
                  .map((campo) => _crearCampo(campo, theme)),
              const SizedBox(height: 30),
              _botonEnviar(theme),
            ],
          ),
        ),
      ),
    );
  }

  // UI

  Widget _dropdownTipo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: tipoReporteSeleccionado,
              isExpanded: true,
              style: theme.textTheme.bodyMedium,
              items: camposPorTipo.keys
                  .map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      ))
                  .toList(),
              onChanged: (valor) => setState(() {
                tipoReporteSeleccionado = valor!;
                valores.clear(); // 🔥 limpia al cambiar tipo
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonEnviar(ThemeData theme) {
    return Center(
      child: ElevatedButton(
        onPressed: _enviarReporte,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A374D),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
        child: Text(
          'Enviar Reporte',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _cabeceraReporte(String tipo, ThemeData theme) {
    final map = {
      'Servicios Públicos': [Icons.construction, Colors.blue.shade800],
      'Robo o Asalto': [Icons.lock_open, Colors.purple.shade400],
      'Corrupción u omisión de servidor público': [
        Icons.account_balance,
        Colors.pink.shade800
      ],
      'Violencia de Género': [Icons.female, Colors.pinkAccent],
      'Narcomenudeo': [Icons.local_police, Colors.cyan.shade400],
      'Reporte General': [Icons.description, Colors.deepOrangeAccent],
    };

    final icon = map[tipo]![0] as IconData;
    final color = map[tipo]![1] as Color;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tipo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _subtitulo(String texto, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4, top: 12),
        child: Text(
          texto,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.grey,
          ),
        ),
      );

  Widget _crearCard({required Widget child, VoidCallback? onTap}) => Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(padding: paddingCard, child: child),
        ),
      );

  // Campos

  Widget _crearCampo(Map<String, dynamic> campo, ThemeData theme) {
    switch (campo['tipo']) {
      case 'text':
        return _crearCard(
          child: TextField(
            onChanged: (v) => setState(() {
              valores[campo['label']] = v;
            }),
            maxLines: campo['multiline'] == true ? null : 1,
            decoration: InputDecoration(labelText: campo['label']),
          ),
        );

      case 'dropdown':
        return _crearCard(
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: (campo['opciones'] as List)
                          .map((e) => e.toString())
                          .contains(valores[campo['label']])
                      ? valores[campo['label']]
                      : null,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: campo['label']),
                  items: (campo['opciones'] as List)
                      .map((o) => DropdownMenuItem(
                            value: o.toString(),
                            child: Text(
                              o,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    valores[campo['label']] = v;
                  }),
                ),
              ),
            ],
          ),
        );

      case 'subtitulo':
        return _subtitulo(campo['label'], theme);

      case 'date':
        return _crearCard(
          child: TextField(
            readOnly: true,
            controller: TextEditingController(
              text: valores[campo['label']] != null
                  ? valores[campo['label']].toString().split(' ')[0]
                  : '',
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  valores[campo['label']] = pickedDate;
                });
              }
            },
            decoration: InputDecoration(
              labelText: campo['label'],
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
        );

      case 'foto':
        return _crearCard(
          onTap: () => _tomarEvidencia(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text('Agregar evidencia'),
                ],
              ),

              if (evidenciaNombre != null) ...[
                const SizedBox(height: 8),
                Text(
                  evidenciaNombre!,
                  style: const TextStyle(color: Colors.green),
                ),
              ]
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }

  // Envío

  void _enviarReporte() async {
    final tipoMap = {
      'Servicios Públicos': 1,
      'Robo o Asalto': 2,
      'Corrupción u omisión de servidor público': 3,
      'Violencia de Género': 4,
      'Narcomenudeo': 5,
      'Reporte General': 6,
    };

    final tipoId = tipoMap[tipoReporteSeleccionado];

    Map<String, dynamic> detalle = {};

    switch (tipoId) {
      case 1:
        detalle = {
          "tipoProblema": valores['Tipo de problema'],
          "tiempoEstimadoSinAtencion": int.tryParse(valores['Tiempo estimado sin atención (Días)'] ?? ''),
        };
        break;
      case 2:
        detalle = {
          "tipoIncidente": valores['Tipo de incidente'],
          "objetosRobados": valores['Objetos robados'],
          "numeroAgresores": valores['Número de agresores'],
          "descripcionAgresores": valores['Descripción de los agresores'],
          "medioTransporteUtilizado": valores['Medio de transporte utilizado'],
          "armaUtilizada": valores['Arma utilizada'],
        };
        break;
      case 3:
        detalle = {
          "tipoFaltaReportada": valores['Tipo de falta reportada'],
          "dependencia": valores['Dependencia o institución involucrada'],
          "nombreServidor": valores['Nombre del servidor público'],
          "cargoServidor": valores['Cargo del servidor público'],
        };
        break;
      case 4:
        detalle = {
          "tipoViolencia": valores['Tipo de violencia'],
          "relacion": valores['Relación con la persona agresora'],
          "nombreAgresor": valores['Nombre o alias del agresor'],
        };
        break;
      case 5:
        detalle = {
          "tipoActividad": valores['Tipo de actividad sospechosa'],
          "numeroPersonas": valores['Número de personas involucradas'],
          "descripcionPersonas": valores['Descripción de las personas involucradas'],
          "vehiculos": valores['Vehículos relacionados'],
          "frecuencia": valores['Frecuencia del suceso'],
        };
        break;
      case 6:
        detalle = {
          "tipoSituacion": valores['Tipo de situación reportada'],
          "personas": valores['Personas o elementos involucrados'],
          "frecuencia": valores['Frecuencia o recurrencia del hecho'],
          "observaciones": valores['Observaciones adicionales'],
        };
        break;
    }

    final data = {
      "folioSUAC": valores['Folio SUAC'],
      "tipoReporteId": tipoId,
      "descripcion": 
        valores['Descripción del problema'] ??
          valores['Descripción del incidente'] ??
          valores['Descripción del hecho'] ??
          valores['Descripción del hecho o actividad'] ??
          valores['Descripción detallada del hecho'],
      "fecha": (valores['Fecha del reporte'] ??
          valores['Fecha del incidente'] ??
          valores['Fecha del hecho'] ??
          valores['Fecha del suceso'] ??
          DateTime.now()).toString(),
      "nombreCiudadano": valores['Nombre o alias del ciudadano'],
      "latitud": latitud,
      "longitud": longitud,
      "detalle": detalle,
      "evidenciaUrl": evidenciaNombre
    };

    try {
      await ApiService.createReporte(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte enviado correctamente'),
          duration: Duration(milliseconds: 900),
        ),
      );

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });

    } catch (e) {
      print("Error completo: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _tomarEvidencia() async {
    final XFile? file = await _picker.pickMedia();

    if (file == null) return;

    final fileBytes = await File(file.path).readAsBytes();

    final fileName =
        'reporte_${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    final path = fileName;

    // 🔥 subir directo a Supabase
    await supabase.storage
        .from('Evidencias')
        .uploadBinary(path, fileBytes);

    // 🔥 obtener URL pública
    final url = supabase.storage
        .from('Evidencias')
        .getPublicUrl(path);

    setState(() {
      evidenciaNombre = url;
    });
  }

  // Campos para reporte de Servicios Públicos
  List<Map<String, dynamic>> _camposServiciosPublicos() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {'tipo': 'dropdown', 'label': 'Tipo de problema',
      'opciones': [
        'Bache/socavón',
        'Alumbrado con falla',
        'Falta de señalización',
        'Obstrucción de vía',
        'Basura',
        'Fuga de agua',
        'Coladera tapada',
        'Mobiliario urbano dañado' ],},
    {'tipo': 'text', 'label': 'Descripción del problema', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del reporte'},
    {'tipo': 'text', 'label': 'Tiempo estimado sin atención (Días)'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'foto', 'label': 'Evidencia'}
  ];

  // Campos para reporte de Robo o Asalto
  List<Map<String, dynamic>> _camposRoboAsalto() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {'tipo': 'dropdown', 'label': 'Tipo de incidente',
      'opciones': [
        'Robo sin violencia',
        'Robo con violencia' ],},
    {'tipo': 'text', 'label': 'Descripción del incidente', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del incidente'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'text', 'label': 'Objetos robados', 'multiline': true},
    {'tipo': 'text', 'label': 'Número de agresores'},
    {'tipo': 'text', 'label': 'Descripción de los agresores', 'multiline': true,},
    {'tipo': 'dropdown', 'label': 'Medio de transporte utilizado',
      'opciones': [
        'A pie',
        'Bicicleta',
        'Motocicleta',
        'Automóvil' ],},
    {'tipo': 'dropdown', 'label': 'Arma utilizada', 
    'opciones': [
      'Ninguna', 
      'Cuchillo/Navaja',
      'Armas contundentes',
      'Pistola' ],},
    {'tipo': 'foto', 'label': 'Evidencia'}
  ];

  // Campos para reporte de Corrupción u Omisión
  List<Map<String, dynamic>> _camposCorrupcion() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {'tipo': 'dropdown', 'label': 'Tipo de falta reportada',
      'opciones': [
        'Soborno', 
        'Abuso de autoridad', 
        'Omisión de funciones', 
        'Tráfico de influencias', 
        'Negativa de servicio o Uso indebido de recursos' ],},
    {'tipo': 'text', 'label': 'Descripción del hecho', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del hecho'},
    {'tipo': 'text', 'label': 'Dependencia o institución involucrada'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'text', 'label': 'Nombre del servidor público'},
    {'tipo': 'text', 'label': 'Cargo del servidor público'},
    {'tipo': 'foto', 'label': 'Evidencia'}
  ];

  // Campos para reporte de Violencia de Género
  List<Map<String, dynamic>> _camposViolenciaGenero() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {'tipo': 'dropdown', 'label': 'Tipo de violencia',
      'opciones': [
        'Física',
        'Psicológica',
        'Sexual',
        'Económica',
        'Digital' ],},
    {'tipo': 'text', 'label': 'Descripción del incidente', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del incidente'},
    {'tipo': 'dropdown', 'label': 'Relación con la persona agresora',
      'opciones': [
        'Pareja actual',
        'Expareja',
        'Familiar',
        'Amigo',
        'Compañero de trabajo o escuela',
        'Desconocido' ],},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'text', 'label': 'Nombre o alias del agresor'},
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];

  // Campos para reporte de Narcomenudeo
  List<Map<String, dynamic>> _camposNarcomenudeo() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {'tipo': 'dropdown', 'label': 'Tipo de actividad sospechosa',
      'opciones': [
        'Distribución desde vehículo', 
        'Intercambio sospechoso de paquetes', 
        'Entrega rápida a transeúntes', 
        'Venta de drogas en vía pública', 
        'Puntos de venta recurrentes o Venta cerca de escuela' ],},
    {'tipo': 'text', 'label': 'Descripción del hecho o actividad', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del hecho'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'text', 'label': 'Número de personas involucradas'},
    {'tipo': 'text', 'label': 'Descripción de las personas involucradas', 'multiline': true},
    {'tipo': 'text', 'label': 'Vehículos relacionados', 'multiline': true},
    {'tipo': 'dropdown', 'label': 'Frecuencia del suceso',
      'opciones': [
        'Varias veces por semana', 
        'Fines de semana', 
        'Diario', 
        'Ocasional',
        'Cada noche' ],},
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];

  // Campos para reporte General
  List<Map<String, dynamic>> _camposReporteGeneral() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {'tipo': 'text', 'label': 'Tipo de situación reportada'},
    {'tipo': 'text', 'label': 'Descripción detallada del hecho', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del suceso'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'text', 'label': 'Personas o elementos involucrados', 'multiline': true},
    {'tipo': 'dropdown', 'label': 'Frecuencia o recurrencia del hecho',
      'opciones': [
        'Varias veces por semana', 
        'Fines de semana', 
        'Diario', 
        'Ocasional',
        'Cada noche' ],},
    {'tipo': 'text', 'label': 'Observaciones adicionales', 'multiline': true},
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];
}