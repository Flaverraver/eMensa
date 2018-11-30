/* Annahmen, die ich allgemein treffe schreibe ich hier hin. Spezifische
// Annahmen werden vor der jeweiligen Tabelle beschrieben.
// - 
*/
-- DROP DATABASE `E-Mensa`;
-- CREATE DATABASE IF NOT EXISTS `E-Mensa`;				
USE `E-Mensa`;

DROP USER IF EXISTS 'webapp'@'localhost';
CREATE USER 'webapp'@'localhost' IDENTIFIED BY 'heinz';
GRANT USAGE ON *.* To 'webapp'@'localhost';
GRANT SELECT, DELETE, INSERT, UPDATE ON *.* TO 'webapp'@'localhost';
FLUSH PRIVILEGES;



DROP TABLE IF EXISTS `Mahlzeit-Zutaten`;
DROP TABLE IF EXISTS `Zutaten`;
DROP TABLE IF EXISTS `Mahlzeit-Bild`;
DROP TABLE IF EXISTS `Kategorien-Bilder`;
DROP TABLE IF EXISTS `Mahlzeiten-Kategorie`;
DROP TABLE IF EXISTS `Unterkategorien`;
DROP TABLE IF EXISTS `Preise`;
DROP TABLE IF EXISTS `Mahlzeit-Deklaration`;
DROP TABLE IF EXISTS `Mahlzeiten-Kommentar`;
DROP TABLE IF EXISTS `Bestellanzahl`;
DROP TABLE IF EXISTS `Mahlzeiten`;
DROP TABLE IF EXISTS `Kategorien`;
DROP TABLE IF EXISTS `Bilder`;
DROP TABLE IF EXISTS `Oberkategorien`;
DROP TABLE IF EXISTS `tätigt`;
DROP TABLE IF EXISTS `Bestellungen`;
DROP TABLE IF EXISTS `Deklarationen`;
DROP TABLE IF EXISTS `schreibt`;
DROP TABLE IF EXISTS `Kommentare`;
DROP TABLE IF EXISTS `FH_zu_FB`;
DROP TABLE IF EXISTS `Fachbereiche`;
DROP TABLE IF EXISTS `Studenten`;
DROP TABLE IF EXISTS `Mitarbeiter`;
DROP TABLE IF EXISTS `FH-Angehörige`;
DROP TABLE IF EXISTS `Gäste`;
DROP TABLE IF EXISTS `befreundet mit`;
DROP TABLE IF EXISTS `Benutzer`;

CREATE TABLE IF NOT EXISTS `Benutzer`(
	`Nummer` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`E-Mail` VARCHAR(255) NOT NULL UNIQUE,
	`Letzter Login` TIMESTAMP NULL DEFAULT NULL,				-- Warum NULL (ist doch Standard eig?)
	`Nutzername` VARCHAR(20) NOT NULL UNIQUE,
	`Salt` CHAR(32) NOT NULL,							
	`Hash` CHAR(24) NOT NULL,							
	`Anlegedatum` DATE DEFAULT CURRENT_DATE,
	`Aktiv` BOOL NOT NULL,								-- Flag: Alternativ Bit?  |||| Hier noch Default-Wert setzen?
	`Vorname` VARCHAR(50) NOT NULL,
	`Nachname` VARCHAR(50) NOT NULL,
	`Geburtsdatum`	DATE,
	`Alter` TINYINT(3) UNSIGNED						-- Später in der Manipulation der Daten	
);

-- N-zu-M

CREATE TABLE IF NOT EXISTS `befreundet mit` (
	`Nummer 1` INT UNSIGNED,
	`Nummer 2` INT UNSIGNED,
																					-- Many-Many Relation zur selben Entität in Ordnung so?
	CONSTRAINT `Benutzer befreundet mit` 
		FOREIGN KEY(`Nummer 1`) REFERENCES Benutzer(Nummer),
		FOREIGN KEY(`Nummer 2`) REFERENCES Benutzer(Nummer),
	CONSTRAINT `Selber Freund`
		CHECK (`Nummer 1` != `Nummer 2`) 	
);

