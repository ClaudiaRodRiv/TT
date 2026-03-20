import 'package:flutter/material.dart';

class PantallaDirectorio extends StatefulWidget {
  const PantallaDirectorio({super.key});

  @override
  State<PantallaDirectorio> createState() => _PantallaDirectorioState();
}

class _PantallaDirectorioState extends State<PantallaDirectorio> {
  final List<Map<String, String>> instituciones = [
    {
      'nombre': 'FGJCDMX - Fiscalía General de Justicia de la Ciudad de México',
      'descripcion':
          'Es la instancia para presentar la denuncia formal, solicitar seguimiento e integridad de la investigación. Ofrece atención telefónica 24/7 y la opción de Denuncia Digital para ciertos delitos.',
      'categoria': 'Violencia de Género',
      'telefono': '(55) 5200 9000',
      'correo': 'gestion_fiscal@fgjcdmx.gob.mx',
      'horario': 'Las 24 horas, los 365 días del año.',
      'direccion':
          'Calle Digna Ochoa y Plácido, Colonia Doctores, Alcaldía Cuauhtémoc, C.P. 06720, Ciudad de México.',
      'enlace': 'https://www.fgjcdmx.gob.mx',
    },
  ];

  String filtroCategoria = 'Todos';

  final List<String> categorias = [
    'Todos',
    'Servicios Públicos',
    'Robo o Asalto',
    'Corrupción u omisión de servidor público',
    'Violencia de Género',
    'Narcomenudeo',
    'Reporte General',
  ];

  final Map<String, List<dynamic>> categoriaIconosColores = {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final institucionesFiltradas = filtroCategoria == 'Todos'
        ? instituciones
        : instituciones
              .where(
                (inst) =>
                    inst['categoria']!.toLowerCase() ==
                    filtroCategoria.toLowerCase(),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Directorio de Instituciones',
          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white70),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filtroCategoria,
                      isExpanded: true,
                      style: theme.textTheme.bodyMedium,
                      items: categorias
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (valor) {
                        setState(() => filtroCategoria = valor ?? 'Todos');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: institucionesFiltradas.isEmpty
                  ? Center(
                      child: Text(
                        'No hay instituciones para esta categoría',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: institucionesFiltradas.length,
                      itemBuilder: (context, index) {
                        final inst = institucionesFiltradas[index];
                        final icono =
                            categoriaIconosColores[inst['categoria']]![0]
                                as IconData;
                        final color =
                            categoriaIconosColores[inst['categoria']]![1]
                                as Color;

                        return Card(
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: Icon(icono, color: color),
                              title: Text(
                                inst['nombre']!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                inst['categoria']!,
                                style: TextStyle(color: color),
                              ),
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          inst['descripcion']!,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 12),
                                        _filaIconoTexto(
                                          Icons.phone,
                                          inst['telefono']!,
                                          theme,
                                        ),
                                        const SizedBox(height: 6),
                                        _filaIconoTexto(
                                          Icons.email,
                                          inst['correo']!,
                                          theme,
                                        ),
                                        const SizedBox(height: 6),
                                        _filaIconoTexto(
                                          Icons.access_time,
                                          inst['horario']!,
                                          theme,
                                        ),
                                        const SizedBox(height: 6),
                                        _filaIconoTexto(
                                          Icons.location_on,
                                          inst['direccion']!,
                                          theme,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.link,
                                              size: 18,
                                              color: Colors.black87,
                                            ),
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () {},
                                              child: Text(
                                                inst['enlace']!,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaIconoTexto(IconData icono, String texto, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 18, color: Colors.black87),
        const SizedBox(width: 6),
        Expanded(child: Text(texto, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
