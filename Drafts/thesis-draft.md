# Abstract
In der Defaulteinstellung speichert das CMS TYPO3 die Inhalte der Website in einer MySQL-Datenbank. Soll sich das CMS mit der Datenbank eines anderen Herstellers verbinden, muss die mitgelieferte Systemextension \emph{DBAL} installiert werden. Damit die Anfrage von der DBAL Extension geparst und in die anderen SQL-Dialekte konvertiert werden kann, müssen sich die Entwickler - sei es TYPO3 Kern- oder externer Extensionprogrammier - an gewisse Richtlinien, wie zum Beispiel die ausschließliche Nutzung der TYPO3 Datenbank API, halten. Trotz der Nutzung der API können zu DBAL inkompatible Anfragen formuliert werden. Ferner ist es möglich komplett an der API vorbei mit der Datenbank zu kommunizieren, wodurch man wieder beim Anfangsproblem angelangt ist, welches man mit der Nutzung der DBAL Extension lösen wollte: Die Fixierung auf einen SQL-Dialekt. Desweiteren verwendert die DBAL Extension die extene Bibliothek \emph{AdoDB} welche nicht mehr aktiv weiterentwickelt wird und weder Verbessungen noch Sicherheitsupdates bereitstellt. Ziel dieser Arbeit war es zum einen die veraltete Bibliothek gegen eine andere - in dem Fall Doctrine 2 DBAL - zu ersetzen, die in sich unter aktiver Entwicklung befindet, und zum anderen eine einheitlichen Zugriff auf die Datenbank zu erlauben, der die direkte Kommunikation mit der Datenbank verbietet. Es wurde eine Extension geschrieben, die die TYPO3 eigene Datenbank API überschreibt und anstelle dessen eine eigene API anbietet, die über Doctrine DBAL und PDO auf die Datenbank zugreift. Dabei wurde auf die Abwärtskompatibilität zur TYPO3 eigenen API geachtet, dass noch nicht angepasster Code weiterhin mit der Datenbank kommunizieren kann. Zu Test- und Demonstrationszwecken wurde der Kern von TYPO3 an die neue API Dies erlaubt das manuelle Testen der Funktionsweise des Backends und des Frontends - es wurden jedoch auch Unit Tests für die API implementiert, wodurch das auch das automatische Testen ermöglicht wird.


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

## DBAL 

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
