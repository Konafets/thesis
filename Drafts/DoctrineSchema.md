# Doctrines Schemarepräsentation
\section{Doctrines Schemarepräsentation}
\label{sec:doctrineSchema}

Während der Installation werden alle notwendigen Datenbanktabellen angelegt. Die dafür notwendigen SQL-Anweisungen halten die Extensions in \pdf{*.sql}-Dateien vor. Dabei handelt es sich um einfache Textdateien, die aus ein oder mehreren \mysqlinline{CREATE TABLE} Anweisungen bestehen. Diese werden von \phpinline{TYPO3\CMS\Core\Database\SqlParser} geparst, auseinandergenommen und neu zusammengesetzt, wobei kleinere Syntaxfehler behoben werden. Eine Hauptaufgabe des Parsers liegt darin, diejenigen \pdf{*.sql}-Dateien zu erkennen und zu vereinen, die die gleiche Tabelle mit unterschiedlichen Feldern anlegen wollen. Als Bespiel seien die Systemextensions \texttt{ext:frontend} und \texttt{ext:felogin} erwähnt, die beide die Tabelle \texttt{fe_users} anlegen.

\begin{listing}
\begin{mysqlcode}
# ext:felogin
CREATE TABLE fe_users (
	felogin_redirectPid  tinytext,
	felogin_forgotHash  varchar(80) default '' 
);

# ext:frontend
CREATE TABLE fe_users (
	uid int(11) unsigned NOT NULL auto_increment,
	pid int(11) unsigned DEFAULT '0' NOT NULL,
	tstamp int(11) unsigned DEFAULT '0' NOT NULL,
	username varchar(50) DEFAULT '' NOT NULL,
	password varchar(100) DEFAULT '' NOT NULL,
	usergroup tinytext,
	…
);
\end{mysqlcode}
\caption{}
\label{lst:sameSQLDefinitionOfFeUsers}
\end{listing}

Der Importvorgang erfolgt durch \phpinline{\TYPO3\CMS\Install\Controller\Action\Step\DatabaseData::importDatabaseData()}, die den Ist-Zustand der Datenbank mit dem Soll-Zustand vergleicht. Der Soll-Zustand wird durch den Service \phpinline{\TYPO3\CMS\Install\Service\SqlExpectedSchemaService::getTablesDefinitionString()} anhand der  \pdf{*.sql}-Dateien ermittelt. Der Ist-Zustand wird durch \phpinline{\TYPO3\CMS\Install\Service\SqlSchemaMigrationService::getFieldDefinitions_database()} ermittelt und anschließend durch die Methoden \phpinline{getDatabaseExtra()} und \phpinline{getUpdateSuggestions()} derselben Klasse verglichen. Die genauere Analyse der Methoden würde für die Arbeit zu weit und kann zu Kopfschmerzen führen.\footnote{Der Autor spricht hier aus eigener Erfahrung.} Anschließend wird die Differenz in Form von SQL-Anweisungen an die Datenbank gesendet.

Statische Daten werden über Dateien mit der Bezeichnung \pdf{ext_tables_static+adt.sql}, die einer Extension beiliegen, in die Datenbank eingfügt. Im Moment besitzt lediglich der Extension Manager solch eine Datei, die die URL zum \gls{ter} einfügt.

## Umstellung auf Doctrine Schema

Um die Abhängigkeit des Install Tools zu MySQL bei der Erstellung der Basistabellen aufzulösen wurden die *.sql Dateien in die Schema Syntax von Doctrine überführt. Dies wurde bereits in Kapitel~\ref{basics:doctrine:subsec:dbal} durch die Erstelltung eines Schemas skizziert. Die Zielstellung war die vollständige Umstellung auf die Nutzung von \phpinline{\Doctrine\DBAL\Schema\Schema}-Objekten, da diese die notwendige Abstraktion von dem \gls{dbms} bieten und von Doctrine DBAL jederzeit anhand der aktuell verwendenten Plattform in die entsprechenden SQL-Anweisungen konvertiert werden können.

Dazu mußten die \pdf{*.sql}-Dateien der Systemextensions umgewandelt werden, sowie die Erstellung der dynamischen Cachetabellen implementiert werden. Im ersten Schritt wurden die \pdf{*.sql}-Dateien der folgenden Sytemextension in die Schemarepräsentation von Doctrine migriert:

\begin{itemize}
\item typo3/sysext/core
\item typo3/sysext/extbase
\item typo3/sysext/extensionmanager
\item typo3/sysext/felogin
\item typo3/sysext/filemetadata
\item typo3/sysext/frontend
\item typo3/sysext/impexp
\item typo3/sysext/indexed_search
\item typo3/sysext/indexed_search_mysql
\item typo3/sysext/linkvalidator
\item typo3/sysext/openid
\item typo3/sysext/rsauth
\item typo3/sysext/rtehtmlarea
\item typo3/sysext/scheduler
\item typo3/sysext/sys_action
\item typo3/sysext/sys_note
\item typo3/sysext/version
\item typo3/sysext/workspaces
\end{itemize}

Die Datei \pdf{ext_tables_static+adt.sql}, die die statischen Daten enthält wurde als Klasse TYPO3\CMS\Extensionmanager\Schema\DefaultData umgesetzt.

