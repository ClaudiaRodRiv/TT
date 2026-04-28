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
app.get('/reportes', async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM reportes');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Reportes de corrupción
app.get('/reportescorrupcion', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT r.*, rc.*
      FROM reportes r
      INNER JOIN reportecorrupcion rc
      ON r.idreporte = rc.reporteid
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Reportes de narcomenudeo
app.get('/reportesnarcomenudeo', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT r.*, rn.*
      FROM reportes r
      INNER JOIN reportenarcomenudeo rn
      ON r.idreporte = rn.reporteid
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Reportes violencia género
app.get('/reportesviolenciagenero', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT r.*, rv.*
      FROM reportes r
      INNER JOIN reporteviolenciagenero rv
      ON r.idreporte = rv.reporteid
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Reportes robo
app.get('/reportesroboasalto', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT r.*, rr.*
      FROM reportes r
      INNER JOIN reporteroboasalto rr
      ON r.idreporte = rr.reporteid
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Servicios públicos
app.get('/reportesserviciospublicos', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT r.*, rs.*
      FROM reportes r
      INNER JOIN reporteserviciospublicos rs
      ON r.idreporte = rs.reporteid
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Generales
app.get('/reportesgenerales', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT r.*, rg.*
      FROM reportes r
      INNER JOIN reportegeneral rg
      ON r.idreporte = rg.reporteid
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Instituciones
app.get('/instituciones', async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM instituciones');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Evidencias
app.get('/evidencias/:reporteId', async (req, res) => {
  try {
    const { reporteId } = req.params;
    const result = await db.query(
      'SELECT * FROM evidencias WHERE reporteid = $1',
      [reporteId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error en la consulta');
  }
});

// Crear reporte
app.post('/crearreporte', async (req, res) => {
  try {
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

    const result = await db.query(
      `INSERT INTO reportes
      (foliosuac, tiporeporteid, descripcion, fecha, nombreciudadano, latitud, longitud)
      VALUES ($1,$2,$3,$4,$5,$6,$7)
      RETURNING idreporte`,
      [folioSUAC, tipoReporteId, descripcion, fecha, nombreCiudadano, latitud, longitud]
    );

    const reporteId = result.rows[0].idreporte;

    let queryDetalle = '';
    let values = [];

    switch (tipoReporteId) {
      case 1:
        queryDetalle = `INSERT INTO reporteserviciospublicos VALUES ($1,$2,$3)`;
        values = [reporteId, detalle.tipoProblema, detalle.tiempoEstimadoSinAtencion];
        break;
      case 2:
        queryDetalle = `INSERT INTO reporteroboasalto VALUES ($1,$2,$3,$4,$5,$6,$7)`;
        values = [reporteId, detalle.tipoIncidente, detalle.objetosRobados, detalle.numeroAgresores, detalle.descripcionAgresores, detalle.medioTransporteUtilizado, detalle.armaUtilizada];
        break;
      case 3:
        queryDetalle = `INSERT INTO reportecorrupcion VALUES ($1,$2,$3,$4,$5)`;
        values = [reporteId, detalle.tipoFaltaReportada, detalle.dependencia, detalle.nombreServidor, detalle.cargoServidor];
        break;
      case 4:
        queryDetalle = `INSERT INTO reporteviolenciagenero VALUES ($1,$2,$3,$4)`;
        values = [reporteId, detalle.tipoViolencia, detalle.relacion, detalle.nombreAgresor];
        break;
      case 5:
        queryDetalle = `INSERT INTO reportenarcomenudeo VALUES ($1,$2,$3,$4,$5,$6)`;
        values = [reporteId, detalle.tipoActividad, detalle.numeroPersonas, detalle.descripcionPersonas, detalle.vehiculos, detalle.frecuencia];
        break;
      case 6:
        queryDetalle = `INSERT INTO reportegeneral VALUES ($1,$2,$3,$4,$5)`;
        values = [reporteId, detalle.tipoSituacion, detalle.personas, detalle.frecuencia, detalle.observaciones];
        break;
      default:
        return res.status(400).send('Tipo de reporte inválido');
    }

    await db.query(queryDetalle, values);

    res.json({ mensaje: 'Reporte creado correctamente', reporteId });
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al insertar');
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
});