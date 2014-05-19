# Doctrines Schemarepräsentation
\section{Doctrines Schemarepräsentation}
\label{sec:doctrineSchema}

Bei der Installation werden nach Betätigung der Schalfläche im vierten Schritt (Abb:.~\ref{fig:installTYPO3LegacyStepFour}) die Basistabellen angelegt. Die Methode \phpinline{\TYPO3\CMS\Install\Controller\Action\Step\DatabaseData::importDatabaseData()} vergleicht dazu den IST-Zustand der Datenbank mit dem SOLL-Zustand. Anschließend wird die Differenz in Form von SQL-Anweisungen an die Datenbank gesendet.


Der SOLL-Zustand wird durch den Service \phpinline{\TYPO3\CMS\Install\Service\SqlExpectedSchemaService::getTablesDefinitionString()} anhand von mehreren \pdf{*.sql}-Dateien ermittelt, welche von einigen Systemextensions bereitgestellt werden. Dabei handelt es sich um einfache Textdateien, die aus ein oder mehreren \mysqlinline{CREATE TABLE} Anweisungen bestehen. Diese werden von \phpinline{TYPO3\CMS\Core\Database\SqlParser} geparst, auseinandergenommen und neu zusammengesetzt, wobei kleinere Syntaxfehler behoben werden. Eine Hauptaufgabe des Parsers liegt darin, diejenigen \pdf{*.sql}-Dateien zu erkennen und zu vereinen, die die gleiche Tabelle mit unterschiedlichen Feldern anlegen wollen. Als Bespiel seien die die Systemextensions \texttt{ext:frontend} und \texttt{ext:felogin} erwähnt, die beide die Tabelle \texttt{fe_users} anlegen.

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

Der IST-Zustand wird durch \phpinline{\TYPO3\CMS\Install\Service\SqlSchemaMigrationService::getFieldDefinitions_database()} ermittelt und anschließend durch die Methoden \phpinline{getDatabaseExtra()} und \phpinline{getUpdateSuggestions()} derselben Klasse verglichen. Die genauere Analyse der Methoden würde für die Arbeit zu weit und möglicherweise zu Kopfschmerzen führen.\footnote{Der Autor spricht hier aus eigener Erfahrung.}

Die Tabellen für das \textit{Caching Framework} von TYPO3 CMS werden dynamisch nach dem Muster \texttt{cf_cache_<variablerBezeichner>} beziehungsweise \texttt{cf_cache_<variablerBezeichner>_tags} erstellt. 

Die Cache- und Tagstabellen für Extbase werden vorerst mit einem Hash erstellt und erst im weiteren Verlauf in die Tabellen \texttt{cf_extbase_object} und \texttt{cf_extbase_object_tags} umbenannt.

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


Statische Daten werden über Dateien mit der Bezeichnung \pdf{ext_tables_static+adt.sql}, die einer Extension beiliegen, in die Datenbank eingfügt. Im Moment besitzt lediglich der Extension Manager solch eine Datei, die die URL zum \gls{ter} einfügt.

Um die Abhängigkeit des Install Tools zu MySQL bei der Erstellung der Basistabellen aufzulösen wurden die *.sql Dateien in die Schema Syntax von Doctrine überführt. Dies wurde bereits in Kapitel~\ref{basics:doctrine:subsec:dbal} durch die Erstelltung eines Schemas skizziert.

Die *.sql-Dateien der folgenden Sytemextension wurden von Hand in die Schemarepräsentation von Doctrine migriert:

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

Zur Ermittlung des Soll-Zustand der Datenbank wurde der Klasse \phpinline{\TYPO3\CMS\Install\Service\SqlExpectedSchemaService} die Methode \phpinline{getTablesDefinitionAsDoctrineSchemaObjects()} hinzugefügt, die die vorhandenen \pdf{Schema.php}-Dateien sucht und per \phpinline{require} in ein Array speichert. [Zeile 136]

Die Methode emittiert ein Signal über den Signal/Slot Mechanismus, woraufhin unter anderem die Erstellen der Datenbanktabellen für das Caching Framework angestoßen wird. 

Zur Erstellung der Cachetabellen wurden die Klassen \phpinline{\TYPO3\CMS\Core\Cache\Schema\Typo3DatabaseBackendCacheSchema} und \phpinline{\TYPO3\CMS\Core\Cache\Schema\Typo3DatabaseBackendTagsSchema} erstellt, die als Templates dienen. Bei der Instantiierung wird dem Konstruktur der <VariableBezeichner> mitgegeben. Intern wird ein Objekt vom Typ \phpinline{\Doctrine\DBAL\Schema\Schema} erstellt, welches die ensprechende Cachetabelle repräsentiert.

Wie oben beschrieben, werden die Cachetabellen für Extbase zunächst mit einem Fake-Namen erstellt und erst später gegen den richtigen Namen ersetzt. Im Gegensatz zum orignalen Code, bei dem \phpinline{str_replace()} dazu genutzt wurde, bietet Doctrine mit \Doctrine\DBAL\Schema\Schema::renameTable() bereits eine Methode zum Umbennen an.

Dieses Array beinhaltet alle zu erstellenden Tabellen, auch jene, die von den Extensions mehrfach mit unterschiedlichen Feldern definiert wurden. Um diese Tabellen zu vereinen, wurde in der Klasse die \phpinline{flattenSchemas()} implementiert.




### 2) Adjust the Install Tool
- Die Methode \TYPO3\CMS\Install\Controller\Action\Step\DatabaseData::importDatabaseData() legt die Datenbank an
- nutzt *.sql Dateien aus den Extensions
- \phpinline{\TYPO3\CMS\Install\Service\SqlExpectedSchemaService}
- \phpinline{\TYPO3\CMS\Install\Service\SqlSchemaMigrationService}
- 



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

### 3) Adjust the prototype
