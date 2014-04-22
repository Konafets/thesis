## TYPO3
Content-Management-System, Web-Content-Managentsystem, Enterprise-Content-Management-System oder Content-Management-Framework. 

In diesen Kapitel werden diese Begriffe erläutert und in welchen Bezug sie zu TYPO3 stehen.

TYPO3 CMS ist ein \gls{wcms} und wurde von dem dänischen Programmierer Kaspar Skårhøj im Jahr 1997 zunächst für seine Kunden entwickelt - im Jahr 2000 von ihm unter der \gls{gpl2} veröffentlicht. Dadurch fand es weltweit Beachtung und erreichte eine breite Öffentlichkeit. Laut der Website T3Census\footnote{http://t3census.info/} gab es am 7. April 208561 Installationen von TYPO3 CMS.
\\
\\
    \begin{figure}[h]
			\startchronology[startyear=1995, stopyear=2015]
			\chronoevent{1997}{Beginn der Entwicklung}
			\chronoevent[markdepth=45pt]{2001}{Version 3.0}
			\chronoevent{2006}{Versoin 4.0}
			\chronoevent[markdepth=25pt]{2011}{Versoin 4.5 LTS}
			\chronoevent[markdepth=55pt]{2014}{Version 6.2 LTS}
			\stopchronology
			\caption{Zeitachse der TYPO3 Entwicklung}
		\end{figure}

Im Jahr 2012 entschied sich das Projekt zu einer Änderung in der Namesgebung. Bis zu dem Zeitpunkt gab es die Projekte:

\begin{itemize}
  \item TYPO3 v4 \footnote{TYPO3 stellt dabei das bis dahin bekannte, von Skårhøj entwickelte \gls{cms} dar, welches den 4.x Zweig des Projekts darstellt.}
  \item FLOW3
  \item TYPO3 5.0 bzw. TYPO3 Phoenix
\end{itemize}

Eine Änderung wurde notwendig, da schon länger abzusehen war, dass TYPO3 Phoenix nicht den Nachfolger von TYPO3 v4 darstellen würde. Somit war die Entwicklung von TYPO3 v4 in dem Versionszweig 4.x gefangen und konnte keine neuen Features einbauen oder veraltete Funktionen entfernen.

Durch das neue Namesschema bekommt der Name TYPO3 die Bedeutung einer Dachmarke während TYPO3 v4, FLOW3 und TYPO3 Phoenix Produkte darstellen. Die neue Namen im Einzelnen:

\begin{itemize}
	\item aus TYPO3 v4 wird TYPO3 CMS
	\item aus FLOW3 wird TYPO3 Flow 
	\item und aus TYPO3 5.0 / TYPO3 Phoenix wird TYPO3 Neos
\end{itemize}

Im weiteren Verlauf dieser Arbeit werden ausschließlich die neuen Namen verwendet.

Heute kümmert sich je ein Team um die Entwicklung von TYPO3 CMS und eines um TYPO3 Flow und TYPO3 Neos. Dahinter steht keine Firma, wie es bei anderen Open Source Projekten wie Drupal (Acquia) oder Wordpress (Automattic) vorzufinden ist, sonderen die \gls{t3assoc} TYPO3 Association (T3Assoc). Die \gls{t3assoc} ist ein gemeinnütziger Verein und wurde 2004 von Kaspar Skårhøj und andern Entwicklern gegründet um als Anlaufstelle für Spenden zu dienen, die die langfristige Entwicklung von TYPO3 sicherstellen sollen. Die Spenden werden in Form von Mitgliedsbeiträgen erhoben.\footnote{http://association.typo3.org/}

### Definition

Das System ist ein klassisches \gls{cms}, welches auf die Erstellung, die Bearbeitung und das Publizieren von Inhalten im Intra- oder Internet spezialisiert ist, was es somit per Definition zu einem \gls{wcms} macht.

Daneben wird TYPO3 auch als \gls{ecms} bezeichnet\footnote{http://www.typo3.org}, was als Hinweis auf den Einsatz des Systems für mittel- bis große Webprojekte dient.

TYPO3 stellt zudem verschiedene \gls{api}s bereit, wodurch es auch als \gls{cmf} bezeichnet wird:
		
\begin{minted}{html}
<!-- 
  This website is powered by TYPO3 - inspiring people to share!
  TYPO3 is a free open source Content Management Framework
  initially created by Kasper Skaarhoj and licensed under GNU/GPL.
  TYPO3 is copyright 1998-2012 of Kasper Skaarhoj. Extensions
  are copyright of their respective owners.
  Information and contribution at http://typo3.org/
-->
\end{minted}

### Architektur und Aufbau von TYPO3

Im folgenden werden die grundlegenden Konzepte von TYPO3 CMS vorgestellt. Dort wo es für das weitere Verständis notwenig ist, wird tiefer in das Thema eingestiegen. Ansonsten werden die Konzepte lediglich angerissen um einen generellen Überblick zu erhalten.

#### Webstack als Basis

TYPO3 CMS wurde in PHP - basierend auf dem Konzept der Objektorientierung - geschrieben und ist damit auf jeder Platform lauffähig, die über einem PHP Interpreter verfügt. Die Version 6.2 von TYPO3 CMS benötigt mindestens PHP 5.3.7.

PHP bildet zusammen mit einem Apache Webserver und einer MySQL Datenbank den sogenannten Webstack, der abhängig von dem eingesetzten Betriebssystem MAMP (OSX / \bfseries{M}ac), LAMP (\bfseries{L}inux) oder WAMP (\bfseries{W}indows) heißt.

In der Standardeinstellung kommt MySQL als Datenbank zum Einsatz - durch die Systemextension [Glossar] können jedoch auch Datenbanken anderer Hersteller angesprochen werden. Eine genaue Analyse dieser Extension erfolgt im Kapitel [KAPITEL zur Analyse von ext:DBAL einfügen].


#### Ansichtssache

Aus Anwendersicht teilt sich TYPO3 in zwei Bereiche:

\begin{itemize}
    \item das Backend\\
          stellt die Administrationsoberfläche dar. Hier erstellen und verändern Redaktuere die Inhalte während Administratoren das System von hier aus konfigurieren
    \item das Frontend\\
          stellt die Website dar, die ein Besucher zu Gesicht bekommt.
\end{itemze}
(vgl. \cite[S. 5]{book:dulepovTypo32008)

[Skizze Backend / Frontend einfügen]


#### Der Systemkern und die APIs
TYPO3 CMS besteht aus einem Systemkern, der lediglich grundlegende Funktionen zur Datenbank-, Datei- und Benutzerverwaltung zu Verfügung stellt. Dieser Kern ist nicht monolithisch aufgebaut, sondern besteht aus Systemextensions. (vgl. \cite[S. 32]{book:laborenzTypo32006})

Die Gesamtheit aller von TYPO3 CMS zur Verfügung gestellten APIs, wird als die "TYPO3 API" bezeichnet. Diese kann - analog zum Backend / Frontend Konzept - in eine Backend API und eine Frontend API unterteilt werden kann. Die Aufgabe der Frontend API ist die Zusammenführung der getrennt vorliegenden Bestandteile (Inhalt, Struktur und Layout) aus der Datenbank oder dem Cache zu einer HTML-Seite. Die Backend API stellt Funktionen zur Erstellung und Bearbeitung von Inhalten zur Verfügung. (vgl. \cite[S. 5 ff.]{book:dulepovTypo32008})

Die APIs, die keiner der beiden Kategorien zugeordnet werden kann, bezeichnet \cite[S. 5 ff.]{book:dulepovTypo32008} als "Common"-API. Die Funktionen der Common-APi werden von allen anderen APIs genutzt. Ein Beispiel dafür stellt die Datenbank API dar, welche in der Regel nur einfache Funktionen wie das Erstellen, Einfügen, Aktualisieren, Löschen und Leeren \footnote{CRUD - \bfseries{C}reate, \bfseries{R}etrieve, \bfseries{U}pdate und \bfseries{D}elete) von Datensätzen bereitzustellen hat. Würde man je eine Datenbank API für das Frontend und das Backend zur Verfügung stellen, bricht man eine wichtige Regel der Objekt-orientierten Programmierung - Don't repeat yourself. Dieser - mit hoher Wahrscheinlichkeit - redundanter Code würde die Wartbarkeit des Programms verschlechtern und die Fehleranfälligkeit erhöhen.

Auf die aktuelle Datenbank-API wird in [KAPITEL zur Analyse der aktuellen Situation einfügen] näher eingegangen.

#### Verzeichnisstruktur

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

#### Verzeichnisstruktur

#### XCLASS

#### TCA

* Interner Aufbau durch Extensions √
* in PHP geschrieben √
* läuft auf einem Webserver (Apache oder Nginx) √
* standardmäßig MySQL Datenbank √
* kann über DBAL mit anderen DBs benutzt werden √
* geht DBAL überhaupt mit Version 6.2?
* Extbase und pi-Based erwähnen
* Unterschiede erklären
* erklären warum eskeinen Sinn macht weder den einen noch den anderen Ansatz zu wählen
* Low-Level
* TCA
* XCLASS
* Aufbau von TYPO3 erklären
  * Frontend / Backend √
  * Core √
  * Verzeichnisstruktur √
  * einzelne Dateien (LocalConf, index.php, Symlinks) √
* Aufbau von Extension erklären
  * Verzeichnisstruktur
  * Namenskonventionen
  * was machen all die Dateien

