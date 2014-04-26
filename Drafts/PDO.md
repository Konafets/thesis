## PDO
Wie wir im nächsten Kapitel sehen werden [Hängt davon ab, wo dieses Kapitel eingefügt wird], baut Doctrine \gls{dbal} auf \gls{pdo} auf. Es wendet dessen Konzepte an und erweitert diese. Um ein tieferes Verständnis von Doctrine \gls{dbal} zu erlangen kommt man nicht umhin sich mit \gls{pdo} selbst zu beschäftigen - dies geschieht im folgenden Kapitel.

Im diesem Kapitel wird auf den Hintergrund von \gls{pdo} und dessen Konzepte eingegangen. Es werden die Fähigkeiten und die Grenzen aufgezeigt, sowie anhand von einfachen Beispielen die Funktionsweise illustriert.

### Was ist PDO
PHP Data Objects (PDO) ist eine Extension aus der \gls{PECL} PHP Extension Community Library (PECL) für PHP5 und stellt eine Abstraktionsbibliothek für die Interaktion mit \gls{dbms} verschiedener Hersteller dar. Dabei orientiert sie sich an dem Konzept der Java Data Objects (JDO) \gls{jdo}.

Der Grund der Existenz einer solchen Bibliothek liegt darin begründet, dass man in PHP viele verschiedene \gls{dbms} über jeweils eigene Extensions ansprechen kann. Die dazu extra zu installierenden Extensions bringt jeweils eine eigene API für die \gls{dbms} mit, so das sich die Art des Aufbaues der Verbindung und das Absetzen von Anfragen von \gls{dbms} zu \gls{dbms} unterschiedlich ausgestaltet ist. 
Dies kann zu einem hohem Aufwand führen, wenn die Anwendung von einem \gls{dbms} auf ein anderes umgestellt werden soll. \gls{pdo} hingegen definiert unabhängig vom zugrundeliegenden \gls{dbms} eine einheitliche Schnittstelle für das Verbindungsmanagement und die Kommunikation mit der Datenbank. 

