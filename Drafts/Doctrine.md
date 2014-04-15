Doctrine 2
==========

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