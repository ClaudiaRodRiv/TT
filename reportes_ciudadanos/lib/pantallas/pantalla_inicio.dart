import 'package:flutter/material.dart';
import 'pantalla_mapa.dart';
import 'pantalla_directorio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});
  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _indiceActual = 0;
  final _pantallas = const [PantallaMapa(), PantallaDirectorio()];

  @override
  void initState() {
    super.initState();
    _mostrarAviso();
  }

Future<void> _mostrarAviso() async {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                Icons.warning_amber_rounded,
                size: 50,
                color: Colors.orange,
              ),

              const SizedBox(height: 12),

              const Text(
                'Aviso importante',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Esta no es una aplicación oficial del gobierno.\n\n'
                'Para presentar un reporte aquí, primero debiste haber realizado '
                'la denuncia correspondiente en el SUAC.\n\n'
                'Esta aplicación no canaliza ni gestiona reportes oficialmente.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _pantallas[_indiceActual],
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF1A374D),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Row(
          children: List.generate(2, (i) {
            final iconData = i == 0
                ? FontAwesomeIcons.mapLocation
                : FontAwesomeIcons.building;
            final label = i == 0 ? 'Mapa' : 'Directorio';
            final isActivo = _indiceActual == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _indiceActual = i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      iconData,
                      size: 26,
                      color: isActivo
                          ? const Color(0xFFA4DE02)
                          : Colors.white70,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        color: isActivo
                            ? const Color(0xFFA4DE02)
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
