## PDO
Wie wir im Kapitel über Doctrine sehen werden [Hängt davon ab, wo dieses Kapitel eingefügt wird], baut es auf \gls{pdo} auf. Es verwendet dessen Konzepte und erweitert diese. Um ein tieferes Verständnis von Doctrine \gls{dbal} zu erlangen, kommt man nicht umhin sich mit \gls{pdo} zu beschäftigen.

Im diesem Kapitel wird auf den Hintergrund von \gls{pdo}. Es werden die Fähigkeiten und Grenzen aufgezeigt, sowie anhand von einfachen Beispielen die Funktionsweise illustriert.

### Was ist PDO
PHP Data Objects (PDO) stellt eine Abstraktionsbibliothek für die Interaktion mit \gls{dbms} verschiedener Hersteller dar und orientiert sich dabei an dem Konzept der Java Data Objects (JDO) \gls{jdo}[LINK zu jdo einfügen]. Es ist seit Version 5.1 in \gls{php} enthalten.

Der Grund der Existenz einer solchen Bibliothek liegt darin begründet, dass man in PHP viele verschiedene \gls{dbms} über jeweils eigene Extensions ansprechen kann. Die dazu extra zu installierenden Extensions bringt jeweils eine eigene API für die \gls{dbms} mit, so das sich die Art des Aufbaues der Verbindung und das Absetzen von Anfragen von \gls{dbms} zu \gls{dbms} unterschiedlich ausgestaltet ist. 
Dies kann zu einem hohem Aufwand führen, wenn die Anwendung von einem \gls{dbms} auf ein anderes umgestellt werden soll. \gls{pdo} hingegen definiert unabhängig vom zugrundeliegenden \gls{dbms} eine einheitliche Schnittstelle für das Verbindungsmanagement und die Kommunikation mit der Datenbank. 

