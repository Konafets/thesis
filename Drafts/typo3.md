## TYPO3

* in PHP geschrieben 
* läuft auf einem Webserver (Apache oder Nginx)
* standardmäßig MySQL Datenbank
* kann über DBAL mit anderen DBs benutzt werden
* geht DBAL überhaupt mit Version 6.2?
* Extbase und pi-Based erwähnen
* Unterschiede erklären
* erklären warum eskeinen Sinn macht weder den einen noch den anderen Ansatz zu wählen
* Low-Level
* TCA
* XCLASS
* Aufbau von TYPO3 erklären
  * Verzeichnisstruktur √
  * einzelne Dateien (LocalConf, index.php, Symlinks) √
* Aufbau von Extension erklären
  * Verzeichnisstruktur
  * Namenskonventionen
  * was machen all die Dateien

Content-Management-System, Web-Content-Managentsystem, Enterprise-Content-Management-System oder Content-Management-Framework. 

In diesen Kapitel werden diese Begriffe erläutert und in welchen Bezug sie zu TYPO3 stehen.


### Geschichte
TYPO3 ist ein TYPO3 ist ein \gls{wcms} Web Content Management-System (WCMS) und wurde vom Dänen Kaspar Skårhøj zunächst für seine Kunden entwickelt - im Jahr 2000 von ihm unter der \gls{gnu2} veröffentlich. Dadurch wurde es einer breiten Öffentlichkeit bekannt und fand weltweit Beachtung. 

Im April 2007 hat sich Skårhøjs aus dem Projekt zurückgezogen um die Entwicklung in die Hände einer neuen Generation zu geben. Projektleiter des CMS ist Oliver Hader; für TYPO3 Flow and TYPO3 Neos Robert Lemke. 

\startchronology[startyear=1995, stopyear=2015]
	\chronoevent{1997}{Beginn der Entwicklung}
	\chronoevent[markdepth=45pt]{2001}{Version 3.0}
	\chronoevent{2006}{Versoin 4.0}
	\chronoevent[markdepth=25pt]{2011}{Versoin 4.5 LTS}
	\chronoevent[markdepth=55pt]{2014}{Version 6.2 LTS}
\stopchronology

Hinter der Marke TYPO3 steht keine Firma, sondern alle Projekte werden allein von der Community betreut und weiterentwickelt.

