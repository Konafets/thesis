# Abstract
In der Defaulteinstellung speichert das CMS TYPO3 die Inhalte der Website in einer MySQL-Datenbank. Soll sich das CMS mit der Datenbank eines anderen Herstellers verbinden, muss die mitgelieferte Systemextension \emph{DBAL} installiert werden. Damit die Anfrage von der DBAL Extension geparst und in die anderen SQL-Dialekte konvertiert werden kann, müssen sich die Entwickler - sei es TYPO3 Kern- oder externer Extensionprogrammier - an gewisse Richtlinien, wie zum Beispiel die ausschließliche Nutzung der TYPO3 Datenbank API, halten. Trotz der Nutzung der API können zu DBAL inkompatible Anfragen formuliert werden. Ferner ist es möglich komplett an der API vorbei mit der Datenbank zu kommunizieren, wodurch man wieder beim Anfangsproblem angelangt ist, welches man mit der Nutzung der DBAL Extension lösen wollte: Die Fixierung auf einen SQL-Dialekt. Desweiteren verwendert die DBAL Extension die extene Bibliothek \emph{AdoDB} welche nicht mehr aktiv weiterentwickelt wird und weder Verbessungen noch Sicherheitsupdates bereitstellt. Ziel dieser Arbeit war es zum einen die veraltete Bibliothek gegen eine andere - in dem Fall Doctrine 2 DBAL - zu ersetzen, die in sich unter aktiver Entwicklung befindet, und zum anderen eine einheitlichen Zugriff auf die Datenbank zu erlauben, der die direkte Kommunikation mit der Datenbank verbietet. Es wurde eine Extension geschrieben, die die TYPO3 eigene Datenbank API überschreibt und anstelle dessen eine eigene API anbietet, die über Doctrine DBAL und PDO auf die Datenbank zugreift. Dabei wurde auf die Abwärtskompatibilität zur TYPO3 eigenen API geachtet, dass noch nicht angepasster Code weiterhin mit der Datenbank kommunizieren kann. Zu Test- und Demonstrationszwecken wurde der Kern von TYPO3 an die neue API Dies erlaubt das manuelle Testen der Funktionsweise des Backends und des Frontends - es wurden jedoch auch Unit Tests für die API implementiert, wodurch das auch das automatische Testen ermöglicht wird.


# Einleitung 
## Motivation
Als sich auf den Developer Days 2006 das Entwicklerteam für einen Nachfolger der eben erst erschienen TYPO3 Version 4.0 formierte\\ (vgl.~\cite{web:berlinManifesto2008}), war wohl keinem der dort Anwesenden klar wohin die Reise gehen würde – ging man anfänglich noch von einem Refactoring\footnote{Strukturverbesserung des Quellcodes bei Beibehaltung der Funktionalität} der schon vorhandenen Codebasis aus.

In der Konzeptionsphase kristallisierte sich immer mehr heraus, dass es damit nicht getan sein würde. Der Nachfolger mit dem Arbeitstitel ``Phoenix'' sollte nicht nur den zukünftigen Anforderungen des Web standhalten, sondern die Position der Version 4.0 weiter ausbauen. Das Entwicklerteam um Chefentwickler Robert Lemke entschloss sich die Version 5.0 des Systems komplett neu zu schreiben [Quelle anfügen] und merkte dabei, dass Entwickler bei der Programmierung von Webanwendungen immer wieder mit den gleichen Problemen wie Routing, die Erstellung und Validierung von Formularen, Login von Benutzern oder dem Aufbau einer Verbindung zur Datenbank konfrontiert werden.

Die Idee eines – von dem Content-Management-System – unabhängigen PHP Frameworks war geboren und wurde zunächst auf den Namen FLOW3 getauft. Dieses Framework sollte die spätere Basis für TYPO3 5.0 bilden und all die oben beispielhaft angeführten wiederkehrenden Aufgaben übernehmen. Die Version 5.0 von TYPO3 sollte lediglich eins von vielen Packages darstellen mit denen FLOW3 erweitert werden kann. Vielmehr wurde es als eigenständiges ``Webapplication Framework'' konzipiert und umgesetzt, so dass es auch ohne ein \gls{cms} betrieben werden kann und auch wird. [Quelle zu Rossmann einfügen].

