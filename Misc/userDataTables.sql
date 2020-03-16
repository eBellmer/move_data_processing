/* Create tables for storing data related to users and athentication credentials */

CREATE TABLE salfordMove.dbo.USERS(
	userID GUID NOT NULL,
	username NVARCHAR(20) NOT NULL,
	forename NVARCHAR(20) NOT NULL,
	surname NVARCHAR(50) NULL,
	email NVARCHAR(100) NOT NULL,
	contactNo NVARCHAR(15) NULL,
	CONSTRAINT PK_USERS PRIMARY KEY (userID),
);

CREATE TABLE salfordMove.dbo.ADMINS(
	adminID GUID NOT NULL,
	userID GUID NOT NULL,
	isAdmin BIT NOT NULL,
	CONSTRAINT PK_ADMINS PRIMARY KEY (adminID),
	CONSTRAINT FK_ADMINS_USER_ID FOREIGN KEY (userID)
	REFERENCES salfordMove.dbo.USERS (userID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE salfordMove.dbo.PASSWORDS(
	passwordID GUID NOT NULL,
	userID GUID NOT NULL,
	userPassword NVARCHAR(MAX) NOT NULL,
	salt NVARCHAR(MAX) NOT NULL,
	CONSTRAINT PK_PASSWORDS PRIMARY KEY (passwordID),
	CONSTRAINT FK_PASSWORDS_USER_ID FOREIGN KEY (userID)
	REFERENCES salfordMove.dbo.USERS (userID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE salfordMove.dbo.USER_PERMISSIONS(
	permissionID GUID NOT NULL,
	userID GUID NOT NULL,
	permission INT NOT NULL,
	CONSTRAINT PK_USER_PERMISSIONS PRIMARY KEY (permissionID),
	CONSTRAINT FK_PERMISSIONS_USER_ID FOREIGN KEY (userID)
	REFERENCES salfordMove.dbo.USERS (userID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

GO