Neben \gls{pdo} existieren unter anderen die Projekte  MDB2\footnote{\url{http://pear.php.net/package/MDB2}} und ADOdb\footnote{\url{http://adodb.sourceforge.net/}}, die den gleichen Ansatz verfolgen. Wenn man sich jedoch die letzten Releasedaten\footnote{bei MDB2 2.5.0b5 war die letzte Veröffentlichung am 2012-10-29; bei ADOdb am 2012-09-04} beider Projekte ansieht, kann man leicht den Eindruck erhalten, dass sie nicht mehr weiterentwickelt werden.

Ein weiterer Vorteil von \gls{pdo} gegenüber anderen Projekten ist die Geschwindigkeit, da es vollständig in C++ programmiert wurde.

(vgl. \cite[S. 5]{book:popel2007pdo})
  
### Grenzen / Limitierungen
Bei einer Abstraktion wird stets etwas Spezifisches, durch das Weglassen von Details, in etwas Allgemeines überführt. Im Fall von \gls{pdo} wird der andere Weg gegangen – es werden allgemeine \gls{sql}-Anfragen in den Dialekt\footnote{Als Dialekt wird die Hersteller-eigene Implementation des \gls{sql}-Standards genannt, dass sich im Umfang und Syntax vom Standard unterscheidet.} des Herstellers übersetzt. 

Aus diesem Grund vermag es \gls{pdo} nicht eine SQL-Abfrage, die in dem Dialekt eines Herstellers formuliert wurde, in den eines anderen zu übersetzen. Stattdessen muss die Anfrage so nah wie möglich am Standard gestellt werden, um als portabel zu gelten.

[Beispiel einfügen SQL-Standard und eigene Erweiterung von MySQL -> Siehe Buch Seite 17]
  
### Verwendung
Der grundlegenden Unterschied von PHP-Extensions wie die für MySQL und PosgreSQL zu PDO besteht darin, dass die zuerst genannten eine prozeduale Bibliothek darstellen und \gls{pdo} streng Objekt-orientiert aufgebaut ist. Während diese Extensions lediglich Funktionen zur Interaktion mit der Datenbank zur Verfügung stellen, die keine weiteren Informationen über den inneren Zustand der Verbindung besitzen, führt \gls{pdo} Klassen ein, die sowohl die Verbindung als auch die eine Abfrage kapseln und als Schnittstelle dienen.

Die Klasse (\phpinline{PDO}) beinhaltet die Verbindung zur Datenbank und stellt Methoden zum Verbindungsmanament bereit, während die Klasse \phpinline{PDOStatement}eine Schnittstelle zu Anfragen und teilweise auch zur Ergebnismenge\footnote{Da alle betrachteten Datenbanken den relationalen Datenbanken zuzuschreiben sind, handelt es sich bei den Datenbanktabellen um die mathematischen Beschreibung einer Relation [http://de.wikipedia.org/wiki/Relationale_Datenbank]. Zudem kann eine Relation/Tabelle als eine Menge aufgefasst werden. Verknüpft man Relationen mit Operatoren (Abfrage) erhält man stets wieder eine Relation. Somit ist das Ergebnis einer Abfrage eine Menge - die Ergebnismenge} bietet.

Im Folgenden wird die Verwendung der Klassen an einfachen Beispielen erläutert. Dabei werden die Unterschiede zur den klassischen Verfahren (MySQL und PostgreSQL) demonstriert. Damit \gls{pdo} mit verschiedenen \gls{dbms} benutzt werden kann, müssen die Treiber des entsprechenden \gls{dbms} installiert sein. Als Grundlage der Abfragen und Ergebnisse dient eine Datenbank mit den folgenden Tabellen. Es wird davon ausgegangen, dass sie bereits erstellt wurde.
    
    
\begin{Verbatim}
    students
	+----+------------+-----------+-------+	| id | first_name | last_name | house |	+----+------------+-----------+-------+	|  1 | Lucius     | Malfoy    |   4   |	|  3 | Herminone  | Granger   |   1   |
	|  4 | Ronald     | Weasley   |   1   |
	|  5 | Luna       | Lovegood  |   3   |	|  6 | Cedric     | Diggory   |   2   |	+----+------------+-----------+-------+
    
    houses
    +----+------------+
    | id | name       |
    +----+------------+
    |  1 | Gryffindor |
    |  2 | Huffelpuff |
    |  3 | Ravenclaw  |
    |  4 | Slytherin  |
    +----+------------+
\end{Verbatim}

#### Verbindung aufbauen
Traditionell wird eine Verbindung wie folgt aufgebaut:

	\begin{phpcode}
	// MySQLi
	$connection = mysqli_connect($host, $username, $password, $dbname);

  	// PostgreSQL
  	$connection = pg_connect('host=' . $host . ' dbname=' . $dbname . ' user=' . $userName . ' password=' . $password);
 	\end{phpcode}

Dieses Beispiel zeigt, dass MySQLi\footnote{MySQLi bietet sowohl eine prodezuale als auch eine objektorientierte \gls{api} an. Da TYPO3 CMS auschließlich den  prodezualen Ansatz nutzt und sich dieser nahezu mit derAPI von MySQL deckt, sind die Bespiele in prozedualer Form gehalten.} und PostgreSQL zwar einfache Methoden zur Verfügung stellen, diese sich jedoch in der Benutzung voneinander unterscheiden.

Um eine Verbindung mit \gls{pdo} zu etablieren wird der Konstruktor verwendet, welcher ein Objekt vom Typ PDO zurückgibt. Die Signatur des Konstruktors sieht wie folgt aus:

	\begin{phpcode}
	public PDO::__construct ( string $dsn [, string $username [, string $password [, array $driver_options ]]] )
	\end{phpcode}

Während die Parameter \phpinline{$username} und \phpinline{$password} selbsterklärend sind und über den letzten Parameter \phpinline{$driver_options} Datenbanktreiber-spezifische Einstellungen übergeben werden können, erfordert der erste Parameter eine nähere Beschreibung.

Mit dem Kürzel \phpinline{$dsn} (engl. Data Source Name) ist die Datenquelle gemeint, die in einem bestimmten Format übergeben werden muss. Dabei wird zuerst der Typ des \gls{dbms} angegeben und - getrennt von einem Doppelpunkt - der Datenbank-spezifische Teil.

	\begin{phpcode}   
	// MySQL
  	$connection = new PDO('mysql:host=$host;dbname=$db', $user, $pass);

  	// PostgreSQL
  	$connection = new PDO('pgsql:host=$host dbname=$db', $user, $pass);
  	\end{phpcode}

Das in der Variablen \phpinline{$connection} enthaltene Verbindungsobjekt stellt den Ausgangspunkt für alles Weitere dar. Die naheliegendsten Aktionen nach dem Verbindungsaufbau sind das Absetzen einer SQL-Anfrage an die Datenbank und die Ausgabe des Ergebnisses.

#### Datenbankabfragen
Die als Beispiel dienende Abfrage soll die Nachnamen aller Studierenden in alphabetischer Reihenfolge ausgeben. Die in einer Variablen gespeicherten SQL-Abfrage\footnote{Um SQL-Injections zu unterbinden, muß das \gls{sql}-Query entsprechenden maskiert werden. \gls{pdo} bietet dafür die Methode \phpinline{PDO::quote()} an. SQL-Injections werden im Kapitel [KAP Sicherheit einfügen] über Sicherheit eingehend behandelt.\label{ftn:maskQueries} wird an die Datenbank gesendet und das Ergebnis über eine Schleife ausgegeben. Zunächst wird der althergebrachte Weg gezeigt. Beide PHP-Extensions stellen dafür \phpinline{*_query} Funktionen zur Verfügung, die eine Kennung der Datenbankverbindung zurückgeben. Im Fall eines Fehlers geben sie \phpinline{FALSE} zurück. 

	\begin{phpcode}
	$query = 'SELECT last_name FROM students ORDER BY last_name';
	   	// For MySQLi:   	$result = mysqli_query($connection, $query);   	while($row = mysqli_fetch_assoc($result))   	{    	echo $row['last_name'] . "\n";   	}

	// PostgreSQL:   	$result = pg_query($query);   	while($row = pg_fetch_assoc($result))   	{		echo $row['last_name'] . "\n";	}
    \end{phpcode}
    
Das \gls{pdo}-Objekt bietet dafür die Methode \phpinline{query()} an, die ein Objekt vom Typ \phpinline{PDOStatement} zurückgibt. Dieses implementiert das Interface Traversable und kann somit - analog zu einem Array - in einer Schleife durchlaufen werden.

	\begin{phpcode}   	$sql = 'SELECT last_name FROM students ORDER BY last_name';
	
	$statement = $connection->query($sql);
	
	foreach($statement as $row) {
	  echo $row['last_name'];
	}	
	\end{phpcode}
	
Die Ausgabe aller Bespiele lautet:

\begin{Verbatim}
Diggory
Granger
Lovegood
Malfoy
Potter
Weasly
\end{Verbatim}Somit erübrigt sich der Aufruf einer weiteren Methode wie \phpinline{mysqli_result::fetch_assoc}. 

Um das Ergebnis der Abfrage sinnvoll nutzen zu können, gibt es verschiedene Stile (engl. fetch styles) in die es formatiert werden kann. Um dennoch die interne Struktur der Ergebnismenge beinflussen zu können, gibt es in \gls{pdo} Konstanten, die als optionales Argument an \phpinline{query()} übergeben werden. In der Defaulteinstellung benutzt \gls{pdo} die Konstante \phpinline{PDO::FETCH_BOTH}, bei dem das Ergebnis zum einen über den Spaltenbezeichner (wie im obigen Beispiel) als auch über eine Indexzahl angesprochen werden kann. Im Beispiel würde das so aussehen: \phpinline{echo $row[0]}.
Zu allen \phpinline{*_fetch_*}-Methoden gibt es das entsprechende Äquivalent als \gls{pdo}-Konstante. Die Wichtigsten sind:

\begin{itemize}
	\item PDO::FETCH_ASSOC - entspricht *_fetch_assoc() 
	\item PDO::FETCH_NUM   - entspricht *_fetch_array()
	\item PDO::FETCH_ROW   - entspricht *_fetch_row()
\end{itemize}

Darüberhinaus definiert \gls{pdo} noch weitere Konstanten, die keine Ensprechungen haben. 

\begin{itemize}
	\item PDO::FETCH_OBJ - liefert jede Zeile der Ergebnisrelation als Objekt zurück. Die Spaltenbezeichner werden dabei zu Eigenschaften der Klasse.
	\item PDO::FETCH_LAZY - wie PDO::FETCH_OBJ. Das Objekt wird jedoch erst dann erstellt, wenn darauf zugegriffen wird.
	\item PDO::FETCH_CLASS - liefert eine neue Instanz der angeforderten Klasse zurück. Die Spaltenbezeichner werden dabei zu Eigenschaften der Klasse. 
	\item PDO::FETCH_COLUMN - liefert nur eine Spalte aus der Ergebnismenge zurück.
\end{itemize}

Dies stellt eine nicht abschließende Aufzählung dar. Die Dokumentation von \gls{pdo} benennt weitere sogenannte ``Fetch Styles''-Konstanten\footnote{\url{http://mx2.php.net/manual/en/pdo.constants.php}}, die für diese Arbeit jedoch nicht von Interesse sind.
Die Benutzung der Konstanten erfolgt per Übergabe als Parameter an die \phpinline{query()}-Methode:
	\begin{phpcode}
	$statement = $connection->query($sql, PDO::FETCH_NUM);
	
	foreach($statement as $row) {
	  echo $row[0];
	}	
	\end{phpcode}
	
Über das PDOStatement-Objekt\footnote{Leider ist der Begriff dieser Klasse etwas unglücklich gewählt oder es ist ein Designfehler von \gls{pdo}, denn ein Objekt dieser Klasse repräsentiert zum einen ein (Prepared) Statement und, nachdem die Anfrage ausgeführt wurde, die Ergebnisrelation. Die Methoden der Klasse agieren somit einmal auf dem Statement und einmal auf dem Ergebnis.} werden weitere Möglichkeiten wie die Methoden \phpinline{fetch()} und \phpinline{fetchAll()} angeboten, um das Ergebnis zu erhalten. Diese Methoden müssen auch genutzt werden, wenn statt der \phpinline{foreach}-Schleife eine \phpinline{while}-Schleife genutzt werden soll:

	\begin{phpcode}
	$statement = $connection->query($sql);
	
	while($row = $statement->fetch(PDO::FETCH_ASSOC)) {
	  echo $row['last_name'];
	}	
	\end{phpcode}

Zudem gibt es mit \phpinline{fetch_column()} und \phpinline{fetch_Object()} Alternativen für die Verwendung von \phpinline{fetch()} in Verbindung mit den entsprechenden Konstanten. 

#### Prepared Statements (PS)
Bereits MySQLi führt Prepared Statements ein, somit sind sie in der PHP-Welt nicht so neu. Während MySQLi nur einen Typ von Prepared Statements unterstützt, bietet \gls{pdo} eine weitere sinnvolle Variante an. Im Folgenden wird das Konzept und der Nutzen von Prepared Statements kurz erklärt.

Prepared Statements können als eine Vorlage für SQL-Abfragen verstanden werden, die immer wieder, mit verschiedenen Werten, ausgeführt werden. Dabei kann ein \gls{dbms} die Struktur dieses Templates einmalig analyisieren und vorkompiliert im Cache speichern. Bei jedem erneuten Aufruf setzt es lediglich die anderen Werte anstelle von Platzhaltern ein, was die Ausführung schneller macht. (vgl. \cite[S. 75]){book:popel2007pdo}

Zur Demonstration soll je ein Codebeispiel dienen. Dabei fügen wir neue Studierende in die oben gezeigte Datenbanktabelle ein. Der sprechende Hut\footnote{\url{http://de.harry-potter.wikia.com/wiki/Sprechender_Hut}} hat bereits über die Häuser der Neuzugänge entschieden. Um die Abfrage einfach zu halten, wird der Fremdschlüssel der Tabelle für die Häuser direkt in dem Query angegeben.

Die Daten der Studierenden liegen in einem assoziativen Array vor und können somit über eine For-Schleife durchiteriert werden. Pro Schleifendurchlauf wird ein Studierender der Datenbank hinzugefügt. Die Werte werden mit der \phpinline{pdo::quote()}-Methode maskiert um SQL-Injections zu unterbinden.

	\begin{phpcode}
	$students = array (
		array (
			'last_name' => 'Ellesmere',
			'first_name' => 'Corin',
			'house' => 1
		),
		array (
			'last_name' => 'Tugwood',
			'first_name' => 'Havelock',
			'house' => 4
		),
		array (
			'last_name' => 'Fenetre',
			'first_name' => 'Valentine',
			'house' => 3
		)
		
	)
	
	foreach ($students as $student) {
		$sql = 'INSERT INTO students (last_name, first_name, house) 
		          VALUES (' . $connection->quote($student['last_name']) . 
		            ',' . $connection->quote($student['first_name']) . 
		            ',' . $connection->quote($student['house']) . ')';
		            
		$connection->query($sql);
		);
	}
	\end{phpcode}
	
Bei jedem Durchlauf wird eine neue Abfrage mit den aktuellen Daten erzeugt und an die Datenbank geschickt. In diesen Fall bietet sich die Benutzung von Prepared Statements an, da sich pro Iteration lediglich die Werte ändern.

	\begin{phpcode}
	$statement = $connection->prepare(
	  'INSERT INTO students (last_name, first_name, house) VALUES (?, ?, ?)');

	foreach ($students as $student) {		            
		$statement->execute(
		  array($student['last_name'], $student['first_name'], $student['house']);
		);
	}
	\end{phpcode}

Die hier, anstelle der eigentlichen Daten, verwendeten Fragezeichen stellen Platzhalter dar, die als ``Positional Placeholders'' (engl. Positions Platzhalter) bezeichnet werden. Die Daten werden der Methode \phpinline{PDOStatement::execute()} in einem Array übergeben. Dabei ist die Reihenfolge wichtig, da ansonsten die Daten in die falschen Spalten der Tabelle geschrieben werden. 

Bei der Benutzung von Prepared Statements kann auf die Maskierung per \phpinline{PDO::quote()} verzichtet werden, da dies die Datenbank übernimmt.

\gls{pdo} bietet - im Gegensatz zu MySQLi - mit den ``Named Paramentern'' noch eine weitere Möglichkeit für Platzhalter an. Anstelle von Fragezeichen werden Bezeichner mit einem vorangestellen Doppelpunkt verwendet. Der Vorteil von dieser Variante, dass die Reihenfolge bei der Übergabe der Daten an die \phpinline{PDOStatement::execute()}-Methode keine Rolle mehr spielt. Das folgende Listing zeigt den gleichen Code von oben jedoch diesmal mit Named Parametern. Die Daten werden dieses Mal als Key/Value-Paar übergeben, bei dem der Key den benannten Platzhalter darstellt und der Value die einzufügenden Daten.
 
	\begin{phpcode}
	$statement = $connection->prepare(
	  'INSERT INTO students (last_name, first_name, house) VALUES (:lastname, :firstname, :house)');

	foreach ($students as $student) {		            
		$statement->execute(
		  array(
		    ':firstname' => $student['first_name'],
		    ':lastname'  => $student['last_name'], 
		    ':house'     => $student['house']);
		);
	}
	\end{phpcode} 
 
Nun spielt die Reihenfolge keine Rolle mehr – die Daten werden in die richtige Spalten eingefügt.

Die Zuordnung einer Variablen zu einem Platzhalter wird ``Binding'' genannt; gebundene Variablen werden demzufolge als ``Bounded Variables'' bezeichnet. Neben der gezeigten Bindung über \phpinline{PDOStatement::execute()} bietet \gls{pdo} spezialisiserte Methoden an, was folgende Ursachen hat: 

\begin{enumeration}
	\item Bei der gezeigten Bindung werden die Variablen stets als String behandelt. Es ist nicht möglich dem \gls{dbms} mitzuteilen, das der übergebene Wert einem anderen Datentyp entspricht.  
	\item Die Variablen werden bei dieser Methode stets als In-Parameter übergeben. Auf den Wert der Variablen kann innerhalb der Funktion nur lesenend zugegiffen werden. Man nennt diese Übergabe auch ``by Value''. Es gibt jedoch Szenarien in denen der Wert der Variable innerhalb der Funktion geändert werden soll. Dann müssen die Parameter als Referenz (``by Reference'') übergeben werden und agieren als In/Out-Paramaeter. Einige \gls{dmbs} unterstützen dieses Vorgehen und speichern das Ergebnis der Abfrage wieder in der übergebenen Variable.
\end{enumeration}

Das Äquivalent zum obigen Beispiel ist die Methode \phpinline{PDOStatement::bindValue()}, bei der die Variable als In-Parameter übergeben wird. Für jeden zu bindenden Platzhalter muß die Methode aufgerufen werden, die den Name des Platzhalters, den zu bindenen Wert und die optionale Angabe des Datentyps erwartet. \gls{pdo} bietet dazu vordefinierte Konstanten an, die den \gls{sql} Datentypen entsprechen.

	\begin{phpcode}
	$statement = $connection->prepare(
	  'INSERT INTO students (last_name, first_name, house) VALUES (:lastname, :firstname, :house)');

	foreach ($students as $student) {
	    $statement->bindValue(':lastname', $student['first_name']);
	    $statement->bindValue(':firstname', $student['last_name']);
	    $statement->bindValue(':house', $student['house'], PDO::PARAM_INT);
	    
		$statement->execute();
	}
	\end{phpcode}

Die Methode zur Übergabe der zu bindenden Werte per Referenz heißt \phpinline{PDOStatement::bindParam()}. Die Funktionsweise unterscheidet sich dahingehend von \phpinline{bindValue()}, als dass die Werte, welche in der Variablen gespeichert sind, erst dann aus der Adresse im Speicher ausgelesen werden, wenn \phpinline{execute()} ausgeführt wird, während \phpinline{bindValue()} die Werte sofort bei Aufruf der Funktion ausliest. Aus diesem Grund muß \phpinline{bindValue()} innerhalb der Schleife stehen. 

	\begin{phpcode}
	$statement = $connection->prepare(
	  'INSERT INTO students (last_name, first_name, house) VALUES (:lastname, :firstname, :house)');
	  
	$statement->bindParam(':lastname', $student['first_name']);
	$statement->bindParam(':firstname', $student['last_name']);
	$statement->bindParam(':house', $student['house'], PDO::PARAM_INT);  

	foreach ($students as $student) {
		$statement->execute();
	}
	\end{phpcode}


#### SQL-Injections
[SQL injections Mummy image einfügen]

Bei SQL-Injections kann über das Frontend einer Anwendung eine Zeichenkette in eine SQL-Abfrage injiziert werden, die die Fähigkeit besitzt den betroffenen SQL-Code derart zu verändern, dass er  

\begin{itemize}
	\item Informationen wie den Adminbenutzer der Webanwendung zurückliefert
	\item Daten in der Datenbank manipuliert um ein neuer Adminbenutzer anzugelegen
	\item oder die Datenbank ganz- oder teilweise löscht
\end{itemize}

Für ein kurzes Beispiel einer SQL-Injection soll ein Formular dienen, indem nach den Nachnamen der Studierenden aus Hogwarts gesucht werden kann. Der gesuchte  Datensatz wird ausgegeben wenn er gefungen wird, ansonsten erscheint eine entsprechende Meldung. Der in das Inputfeld eingegebene Wert wird von PHP automatisch in der Variablen \phpinline{$_REQUEST} gespeichert und kann in der Anwendung ausgelesen werden. \phpinline{'SELECT * FROM students WHERE last_name = Diggory'} stellt eine mögliche, zu erwartende SQL-Anfrage dar.

[Balsamico Formular einfügen]

\begin{phpcode}
$sql = "SELECT * FROM students WHERE last_name = '" . $_REQUEST['lastName'] . "'";
	
$statement = $connection->query($sql);
	  
foreach($statement as $student) {
    echo 'Lastname: ' . $student['last_name'] . "\n";
	echo 'Firstname: ' . $student['first_name'] . "\n"; 
	echo 'Haus: ' . $student['house'] . "\n";
}	
\end{phpcode}

Dieser Code beinhaltet zwei Fehler:

\begin{enumeration}
	\item Es wird nicht überprüft, ob \phpinline{$_REQUEST['lastName']} leer ist oder was ganz anders enthält als erwartet. 
	\item die Benutzereingabe wird nicht maskiert
\end{enumeration}

Im Falle einer leeren Variable, sähe die Abfrage so aus: \phpinline{'SELECT * FROM students WHERE last_name = '}. Im besten Fall gibt sie eine leere Ergebnismenge zurück im schlechtesten einen Fehler. Diese Problem ist leicht zu lösen, indem zum einen auf die Existenz der Variablen geprüft wird und zum anderen ob sie einen Wert enthält. Zusätzlich sollte noch auf den Datentyp des enthaltenen Wertes geprüft werden. Erst dann wird die Anfrage abgesetzt.

Da die Eingabe nicht maskiert wird, interpretiert der SQL-Parser einige Zeichen als Teil als Steuerzeichen der SQL-Syntax. Beispiele solcher Zeichen sind das Semikolon, der Apostroph und ein Backslash.

Selbst ein Websitebesucher ohne böse Ansichten könnte mit der Suche nach einem Studenten mit dem Namen O'Hara die SQL-Injection auslösen. Die in diesen Fall an die Datenbank gesendetet SQL-Anfrage \phpinline{'SELECT * FROM students WHERE last_name = 'O'Hara';} würde wohl einen Fehler auslösen, da der Parser die Anfrage nach dem ``O'' anhand des Apostroph als beendet interpretiert und ``Hara'' kein gültiges Sprachkonstrukt von SQL darstellt.

Ein Angreifer könnte hingegen die Eingabe in das Formular nach \phpinline{' or '1'='1} verändern. Damit würde sich diese Abfrage phpinline{'SELECT * FROM students WHERE last_name = '' or '1'='1';} ergeben.

Wird die Maskierung mit einer entsprechenden Prüfung von Benutzereingaben kombinert, verhindert das die Gefahr von SQL-Injections – eine richtige Anwendung vorrausgesetzt. Wie in Fußnote \footref{ftn:maskQueries} bereits erwähnt wurde, müssen an \phpinline{pdo::query()} übergebene SQL-Anfragen mit \phpinline{PDO::quote()} maskiert werden. Traditionell wird dafür die PHP-Methode \phpinline{addslashes()} oder die jeweiligen Maskierungsmethoden der \gls{dbms} verwendet. Für MySQLi wird \phpinline{mysqli_real_escape_string()} verwendet. 

Werden Prepared Statements genutzt, müssen die Benutzereingaben trotzdem überprüft, jedoch nicht mehr maskiert werden. Dies übernimmt dann die Datenbank. Wird dem Prepared Statement noch der Typ des Wertes mitgeteilt, kann das \gls{dbms} eine Typprüfung vornehmen und ggf. einen Fehler zurückgeben.

#### Fehlerbehandlung


======
* somit bietet es viele verschiedene Methoden auf der Ergebnismenge an
  * fetch
  * close
  * *error
  * count
  * Metadata der Ergebnismenge. Traditionell mysql_num_rows

Die Objekte PDO und PDOStatement besitzen weitere Methoden, von denen einige im Kapitel [KAP zum praktischen Teil einfügen] verwendet und erläutert werden. Für weiterführende Informationen sei auf die Dokumentation verwiesen \url{http://mx2.php.net/manual/en/book.pdo.php}.


Consider to take an example on 'The Hobbit' and split my thesis into 2 parts. Intro about #TYPO3, #PDO and #Doctrine goes into BA Thesis 1/2

2/2 Analytics about the current situation, market survey and my prototyp into MA thesis. ;-) 
