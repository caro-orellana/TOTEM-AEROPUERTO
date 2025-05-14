-- Proyecto TOTEM AEROPUERTO
-- Topic Avanzados de Base de datos

-- Integrante: 
-- Gianfranco Astorga
-- Ernesto Starck
-- David Ñanculeo

-- Creación del usuario en Oracle

CREATE USER admin IDENTIFIED BY admin;
GRANT ALL PRIVILEGES TO admin;

-- Eliminación de tablas si existen previamente

DROP TABLE EQUIPAJE CASCADE CONSTRAINTS;
DROP TABLE CHECK_IN CASCADE CONSTRAINTS;
DROP TABLE ASISTENCIA CASCADE CONSTRAINTS;
DROP TABLE SERVICIOS_ADICIONALES CASCADE CONSTRAINTS;
DROP TABLE BOLETO CASCADE CONSTRAINTS;
DROP TABLE PASAJERO CASCADE CONSTRAINTS;
DROP TABLE VUELO CASCADE CONSTRAINTS;
DROP TABLE ASIENTOS CASCADE CONSTRAINTS;
DROP TABLE AVION CASCADE CONSTRAINTS;
DROP TABLE PUERTA CASCADE CONSTRAINTS;
DROP TABLE TERMINAL_PUERTA CASCADE CONSTRAINTS;
DROP TABLE AEROPUERTO CASCADE CONSTRAINTS;
DROP TABLE AEROLINEA CASCADE CONSTRAINTS;
DROP TABLE PAIS CASCADE CONSTRAINTS;
DROP TABLE TIPO_EQUIPAJE CASCADE CONSTRAINTS;
DROP TABLE TIPO_BOLETO CASCADE CONSTRAINTS;
DROP TABLE ESTADO CASCADE CONSTRAINTS;

-- Creación de tablas

-- Tabla Estado de Vuelo

CREATE TABLE ESTADO (
    id_estado NUMBER NOT NULL PRIMARY KEY,
    nombre_estado VARCHAR2(50) UNIQUE NOT NULL
);

-- Tabla Tipo de Boleto

CREATE TABLE TIPO_BOLETO (
    id_tipo_boleto NUMBER NOT NULL PRIMARY KEY,
    nombre_tipo_boleto VARCHAR2(50) UNIQUE NOT NULL
);

-- Tabla Tipo de Equipaje

CREATE TABLE TIPO_EQUIPAJE (
    id_tipo_equipaje NUMBER NOT NULL PRIMARY KEY,
    nombre_tipo_equipaje VARCHAR2(50) UNIQUE NOT NULL
);

-- Tabla Pais

CREATE TABLE PAIS (
    id_pais NUMBER NOT NULL PRIMARY KEY,
    nombre_pais VARCHAR2(50) NOT NULL,
    visa_requerida CHAR(1) CHECK (visa_requerida IN ('S', 'N')),
    pasaporte_requerido CHAR(1) CHECK (pasaporte_requerido IN ('S', 'N'))
);

-- Tabla Aerolinea

CREATE TABLE AEROLINEA (
    id_aerolinea NUMBER NOT NULL PRIMARY KEY,
    nombre_aerolinea VARCHAR2(50) UNIQUE NOT NULL
);

-- Tabla Aeropuerto

CREATE TABLE AEROPUERTO (
    id_aeropuerto NUMBER NOT NULL PRIMARY KEY,
    nombre_aeropuerto VARCHAR2(70) NOT NULL,
    ciudad VARCHAR2(50) NOT NULL,
    latitud NUMBER NOT NULL,
    longitud NUMBER NOT NULL,
    id_pais NUMBER NOT NULL,
    CONSTRAINT fk_pais_aeropuerto FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE,
    CONSTRAINT ck_latitud_aeropuerto CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT ck_longitud_aeropuerto CHECK (longitud BETWEEN -180 AND 180)
);

-- Tabla Terminal de Aeropuerto

CREATE TABLE TERMINAL_PUERTA (
    id_terminal NUMBER NOT NULL PRIMARY KEY,
    nombre_terminal VARCHAR2(50) NOT NULL,
    id_aeropuerto NUMBER NOT NULL,
    CONSTRAINT fk_aeropuerto_terminal FOREIGN KEY (id_aeropuerto) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE
);

-- Tabla Puerta de Embarque

CREATE TABLE PUERTA (
    id_puerta NUMBER NOT NULL PRIMARY KEY,
    nombre_puerta VARCHAR2(50) NOT NULL,
    id_terminal NUMBER NOT NULL,
    CONSTRAINT fk_terminal_puerta FOREIGN KEY (id_terminal) REFERENCES TERMINAL_PUERTA(id_terminal) ON DELETE CASCADE
);

-- Tabla Avion de Aerolinea

CREATE TABLE AVION (
    id_avion NUMBER NOT NULL PRIMARY KEY,
    nombre_avion VARCHAR2(50) NOT NULL,
    capacidad NUMBER NOT NULL,
    id_aerolinea NUMBER NOT NULL,
    CONSTRAINT fk_aerolinea_avion FOREIGN KEY (id_aerolinea) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE
);

-- Tabla Asientos
CREATE TABLE ASIENTOS (
    id_asiento NUMBER NOT NULL,
    id_avion NUMBER NOT NULL,
    fila CHAR(1) NOT NULL,
    columna NUMBER NOT NULL,
    numero_asiento AS (fila || columna),
    estado VARCHAR2(15) DEFAULT 'Disponible' CHECK (estado IN ('Disponible', 'Ocupado')),
    PRIMARY KEY (id_asiento, id_avion),
    CONSTRAINT fk_avion_asiento FOREIGN KEY (id_avion) REFERENCES AVION(id_avion) ON DELETE CASCADE
);

-- Tabla Pasajero de Vuelo