-- Gäste bekommen im Zuge der "is-a-relation" ein weiteres Attribut ID, welches die Nummer/ID
-- des Benutzers referenziert, beziehungsweise auch den selben Wert hat. (?)
CREATE TABLE IF NOT EXISTS `Gäste` (
	`ID` INT UNSIGNED PRIMARY KEY,
	`Ablaufdatum` DATE DEFAULT ADDDATE(CURRENT_DATE,7),
	`Grund` VARCHAR(255) NOT NULL,
	
	CONSTRAINT `FK_Gast_Benutzer` FOREIGN KEY(`ID`) REFERENCES Benutzer(Nummer) ON DELETE CASCADE				-- Is-a Beziehung? So in Ordnung?
); 

-- FH-Angehörige bekommen im Zuge der "is-a-relation" ein weiteres Attribut ID, welches die Nummer/ID
-- des Benutzers referenziert, beziehungsweise auch den selben Wert hat. (?)
CREATE TABLE IF NOT EXISTS `FH-Angehörige` (
	`ID` INT UNSIGNED PRIMARY KEY,
	
	CONSTRAINT `FK_FH_Benutzer` FOREIGN KEY(`ID`) REFERENCES Benutzer(Nummer)  ON DELETE CASCADE				-- Is-a Beziehung? So in Ordnung?
);

-- Attribut `Büro` wird aufgeteilt in Gebäude-Buchstabe und Raumnummer.
-- Zudem bekommt der Mitarbeiter noch ein weiteres Attribut "ID", welches der ID des FH-
-- Angehörigen referenziert.
CREATE TABLE IF NOT EXISTS `Mitarbeiter` (
	`ID` INT UNSIGNED PRIMARY KEY,
	`Telefon` BIGINT(15) UNSIGNED,
	`Gebäude` ENUM('C','D','E','F','G','H','W'),						
	`Raumnummer` SMALLINT(3),
	
	CONSTRAINT `FK_MA_FH` FOREIGN KEY(`ID`) REFERENCES `FH-Angehörige`(ID)  ON DELETE CASCADE			-- Auch eine Is-a Beziehung?
);

-- Weiteres Attribut ID, welches die ID vom FH-Angehörigen referenziert.
CREATE TABLE IF NOT EXISTS `Studenten` (
	`ID` INT UNSIGNED PRIMARY KEY,
	`Studiengang` ENUM('ET','INF','ISE','MCD','WI') NOT NULL,
	`Matrikelnummer` INT(9) UNSIGNED NOT NULL UNIQUE,
	
	CONSTRAINT `FK_Studenten_FH` FOREIGN KEY(`ID`) REFERENCES `FH-Angehörige`(ID)  ON DELETE CASCADE,
	CONSTRAINT `Matrikelnummer` CHECK (LENGTH(Matrikelnummer) >= 8)
);

CREATE TABLE IF NOT EXISTS `Fachbereiche` (
	`ID` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`Name` ENUM ('Architektur', 'Bauingenieurwesen', 'Chemie und Biotechnologie', 'Gestaltung', 'Elektrotechnik und Informationstechnik', 
		'Luft- und Raumfahrttechnik', 'Wirtschaftswissenschaften', 'Maschinenbau und Mechatronik', 'Medizintechnik und Technomathematik', 'Energietechnik') NOT NULL,
	`Website` VARCHAR(255) NOT NULL
);

-- N-zu-M
CREATE TABLE IF NOT EXISTS `FH_zu_FB` (
	`FH-ID` INT UNSIGNED,
	`FB-ID` INT UNSIGNED,
	
	CONSTRAINT `FH_zu_FB`
		FOREIGN KEY(`FH-ID`) REFERENCES `FH-Angehörige`(ID),
		FOREIGN KEY(`FB-ID`) REFERENCES Fachbereiche(ID)
);

CREATE TABLE IF NOT EXISTS `Bilder` (
	`ID` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`Alt-Text` VARCHAR(255) NOT NULL,
	`Titel` VARCHAR(50),
	`Binaerdaten` LONGBLOB NOT NULL
);

