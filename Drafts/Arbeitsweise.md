### Arbeitsweise (besseren Titel finden)
Aufgrund seiner Aufgabe stellt der Protoyp einen tiefen Eingriff in die Architektur von TYPO3 dar. Vor diesem Hintergrund ist es umungänglich, dass er alle Anforderungen erfüllt, die an eine Systemextension gestellt werden \footnote{Auch wenn er keine Systemextension ist}. 

Dies fängt mit der Einhaltung der TYPO3 Coding Guidelines an, geht über die Versionierung des Codes hin zum Testen des Prototypes.

#### TYPO3 Coding Guidelines
Programmier neigen zu unterschiedlichen Programmierstilen, was solange kein Problem darstellt, solange sie allein an einem Projekt arbeiten. Kommen mehr Entwickler hinzu und es vermischen sich verschiedene Stile, kann es schnell unübersichtlich werden. Um den Sinn eines Programms zu verstehen, hilft es allmein, wenn die Codebasis in einer konsistenten Form formatiert wurde. Dies erhöht die Wartbarkeit und verbessert die Code Qualität. 

Coding Guidelines stellen dabei das Regelwerk dar auf das sich die Entwickler eines Projekts geeingt haben. 

In den TYPO3 Coding Guidelines\cite{pdf:Typo3CodingGuidelines14} (CGL) wird die Verzeichnisstruktur von TYPO3 selbst, sowie die von Extensions erläutert. Sie erklären die Namenskonventionen für Dateien, Klassen, Methoden und Variablen und beschreiben den Aufbau einer Klassendatei mit notwendigen Inhalt, der unabhängig von dem Zweck der Klasse vorhanden sein muss.

Der größter Teil der CGL behandelt die Formatierung verschiedene Sprachkonstrukte wie Schleifen, Arrays und Bedingungen.

Da das Regelwerk mit 28 Seiten recht umfangreich aussfällt, wird zur Überprüfung des Quellcodes das Programm PHP_CodeSniffer\footnote{Link} in Zusammenhang mit dem entsprechendem Regelset für das TYPO3 Projekt \footnote{Link}.

#### Unit Testing
Eine Anforderung an den Prototyp war, dass er die alte Datenbank API weiterhin unterstützt. Dadurch ist gewährleistet, dass noch nicht angepasste Extensions weiterhin funktionieren. Um dies zu überprüfen muß die Funktionaliät von TYPO3 in Verbindung alter API / neue API fortlaufend getestet werden.

Ein möglicher Ansatz wäre es, mit zwei identischen TYPO3 Installationen zu starten, die mit der Zeit auseinander divergieren, indem eine der beiden APIs immer mehr auf die neue API umgebaut würde. Das Testen dabei kann jedoch nur auf eine stichprobenartige Überprüfung der Funktionaliät des manipulierten Systems beruhen, da es nahezu unmöglich ist, durch dieses manuelle Vorgehen alle Testfälle abzudecken.

Ein andere Ansatz würde auf der Code Ebene ansetzen und pro Methode der alten API verschiedene Testfälle definieren, welche nachvollziehbar wären und immer wieder ausgeführt werden könnten.

