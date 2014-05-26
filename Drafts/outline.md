# Abstract

# Einleitung 
(aka Houston, we have a problem)

## Motivation
## Ziel
auch was nicht bearbeitet wird und warum nicht
## Aufbau der Arbeit

# Grundlagen (besseren Titel finden)
(Vorstellung der verwendeten Werkzeuge)

* warum TYPO3
* warum Dotrine und nicht Propel

## TYPO3
* in PHP geschrieben
* läuft auf einem Webserver (Apache oder Nginx)
* standardmäßig MySQL Datenbank
* kann über DBAL mit anderen DBs benutzt werden
* geht DBAL überhaupt mit Version 6.2?

### Geschichte
### Was ist ein CMS
### TYPO3 als CMS
### TYPO3 als Framework
### Extensions
* Extbase und pi-Based erwähnen
* Unterschiede erklären
* erklären warum eskeinen Sinn macht weder den einen noch den anderen Ansatz zu wählen
* Low-Level
* TCA
* XCLASS
* Aufbau von Extension erklären
  * Verzeichnisstruktur
  * Namenskonventionen
  * was machen all die Dateien
   
## Doctrine
### Geschichte
### Aufbau
#### ORM
#### DBAL
#### PDO


# Analyse der aktuellen Situation
(aka Status quo)

## natives MySQL
### Aufbau
### DatabaseConnection
### PreparedStatements
### DataHandler
### Typo3DatabaseBackend (Extbase Portal to TYPO3 Database)

## Extension DBAL 

* Installation
* handlerCfg
* native
* AdoDB
* Aufbau

# Sicherheit
## Prepared Statements

# Prototypischer Nachweis der Herstellbarkeit
## Entwurf
(aka I have an idea how to get out of here)
## Umsetzung
(Look mami, this is how I solved the problem)
### Arbeitsweise (besseren Titel finden)
* GIT
* Github
  * Quellcodeverwaltung
  * Issues
* PHPUnit
* Verwendete IDE
#### Erstellen der Extension über den Extension Builder


# Schlussbetrachtung
(My results are)
## Zusammenfassung
## Ausblick