CREATE TABLE IF NOT EXISTS `Kategorien` (
	`ID` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`Bezeichnung` VARCHAR(255) NOT NULL DEFAULT "Test",
	`Oberkategorie` INT UNSIGNED DEFAULT NULL,
	`Bild` INT UNSIGNED,
	
	FOREIGN KEY (Bild) REFERENCES Bilder(ID) ON DELETE SET NULL,
	FOREIGN KEY (Oberkategorie) REFERENCES Kategorien(ID) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS `Mahlzeiten` (
	`ID` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`Name` VARCHAR(40) NOT NULL,
	`Beschreibung` TEXT NOT NULL,
	`Vorrat` INT UNSIGNED NOT NULL DEFAULT 0,
	`Verfuegbar` BOOL,							-- Muss berechnet werden
	`Kategorie` INT UNSIGNED NOT NULL,
	`Bild` INT UNSIGNED NOT NULL,
	
	FOREIGN KEY (Kategorie) REFERENCES Kategorien(ID),
	FOREIGN KEY (Bild) REFERENCES Bilder(ID)
	
);

CREATE TABLE IF NOT EXISTS `Kommentare` (
	`ID` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`Bemerkung` TEXT NULL,
	`Bewertung` TINYINT(1) NOT NULL,
	`Studenten-ID` INT UNSIGNED NOT NULL,
	`Mahlzeit-ID` INT UNSIGNED NOT NULL,
	
	FOREIGN KEY (`Studenten-ID`) REFERENCES `Studenten`(`ID`)
	-- FOREIGN KEY `Mahlzeit-ID` REFERENCES Mahlzeiten(ID)
		
	-- CONSTRAINT `Bewertung 1-5` CHECK (`Bewertung` <= 5)
);

-- 1-zu-N
CREATE TABLE IF NOT EXISTS `Schreibt` (
	`K-ID` INT UNSIGNED PRIMARY KEY,
	`S-ID` INT UNSIGNED,
	
	CONSTRAINT `Schreibt` 
		FOREIGN KEY (`K-ID`) REFERENCES Kommentare(ID),
		FOREIGN KEY (`S-ID`) REFERENCES Studenten(ID)
);

CREATE TABLE IF NOT EXISTS `Deklarationen` (
	`Zeichen` VARCHAR(2) NOT NULL PRIMARY KEY,
	`Beschriftung` VARCHAR(32) NOT NULL,
	
	CONSTRAINT `Zeichenlänge`
		CHECK (LENGTH(Zeichen) > 0)
);

CREATE TABLE IF NOT EXISTS `Bestellungen` (
	`Nummer` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`Bestell-Zeitpunkt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`Abhol-Zeitpunkt` TIMESTAMP NULL,
	`Endpreis` DECIMAL(6,2) NOT NULL,				-- Manipulation der Daten fehlt
	`Benutzer-ID` INT UNSIGNED,
	
	CONSTRAINT `Abholzeitpunkt` CHECK (UNIX_TIMESTAMP(`Abhol-Zeitpunkt`) > UNIX_TIMESTAMP(`Bestell-Zeitpunkt`)),
	FOREIGN KEY (`Benutzer-ID`) REFERENCES Benutzer(Nummer)
);

-- 1-zu-N
CREATE TABLE IF NOT EXISTS `Tätigt` (
	`Bestellnummer` INT UNSIGNED PRIMARY KEY,
	`Benutzer-ID` INT UNSIGNED NOT NULL,
	
	CONSTRAINT `Bestellung` 
		FOREIGN KEY(`Bestellnummer`) REFERENCES Bestellungen(Nummer),
		FOREIGN KEY(`Benutzer-ID`) REFERENCES Benutzer(Nummer)
);

CREATE TABLE IF NOT EXISTS `Oberkategorien` (
	`ID` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`Bezeichnung` VARCHAR(255) NOT NULL
);

-- N-zu-M
CREATE TABLE IF NOT EXISTS `Bestellanzahl` (
	`Mahlzeiten-ID` INT UNSIGNED,
	`Bestell-ID` INT UNSIGNED,
	`Anzahl` TINYINT(2) UNSIGNED NOT NULL,
	
	CONSTRAINT `Bestellanzahl` 
		FOREIGN KEY(`Mahlzeiten-ID`) REFERENCES Mahlzeiten(ID),
		FOREIGN KEY(`Bestell-ID`) REFERENCES Bestellungen(Nummer)
);

-- 1-zu-N
CREATE TABLE IF NOT EXISTS `Mahlzeiten-Kommentar` (
	`Kommentar-ID` INT UNSIGNED PRIMARY KEY,
	`Mahlzeiten-ID` INT UNSIGNED,
	
	CONSTRAINT `Mahlzeiten-Kommentar` 
		FOREIGN KEY(`Kommentar-ID`) REFERENCES Kommentare(ID),
		FOREIGN KEY(`Mahlzeiten-ID`) REFERENCES Mahlzeiten(ID)
);

-- N-zu-M
CREATE TABLE IF NOT EXISTS `Mahlzeit-Deklaration` (
	`Mahlzeiten-ID` INT UNSIGNED,
	`Deklarations-Zeichen` CHAR(2),
	
	CONSTRAINT `Mahlzeit-Deklaration` 
		FOREIGN KEY(`Mahlzeiten-ID`) REFERENCES Mahlzeiten(ID),
		FOREIGN KEY(`Deklarations-Zeichen`) REFERENCES Deklarationen(Zeichen)
);

-- Schwache Entität. Wird gelöscht, wenn die zugehörigen besitzenden Entitäten gelöscht werden.
-- Weiteres Attribut Mahlzeiten-ID, wegen der 1-zu-1 (muss:muss)-Relation zu Mahlzeiten.
CREATE TABLE IF NOT EXISTS `Preise` (
	`Jahr` YEAR,																		-- Warum ist das unterstrichen? -> Preise für eine Mahlzeit gelten für ein `Jahr` (?)
	`Gastpreis` DECIMAL(4,2) UNSIGNED NOT NULL,
	`Studentpreis` DECIMAL(4,2) UNSIGNED,
	`MA-Preis` DECIMAL(4,2) UNSIGNED,
	`Mahlzeiten-ID` INT UNSIGNED,
	
	CONSTRAINT `Studentenrabatt` 
		CHECK(`Studentpreis` < `MA-Preis`),
		FOREIGN KEY (`Mahlzeiten-ID`) REFERENCES Mahlzeiten(ID) ON DELETE CASCADE	
);

-- N-zu-M
CREATE TABLE IF NOT EXISTS `Mahlzeit-Bild` (
	`Mahlzeiten-ID` INT UNSIGNED,
	`Bilder-ID` INT UNSIGNED,
	
	CONSTRAINT `Mahlzeit-Bild` 
		FOREIGN KEY(`Mahlzeiten-ID`) REFERENCES Mahlzeiten(ID),
		FOREIGN KEY(`Bilder-ID`) REFERENCES Bilder(ID)
);

CREATE TABLE IF NOT EXISTS `Zutaten` (
	`ID` INT(5) UNSIGNED PRIMARY KEY,
	`Name` VARCHAR(50) NOT NULL,
	`Bio` BOOL NOT NULL,
	`Vegetarisch` BOOL NOT NULL,
	`Vegan` BOOL NOT NULL,
	`Glutenfrei` BOOL NOT NULL
	
--	CONSTRAINT `ID 5-stellig`									-- Auskommentiert, da die vorgegeben ID`s nicht 5-stellig waren.
--		CHECK(LENGTH(ID) = 5)
);

-- N-zu-M
CREATE TABLE IF NOT EXISTS `Mahlzeit-Zutaten` (
	`Mahlzeiten-ID` INT UNSIGNED,
	`Zutaten-ID` INT UNSIGNED,
	
	CONSTRAINT `Zutaten_der_Mahlzeit` 
		FOREIGN KEY(`Mahlzeiten-ID`) REFERENCES Mahlzeiten(ID),
		FOREIGN KEY(`Zutaten-ID`) REFERENCES Zutaten(ID)
);
 
REPLACE INTO `Deklarationen` (`Zeichen`, `Beschriftung`) VALUES
	('2', 'Konservierungsstoff'),
	('3', 'Antioxidationsmittel'),
	('4', 'Geschmacksverstärker'),
	('5', 'geschwefelt'),
	('6', 'geschwärzt'),
	('7', 'gewachst'),
	('8', 'Phosphat'),
	('9', 'Süßungsmittel'),
	('10', 'enthält eine Phenylalaninquelle'),
	('A', 'Gluten'),
	('A1', 'Weizen'),
	('A2', 'Roggen'),
	('A3', 'Gerste'),
	('A4', 'Hafer'),
	('A5', 'Dinkel'),
	('B', 'Sellerie'),
	('C', 'Krebstiere'),
	('D', 'Eier'),
	('E', 'Fische'),
	('F', 'Erdnüsse'),
	('G', 'Sojabohnen'),
	('H', 'Milch'),
	('I', 'Schalenfrüchte'),
	('I1', 'Mandeln'),
	('I2', 'Haselnüsse'),
	('I3', 'Walnüsse'),
	('I4', 'Kaschunüsse'),
	('I5', 'Pecannüsse'),
	('I6', 'Paranüsse'),
	('I7', 'Pistazien'),
	('I8', 'Macadamianüsse'),
	('J', 'Senf'),
	('K', 'Sesamsamen'),
	('L', 'Schwefeldioxid oder Sulfite'),
	('M', 'Lupinen'),
	('N', 'Weichtiere')
;

REPLACE INTO `Zutaten` (`ID`, `Name`, `Bio`, `Vegan`, `Vegetarisch`, `Glutenfrei`) VALUES
	(00080, 'Aal', 0, 0, 0, 1),
	(00081, 'Forelle', 0, 0, 0, 1),
	(00082, 'Barsch', 0, 0, 0, 1),
	(00083, 'Lachs', 0, 0, 0, 1),
	(00084, 'Lachs', 1, 0, 0, 1),
	(00085, 'Heilbutt', 0, 0, 0, 1),
	(00086, 'Heilbutt', 1, 0, 0, 1),
	(00100, 'Kurkumin', 1, 1, 1, 1),
	(00101, 'Riboflavin', 0, 1, 1, 1),
	(00123, 'Amaranth', 1, 1, 1, 1),
	(00150, 'Zuckerkulör', 0, 1, 1, 1),
	(00171, 'Titandioxid', 0, 1, 1, 1),
	(00220, 'Schwefeldioxid', 0, 1, 1, 1),
	(00270, 'Milchsäure', 0, 1, 1, 1),
	(00322, 'Lecithin', 0, 1, 1, 1),
	(00330, 'Zitronensäure', 1, 1, 1, 1),
	(00999, 'Weizenmehl', 1, 1, 1, 0),
	(01000, 'Weizenmehl', 0, 1, 1, 0),
	(01001, 'Hanfmehl', 1, 1, 1, 1),
	(01010, 'Zucker', 0, 1, 1, 1),
	(01013, 'Traubenzucker', 0, 1, 1, 1),
	(01015, 'Branntweinessig', 0, 1, 1, 1),
	(02019, 'Karotten', 0, 1, 1, 1),
	(02020, 'Champignons', 0, 1, 1, 1),
	(02101, 'Schweinefleisch', 0, 0, 0, 1),
	(02102, 'Speck', 0, 0, 0, 1),
	(02103, 'Alginat', 0, 1, 1, 1),
	(02105, 'Paprika', 0, 1, 1, 1),
	(02107, 'Fenchel', 0, 1, 1, 1),
	(02108, 'Sellerie', 0, 1, 1, 1),
	(09020, 'Champignons', 1, 1, 1, 1),
	(09105, 'Paprika', 1, 1, 1, 1),
	(09107, 'Fenchel', 1, 1, 1, 1),
	(09110, 'Sojasprossen', 1, 1, 1, 1)
;


-- Im ER-Diagramm fehlt noch das Attribut Adresse, 
-- das Sie per ALTER TABLE einfach hinzufügen können
-- sobald Sie an den Punkt kommen ;)
ALTER TABLE `Fachbereiche` ADD COLUMN IF NOT EXISTS `Adresse` VARCHAR(255);