Das dafür in Frage kommende Framework heißt PHPUnit\footnote{LINK}. Es stellt das PHP Pedant von dem aus der Javawelt bekannten JUnit dar und wird von TYPO3 unterstützt. TYPO3 bringt selbst schon über 6000 UnitTests mit\footnote{https://travis-ci.org/TYPO3/TYPO3.CMS/builds/23070563}. 

Das eingangs umrissene Szenario stellt lediglich ein greifbares Beispiel für den Nutzen von Unit Tests dar und ist keineswegs auf Spezialfälle wie Refactorings oder dem Austausch einer API beschränkt. In der vorliegenden Arbeit wurden alle implementierten Methoden der neuen API mit Unit Tests - in Verbindung mit PHPUnit -abgedeckt. 

Um die Tests zu starten gibt es mehre Möglichkeiten:

##### Im TYPO3 Backend
[Bild einfügen]

##### Auf der Konsole
[Bild einfügen]

##### In der IDE
[Bild einfügen]

#### GIT
[Bild einfügen]
Als Versionsverwaltung wurde GIT\footnote{http://git-scm.com/} in Verbindung mit dem Code Hostingdienst GiHub\footnote{http://github.com} genutzt. Github dient zum einen als Backup im Falle eines Festplattenausfalls und zum anderen als späterer Anlaufpunkt der Extension für Interessierte.

GitHub bietet zudem auch eine Aufgabenverwaltung\footnote{Issuetracking} an, dass bei dem Projekt mehr oder minder intensiv genutzt wurde, dem jedoch nach der Veröffentlich als OpenSource Software mehr Bedeutung zukommen wird.

Ferner hat sich um GitHub eine Vielzahl von Services entwickelt, welche unter anderen dabei hilft, die CodeQualität zu analysieren. Die zwei zu erwähnenden Projekte sind Travis\footnote{LINK} und Scrutinizer\footnote{LINK}, welche für das Projekt genutzt wurden.


#### Travis-CI
[Bild einfügen]
Travis-CI ist ein Continuous Integration\footnote{Kontinuierliche Integration} (CI) Service, welcher auf Github gehostete baut\footnote{Der Begriff "bauen" kommt von Sprachen wie C oder Java, die erst kompiliert werden müssen (engl. to compile oder to build), bevor sie ein ausführbares Programm darstellen. Im Gegesatz zu interpretierten Sprachen, die zur Laufzeit von einem Interpreter übersetzt werden. Hier definiert der Begriff "bauen" im Zusammmenhang mit CI das auschecken des Codes aus einem Repository und die Ausführung von:

* Tests (Unit-, Smoke-, Akteptanz- und Behaviortests), 
* statischer Codeanalysen wie den oben genannten PHP_CodeSniffer, PHPDepend\footnote{LINK}, PHP Mess Detection\footnote{LINK} oder PHP Copy and Paste\footnote{LINK} 
* oder das Verpacken der Software in ein Realease fähiges Format wie PHAR\footnote{LINK} oder einen Tarball\footnote{LINK}}.

Die Konfiguration von Travis-CI erfolgt über eine Textdatei im YAML-Format\footnote{LINK} und liegt im Wurzelverzeichnis des Projekts.

[Beispiel einer YAML Datei für Travis einfügen]

Da der Prototyp aus zwei Teilen besteht, wurden zwei Travisprojekte erstellt. Eins für die Extension und eins für den modifizierten TYPO3 Kern.

##### Konfiguration für die Extension
PHPUnit
CodeSniffer
PHPCPD
PHPMessDetection
PHPLOC

Ziel war eine möglichst 100% Testabdeckung zu erreichen.

##### Konfiguration für den TYPO3 Kern
Während bei den Tests der Extension auf eine innere Konsistenz des Programmcodes geschaut wurde, wurde bei den Tests des Kerns Augenmerk auf die Integration der Extension in das modifizierte TYPO3 gelegt. Ziel war es, dass alle mitgelieferten Tests des Cores erfüllt werden.

PHPUNit

#### Scrutinizer
[Bild einfügen]
Es kann zweifelsfrei gesagt werden, dass Travis-CI das Arbeitstier ist. Außer den oben beschriebenen Tätigkeiten macht er nicht viel. Das Besondere daran ist jedoch, dass er diese Aufgaben unermüdlich mit der gleichen Gewissenhaft ausführt. Das ist die Stärke eines solchen Progamms. Am Ende steht jedoch immer nur ein binäres Ergebnis:

* die Tests sind bestanden
* es sind Tests fehlgeschlagen

Anhand dieses Ergebnis können dann weitere Entscheidungen getroffen werden. Zum Beispiel wird es sinnvoll sein bei einem negativen Ergebnis darauf zu verzichten ein Download Paket zu erstellen und veröffentlichen.

Braucht man jedoch eine graphische Auswertung, der durch die statische Codeanalysen gewonnen Daten, kommt ein Service wie Scrutinizer zum Einsatz. Wie schon bei Travis-CI erfolgt die Konfiguration über eine YAML Datei.

Wie Tests gezeigt haben\footnote{https://scrutinizer-ci.com/g/Konafets/TYPO3v4-Core/inspections} ist es gegenwärtig nicht möglich den TYPO3 Kern mit Scrutinizer auszuwerten, da das Tool verschiedene Limits implementiert hat. Dies Limits werden von TYPO3 teilweise um ein Vielfaches überschritten. Es ist lediglich gelungen die Auswertung der Analyse zum Umfang des Codes und zur Copy and Paste Detection darzustellen. Da dies jedoch keine ausreichende Aussage über die Code Qualität treffen kann und die Qualität des Codes des TYPO3 Kerns nicht im Fokus dieser Arbeit liegt, wurde auf die Auswertung verzichtet.

Es wurde lediglich ein Srcutinizer Projekt für die Extension erstellt.

[Auswertung des Scrutinzer beschreiben]

Eins wird bei 10.000 Issues\footnote{Mit Issues sind Stellen gemeint, die laut Scrutinizer überarbeitet werden müssten) überschritten, welches von fast alles Analysen übertroffen wird. Zum Beispiel und zum anderen hat es einen zeitlichen Timeout, der bei der Analyse der Ergebnisse wie zum Beispiel der Code Coverage\footnote{Abdeckung der Codebasis mit Unit Tests} überschritten wird  

Der Grund für die Verbindung mit Scrutinizer war auch hier der Gedanke an die spätere Veröffentlichung der Extension und stellt die Grundsteinlegung für eine gleichbeleibend hohe Codequalität dar, die überprüfbar sein soll.

#### IDE
Als Editor wurde die \gls{ide} PHPStorm. 

[Bild einfügen]

PHPStorm verfügt über Autovervollständig von Variablen, Methoden und Klassen, unterstützt den Programmierer bei der Erstellung von Klassen durch Templates und bietet vielseitige Integration von externen Programmen. 

So ist es zum Beispiel möglich die PHPUnit Tests von PHPStorm aus zu starten und mit ein wenig Konfiguraton\cite{web:kowalke14} kann man sich die CodeCoverage im Editor anzeigen lassen.

[Bild einfügen]

Besonders hilfreich ist es jedoch sich die Ergebnisse des PHP_CodeSniffers anzeigen zu lassen um zumindest beim Feinschliff den Code GCL konform zu formatieren.

Die überaus leistungsfähige Integraton von XDebug runden die Funktionaliät, die der Editor bildet, ab.

Mit Hilfe von PHPStorm war es möglich sich schnell und umfassend in den Quellcode von TYPO3 und der Extension DBAL einzuarbeiten
