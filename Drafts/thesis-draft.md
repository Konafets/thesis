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




# Grundlegendes / Grundlagen / Basics / 
In diesem Kapitel werden die Werkzeuge vorgestellt, die im praktischen Teil verwendet wurden. Dies umfasst sowohl die verwendeten Programmbibliotheken, sowie die Infrastruktur für die \gls{qa} und schließt mit dem Editor ab.

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
Doctrine ist eine Sammlung von PHP Bibliotheken, die einen abstrahierten Zugriff auf Datenbanken unterschiedlicher Hersteller ermöglichen. Es orientriert sich an Javas Hibernate. (http://t3n.de/magazin/jonathan-wage-seinen-einstieg-doctrine-zukunft-projekts-224058/2/) und Rubys Active Record \footnote{Wobei Active Record nicht auf Ruby beschränkt ist, sondern ein Entwurfsmuster darstellt, welches von Martin Fowler in seinem Buch [Patterns of Enterprise Application Architecture by Martin Fowler] vorgestellt wurde.}

Geschichte
----------

Das Projekt wurde 2006 von Konsta Vesterinen (http://docs.doctrine-project.org/projects/doctrine1/en/latest/en/manual/acknowledgements.html) initiiert und  Im weiteren Verlauf der Entwicklung wurde es von Jonathan Wage übernommen und unter dessen Leitung im Jahr 2008 als Version 1.0.0 (http://www.doctrine-project.org/2008/09/01/doctrine-1-0-released.html) veröffentlicht. 

Zwei Jahre später wurden von neuen Projektleiter Benjamin Eberlei die Version 2.0.0 veröffentlicht. Der Code wurde zum Teil von Grund auf neu geschrieben oder so stark umstrukturiert, dass es mit dem Version 1 - außer dem Namen - nichts mehr gemeinsam hat.
 (http://www.doctrine-project.org/2010/12/21/doctrine2-released.html)

Die beiden bekanntesten Bibliotheken sind DBAL und der auf DBAL aufbauende ORM. Oft wird Doctrine als Synonym für den ORM verwendet, was jedoch irreführend ist, da DBAL unabhängig von ORM verwendet werden kann.

[Grafik über den Aufbau von Doctrine 2 einfügen]

ORM
---

„Ein ORM ist eine Abstraktionsschicht zwischen relationaler Datenbank und der eigentlichen Anwendung. Statt per SQL kann man durch das ORM objektorientiert auf die Daten zugreifen.“ (Jonathan Wage, http://t3n.de/magazin/jonathan-wage-seinen-einstieg-doctrine-zukunft-projekts-224058/)

Was das bedeutet, sei an folgendem Beispiel erläutert:
    
    <?php
    
    $student = new Student();
    $student->setFirstName('Stefano');
    $student->setLastName('Kowalke');
	$student->setEnrolmentNumber('12345');
	$entityManager->persist($student);
	$entityManager->flush();

im Vergleich dazu das Vorgehen ohne ORM:

	<?php
	
	$sql = 
	    'INSERT INTO students ('first_name', 'last_name', 'enrolment_number') 
	    VALUES ('Stefano', 'Kowalke', '12345');

    mysqli_query($con, $sql);

Hier stellt sich die Frage warum der erste Ansatz mit deutlich mehr Code dem zweiten Ansatz mit nur zwei Zeilen vorzuziehen ist. 

In der Tat macht es wenig Sinn zuerst ein Objekt zu erstellen, welches dann in der Datenbank gespeichert wird. Jedoch ist es so, dass die Daten in einer sauber - nach dem Konzept der Objektorientierung - programmierten Anwendung ohnehin schon als Objekt vorliegen. Entweder weil sie eingangs aus der Datenbank abgefragt oder von einem Formular zurückgegeben wurden. Geht man von diesem Szenario aus, dann sieht der direkte Weg über ein SQL Statement wie folgt aus:

	<?php
	
    $sql = 
        'INSERT INTO students ('first_name', 'last_name', 'enrolment_number') 
        VALUES ($student->getFirstName(), $student->getLastName(), $student->getEnrolmentNumber());
            
    mysqli_query($con, $sql);

Dieser Code unterscheidet sich dem ersten Blick nicht so sehr wie der Zeile weiter oben. Anstelle dass die Daten direkt in der Abfrage angegeben werden, werden sie nun aus dem Objekt ausgelesen. Er ist jedoch wartungsintensiv, da er jedesmal angepasst werden muss, wenn sich an der Struktur der Datenbank etwas ändert oder sich die zu speichernden Daten ändern,

Nutzt man dagegen ein ORM, so reduziert sich der Code auf zwei Zeilen und ist unabhängig von den zu speichernden Daten, da man lediglich das Objekt übergibt:

	<?php
	
	$entityManager->persist($student);
	$entityManager->flush();

Dies ist zum einen dadurch möglich, da das ORM die Struktur der Datenbank „kennt“ und zum anderen Buch über die geänderten Daten eines Objekts Buch führt. Wird also in Zukunft eine neue Eigenschaft zu der Klasse `Student` hinzugefügt, legt das ORM automatisch eine neue Spalte in der Tabelle an - entfällt eine Eigenschaft, wird die Spalte entfernt \footnote{Dabei ist jedoch vom Entwickler festzulegen, was mit den Daten aus entfernten Spalten geschieht.}

Wärend im ersten CodeListing keine Datenbankfunktion direkt aufgerufen wird, kann man dies jedoch im zweiten Listing in Form von `mysqli_query();` erkennen. Dadurch hat man seine Anwendung an die Datenbankerweiterung MySQL Improved Extension (MySQLi) gebunden. Es ist nun nicht mehr ohne weiteren Code möglich seine Anwendung mit der Datenbank eines anderen Herstellers zu verwenden. Dies kann jedoch gerade im Enterprise Bereich eine Anforderung darstellen und man verkleinert damit schon von Begin an die Menge der potentiellen Benutzer seiner Anwendung.

Es ist somit nicht nur aus Marketing Perspektive von Vorteil mehr als eine Datenbank zu unterstützen, sondern auch aus Sicht der Entwickler. Sie müssen sich dadurch nicht mit den Eigenheiten der zugrunde liegenden Datenbank beschäftigen, sondern können sich voll und ganz auf die eigentliche Aufgabe der Anwendung - die sogenannte Geschäftslogik - zu konzentrieren. 

DBAL
----

Das ist der Punkt an dem das Doctrines DBAL ins Spiel kommt. Es übersetzt die vom ORM kommenden Objekte in das SQL der verschiedenen Datenbankhersteller. Da in der Thesis kein ORM genutzt wurde, wird die Konvertierung in die SQL Dialekte anhand von Doctrines Representation eines Tabellenschemas gezeigt. Das Beispiel ist funktionierender Code, welcher im weiteren Verlauf der Thesis näher erläutert und auch im Projekt benutzt wird. Hier dient er jedoch nur als Beispiel um die Fähigkeiten von DBAL zu demonstrieren.

	<?php

	$schema = new \Doctrine\DBAL\Schema\Schema();
	$beUsers = $schema->createTable('be_users‘);
	$beUsers->addColumn('uid', 'integer', array('unsigned' => TRUE, 'notnull' => TRUE, 'autoincrement' => TRUE));
	$beUsers->addColumn('pid', 'integer', array('unsigned' => TRUE, 'default' => '0', 'notnull' => TRUE));
	$beUsers->addColumn('tstamp', 'integer', array('unsigned' => TRUE, 'default' => '0', 'notnull' => TRUE));
	$beUsers->addColumn('username', 'string', array('length' => 50, 'default' => '', 'notnull' => TRUE));
	$beUsers->addColumn('password', 'string', array('length' => 100, 'default' => '', 'notnull' => TRUE));
	$beUsers->addColumn('admin', 'boolean', array('default' => '0', 'notnull' => TRUE));
	$beUsers->addColumn('usergroup', 'string', array('length' => 255, 'default' => '', 'notnull' => TRUE));
	$beUsers->addColumn('disable', 'boolean', array('default' => '0', 'notnull' => TRUE));
	…
	$beUsers->setPrimaryKey(array('uid'));
	$beUsers->addIndex(array('pid'), 'be_users_pid_idx');
	$beUsers->addIndex(array('username'), 'be_users_username');

	$queries = $schema->toSql($myPlatform);

	// Der Inhalt von $queries für MySQL
	CREATE TABLE `be_users` (
  		`uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
	  	`pid` int(10) unsigned NOT NULL DEFAULT '0',
  		`tstamp` int(10) unsigned NOT NULL DEFAULT '0',
  		`username` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
	    `password` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  		`admin` tinyint(1) NOT NULL DEFAULT '0',
  		`usergroup` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
 	 	`disable` tinyint(1) NOT NULL DEFAULT '0',
		…
  		PRIMARY KEY (`uid`),
  		KEY `be_users_pid_idx` (`pid`),
  		KEY `be_users_username` (`username`)
	) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

	// Der Inhalt von $queries für PostgreSQL
	CREATE TABLE be_users (
  		uid serial NOT NULL,
	 	pid integer NOT NULL DEFAULT 0,
  		tstamp integer NOT NULL DEFAULT 0,
  		username character varying(50) NOT NULL DEFAULT ''::character varying,
  		password character varying(100) NOT NULL DEFAULT ''::character varying,
  		admin boolean NOT NULL DEFAULT false,
  		usergroup character varying(255) NOT NULL DEFAULT ''::character varying,
  		disable boolean NOT NULL DEFAULT false,
		… 
  		CONSTRAINT be_users_pkey PRIMARY KEY (uid)
	) WITH (
  		OIDS=FALSE
	);

Hier kann man die Unterschiede von Datenbanken verschiedener Hersteller erkennen. Alle nutzen den SQL Standard (LINK) - setzen ihn entweder nicht zu 100% um, oder erweitern in mite eigenen Anweisungen. Die Ursachen liegen darin begründet, dass die verschiedenen Hersteller eigene Features in ihre Datenbanken implementiert haben, oder sich die interne Verwaltung der Daten unterscheidet. Dies ist wohl vergleichbar mit dem HTML Standard und den Browser spezifischen Tags. Als Stichwort sei hier SQLite genannt, die die Daten wahlweise in einer Datei oder im RAM speichert und sich somit grundsätzlich von Datenbanken wie MySQL, Postgres oder Oracle unterscheidet, die die Daten in mehren Dateien ablegen. 

Diese Unterschiede werden als SQL Dialekt bezeichnet. (LINK)

Datenbanken verwalten die Daten in Datentypen, wie es von Programmiersprachen bekannt ist. Jedoch bieten nicht alle Hersteller die gleichen Typen an. So gibt es zum Beispiel keinen Boolan Typ in MySQL, jedoch in Postgres. Eine Metasprache wie die von Doctrine angebotene, muß jedoch so generisch ausgestaltet sein damit sie den angebenen Datentyp in das Datenbank spezifische Eqvivalent umsetzen kann.

Zu beachten sind an diesem Beispiel die folgenden Besonderheiten:

* Autoincrement -> autoincrement / Serial
* Boolean -> tinyint / Boolean
* string -> varchar / charakter varying
* primary key -> PRIMARY KEY (`uid`) / CONSTRAINT be_users_pkey PRIMARY KEY (uid)
* $beUsers->addIndex -> KEY `be_users_pid_idx` (`pid`) / Indices werden in Postgres gesondert verwaltet (Screenshot einfügen)


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
Aufgrund seiner Aufgabe stellt der Protoyp einen tiefen Eingriff in die Architektur von TYPO3 dar. Vor diesem Hintergrund ist es umungänglich, dass er alle Anforderungen erfüllt, die an eine Systemextension gestellt werden \footnote{Auch wenn er keine Systemextension ist}. 

Dies fängt mit der Einhaltung der TYPO3 Coding Guidelines an, geht über die Versionierung des Codes hin zum Testen des Prototypes.

#### TYPO3 Coding Guidelines
Programmier neigen zu unterschiedlichen Programmierstilen, was solange kein Problem darstellt, solange sie allein an einem Projekt arbeiten. Kommen mehr Entwickler hinzu und es vermischen sich verschiedene Stile, kann es schnell unübersichtlich werden. Um den Sinn eines Programms zu verstehen, hilft es allmein, wenn die Codebasis in einer konsistenten Form formatiert wurde. Dies erhöht die Wartbarkeit und verbessert die Code Qualität. 

Coding Guidelines stellen dabei das Regelwerk dar auf das sich die Entwickler eines Projekts geeingt haben. 

In den TYPO3 Coding Guidelines\cite{pdf:Typo3CodingGuidelines14} (CGL) wird die Verzeichnisstruktur von TYPO3 selbst, sowie die von Extensions erläutert. Sie erklären die Namenskonventionen für Dateien, Klassen, Methoden und Variablen und beschreiben den Aufbau einer Klassendatei mit notwendigen Inhalt, der unabhängig von dem Zweck der Klasse vorhanden sein muss.

Der größter Teil der CGL behandelt die Formatierung verschiedene Sprachkonstrukte wie Schleifen, Arrays und Bedingungen.

Da das Regelwerk mit 28 Seiten recht umfangreich aussfällt, wird zur Überprüfung des Quellcodes das Programm PHP_CodeSniffer\footnote{Link} in Zusammenhang mit dem entsprechendem Regelset für das TYPO3 Projekt \footnote{Link}.

#### Unit Testing
Eine Anforderung an den Prototyp war, dass er die alte Datenbank API weiterhin unterstützt. Dadurch ist gewährleistet, dass noch nicht angepasste Extensions weiterhin funktionieren. Um dies zu überprüfen muß die Funktionaliät von TYPO3 in Verbindung alter API / neue API fortlaufend getestet werden.

Ein möglicher Ansatz wäre es, mit zwei identischen TYPO3 Installationen zu starten, die mit der Zeit auseinander divergieren, indem eine der beiden APIs immer mehr auf die neue API umgebaut würde. Das Testen dabei kann jedoch nur auf eine stichprobenartige Überprüfung der Funktionaliät des manipulierten Systems beruhen, da es nahezu unmöglich ist, durch dieses manuelle Vorgehen alle Testfälle abzudecken.

Ein andere Ansatz würde auf der Code Ebene ansetzen und pro Methode der alten API verschiedene Testfälle definieren, welche nachvollziehbar wären und immer wieder ausgeführt werden könnten.

Das dafür in Frage kommende Framework heißt PHPUnit\footnote{LINK}. Es stellt das PHP Pedant von dem aus der Javawelt bekannten JUnit dar und wird von TYPO3 unterstützt. TYPO3 bringt selbst schon über 6000 UnitTests mit\footnote{https://travis-ci.org/TYPO3/TYPO3.CMS/builds/23070563}. 

Das eingangs umrissene Szenario stellt lediglich ein greifbares Beispiel für den Nutzen von Unit Tests dar und ist keineswegs auf Spezialfälle wie Refactorings oder dem Austausch einer API beschränkt. In der vorliegenden Arbeit wurden alle implementierten Methoden der neuen API mit Unit Tests - in Verbindung mit PHPUnit -abgedeckt. 

Um die Tests zu starten gibt es mehre Möglichkeiten:

##### Im TYPO3 Backend
[Bild einfügen]

##### Auf der Konsole
[Bild einfügen]

##### In der IDE
[Bild einfügen]

#### GIT
[Bild einfügen]
Als Versionsverwaltung wurde GIT\footnote{http://git-scm.com/} in Verbindung mit dem Code Hostingdienst GiHub\footnote{http://github.com} genutzt. Github dient zum einen als Backup im Falle eines Festplattenausfalls und zum anderen als späterer Anlaufpunkt der Extension für Interessierte.

GitHub bietet zudem auch eine Aufgabenverwaltung\footnote{Issuetracking} an, dass bei dem Projekt mehr oder minder intensiv genutzt wurde, dem jedoch nach der Veröffentlich als OpenSource Software mehr Bedeutung zukommen wird.

Ferner hat sich um GitHub eine Vielzahl von Services entwickelt, welche unter anderen dabei hilft, die CodeQualität zu analysieren. Die zwei zu erwähnenden Projekte sind Travis\footnote{LINK} und Scrutinizer\footnote{LINK}, welche für das Projekt genutzt wurden.


#### Travis-CI
[Bild einfügen]
Travis-CI ist ein Continuous Integration\footnote{Kontinuierliche Integration} (CI) Service, welcher auf Github gehostete baut\footnote{Der Begriff "bauen" kommt von Sprachen wie C oder Java, die erst kompiliert werden müssen (engl. to compile oder to build), bevor sie ein ausführbares Programm darstellen. Im Gegesatz zu interpretierten Sprachen, die zur Laufzeit von einem Interpreter übersetzt werden. Hier definiert der Begriff "bauen" im Zusammmenhang mit CI das auschecken des Codes aus einem Repository und die Ausführung von:

* Tests (Unit-, Smoke-, Akteptanz- und Behaviortests), 
* statischer Codeanalysen wie den oben genannten PHP_CodeSniffer, PHPDepend\footnote{LINK}, PHP Mess Detection\footnote{LINK} oder PHP Copy and Paste\footnote{LINK} 
* oder das Verpacken der Software in ein Realease fähiges Format wie PHAR\footnote{LINK} oder einen Tarball\footnote{LINK}}.

Die Konfiguration von Travis-CI erfolgt über eine Textdatei im YAML-Format\footnote{LINK} und liegt im Wurzelverzeichnis des Projekts.

[Beispiel einer YAML Datei für Travis einfügen]

Da der Prototyp aus zwei Teilen besteht, wurden zwei Travisprojekte erstellt. Eins für die Extension und eins für den modifizierten TYPO3 Kern.

##### Konfiguration für die Extension
PHPUnit
CodeSniffer
PHPCPD
PHPMessDetection
PHPLOC

Ziel war eine möglichst 100% Testabdeckung zu erreichen.

##### Konfiguration für den TYPO3 Kern
Während bei den Tests der Extension auf eine innere Konsistenz des Programmcodes geschaut wurde, wurde bei den Tests des Kerns Augenmerk auf die Integration der Extension in das modifizierte TYPO3 gelegt. Ziel war es, dass alle mitgelieferten Tests des Cores erfüllt werden.

PHPUNit

#### Scrutinizer
[Bild einfügen]
Es kann zweifelsfrei gesagt werden, dass Travis-CI das Arbeitstier ist. Außer den oben beschriebenen Tätigkeiten macht er nicht viel. Das Besondere daran ist jedoch, dass er diese Aufgaben unermüdlich mit der gleichen Gewissenhaft ausführt. Das ist die Stärke eines solchen Progamms. Am Ende steht jedoch immer nur ein binäres Ergebnis:

* die Tests sind bestanden
* es sind Tests fehlgeschlagen

Anhand dieses Ergebnis können dann weitere Entscheidungen getroffen werden. Zum Beispiel wird es sinnvoll sein bei einem negativen Ergebnis darauf zu verzichten ein Download Paket zu erstellen und veröffentlichen.

Braucht man jedoch eine graphische Auswertung, der durch die statische Codeanalysen gewonnen Daten, kommt ein Service wie Scrutinizer zum Einsatz. Wie schon bei Travis-CI erfolgt die Konfiguration über eine YAML Datei.

Wie Tests gezeigt haben\footnote{https://scrutinizer-ci.com/g/Konafets/TYPO3v4-Core/inspections} ist es gegenwärtig nicht möglich den TYPO3 Kern mit Scrutinizer auszuwerten, da das Tool verschiedene Limits implementiert hat. Dies Limits werden von TYPO3 teilweise um ein Vielfaches überschritten. Es ist lediglich gelungen die Auswertung der Analyse zum Umfang des Codes und zur Copy and Paste Detection darzustellen. Da dies jedoch keine ausreichende Aussage über die Code Qualität treffen kann und die Qualität des Codes des TYPO3 Kerns nicht im Fokus dieser Arbeit liegt, wurde auf die Auswertung verzichtet.

Es wurde lediglich ein Srcutinizer Projekt für die Extension erstellt.

[Auswertung des Scrutinzer beschreiben]

Eins wird bei 10.000 Issues\footnote{Mit Issues sind Stellen gemeint, die laut Scrutinizer überarbeitet werden müssten) überschritten, welches von fast alles Analysen übertroffen wird. Zum Beispiel und zum anderen hat es einen zeitlichen Timeout, der bei der Analyse der Ergebnisse wie zum Beispiel der Code Coverage\footnote{Abdeckung der Codebasis mit Unit Tests} überschritten wird  

Der Grund für die Verbindung mit Scrutinizer war auch hier der Gedanke an die spätere Veröffentlichung der Extension und stellt die Grundsteinlegung für eine gleichbeleibend hohe Codequalität dar, die überprüfbar sein soll.

#### IDE
Als Editor wurde die \gls{ide} PHPStorm. 

[Bild einfügen]

PHPStorm verfügt über Autovervollständig von Variablen, Methoden und Klassen, unterstützt den Programmierer bei der Erstellung von Klassen durch Templates und bietet vielseitige Integration von externen Programmen. 

So ist es zum Beispiel möglich die PHPUnit Tests von PHPStorm aus zu starten und mit ein wenig Konfiguraton\cite{web:kowalke14} kann man sich die CodeCoverage im Editor anzeigen lassen.

[Bild einfügen]

Besonders hilfreich ist es jedoch sich die Ergebnisse des PHP_CodeSniffers anzeigen zu lassen um zumindest beim Feinschliff den Code GCL konform zu formatieren.

Die überaus leistungsfähige Integraton von XDebug runden die Funktionaliät, die der Editor bildet, ab.

Mit Hilfe von PHPStorm war es möglich sich schnell und umfassend in den Quellcode von TYPO3 und der Extension DBAL einzuarbeiten

#### Erstellen der Extension über den Extension Builder

Obwohl die TYPO3 Community sehr auf die Qualität des Codes achtet und es mittlerweile ca. 6458 UnitTests ausgeführt werden\footnote{https://travis-ci.org/TYPO3/TYPO3.CMS/builds/23070563}, gab es nur eine handvoll an Unit Tests für die DatbaseConnection Klasse. 



Es war vielmehr notwendig eine Ebene tiefer anzusetzen und Testcases für die Methoden der alten API zu definieren, die von den Methoden der neuen API erfüllt werden müssen. 

# Schlussbetrachtung
(My results are)
## Zusammenfassung
## Ausblick
