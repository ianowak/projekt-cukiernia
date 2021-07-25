# Projekt SQL cukiernia

## Opis
Projekt przedstawia bazę danych cukierni. Zawiera on informacje dotyczące pracowników cukierni, dostawców zaopatrujących cukiernię w produkty, klientów oraz szczegóły dotyczące sprzedaży i zamówień.

### Omówienie tabel:
*	Adresy – tabela zawiera informacje dotyczące adresów klientów, pracowników oraz dostawców
*	Dostawcy – dane osobowe dostawców, nazwa firmy
*	Pracownicy – dane osobowe pracowników, kontakt, stanowisko, pensja
*	Klienci – dane osobowe klientów, kontakt
*	Produkty – nazwa produktów, cena, dostępna ilość, informacja czy są wegański
*	Zamówienia – daty zamówienia i odbioru
*	Szczegóły Zamówień – cena zamówienia, ilość oraz wysokość zniżki
*	Wyroby Cukiernicze – nazwa wyrobów, cena, ilość kalorii, informacja czy są bezglutenowe
*	Sprzedaż – data sprzedaży, informacja czy została wpłacona zaliczka
*	Szczegóły sprzedaży – cena, ilość sprzedanych produktów, wysokość zniżki

### Omówienie funkcji, widoków, procedur i wyzwalaczy:
*	najwyzsza_cena – wyświetla informacje o wyrobach cukierniczych o najwyższej cenie
*	dodaj_adres – procedura dodająca wartości do tabeli Adresy
*	cena_ss – uaktualnia wartość ceny w tabeli Szczegóły Sprzedaży
*	cena_sz - uaktualnia wartość ceny w tabeli Szczegóły Zamówień
*	zamowienia – wyświetla zamówienia złożone po podanej dacie
*	zarobki – zabrania nadawania pensji wartości zero
*	ilosc – zabrania zamawiania większej ilości produktów niż jest dostępna
*	dostawca – zabrania zamawiania produktów od nieznanego dostawcy
*	stanowisko – zabrania sprzedaży pracownikom o stanowisku innym niż kasjer
*	znizka – wprowadza zniżkę dla klientów, którzy wpłacili zaliczkę
*	produkty_weganskie – wyświetla informacje o produktach wegańskich
*	wyroby_bezglutenowe – wyświetla informacje o wyrobach bezglutenowych
*	staly_klient – wyświetla informacje o stałych klientach
*	staly_dostawca – wyswietla informacje o stałych dostawcach
*	zaliczki – wyświetla informacje o zaliczkach
*	zamowione_produkty – wyświetla informacje o zamówionych produktach
*	kalorie – wyświetla informacje o wyrobach posiadających mniejszą kaloryczność niż podana ilość
*	adresy_dostawcow – wyświetla informacje o adresach dostawców
*	adresy_pracowniow – wyświetla informacje o adresach pracowników
*	adresy_klientow – wyświetla informacje o adresach klientów


## Technologia
* T-SQL

## Schemat bazy danych
![diagram1](https://user-images.githubusercontent.com/61416527/126903479-168b0204-c71e-4b72-b790-6000ac6c1ef2.png)

