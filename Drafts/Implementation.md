# Prototypischer Nachweis der Herstellbarkeit

Die Erstellung des Prototyps begann mit der Definition verschiedener Zielstellungen. Diese wurden in zusammenhängenden Arbeitspaketen zusammengefasst und dienten als Meileinsteine. 


## Vorüberlegungen
Die Extension wurde als normale Extension konzipiert, die dennoch durch das \textit{Install Tool} installierbar sein muß. Dieser Anforderung ist notwendig, da bereits bei der Installation das zu nutzende \gls{dbms} auswählbar sein muß. 

Desweiteren muß die Extension weiterhin die alte API unterstützen, damit TYPO3 CMS und vor allem die Extensions der externen Entwickler weiterhin funktionieren. Dazu zählt auch das von TYPO3 CMS angebotene Prepared Statement, welches intern die Prepared Statements von MySQLi nutzt und die \textit{Named Paramenter} lediglich simuliert. Die Extension wird die Prepared Statement von Doctrine DBAL / PDO nutzen, ohne die alte API zu verändern.

Es wird lediglich die Unterstützung von MySQL als Datenbank angestreb. Ist das Abgeschlossen kann mit einem weiteren \gls{dbms} experimentiert werden.

Die Methodennamen der neuen API folgen der CGL.

Die Erstellung der Basisdatenbank durch Doctrine DBAL und nutzt dessen abstrahierte Schemarepräsentation.

Die Extension wurde zunächst als normale Extension konzipiert, die gegenfalls ohne größeren Aufwand in eine Systemextension umgewandelt werden kann. 

Die Extension führt eine Query Syntax ein, damit auf die manuelle Formulierung von SQL Anfragen verzichtet werden kann. 

Intern werden stets Prepared Statements genutzt

Anfragen in selbst formuliertem SQL sind nicht mehr möglich

Excelsheet erstellen mit den LegacyMethoden und den neuen MethodenNamen, die der CGL folgen

Daraus ergeben sich folgende zusammenhängende Aufgaben, welche zugleich die Meilensteine sind:

1. Erstellen der Extension -> TYPO3 nutzt die Extension als DB Layer
2. Extension ist per Installtool installierbar
3. Extension nutzt Doctrine DBAL
4. Umwandlung der SQL Dateien in Schema Dateien
5. Implementation einer Fluent API
6. Umbau des Cores auf die API 

Ein Großteil dieser Anforderungen ist erreichbar ohne eine Veränderung an TYPO3 CMS vorzunehmen, da die Extension lediglich die neue API als ein Angebot darstellt. Ein massiver Eingriff in den Code von TYPO3 CMS stellt der Meilenstein 6 dar. Hier muß jede Datenbankfunktion auf die neue API umgestellt werden. Bevor das jedoch geschehen kann, müssen minimale Anpassungen an der Installationsroutine von TYPO3 CMS vorgenommen werden. Dabei diente die Systemextension DBAL als Vorbild, da sie ebenfalls während der Installation installierbar sein muß.

## Installation von TYPO3
Zur Installation wurde im lokalen Webroot (\pdf{Sites} auf unter MacOSX) ein Verzeichnis \pdf{thesis.dev/http} angelegt. Dies stellt das Webroot dieser TYPO3 CMS Instanz dar. 

\begin{shcode}
$ cd Sites/
$ mkdir -p thesis.dev/http/
$ cd thesis.dev/
\end{shcode}

TYPO3 wurde per GIT nach \pdf{thesis.dev/typocms} heruntergeladen. Dieses Verzeichnis wurde gewählt, damit der Quellcode von TYPO3 CMS nicht über das Internet erreichbar ist. Das Kommando \shinline{tree} zeigt das Ergebnis.

\begin{shcode}
$ git clone git://git.typo3.org/Packages/TYPO3.CMS.git typo3cms
$ tree -L 1 --dirsfirst typo3cms

typo3cms
├── contrib
├── ext
├── gfx
├── install
├── js
├── mod
├── sysext
├── ajax.php
…
├── tce_file.php
└── thumbs.php

7 directories, 32 files
\end{shcode}

Danach wurde nach \pdf{http} gewechselt und es wurden die notwendigen Symlinks und Verzeichnisse angelegt. \shinline{tree} zeigt die erstellte Verzeichnisstruktur.

\begin{shcode}
$ cd http/
$ ln -s ../typo3cms/ typo3_src
$ ln -s typo3_src/typo3 typo3
$ ln -s typo3_src/index.php index.php

$ mkdir -p fileadmin typo3conf/ext uploads Packages/Library

$ tree -L
.
├── Packages
├── fileadmin
├── index.php -> typo3_src/index.php
├── typo3 -> typo3_src/typo3
├── typo3_src -> ../typo3cms
├── typo3conf
├── typo3temp
└── uploads

7 directories, 1 file
\end{shcode}

Im Anschluß wurde in der Hostdatei ein A-Record der Domain \pdf{thesis.dev} angelegt, welcher auf den lokalen Rechner zeigt.

\shinline{$ sudo sh -c "echo '127.0.0.1 thesis.dev' >> /etc/hosts"}

Zum Schluß wurde ein virtueller Host in der Apache2 Konfiguration angelegt, der auf das Verzeichnis \pdf{thesis.dev/http} zeigt. 

\begin{shcode}
<VirtualHost *:80>¬
  DocumentRoot "~/Sites/thesis.dev/http"¬
  ServerName thesis.dev¬
  ErrorLog "~/Sites/thesis.dev/logs/error_log"¬
  CustomLog "~/Sites/thesis.dev/logs/access_log" common¬
</VirtualHost>
\end{shcode}

