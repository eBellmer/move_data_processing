/* Create tables for the processed data */
/* This file creates tables using corrected normalisation tables */

CREATE TABLE salfordMove.dbo.APPLICATIONS(
	applicationID INT NOT NULL,
	applicationName NVARCHAR(20),
	CONSTRAINT PK_APPLICATIONS PRIMARY KEY (applicationID)
);

CREATE TABLE salfordMove.dbo.NETWORKS(
	networkID INT NOT NULL,
	networkName NVARCHAR(20),
	CONSTRAINT PK_NETWORKS PRIMARY KEY (networkID)
);

CREATE TABLE salfordMove.dbo.SENSORS(
	sensorID INT NOT NULL,
	applicationID INT NOT NULL,
	networkID INT NOT NULL,
	sensorName NVARCHAR(MAX),
	CONSTRAINT PK_SENSORS PRIMARY KEY (sensorID),
	CONSTRAINT FK_SENSORS_APPLICATIONS FOREIGN KEY (applicationID)
	REFERENCES salfordMove.dbo.APPLICATIONS (applicationID)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT FK_SENSORS_NETWORKS FOREIGN KEY (networkID)
	REFERENCES salfordMove.dbo.NETWORKS (networkID)
	ON DELETE CASCADE
	on UPDATE CASCADE
);

CREATE TABLE salfordMove.dbo.DATA_TYPES(
	dTypeID UNIQUEIDENTIFIER NOT NULL,
	dataType NVARCHAR(20) NOT NULL,
	CONSTRAINT PK_DATA_TYPES PRIMARY KEY (dTypeID)
);

CREATE TABLE salfordMove.dbo.READINGS(
	dataMessageGUID UNIQUEIDENTIFIER NOT NULL,
	sensorID INT REFERENCES salfordMove.dbo.SENSORS(sensorID) NOT NULL,
	dTypeID UNIQUEIDENTIFIER NOT NULL,
	reading NVARCHAR(5) NOT NULL,
	messageType NVARCHAR(5),
	CONSTRAINT PK_READINGS PRIMARY KEY (sensorID, dataMessageGUID),
	CONSTRAINT FK_READINGS_DTYPE FOREIGN KEY (dTypeID)
	REFERENCES salfordMove.dbo.DATA_TYPES (dTypeID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE salfordMove.dbo.SIGNAL_STATUS(
	sensorID INT NOT NULL,
	dataMessageGUID UNIQUEIDENTIFIER NOT NULL,
	signalStrength FLOAT,
	CONSTRAINT FK_SIGNAL_STATUS FOREIGN KEY (sensorID, dataMessageGUID)
	REFERENCES salfordMove.dbo.READINGS (sensorID, dataMessageGUID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE salfordMove.dbo.BATTERY_STATUS(
	sensorID INT NOT NULL,
	dataMessageGUID UNIQUEIDENTIFIER NOT NULL,
	batteryLevel INT,
	CONSTRAINT FK_BATTERY_STATUS FOREIGN KEY (sensorID, dataMessageGUID)
	REFERENCES salfordMove.dbo.READINGS (sensorID, dataMessageGUID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE salfordMove.dbo.PENDING_CHANGES(
	sensorID INT REFERENCES salfordMove.dbo.SENSORS(sensorID) NOT NULL,
	dataMessageGUID UNIQUEIDENTIFIER NOT NULL,
	pendingChange BIT,
	CONSTRAINT FK_PENDING_CHANGES FOREIGN KEY (sensorID, dataMessageGUID)
	REFERENCES salfordMove.dbo.READINGS (sensorID, dataMessageGUID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE salfordMove.dbo.SENSOR_VOLTAGE(
	sensorID INT NOT NULL,
	dataMessageGUID UNIQUEIDENTIFIER NOT NULL,
	voltage FLOAT,
	CONSTRAINT FK_SENSOR_VOLTAGE FOREIGN KEY (sensorID, dataMessageGUID)
	REFERENCES salfordMove.dbo.READINGS (sensorID, dataMessageGUID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

GO