REPLACE INTO `Fachbereiche` (`ID`, `Name`, `Website`, `Adresse`) VALUES
	(1, 'Architektur', 'https://www.fh-aachen.de/fachbereiche/architektur/', 'Bayernallee 9, 52066 Aachen'),
	(2, 'Bauingenieurwesen', 'https://www.fh-aachen.de/fachbereiche/bauingenieurwesen/', 'Bayernallee 9, 52066 Aachen'),
	(3, 'Chemie und Biotechnologie', 'https://www.fh-aachen.de/fachbereiche/chemieundbiotechnologie/', 'Heinrich-Mußmann-Straße 1, 52428 Jülich'),
	(4, 'Gestaltung', 'https://www.fh-aachen.de/fachbereiche/gestaltung/', 'Boxgraben 100, 52064 Aachen'),
	(5, 'Elektrotechnik und Informationstechnik', 'https://www.fh-aachen.de/fachbereiche/elektrotechnik-und-informationstechnik/', 'Eupener Straße 70, 52066 Aachen'),
	(6, 'Luft- und Raumfahrttechnik', 'https://www.fh-aachen.de/fachbereiche/luft-und-raumfahrttechnik/', 'Hohenstaufenallee 6, 52064 Aachen'),
	(7, 'Wirtschaftswissenschaften', 'https://www.fh-aachen.de/fachbereiche/wirtschaft/', 'Eupener Straße 70, 52066 Aachen'),
	(8, 'Maschinenbau und Mechatronik', 'https://www.fh-aachen.de/fachbereiche/maschinenbau-und-mechatronik/', 'Goethestraße 1, 52064 Aachen'),
	(9, 'Medizintechnik und Technomathematik', 'https://www.fh-aachen.de/fachbereiche/medizintechnik-und-technomathematik/', 'Heinrich-Mußmann-Straße 1, 52428 Jülich'),
	(10, 'Energietechnik', 'https://www.fh-aachen.de/fachbereiche/energietechnik/', 'Heinrich-Mußmann-Straße 1, 52428 Jülich')