Schon in einer recht frühen Entwicklungsphase hat man sich dem Thema Persistenz gewidmet, die zunächst noch als ``\gls{jcr}'' in PHP implementiert, jedoch später wegen zu vieler Probleme bei der Portierung der Java Spezifikation JSR-170 nach PHP durch eine eigene Persistenzschicht ersetzt wurde (vgl.~\cite{web:dambekalnsFroscamp2010}). Im weiteren Verlauf der Entwicklung kam man von dieser Idee wieder ab, da die eigene Persistenzschicht nicht performant genug war und andere Projekte wie Doctrine oder Propel schon fertige Lösungen anboten (vgl.~\cite{twitter:DoctrineFlow2014}). Schlußendlich entschied man sich für die Integration von Doctrine als Persistenzschicht, da der Hauptentwickler von Doctrine, Benjamin Eberlei, seine Hilfe anbot.

Für die Anwender stellt sich bei einem Versionssprung stets die Frage, ob eine Migration von der alten zur neuen Version möglich ist und mit wieviel Aufwand dies verbunden sein würde. Diesen Bedenken folgend trafen sich die Kernentwickler beider Teams 2008 in Berlin, um die Routemaps beider Projekte in Einklang zu bringen. Als ein Ergebnis dieses Treffens wurde das ``Berlin Manifesto''(vgl.~\cite{web:berlinManifesto2008}) bekanntgegeben, welches mit kappen Worten feststellt\footnote{Mittlerweile wird TYPO3 Neos innerhalb der Community nicht mehr als der Nachfolger von TYPO3 \gls{cms} angesehen. Es stellt lediglich – wie TYPO3 Flow – ein weiteres Produkt innerhalb der TYPO3 Familie dar. [Quellen angabe]}:
\begin{shadequote}[l]{Die TYPO3 Kernentwickler}
	\begin{itemize}
		\item TYPO3 v4 continues to be actively developed
		\item v4 development will continue after the the release of v5
		\item Future releases of v4 will see its features converge with those in TYPO3 v5
		\item TYPO3 v5 will be the successor to TYPO3 v4
		\item Migration of content from TYPO3 v4 to TYPO3 v5 will be easily possible
		\item TYPO3 v5 will introduce many new concepts and ideas. Learning never stops and we'll help with adequate resources to ensure a smooth transition
	\end{itemize}
\end{shadequote}

An der Umsetzung wurde sofort nach dem Treffen begonnen, indem Teile des FLOW3 Frameworks nach TYPO3 Version 4.0 zurück portiert und unter dem Namen \emph{Extbase} als Extension veröffentlicht wurden. Es erfüllt zu gleichen Teilen die Punkte 3 und 6 des Manifests, da es die neuen Konzepte aus FLOW3 der Version 4.0 zur Verfügung stellt und somit gleichzeitig diese Version näher an die Technologie des Frameworks heranführt.

Die Aufgabe von Extbase besteht darin ein \gls{api} bereitzustellen, mit denen Entwickler von Extensions auf die internen Ressourcen und Funktionen von TYPO3 \gls{cms} zugreifen und das System somit nach eigenen Wünschen und Anforderungen erweitern können, ohne den Code des \gls{cms} selbst verändern zu müssen. Es ist als vollständiger Ersatz der bis dahin angebotenen PI-Base \gls{api} [LINK ZU PI BASE] konzipiert worden, wobei es aktuell noch möglich ist sich für einen der beiden Ansätze zu entscheiden.

Extbase führt per Definition einige – bis dahin in TYPO3 v4 unbekannte – Programmierparadigmen ein. Als größter Unterschied zu dem PI-Based Ansatz ist hier sicherlich das \gls{mvc} Pattern zu nennen. Dabei werden die Daten im Model vorgehalten, der View gibt die Daten aus und der Controller steuert die Ausgabe der Daten. Das Model ist unabhängig von der View, was bedeutet, dass die gleichen Daten auf verschiedene Weise ausgegeben werden können. Man denke hier an Meßdaten, die zum einen als Tabelle über einer Listview dargestellt werden können oder als Diagramme mit einer entsprechenden View.

Das Model – eine herkömmliche PHP Klasse – wird dabei von Extbase automatisch auf die Datenbank abgebildet, so dass ein Objekt eine Zeile darstellt und dessen Eigenschaften als Spalten der Tabelle interpretiert werden. Diese Technik wird als Objektrelationale Abbildung (engl. \gls{orm}) genannt. Das zum Einsatz kommende \gls{orm} ist Bestandteil der oben erwähnten selbstgeschriebenen Persistenzschicht von FLOW3, da Extbase zu der Zeit rückportiert wurde, als diese bei FLOW3 im Einsatz war.

