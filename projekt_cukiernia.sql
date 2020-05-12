
CREATE TABLE Adresy(
id_adres INT IDENTITY(1,1) PRIMARY KEY,
ulica VARCHAR(60) NULL,
numer CHAR(10) NULL,
kod_pocztowy VARCHAR(10) NULL,
miasto VARCHAR(30) NULL
)

CREATE TABLE Pracownicy(
id_pracownik INT IDENTITY(1,1) PRIMARY KEY,
id_adres_pracownika INT NOT NULL,
imie VARCHAR(15) NOT NULL CHECK(LEN(imie)>2),
nazwisko VARCHAR(25) NOT NULL CHECK(LEN(nazwisko)>2),
pesel VARCHAR(15) NOT NULL UNIQUE,
pensja MONEY NOT NULL CHECK(pensja BETWEEN 2000 AND 3500),
stanowisko VARCHAR(20) NULL
)


ALTER TABLE Pracownicy
ADD FOREIGN KEY (id_adres_pracownika)
REFERENCES Adresy(id_adres)
ON DELETE CASCADE
ON UPDATE CASCADE

CREATE TABLE Dostawcy(
id_dostawca INT IDENTITY(1,1) PRIMARY KEY,
id_adres_dostawcy INT NOT NULL,
imie VARCHAR(15) NOT NULL CHECK(LEN(imie)>2),
nazwisko VARCHAR(25) NOT NULL CHECK(LEN(nazwisko)>2),
nazwa_firmy VARCHAR(30) NULL,
staly_dostawca VARCHAR(3) NULL
)



ALTER TABLE Dostawcy
ADD FOREIGN KEY (id_adres_dostawcy)
REFERENCES Adresy(id_adres)
ON DELETE CASCADE
ON UPDATE CASCADE

CREATE TABLE Klienci(
id_klient INT IDENTITY(1,1) PRIMARY KEY,
id_adres_klienta INT NOT NULL,
imie VARCHAR(15) NOT NULL CHECK(LEN(imie)>2),
nazwisko VARCHAR(25) NOT NULL CHECK(LEN(nazwisko)>2),
telefon VARCHAR(15) NULL,
staly_klient VARCHAR(3) NULL
)

ALTER TABLE Klienci
ADD FOREIGN KEY (id_adres_klienta)
REFERENCES Adresy(id_adres)
ON DELETE CASCADE
ON UPDATE CASCADE

CREATE TABLE Produkty(
id_produkt INT IDENTITY(1,1) PRIMARY KEY,
id_dostawcy INT NOT NULL,
nazwa_produktu VARCHAR(20) NOT NULL,
cena MONEY NOT NULL,
dostepna_ilosc INT NULL,
weganski VARCHAR(3) NULL
)

ALTER TABLE Produkty
ADD FOREIGN KEY (id_dostawcy)
REFERENCES Dostawcy(id_dostawca)
ON DELETE CASCADE
ON UPDATE CASCADE


CREATE TABLE Zamowienia(
id_zamowienia INT IDENTITY(1,1) PRIMARY KEY,
data_zamowienia DATE NOT NULL,
data_odbioru DATE NOT NULL
)

ALTER TABLE Zamowienia
ADD CHECK (data_odbioru>=data_zamowienia)

CREATE TABLE [Szczegoly Zamowien](
id_szczegolyz INT IDENTITY(1,1) PRIMARY KEY,
id_szamowienia INT NOT NULL,
id_sprodukt INT NOT NULL,
cena MONEY NULL,
ilosc INT NOT NULL,
znizka REAL NULL
)

ALTER TABLE [Szczegoly Zamowien]
ADD FOREIGN KEY (id_szamowienia)
REFERENCES Zamowienia (id_zamowienia)
ON DELETE CASCADE
ON UPDATE CASCADE

ALTER TABLE [Szczegoly Zamowien]
ADD FOREIGN KEY (id_sprodukt)
REFERENCES Produkty (id_produkt)
ON DELETE CASCADE
ON UPDATE CASCADE

