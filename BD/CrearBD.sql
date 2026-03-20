-- Crear BD (DONE)
CREATE DATABASE ReportesCiudadanos;

-- Usar BD
USE ReportesCiudadanos;

-- Tabla TiposReporte (DONE)
CREATE TABLE TiposReporte (
    IdTipoReporte INT AUTO_INCREMENT PRIMARY KEY,
    NombreTipoReporte VARCHAR(50) NOT NULL
);

-- Tabla Instituciones (DONE)
CREATE TABLE Instituciones (
    IdInstitucion INT AUTO_INCREMENT PRIMARY KEY,
    NombreInstitucion VARCHAR(150) NOT NULL,
    TipoReporteId INT NOT NULL,
    Descripcion TEXT NOT NULL,
    Telefono VARCHAR(100),
    CorreoElectronico VARCHAR(100),
    HorarioAtencion VARCHAR(100),
    Direccion VARCHAR(200),
    EnlaceWeb VARCHAR(150),

    FOREIGN KEY (TipoReporteId)
    REFERENCES TiposReporte(IdTipoReporte)
);

-- Tabla Reportes (DONE)
CREATE TABLE Reportes (
    IdReporte INT AUTO_INCREMENT PRIMARY KEY,
    FolioSUAC VARCHAR(50) UNIQUE NOT NULL,
    TipoReporteId INT NOT NULL,
    Descripcion TEXT NOT NULL,
    Fecha DATETIME NOT NULL,
    NombreCiudadano VARCHAR(150),
    Latitud DECIMAL(9,6) NOT NULL,
    Longitud DECIMAL(9,6) NOT NULL,

    FOREIGN KEY (TipoReporteId)
    REFERENCES TiposReporte(IdTipoReporte)
);

-- Evidencias (DONE)
CREATE TABLE Evidencias (
    IdEvidencia INT AUTO_INCREMENT PRIMARY KEY,
    ReporteId INT NOT NULL,
    UrlArchivo VARCHAR(250) NOT NULL,

    FOREIGN KEY (ReporteId)
    REFERENCES Reportes(IdReporte)
);

-- Tabla ReporteServiciosPublicos (DONE)
CREATE TABLE ReporteServiciosPublicos (
    ReporteId INT PRIMARY KEY,
    TipoProblema VARCHAR(50) NOT NULL,
    TiempoEstimadoSinAtencion INT,

    FOREIGN KEY (ReporteId)
    REFERENCES Reportes(IdReporte)
);

-- Tabla ReporteRoboAsalto (DONE)
CREATE TABLE ReporteRoboAsalto (
    ReporteId INT PRIMARY KEY,
    TipoIncidente VARCHAR(50) NOT NULL,
    ObjetosRobados TEXT,
    NumeroAgresores INT,
    DescripcionAgresores TEXT,
    MedioTransporteUtilizado VARCHAR(50),
    ArmaUtilizada VARCHAR(50),

    FOREIGN KEY (ReporteId)
    REFERENCES Reportes(IdReporte)
);

-- Tabla ReporteCorrupcion (DONE)
CREATE TABLE ReporteCorrupcion (
    ReporteId INT PRIMARY KEY,
    TipoFaltaReportada VARCHAR(50) NOT NULL,
    DependenciaInstitucionInvolucrada VARCHAR(150) NOT NULL,
    NombreServidorPublico VARCHAR(150),
    CargoServidorPublico VARCHAR(150),

    FOREIGN KEY (ReporteId)
    REFERENCES Reportes(IdReporte)
);

-- Tabla ReporteViolenciaGenero (DONE)
CREATE TABLE ReporteViolenciaGenero (
    ReporteId INT PRIMARY KEY,
    TipoViolencia VARCHAR(50) NOT NULL,
    RelacionPersonaAgresora VARCHAR(50),
    NombreAgresor VARCHAR(150),

    FOREIGN KEY (ReporteId)
    REFERENCES Reportes(IdReporte)
);

-- Tabla ReporteNarcomenudeo (DONE)
CREATE TABLE ReporteNarcomenudeo (
    ReporteId INT PRIMARY KEY,
    TipoActividadSospechosa VARCHAR(50) NOT NULL,
    NumeroPersonasInvolucradas INT,
    DescripcionPersonasInvolucradas TEXT,
    VehiculosRelacionados TEXT,
    FrecuenciaSuceso VARCHAR(50),

    FOREIGN KEY (ReporteId)
    REFERENCES Reportes(IdReporte)
);

-- Tabla ReporteGeneral (DONE)
CREATE TABLE ReporteGeneral (
    ReporteId INT PRIMARY KEY,
    TipoSituacionReportada TEXT NOT NULL,
    PersonasElementosInvolucrados TEXT,
    FrecuenciaRecurrenciaHecho VARCHAR(50),
    ObservacionesAdicionales TEXT,

    FOREIGN KEY (ReporteId)
    REFERENCES Reportes(IdReporte)
);

-- Insertar los 6 tipos de reporte (DONE)
INSERT INTO TiposReporte (NombreTipoReporte) VALUES
('Servicios públicos'),
('Robo o asalto'),
('Corrupción u omisión de servidor público'),
('Violencia de género'),
('Narcomenudeo'),
('General');
SELECT * FROM TiposReporte;