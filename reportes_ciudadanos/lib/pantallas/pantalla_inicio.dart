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
