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

* Beispiel einfügen SQL-Standard und eigene Erweiterung von MySQL -> Siehe Buch Seite 17
  
### Verwendung
Der grundlegenden Unterschied von PHP-Extensions wie die für MySQL und PosgreSQL zu PDO besteht darin, dass die zuerst genannten eine prozeduale Bibliothek darstellen und \gls{pdo} streng Objekt-orientiert aufgebaut ist. Während diese Extensions lediglich Funktionen zur Interaktion mit der Datenbank zur Verfügung stellen, die keine weiteren Informationen über den inneren Zustand der Verbindung besitzen, führt \gls{pdo} Klassen ein, die sowohl die Verbindung als auch die eine Abfrage kapseln und als Schnittstelle dienen.

Die Klasse (\inlinephp{PDO}) beinhaltet die Verbindung zur Datenbank und stellt Methoden zum Verbindungsmanament bereit, während die Klasse \inlinephp{PDOStatement}eine Schnittstelle zu Anfragen und teilweise auch zur Ergebnismenge\footnote{Da alle betrachteten Datenbanken den relationalen Datenbanken zuzuschreiben sind, handelt es sich bei den Datenbanktabellen um die mathematischen Beschreibung einer Relation [http://de.wikipedia.org/wiki/Relationale_Datenbank]. Zudem kann eine Relation/Tabelle als eine Menge aufgefasst werden. Verknüpft man Relationen mit Operatoren (Abfrage) erhält man stets wieder eine Relation. Somit ist das Ergebnis einer Abfrage eine Menge - die Ergebnismenge} bietet.

Im Folgenden wird die Verwendung der Klassen an einfachen Beispielen erläutert. Dabei werden die Unterschiede zur den klassischen Verfahren (MySQL und PostgreSQL) demonstriert. Damit \gls{pdo} mit verschiedenen \gls{dbms} benutzt werden kann, müssen die Treiber des entsprechenden \gls{dbms} installiert sein. Als Grundlage der Abfragen und Ergebnisse dient eine Datenbank mit den folgenden Tabellen. Es wird davon ausgegangen, dass sie bereits erstellt wurde.
    
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

Während die Parameter \inlinephp{$username} und \inline{$password} selbsterklärend sind und über den letzten Parameter \inlinephp{$driver_options} Datenbanktreiber-spezifische Einstellungen übergeben werden können, erfordert der erste Parameter eine nähere Beschreibung.

Mit dem Kürzel \phpinline{$dsn} (engl. Data Source Name) ist die Datenquelle gemeint, die in einem bestimmten Format übergeben werden muss. Dabei wird zuerst der Typ des \gls{dbms} angegeben und - getrennt von einem Doppelpunkt - der Datenbank-spezifische Teil.

	\begin{phpcode}   
	// MySQL
  	$connection = new PDO('mysql:host=$host;dbname=$db', $user, $pass);

  	// PostgreSQL
  	$connection = new PDO('pgsql:host=$host dbname=$db', $user, $pass);
  	\end{phpcode}

Das in der Variablen \phpinline{$connection} enthaltene Verbindungsobjekt stellt den Ausgangspunkt für alles Weitere dar. Die naheliegendsten Aktionen nach dem Verbindungsaufbau sind das Absetzen einer SQL-Anfrage an die Datenbank und die Ausgabe des Ergebnisses.

#### Datenbankabfragen
Die als Beispiel dienende Abfrage soll die Nachnamen aller Studierenden in alphabetischer Reihenfolge ausgeben. Die in einer Variablen gespeicherten SQL-Abfrage\footnote{Um SQL-Injections zu unterbinden, muß das \gls{sql}-Query entsprechenden maskiert werden. \gls{pdo} bietet dafür die Methode \inlinephp{PDO::quote()} an. SQL-Injections werden im Kapitel [KAP Sicherheit einfügen] über Sicherheit eingehend behandelt.\label{ftn:maskQueries} wird an die Datenbank gesendet und das Ergebnis über eine Schleife ausgegeben. Zunächst wird der althergebrachte Weg gezeigt. Beide PHP-Extensions stellen dafür \inlinephp{*_query} Funktionen zur Verfügung, die eine Kennung der Datenbankverbindung zurückgeben. Im Fall eines Fehlers geben sie \inlinephp{FALSE} zurück. 

	\begin{phpcode}
	$query = 'SELECT last_name FROM students ORDER BY last_name';
	   	// For MySQLi:   	$result = mysqli_query($connection, $query);   	while($row = mysqli_fetch_assoc($result))   	{    	echo $row['last_name'] . "\n";   	}

	// PostgreSQL:   	$result = pg_query($query);   	while($row = pg_fetch_assoc($result))   	{		echo $row['last_name'] . "\n";	}
    \end{phpcode}
    
Das \gls{pdo}-Objekt bietet dafür die Methode \inlinephp{query()} an, die ein Objekt vom Typ \inlinephp{PDOStatement} zurückgibt. Dieses implementiert das Interface Traversable und kann somit - analog zu einem Array - in einer Schleife durchlaufen werden.

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
\end{Verbatim}Somit erübrigt sich der Aufruf einer weiteren Methode wie \inlinephp{mysqli_result::fetch_assoc}. 

Um das Ergebnis der Abfrage sinnvoll nutzen zu können, gibt es verschiedene Stile (engl. fetch styles) in die es formatiert werden kann. Um dennoch die interne Struktur der Ergebnismenge beinflussen zu können, gibt es in \gls{pdo} Konstanten, die als optionales Argument an \inlinephp{query()} übergeben werden. In der Defaulteinstellung benutzt \gls{pdo} die Konstante \inlinephp{PDO::FETCH_BOTH}, bei dem das Ergebnis zum einen über den Spaltenbezeichner (wie im obigen Beispiel) als auch über eine Indexzahl angesprochen werden kann. Im Beispiel würde das so aussehen: \inlinephp{echo $row[0]}.
Zu allen \inlinephp{*_fetch_*}-Methoden gibt es das entsprechende Äquivalent als \gls{pdo}-Konstante. Die Wichtigsten sind:

* PDO::FETCH_ASSOC - entspricht *_fetch_assoc() 
* PDO::FETCH_NUM   - entspricht *_fetch_array()
* PDO::FETCH_ROW   - entspricht *_fetch_row()

Darüberhinaus definiert \gls{pdo} noch weitere Konstanten, die keine Ensprechungen haben. 

* PDO::FETCH_OBJ - liefert jede Zeile der Ergebnisrelation als Objekt zurück. Die Spaltenbezeichner werden dabei zu Eigenschaften der Klasse.
* PDO::FETCH_LAZY - wie PDO::FETCH_OBJ. Das Objekt wird jedoch erst dann erstellt, wenn darauf zugegriffen wird.
* PDO::FETCH_CLASS - liefert eine neue Instanz der angeforderten Klasse zurück. Die Spaltenbezeichner werden dabei zu Eigenschaften der Klasse. 
* PDO::FETCH_COLUMN - liefert nur eine Spalte aus der Ergebnismenge zurück.

Dies stellt eine nicht abschließende Aufzählung dar. Die Dokumentation von \gls{pdo} benennt weitere sogenannte ``Fetch Styles''-Konstanten\footnote{\url{http://mx2.php.net/manual/en/pdo.constants.php}}, die für diese Arbeit jedoch nicht von Interesse sind.
Die Benutzung der Konstanten erfolgt per Übergabe als Parameter an die \inlinephp{query()}-Methode:
	\begin{phpcode}
	$statement = $connection->query($sql, PDO::FETCH_NUM);
	
	foreach($statement as $row) {
	  echo $row[0];
	}	
	\end{phpcode}
	
Über das PDOStatement-Objekt\footnote{Leider ist der Begriff dieser Klasse etwas unglücklich gewählt oder es ist ein Designfehler von \gls{pdo}, denn ein Objekt dieser Klasse repräsentiert zum einen ein (Prepared) Statement und, nachdem die Anfrage ausgeführt wurde, die Ergebnisrelation. Die Methoden der Klasse agieren somit einmal auf dem Statement und einmal auf dem Ergebnis.} werden weitere Möglichkeiten wie die Methoden \inlinephp{fetch()} und \inlinephp{fetchAll()} angeboten, um das Ergebnis zu erhalten. Diese Methoden müssen auch genutzt werden, wenn statt der \inlinephp{foreach}-Schleife eine \inlinephp{while}-Schleife genutzt werden soll:

	\begin{phpcode}
	$statement = $connection->query($sql);
	
	while($row = $statement->fetch(PDO::FETCH_ASSOC)) {
	  echo $row['last_name'];
	}	
	\end{phpcode}

Zudem gibt es mit \inlinephp{fetch_column()} und \inlinephp{fetch_Object()} Alternativen für die Verwendung von \inlinephp{fetch()} in Verbindung mit den entsprechenden Konstanten. 

#### Prepared Statements (PS)
Bereits MySQLi führt Prepared Statements ein, somit sind sie in der PHP-Welt nicht so neu. Während MySQLi nur einen Typ von Prepared Statements unterstützt, bietet \gls{pdo} eine weitere sinnvolle Variante an. Im Folgenden wird das Konzept und der Nutzen von Prepared Statements kurz erklärt.

Prepared Statements können als eine Vorlage für SQL-Abfragen verstanden werden, die immer wieder, mit verschiedenen Werten, ausgeführt werden. Dabei kann ein \gls{dbms} die Struktur dieses Templates einmalig analyisieren und vorkompiliert im Cache speichern. Bei jedem erneuten Aufruf setzt es lediglich die anderen Werte anstelle von Platzhaltern ein, was die Ausführung schneller macht. (vgl. \cite[S. 75]){book:popel2007pdo}

Zur Demonstration soll je ein Codebeispiel dienen. Dabei fügen wir neue Studierende in die oben gezeigte Datenbanktabelle ein. Der sprechende Hut\footnote{\url{http://de.harry-potter.wikia.com/wiki/Sprechender_Hut}} hat bereits über die Häuser der Neuzugänge entschieden. Um die Abfrage einfach zu halten, wird der Fremdschlüssel der Tabelle für die Häuser direkt in dem Query angegeben.

Die Daten der Studierenden liegen in einem assoziativen Array vor und können somit über eine For-Schleife durchiteriert werden. Pro Schleifendurchlauf wird ein Studierender der Datenbank hinzugefügt. Die Werte werden mit der \inlinephp{pdo::quote()}-Methode maskiert um SQL-Injections zu unterbinden.

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

Die hier, anstelle der eigentlichen Daten, verwendeten Fragezeichen stellen Platzhalter dar, die als ``Positional Placeholders'' (engl. Positions Platzhalter) bezeichnet werden. Die Daten werden der Methode \inlinephp{PDOStatement::execute()} in einem Array übergeben. Dabei ist die Reihenfolge wichtig, da ansonsten die Daten in die falschen Spalten der Tabelle geschrieben werden. 

Bei der Benutzung von Prepared Statements kann auf die Maskierung per \inlinephp{PDO::quote()} verzichtet werden, da dies die Datenbank übernimmt.

\gls{pdo} bietet - im Gegensatz zu MySQLi - mit den ``Named Paramentern'' noch eine weitere Möglichkeit für Platzhalter an. Anstelle von Fragezeichen werden Bezeichner mit einem vorangestellen Doppelpunkt verwendet. Der Vorteil von dieser Variante, dass die Reihenfolge bei der Übergabe der Daten an die \inlinephp{PDOStatement::execute()}-Methode keine Rolle mehr spielt. Das folgende Listing zeigt den gleichen Code von oben jedoch diesmal mit Named Parametern. Die Daten werden dieses Mal als Key/Value-Paar übergeben, bei dem der Key den benannten Platzhalter darstellt und der Value die einzufügenden Daten.
 
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

Die Zuordnung einer Variablen zu einem Platzhalter wird ``Binding'' genannt; gebundene Variablen werden demzufolge als ``Bounded Variables'' bezeichnet. Neben der gezeigten Bindung über \inlinephp{PDOStatement::execute()} bietet \gls{pdo} spezialisiserte Methoden an, was folgende Ursachen hat: 

1. Bei der gezeigten Bindung werden die Variablen stets als String behandelt. Es ist nicht möglich dem \gls{dbms} mitzuteilen, das der übergebene Wert einem anderen Datentyp entspricht.  
2. Die Variablen werden bei dieser Methode stets als In-Parameter übergeben. Auf den Wert der Variablen kann innerhalb der Funktion nur lesenend zugegiffen werden. Man nennt diese Übergabe auch ``by Value''. Es gibt jedoch Szenarien in denen der Wert der Variable innerhalb der Funktion geändert werden soll. Dann müssen die Parameter als Referenz (``by Reference'') übergeben werden und agieren als In/Out-Paramaeter. Einige \gls{dmbs} unterstützen dieses Vorgehen und speichern das Ergebnis der Abfrage wieder in der übergebenen Variable.

Das Äquivalent zum obigen Beispiel ist die Methode \inlinephp{PDOStatement::bindValue()}, bei der die Variable als In-Parameter übergeben wird. Für jeden zu bindenden Platzhalter muß die Methode aufgerufen werden, die den Name des Platzhalters, den zu bindenen Wert und die optionale Angabe des Datentyps erwartet. \gls{pdo} bietet dazu vordefinierte Konstanten an, die den \gls{sql} Datentypen entsprechen.

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

Die Methode zur Übergabe der zu bindenden Werte per Referenz heißt \inlinephp{PDOStatement::bindParam()}. Die Funktionsweise unterscheidet sich dahingehend von \inlinephp{bindValue()}, als dass die Werte, welche in der Variablen gespeichert sind, erst dann aus der Adresse im Speicher ausgelesen werden, wenn \inlinephp{execute()} ausgeführt wird, während \inlinephp{bindValue()} die Werte sofort bei Aufruf der Funktion ausliest. Aus diesem Grund muß \inlinephp{bindValue()} innerhalb der Schleife stehen. 

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


Prepared Statement sind 
Wie in Fußnote \footref{ftn:maskQueries} bereits erwähnt wird, müssen die SQL-Anfragen die an \inlinephp{pdo::query()} übergeben werden maskiert werden. Traditionell wird dafür die PHP-Methode \inlinephp{addslashes()} oder die MySQL-Methode \inlinephp{mysqli_real_escape_string()} verwendet, die entsprechende Zeichen mit einem \-Zeichen maskiert. Dies verhindert einen Angriff auf die Datenbankanwendung über SQL-Injections. Auch schon erwähnt wurde die Methode \inlinephp{pdo::quote()}, die diese Maskierung für \gls{pdo} vornimmt.

Eine weitaus sichere Möglichkeite bietet \gls{pdo} mit den Prepared Statements an.

* kann als Vorlage / Template für eine Abfrage aufgefasst werden (vgl. \cite[S. 75]){book:popel2007pdo} √
* gleicher Query aber jedesmal unterschideliche Werte √
* Vorteile:
  * Precompiling des Query -> schneller Ausführung √
* Beispiel eines Queries mit/ohne PS das verschiedene neue Schüler in die DB einfügt (Beispiel für PS mit Positional Platzhalter)
* Positionale Platzhalter / Benannte Platzhalter
  * Erklärung des Unterschieds
  * Beispiel Code
* Bound Values
  * bindValues()
  * bindParam()  


======
* somit bietet es viele verschiedene Methoden auf der Ergebnismenge an
  * fetch
  * close
  * *error
  * count
  * Metadata der Ergebnismenge. Traditionell mysql_num_rows
   
  
#### Prepared Statements
* Traue keiner Benutzereingabe
* Angiff über Suchfeld/Formulare (GET/POSt)
* Angriff über GET Parameter
* Beispielcode mit ungeschützten Eingaben
* Beispielcode mit geschützten Eingaben per add_slashes
* Beispeilcode mit Prepared Statements
##### Positionale Platzhalter (Positional Placeholders)
##### Benannte Platzhalter (Named Placeholders)
##### Gebundene Werte (Bound values)

#### Fehlerbehandlung

#### SQL Injections (S. 60) (macht mehr Sinn im Kapitel Sicherheit)

Ein bisher nur angedeuteter aber nicht zu unterschätzende Vorteil von PS ist die nahezu 100%ige Unterbindung von SQL-Injections


Dies trägt erheblich zur Sicherheit einer Webanwendung bei und ist.

, 
	$sql = "SELECT sum(price) FROM cars WHERE make='Ford'"
	
	// MySQL:   	$m = mysql_real_escape_string($make);	$q = mysql_query("SELECT sum(price) FROM cars WHERE make='$m'");   	// and PostgreSQL:   	$m = pg_escape_string($make);   	$q = pg_query("SELECT sum(price) FROM cars WHERE make='$m'");
   	
	// PDO   	$m = $conn->quote($make);	$q = $conn->query("SELECT sum(price) FROM cars WHERE make=$m");
	
	

#### Transactions (S. 128)
* Wird in TYPO3 nicht benutzt. Trotzdem erwähnen?
* Wie wird es von Doctrine genutzt

Die Objekte PDOConnection und PDOStatement besitzen viele weitere nützliche Methoden, die hier jedoch nicht alle aufgezählt werden. In Kapitel [KAP zum praktischen Teil einfügen] werden jedoch die gängigen Methoden verwendet und teilweise erläutert. Für weiterführende Informationen sei auf die Dokumentation verwiesen \url{http://mx2.php.net/manual/en/book.pdo.php}.

All die bisher gezeigen Funktionen von \gls{pdo} sind im Grunde schon mit den \gls{php}-Extensions für Datenbanken abbildbar. MySQLi bietet durch seine duale \gls{api} auch eine Kapselung in Klassen an und führt Prepared Statements ein. Der 
