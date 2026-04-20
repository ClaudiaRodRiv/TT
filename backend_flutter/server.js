const express = require('express');
const cors = require('cors');
const db = require('./db');

const app = express();

app.use(cors());
app.use(express.json());

// Endpoint base
app.get('/', (req, res) => {
  res.send('API funcionando');
});

// Todos los reportes
app.get('/reportes', (req, res) => {
  db.query('SELECT * FROM Reportes', (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error en la consulta');
      return;
    }
    res.json(result);
  });
});

// Reportes de corrupción u omisión de servidor público 
app.get('/reportescorrupcion', (req, res) => {

  const query = `
    SELECT Reportes.*, ReporteCorrupcion.*
    FROM Reportes
    INNER JOIN ReporteCorrupcion
    ON Reportes.IdReporte = ReporteCorrupcion.ReporteId;
  `;

  db.query(query, (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error en la consulta');
      return;
    }
    res.json(result);
  });
});

// Reportes de narcomenudeo
app.get('/reportesnarcomenudeo', (req, res) => {
  const query = `
    SELECT Reportes.*, ReporteNarcomenudeo.*
    FROM Reportes
    INNER JOIN ReporteNarcomenudeo
    ON Reportes.IdReporte = ReporteNarcomenudeo.ReporteId
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error en la consulta');
    } else {
      res.json(results);
    }
  });
});

// Reportes de violencia de género
app.get('/reportesviolenciagenero', (req, res) => {
  const query = `
    SELECT Reportes.*, ReporteViolenciaGenero.*
    FROM Reportes
    INNER JOIN ReporteViolenciaGenero
    ON Reportes.IdReporte = ReporteViolenciaGenero.ReporteId
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error en la consulta');
    } else {
      res.json(results);
    }
  });
});

// Reportes de robo o asalto
app.get('/reportesroboasalto', (req, res) => {
  const query = `
  SELECT Reportes.*, ReporteRoboAsalto.*
  FROM Reportes
  INNER JOIN ReporteRoboAsalto
  ON Reportes.IdReporte = ReporteRoboAsalto.ReporteId  
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error en la consulta');
    } else {
      res.json(results);
    }
  });
});

// Reportes de servicios públicos
app.get('/reportesserviciospublicos', (req, res) => {
  const query = `
  SELECT Reportes.*, ReporteServiciosPublicos.*
  FROM Reportes
  INNER JOIN ReporteServiciosPublicos
  ON Reportes.IdReporte = ReporteServiciosPublicos.ReporteId
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error en la consulta');
    } else {
      res.json(results);
    }
  });
});

