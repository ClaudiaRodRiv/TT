import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class PantallaReporte extends StatefulWidget {
  const PantallaReporte({super.key});
  @override
  State<PantallaReporte> createState() => _PantallaReporteState();
}

class _PantallaReporteState extends State<PantallaReporte> {
  String tipoReporteSeleccionado = 'Servicios Públicos';
  final Map<String, List<Map<String, dynamic>>> camposPorTipo = {};
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
              Padding(
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
                            .map(
                              (tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              ),
                            )
                            .toList(),
                        onChanged: (valor) =>
                            setState(() => tipoReporteSeleccionado = valor!),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _cabeceraReporte(tipoReporteSeleccionado, theme),
              const SizedBox(height: 16),
              ...camposPorTipo[tipoReporteSeleccionado]!.map(
                (campo) => _crearCampo(campo, theme),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A374D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearCard({required Widget child, VoidCallback? onTap}) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: paddingCard, child: child),
    ),
  );

  Widget _cabeceraReporte(String tipo, ThemeData theme) {
    final map = {
      'Servicios Públicos': [Icons.construction, Colors.blue.shade800],
      'Robo o Asalto': [Icons.lock_open, Colors.purple.shade400],
      'Corrupción u omisión de servidor público': [
        Icons.account_balance,
        Colors.pink.shade800,
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
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tipo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 20,
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
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    ),
  );

  Widget _crearCampo(Map<String, dynamic> campo, ThemeData theme) {
    final estiloTexto = theme.textTheme.bodyMedium;

    InputDecoration decoracion({
      required String label,
      Widget? prefixIcon,
      Widget? suffixIcon,
      EdgeInsetsGeometry? padding,
    }) => InputDecoration(
      labelText: label,
      border: InputBorder.none,
      isDense: true,
      contentPadding: padding ?? const EdgeInsets.symmetric(vertical: 12),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: estiloTexto,
      hintStyle: estiloTexto,
    );

    switch (campo['tipo']) {
      case 'text':
        return _crearCard(
          child: TextField(
            keyboardType: campo['multiline'] == true
                ? TextInputType.multiline
                : TextInputType.text,
            maxLines: campo['multiline'] == true ? null : 1,
            style: estiloTexto,
            decoration: decoracion(label: campo['label']),
          ),
        );

      case 'dropdown':
        final opciones = (campo['opciones'] as List)
            .map((e) => e.toString())
            .toList();
        return _crearCard(
          child: DropdownButtonFormField<String>(
            initialValue: null,
            decoration: decoracion(
              label: campo['label'],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            style: estiloTexto,
            isExpanded: true,
            items: opciones
                .map(
                  (o) => DropdownMenuItem(
                    value: o,
                    child: Text(o, style: estiloTexto),
                  ),
                )
                .toList(),
            onChanged: (valor) {},
          ),
        );

      case 'date':
        return _crearCard(
          child: TextField(
            readOnly: true,
            style: estiloTexto,
            decoration: decoracion(
              label: campo['label'],
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.black),
            ),
          ),
        );

      case 'foto':
        return _crearCard(
          onTap: () {},
          child: TextField(
            readOnly: true,
            style: estiloTexto,
            decoration: decoracion(
              label: campo['label'],
              prefixIcon: const Icon(Icons.camera_alt, color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
        );

      case 'subtitulo':
        return _subtitulo(campo['label'], theme);

      case 'number':
        int valorInicial = 0;
        return _crearCard(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(campo['label'], style: estiloTexto),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: NumberPicker(
                      value: valorInicial,
                      minValue: 0,
                      maxValue: 1000,
                      step: 1,
                      axis: Axis.horizontal,
                      onChanged: (valor) =>
                          setState(() => valorInicial = valor),
                    ),
                  ),
                ],
              );
            },
          ),
        );

      default:
        return const SizedBox();
    }
  }

  // Campos para reporte de Servicios Públicos
  List<Map<String, dynamic>> _camposServiciosPublicos() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {
      'tipo': 'dropdown',
      'label': 'Tipo de problema',
      'opciones': [
        'Bache/socavón',
        'Alumbrado público con falla',
        'Basura',
        'Fuga de agua',
        'Otro',
      ],
    },
    {'tipo': 'text', 'label': 'Descripción del problema', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del reporte'},
    {'tipo': 'number', 'label': 'Tiempo estimado sin atención'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];

  // Campos para reporte de Robo o Asalto
  List<Map<String, dynamic>> _camposRoboAsalto() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {
      'tipo': 'dropdown',
      'label': 'Tipo de incidente',
      'opciones': ['Robo sin violencia', 'Robo con violencia'],
    },
    {'tipo': 'text', 'label': 'Descripción del incidente', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del incidente'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'text', 'label': 'Objetos robados', 'multiline': true},
    {'tipo': 'number', 'label': 'Número de agresores'},
    {
      'tipo': 'text',
      'label': 'Descripción de los agresores',
      'multiline': true,
    },
    {
      'tipo': 'dropdown',
      'label': 'Medio de transporte utilizado',
      'opciones': ['A pie', 'Motocicleta', 'Automóvil', 'Otro'],
    },
    {
      'tipo': 'dropdown',
      'label': 'Arma utilizada',
      'opciones': ['Ninguna', 'Cuchillo', 'Pistola', 'Otro'],
    },
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];

  // Campos para reporte de Corrupción u Omisión
  List<Map<String, dynamic>> _camposCorrupcion() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {
      'tipo': 'dropdown',
      'label': 'Tipo de falta reportada',
      'opciones': ['Corrupción', 'Omisión o negligencia', 'Otro'],
    },
    {'tipo': 'text', 'label': 'Descripción del hecho', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del hecho'},
    {'tipo': 'text', 'label': 'Dependencia o institución involucrada'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'text', 'label': 'Nombre del servidor público'},
    {'tipo': 'text', 'label': 'Cargo del servidor público'},
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];

  // Campos para reporte de Violencia de Género
  List<Map<String, dynamic>> _camposViolenciaGenero() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {
      'tipo': 'dropdown',
      'label': 'Tipo de violencia',
      'opciones': [
        'Física',
        'Psicológica',
        'Sexual',
        'Económica',
        'Digital',
        'Otra',
      ],
    },
    {'tipo': 'text', 'label': 'Descripción del incidente', 'multiline': true},
    {'tipo': 'date', 'label': 'Fecha del incidente'},
    {
      'tipo': 'dropdown',
      'label': 'Relación con la persona agresora',
      'opciones': [
        'Pareja actual',
        'Expareja',
        'Familiar',
        'Compañero de trabajo o escuela',
        'Desconocido',
        'Otro',
      ],
    },
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'text', 'label': 'Nombre o alias del agresor'},
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];

  // Campos para reporte de Narcomenudeo
  List<Map<String, dynamic>> _camposNarcomenudeo() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {
      'tipo': 'dropdown',
      'label': 'Tipo de actividad sospechosa',
      'opciones': [
        'Venta de drogas',
        'Consumo en vía pública',
        'Presencia de personas armadas o vehículos sospechosos',
        'Otro',
      ],
    },
    {
      'tipo': 'text',
      'label': 'Descripción del hecho o actividad',
      'multiline': true,
    },
    {'tipo': 'date', 'label': 'Fecha del hecho'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {'tipo': 'number', 'label': 'Número de personas involucradas'},
    {
      'tipo': 'text',
      'label': 'Descripción de las personas involucradas',
      'multiline': true,
    },
    {'tipo': 'text', 'label': 'Vehículos relacionados', 'multiline': true},
    {
      'tipo': 'dropdown',
      'label': 'Frecuencia del suceso',
      'opciones': ['Único', 'Ocasional', 'Recurrente'],
    },
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];

  // Campos para reporte General
  List<Map<String, dynamic>> _camposReporteGeneral() => [
    {'tipo': 'subtitulo', 'label': 'Campos obligatorios'},
    {'tipo': 'text', 'label': 'Folio SUAC'},
    {'tipo': 'text', 'label': 'Tipo de situación reportada'},
    {
      'tipo': 'text',
      'label': 'Descripción detallada del hecho',
      'multiline': true,
    },
    {'tipo': 'date', 'label': 'Fecha del suceso'},
    {'tipo': 'subtitulo', 'label': 'Campos opcionales'},
    {'tipo': 'text', 'label': 'Nombre o alias del ciudadano'},
    {
      'tipo': 'text',
      'label': 'Personas o elementos involucrados',
      'multiline': true,
    },
    {
      'tipo': 'dropdown',
      'label': 'Frecuencia o recurrencia del hecho',
      'opciones': ['Único', 'Ocasional', 'Recurrente'],
    },
    {'tipo': 'text', 'label': 'Observaciones adicionales', 'multiline': true},
    {'tipo': 'foto', 'label': 'Evidencia'},
  ];
}
