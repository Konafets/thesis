## PDO

### Was ist PDO
* Was ist PDO
  * PHP5 Extension
  * Objektorientiert
  * Verbindungsobjekt
  * Abstraktionsbibliothek für DBMS Verbindungen
  * Der Sinn dahinter: PHP unterstützt viele Datenbanken, welche alle eine eigene Exntension benötigen, die jeweils eine eigene API (Ansprechen der DB, Verbdindung aufbauen) mitbringen 
  * definiert einheitliches Interface zum Erstellen und Verwalten einer Verbindung, Abfragen von Daten, Traversieren durch Ergebnisse, Prepared Statements und der Fehlerbehandlung
  * das führt zu einen hohem Aufwand beim Wechsel zu einer anderen Datenbank
  * außerdem hat die Nicht-Existenz einer API wie JDBC für Java gerat PHP immer mehr ins Hintertreffen
  * Alternativen zu PDO: ADOdb und PEAR DB [Gibt es die noch?][Verweis auf nähere Beleuchtung von ADOdb später]
  * Der Vorteil von PDO gegenüber den Alternativen ist Geschwindigkeit, da in C++ 
programmiert
  (vgl. \cite[S. 5]{book:popel2007pdo})
  
  * PDO ist eine \gls{PECL} PHP Extension Community Library (PECL)
  * Braucht Datenbank-spezifische Treiber
  
### Verwendung

#### Verbindung
  * Vergleich von Verbindungsaufbau
  // mysql [LINK zu Manual]
  mysql_connect($host, $user, $password);
  mysql_select_db($db)
  
  // SQLite [LINK zu Manual]
  $dbh = sqlite_open($db, 0666);
  
  // PostgreSQL
  pg_connect("host=$host dbname=$db user=$user password=$password");
  
  * Mit PDO
  // mysql
  $connection = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
  // sqlite
  $connection = new PDO("sqlite:$db");
  // postgresSQL
  $connection = new PDO("pgsql:host=$host dbname=$db", $user, $pass);
  (vgl. \cite[S. 6 ff]{book:popel2007pdo})

#### PDO Statements und Ergebnismengen
  * Unterschiede der Queries von MySQL, Postgres und PDO zeigen
  * $connection->query gibt PDOStatement Objekt zurück im Gegensatz zu PHP Resourcen [Was ist das?]
  
#### Prepared Statements
##### Positionale Plathalter (Positional Placeholders)
##### Benannte Platzhalter (Named Placeholders)
##### Gebundene Werte (Bound values)

#### Fehlerbehandlung

#### SQL Injections (S. 60)

#### Transactions (S. 128)
  
* Wie wird es von Doctrine genutzt