CREATE TABLE [Wyroby Cukiernicze](
id_wyroby INT IDENTITY(1,1) PRIMARY KEY,
nazwa VARCHAR(20) NOT NULL,
cena MONEY NOT NULL,
kalorie INT NULL,
bezglutenowe VARCHAR(3)
)

CREATE TABLE Sprzedaz(
id_sprzedaz INT IDENTITY(1,1) PRIMARY KEY,
id_spracownik INT NOT NULL,
id_sklient INT NOT NULL,
data_sprzedazy DATE NOT NULL,
zaliczka VARCHAR(3) NULL
)

ALTER TABLE Sprzedaz
ADD FOREIGN KEY (id_spracownik)
REFERENCES Pracownicy(id_pracownik)
ON DELETE CASCADE
ON UPDATE CASCADE

ALTER TABLE Sprzedaz
ADD FOREIGN KEY (id_sklient)
REFERENCES Klienci(id_klient)
--ON DELETE CASCADE
--ON UPDATE CASCADE

CREATE TABLE [Szczegoly Sprzedazy](
id_szczegolys INT IDENTITY(1,1) PRIMARY KEY,
id_swyroby INT NOT NULL,
id_ssprzedaz INT NOT NULL,
cena MONEY NULL,
ilosc INT NOT NULL,
znizka REAL NULL
)


ALTER TABLE [Szczegoly Sprzedazy]
ADD FOREIGN KEY (id_swyroby)
REFERENCES [Wyroby Cukiernicze](id_wyroby)
ON DELETE CASCADE
ON UPDATE CASCADE

ALTER TABLE [Szczegoly Sprzedazy]
ADD FOREIGN KEY (id_ssprzedaz)
REFERENCES Sprzedaz(id_sprzedaz)
ON DELETE CASCADE 
ON UPDATE CASCADE

--max cena wyrobow
CREATE PROC najwyzsza_cena
AS
DECLARE @makscena MONEY
SET @makscena = (SELECT MAX(cena) FROM [Wyroby Cukiernicze])
SELECT id_wyroby,nazwa,cena FROM [Wyroby Cukiernicze]
WHERE cena=@makscena
GO

--EXEC najwyzsza_cena

--dodaj adres
CREATE PROC dodaj_adres
@ulica VARCHAR(30),@numer VARCHAR(10),@kod_pocztowy VARCHAR(10),@miasto VARCHAR(30)
AS
INSERT INTO Adresy(ulica,numer,kod_pocztowy,miasto)
VALUES(@ulica,@numer,@kod_pocztowy,@miasto)
GO


--EXEC dodaj_adres 'dsss',12,'23-22','sads'

--cena1
CREATE PROC cena_ss
AS
UPDATE [Szczegoly Sprzedazy]
SET cena=(cena*ilosc)-(cena*znizka)
RETURN

--cena2
CREATE PROC cena_sz
AS
UPDATE [Szczegoly Zamowien]
SET cena=(cena*ilosc)-(cena*znizka)
RETURN

--zamowienia zlozone po podanej dacie
CREATE PROC zamowienia
@data DATE
AS 
BEGIN
SELECT data_zamowienia,data_odbioru FROM Zamowienia
WHERE data_zamowienia>@data
END
GO

--zarobki nie moga byc zerowe
CREATE TRIGGER zarobki
ON Pracownicy
FOR INSERT
AS
DECLARE @pensja MONEY
SELECT @pensja = pensja FROM inserted
If @pensja  = 0
BEGIN
ROLLBACK
RAISERROR('zarobki nie moga byc zerowe',1,1)
END

--dostepna ilosc produktow
CREATE TRIGGER ilosc
ON [Szczegoly Zamowien]
FOR INSERT,UPDATE
AS
DECLARE @ilosc INT,@dostepna_ilosc INT
SELECT @ilosc=ilosc FROM inserted
SELECT @dostepna_ilosc=dostepna_ilosc FROM Produkty
IF @ilosc>@dostepna_ilosc
BEGIN
ROLLBACK
RAISERROR('nie ma takiej ilosci dostepnych produktow',2,2)
END