Laut der Website TYPO3 Census\footnote{http://t3census.org} existierten am 07.04.2014 weltweit 208.561 TYPO3 Installationen. 

In der Literatur und auf der Projektseite von TYPO3\footnote{http://typo3.org/} findet sich noch der Begriff \gls{ecms} Enterprise Content Management-System (ECMS), was auf den Einsatz von TYPO3 in großen Projekten hinweisen soll.

### TYPO3 als CMS
\cite[Seite 2]{Content-Management-Systeme (CMS) sind Anwendungen, die das Erstellen, die Kontrolle, die Freigabe, die Publikation, die Archivierung und die Individualisierung von Inhalten im Inter-, Intra oder Extranet ermöglichen. Sie sind darauf ausgelegt einerseits dem Anwender einen einfachen Zugang zum Publikationsprozess zu verschaffen und anderseits eine systemtechnische Grundlage für die Verwaltung darzustellen.}

Die Frage was TYPO3 eigentlich ist, ist gar nicht so einfach zu beanworten, da es dabei auf die Sichweise ankommt. Allgemein wird es als Content-Management-System bezeichnet. Da es sich um den Inhalt von Webseiten kümmert, kann gesagt werden, dass TYPO3 ein Web Content Management System ist (WCMS). Fragt man das TYPO3 Marketing Team, so würde man wohl die Antwort erhalten, dass TYPO3 ein Enterprise Content Management System ist, da es vorwiegend für umfangreiche Webprojekte von Unternehmen eingesetzt wird, anstatt als Basis für die Webvisitenkarte.




[Skizze Backend / Frontend einfügen]

Für das Grundverständnis ist es wichtig zu wissen, dass sich TYPO3 in ein Backend und ein Frontend unterteilt, wobei letzteres naturgemäß für die Webseitenbenutzer sichtbar. Das Backend wird zur Konfiguration, Administration und der Pflege der Website benutzt und ist deshalb nur für einen internen Personenkreis verfügbar. 

Aus der Perspektive eines Programmierers, ist TYPO3 ein Framework und wird deshalb auch als Content-Manangement-Framework (CMF) [Abkürzungsverzeichnis] bezeichnet. 

Eine der großen Stärken des System ist seine nahezu unendliche Erweiterbarkeit durch ein Pluginsystem. Plugins werden in der TYPO3 Terminologie als Extensions bezeichnet, wobei man zwischen System- und „normalen“ Extensions unterscheidet. 

Systemextensions, sind für den Betrieb einer TYPO3 Instanz unverzichtbar - sie \emph{sind} das System, während mit normalen Extensions solche bezeichnet werden, die aus der Community kommen. Diese sind im TYPO3 \gls{ter}\footnote{http://typo3.org/extensions/repository/} zu finden.

Die Datenbank-API ist eine der vielen APIs, die TYPO3 anbietet. Sie wird vom Core\footnote{Programmkern - eine Teilmenge von unverzichtbaren Systemextensions} genutzt und es wird den Entwicklern von Extensions sehr empfohlen diese API in ihrem Code zu verwenden anstelle von eigenen Queries.\footnote{Es ist aktuell möglich komplett an der Datenbank API vorbei mit der Datenbank zu kommunizieren.}



Seine Mächtigkeit erhält TYPO3 durch dessen Erweiterbarkeit über Extensions, durch die das System nahezu jeder Anforderung angepasst werden kann. Aus diesem Grund wird es auch oft als Content-Management-Framework bezeichnet, da es Drittparteien möglich ist - wie in der Einleitung schon angeklungen ist - das System durch eigene Extension zu erweitern. Dem sind fast keine Grenzen gesetzt.

TYPO3 ist eine klassische Datenbankanwendung, welche die Trennung von Inhalt, Struktur und Design befolgt, in dem es die Inhalte in einer Datenbank speichert, die Struktur in HTML Templates und das Design durch CSS Styles vorhält. 

Backend / Frontend Konzept

[Bild einfügen]

Das System unterscheidet zwischen einem Backend und einem Frontend, die strikt voneinander getrennt sind, jedoch beide auf die Datenbank zugreifen. Intern besteht das TYPO3 aus verschiedenen Systemextensions, die genauso aufgebaut sind, wie extene Extensions, mit dem Unterschied, dass es ohne sie nicht funktionieren würde. Sucht man den Kern von TYPO3, so findet man die Core Extension, die auch die Anbindung an die Datenbank bereitstellt.

### Was ist ein Framework

### TYPO3 als Framework
Schaut man in den Quellcode einer TYPO3 Website, so sieht man in der Regel diesen HTML Kommentar:

    <!-- 
	    This website is powered by TYPO3 - inspiring people to share!
	    TYPO3 is a free open source Content Management Framework initially created by Kasper Skaarhoj and licensed under GNU/GPL.
	    TYPO3 is copyright 1998-2012 of Kasper Skaarhoj. Extensions are copyright of their respective owners.
	    Information and contribution at http://typo3.org/
    -->
    
Aus der Sicht seines Erfinders ist TYPO3 ein Content Managment Framework. 



### Architektur und Aufbau von TYPO3

In der im März 2014 erschienen Version 6.2 gab es viele grundlegende Änderungen am Dateisystem, die hier kurz erläutert werden. Dies schafft das notwendige Grundwissen um im späteren Verlauf die Zusammenhänge des Eingreifens des Prototypen in das System herzustellen.

Im Gegensatz zu frühren TYPO3 Versionen gibt es kein "Dummy"-Package\footnote{Damit ist ein weitgehend leeres Paket gemeint, dass alle Dateien enthält die im Webroot des Servers laufen sollen. Es stellt einen Container für die spätere Website dar.} mehr. Ab Version 6.2 enhält der Download lediglich den TYPO3 Kern in Form des Verzeichnisses *typo3/*.

Dieses Verzeichnis ist außerhalb des Webroots abzulegen. Im Webroot ist ein Verzeichnis *www.example.com* anzulegen, in dem die Verzeichnisse *fileadmin/*, *typo3conf/*, *typo3temp/* und *uploads/* anzulegen sind. Das Verzeichnis *typo3_src/* ist ein (Linux) Symlink auf das Installationsverzeichnis von TYPO3 und das Verzichnis *typo3/* ist ebenfalls ein Symlink, welcher auf über den Symlink *typo3_src* auf *typo3* zeigt. Dieser Aufbau macht ein Update recht einfach, da lediglich der Symlink *typo3_src* auf das Installationverzeichnis der neuen Version "umgebogen" werden muss. 

	.
	├── Packages/
	│   └── Libraries/
	├── fileadmin/
	├── typo3_src/ -> ../../typo3-6.2.0
	├── typo3/ -> typo3_src/typo3
	│   ├── contrib/
	│   ├── ext/
	│   ├── gfx/
	│   ├── install/
	│   ├── js/
	│   ├── mod/
	│   └── sysext/
	├── typo3conf/
	│   ├── ext/
	│   │   ├── doctrine_dbal/
	│   │   └── phpunit/
	│   └── l10n/
	├── typo3temp/
	└── uploads/
	    ├── media/
	    ├── pics/
	    ├── tf/
	    └── tx_phpunit/
	    
Im folgenden werden die einzelen Verzeichnisse näher erklärt:

| Verzeichnis         | Erklärung |
|---------------------|-----------|
| Packages/Libraries/ | Dieser Ordner ist neu und wurde von der Packageverwaltug von TYPO3 Flow übernommen. Ziel ist hier, dass die heuzutage als Extension bezeichnete Erweiterungen von TYPO3 in einer der nächsten Versionen als Packages umdefiniert werden. Im aktuellen Fall liegen hier externe Bibliotheken, die zum Bespiel mit Composer\footnote{Ein Kommandozeilen Programm um Abhängigkeiten in PHP Projekten aufzulösen. https://getcomposer.org/‎} installiert wurden, wie zum Beispiel Doctrine DBAL          |
| fileadmin/          | In diesem Ordner werden Dateien gespeichert, die über die Website erreichbar und ausgeliefert werden sollen. Dazu zählen CSS-, Image, HTML-Template- und TypoScriptdateien. Allgemein also Dateien, die vom Websitebetreiber hochgeladen werden.
| typo3/              | Der TYPO3 Kern
|   contrib/          | Bibliotheken von Drittanbietern
|   ext/              | Das Verzeichnis für globale Extensions
|   gfx/              | Jegliche Grafiken die im Core verwendet werden
|   install/          | Hier befand sich in früheren Versionen das Installtool. Aktuell existiert das Verzeichnis nur noch aus Gründen der Abwärtskompatibiliät und wird in einer der nächsten Versionen entfernt. Das Installtool wurde als Sytemextension realisiert und ist im entsprechenden Ordner unter *sysext/install/* zu finden.
|   js/               | Hier befinden sich die JavaScript Bibliotheken, die von Core genutzt werden.
|   mod/              | Enthält die Konfiguration der Hauptmodule des Backends (File, Help, System, Tools, User, Web).
|   sysext/           | Enthält die Systemextensions. Letztendlich kann man sagen, dass dies der Core ist.
| typo3conf/          | Lokale Extensions und die lokale Konfiguration
| typo3temp/          | Temporäre Dateien
| uploads/            | Dateien die vom Websitebesucher hochgeladen werden - zum Beispiel über ein Formular.

Im Verzeichnis *www.example.com* muss noch ein Symlink *index.php* angelegt werden, welcher auf *typo3_src/index.php* zeigt.

Unter *www.example.com/typo3conf/* befindet sich die Datei *LocalConfiguration.php*. Diese enthält die Grundkonfiguration in Form eines Arrays. Darin sind verschiedenen Einstellungen festgelegt:

* Debug Mode
* Sicherheitslevel für den Login (Fronend und Backend)
* das Passwort für das Installtool (mit MD5 und Salt gehasht)
* die Zugangsdaten zur Datenbank (Benutzername, Password, Datenbankname, Socket, …)
* Einstellungen zum Caching
* Titel der Website
* Einstellungen zum Erzeugen von Graphiken

Die Einstellungen zur Datenbank werden im praktischen Teil näher beleuchtet.

### Extensions

Extensions sind funktionale Erweiterungen, welche in System-, globale\footnote{Das Feature von globalen Extension funktioniert immer noch, wird jedoch nur noch vereinzelt genutzt und es gibt Bestrebungen es ganz zu entfernen. Da sie außerdem nicht zum weiteren Verständis der Arbeit benötigt werden, wurden sie hier nur der Vollständigkeit halber erwähnt.} und lokale Extensions unterteilt werden. 

#### Einteilung

Systemextension werden mit dem System mitgeliefert und befinden sich ausschließlich im Ordner *typo3/sysext/*. Sie werden nochmals unterteilt in jene, die für den Betrieb von TYPO3 unabdingbar sind und solche die nicht zwangsläufig installiert sein müssen, jedoch wichtige Funktionen beisteuern. Die Extension DBAL ist solch eine Erweiterung, auf die im Kapitel \ref{extDBAL} näher eingegangen wird.

Mit dem Begriff "Extension" ist jede andere Extension gemeint, auf die die oben genannten Bedingungen nicht zutreffen. Lokale Extension werden im Ordner *typo3conf/ext/* und globale Extensions im Ordner *typo3/ext* installiert.

#### Interner Aufbau durch Extensions