CREATE TABLE PASAJERO (
    id_pasajero NUMBER NOT NULL PRIMARY KEY,
    dni_pasajero CHAR(10) UNIQUE NOT NULL,
    nombre_pasajero VARCHAR2(50) NOT NULL,
    apellido_pasajero VARCHAR2(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    pasaporte CHAR(10) UNIQUE NOT NULL,
    visa CHAR(10) UNIQUE NOT NULL,
    correo_pasajero VARCHAR2(50) UNIQUE NOT NULL,
    telefono_pasajero CHAR(9) UNIQUE NOT NULL,
    asistencia_especial CHAR(1) CHECK (asistencia_especial IN ('S', 'N')),
    id_pais NUMBER NOT NULL,
    CONSTRAINT fk_pais_pasajero FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE
);

-- Tabla Vuelo

CREATE TABLE VUELO (
    id_vuelo NUMBER NOT NULL PRIMARY KEY,
    id_aerolinea NUMBER NOT NULL,
    fecha_salida TIMESTAMP NOT NULL,
    fecha_llegada TIMESTAMP NOT NULL,
    id_estado NUMBER NOT NULL,
    id_avion NUMBER NOT NULL,
    id_terminal NUMBER NOT NULL,
    id_puerta NUMBER NOT NULL,
    id_aeropuerto_origen NUMBER NOT NULL,
    id_aeropuerto_destino NUMBER NOT NULL,
    duracion GENERATED ALWAYS AS (EXTRACT(HOUR FROM (fecha_llegada - fecha_salida))) VIRTUAL,
    CONSTRAINT fk_aerolinea_vuelo FOREIGN KEY (id_aerolinea) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE,
    CONSTRAINT fk_estado_vuelo FOREIGN KEY (id_estado) REFERENCES ESTADO(id_estado) ON DELETE CASCADE,
    CONSTRAINT fk_avion_vuelo FOREIGN KEY (id_avion) REFERENCES AVION(id_avion) ON DELETE CASCADE,
    CONSTRAINT fk_terminal_vuelo FOREIGN KEY (id_terminal) REFERENCES TERMINAL_PUERTA(id_terminal) ON DELETE CASCADE,
    CONSTRAINT fk_puerta_vuelo FOREIGN KEY (id_puerta) REFERENCES PUERTA(id_puerta) ON DELETE CASCADE,
    CONSTRAINT fk_aeropuerto_origen_vuelo FOREIGN KEY (id_aeropuerto_origen) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE,
    CONSTRAINT fk_aeropuerto_destino_vuelo FOREIGN KEY (id_aeropuerto_destino) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE
);

-- Tabla Boleto de Vuelo

CREATE TABLE BOLETO (
    id_boleto NUMBER NOT NULL PRIMARY KEY,
    id_pasajero NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    id_tipo_boleto NUMBER NOT NULL,
    id_asiento NUMBER NOT NULL,
    id_avion NUMBER NOT NULL,
    estado VARCHAR2(15) DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Confirmado', 'Cancelado')),
    precio NUMBER NOT NULL CHECK (precio > 0),
    CONSTRAINT fk_pasajero_boleto FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT fk_asiento_boleto FOREIGN KEY (id_asiento, id_avion) REFERENCES ASIENTOS(id_asiento, id_avion) ON DELETE CASCADE,
    CONSTRAINT fk_vuelo_boleto FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT fk_tipo_boleto_boleto FOREIGN KEY (id_tipo_boleto) REFERENCES TIPO_BOLETO(id_tipo_boleto) ON DELETE CASCADE
);

-- Tabla de Servicios Adicionales

CREATE TABLE SERVICIOS_ADICIONALES (
    id_servicio NUMBER NOT NULL PRIMARY KEY,
    id_boleto NUMBER NOT NULL,
    nombre_servicio VARCHAR2(50) NOT NULL,
    precio NUMBER NOT NULL CHECK (precio > 0),
    CONSTRAINT fk_boleto_servicio FOREIGN KEY (id_boleto) REFERENCES BOLETO(id_boleto) ON DELETE CASCADE
);

-- Tabla Asistencia Especial

CREATE TABLE ASISTENCIA (
    id_asistencia NUMBER NOT NULL PRIMARY KEY,
    id_pasajero NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    nombre_asistencia VARCHAR2(50) NOT NULL,
    precio NUMBER NOT NULL CHECK (precio > 0),
    CONSTRAINT fk_pasajero_asistencia FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT fk_vuelo_asistencia FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE
);

-- Tabla CHECK-IN

CREATE TABLE CHECK_IN (
    id_checkin NUMBER NOT NULL PRIMARY KEY,
    id_boleto NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    fecha_checkin TIMESTAMP NOT NULL,
    CONSTRAINT fk_boleto_checkin FOREIGN KEY (id_boleto) REFERENCES BOLETO(id_boleto) ON DELETE CASCADE,
    CONSTRAINT fk_vuelo_checkin FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT uq_pasajero_vuelo_checkin UNIQUE (id_boleto, id_vuelo)
);

-- Tabla Equipaje de Pasajero

CREATE TABLE EQUIPAJE (
    id_equipaje NUMBER NOT NULL PRIMARY KEY,
    id_boleto NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    id_tipo_equipaje NUMBER NOT NULL,
    peso NUMBER NOT NULL,
    alto NUMBER NOT NULL,
    ancho NUMBER NOT NULL,
    largo NUMBER NOT NULL,
    precio NUMBER NOT NULL CHECK (precio > 0),
    CONSTRAINT fk_boleto_equipaje FOREIGN KEY (id_boleto) REFERENCES BOLETO(id_boleto) ON DELETE CASCADE,
    CONSTRAINT fk_vuelo_equipaje FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT fk_tipo_equipaje_equipaje FOREIGN KEY (id_tipo_equipaje) REFERENCES TIPO_EQUIPAJE(id_tipo_equipaje) ON DELETE CASCADE,
    CONSTRAINT ck_dimensiones_equipaje CHECK (peso >0 AND alto > 0 AND ancho > 0 AND largo > 0)
);

-- Insertar datos base iniciales de la base de datos

-- Insertar datos de Estado

INSERT INTO ESTADO (id_estado, nombre_estado) VALUES (1, 'En Tierra');
INSERT INTO ESTADO (id_estado, nombre_estado) VALUES (2, 'En Vuelo');
INSERT INTO ESTADO (id_estado, nombre_estado) VALUES (3, 'En Mantenimiento');
INSERT INTO ESTADO (id_estado, nombre_estado) VALUES (4, 'En Espera');
INSERT INTO ESTADO (id_estado, nombre_estado) VALUES (5, 'Cancelado');
INSERT INTO ESTADO (id_estado, nombre_estado) VALUES (6, 'Aterrizado');

-- Insertar datos de Tipo de Boleto

INSERT INTO TIPO_BOLETO (id_tipo_boleto, nombre_tipo_boleto) VALUES (1, 'Económico');
INSERT INTO TIPO_BOLETO (id_tipo_boleto, nombre_tipo_boleto) VALUES (2, 'Ejecutivo');
INSERT INTO TIPO_BOLETO (id_tipo_boleto, nombre_tipo_boleto) VALUES (3, 'Primera Clase');

-- Insertar datos de Tipo de Equipaje

INSERT INTO TIPO_EQUIPAJE (id_tipo_equipaje, nombre_tipo_equipaje) VALUES (1, 'Equipaje de Mano');
INSERT INTO TIPO_EQUIPAJE (id_tipo_equipaje, nombre_tipo_equipaje) VALUES (2, 'Equipaje de Bodega');
INSERT INTO TIPO_EQUIPAJE (id_tipo_equipaje, nombre_tipo_equipaje) VALUES (3, 'Equipaje Especial');

-- Insertar datos de País

INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (1, 'Chile', 'N', 'N');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (2, 'Argentina', 'N', 'N');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (3, 'Perú', 'N', 'N');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (4, 'Brasil', 'N', 'N');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (5, 'Estados Unidos', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (6, 'España', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (7, 'Francia', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (8, 'Alemania', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (9, 'Italia', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (10, 'China', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (11, 'Japón', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (12, 'Australia', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (13, 'Rusia', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (14, 'India', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (15, 'Sudáfrica', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (16, 'Egipto', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (17, 'México', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (18, 'Canadá', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (19, 'Reino Unido', 'S', 'S');
INSERT INTO PAIS (id_pais, nombre_pais, visa_requerida, pasaporte_requerido) VALUES (20, 'Portugal', 'S', 'S');

-- Insertar datos de Aerolínea

INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (1, 'LATAM');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (2, 'SKY');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (3, 'JetSMART');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (4, 'American Airlines');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (5, 'United Airlines');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (6, 'Delta Airlines');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (7, 'British Airways');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (8, 'Iberia');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (9, 'Air France');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (10, 'Lufthansa');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (11, 'Alitalia');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (12, 'Air China');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (13, 'ANA');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (14, 'Qantas');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (15, 'Aeroflot');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (16, 'Air India');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (17, 'South African Airways');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (18, 'EgyptAir');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (19, 'Aeroméxico');
INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea) VALUES (20, 'Air Canada');

-- Insertar datos de Aeropuerto

INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (1, 'Aeropuerto Internacional Comodoro Arturo Merino Benítez', 'Santiago', -33.393, -70.785, 1);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (2, 'Aeropuerto Internacional Ministro Pistarini', 'Buenos Aires', -34.822, -58.535, 2);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (3, 'Aeropuerto Internacional Jorge Chávez', 'Lima', -12.021, -77.114, 3);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (4, 'Aeropuerto Internacional de Guarulhos', 'Sao Paulo', -23.435, -46.473, 4);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (5, 'Aeropuerto Internacional de Miami', 'Miami', 25.795, -80.287, 5);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (6, 'Aeropuerto Internacional de Barajas', 'Madrid', 40.472, -3.560, 6);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (7, 'Aeropuerto Internacional Charles de Gaulle', 'Paris', 49.009, 2.547, 7);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (8, 'Aeropuerto Internacional de Frankfurt', 'Frankfurt', 50.033, 8.570, 8);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (9, 'Aeropuerto Internacional Leonardo da Vinci', 'Roma', 41.800, 12.238, 9);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (10, 'Aeropuerto Internacional de Pekín', 'Pekín', 40.079, 116.603, 10);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (11, 'Aeropuerto Internacional de Narita', 'Tokio', 35.771, 140.392, 11);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (12, 'Aeropuerto Internacional de Sídney', 'Sídney', -33.946, 151.177, 12);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (13, 'Aeropuerto Internacional de Sheremétievo', 'Moscú', 55.972, 37.414, 13);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (14, 'Aeropuerto Internacional Indira Gandhi', 'Nueva Delhi', 28.556, 77.100, 14);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (15, 'Aeropuerto Internacional de Ciudad del Cabo', 'Ciudad del Cabo', -33.968, 18.602, 15);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (16, 'Aeropuerto Internacional de El Cairo', 'El Cairo', 30.121, 31.405, 16);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (17, 'Aeropuerto Internacional de la Ciudad de México', 'Ciudad de México', 19.436, -99.072, 17);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (18, 'Aeropuerto Internacional de Toronto Pearson', 'Toronto', 43.681, -79.612, 18);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (19, 'Aeropuerto Internacional de Heathrow', 'Londres', 51.470, -0.454, 19);
INSERT INTO AEROPUERTO (id_aeropuerto, nombre_aeropuerto, ciudad, latitud, longitud, id_pais) VALUES (20, 'Aeropuerto Internacional de Lisboa', 'Lisboa', 38.774, -9.134, 20);

-- Insertar datos de Avión de Aerolínea

INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (1, 'Airbus A320', 180, 1);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (2, 'Boeing 737', 150, 2);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (3, 'Airbus A330', 250, 3);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (4, 'Boeing 777', 300, 4);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (5, 'Airbus A380', 500, 5);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (6, 'Boeing 787', 250, 6);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (7, 'Airbus A350', 300, 7);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (8, 'Boeing 747', 400, 8);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (9, 'Airbus A340', 250, 9);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (10, 'Boeing 767', 200, 10);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (11, 'Airbus A310', 150, 11);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (12, 'Boeing 757', 200, 12);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (13, 'Airbus A300', 150, 13);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (14, 'ATR 72', 70, 14);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (15, 'Sukhoi Superjet 100', 100, 15);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (16, 'Boeing 737 MAX', 150, 16);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (17, 'McDonnell Douglas MD-11', 200, 17);
INSERT INTO AVION (id_avion, nombre_avion, capacidad, id_aerolinea) VALUES (18, 'Concorde', 100, 18);

-- Insertar datos de Terminal de Aeropuerto

INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (1, 'Terminal Internacional', 1);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (2, 'Terminal Nacional', 1);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (3, 'Terminal A', 2);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (4, 'Terminal B', 2);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (5, 'Terminal Único', 3);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (6, 'Terminal 1', 4);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (7, 'Terminal 2', 4);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (8, 'Concourse D', 5);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (9, 'Concourse E', 5);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (10, 'Terminal T4', 6);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (11, 'Terminal 1', 7);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (12, 'Terminal 2', 7);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (13, 'Terminal Principal', 8);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (14, 'Terminal 3', 9);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (15, 'Terminal 5', 9);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (16, 'Terminal Norte', 10);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (17, 'Terminal Sur', 10);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (18, 'Terminal Este', 11);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (19, 'Terminal Oeste', 11);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (20, 'Terminal Principal', 12);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (21, 'Terminal Regional', 12);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (22, 'Terminal A', 13);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (23, 'Terminal B', 13);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (24, 'Terminal Principal', 14);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (25, 'Terminal 1', 15);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (26, 'Terminal 2', 16);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (27, 'Terminal 1', 17);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (28, 'Terminal 3', 17);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (29, 'Terminal 1', 18);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (30, 'Terminal 2', 18);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (31, 'Terminal 1', 19);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (32, 'Terminal 3', 19);
INSERT INTO TERMINAL_PUERTA (id_terminal, nombre_terminal, id_aeropuerto) VALUES (33, 'Terminal Principal', 20);

-- Insertar datos de Puerta de Embarque

-- Terminal 1 (Aeropuerto 1 - Santiago)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (1, 'Puerta A1', 1);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (2, 'Puerta A2', 1);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (3, 'Puerta A3', 1);

-- Terminal 2 (Aeropuerto 1 - Santiago)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (4, 'Puerta B1', 2);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (5, 'Puerta B2', 2);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (6, 'Puerta B3', 2);

-- Terminal 3 (Aeropuerto 2 - Buenos Aires)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (7, 'Puerta C1', 3);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (8, 'Puerta C2', 3);

-- Terminal 4 (Aeropuerto 2 - Buenos Aires)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (9, 'Puerta D1', 4);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (10, 'Puerta D2', 4);

-- Terminal 5 (Aeropuerto 3 - Lima)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (11, 'Puerta E1', 5);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (12, 'Puerta E2', 5);

-- Terminal 6 (Aeropuerto 4 - Sao Paulo)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (13, 'Puerta F1', 6);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (14, 'Puerta F2', 6);

-- Terminal 7 (Aeropuerto 4 - Sao Paulo)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (15, 'Puerta G1', 7);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (16, 'Puerta G2', 7);

-- Terminal 8 (Aeropuerto 5 - Miami)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (17, 'Puerta H1', 8);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (18, 'Puerta H2', 8);

-- Terminal 9 (Aeropuerto 5 - Miami)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (19, 'Puerta I1', 9);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (20, 'Puerta I2', 9);

-- Terminal 10 (Aeropuerto 6 - Madrid)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (21, 'Puerta J1', 10);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (22, 'Puerta J2', 10);

-- Terminal 11 (Aeropuerto 7 - París)
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (23, 'Puerta K1', 11);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (24, 'Puerta K2', 11);

-- Terminal 12 (Aeropuerto 7 - París)

INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (25, 'Puerta L1', 12);
INSERT INTO PUERTA (id_puerta, nombre_puerta, id_terminal) VALUES (26, 'Puerta L2', 12);

-- Proxima adiciones

-- Procedimiento para crear los asientos de un avión en base a su capacidad

CREATE OR REPLACE PROCEDURE sp_crear_asientos (p_id_avion IN NUMBER)
AS
    v_capacidad NUMBER;
    v_fila NUMBER;
    v_columna CHAR(1);
    v_id_asiento NUMBER := 1; -- Contador para IDs de asientos
BEGIN
    -- Obtener la capacidad del avión
    SELECT capacidad INTO v_capacidad FROM AVION WHERE id_avion = p_id_avion;

    -- Generar filas y columnas según la capacidad
    FOR v_fila IN 1..CEIL(v_capacidad / 6) LOOP -- Suponiendo 6 columnas (A-F) por fila
        FOR v_columna IN 1..6 LOOP -- Representar columnas A-F como 1-6
            INSERT INTO ASIENTOS (id_asiento, id_avion, fila, columna, estado)
            VALUES (v_id_asiento, p_id_avion, CHR(64 + v_columna), v_fila, 'Disponible'); -- 'A' = CHR(65)
            v_id_asiento := v_id_asiento + 1; -- Incrementar el ID de asiento
        END LOOP;
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontró el avión con ID = ' || p_id_avion);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

-- Ejecutar procedimiento de creación de asientos

BEGIN
    sp_crear_asientos(1);
    sp_crear_asientos(2);
    sp_crear_asientos(3);
    sp_crear_asientos(4);
    sp_crear_asientos(5);
    sp_crear_asientos(6);
    sp_crear_asientos(7);
    sp_crear_asientos(8);
    sp_crear_asientos(9);
    sp_crear_asientos(10);
    sp_crear_asientos(11);
    sp_crear_asientos(12);
    sp_crear_asientos(13);
    sp_crear_asientos(14);
    sp_crear_asientos(15);
    sp_crear_asientos(16);
    sp_crear_asientos(17);
    sp_crear_asientos(18);
END;
/

-- Triggers

-- Triggers de Validación

-- Validación del peso y dimensiones del equipaje

CREATE OR REPLACE TRIGGER ck_equipaje
BEFORE INSERT OR UPDATE OF peso, alto, ancho, largo ON EQUIPAJE
FOR EACH ROW
BEGIN
    IF :NEW.peso <= 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'El peso del equipaje debe ser mayor a 0.');
    END IF;
    IF :NEW.alto <= 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'La altura del equipaje debe ser mayor a 0.');
    END IF;
    IF :NEW.ancho <= 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'El ancho del equipaje debe ser mayor a 0.');
    END IF;
    IF :NEW.largo <= 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'El largo del equipaje debe ser mayor a 0.');
    END IF;
END;
/

-- Validación de la visa y pasaporte del pasajero

CREATE OR REPLACE TRIGGER ck_pasajero
BEFORE INSERT OR UPDATE OF visa, pasaporte ON PASAJERO
FOR EACH ROW
BEGIN
    IF :NEW.visa = 'S' AND :NEW.pasaporte = 'N' THEN
        RAISE_APPLICATION_ERROR(-20000, 'Si el pasajero requiere visa, también debe tener pasaporte.');
    END IF;
END;
/

-- Restricción de duplicados en el check-in por boleto

CREATE OR REPLACE TRIGGER uq_checkin
BEFORE INSERT OR UPDATE OF id_boleto, id_vuelo ON CHECK_IN
FOR EACH ROW
DECLARE
    v_estado VARCHAR2(15);
BEGIN
    SELECT estado INTO v_estado
    FROM BOLETO
    WHERE id_boleto = :NEW.id_boleto;

    IF v_estado = 'Confirmado' THEN
        RAISE_APPLICATION_ERROR(-20000, 'El pasajero ya realizó el check-in para este vuelo.');
    END IF;
END;
/

ALTER TRIGGER uq_checkin DISABLE;


-- Bloquear cambios en los datos del vuelo después de su despegue

CREATE OR REPLACE TRIGGER tg_bloquear_cambios_vuelo
BEFORE UPDATE ON VUELO
FOR EACH ROW
BEGIN
    IF :OLD.id_estado IN (2, 6) AND :NEW.id_estado != 5 THEN -- "En Vuelo" o "Aterrizado"
        RAISE_APPLICATION_ERROR(-20002, 'No se puede modificar un vuelo que ya está en curso o finalizado.');
    END IF;
END;
/

-- Evitar duplicados en los servicios adicionales por boleto

CREATE OR REPLACE TRIGGER tg_servicio_unico
BEFORE INSERT ON SERVICIOS_ADICIONALES
FOR EACH ROW
DECLARE
    v_servicio_existente NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_servicio_existente 
    FROM SERVICIOS_ADICIONALES
    WHERE id_boleto = :NEW.id_boleto AND nombre_servicio = :NEW.nombre_servicio;

    IF v_servicio_existente > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'El servicio ya está registrado para este boleto.');
    END IF;
END;
/

-- Triggers de actualización automática

-- Actualización del estado del vuelo según la hora actual

CREATE OR REPLACE TRIGGER tg_estado_vuelo
BEFORE INSERT OR UPDATE OF fecha_salida, fecha_llegada ON VUELO
FOR EACH ROW
BEGIN
    IF :NEW.fecha_salida IS NOT NULL AND :NEW.fecha_llegada IS NOT NULL THEN
        IF :NEW.fecha_salida < SYSDATE THEN
            :NEW.id_estado := 2;
        ELSIF :NEW.fecha_salida > SYSDATE THEN
            :NEW.id_estado := 4;
        ELSIF :NEW.fecha_llegada < SYSDATE THEN
            :NEW.id_estado := 6;
        END IF;
    END IF;
END;
/

-- Actualizar el estado del asiento

CREATE OR REPLACE TRIGGER actualizar_estado_asiento
AFTER INSERT OR UPDATE ON BOLETO
FOR EACH ROW
BEGIN
    IF :NEW.id_asiento IS NOT NULL THEN
        UPDATE ASIENTOS
        SET estado = 'Ocupado'
        WHERE id_asiento = :NEW.id_asiento;
    END IF;
END;
/

-- Actualizar el estado del asiento al cancelar un boleto

CREATE OR REPLACE TRIGGER tg_asiento_disponible
AFTER DELETE OR UPDATE OF id_asiento ON BOLETO
FOR EACH ROW
BEGIN
    UPDATE ASIENTOS
    SET estado = 'Disponible'
    WHERE id_asiento = :OLD.id_asiento AND id_avion = :OLD.id_avion;
END;
/

-- Actualizar el estado del boleto al realizar el check-in

CREATE OR REPLACE TRIGGER tg_checkin
AFTER INSERT ON CHECK_IN
FOR EACH ROW
BEGIN
    UPDATE BOLETO
    SET estado = 'Confirmado'
    WHERE id_boleto = :NEW.id_boleto;
END;
/

-- Evitar vuelos duplicados en la misma fecha, hora y avion

CREATE OR REPLACE TRIGGER tg_validar_vuelo_unico
BEFORE INSERT ON VUELO
FOR EACH ROW
DECLARE
    v_existente NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existente
    FROM VUELO
    WHERE id_avion = :NEW.id_avion
    AND id_aeropuerto_origen = :NEW.id_aeropuerto_origen
    AND id_aeropuerto_destino = :NEW.id_aeropuerto_destino
    AND TRUNC(fecha_salida) = TRUNC(:NEW.fecha_salida);

    IF v_existente > 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Ya existe un vuelo con este avión y destino en la misma fecha.');
    END IF;
END;
/

-- Control para asignar un asiento 
CREATE OR REPLACE TRIGGER tg_actualizar_estado_asiento
AFTER INSERT OR UPDATE OF id_asiento ON BOLETO
FOR EACH ROW
BEGIN
    -- Actualizar el estado del asiento a "Ocupado" si se asigna a un boleto
    IF :NEW.id_asiento IS NOT NULL THEN
        UPDATE ASIENTOS
        SET estado = 'Ocupado'
        WHERE id_asiento = :NEW.id_asiento AND id_avion = :NEW.id_avion;
    END IF;

    -- Liberar el asiento si se elimina el registro del boleto o se cambia el asiento
    IF :OLD.id_asiento IS NOT NULL AND :OLD.id_asiento != :NEW.id_asiento THEN
        UPDATE ASIENTOS
        SET estado = 'Disponible'
        WHERE id_asiento = :OLD.id_asiento AND id_avion = :OLD.id_avion;
    END IF;
END;
/

-- Control de cancelacion de vuelo y boletos asociados

CREATE OR REPLACE TRIGGER tg_cancelar_boletos_vuelo
AFTER UPDATE OF id_estado ON VUELO
FOR EACH ROW
BEGIN
    IF :NEW.id_estado = 5 THEN
        UPDATE BOLETO
        SET estado = 'Cancelado'
        WHERE id_vuelo = :NEW.id_vuelo;
    END IF;
END;
/

-- Aumentar el precio del boleto si el equipaje de mano, bodega y especial exceden el peso permitido

CREATE OR REPLACE TRIGGER tg_precio_equipaje
BEFORE INSERT OR UPDATE OF id_boleto ON EQUIPAJE
FOR EACH ROW
DECLARE
    v_peso_total NUMBER;
    v_precio_total NUMBER;
BEGIN
    SELECT SUM(peso) INTO v_peso_total
    FROM EQUIPAJE
    WHERE id_boleto = :NEW.id_boleto;

    IF v_peso_total > 15 THEN
        SELECT precio INTO v_precio_total
        FROM BOLETO
        WHERE id_boleto = :NEW.id_boleto;

        IF v_peso_total > 15 AND v_peso_total <= 20 THEN
            :NEW.precio := v_precio_total + 50;
        ELSIF v_peso_total > 20 AND v_peso_total <= 25 THEN
            :NEW.precio := v_precio_total + 100;
        ELSIF v_peso_total > 25 THEN
            :NEW.precio := v_precio_total + 150;
        END IF;
    END IF;
END;
/

-- Actualizar el precio del boleto al agregar servicios adicionales

CREATE OR REPLACE TRIGGER tg_precio_servicios
AFTER INSERT ON SERVICIOS_ADICIONALES
FOR EACH ROW
BEGIN
    UPDATE BOLETO
    SET precio = precio + :NEW.precio
    WHERE id_boleto = :NEW.id_boleto;
END;
/

-- Procedimientos

-- Procedimiento para registrar el check-in del boleto y cambiar su estado

CREATE OR REPLACE PROCEDURE SP_CHECKIN (
    p_id_boleto IN NUMBER
) AS
    v_id_vuelo NUMBER;
    v_id_checkin NUMBER;
    v_asiento_actual NUMBER;
    v_asiento_boleto NUMBER;
BEGIN
    -- Verificar si el boleto existe
    BEGIN
        SELECT id_vuelo, id_asiento INTO v_id_vuelo, v_asiento_boleto
        FROM BOLETO
        WHERE id_boleto = p_id_boleto;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'El boleto especificado no existe.');
    END;

    -- Verificar si ya existe un check-in para el mismo vuelo y boleto
    BEGIN
        SELECT id_checkin INTO v_id_checkin
        FROM CHECK_IN
        WHERE id_boleto = p_id_boleto AND id_vuelo = v_id_vuelo;

        -- Si existe, verificar si el asiento cambió
        SELECT id_asiento INTO v_asiento_actual
        FROM BOLETO
        WHERE id_boleto = p_id_boleto;

        IF v_asiento_actual = v_asiento_boleto THEN
            RAISE_APPLICATION_ERROR(-20015, 'El pasajero ya realizó el check-in para este asiento.');
        ELSE
            -- Actualizar la fecha del check-in al cambiar el asiento
            UPDATE CHECK_IN
            SET fecha_checkin = SYSDATE
            WHERE id_checkin = v_id_checkin;

            -- Actualizar el estado del boleto
            UPDATE BOLETO
            SET estado = 'Confirmado'
            WHERE id_boleto = p_id_boleto;

            COMMIT;
            RETURN;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Si no existe, proceder con el nuevo check-in
            NULL;
    END;

    -- Generar un nuevo ID para el check-in
    SELECT NVL(MAX(id_checkin), 0) + 1 INTO v_id_checkin
    FROM CHECK_IN;

    -- Insertar el nuevo registro de check-in
    INSERT INTO CHECK_IN (id_checkin, id_boleto, id_vuelo, fecha_checkin)
    VALUES (v_id_checkin, p_id_boleto, v_id_vuelo, SYSDATE);

    -- Actualizar el estado del boleto
    UPDATE BOLETO
    SET estado = 'Confirmado'
    WHERE id_boleto = p_id_boleto;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/





CREATE OR REPLACE PROCEDURE sp_cambiar_asiento (
    p_id_boleto IN NUMBER,
    p_id_asiento_nuevo IN NUMBER
) AS
    v_id_vuelo NUMBER;
    v_id_avion NUMBER;
    v_estado_asiento VARCHAR2(15);
    v_asiento_actual NUMBER;
    v_asiento_ocupado NUMBER;
BEGIN
    -- 1. Obtener el vuelo, avión y asiento actual asociado al boleto
    SELECT id_vuelo, id_avion, id_asiento
    INTO v_id_vuelo, v_id_avion, v_asiento_actual
    FROM BOLETO
    WHERE id_boleto = p_id_boleto;

    -- 2. Validar que el nuevo asiento no sea el mismo que el actual
    IF v_asiento_actual = p_id_asiento_nuevo THEN
        RAISE_APPLICATION_ERROR(-20012, 'El asiento solicitado ya está asignado a este boleto.');
    END IF;

    -- 3. Verificar que el asiento nuevo esté disponible
    SELECT estado
    INTO v_estado_asiento
    FROM ASIENTOS
    WHERE id_asiento = p_id_asiento_nuevo AND id_avion = v_id_avion;

    IF v_estado_asiento != 'Disponible' THEN
        RAISE_APPLICATION_ERROR(-20010, 'El asiento solicitado no está disponible.');
    END IF;

    -- 4. Validar que el asiento no esté asignado a otro boleto del mismo vuelo
    SELECT COUNT(*)
    INTO v_asiento_ocupado
    FROM BOLETO
    WHERE id_asiento = p_id_asiento_nuevo AND id_vuelo = v_id_vuelo;

    IF v_asiento_ocupado > 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'El asiento solicitado ya está asignado a otro boleto.');
    END IF;

    -- 5. Liberar el asiento actual (si existe)
    IF v_asiento_actual IS NOT NULL THEN
        UPDATE ASIENTOS
        SET estado = 'Disponible'
        WHERE id_asiento = v_asiento_actual AND id_avion = v_id_avion;
    END IF;

    -- 6. Actualizar el boleto con el nuevo asiento
    UPDATE BOLETO
    SET id_asiento = p_id_asiento_nuevo
    WHERE id_boleto = p_id_boleto;

    -- 7. Marcar el nuevo asiento como ocupado
    UPDATE ASIENTOS
    SET estado = 'Ocupado'
    WHERE id_asiento = p_id_asiento_nuevo AND id_avion = v_id_avion;

    -- Confirmar los cambios
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'No se encontró el boleto o el asiento especificado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, 'Error inesperado: ' || SQLERRM);
END;
/



-- Procedimiento para obtener los asientos disponibles de un vuelo
CREATE OR REPLACE PROCEDURE sp_asientos_disponibles (
    p_id_vuelo IN NUMBER,
    o_asientos OUT SYS_REFCURSOR
) AS
BEGIN
    -- Obtener el ID del avión asociado al vuelo
    DECLARE
        v_id_avion NUMBER;
    BEGIN
        SELECT id_avion INTO v_id_avion
        FROM VUELO
        WHERE id_vuelo = p_id_vuelo;

        -- Abrir un cursor con los asientos disponibles
        OPEN o_asientos FOR
        SELECT id_asiento, numero_asiento
        FROM ASIENTOS
        WHERE id_avion = v_id_avion AND estado = 'Disponible';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'No se encontró un avión para el vuelo proporcionado.');
    END;
END;
/


-- Procedimiento para obtener los vuelos disponibles

CREATE OR REPLACE PROCEDURE sp_vuelos_disponibles (p_origen IN VARCHAR2, p_destino IN VARCHAR2, p_fecha_salida IN DATE)
AS
    v_id_origen NUMBER;
    v_id_destino NUMBER;
    CURSOR c_vuelos IS
        SELECT v.id_vuelo, a.nombre_aerolinea, v.fecha_salida, v.fecha_llegada
        FROM VUELO v
        JOIN AEROLINEA a ON v.id_aerolinea = a.id_aerolinea
        WHERE v.id_aeropuerto_origen = v_id_origen
        AND v.id_aeropuerto_destino = v_id_destino
        AND v.fecha_salida >= p_fecha_salida;
    r_vuelo c_vuelos%ROWTYPE;
BEGIN
    -- Obtener los IDs de los aeropuertos de origen y destino
    SELECT id_aeropuerto INTO v_id_origen
    FROM AEROPUERTO
    WHERE ciudad = p_origen;

    SELECT id_aeropuerto INTO v_id_destino
    FROM AEROPUERTO
    WHERE ciudad = p_destino;

    -- Mostrar los vuelos disponibles
    OPEN c_vuelos;
    LOOP
        FETCH c_vuelos INTO r_vuelo;
        EXIT WHEN c_vuelos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Vuelo ID: ' || r_vuelo.id_vuelo || ', Aerolínea: ' || r_vuelo.nombre_aerolinea || ', Fecha de Salida: ' || r_vuelo.fecha_salida || ', Fecha de Llegada: ' || r_vuelo.fecha_llegada);
    END LOOP;
    CLOSE c_vuelos;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para generar el itinerario de un pasajero

CREATE OR REPLACE PROCEDURE sp_itinerario_pasajero (
    p_id_pasajero IN NUMBER,
    o_itinerario OUT SYS_REFCURSOR
) AS
BEGIN
    -- Validar que el pasajero exista antes de abrir el cursor
    DECLARE
        v_existe_pasajero NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_existe_pasajero
        FROM PASAJERO
        WHERE id_pasajero = p_id_pasajero;

        IF v_existe_pasajero = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El ID del pasajero no existe.');
        END IF;
    END;

    -- Abrir el cursor para devolver los datos del itinerario
    OPEN o_itinerario FOR
        SELECT 
            p.nombre_pasajero || ' ' || p.apellido_pasajero AS pasajero,
            SUBSTR(p.dni_pasajero, 1, 2) || '.' || SUBSTR(p.dni_pasajero, 3, 3) || '.' || SUBSTR(p.dni_pasajero, 6, 3) || '-' || SUBSTR(p.dni_pasajero, 9, 1) AS dni,
            b.id_boleto AS boleto,
            v.id_vuelo AS vuelo,
            TO_CHAR(v.fecha_salida, 'YYYY-MM-DD') AS fecha_salida,
            TO_CHAR(v.fecha_salida, 'HH24:MI:SS') AS hora_salida,
            TO_CHAR(v.fecha_llegada, 'YYYY-MM-DD') AS fecha_llegada,
            TO_CHAR(v.fecha_llegada, 'HH24:MI:SS') AS hora_llegada,
            ao.ciudad AS ciudad_origen,
            ad.ciudad AS ciudad_destino,
            a.numero_asiento AS asiento,
            t.nombre_terminal AS terminal,
            pu.nombre_puerta AS puerta,
            b.estado AS estado_boleto
        FROM BOLETO b
        JOIN PASAJERO p ON b.id_pasajero = p.id_pasajero
        JOIN VUELO v ON b.id_vuelo = v.id_vuelo
        JOIN AEROPUERTO ao ON v.id_aeropuerto_origen = ao.id_aeropuerto
        JOIN AEROPUERTO ad ON v.id_aeropuerto_destino = ad.id_aeropuerto
        JOIN ASIENTOS a ON b.id_asiento = a.id_asiento AND b.id_avion = a.id_avion
        JOIN TERMINAL_PUERTA t ON v.id_terminal = t.id_terminal
        JOIN PUERTA pu ON v.id_puerta = pu.id_puerta
        WHERE b.id_pasajero = p_id_pasajero;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No se encontró ningún itinerario asociado al pasajero.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error inesperado: ' || SQLERRM);
END;
/



-- Procedimiento para registrar servicios adicionales en masa

CREATE OR REPLACE PROCEDURE sp_registrar_servicios (p_id_boleto IN NUMBER, p_servicios IN SYS.ODCIVARCHAR2LIST)
AS
    v_servicio VARCHAR2(50);
BEGIN
    FOR i IN 1..p_servicios.COUNT LOOP
        v_servicio := p_servicios(i);

        INSERT INTO SERVICIOS_ADICIONALES (id_boleto, nombre_servicio, precio)
        VALUES (p_id_boleto, v_servicio, 0);
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para Obtener ocupacion del vuelo

CREATE OR REPLACE PROCEDURE sp_ocupacion_vuelo (p_id_vuelo IN NUMBER)
AS
    v_capacidad NUMBER;
    v_ocupacion NUMBER;
BEGIN
    -- Obtener la capacidad del avión
    SELECT capacidad INTO v_capacidad
    FROM AVION
    WHERE id_avion = (
        SELECT id_avion
        FROM VUELO
        WHERE id_vuelo = p_id_vuelo
    );

    -- Obtener la ocupación del vuelo
    SELECT COUNT(*) INTO v_ocupacion
    FROM BOLETO
    WHERE id_vuelo = p_id_vuelo;

    DBMS_OUTPUT.PUT_LINE('Ocupación del vuelo: ' || v_ocupacion || '/' || v_capacidad);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para registrar equipaje para un pasajero

CREATE OR REPLACE PROCEDURE sp_registrar_equipaje (p_id_boleto IN NUMBER, p_equipajes IN SYS.ODCINUMBERLIST, p_pesos IN SYS.ODCINUMBERLIST)
AS
BEGIN
    FOR i IN 1..p_equipajes.COUNT LOOP
        INSERT INTO EQUIPAJE (id_boleto, id_tipo_equipaje, peso, precio)
        VALUES (p_id_boleto, p_equipajes(i), p_pesos(i), p_pesos(i) * 10); -- Precio basado en peso
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para cancelar un vuelo y sus boletos asociados

CREATE OR REPLACE PROCEDURE sp_cancelar_vuelo (p_id_vuelo IN NUMBER)
AS
BEGIN
    UPDATE VUELO
    SET id_estado = 5
    WHERE id_vuelo = p_id_vuelo;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para ingresar vuelos

CREATE OR REPLACE PROCEDURE sp_ingresar_vuelo (p_id_vuelo IN NUMBER, p_id_aerolinea IN NUMBER, p_id_avion IN NUMBER, p_id_aeropuerto_origen IN NUMBER, p_id_aeropuerto_destino IN NUMBER, p_id_terminal IN NUMBER, p_id_puerta IN NUMBER, p_fecha_salida IN DATE, p_fecha_llegada IN DATE, p_id_estado IN NUMBER)
AS
BEGIN
    INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado)
    VALUES (p_id_vuelo, p_id_aerolinea, p_id_avion, p_id_aeropuerto_origen, p_id_aeropuerto_destino, p_id_terminal, p_id_puerta, p_fecha_salida, p_fecha_llegada, p_id_estado);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para ingresar pasajeros

CREATE OR REPLACE PROCEDURE sp_ingresar_pasajero (p_id_pasajero IN NUMBER, p_nombre_pasajero IN VARCHAR2, p_pasaporte IN VARCHAR2, p_visa IN VARCHAR2)
AS
BEGIN
    INSERT INTO PASAJERO (id_pasajero, nombre_pasajero, pasaporte, visa)
    VALUES (p_id_pasajero, p_nombre_pasajero, p_pasaporte, p_visa);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para ingresar boletos

CREATE OR REPLACE PROCEDURE sp_ingresar_boleto (p_id_boleto IN NUMBER, p_id_pasajero IN NUMBER, p_id_vuelo IN NUMBER, p_id_asiento IN NUMBER, p_precio IN NUMBER, p_estado IN VARCHAR2)
AS
BEGIN
    INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_asiento, precio, estado)
    VALUES (p_id_boleto, p_id_pasajero, p_id_vuelo, p_id_asiento, p_precio, p_estado);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para ingresar servicios adicionales

CREATE OR REPLACE PROCEDURE sp_ingresar_servicio (p_id_boleto IN NUMBER, p_nombre_servicio IN VARCHAR2, p_precio IN NUMBER)
AS
BEGIN
    INSERT INTO SERVICIOS_ADICIONALES (id_boleto, nombre_servicio, precio)
    VALUES (p_id_boleto, p_nombre_servicio, p_precio);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/



-- Insertar datos en la tabla vuelo

INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (1, 1, 1, 1, 2, 1, 1, TO_DATE('2024-12-04 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-12-04 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (2, 2, 2, 2, 3, 3, 7, SYSDATE + INTERVAL '1' DAY, SYSDATE + INTERVAL '1' DAY + INTERVAL '2' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (3, 3, 3, 3, 4, 5, 13, SYSDATE + INTERVAL '2' DAY, SYSDATE + INTERVAL '2' DAY + INTERVAL '3' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (4, 4, 4, 4, 5, 6, 17, SYSDATE + INTERVAL '3' DAY, SYSDATE + INTERVAL '3' DAY + INTERVAL '4' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (5, 5, 5, 5, 6, 8, 21, SYSDATE + INTERVAL '4' DAY, SYSDATE + INTERVAL '4' DAY + INTERVAL '5' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (6, 6, 6, 6, 7, 10, 25, SYSDATE + INTERVAL '5' DAY, SYSDATE + INTERVAL '5' DAY + INTERVAL '6' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (10, 10, 10, 10, 11, 16, 1, SYSDATE + INTERVAL '9' DAY, SYSDATE + INTERVAL '9' DAY + INTERVAL '10' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (11, 11, 11, 11, 12, 18, 2, SYSDATE + INTERVAL '10' DAY, SYSDATE + INTERVAL '10' DAY + INTERVAL '11' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (12, 12, 12, 12, 13, 20, 3, SYSDATE + INTERVAL '11' DAY, SYSDATE + INTERVAL '11' DAY + INTERVAL '12' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (13, 13, 13, 13, 14, 22, 4, SYSDATE + INTERVAL '12' DAY, SYSDATE + INTERVAL '12' DAY + INTERVAL '13' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (14, 14, 14, 14, 15, 24, 5, SYSDATE + INTERVAL '13' DAY, SYSDATE + INTERVAL '13' DAY + INTERVAL '14' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (15, 15, 15, 15, 16, 26, 6, SYSDATE + INTERVAL '14' DAY, SYSDATE + INTERVAL '14' DAY + INTERVAL '15' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (16, 16, 16, 16, 17, 27, 7, SYSDATE + INTERVAL '15' DAY, SYSDATE + INTERVAL '15' DAY + INTERVAL '16' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (17, 17, 17, 17, 18, 29, 8, SYSDATE + INTERVAL '16' DAY, SYSDATE + INTERVAL '16' DAY + INTERVAL '17' HOUR, 1);
INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, id_terminal, id_puerta, fecha_salida, fecha_llegada, id_estado) VALUES (18, 18, 18, 18, 19, 31, 9, SYSDATE + INTERVAL '17' DAY, SYSDATE + INTERVAL '17' DAY + INTERVAL '18' HOUR, 1);

-- Insertar datos en la tabla pasaajero

INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (1, '123456789', 'Juan', 'Perez', TO_DATE('1990-01-01', 'YYYY-MM-DD'), '24515488', '78451548', 'g.g@gmail.com', '12345678', 'N', 1);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (2, '234567890', 'Ana', 'Gomez', TO_DATE('1985-02-15', 'YYYY-MM-DD'), '34567890', '12345678', 'ana.gomez@gmail.com', '23456789', 'N', 2);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (3, '345678901', 'Luis', 'Martinez', TO_DATE('1978-03-20', 'YYYY-MM-DD'), '45678901', '23456789', 'luis.martinez@gmail.com', '34567890', 'N', 3);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (4, '456789012', 'Maria', 'Lopez', TO_DATE('1992-04-25', 'YYYY-MM-DD'), '56789012', '34567890', 'maria.lopez@gmail.com', '45678901', 'N', 4);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (5, '567890123', 'Carlos', 'Rodriguez', TO_DATE('1980-05-30', 'YYYY-MM-DD'), '67890123', '45678901', 'carlos.rodriguez@gmail.com', '56789012', 'N', 5);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (6, '678901234', 'Laura', 'Fernandez', TO_DATE('1988-06-10', 'YYYY-MM-DD'), '78901234', '56789012', 'laura.fernandez@gmail.com', '67890123', 'N', 6);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (7, '789012345', 'Jorge', 'Perez', TO_DATE('1995-07-15', 'YYYY-MM-DD'), '89012345', '67890123', 'jorge.perez@gmail.com', '78901234', 'N', 7);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (8, '890123456', 'Sofia', 'Gonzalez', TO_DATE('1983-08-20', 'YYYY-MM-DD'), '90123456', '78901234', 'sofia.gonzalez@gmail.com', '89012345', 'N', 8);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (9, '901234567', 'Miguel', 'Diaz', TO_DATE('1975-09-25', 'YYYY-MM-DD'), '01234567', '89012345', 'miguel.diaz@gmail.com', '90123456', 'N', 9);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (10, '012345678', 'Elena', 'Ramirez', TO_DATE('1990-10-30', 'YYYY-MM-DD'), '12345678', '90123456', 'elena.ramirez@gmail.com', '01234567', 'N', 10);
INSERT INTO PASAJERO (id_pasajero, dni_pasajero, nombre_pasajero, apellido_pasajero, fecha_nacimiento, pasaporte, visa, correo_pasajero, telefono_pasajero, asistencia_especial, id_pais) VALUES (11, '202456731', 'Gianfranco', 'Astorga', TO_DATE('2000-05-24', 'YYYY-MM-DD'), '23456789', '01234567', 'gianastorga11@gmail.com', '976177521', 'N', 11);


-- Insertar datos en la tabla boleto

INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (1, 1, 1, 1, 1, 1, 'Pendiente', 100000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (2, 2, 2, 2, 2, 2, 'Pendiente', 200000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (3, 3, 3, 3, 3, 3, 'Pendiente', 300000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (4, 4, 4, 1, 4, 4, 'Pendiente', 400000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (5, 5, 5, 2, 5, 5, 'Pendiente', 500000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (6, 6, 6, 3, 6, 6, 'Pendiente', 600000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (7, 7, 1, 1, 7, 7, 'Pendiente', 700000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (8, 8, 3, 2, 8, 8, 'Pendiente', 800000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (9, 9, 3, 3, 9, 9, 'Pendiente', 900000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (10, 10, 10, 1, 10, 10, 'Pendiente', 1000000);
INSERT INTO BOLETO (id_boleto, id_pasajero, id_vuelo, id_tipo_boleto, id_asiento, id_avion, estado, precio) VALUES (11, 11, 1, 1, 2, 1, 'Pendiente', 1000000);

-- Insertar datos en la tabla servicios adicionales

INSERT INTO SERVICIOS_ADICIONALES (id_servicio, id_boleto, nombre_servicio, precio) VALUES (1, 1, 'Wifi', 10);

-- Insertar datos en la tabla equipaje

INSERT INTO EQUIPAJE (id_equipaje, id_boleto, id_vuelo, id_tipo_equipaje, peso, alto, ancho, largo, precio) VALUES (1, 1, 1, 1, 15, 50, 30, 20, 150);
INSERT INTO EQUIPAJE (id_equipaje, id_boleto, id_vuelo, id_tipo_equipaje, peso, alto, ancho, largo, precio) VALUES (2, 2, 2, 2, 20, 60, 40, 30, 200);
INSERT INTO EQUIPAJE (id_equipaje, id_boleto, id_vuelo, id_tipo_equipaje, peso, alto, ancho, largo, precio) VALUES (3, 3, 3, 3, 25, 70, 50, 40, 250);
INSERT INTO EQUIPAJE (id_equipaje, id_boleto, id_vuelo, id_tipo_equipaje, peso, alto, ancho, largo, precio) VALUES (4, 4, 4, 1, 10, 40, 20, 10, 100);
INSERT INTO EQUIPAJE (id_equipaje, id_boleto, id_vuelo, id_tipo_equipaje, peso, alto, ancho, largo, precio) VALUES (5, 5, 5, 2, 15, 50, 30, 20, 150);
INSERT INTO EQUIPAJE (id_equipaje, id_boleto, id_vuelo, id_tipo_equipaje, peso, alto, ancho, largo, precio) VALUES (6, 6, 6, 3, 20, 60, 40, 30, 200);



SELECT * FROM PASAJERO;

SELECT * FROM BOLETO;

SELECT * FROM VUELO;

-- Verificar asiento ocupados

SELECT numero_asiento, estado
FROM ASIENTOS
WHERE id_avion = 1;

-- Check-in

BEGIN
    sp_checkin(2, 2);
END;
/

-- Revisar boletos después del check-in

SELECT * FROM BOLETO;

-- Cancelar un vuelo

BEGIN
    sp_cancelar_vuelo(1);
END;
/

-- itinerario de un pasajero
DECLARE
    v_itinerario SYS_REFCURSOR;
BEGIN
    sp_itinerario_pasajero(1,v_itinerario);
    sp_itinerario_pasajero(11, v_itinerario);
END;
/

-- Hacer check-in a todos los pasajeros del vuelo 1

SELECT * FROM VUELO;