;

INSERT INTO `Benutzer` (`E-Mail`, Nutzername, Salt, `Hash`, Aktiv, Vorname, Nachname)
	VALUES ('Max@Mustermann.de', 'MaxMu', '12345678901234567890123456789012', '123456789012345678901234', '1', 'Max', 'Mustermann');
INSERT INTO `Benutzer` (`E-Mail`, Nutzername, Salt, `Hash`, Aktiv, Vorname, Nachname)
	VALUES ('Maria@Mustermann', 'MarMu', '12345678901234567890123456789012', '123456789012345678901234', '1', 'Maria', 'Mustermann');
INSERT INTO `Benutzer` (`E-Mail`, Nutzername, Salt, `Hash`, Aktiv, Vorname, Nachname)
	VALUES ('Peter@Mastermann.de', 'PetMa', '12345678901234567890123456789012', '123456789012345678901234', '1', 'Peter', 'Mastermann');
INSERT INTO `Benutzer` (`E-Mail`, Nutzername, Salt, `Hash`, Aktiv, Vorname, Nachname)
	VALUES ('Paul@Dealer', 'PauDe', '12345678901234567890123456789012', '123456789012345678901234', '1', 'Paul', 'Dealer');	
	
INSERT INTO `FH-Angehörige` (ID) 
	VALUES 
	(1),
	(2),
	(3);
