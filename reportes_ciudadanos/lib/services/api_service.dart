import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {

  static const String baseUrl = 'http://192.168.0.22:3000';

  static Future<List<dynamic>> getReportes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reportes'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener reportes');
    }
  }

  static Future<List<dynamic>> getReportesCorrupcion() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reportescorrupcion'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener reportes de corrupción');
  }
}

  static Future<List<dynamic>> getReportesNarcomenudeo() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reportesnarcomenudeo'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener reportes de narcomenudeo');
  }
}

static Future<List<dynamic>> getReportesViolenciaGenero() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reportesviolenciagenero'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener reportes de violencia de género');
  }
}

static Future<List<dynamic>> getReportesRoboAsalto() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reportesroboasalto'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener reportes de robo o asalto');
  }
}

static Future<List<dynamic>> getReportesServiciosPublicos() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reportesserviciospublicos'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener reportes de servicios públicos');
  }
}

static Future<List<dynamic>> getReportesGenerales() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reportesgenerales'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener reportes generales');
  }
}

static Future<List<dynamic>> getInstituciones() async {
  final response = await http.get(
    Uri.parse('$baseUrl/instituciones'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener instituciones');
  }
}

static Future<List<dynamic>> getEvidencias(int reporteId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/evidencias/$reporteId'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener evidencias');
  }
}

static Future<Map<String, dynamic>> createReporte(
    Map<String, dynamic> data) async {

  final response = await http.post(
    Uri.parse('$baseUrl/crearreporte'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error: ${response.body}');
  }
}

}