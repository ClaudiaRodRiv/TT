USE ReportesCiudadanos;

SELECT * FROM Reportes;

DELETE FROM ReporteServiciosPublicos WHERE ReporteId = 10001;
DELETE FROM Reportes WHERE IdReporte = 10001;
ALTER TABLE Reportes AUTO_INCREMENT = 10001;
ALTER TABLE ReporteServiciosPublicos AUTO_INCREMENT = 10001;

SELECT Reportes.*, ReporteCorrupcion.* FROM Reportes INNER JOIN ReporteCorrupcion ON Reportes.IdReporte = ReporteCorrupcion.ReporteId;

SELECT Reportes.*, ReporteNarcomenudeo.* FROM Reportes INNER JOIN ReporteNarcomenudeo ON Reportes.IdReporte = ReporteNarcomenudeo.ReporteId;

SELECT Reportes.*, ReporteViolenciaGenero.* FROM Reportes INNER JOIN ReporteViolenciaGenero ON Reportes.IdReporte = ReporteViolenciaGenero.ReporteId;

SELECT Reportes.*, ReporteServiciosPublicos.* FROM Reportes INNER JOIN ReporteServiciosPublicos ON Reportes.IdReporte = ReporteServiciosPublicos.ReporteId;

SELECT Reportes.*, ReporteRoboAsalto.* FROM Reportes INNER JOIN ReporteRoboAsalto ON Reportes.IdReporte = ReporteRoboAsalto.ReporteId;

SELECT Reportes.*, ReporteGeneral.* FROM Reportes INNER JOIN ReporteGeneral ON Reportes.IdReporte = ReporteGeneral.ReporteId;

SELECT * FROM Instituciones;