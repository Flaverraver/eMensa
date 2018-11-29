USE world;
-- In der VL wurde die world Database demonstriert, die nicht weiter benutzt werden wird
-- bei Interesse können Sie sich die SQL Anweisungen bei MySQL herunterladen
-- https://dev.mysql.com/doc/world-setup/en/world-setup-installation.html


-- SHOW TABLES;
-- DESCRIBE countrylanguage

SELECT * FROM city;

SELECT CountryCode, Name FROM city;

SELECT Name, Population FROM city
	WHERE Population > 100000;

SELECT COUNT(*) AS Anzahl FROM city
	WHERE Population > 100000;

-- Aachen first (per Limit und Offset)
SELECT Name, Population FROM city
	WHERE Population > 100000
	ORDER BY Name
	LIMIT 1 OFFSET 1;





-- mit LIKE nach Mustern suchen
SELECT LocalName FROM country
	WHERE LocalName LIKE 'D%';

-- Länder mit D UND in Europa
SELECT District, SUM(Population)	FROM 	city
	WHERE CountryCode IN (
		SELECT Code FROM country WHERE Continent = 'Europe' AND LocalName LIKE 'D%'
	)
	-- WHERE SUM(Population) < 1000000
	GROUP BY District
	-- HAVING SUM(Population) < 1000000
	ORDER BY CountryCode, Name;
	
-- Reihenfolge in SQL Abfragen (DQL)
-- SELECT FROM (JOIN) WHERE GROUP BY HAVING ORDER BY LIMIT OFFSET

-- Alles ist eine Tabelle
SELECT Code, Name 
	FROM (
		SELECT Code, Name FROM country WHERE Continent = 'Europe'
	) AS Länder;

-- Subselect UND Join ;)
SELECT city.Name, city.Population 
	FROM (
		SELECT Code, Name FROM country WHERE Continent = 'Europe'
		) AS Länder 
	JOIN city
	ON Länder.Code = city.CountryCode
	ORDER BY city.Name;



-- Land für JOIN!
SELECT Code AS ID FROM
	(
	SELECT Code FROM country WHERE Name = 'Germany'
	)
AS Land;

-- eine VIEW anlegen
CREATE VIEW Europaländer AS
	SELECT Code FROM country WHERE Continent = 'Europe';

-- eine TABLE anlegen nach Vorbild einer anderen (persistieren)
CREATE TABLE Europagesichert AS
	SELECT * FROM Europaländer

-- die VIEW ändert sich, wenn Daten in der Tabelle `country` geändert werden, die neu erzeugte TABLE nicht
SELECT * FROM Europagesichert;

-- Gibt es Zeilen in der VIEW, die nicht in der TABLE sind?
SELECT * FROM Europaländer
	EXCEPT
	SELECT * FROM Europagesichert;

SELECT * FROM country 
	WHERE Continent NOT LIKE '% America' AND Code IN('FRA','DEU');

-- Welche Sprachen werden in Europa gesprochen
SELECT Language,Percentage, CountryCode, LocalName 
	FROM country AS L 
	JOIN countrylanguage AS S
	ON L.Code = S.CountryCode
	WHERE CountryCode IN (SELECT Code FROM Europaländer);

-- Welche Sprache wird in der Region Karibik gesprochen	
SELECT country.Region, countrylanguage.Language
	FROM country
	LEFT JOIN countrylanguage 
	ON country.Code = countrylanguage.CountryCode
	WHERE country.Region = "Caribbean"
