# Prototypischer Nachweis der Herstellbarkeit

## Erstellung des Prototypen

_Änderungen am Prototypen_

1. Extension Builder -> Extension erstellen
2. Icon zufügen
3. Verzeichnis Classes/Persistence/Legacy erstellen
4. Kopieren von DatabaseConnection.php und PreparedStatements.php in das Verzeichnis
5. Verzeichnis Tests/Persistence/Legacy erstellen
6. Kopieren von DatabaseConnectionTest.php und PreparedStatementTest.php in das Verzeichnis
7. Namespaces anpassen Vendor\Extensionname\Persistence\Legacy
8. Datei ext_localconf.php erstellen und XCLASSEN der beiden Dateien 
9. Extension installieren
10. Per Debuggen in der IDE feststellen, ob ByPass funktioniert
12. Verzeichnis Classes/Persistence/Doctrine/ erstellen
13. Datei DatabaseConnection.php in dem Verzeichnis erstellen -> Datei erbt von Classes\Persistence\Legacy\DatabaseConnection.php
14. Datei PreparedStatemetns.php in dem Verzeichnis erstellen -> Datei erbt von Classes\Persistence\Legacy\PreparedStatements
15. Excelsheet erstellen mit den LegacyMethoden und den neuen MethodenNamen, die der CGL folgen
16. \Classes\Persistence\Doctrine\DatabaseConnection.php bekommt die neuen Methoden, die auf die die alte API nutzen parent::
17. Syncron dazu die Tests schreiben
18. Refactoring von connectDb() / connectDatabase()
19. Testen durch Überschreiben von connectDb() in \Classes\Persistence\Doctrine\DatabaseConnection.php

## Umstellen auf Doctrine DBAL

_Änderungen am Prototypen_

20. Doctrine einbauen per Composer laden
21. vendor/doctrine nach Packages/Library kopieren
23. Manuelles Editieren der PackageStates.php -> 'state' => 'active' auf active setzen
24. ggf. Reihenfolge in PackagesStates.php anpassen 
25. Classes\Persistence\Legacy\DatabaseConnection.php erbt von Classes\Persistence\Doctrine\DatabaseConnection.php
26. Methoden die nicht der CGL folgen, werden in richtiger Schreibweise in die neue API übernommen, die alten Methoden zeigen auf die neuen Methoden
27. neue Methoden werden in der neuen API implementiert
28. Connection erfolgt nun über Doctrine
29. \Konafets\DoctrineDbal\Persistence\PreparedStatement.php nutzt intern Doctrines /PDO Prepared Statement 
30. Exceptions erstellen und nutzen


_Änderungen am TYPO3 CMS_

1. Autoload von Doctrine in Bootstrap.php
2. Anpassen der Klassen in TYPO3\CMS\Install\Controller/Action/Step/
3.   DatabaseConnect
4.   DatabaseData
5.   DatabaseSelect
6.   AbstractAction
7. Anpassen der Fluid-Partials
8.   DoctrineDetails
9.   DoctrineDbalDriver
10.  LoadDoctrineDbal
11.  UnloadDoctrineDbal

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








## Vorüberlegungen
- Name der Extension

- Anforderungen an den Prototyp
  - alte API unterstützen 
  - MySQL unterstützen
  - Namen der Methoden folgen nicht der CGL
  
- PreparedStatement überflüssig


## Vorarbeiten
Der Ausgangspunkt ist ein reguläres TYPO3 CMS in der Version 6.2.2 [<- updaten], welches über die lokale Domain \pdf{http://thesis.typo3_6-2.dev/typo3/} erreichbar ist. Die Installation folgt der in Kapitel~\ref{basics:typo3:subsubsec:architectureTypo3} vorgestellten Verzeichnisstruktur. 

[Bild des ExtensionBuilder einfügen]

Die Grundstruktur der Extension wurde mit dem \textit{Extension Builder} erstellt. Er bietet im TYPO3 CMS Backend eine graphische Oberfläche zum Festlegen der Grunddaten wie Name, Autor, Typ, Abhängigkeiten und andere Dinge an. Abbildung~\ref{fig:extensionInitialFolderStructure} zeigt die Verzeichnisstruktur.

\begin{Verbatim}[samepage=true]
.
├── doctrine_dbal
│   ├── Configuration
│   ├── Documentation.tmpl
│   ├── Resources
│   ├── ext_emconf.php
│   ├── ext_icon.gif
│   └── ext_tables.php\end{Verbatim}
Die Verzeichnisse enthalten Dateien, die in Zukunft von dem Prototypen benötigt werden könnten, wie zum Beispiel die Dateien in \pdf{Documentation.tmpl}, die ein Template für die Dokumentation bereitstellen.
Die Datei \pdf{ext_emconf.php} enthält die Metainformationen der Extension, die von dem Extension Manager verarbeitet werden (emconf = Extension Mangager Configuration).
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
Ab TYPO3 CMS 6.2 wird zudem die Datei \pdf{composer.json} erwartet, über die inJSON Syntax teilweise gleichen Angaben wie in \pdf{ext_emconf.php} gemacht werden. Composer ist ein Dependency Manager\footnote{https://getcomposer.org/} für PHP. 
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
\caption{Die Datei ext_emconf.php}
\label{lst:extEmconf}
\end{listing}   

Um die Extension zu erstellen, wurde unter \pdf{thesis.typo3_6-1.dev/typo3conf/ext/} das Verzeichnis \pdf{doctrine_dbal} angelegt. 


 
Zum erstellen der Zunächst wurde eine TYPO3-Extension mit dem Namen \textit{doctrine_dbal} erstellt. Dazu wurde ein Verzeichnis unter \pdf{www.theses.dev}

## Refactoring der alten Datenbank API

## Tests für die alte Datenbank API
Um zu gewährleisten, dass TYPO3 CMS und die Extensions weiterhin mit der neuen Datenbank API kompatibel sind, wurden Untit Tests für die alte Datenbank API geschrieben. Zu den 40 Tests existierenden Tests wurden 68 hinzugefügt, die nahezu 


die alte API weiterhin funktioniert, 

Zunächste wurde 
- Anlegen der Verzeichnisstruktur
- Kopieren der DatebaseConnection.php in die Extension
- Kopieren der PreparedStatement.php in die Extension
- Überschreiben der Original Mehtoden per XCLASS
- reinhängen in Installation
- Schreiben der Tests für die alte API
- pConnect
- Benennung der Methoden



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




 
   
