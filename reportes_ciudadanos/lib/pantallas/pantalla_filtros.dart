import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PantallaFiltros extends StatefulWidget {
  final Map? filtrosIniciales;

  const PantallaFiltros({super.key, this.filtrosIniciales});

  @override
  State<PantallaFiltros> createState() => _PantallaFiltrosState();
}

class _PantallaFiltrosState extends State<PantallaFiltros> {

  List<dynamic> colonias = [];
  List<dynamic> resultados = [];
  TextEditingController controller = TextEditingController();
  Map<String, dynamic>? geometrySeleccionada;

  String? coloniaSeleccionada;
  String? alcaldiaSeleccionada;

  Map<String, bool> tipos = {
    'corrupcion': false,
    'narcomenudeo': false,
    'violencia': false,
    'robo': false,
    'servicios': false,
    'general': false,
  };

  @override
  void initState() {
    super.initState();
    cargarColonias();

    if (widget.filtrosIniciales != null) {
      coloniaSeleccionada = widget.filtrosIniciales!['colonia'];
      alcaldiaSeleccionada = widget.filtrosIniciales!['alcaldia'];

      final tiposIniciales = widget.filtrosIniciales!['tipos'];
      if (tiposIniciales != null) {
        tipos = Map<String, bool>.from(tiposIniciales);
      }
    }
  }

  Future<void> cargarColonias() async {
    final String data = await rootBundle.loadString('recursos/cdmx_colonias.json');
    final jsonResult = json.decode(data);

    setState(() {
      colonias = jsonResult['features'];
    });
  }

  void filtrar(String query) {
    if (colonias.isEmpty) return;

    if (query.isEmpty) {
      setState(() => resultados = []);
      return;
    }

    final filtradas = colonias.where((col) {
      final nombre = col['properties']['colonia'].toString().toLowerCase();
      return nombre.contains(query.toLowerCase());
    }).toList();

    setState(() => resultados = filtradas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Filtros',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.white70),
        ),
      ),
      body: Stack(
        children: [

          SafeArea(
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Buscar colonia...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: filtrar,
                  ),
                ),

                if (coloniaSeleccionada != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$coloniaSeleccionada (${alcaldiaSeleccionada ?? ''})',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tipos de reporte',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      filtroChip('Corrupción', 'corrupcion'),
                      filtroChip('Narcomenudeo', 'narcomenudeo'),
                      filtroChip('Violencia', 'violencia'),
                      filtroChip('Robo', 'robo'),
                      filtroChip('Servicios', 'servicios'),
                      filtroChip('General', 'general'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: resultados.isEmpty
                      ? const Center(child: Text('Escribe para buscar colonias'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: resultados.length,
                          itemBuilder: (context, index) {
                            final col = resultados[index]['properties'];
                            final item = resultados[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(col['colonia']),
                                subtitle: Text(col['alc']),
                                onTap: () {
                                  setState(() {
                                    coloniaSeleccionada = item['properties']['colonia'];
                                    alcaldiaSeleccionada = item['properties']['alc'];
                                    geometrySeleccionada = item['geometry'];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (coloniaSeleccionada != null || tipos.containsValue(true)) {
                        Navigator.pop(context, {
                          'colonia': coloniaSeleccionada,
                          'alcaldia': alcaldiaSeleccionada,
                          'geometry': geometrySeleccionada,
                          'highlight': coloniaSeleccionada != null,
                          'tipos': tipos,
                        });
                      } else {
                        Navigator.pop(context, null);
                      }
                    },
                    child: const Text('Aplicar filtros'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        coloniaSeleccionada = null;
                        alcaldiaSeleccionada = null;
                        resultados = [];
                        controller.clear();
                        tipos.updateAll((key, value) => false);
                      });

                      Navigator.pop(context, null);
                    },
                    child: const Text('Limpiar'),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget filtroChip(String label, String key) {
    return FilterChip(
      label: Text(label),
      selected: tipos[key] ?? false,
      onSelected: (value) {
        setState(() {
          tipos[key] = value;
        });
      },
    );
  }
}