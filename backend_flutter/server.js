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

app.listen(3000, () => {
  console.log('Servidor corriendo en http://localhost:3000');
});