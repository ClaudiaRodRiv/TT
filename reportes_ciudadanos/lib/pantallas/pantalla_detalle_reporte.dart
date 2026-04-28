import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pantalla_suac.dart';
import '../services/api_service.dart';
import 'package:video_player/video_player.dart';

class DetalleReporte extends StatelessWidget {
  final Map<String, dynamic> reporte;
  final String tipo;

  const DetalleReporte({
    super.key,
    required this.reporte,
    required this.tipo,
  });

  static const paddingCard =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle del reporte',
          style:
              theme.textTheme.headlineSmall?.copyWith(color: Colors.white70),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _cabeceraReporte(tipo, theme),
            const SizedBox(height: 20),

            ...reporte.entries.map((entry) {
              if (entry.value == null || entry.value.toString().isEmpty) {
                return const SizedBox();
              }

              if ([
                'idreporte',
                'tiporeporteid',
                'latitud',
                'longitud',
                'reporteid'
              ].contains(entry.key)) {
                return const SizedBox();
              }

              return _crearCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatearCampo(entry.key),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        if (entry.key == 'foliosuac')
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copiar folio',
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: entry.value.toString()),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Folio copiado'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.value.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            FutureBuilder<List<dynamic>>(
              future: ApiService.getEvidencias(
                reporte['idreporte'] ?? reporte['reporteid'],
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text('Error al cargar evidencias');
                }

                final evidencias = snapshot.data ?? [];

                if (evidencias.isEmpty) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evidencias',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    ...evidencias.map((evidencia) {
                      final url = evidencia['urlarchivo'];
                      final esVideo = url.toString().contains('.mp4');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: esVideo
                              ? VideoPlayerWidget(url: url)
                              : Image.network(
                                  url,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Error al cargar contenido');
                                  },
                                ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaSUAC(
                      url: 'https://311locatel.cdmx.gob.mx/',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.language),
              label: const Text('Abrir SUAC / Locatel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A374D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _crearCard({required Widget child}) => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: paddingCard,
          child: child,
        ),
      );

  Widget _cabeceraReporte(String tipo, ThemeData theme) {
    final map = {
      'Servicios Públicos': [Icons.construction, Colors.blue.shade800],
      'Robo o Asalto': [Icons.lock_open, Colors.purple.shade400],
      'Corrupción u omisión de servidor público': [Icons.account_balance, Colors.pink.shade800],
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

  String _formatearCampo(String key) {
    const map = {
      // Reportes
      'idreporte': 'ID del reporte',
      'foliosuac': 'Folio SUAC',
      'tiporeporteid': 'Tipo de reporte',
      'descripcion': 'Descripción',
      'fecha': 'Fecha',
      'nombreciudadano': 'Ciudadano',
      'latitud': 'Latitud',
      'longitud': 'Longitud',

      // Instituciones
      'nombreinstitucion': 'Institución',
      'telefono': 'Teléfono',
      'correoelectronico': 'Correo electrónico',
      'horarioatencion': 'Horario de atención',
      'direccion': 'Dirección',
      'enlaceweb': 'Sitio web',

      // Servicios Públicos
      'tipoproblema': 'Tipo de problema',
      'tiempoestimadosinatencion': 'Tiempo sin atención',

      // Robo o Asalto
      'tipoincidente': 'Tipo de incidente',
      'objetosrobados': 'Objetos robados',
      'numeroagresores': 'Número de agresores',
      'descripcionagresores': 'Descripción de agresores',
      'mediotransporteutilizado': 'Medio de transporte',
      'armautilizada': 'Arma utilizada',

      // Corrupción
      'tipofaltareportada': 'Tipo de falta',
      'dependenciainstitucioninvolucrada': 'Dependencia',
      'nombreservidorpublico': 'Servidor público',
      'cargoservidorpublico': 'Cargo del servidor',

      // Violencia de Género
      'tipoviolencia': 'Tipo de violencia',
      'relacionpersonaagresora': 'Relación con agresor',
      'nombreagresor': 'Agresor',

      // Narcomenudeo
      'tipoactividadsospechosa': 'Actividad sospechosa',
      'numeropersonasinvolucradas': 'Personas involucradas',
      'descripcionpersonasinvolucradas': 'Descripción de personas',
      'vehiculosrelacionados': 'Vehículos relacionados',
      'frecuenciasuceso': 'Frecuencia',

      // Reporte General
      'tiposituacionreportada': 'Tipo de situación',
      'personaselementosinvolucrados': 'Personas involucradas',
      'frecuenciarrecurrenciahecho': 'Frecuencia',
      'observacionesadicionales': 'Observaciones',

      // Evidencias
      'urlarchivo': 'Evidencia',
    };
    return map[key] ?? key;
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    )
      ..setLooping(true)
      ..initialize().then((_) {
      setState(() {});
      controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}