Zur Ermittlung des Soll-Zustand der Datenbank wurde der Klasse \phpinline{\TYPO3\CMS\Install\Service\SqlExpectedSchemaService} die Methode \phpinline{getTablesDefinitionAsDoctrineSchemaObjects()} hinzugefügt, die die vorhandenen \pdf{Schema.php}-Dateien sucht und per \phpinline{require} dem PHP-Skript zur Verfügung stellt. [Zeile 136] Die so eingebundenen Dateien werden zur weiteren Verarbeitung in einem Array gespeichert und als Parameter einer Funktion übergeben, die – über die Signal/Slot-Implementation von TYPO3 CMS – ein Signal emittiert. Die empfangende Methode erstellt daraufhin die Tabellen für das \textit{Caching Framework}. Diese werden von TYPO3 CMS dynamisch nach dem Muster \texttt{cf_cache_<variablerBezeichner>} beziehungsweise \texttt{cf_cache_<variablerBezeichner>_tags} erstellt. Die dazu implementierten Klassen \phpinline{\TYPO3\CMS\Core\Cache\Schema\Typo3DatabaseBackendCacheSchema} und \phpinline{\TYPO3\CMS\Core\Cache\Schema\Typo3DatabaseBackendTagsSchema}  dienen dabei als Templates, denen bei der Instantiierung der <VariableBezeichner> mitgegeben wird. Sie erstellen intern ein Objekt vom Typ \phpinline{\Doctrine\DBAL\Schema\Schema}, welches schließlich die ensprechende Cachetabelle repräsentiert.

Einen Sonderfall stellen die Cache- und Tagstabellen für Extbase dar, da sie von TYPO3 CMS aus internen Gründen zunächst mit einem temporären Namen erstellt werden und erst im weiteren Verlauf in die Tabellen \texttt{cf_extbase_object} und \texttt{cf_extbase_object_tags} umbenannt werden können. Bereits hier zeigten sich die Vorteile durch die  interne Verwendung von \phpinline{\Doctrine\DBAL\Schema\Schema}-Objekten. Die Umbenennung konnte durch \phpinline{renameTable()} des Objekts realisiert werden, anstelle der Nutzung von \phpinline{str_replace()}, wie dies im originalen Code implementiert wurde.

Das von dem Signal zurückgegeben Schema-Array enthält nun alle zu erstellenden Tabellen - auch jene, die – wie oben beschrieben – von den Extensions mehrfach mit unterschiedlichen Feldern definiert wurden. Um diese Tabellen zu vereinen, wurde die Methode \phpinline{flattenSchemas()} in der gleichen Klasse implementiert, der das Schema-Array übergeben wird.

Das daraus resultierende Array stellt den Soll-Zustand der Datenbank dar.

Zur Ermittlung des Ist-Zustandes wurde die Klasse \phpinline{\TYPO3\CMS\Install\Service\SqlSchemaMigrationService} in die Extension kopiert und per XCLASS registriert. Sie wird von der Klasse \phpinline{\Konafets\DoctrineDbal\Install\Service\SqlSchemaMigrationService} um die Methode \phpinline{getCurrentSchemaFromDatabase()} erweitert, die den \textit{Schema Manager} von Doctrine nutzt um den Zustand der Datenbank unabhängig vom \gls{dbms} abzufragen. Der gleichen Klasse wurde die Methode)  \phpinline{getDifferenceBetweenDatabaseAndExpectedSchemaAsSql()} hinzugefügt um die Differenz zwischen dem Ist- und Sollzustand zu ermitteln. Sie gibt die Differenz in Form der zu erstellenden Tabellen in der jeweiligen SQL-Syntax des benutzten \gls{dbms} zurück.

Damit ist die Abhängigkeit des Install Tools zu einem bestimmten \gls{dbms} aufgelöst.





\begin{listing}
\begin{phpcode}
public function getCachingFrameworkRequiredDatabaseSchema() {
    …
    $extbaseObjectFakeName = uniqid('extbase_object');
	$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$extbaseObjectFakeName] = array(
	    'groups' => array('system')
	);
	…
	$cacheSqlString = \TYPO3\CMS\Core\Cache\Cache::getDatabaseTableDefinitions();
	$sqlString = str_replace($extbaseObjectFakeName, 'extbase_object', $cacheSqlString);
	...
}
\end{phpcode}
\caption{Erstellen der Extbase Cache Tabelle}
\label{lst:extbaseFakeTableLegacy}
\end{listing}





protected function importDatabaseData() {
  
  /** @var \TYPO3\CMS\Install\Service\SqlExpectedSchemaService $expectedSchemaService */
  $expectedSchemaService = $this->objectManager->get('TYPO3\\CMS\\Install\\Service\\SqlExpectedSchemaService');
  $schemaMigrationService = $this->objectManager->get('TYPO3\\CMS\\Install\\Service\\SqlSchemaMigrationService');

  // Raw concatenated ext_tables.sql and friends string
  $expectedSchemaString = $expectedSchemaService->getTablesDefinitionString(TRUE);
  $statements = $schemaMigrationService->getStatementArray($expectedSchemaString, TRUE);
  list($_, $insertCount) = $schemaMigrationService->getCreateTables($statements, TRUE);

  $fieldDefinitionsFile = $schemaMigrationService->getFieldDefinitions_fileContent($expectedSchemaString);
  $fieldDefinitionsDatabase = $schemaMigrationService->getFieldDefinitions_database();
  $difference = $schemaMigrationService->getDatabaseExtra($fieldDefinitionsFile, $fieldDefinitionsDatabase);
  $updateStatements = $schemaMigrationService->getUpdateSuggestions($difference);

  $schemaMigrationService->performUpdateQueries($updateStatements['add'], $updateStatements['add']);
  $schemaMigrationService->performUpdateQueries($updateStatements['change'], $updateStatements['change']);
  $schemaMigrationService->performUpdateQueries($updateStatements['create_table'], $updateStatements['create_table']);

  foreach ($insertCount as $table => $count) {
    $insertStatements = $schemaMigrationService->getTableInsertStatements($statements, $table);
	foreach ($insertStatements as $insertQuery) {
	  $insertQuery = rtrim($insertQuery, ';');
	  $database->admin_query($insertQuery);
	}
  }
}