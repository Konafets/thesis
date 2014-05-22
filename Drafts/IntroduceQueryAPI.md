# Umstellen der Query-Methoden auf Doctrine DBAL und Prepared Statements


In Kapitel~\ref{sec:currentSituation} zur Datenbank API wurde bereits die Unterteilung in Generierende und Ausführende SQL-Methoden erläutert. Die Generierung der Anfrage erfolgt anhand der Parameter, die – zusammen mit den entsprechenden SQL-Anweisungen – in eine Zeichenkette umgewandelt und zurückgegeben werden.

\begin{listing}[H]
\begin{phpcode}
public function INSERTquery($table, array $fields_values, $no_quote_fields = FALSE) {
  …
    // Quote and escape values
	$fieldsValues = $this->fullQuoteArray($fields_values, $table, $no_quote_fields);
	// Build query
	$query = 'INSERT INTO ' . $table . ' (' . implode(',', array_keys($fields_values)) . ') VALUES ' . '(' . implode(',', $fields_values) . ')';
		
	...

	return $query;
  }
}
\end{phpcode}
\caption{Original INSERTquery der alten Datenbank API}
\label{lst:INSERToldAPI}
\end{listing}

Doctrine DBAL bietet mit dem \phpinline{QueryBuilder} eine Klasse an, mit der die Formulierung von SQL-Anweisungen abstrahiert werden kann. Neben den notwendigen CRUD-Methoden (\phpinline{isnert()}, \phpinline{select(), \phpinline{delete()}, \phpinline{update()}}) stellt die Klasse Methoden wie \phpinline{prepare()}, \phpinline{bindParam()} und \phpinline{binValue()} zur Benutzung in Zusammenhang mit Prepared Statements zur Verfügung. Das folgende Beispiel zeigt eine abstrahiertes \mysqlinline{INSERT INTO}-Anweisung.

\begin{listing}[H]
\begin{phpcode} 
$query = $queryBuilder
    ->insert('be_users')
    ->values(
      array(
        'username' => 'stefano.kowalke',
        'admin' => 1,
        'password' => 'secret'
      )
    )

// INSERT INTO 'be_users' (username, admin, password) VALUES (stefano.kowalke, 1, secret);
$query->getSQL();  

// Ausführung der Anweisung
$query->execute();  
\end{phpcode}
\caption{}
\label{}
\end{listing}

Die Generierung der SQL-Anweisung aus Listing~\ref{lst:INSERToldAPI} konnte durch die Nutzung des \phpinline{QueryBuilders} wie folgt verändert werden:

\begin{listing}[H]
\begin{phpcode} 
public function INSERTquery(...) {
…
  $query = $this->link->createQueryBuilder()
    ->insert('pages')
    ->values(array('title' => 'Foo'))
    ->getSQL();
…
}
\end{phpcode}
\caption{Generierung der SQL-Anfrage wird an den QueryBuilder delegiert}
\label{lst:createSqlByDirectCallToQueryBuilder}
\end{listing}

Dies wurde für alle generienden Methoden der alten API realisiert. Dabei wurde der Code der Methoden in die neue API kopiert, während die alten Klassen den Aufruf an ihre Elternmethode delegieren \phpinlin{return parent::insertQuery(…)}. Dies wurde notwendig, da der Methodenname der alten API nicht der \gls{cgl} entsprach; der Aufruf über \phpinline{parent::} und nicht über \phpinline{$this->} wurde notwendig, da \gls{php} nicht zwischen Groß- und Kleinschreibung unterscheidet - die Methoden \phpinline{INSERTquery()} und \phpinline{insertQuery()} werden als identisch angesehen. 

Durch diesen Schritt wurde die letzte Abhängikeit zu einem bestimmten \gls{dbms} aufgelöst.

Während die alte Datenbank API wie gewohnt benutzt werden kann (siehe Listing~\ref{lst:resetStageOfElementsOldAPI), wird für die neue Datenbank API eine Abstraktion zur Formulierung von SQL-Anweisungen nach dem Vorbild des \phpinline{QueyBuilers} angestrebt (siehe Listing~\ref{lst:resetStageOfElementsNewAPI)). Wie zu sehen ist, werden dort auch die logischen Ausdrücke abstrahiert. 

\begin{listing}[H]
\begin{phpcode}
protected function resetStageOfElements($stageId) {
  $fields = array('t3ver_stage' => \TYPO3\CMS\Workspaces\Service\StagesService::STAGE_EDIT_ID);
  foreach ($this->getTcaTables() as $tcaTable) {
    if (BackendUtility::isTableWorkspaceEnabled($tcaTable)) {
      $where = 't3ver_stage = ' . (int)$stageId;
      $where .= ' AND t3ver_wsid > 0 AND pid=-1';
      $GLOBALS['TYPO3_DB']->exec_UPDATEquery($tcaTable, $where, $fields);
	}
  }
}
\end{phpcode}
\caption{}
\label{lst:resetStageOfElementsOldAPI}
\end{listing}

\begin{listing}[H]
\begin{phpcode}
protected function resetStageOfElements($stageId) {
  ...
      $where = 't3ver_stage = ' . (int)$stageId;
      $where .= ' AND t3ver_wsid > 0 AND pid=-1';;
      $dbh = $GLOBALS['TYPO3_DB'];
      $expr = $dbh->expr();
      $query = $dbh->createInsertQuery();
      $query->insertInto($tcaTable)
        ->values($fields)
        ->where(
          $expr->equals(t3ver_stage, $stageId),
          $expr->greaterThan(t3ver_wsid, 0),
          $expr->equals(pid, -1)
        )     
      );
	}
  }
}
\end{phpcode}
\caption{}
\label{lst:resetStageOfElementsNewAPI}
\end{listing}