INSERT INTO `Mitarbeiter` (ID, Telefon, Gebäude, Raumnummer)
	VALUES (1, 12345678, 'E', 113);

INSERT `Studenten` (ID, Studiengang, Matrikelnummer)
	VALUES
	(2,'ET',12345678),
	(3,'INF',123456789);
	
	
DELETE FROM `Benutzer` WHERE Nummer= (1);

REPLACE INTO Kategorien (`ID`, `Bezeichnung`, `Oberkategorie`, `Bild`) VALUES
	(1, 'Hauptspeisen', NULL, NULL),
	(2, 'Kleinigkeiten', NULL, NULL),
	(3, 'Smoothies', 2, NULL),
	(4, 'Snacks', 2, NULL),
	(5, 'Burger und Co', 1, NULL),
	(6, 'Asiatisch', 1, NULL),
	(7, 'Klassiker', 1, NULL),
	(8, 'Italienisch', 1, NULL),
	(9, 'Aktionen', NULL, NULL),
	(10, 'Weihnachten', 9, NULL),
	(11, 'Sommergenuss', 9, NULL),
	(12, 'Mensa Vital', 9, NULL),
	(13, 'Sonderangebote', NULL, NULL),
	(14, 'Ersti-Woche', 13, NULL),
	(15, 'Geburtstagsessen', 13, NULL);
	