Die TYPO3 CMS Installation ist nun über \url{http://thesis.dev/} erreichbar

\begin{shcode}
$ ping thesis.dev
PING thesis.dev (127.0.0.1): 56 data bytes
64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.118 ms
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.100 ms
\end{shcode}

Anschließend wurde eine leere Datenbank erstellt:

\begin{shcode}
mysql -u root -p
MariaDB [(none)]> create database if not exists thesis;
Query OK, 1 row affected (0.01 sec)
MariaDB [(none)]> quit;
\end{shcode}

Durch das Aufrufen von \url{http://thesis.dev/} im Browser wird der Installationsprozess gestartet, der über verschiedene Schritte das System installiert. 

Im ersten Schritt prüft das \textit{Install Tool} ob alle Verzeichnisse und Symlinks angelegt wurden und die entsprechenden Benutzerrechte besitzen. Abbildung~\ref{fig:installLegacyOne}
![image](../gfx/InstallingTYPO3/DoctrineDBAL/01 - SystemEnvironmentCheck.png)

Im zweiten Schritt werden die Benutzerdaten für die gerade erstellte Datenbank eingegeben. Es kann hier zwischen einer Port- oder Socke-basierten Verbindung ausgewählt werden. Über den Button am Ende der Formulars wird dem System mitgeteilt, dass anstelle der nativen Datenbank API die Systemextension DBAL genutzt werden soll, da TYPO3 CMS ein anderes \gls{dbms} nutzen soll. Die Exension wird daraufhin installiert und in ähnlicher Weise konfiguriert, wie es hier dargestellt wird.Abbildung~\ref{fig:installLegacyTwo}

![image](../gfx/InstallingTYPO3/Legacy/02 - DatabaseConnectionLegacy.png)

Nachdem die Verbindungsdaten eingegeben wurden, versucht TYPO3 CMS sich mit dem \gls{dbms} zu verbinden. Gelingt dies, werden alle verfügbaren Datenbanken abgefragt und aufgelistet (Abbildung~\ref{fig:installLegacyThree}). Aus dem Selectfeld kann eine leere Datenbank ausgewählt werden oder es kann eine über das Inputfeld angegeben werden. Durch das Klicken auf die Schaltfläche werden die Basistabellen in der Datenbank angelegt.

![image](../gfx/InstallingTYPO3/Legacy/03 - SelectDatabaseLegacy.png)

In 4. Schritt der Installation wird ein Administrator für die Seite eingerichtet Abbildung~\ref{fig:installLegacyFour} und es kann ein Name für die Seite vergeben werden.

![image](../gfx/InstallingTYPO3/Legacy/04 - CreateUserAndImportBaseDataLegacy.png)

Danach ist die Installation abgeschlossen und über die Schaltfläche gelangt man in das Backend, welches sich nach Eingabe der Logindaten öffnet. Abbildung~\ref{fig:installLegacyFive}

![image](../gfx/InstallingTYPO3/Legacy/05 - InstallationDoneLegacy.png)


![image](../gfx/TYPO3/Backend.png)



\begin{shcode}
$ cd Sites/
$ mkdir -p thesis.dev/http/
$ cd thesis.dev/
$ git clone git://git.typo3.org/Packages/TYPO3.CMS.git typo3cms
$ tree -L 1 --dirsfirst typo3cms

typo3cms
├── contrib
├── ext
├── gfx
├── install
├── js
├── mod
├── sysext
├── ajax.php
…
├── tce_file.php
└── thumbs.php

7 directories, 32 files

$ cd http/
$ ln -s ../typo3cms/ typo3_src
$ ln -s typo3_src/typo3 typo3
$ ln -s typo3_src/index.php index.php

$ mkdir -p fileadmin typo3conf/ext uploads Packages/Library

$ tree -L
.
├── Packages
├── fileadmin
├── index.php -> typo3_src/index.php
├── typo3 -> typo3_src/typo3
├── typo3_src -> ../typo3cms
├── typo3conf
├── typo3temp
└── uploads

7 directories, 1 file

$ sudo sh -c "echo '127.0.0.1 thesis.dev' >> /etc/hosts"
\end{shcode}




## Tests für die alte Datenbank API
Um zu gewährleisten, dass TYPO3 CMS sowohl mit der alten API - die von dem Prototypen zur Verfügung gesellt wird - als auch mit der neuen API kompatibel ist, müssen Untit Tests für die alte Datenbank API geschrieben werden. 

Zur Ausführung der Unit Tests wird die Extension \textit{PHPUnit} benötigt, welche das gleichnamige Testing Framework \textit{PHPUnit\footnote{\url{http://www.phpunit.de}}} zur Verfügung und einen einen graphischen Testrunner im Backend mitbringt. Sie wird über den Extension Manager installiert.

![image](../gfx/TYPO3/InstallationPHPUnit.png)

Die alte Datenbank API verfügt zur dem Zeitpunkt der Erstelltung des Prototypen über 40 Tests mit 49 Assertions, welche jedoch lediglich Hilfsmethoden testen. Abbildung~\ref{fig:testRunnerUnitTestDatabasConnectionLegacyBefore} und~\ref{fig:DatabasConnectionTestLegacyBefore} zeigen die Testabdeckung in Form des Testrunners und als UML Diagramm. Abbildung~\ref{fig:DatabasConnectionTestLegacyAfter} zeigt die gleiche Klasse mit den für den Prototypen implementierten Unit Tests.  

![image](../gfx/TYPO3/DatabaseConnectionUnitTestsLegacy.png)

![image](../gfx/uml/UnitTests/DatabaseConnectionTest.png)
![image](../gfx/uml/UnitTests/DatabaseConnectionTestAfter.png)


Es wurden 68 Tests für \phpinline{TYPO3\CMS\Core\Database\DatabaseConnection} zugefügt.

  
## Erstellung des Prototypen

### Stichpunkte

_Änderungen am Prototypen_

1. Extension Builder -> Extension erstellen √
3. Verzeichnis Classes/Persistence/Legacy erstellen √
4. Kopieren von DatabaseConnection.php und PreparedStatements.php in das Verzeichnis √
5. Verzeichnis Tests/Persistence/Legacy erstellen √
6. Kopieren von DatabaseConnectionTest.php und PreparedStatementTest.php in das Verzeichnis √
7. Namespaces anpassen Vendor\Extensionname\Persistence\Legacy √
8. Datei ext_localconf.php erstellen und XCLASSEN der beiden Dateien  √
9. Extension installieren √
10. Per Debuggen in der IDE feststellen, ob ByPass funktioniert √
12. Verzeichnis Classes/Persistence/Doctrine/ erstellen  √
13. Datei DatabaseConnection.php in dem Verzeichnis erstellen -> Datei erbt von Classes\Persistence\Legacy\DatabaseConnection.php √
14. Datei PreparedStatemetns.php in dem Verzeichnis erstellen -> Datei erbt von Classes\Persistence\Legacy\PreparedStatements √
16. \Classes\Persistence\Doctrine\DatabaseConnection.php bekommt die neuen Methoden, die auf die die alte API nutzen parent:: √
17. Syncron dazu die Tests schreiben √
18. Refactoring von connectDb() / connectDatabase() √
19. Testen durch Überschreiben von connectDb() in \Classes\Persistence\Doctrine\DatabaseConnection.php √


Die Grundstruktur der Extension wurde in dem Verzeichnis \pdf{thesis/http/typo3conf/ext/doctrine_dbal} erstellt, wobei der letzte Pfadbestandteil den Namen der Extension darstellt. Abbildung~\ref{fig:extensionInitialFolderStructure} zeigt die Verzeichnisstruktur. 

\begin{Verbatim}[samepage=true]
thesis.dev/http/typo3con/ext/
├── doctrine_dbal/
│   ├── Configuration/
│   ├── Resources/
│   ├── ext_emconf.php
│   ├── ext_icon.gif
│   └── ext_tables.php\end{Verbatim}
Die Datei \pdf{ext_emconf.php} enthält die Metainformationen der Extension, die von dem Extension Manager verarbeitet werden.
\begin{listing}
\begin{phpcode}
<?php
$EM_CONF[$_EXTKEY] = array(
	'title' => 'Doctrine DBAL',
	'description' => 'Doctrine DBAL Integration in TYPO3 CMS',
	'category' => 'be',
	'author' => 'Stefano Kowalke',
	'author_email' => 'blueduck@gmx.net',
	'author_company' => 'Skyfillers GmbH',
	'shy' => 0,
	'priority' => '',
	'module' => 'mod1',
	'state' => 'alpha',
	'internal' => 0,
	'uploadfolder' => 0,
	'createDirs' => '',
	'modify_tables' => '',
	'clearCacheOnLoad' => 0,
	'lockType' => '',
	'version' => '0.1.0',
	'constraints' => array(
		'depends' => array(
			'typo3' => '6.2.0-6.2.99',
		),
		'conflicts' => array('adodb', 'dbal'),
		'suggests' => array(
		),
	),
);
\end{phpcode}
\caption{Die Datei ext_emconf.php}
\label{lst:extEmconf}
\end{listing}

Im nächsten Schritt wurden die Dateien \pdf{DatabaseConnection.php} und \pdf{PreparedStatements} von TYPO3 CMS in den Ordner \pdf{Classes/Persistence/Legacy} der Extension kopiert und dessen Namesspaces angepasst.

TYPO3 CMS erwartet einen Namespace nach dem Muster \phpinline{Vendor\Extensionname\Verzeichnis\zur\Datei}. Dabei stellt \phpinline{Vendor} einen frei wählbaren Bezeichner dar. Für die Extension wurde \phpinline{Konafets} verwendet.

Damit TYPO3 CMS diese Dateien anstelle der Originalen verwendet, müssen diese per XCLASS überschrieben werden. Dazu muß im Verzeichnis des Prototypen eine Datei mit dem Namen ext_localconf.php mit folgendem Inhalt angelegt werden:

\begin{phpcode}
if (!defined('TYPO3_MODE')) {
	die('Access denied.');
}

$GLOBALS['TYPO3_CONF_VARS']['SYS']['Objects']['TYPO3\\CMS\\Core\\Database\\DatabaseConnection'] = array('className' => 'Konafets\\DoctrineDbal\\Persistence\\Doctrine\\DatabaseConnection');
\end{phpcode}

Durch die Installation des Protoypen über den Extension Manager werden diese Änderungen wirksam und TYPO3 CMS nutzt die Klassen des Prototypen anstelle der eigenen. Dies kann festgestellt werden, in dem über die \gls{ide} ein Debug-Breakpoint in die Klasse \phpinlin{Konafets\DoctrineDbal\Persistence\Legacy\DatabaseConnection} innerhalb der \phpinlin{connectDB} gesetzt wird. 

Die \gls{ide} verfügt über einen Debug Listener, der auf ein vom Browser gesendetes Token wartet und bei Empfang den Debug Prozess startet. Für den verwendeten Browser \textit{Chrome} ist ein Addon verfügbar, mittels diesem das Senden des Debug-Tokens per Knopfdruck ein- und ausgeschaltet werden kann.

Wird der Browser und die \gls{ide} in den Debug-Modus gesetzt und TYPO3 CMS neugeladen, bleibt das Programm an dem gesetzten Breakpoint stehen. 

Die neue API wird in dem Verzeichnis \pdf{Classes/Persistence/Doctrine} von den Dateien \pdf{DatabaseConnection.php} und \pdf{PreparedStatement.php} repräsentiert, die dazu erstellt wurden. Da die alte API vorerst nicht verändert werden soll, erbt die Klasse \phpinline{\Konafets\DoctrineDbal\Persistence\Doctrine\DatabaseConnection} von der alten Klasse \phpinline{\Konafets\DoctrineDbal\Persistence\Legacy\DatabaseConnection}. 

![image](../gfx/uml/NewAPI/DatabaseConnectionExtentsFromOldAPI.png)
\label{fig:newDatabaseConnectionExtendsFromOldOne}

Dadurch können die Methoden der neuen API in definiert werden. Intern rufen sie die Methoden der Elternklasse auf. 

\begin{phpcode}
class DatabaseConnection extends \Konafets\DoctrineDbal\Persistence\Legacy\DatabaseConnection {
    /**
	 * Select a SQL database
	 *
	 * @return boolean Returns TRUE on success or FALSE on failure.
	 */
	public function selectDatabase() {
		return parent::sql_select_db();
	}

	/**
	 * Connects to database for TYPO3 sites:
	 *
	 * @throws \RuntimeException
	 * @throws \UnexpectedValueException
	 *
	 * @return void
	 * @api
	 */
	public function connectDatabase() {
		parent::connectDB();
	}
\end{phpcode}

Parallel dazu wurden die Unit Tests der alten API nach \pdf{doctrine_dbal/Tests/Persistence/Legacy/} kopiert und an die neue API angepasst. Da die Anfragen an die neue API zu diesem Zeitpunkt von ihr lediglich an die alte API delegiert werden, funktionieren die Unit Tests weiterhin.

Die letzte Aufgabe des ersten Meilensteins bestand aus dem Refactoring der Methode\phpinline{connectDB}. Laut dem Namen der ist sie zuständig für die Etablierung einer Verbindung zur Datenbank. Tatsächlich hat sie

- einen Test durchgeführt, ob eine Datenbank konfiguriert ist
- die Verbindung angefordert
- die konfigurierte Datenbank ausgewählt und
- verschiedene Hooks ausgeführt

Das folgende Listing zeigt die Methode vor dem Refactoring.

\begin{phpcode}
	/**
	 * Connects to database for TYPO3 sites:
	 *
	 * @param string $host Deprecated since 6.1, will be removed in two versions Database. host IP/domain[:port]
	 * @param string $username Deprecated since 6.1, will be removed in two versions. Username to connect with
	 * @param string $password Deprecated since 6.1, will be removed in two versions. Password to connect with
	 * @param string $db Deprecated since 6.1, will be removed in two versions. Database name to connect to
	 * @throws \RuntimeException
	 * @throws \UnexpectedValueException
	 * @internal param string $user Username to connect with.
	 * @return void
	 */
	public function connectDB($host = NULL, $username = NULL, $password = NULL, $db = NULL) {
		// Early return if connected already
		if ($this->isConnected) {
			return;
		}

		if (!$this->databaseName && !$db) {
			throw new \RuntimeException(
				'TYPO3 Fatal Error: No database selected!',
				1270853882
			);
		}

		if ($host || $username || $password || $db) {
			$this->handleDeprecatedConnectArguments($host, $username, $password, $db);
		}

		if ($this->sql_pconnect()) {
			if (!$this->sql_select_db()) {
				throw new \RuntimeException(
					'TYPO3 Fatal Error: Cannot connect to the current database, "' . $this->databaseName . '"!',
					1270853883
				);
			}
		} else {
			throw new \RuntimeException(
				'TYPO3 Fatal Error: The current username, password or host was not accepted when the connection to the database was attempted to be established!',
				1270853884
			);
		}

		// Prepare user defined objects (if any) for hooks which extend query methods
		$this->preProcessHookObjects = array();
		$this->postProcessHookObjects = array();
		if (is_array($GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['t3lib/class.t3lib_db.php']['queryProcessors'])) {
			foreach ($GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['t3lib/class.t3lib_db.php']['queryProcessors'] as $classRef) {
				$hookObject = GeneralUtility::getUserObj($classRef);
				if (!(
					$hookObject instanceof PreProcessQueryHookInterface
					|| $hookObject instanceof PostProcessQueryHookInterface
				)) {
					throw new \UnexpectedValueException(
						'$hookObject must either implement interface TYPO3\\CMS\\Core\\Database\\PreProcessQueryHookInterface or interface TYPO3\\CMS\\Core\\Database\\PostProcessQueryHookInterface',
						1299158548
					);
				}
				if ($hookObject instanceof PreProcessQueryHookInterface) {
					$this->preProcessHookObjects[] = $hookObject;
				}
				if ($hookObject instanceof PostProcessQueryHookInterface) {
					$this->postProcessHookObjects[] = $hookObject;
				}
			}
		}
	}
\end{phpcode}

Das folgende Listing zeigt die Methode bereits unter neuen Namen nach dem Refactoring. Code, der nicht zur definierten Aufgabe der Methode gehörte, wurde in eigene Methoden ausgelagert. Die Methode zur Überprüfung der veralteten Parameter konnte gänzlich entfallen. Zudem wurden für alle Eigenschaften der Klasse \textit{Getter}-Methoden eingeführt, die innerhalb der neuen Methoden genutzt werden. 

\begin{phpcode}
/**
 * Connects to database for TYPO3 sites:
 *
 * @return void
 * @api
 */
public function connectDatabase() {
	// Early return if connected already
	if ($this->isConnected) {
		return;
	}

	$this->checkDatabasePreconditions();

	try {
		$this->link = $this->getConnection();
	} catch (\Exception $e) {
		echo $e->getMessage();
	}

	$this->isConnected = $this->checkConnectivity();	
	if ($this->isConnected) {	
		$this->initCommandsAfterConnect();
		$this->selectDatabase();
	}

	$this->prepareHooks();
}
 	
/**
 * @throws \RuntimeException
 * @return bool
 */
private function checkConnectivity() {
	$connected = FALSE;
	if ($this->isConnected()) {
		$connected = TRUE;
	} else {
		GeneralUtility::sysLog(
			'Could not connect to MySQL server ' . $this->getDatabaseHost() . ' with user ' . $this->getDatabaseUsername() . ': ' . $this->sqlErrorMessage(),
			'Core',
			GeneralUtility::SYSLOG_SEVERITY_FATAL
		);

		$this->close();

		throw new \RuntimeException(
			'TYPO3 Fatal Error: The current username, password or host was not accepted when the connection to the database was attempted to be established!',
			1270853884
		);
	}

	return $connected;
}
\end{phpcode}

Die Funktion der überarbeiteten Methode konnte erfolgreich überprüft werden, indem in der Kindklasse die Methode \phpinline{connectDB} überschrieben wurde intern \phpinline{connectDatabase()} aufruft.

![image](../gfx/uml/NewAPI/DatabaseConnectionOverridingConnectDB.png)

\begin{phpcode}
function connectDB() {
    $this->connectDatabase();
}
\end{phpcode}

Abbildung~\ref{fig:folderStructureFirstMilestone} zeigt die erstellten Verzeichnisse und Dateien zum Ende des ersten Meilensteins.

\begin{Verbatim}[samepage=true]
doctrine_dbal
├── Classes
│   └── Persistence
│       ├── Doctrine
│       │   ├── DatabaseConnection.php
│       │   └── PreparedStatement.php
│       └── Legacy
│           ├── DatabaseConnection.php
│           └── PreparedStatement.php
├── Tests
│   └── Unit
│       └── Persistence
│           └── Legacy
│                ├── DatabaseConnectionTest.php
│                └── PreparedStatementTest.php
├── composer.json
├── composer.lock
├── ext_emconf.php
├── ext_icon.gif
├── ext_localconf.php
└── ext_tables.php\end{Verbatim}

## Prototyp installierbar über das Install Tool
Für eine Datenbankabstraktionsschicht ist es wichtig, dass sie bereits während der Installation verfügbar ist um ein alternatives \gls{dbms} nutzen zu können. Demnach muß der Prototyp - analog zur Systemextension DBAL - über das Install Tool installierbar sein, was zu geringfügigen Anpassungen am Install Tool führt. 

Wie bei der Installation von TYPO3 CMS zu sehen war, führt das Install Tool in fünf Schritten durch die Installation. Diese Schritte werden von Klassen zur Verfügung gestellt, die sich im Ordner \pdf{typo3/sysext/install/Classes/Controller/Action/Step} befinden. Sie werden über den StepController \pdf{typo3/sysext/install/Classes/Controller/Action/StepController} gesteuert. Dabei iteriert der Controller bei jedem Reload des Installtools über alle Schritte und prüft ob der jeweils aktuelle Schritt bereits ausgeführt wurde oder noch ausgeführt werden muß. Der Controller erkennt dies an Bedingungen, die von jedem Schritt definiert werden.
Sind alle Bedingungen erfüllt, findet ein Redirekt auf den nächsten Schritt statt.

Die Ausgabe der Schritte erfolgt über verschiedene HTML-Template Dateien, die in der TYPO3 eigenen Template-Sprache \textit{Fluid} verfasst sind. Das Install Tool setzt hier das \gls{mvc}-Pattern ein, um die Geschäftslogik von der Präsentation zu trennen.

Die HTML-Templates unterteilen sich in \textit{Layouts}, \textit{Templates} und \textit{Partials}, die in den jeweilig gleichnamigen Verzeichnissen in \pdf{typo3/sysext/install/Resources/Privat/} zu finden sind. 

- Ein Template beschreibt die grundlegende Struktur einer Seite. Typischerweise befindet sich darin der Seitenkopf und -fuß. 
- Die Struktur einer einzelnen Seite wird von einem Template festgelegt. 
- Partials stellen wiederkehrende Elemente einer Seite dar. Sie können in Layout- und Templatedateien eingebunden werden. Die Schaltfläche \textit{I do not use MySQL} aus Abbildung~\ref{fig:installLegacyTwo} im zweiten Schritt ist ein Beispiel eines Partials.

Dieser Schritt stellt zudem den Anfangspunkt der Anpassungen dar. Es wurden zwei Partials erstellt und in das Template des Schrittes eingebunden. Das erste Partial stellt eine Schaltfläche dar, über die der Prototyp installiert werden kann, während das zweite eine Schaltfläche zur Deinstallation bereitstellt. \textit{Fluid} entscheidet anhand der Bedingung \mono{isDoctrineEnabled} welches der beiden Partials angezeigt wird. 

\begin{htmlcode}
<p>
	TYPO3 CMS native database implementation is based on mysql. This feature installs Doctrine DBAL and its experimental at the moment. Use it at your own risk and when you know what you are doing.
</p>

<form method="post">
	<f:render partial="Action/Common/HiddenFormFields" arguments="{_all}" />
	<input type="hidden" value="execute" name="install[set]" />
	<input type="hidden" value="1" name="install[values][loadDoctrine]" />
	<button type="submit">
		I want use Doctrine DBAL
		<span class="t3-install-form-button-icon-negative">&nbsp;</span>
	</button>
</form>
\end{htmlcode}

\begin{htmlcode}
			<f:if condition="{isDoctrineEnabled}">
				<f:then>
					<f:render partial="Action/Step/DatabaseConnect/UnloadDoctrineDbal" arguments="{_all}" />
				</f:then>

				<f:else>
					<f:render partial="Action/Step/DatabaseConnect/ConnectDetails" arguments="{_all}" />
					<f:render partial="Action/Step/DatabaseConnect/LoadDoctrineDbal" arguments="{_all}" />
					<f:render partial="Action/Step/DatabaseConnect/LoadDbal" arguments="{_all}" />
				</f:else>
			</f:if>

\end{htmlcode}

![image](../gfx/InstallingTYPO3/DoctrineDBAL/02 - DatabaseConnection.png)

Damit die Bedingung \mono{isDoctrineEnabled} einen Wert enthält, muß diese von der Action des Schrittes definiert und an die View übergeben werden. In diesem Fall ist dafür die Klasse \phpinline{\TYPO3\CMS\Install\Controller\Action\Step\DatabaseConnect} zuständig. Hier wird der Extension Manager gefragt, ob der Prototyp installiert ist. 

\begin{phpcode}
$isDbalEnabled = \TYPO3\CMS\Core\Utility\ExtensionManagementUtility::isLoaded('doctrine_dbal');

$this->view
  ->assign('isDoctrineEnabled', $isDoctrineEnabled)
  ->assign('username', $this->getConfiguredUsername())
  ->assign('password', $this->getConfiguredPassword())
  ->assign('host', $this->getConfiguredHost())
  ->assign('port', $this->getConfiguredOrDefaultPort())
  ->assign('database', $GLOBALS['TYPO3_CONF_VARS']['DB']['database'] ?: '')
  ->assign('socket', $GLOBALS['TYPO3_CONF_VARS']['DB']['socket'] ?: '');
\end{phpcode}

An diesem Beispiel wird zudem deutlich wie die Zuweisung einer – in PHP definierten – Variable an die View realisiert wird.

Durch den Klick auf die neu hinzugefügte Schaltfläche wird der Prototyp installiert. Dazu wird der per POST-Request gesendete Wert \mono{loadDoctrine} von dem gleichen Schritt auswertet und per Extension Manager installiert (Siehe \pdf{typo3/sysext/install/Classes/Controller/Action/Step/DatabaseConnect.php} Zeilen 59-63 und 815-844). Daraufhin erhält der Benutzer ein visuelles Feedback, dass der Protoyp installiert wurde. Der weitere Verlauf der Installation ist mit der aus Kapitel~\ref{subsec:InstallingTypo3} dargestellten Installation identisch.

## Umstellen auf Doctrine DBAL

### Stichpunkte

_Änderungen am Prototypen_

20. Doctrine einbauen per Composer laden √
21. vendor/doctrine nach Packages/Library kopieren √
23. Manuelles Editieren der PackageStates.php -> 'state' => 'active' auf active setzen
24. ggf. Reihenfolge in PackagesStates.php anpassen 

Nach den bisher vorgenommen Anpassungen ist der Prototyp zum Einen über das Install Tool, sowie über den Extension Manager im Backend installierbar. Anfragen an die Datenbank werden per XCLASS zum Prototypen geleitet. Dabei wird intern weiterhin die alte Datenbank API mit MySQLi genutzt. 

Die nächste Aufgabe bestand darin den Prototypen auf Doctrine DBAL umzustellen, sowie das Install Tool daran anzupassen.

Um den Überblick zu behalten werden zunächst die Änderungen beschrieben, die am Prototypen notwendig wurden. Danach folgen die Anpassungen an TYPO3 CMS.

### Änderungen am Prototypen
#### Installation von Doctrine DBAL

Doctrine DBAL wurde über \textit{Composer} installiert. 

Composer ist ein Dependency Manager\footnote{https://getcomposer.org/} für PHP, welcher von der Kommandozeile aufgerufen wird. Es dient zum Auflösen von Abhängigkeiten eines Projektes. Diese Abhängigkeiten werden in einer \pdf{composer.json}-Datei definiert und durch Ausführung des Programms in Verbindung mit der Konfigurationsdatei in dem Ordner \pdf{vendor} installiert.

Für den Prototypen wurde Doctrine DBAL als externe Abhängigkeit in der \pdf{composer.json} wie folgt definiert:

\begin{listing}
\begin{jsoncode}{
	"name": "typo3/doctrine_dbal",
	"type": "typo3-cms-extension",
	"description": "This brings Doctrine2 to TYPO3",
	"homepage": "http://typo3.org",
	"license": ["GPL-2.0+"],
	"version": "6.2.0",
	"require": {
		"doctrine/dbal": "dev-master"
	},
	"mininum-stability": "dev",
}
\end{jsoncode}
\caption{Die Datei composer.json}
\label{lst:composer}
\end{listing}   

Durch das Kommando \shinline{composer install} erfolgt die Installation von Doctrine DBAL in den Ordner \pdf{vendor/doctrine}.

Composer Konfigurationsdateien werden seit TYPO3 CMS 6.2 analysiert. Aus den definierten Abhängigkeiten und den (System)-Extensions wird vom Package Mananger ein Graph von Abhängigkeiten aufgebaut welcher in \pdf{thesis.dev/http/typo3conf/PackagesStates.php} gespeichert wird. Diese Datei wird bei der Installation erstellt und stetig aktualisiert. Da diese Funktionalität noch recht neu ist, mußte diese Datei bei der Installation des Prototypen manuell angepasst werden. Das wird später detailierter beschrieben.

Externe Abhängigkeiten werden vom Package Manager in \pdf{thesis.dev/http/Packages/Library} erwartet. Aus diesem Grund muß der Ordner \pdf{thesis.dev/http/typo3conf/ext/doctrine_dbal/vendor/doctrine} nach \pdf{thesis.dev/http/Packages/Library/} kopiert werden.

#### Umstellen der neuen API auf Doctrine DBAL

Die Integration von Doctrine DBAL sollte so transparent für TYPO3 CMS und die Extensions erfolgen, dass weiterhin über die Methoden der alten API auf die Datenbank zugegriffen werden konnte. Die alte API steht dabei vergleichbar einer Fassade vor der neuen API, die ankommende Anfragen selbst behandelt oder an die neue API delegiert. Dieses Vorgehen erlaubt die sukzessive Integration von Doctrine DBAL.

Um dies zu erreichen wurde die in Abbildung~\ref{fig:newDatabaseConnectionExtendsFromOldOne} vorgestellte Hierachie umgekehrt - die Klasse \phpinline{\Konafets\DoctrineDbal\Persistence\Legacy\DatbaseConnection} erbt nun von der neuen Klasse \phpinline{\Konafets\DoctrineDbal\Persistence\Doctrine\DatbaseConnection}.

![image](../gfx/uml/NewAPI/OldDatabaseConnectionExtentsFromNewAPI.png)

Anschließend wurde die Änderung der Klassenhierachie in \pdf{doctrine_dbal/ext_localconf.php}  bekannt gemacht. 

\begin{phpcode}
$GLOBALS['TYPO3_CONF_VARS']['SYS']['Objects']['TYPO3\\CMS\\Core\\Database\\DatabaseConnection'] = array('className' => 'Konafets\\DoctrineDbal\\Persistence\\Legacy\\DatabaseConnection');
\end{phpcode}

Im nächsten Schritt wurden alle notwendigen Eigenschaften der alten Klasse in die neue Klasse verschoben. Jede Eigenschaft bekam zudem Setter- und Getter Methode, über die darauf zugegriffen werden soll.

\begin{phpcode}
	public function setDatabaseUsername($username) {
		$this->disconnectIfConnected();
		$this->connectionParams['user'] = $username;

		return $this;
	}

	public function getDatabaseUsername() {
		return $this->connectionParams['user'];
	}
	
	public function setStoreLastBuildQuery($value) {
		$this->store_lastBuiltQuery = (bool)$value;
	}
\end{phpcode} 


Die Eigenschaften die die Konfigurationsinformation für die Datenbank bereithielten wurden entfernt und durch ein Konfigurationsarray ersetzt, welches Doctrine DBAL zum Anfordern einer Verbindung erwartet.

\begin{phpcode}
	protected $connectionParams = array(
		'dbname'   => '',
		'user'     => '',
		'password' => '',
		'host'     => 'localhost',
		'driver'   => 'pdo_mysql',
		'port'     => 3306,
		'charset'  => 'utf8',
	);
\end{phpcode}

Zum wurden verschiedene Doctrine-spezische Eigenschaften und Setter/Getter-Methoden der Klasse hinzugefügt.

Die eigentliche Umstellung auf Doctrine DBAL erfolgte in der Methode \phpinline{\Konafets\DoctrineDbal\Persistence\Doctrine\DatabaseConnection::getConnection()}, da sie das Verbindungsobjekt erstellt und zurückgibt.

Zunächst wurde Code, welcher nicht zum Aufgabengebiet der Methode gehört, in eigene Klassen ausgelagert. In dem Fall betraf das den Test nach einer installierten MySQLi PHP-Erweiterung, welcher im gleichen Zuge auf PDO geändert wurde.

Die Initialisierung von Doctrine erfolgt in einer eigenen Methode. Dort wird je eine Instanz von \phpinline{\Doctrine\DBAL\Configuration} und \phpinline{\Doctrine\DBAL\Schema\Schema}.

Die Methode der \phpinline{sql_pconnect()} der alten API bot die Möglichkeit einer persistenten Verbindung zur Datenbank. Dies wurde implementiert, in dem ein eigenes \phpinlin{PDO}-Objekt mit dem Konstrukturparameter \phpinline{\PDO::ATTR_PERSISTENT => true} erstellt und in dem Konfigurationsarray gespeichert wurde.

Dieses Konfigurationsarray (siehe Listing~\ref{lst:DoctrineConfigArray}) wird \phpinline{\Doctrine\DBAL\DriverManager::getConnection()} übergeben, welches ein Verbindungsobjekt zurückgibt. 

Zudem muß Doctrine DBAL der Datentyp \sqlinline{Enum} bekanntgemacht werden. Anschließend wird der Schema Manager erstellt, welcher zur Verwaltung des Datenbankschemas notwendig ist. 

Am Schluß wird das Verbindungsobjekt zurückgegeben.

\begin{phpcode}
	/**
	 * Open a (persistent) connection to a MySQL server
	 *
	 * @return boolean|void
	 * @throws \RuntimeException
	 */
	public function getConnection() {
		if ($this->isConnected) {
			return $this->link;
		}

		$this->checkForDatabaseExtensionLoaded();

		$this->initDoctrine();

		// If the user want a persistent connection we have to create the PDO instance by ourself and pass it to Doctrine.
		// See http://stackoverflow.com/questions/16217426/is-it-possible-to-use-doctrine-with-persistent-pdo-connections
		// http://www.mysqlperformanceblog.com/2006/11/12/are-php-persistent-connections-evil/
		if ($this->persistentDatabaseConnection) {
			// pattern: mysql:host=localhost;dbname=databaseName
			$cdn = substr($this->getDatabaseDriver(), 3) . ':host=' . $this->getDatabaseHost() . ';dbname=' . $this->getDatabaseName();
			$pdoHandle = new \PDO($cdn, $this->getDatabaseUsername(), $this->getDatabasePassword(), array(\PDO::ATTR_PERSISTENT => true));
			$this->connectionParams['pdo'] = $pdoHandle;
		}

		$connection = DriverManager::getConnection($this->connectionParams, $this->databaseConfiguration);
		$this->platform = $connection->getDatabasePlatform();

		$connection->connect();

		// We need to map the enum type to string because Doctrine don't support it native
		// This is necessary when the installer loops through all tables of all databases it found using this connection
		// See https://github.com/barryvdh/laravel-ide-helper/issues/19
		$this->platform->registerDoctrineTypeMapping('enum', 'string');
		$this->schemaManager = $connection->getSchemaManager();

		return $connection;
	}
\end{phpcode}

Die Methode \phpinline{connectDatabase()} wurden dahingehen verändert, dass sie eine \phpinline{ConnectionException} wirft, wenn von \phpinline{getConnection()} keine Verbindung erstellt werden konnte. Die entsprechenden Exceptionklassen wurden in \pdf{doctrine_dbal/Classes/Exeptions/} erstellt.

Die Methode \phpinline{query()} stellte in der alten API die zentrale Schnittstelle zum Senden der Anfragen an die Datenbank dar. Sie wird intern von allen Methoden verwendet um dessen SQL-Anfragen abzusenden. Intern nutzte sie die gleichnamige Methode von MySQLi. Die neue API übernimmt diese Funktionalität vollständig.

Wie bereits in Kapitel~\ref{sec:doctrine} erwähnt wurde, gibt \phpinline{query()} ein Statementobjekt zurück, welches die Ergebnismenge bereithält. Dort wurde ebenfalls dargestellt, dass diese Menge durch die Methode \phpinline{fetch()} in Verbindung mit PDO-Konstanten zum Beispiel in Index-basierte oder Assoziative Arrays formatiert werden kann. 

Um die Arbeit mit der Ergebnismenge zu erleichtern wurden die drei Methoden \phpinline{fetchAssoc($stmt)}, \phpinline{fetchRow($stmt)} und \phpinline{$fetchColumn($stmt)} implementiert, die die am Häufigsten vorkommenden  \textit{Fetch-Styles} kapseln.

\begin{phpcode}
	/**
	 * Returns an associative array that corresponds to the fetched row, or FALSE if there are no more rows.
	 * Wrapper function for Statement::fetch(\PDO::FETCH_ASSOC)
	 *
	 * @param \Doctrine\DBAL\Driver\Statement $stmt A PDOStatement object
	 *
	 * @return boolean|array Associative array of result row.
	 * @api
	 */
	public function fetchAssoc($stmt) {
		if ($this->debugCheckRecordset($stmt)) {
			return $stmt->fetch(\PDO::FETCH_ASSOC);
		} else {
			return FALSE;
		}
	}
	
		public function fetchColumn($stmt, $index = 0) {
		if ($this->debugCheckRecordset($stmt)) {
			return $stmt->fetchColumn($index);
		} else {
			return FALSE;
		}
	}
	
		public function fetchRow($stmt) {
		if ($this->debugCheckRecordset($stmt)) {
			return $stmt->fetch(\PDO::FETCH_NUM);
		} else {
			return FALSE;
		}
	}
\end{phpcode}

Die ehemaligen \phpinline{admin_*}-Methoden wurden laut der Tabelle~\ref{tab:cglNames} in \phpinline{list_*}-Methoden umbenannt, da die Unterscheidung in sogenannte Admin und Nicht-Admin Methoden nicht nachvollziehbar war. Diese Mehoden stellen wichtige Metainformation zur darunterliegenden Datenbank bereit, die nicht nur für das Install Tool von Nutzen sind.

Als Beipiel der Abstraktion, die Doctrine DBAL mitbringt, sei die Implementation der Methode \phpinline{listDatabases()} angeführt. 

Nach dem obligatorischen Verbindungstest, wird der Schema Manager nach einer Liste alle Datenbanken im System befragt - vollkommen unabhängig von der zugrundeliegenden \gls{dbms}.

\begin{phpcode}
	public function listDatabases() {
		if (!$this->isConnected) {
			$this->connectDatabase();
		}

		$databases = $this->schemaManager->listDatabases();
		if (empty($databases)) {
			throw new \RuntimeException(
				'MySQL Error: Cannot get databases: "' . $this->getErrorMessage() . '"!',
				1378457171
			);
		}

		return $databases;
	}
\end{phpcode}

Alle Methoden der alten API, die sich um die Maskierung von Eingaben kümmerten, mußten hingegen vollständig angepasst werden, da Doctrine lediglich die Methode \phpinline{quote()} zum Maskieren breitstellt. Diese stellt dem zu maskierenden Zeichen ein Hochkomma (') voran. Im Gegensatz dazu mußte für MySQLi mit Backslashes (\) maskiert werden.

Die von Doctrine kommende \phpinline{quote()} wurde in der neuen API durch eine gleichnamige Methode gekapselt. Diese stellt die Basis für alle weitere Methoden wie \phpinline{fullQuoteString()}, \phpinline{fullQuoteArray()}, \phpinline{quoteString()} und \phpinline{escapeStringForLike()} dar. Diese Methoden simulieren lediglich das Verhalten der alten API. Die neue API bietet die Methoden \phpinline{quoteColumn()}, \phpinline{quoteTable()} und \phpinline{quoteIdentifier()} an. Das Maskieren von Benutzereingaben kann weiterhin mit \phpinline{quote()} vollzogen werden; sicherer ist es jedoch von Anfang an Prepared Statements zu verwenden.

Damit der Prototyp funktioniert, mußte das von der alten API implementierte Prepared Statement auf Doctrines Prepared Statements umgestellt werden. 

[UML Diagramm Prepared Statement]

Die von TYPO3 CMS implementierten Prepared Statements bieten nach außen die gleiche API wie in Kapitel~\ref{sec:doctrinePreparedStatemtens} vorgestellt, stellen jedoch seit Version 6.2 einen \textit{Wrapper} um das Prepared Statement von MySQLi dar. Durch den Aufruf der Methode \phpinline{$stmt = $GLOBALS['TYPO3_DB']->prepare($sql)} wird zunächst ein Objekt vom Typ \phpinline{\TYPO3\CMS\Core\Database\PreparedStatement} erstellt, dem der in \phpinline{$sql} gespeicherte Prepared Statemnt übergeben wird.
Ein Aufruf von \phpinline{$stmt->bind(':lastName', 'Potter')} fügt einem internen Array des Objekts lediglich diese Werte hinzu. Zusätzlich wird versucht den Datentyp zu erkennen und ebenfalls zu speichern.

Erst mit dem Aufruf von \phpinline{$stmt->execute()} wird die Datenbank kontaktiert. Zuvor wird jedoch erst die gespeicherte SQL-Anfrage und die durch \phpinline{bind()} übergebenen Parameter von \textit{Named Placeholder} in \textit{Positional Parameter} transformiert, da MySQLi nur diese unterstützt. Daraufhin wird die SQL-Abfrage nun über \phpinline{mysqli::prepare()} an die Datenbank gesendet. Danach werden die, in dem Array gespeicherten, Parameter per \phpinline{mysqli::bind()} gebunden und abschließend per \phpinline{mysqli::execute} ausgeführt.

Zusätzlich wird die Anfrage gecached.

Für die Umstellung auf Doctrine wurden die eigens verwendeten Konstanten auf PDO-Konstanten umgemappt und die Transformation in \textit{Positional Parameter} konnte gänzlich entfallen, da von Doctrine beide Varianten unterstützt werden. 

Dem Konstruktur mußte noch der das aktuelle Verbindungsobjekt übergeben werden.


#### Umbau der neuen Datenbank API auf Doctrine DBAL

25. Classes\Persistence\Legacy\DatabaseConnection.php erbt von Classes\Persistence\Doctrine\DatabaseConnection.php
26. Methoden die nicht der CGL folgen, werden in richtiger Schreibweise in die neue API übernommen, die alten Methoden zeigen auf die neuen Methoden
27. neue Methoden werden in der neuen API implementiert
28. Connection erfolgt nun über Doctrine
29. \Konafets\DoctrineDbal\Persistence\PreparedStatement.php nutzt intern Doctrines /PDO Prepared Statement 
30. Exceptions erstellen und nutzen


### Änderungen an TYPO3 CMS

Die von Composer erstellte \textit{Autoload}-Datei, muß von TYPO3 CMS in die Datei \phpinline{\TYPO3\CMS\Core\Core\Bootstrap} eingebunden werden, damit die von Doctrine DBAL zur Verfügung gestellten Klassen geladen werden können.

\begin{listing}
\begin{phpcode}	/**
	 * Initializes the Class Loader
	 *
	 * @return Bootstrap
	 * @internal This is not a public API method, do not use in own extensions
	 */
	public function initializeClassLoader() {
		/** Composer loader */
		require_once PATH_typo3conf . 'ext/doctrine_dbal/vendor/autoload.php';

		$classLoader = new ClassLoader($this->applicationContext);
		...
	}
\end{phpcode}
\caption{Einbinden der von Composer erstellten Autoloaddatei}
\label{lst:composerAutoload}
\end{listing}   

Der Installationsprozess wurde dahingehend angepasst, dass nach Installation des Prototyps zunächst ein Auswahlfeld erscheint, über das das zu verwendende \gls{dbms} festgelegt wird.

Das dynamisch erzeugte Feld besteht aus einem Partial. Es enthält die vom Install Tool gefundenen Datenbanktreiber. Der Codeteil ist in der Datei \pdf{typo3/sysext/install/Classes/Controller/Action/Step/DatabaseConnect.php} ab Zeile 606 zu finden.

![image](../gfx/InstallingTYPO3/DoctrineDBAL/03a - DatabaseConnectionDoctrineLoadedDriverSelection.png)

Nach der Auswahl des Datenbanktreibers werden die Inputfelder eingeblendet. Da die verschiedenen \gls{dbms} unterschiedliche Daten für den Aufbau einer Verbindung zur Datenbank benötigen, ist die Anzahl und Art der Felder von dem ausgewählten Treiber abhängig. Der Codeteil ist in der Datei \pdf{typo3/sysext/install/Classes/Controller/Action/Step/DatabaseConnect.php} ab Zeile 556 zu finden. Abbildung~\ref{fig:sqlCredentials} zeigt die  Felder für MySQL. 

![image](../gfx/InstallingTYPO3/DoctrineDBAL/03b - DatabaseConnectionDoctrineLoadedCredentials.png)
 
Generell wurde das Eingabefeld für die Datenbank entfernt, da diese im nächsten Schritt ausgewählt wird. Hinzugefügt wurde neben den schon erwähnten Auswahlfeld für die Datenebanktreiber, das Eingabefeld für das Datenbank Charset.

Damit die eingebenen Daten weiterverarbeitet werden konnten wurden diese in der Datei \phpinline{\TYPO3\CMS\Install\Controller\Action\Step\DatabaseConnect} ergänzt. Dort werden sie auch permanent in der Konfigurationsdatei pdf{thesis.dev/http/typo3conf/LocalConfiguration.php} gepeichert.

\begin{listing}
\begin{phpcode}
if (!empty($postValues['database'])) {
  $value = $postValues['database'];
  if (strlen($value) <= 50) {
    $localConfigurationPathValuePairs['DB/database'] = $value;
  }
}
\end{phpcode}
\end{listing}

Die in den Formularen eingegeben Datenbankinformationen werden über POST Variablen an das Install Tool gesendet und anschließend in der Konfigurationsdatei \pdf{thesis.dev/http/typo3conf/LocalConfiguration.php} gepeichert. Während der Laufzeit stehen sie entweder in dem Array \phpinlin{$postValues} oder in dem globalen Array \phpinline{$GLOBALS['TYPO3_CONF_VARS']['DB']} zur Verfügung. Bevor diese Werte verwendet wurden, wurde im Orignalcode per \phpinline{isset()} geprüft, ob sie vorhanden sind. Dies schließt jedoch nicht aus, dass die Variablen leer sind. Als Folge dessen wird ein leerer Wert übergeben. Als Beispiel sei die Möglichkeit der Wahl zwischen einer Socket basierten Datenbankverbindung oder einer Verbindung per Port erwähnt. Da beide Eingabefelder im HTML Code definiert und per htmlinline{name}-Attribut ein Variable zugewiesen bekommen haben, die per POST-Request an das Install Tool gesendet werde, wertet PHP diese Variable als gesetzt und verarbeitet speichert einen leeren Wert für den Port. Um das zu verhindern, wurden an allen notwendigen Stellen der Aufruf von \phpinline{isset()} zu \phpinline{!empty()} geändert. Diese fand in den Klassen \phpinline{\TYPO3\CMS\Core\Core\Bootstrap}, \phpinline{\TYPO3\CMS\Install\Controller\Action\Step\DatabaseConnect} und \phpinline{\TYPO3\CMS\Install\Controller\Action\Step\DatabaseSelect} statt.

Die vollständigen Änderungen an TYPO CMS können unter folgender Adresse nachvollzogen werden:

- typo3/sysext/core/Classes/Database/DatabaseConnection.php \url{https://github.com/Konafets/TYPO3CMSDoctrineDBAL/commit/a8fd161cf660974e1435f37b82a0e6f86f000e05}





## Konvertierung der *.sql Datein in das Doctrine Schema

_Änderungen am Prototypen_

1.

_Änderungen am TYPO3 CMS_

1.

## Implementierung einer Fluenten Query API

_Änderungen am Prototypen_

1.

## Nutzen der Fluenten Query API im Core


_Änderungen am TYPO3 CMS_

1.















## Testgetriebene Entwicklung der neuen API

### Implementierung der neuen API
- Anlegen der Klassen (Geschäftslogik und Testklassen)
- Implementation der Methoden und 
- Aktivierung der neuen API
- Schemakonvertierung
- Fluent API
- Query Builder 
  - Erklärung
  - Beispiele
- Facade Pattern
  - Erklärung
  - Beispiele
  - UML 
  - Query Builder 
- verschiedene Ansätze
  - Constraint Objekte wie in Extbase
  - …
  - schlußendlich Inspiriert von EzPublish
    - GitHub 
- echte Query Objekte
  
   
### Installation der Extension
- Vorher / Nachher Bilder von Installprozess
- 

### Benutzung der Extension
- transparent im Backend
- Beispiele der API
- Migration einer alten Funktion auf die Neue API

### Probleme
- Probleme mit Postgres
  - BLOB -> Dateistream
- TYPO3 Compare Tool
  
### Eigenheiten von Doctrine
- boolean -> tinyint(1)
- auto_increment + Default null



## Ideen

- TCA Ablösung in Form von YAML / XML / JSON

Stefano Kowalke
SteKo
soko
fanoo
noco
noko




 
 