--staly dostawca

CREATE TRIGGER dostawca
ON Produkty
FOR INSERT,UPDATE
AS
DECLARE @dostawca VARCHAR(3)
SELECT @dostawca=staly_dostawca FROM Dostawcy
IF @dostawca!='tak'
BEGIN 
ROLLBACK
RAISERROR('brak mozliwosci zamowien od nieznanego dostawcy',3,3)
END

--stanowisko
CREATE TRIGGER stanowisko
ON Sprzedaz
FOR INSERT,UPDATE
AS
DECLARE @stanowisko VARCHAR(20)
SELECT @stanowisko=stanowisko FROM Pracownicy
IF @stanowisko!='kasjer'
BEGIN
ROLLBACK
RAISERROR('tylko kasjer jest upowazniony do sprzedazy',4,4)
END

--znizka dla klientow, ktorzy wplacili zaliczke
CREATE TRIGGER znizka
ON [Szczegoly Sprzedazy]
FOR INSERT,UPDATE
AS 
DECLARE @zaliczka VARCHAR(3),@znizka REAL
SELECT @znizka=znizka FROM [Szczegoly Sprzedazy]
SELECT @zaliczka=zaliczka FROM Sprzedaz
IF @zaliczka='tak'
BEGIN
SET @znizka=0.2
END
GO

CREATE VIEW produkty_weganskie
AS
SELECT d.imie,d.nazwisko,d.nazwa_firmy,p.nazwa_produktu,p.cena
FROM Dostawcy d JOIN Produkty p
ON d.id_dostawca=p.id_dostawcy
GROUP BY d.nazwa_firmy,d.imie,d.nazwisko,p.nazwa_produktu,p.cena,p.weganski
HAVING p.weganski='tak'

CREATE VIEW wyroby_bezglutenowe
AS
SELECT nazwa,cena
FROM [Wyroby Cukiernicze]
GROUP BY nazwa,cena,bezglutenowe
HAVING bezglutenowe='tak'

CREATE VIEW staly_klient
AS
SELECT imie,nazwisko,telefon
FROM Klienci
GROUP BY imie,nazwisko,telefon,staly_klient
HAVING staly_klient='tak'

CREATE VIEW staly_dostawca
AS
SELECT imie,nazwisko,nazwa_firmy
FROM Dostawcy
GROUP BY nazwa_firmy,imie,nazwisko,staly_dostawca
HAVING staly_dostawca='tak'

CREATE VIEW zaliczki
AS
SELECT k.imie,k.nazwisko
FROM Klienci k JOIN Sprzedaz s
ON k.id_klient=s.id_sklient
GROUP BY k.imie,k.nazwisko,s.zaliczka
HAVING zaliczka='tak'

CREATE VIEW zamowione_produkty
AS
SELECT p.nazwa_produktu,z.data_zamowienia,z.data_odbioru
FROM Produkty p JOIN [Szczegoly Zamowien] s
ON p.id_produkt=s.id_sprodukt RIGHT JOIN Zamowienia z
ON s.id_szamowienia=z.id_zamowienia

CREATE FUNCTION kalorie(@kalorie INT)
RETURNS TABLE AS
RETURN (SELECT * FROM [Wyroby Cukiernicze]
WHERE kalorie<=@kalorie)
GO
--SELECT nazwa,kalorie
--FROM kalorie(2200)

CREATE VIEW adresy_dostawcow
AS
SELECT d.imie,d.nazwisko,d.nazwa_firmy,a.ulica,a.numer,a.kod_pocztowy,a.miasto
FROM Dostawcy d RIGHT JOIN Adresy a
ON d.id_adres_dostawcy=a.id_adres

CREATE VIEW adresy_pracownikow
AS
SELECT p.imie,p.nazwisko,a.ulica,a.numer,a.kod_pocztowy,a.miasto
FROM Pracownicy p RIGHT JOIN Adresy a
ON p.id_adres_pracownika=a.id_adres