INSERT INTO Mahlzeiten (Name, Beschreibung, Vorrat, Verfuegbar, Kategorie, Bild)	VALUES
	('Curry Wok','Lecker',5,1,1,1),
	('Schnitzel','Vom Schwein',5,1,1,1),
	('Bratrolle','Aus Holland',0,0,1,1),
	('Krautsalat','Beliebtes Gericht in Deutschland',5,1,1,1),
	('Falafel','Gibt es auch',5,1,1,1),
	('Currywurst','mit Pommes',5,1,1,1),
	('Käsestulle','Mit Käse schmeckt alles besser',5,1,1,1),
	('Spiegelei','Auch lecker',5,1,1,1);
	
INSERT INTO Preise (Jahr, Gastpreis, Studentpreis, `MA-Preis`, `Mahlzeiten-ID`) VALUES
	(2018, 5.95, 5.00, 5.50, 1),
	(2018, 5.95, 5.00, 5.50, 2),
	(2018, 5.95, 5.00, 5.50, 3),
	(2018, 5.95, 5.00, 5.50, 4),
	(2018, 5.95, 5.00, 5.50, 5),
	(2018, 5.95, 5.00, 5.50, 6),
	(2018, 5.95, 5.00, 5.50, 7),
	(2018, 5.95, 5.00, 5.50, 8);
								
REPLACE INTO Benutzer (`Nummer`, `Vorname`, `Nachname`, `E-Mail`, `Nutzername`, `Letzter Login`, `Anlegedatum`, `Geburtsdatum`, `Alter`, `Salt`, `Hash`, `Aktiv`) VALUES 
	(21, 'Bugs', 'Findmore', 'dbwt2018@ismypassword.com', 'bugfin', '2018-11-14 17:44:10', '2018-11-14', '1996-12-13', 0, 'MPVdLDf0zNVzpOHP+GmRxoBg9mdJIlc5', '4nx5U6DIE+N8xsbpwUr3Q1KG', 1),
	(22, 'Donald', 'Truck', 'testing@ismypassword.com', 'dot', '2018-11-14 17:44:10', '2018-11-14', '1991-12-11', 0, 'Ydn1iGl08JvvkVExSEiKDQhfYOaCtgOO', 'm5kZ68YVNU3xBiDqorthK9UP', 1),
	(23, 'Fiona', 'Index', 'an0ther@ismypassword.com', 'fionad', '2018-11-14 17:44:10', '2018-11-14', '1993-12-10', 0, 'I5GXy7BwYU2t3pHZ5YkBfKMbvN7Sr81O', 'oYylNvPe7YmjO1IHNdLA/XxJ', 1),
	(24, 'Wendy', 'Burger', 's3cr3tz@ismypassword.com', 'bkahuna', '2018-11-14 17:44:10', '2018-11-14', '1982-12-12', 0, 't1TAVguVwIiejXf3baaObIAtPx7Y+2iY', 'IMK2n5r8RUVFo4bMMS8uDyH4', 1),
	(25, 'Monster', 'Robot', '^;_`;^@ismypassword.com', 'root', '2018-11-14 17:44:10', '2018-11-14', '1982-12-12', 0, 'dX8YsBM9atpYto9caWHJM6Eet7bUngxk', 'nRt3MSBdNUHPj/q02WPgXaDA', 1);

REPLACE INTO `befreundet mit` (`Nummer 1`, `Nummer 2`) VALUES 
	(21, 22),
	(21, 23),
	(21, 24),
	(22, 23),
	(22, 24);