Es wurde darauf verzichtet die API des \phpinline{QueryBuilder} direkt anzubieten. Die Gründe dafür sind 

- vereinfachte API: ein \phpinline{Query}-Objekt bietet ledigich die für seine Domain notwendigen Methoden an. Dadurch kann es auch nicht zur Formulierung von syntaktisch falschen Anfragen kommen.
- keine Abhängigkeit zu Doctrine DBAL: die Implementation der Methoden kann – wie am Anfang des Kapitels gezeigt - jederzeit gegen etwas anderes ausgetauscht werden.

Zur Umsetzung wurde das \textit{Facade}-Entwurfsmuster angewendet. Hier stellt ein Domain-spezifisches \phpinline{Query}-Objekt die \textit{Fassade} dar und bietet nach außen lediglich eine Teilmenge der von \phpinline{QueryBuilder} zur Verfügung gestellten Methoden.

\begin{figure}[H]
    \centering
    \includegraphics[scale=0.5]{gfx/uml/FacadePattern.eps}
    \caption{Schematischer Aufbau des Fassade-Entwurfsmuster}
    \label{fig:facadePattern}
\end{figure}

Das folgende UML-Diagramm zeigt anhand der \phpinline{TruncateQuery}- und \phpinline{InsertQuery}-Objekte die fertige Hierachie. Die Wurzel stellt ein \phpinline{QueryInterface} dar, in dem alle Methoden festgelegt worden sind, die von allen \phpinline{Query}-Objekten implementiert werden müssen. Dadurch wird sichergestellt, dass jedes \phpinline{Query}-Objekt in Verbindung mit PreparedStatements verwendet werden kann und die Kenntnis darüber besitzt wie es in eine \gls{sql}-Anweisung konvertiert und ausgeführt werden kann. 

Das Interface wird von einem spezialisierten Interface erweitert, welche die Domain-spezifischen Methoden festlegt. So wird muß ein \phpinline{Query}-Objekt vom Typ \phpinline{TruncateQuery} die Methoden \phpinline{truncate()}, \phpinline{getType()} und \phpinline{getSql()} implementieren. Alle weiteren vom \phpinline{QueryInterface} vorgeschriebenen Methoden werden von dem \phpinline{AbstractQuery}-Objekt implementiert, dass von dem jeweilgen \phpinline{Query}-Objekt erweitert wird.

\begin{figure}[H]
    \centering
    \includegraphics[scale=0.5]{gfx/uml/NewAPI/InsertQuery.eps}
    \caption{Aufbau der Query-API}
    \label{fig:newQueryAPI}
\end{figure}

Die angebotenen Methoden eines \phpinline{Query}-Objekts delegieren den Aufruf an den \phpinline{QueryBuilder}. 

\begin{listing}[H]
\begin{phpcode}
public function insertInto($table) {
  $this->queryBuilder->insert($table);
	
  return $this;
}

public function values(array $values) {
  $this->queryBuilder->values($values);
  
  return $this;
} 

public function getSql() {
  return $this->queryBuilder->getSQL();
}
\end{phpcode}
\caption{Die Konvertierung des InsertQuery erfolgt über den QueryBuilder}
\label{lst:getSqlMethodOfInsertQuery}
\end{listing}

Der Klasse \phpinline{\Konafets\DoctrineDbal\Persistence\Doctrine\DatabaseConnection} wurden \phpinline{creat*Query()}-Methoden hinzugefügt die die Instatiierung eines \phpinline{Query}-Objekts vereinfachen.

\begin{listing}[H]
\begin{phpcode} 
public function createInsertQuery() {
  if (!$this->isConnected) {
    $this->connectDatabase();
  }

  return GeneralUtility::makeInstance('\\Konafets\\DoctrineDbal\\Persistence\\Doctrine\\InsertQuery', $this->link);
}
\end{phpcode}
\caption{Die Erzeugung eines InsertQuery-Objekts}
\label{lst:createInsertQuery}
\end{listing}

Nun konnte die Abhängigkeit zu Doctrine DBAL durch den direkten Aufruf des \phpinline{QueryBuilders} aus Listing~\ref{lst:createSqlByDirectCallToQueryBuilder} entfernt werden:

\begin{listing}[H]
\begin{phpcode} 
public function insertQuery(...) {
…
  $query = $this->createInsertQuery()
    ->insertInto('pages')
    ->values(array('title' => 'Foo'))
    ->getSQL();
…
}
\end{phpcode}
\caption{}
\label{}
\end{listing}





\begin{listing}[H]
\begin{mysqlcode} 
\mysqlinline{INSERT INTO 'table' ('column_a', 'column_b', 'column_'c) VALUES ('value_a', 'value_b', 'value_c');}\end{phpcode}
\caption{}
\label{}
\end{mysqlcode}
\end{listing}

Bei dem Aufbau  der Anfrage diente Diese konnte in folgende Anweisung abstrahiert werden:

\begin{listing}[H]
\begin{phpcode} 
insertInto('table')->values('')
\caption{}
\label{}
\end{mysqlcode}
\end{listing}


- EzPublish
- FLuentAPI
- FascadePattern
- QueryObjekte
- ExpressionAPI -> inspired by Extbase



interface \Konafets\DoctrineDbal\Persistence\Database\DatabaseConnectionInterface {}

class \Konafets\DoctrineDbal\Persistence\DoctrineDatabaseConnection implements \Konafets\DoctrineDbal\Persistence\Database\DatabaseConnectionInterface { }