Neben \gls{pdo} existieren unter anderen die Projekte  MDB2\footnote{\url{http://pear.php.net/package/MDB2}} und ADOdb\footnote{\url{http://adodb.sourceforge.net/}}, die den gleichen Ansatz verfolgen. Wenn man sich jedoch die letzten Releasedaten\footnote{bei MDB2 2.5.0b5 war die letzte Veröffentlichung am 2012-10-29; bei ADOdb am 2012-09-04} beider Projekte ansieht, kann man leicht den Eindruck erhalten, dass sie nicht mehr weiterentwickelt werden.

Ein weiterer Vorteil von \gls{pdo} gegenüber anderen Projekten ist die Geschwindigkeit, da es vollständig in C++ programmiert wurde.

(vgl. \cite[S. 5]{book:popel2007pdo})
  
### Grenzen / Limitierungen
Bei einer Abstraktion wird stets etwas Spezifisches, durch das Weglassen von Details, in etwas Allgemeines überführt. Im Fall von \gls{pdo} wird der andere Weg gegangen – es werden allgemeine \gls{sql}-Anfragen in den Dialekt\footnote{Als Dialekt wird die Hersteller-eigene Implementation des \gls{sql}-Standards genannt, dass sich im Umfang und Syntax vom Standard unterscheidet.} des Herstellers übersetzt. 

Aus diesem Grund vermag es \gls{pdo} nicht eine SQL-Abfrage die in dem Dialekt eines Herstellers formuliert wurde, in den eines anderen zu übersetzen. Stattdessen muss die Anfrage so nah wie möglich am Standard gestellt werden, um als portabel zu gelten.

* Beispiel einfügen SQL-Standard und eigene Erweiterung von MySQL -> Siehe Buch Seite 17
  
### Verwendung
Im Folgenden wird die Verwendung von \gls{pdo} erläutert. Dabei werden die Unterschiede zur den klassischen Verfahren (MySQL und PostgreSQL) demonstriert. 

Damit \gls{pdo} mit verschiedenen \gls{dbms} benutzt werden kann, müssen die Treiber des entsprechenden \gls{dbms} installiert sein.  

#### Verbindung
Da \gls{pdo} eine Objekt-orientierte \gls{api} anbietet, wird die Verbindung über ein Verbindungsobjekt gesteuert. Um eine Verbindung aufzubauen und ein solches Objekt zu erzeugen, wird der Konstrukur mit entsprechenen Parametern aufgerufen.

Die Signatur des Konstruktors sieht wie folgt aus:

	\begin{phpcode}
	public PDO::__construct ( string $dsn [, string $username [, string $password [, array $driver_options ]]] )
	\end{phpcode}

Während die ersten Parameter zwei und drei selbsterklärend sind und über den letzten Parameter Datenbanktreiber-spezifische Einstellungen im Key => Value Format übergeben werden können, erfordert der erste Parameter einen nähere Beschreibung.

Das \phpinline{$dsn} steht für Data Source Name. Hier muß also der Name der Datenquelle übergeben werden. Dieser Name folgt einem gewissen Format, bei dem zuerst der Typ des \gls{dbms} angegeben wird und - getrennt von einem Doppelpunkt - der Datenbank-spezifische Teil.
  

Um eine Verbindung aufzubauen werden dem Konstruktor ein sogenannter ``Connection String'' übergeben. Dieser ist nach dem Muster \pdf{TypPrefix:Datenbank-spezifischerTeil} aufgebaut.

	\begin{phpcode}
  	// MySQL
  	$dsn = 'mysql:host=$host;dbname=$db';
  
  	//PostgresSQL
  	$dsn = 'pgsql:host=$host dbname=$db';
  	\end{phpcode}
  	
Der vollständige Aufbau einer Verbindung mit obigen \gls{dsn}s:
  
	\begin{phpcode}
	// MySQL
  	$connection = new PDO($dsn, $user, $pass);

  	// PostgreSQL
  	$connection = new PDO($dsn, $user, $pass);
  	\end{phpcode}

Die Variable \phpinline{$connection} enthält nun das Verbindungsobjekt.

Als Vergleich dazu der Verbindungsaufbau via MySQLi und PostgreSQL

	\begin{phpcode}
	// MySQL
	mysql_connect($host, $user, $password);
  	mysql_select_db($db)
  
  	// PostgreSQL
  	pg_connect("host=localhost dbname=students user=stefano password=geheim");
 	\end{phpcode}
 	
Schon dieses einfache Beispiel zeigt den Vorteil einer einheitlichen \gls{api} – hier muss lediglich der \gls{dsn} angepasst werden.

#### PDO Statements
Um die Abfrage der Daten mittels \gls{pdo} zu demonstrieren wird davon ausgegangen, dass eine Datenbank mit folgenden Tabellen erstellt wurde.
    
    students
    +----+------------+-----------+-------+   	| id | first_name | last_name | house |   	+----+------------+-----------+-------+   	|  1 | Lucius     | Malfoy    |   4   |   	|  2 | Harry      | Potter    |   1   |   	|  3 | Herminone  | Granger   |   1   |	|  4 | Ronald     | Weasley   |   1   |
    |  5 | Luna       | Lovegood  |   3   |    |  6 | Cedric     | Diggory   |   2   |   	+----+------------+-----------+-------+
    
    houses
    +----+------------+
    | id | name       |
    +----+------------+
    |  1 | Gryffindor |
    |  2 | Huffelpuff |
    |  3 | Ravenclaw  |
    |  4 | Slyhterin  |
    +----+------------+
    
   	// Let's keep our SQL in a single variable   	$sql = 'SELECT last_name FROM students ORDER BY last_name';    
    $db       = 'students';    $host     = 'localhost';
	$user     = 'stefano';
	$password = 'geheim';       	// Now, assuming MySQL:   	mysql_connect($host, $user, $password);   	mysql_select_db($db);   	$q = mysql_query($sql);
      	// And for PostgreSQL:
$connectionString =    	   	pg_connect("host=localhost dbname=students user=stefano password=geheim);   	$q = pg_query($sql);
   	// assume the $connStr variable holds a valid connection string	// as discussed in previous point	$sql = 'SELECT DISTINCT make FROM cars ORDER BY make';	$conn = new PDO($connStr, $user, $password);	$q = $conn->query($sql);
	
#### Traversierung von Ergebnissmengen   	// assume the query is in the $sql variable   	$sql = "SELECT DISTINCT make FROM cars ORDER BY make";   	// For MySQL:   	$q = mysql_query($sql);   	while($r = mysql_fetch_assoc($q))   	{    	echo $r['make'], "\n";   	}

	// and, finally, PostgreSQL:   	$q = pg_query($sql);   	while($r = pg_fetch_assoc($q))   	{		echo $r['make'], "\n";	}
	
	$q = $conn->query("SELECT DISTINCT make FROM cars ORDER BY make");   	while($r = $q->fetch(PDO::FETCH_ASSOC))   	{
		echo $r['make'], "\n";   	}
   	
	Besipiele liefern:   	PDO::FETCH_ASSOC	
	PDO::FETCH_ROW
	PDO::FETCH_NUM
	…
	   		   

  * Unterschiede der Queries von MySQL, Postgres und PDO zeigen
  * $connection->query gibt PDOStatement Objekt zurück im Gegensatz zu PHP Resourcen [Was ist das?]
  
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
	$sql = "SELECT sum(price) FROM cars WHERE make='Ford'"
	
	// MySQL:   	$m = mysql_real_escape_string($make);	$q = mysql_query("SELECT sum(price) FROM cars WHERE make='$m'");   	// and PostgreSQL:   	$m = pg_escape_string($make);   	$q = pg_query("SELECT sum(price) FROM cars WHERE make='$m'");
   	
	// PDO   	$m = $conn->quote($make);	$q = $conn->query("SELECT sum(price) FROM cars WHERE make=$m");
	
	

#### Transactions (S. 128)
* Wird in TYPO3 nicht benutzt. Trotzdem erwähnen?
* Wie wird es von Doctrine genutzt