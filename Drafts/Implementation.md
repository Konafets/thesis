# Prototypischer Nachweis der Herstellbarkeit


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

Um die Grundstruktur der Extension zu erstellen, wurde der \textit{Extension Builder} zu Hilfe genommen. Dieser bietet über das Backend eine graphische Oberfläche an, um die Grunddaten der Extension, wie Name, Autor, Typ, Abhängigkeiten und andere Dinge festzulegen. Vom \textit{Extension Builder} erzeugte Dateien, die für den Prototypen nicht benötigt werden, wurden gelöscht. 

\begin{Verbatim}[samepage=true]
.├── Classes/├── Configuration/├── Documentation/├── Resources/
├── composer.json├── ext_emconf.php├── ext_icon.gif├── ext_localconf.php└── ext_tables.php\end{Verbatim}
Das Verzeichnis \pdf{Classes} ist zu dem Zeitpunkt leer. Die anderen Verzeichnisse enthalten Dateien, die in Zukunft von dem Prototypen benötigt werden könnten, wie zum Beispiel die Dateien in \pdf{Documentation}, die ein Template für die Dokumentation bereitstellen.
Die Datei \pdf{ext_emconf.php} enthält die Metainformationen der Extension, die von dem Extension Manager verarbeitet werden (emconf = Extension Mangager Configuration).
\begin{listing}
\begin{phpcode}
<?php
$EM_CONF[$_EXTKEY] = array(
	'title' => 'Doctrine Database Abstraction Layer for TYPO3',
	'description' => 'This brings Doctrine2 to TYPO3',
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


### Eigenheiten von Doctrine
- boolean -> tinyint(1)
- auto_increment + Default null

### Eigenheiten von Postgres
- Probleme mit Postgres
  - BLOB -> Dateistream

## Ideen

- TCA Ablösung in Form von YAML / XML / JSON





 
   