Obwohl Extbase beständig weiterentwickelt wird und es der Wunsch der Community ist, die in darin verwendete Persistenzschicht gegen Doctrine 2 auszutauschen, was sich in Form von Posts auf der Mailingliste (vgl.~\cite{web:coreListIntegrateDoctrine2013}) oder in Prototypen ausdrückt (vgl.~\cite{web:maroschikWIP2012} und \cite{web:eberleiExtbaseDoctrineExtension2012}), ist dies bis heute noch nicht realisiert worden. Der Chefentwickler von Doctrine, Benjamin Eberlei, hat gegenüber dem Autor in einer persönlichen Korrespondenz die unterschiedlichen Ansätze beider Projekte wie folgt zum Ausdruck gebracht:
\begin{shadequote}{Benjamin Eberlei per E-Mail vom 17.12.13 00:12}
	(\ldots) Doctrine nutzt das Collection interface, Extbase SplObjectStorage.Doctrine Associationen funktionieren semantisch anders als in Extbase, z.B. Inverse/Owning Side Requirements.
	Typo3 hat die Enabled/Deleted flags an m\_n tabellen, sowie das start\_date Konzept. Das gibts in Doctrine \gls{orm} alles evtl nur über Filter \gls{api}, aber vermutlich nicht vollständig abbildbar.
	Das betrifft aber alles nur das \gls{orm}, das Doctrine \gls{dbal} hinter Extbase zu setzen ist ein ganz anderes Abstraktionslevel.
\end{shadequote}

Zum jetzigen Zeitpunkt wird die \gls{dbal} in TYPO3 durch eine Systemextension [Glossareintrag] bereitstellt, die auf der externen Bibliothek AdoDB basiert, welche jedoch Anzeichen des Stillstands aufzeigt und davon ausgegangen werden kann, dass das Projekt nicht weiterentwickelt wird. [Linkt zu SourceForge]

Anhand dieser Fakten wird ersichtlich, dass die Integration von Doctrine erstrebenswert ist, da dadurch die Abhängigkeit zu dem inaktiven Projekt AdoDB aufgelöst werden kann. Da jedoch eine Integration von Doctrine \gls{orm} in Extbase nicht in der gegebenen Zeit, die für die Bearbeitung der Thesis zur Verfügung steht, zu realisieren ist, wurde der Fokus stattdessen auf die Integration von Doctrine \gls{cms} in TYPO3 gelegt, wodurch nicht nur Extbase von den Möglichkeiten eines \gls{dbal} profitieren kann, sondern der gesamte Core und somit alle Extensions die noch nicht mit Extbase erstellt worden sind.

Ferner wird durch diesen Ansatz eine stabile Basis zu Verfügung gestellt, auf der eine zukünftige Integration der \gls{orm} Komponente von Doctrine in Extbase aufbauen kann.

## Ziel 

	auch was nicht bearbeitet wird und warum nicht

Ziel dieser Thesis ist es einen funktionierenden Prototypen zu entwickeln, der zum einen aus einer Extension besteht, die für die Integration von Doctrine \gls{dbal} zuständig ist und zum anderen aus einem modifizierten TYPO3, welches die neue \gls{api}, die mit der Extension eingeführt wird, beispielhaft benutzt.

## Aufbau der Arbeit
Im ersten Teil werden die eingesetzten Werkzeuge vorgestellt. Es wird erklärt warum diese und nicht andere eingesetzt worden sind und wie diese in Hinblick auf die Aufgabenstellung benutzt wurden.

Der zweite Teil beschreibt die praktische Umsetzung und schließt mit einer Demonstration wie der Prototyp getestet werden kann.

Teil drei gibt einen Ausblick auf die weitere Verwendung des Quellcodes und des Prototypen, während Teil vier mit einem Fazit schließt.

Im Anhang befindet sich neben den obligatorischen Verzeichnissen für Literatur und Abbildungen ein Glossar, sowie das Abkürzungsverzeichnis.




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
* Erstellen der Extension über den Extension Builder

Obwohl die TYPO3 Community sehr auf die Qualität des Codes achtet und es mittlerweile ca. 6458 UnitTests ausgeführt werden\footnote{https://travis-ci.org/TYPO3/TYPO3.CMS/builds/23070563}, gab es nur eine handvoll an Unit Tests für die DatbaseConnection Klasse. 



Es war vielmehr notwendig eine Ebene tiefer anzusetzen und Testcases für die Methoden der alten API zu definieren, die von den Methoden der neuen API erfüllt werden müssen. 

# Schlussbetrachtung
(My results are)
## Zusammenfassung
## Ausblick