// Reportes generales
app.get('/reportesgenerales', (req, res) => {
  const query = `
  SELECT Reportes.*, ReporteGeneral.*
  FROM Reportes
  INNER JOIN ReporteGeneral
  ON Reportes.IdReporte = ReporteGeneral.ReporteId
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error en la consulta');
    } else {
      res.json(results);
    }
  });
});

// Todos las instituciones
app.get('/instituciones', (req, res) => {
  db.query('SELECT * FROM Instituciones', (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error en la consulta');
      return;
    }
    res.json(result);
  });
});

// Evidencias
app.get('/evidencias/:reporteId', (req, res) => {
  const { reporteId } = req.params;

  db.query(
    'SELECT * FROM Evidencias WHERE ReporteId = ?',
    [reporteId],
    (err, result) => {
      if (err) {
        console.error(err);
        res.status(500).send('Error en la consulta');
        return;
      }
      res.json(result);
    }
  );
});

// Insertar todos los tipos de reportes
app.post('/crearreporte', (req, res) => {
  const {
    folioSUAC,
    tipoReporteId,
    descripcion,
    fecha,
    nombreCiudadano,
    latitud,
    longitud,
    detalle
  } = req.body;

  // Insertar en Reportes
  const queryReporte = `
    INSERT INTO Reportes 
    (FolioSUAC, TipoReporteId, Descripcion, Fecha, NombreCiudadano, Latitud, Longitud)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;

  db.query(
    queryReporte,
    [folioSUAC, tipoReporteId, descripcion, fecha, nombreCiudadano, latitud, longitud],
    (err, result) => {
      if (err) {
        console.error(err);
        return res.status(500).send('Error al insertar reporte');
      }

      const reporteId = result.insertId;

      // Insertar en tabla específica
      let queryDetalle = '';
      let values = [];

      switch (tipoReporteId) {
        case 1: // Servicios públicos
          queryDetalle = `
            INSERT INTO ReporteServiciosPublicos
            (ReporteId, TipoProblema, TiempoEstimadoSinAtencion)
            VALUES (?, ?, ?)
          `;
          values = [
            reporteId,
            detalle.tipoProblema,
            detalle.tiempoEstimadoSinAtencion
          ];
          break;

        case 2: // Robo o asalto
          queryDetalle = `
            INSERT INTO ReporteRoboAsalto
            (ReporteId, TipoIncidente, ObjetosRobados, NumeroAgresores, DescripcionAgresores, MedioTransporteUtilizado, ArmaUtilizada)
            VALUES (?, ?, ?, ?, ?, ?, ?)
          `;
          values = [
            reporteId,
            detalle.tipoIncidente,
            detalle.objetosRobados,
            detalle.numeroAgresores,
            detalle.descripcionAgresores,
            detalle.medioTransporteUtilizado,
            detalle.armaUtilizada
          ];
          break;

        case 3: // Corrupción
          queryDetalle = `
            INSERT INTO ReporteCorrupcion
            (ReporteId, TipoFaltaReportada, DependenciaInstitucionInvolucrada, NombreServidorPublico, CargoServidorPublico)
            VALUES (?, ?, ?, ?, ?)
          `;
          values = [
            reporteId,
            detalle.tipoFaltaReportada,
            detalle.dependencia,
            detalle.nombreServidor,
            detalle.cargoServidor
          ];
          break;

        case 4: // Violencia de género
          queryDetalle = `
            INSERT INTO ReporteViolenciaGenero
            (ReporteId, TipoViolencia, RelacionPersonaAgresora, NombreAgresor)
            VALUES (?, ?, ?, ?)
          `;
          values = [
            reporteId,
            detalle.tipoViolencia,
            detalle.relacion,
            detalle.nombreAgresor
          ];
          break;

        case 5: // Narcomenudeo
          queryDetalle = `
            INSERT INTO ReporteNarcomenudeo
            (ReporteId, TipoActividadSospechosa, NumeroPersonasInvolucradas, DescripcionPersonasInvolucradas, VehiculosRelacionados, FrecuenciaSuceso)
            VALUES (?, ?, ?, ?, ?, ?)
          `;
          values = [
            reporteId,
            detalle.tipoActividad,
            detalle.numeroPersonas,
            detalle.descripcionPersonas,
            detalle.vehiculos,
            detalle.frecuencia
          ];
          break;

        case 6: // General
          queryDetalle = `
            INSERT INTO ReporteGeneral
            (ReporteId, TipoSituacionReportada, PersonasElementosInvolucrados, FrecuenciaRecurrenciaHecho, ObservacionesAdicionales)
            VALUES (?, ?, ?, ?, ?)
          `;
          values = [
            reporteId,
            detalle.tipoSituacion,
            detalle.personas,
            detalle.frecuencia,
            detalle.observaciones
          ];
          break;

        default:
          return res.status(400).send('Tipo de reporte inválido');
      }

      // Ejecutar inserción específica
      db.query(queryDetalle, values, (err2) => {
        if (err2) {
          console.error(err2);
          return res.status(500).send('Error al insertar detalle');
        }

        res.json({
          mensaje: 'Reporte creado correctamente',
          reporteId
        });
      });
    }
  );
});

app.listen(3000, () => {
  console.log('Servidor corriendo en http://localhost:3000');
});