CREATE VIEW adresy_klientow
AS 
SELECT k.imie,k.nazwisko,k.telefon,a.ulica,a.numer,a.kod_pocztowy,a.miasto
FROM Klienci k RIGHT JOIN Adresy a
ON k.id_adres_klienta=a.id_adres


INSERT INTO Adresy
VALUES
('Skrzydlata',22,'82-300','Elblag'),
('Krawiecka',6,'82-300','Elblag'),
('Grunwaldzka',83,'82-300','Elblag'),
('Morska',122,'83-400','Stegna'),
('Portowa',21,'81-200','Ustka'),
('Lewa',6,'81-211','Szczecin'),
('Warszawska',43,'61-222','Gdynia'),
('Torowa',33,'11-229','Tarnow'),
('Roczna',44,'23-222','Warszawa'),
('Mroczna',11,'82-300','Elblag'),
('Rycerska',31,'82-300','Elblag'),
('Rynkowa',77,'82-300','Elblag'),
('Otwarta',421,'83-400','Stegna'),
('Glowna',22,'81-200','Ustka'),
('Dawna',211,'81-211','Szczecin')





INSERT INTO Dostawcy
VALUES
(1,'Maciej','Kunach','Warzywko','tak'),
(2,'Regina','Phalange','Figa','tak'),
(3,'Mortimer','Cwir','Mewka','tak'),
(4,'Wlodzimierz','Len','Stokrotka','tak'),
(5,'Marek','Trzask','Castorama','nie')

INSERT INTO Pracownicy
VALUES
(6,'Tomek','Rot','98122827177',3400,'piekarz'),
(7,'Marta','Kot','81222274444',2200,'kasjer'),
(8,'Asia','Mak','27272828282',2330,'kasjer'),
(9,'Pola','Tlok','91111822221',2220,'kasjer'),
(10,'Marcin','Rok','98222222122',3200,'cukiernik')

INSERT INTO Klienci
VALUES
(11,'Eryk','Mars','512-333-333','tak'),
(12,'Piotr','Kowal','333-333-333','tak'),
(13,'Bartek','Szmal','553-222-444','tak'),
(14,'Marek','Topol','922-332-333','tak'),
(15,'Basia','Kruk','373-444-444','nie')

INSERT INTO Produkty
VALUES
(1,'kiwi',20,12,'tak'),
(1,'banany',10,50,'tak'),
(2,'maslo',44,40,'nie'),
(2,'mleko',22,44,'nie'),
(3,'kawa',111,22,'tak'),
(4,'maka',12,22,'tak'),
(4,'truskawki',10,22,'tak')

INSERT INTO Zamowienia
VALUES
('12-12-2017','12-12-2017'),
('13-12-2017','14-12-2017'),
('14-12-2017','15-12-2017'),
('15-12-2017','16-12-2017'),
('16-12-2017','17-12-2017'),
('17-12-2017','18-12-2017'),
('18-12-2017','22-12-2017'),
('19-12-2017','22-12-2017')

INSERT INTO [Szczegoly Zamowien]
VALUES
(1,1,null,10,0.1),
(2,1,null,9,0.15),
(3,2,null,11,0.1),
(4,3,null,22,0.11),
(5,4,null,11,0.1),
(6,5,null,7,0.3),
(7,6,null,1,0),
(8,7,null,20,0.2)

INSERT INTO Sprzedaz
VALUES
(2,1,'22-03-2018','tak'),
(2,2,'23-03-2018','tak'),
(3,3,'22-02-2018','nie'),
(3,4,'21-04-2018','tak'),
(4,5,'12-02-2018','nie')

INSERT INTO [Wyroby Cukiernicze]
VALUES
('piernik',22,1200,'nie'),
('drozdzowka',12,700,'nie'),
('tarta owocowa',14,300,'tak'),
('sernik',11,223,'nie'),
('tort',44,1200,'nie')

INSERT INTO [Szczegoly Sprzedazy]
VALUES
(1,1,null,2,0.2),
(2,2,null,10,0.3),
(3,3,null,4,0.1),
(4,4,null,6,0),
(5,5,null,4,0.11)





