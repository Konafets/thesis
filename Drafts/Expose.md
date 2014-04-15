Exposé zur Bachelor Thesis

Integration der Datenbank-Abstraktionsschicht Doctrine2 in das Content-Management-System TYPO3


Verfasser: Stefano Kowalke
Datum: 11.04.2014


1 Motivation

Das Content-Management-System nutzt zur Speicherung der Websiteninhalte in der Standardeinstellung die Datenbank MySQL. Dafür stellt es eine Datenbank API zur Verfügung, über die das System auf die Datenbank zugreift. Soll sich das CMS mit der Datenbank eines anderen Herstellers verbinden, muss die mitgelieferte Systemextension DBAL installiert werden. 

Damit die Anfrage von der DBAL Extension geparst und in die anderen SQL-Dialekte konvertiert werden kann, müssen sich die Entwickler - sei es TYPO3 Kern- oder externer Extensionprogrammier - an gewisse Richtlinien, wie zum Bei- spiel die ausschließliche Nutzung der TYPO3 Datenbank API, halten. Trotz der Nutzung der API können zu DBAL inkompatible Anfragen formuliert werden. Ferner ist es möglich, komplett an der API vorbei mit der Datenbank zu kommunizieren, wodurch man wieder beim Anfangsproblem angelangt ist, welches man mit der Nutzung der DBAL Extension lösen wollte: Die Fixierung auf einen SQL-Dialekt. 

Desweiteren verwendet die DBAL Extension die extene Bibliothek AdoDB welche nicht mehr aktiv weiterentwickelt wird und weder Verbessungen noch Sicherheitsupdates bereitstellt. 

Ziel

Das Ziel dieser Arbeit war es, eine Datenbank API auf Basis von Doctrine DBAL zu implementieren. Diese 
- löst die Abhängigkeit zu AdoDB auf
- ist konsistent aufgebaut, 
- folgt dem TYPO3 Namesschemata für Methodennamen, 
- verbietet den direkten Zugriff auf die Datenbank und 
- unterstützt weiterhin die vorhandene API

Vorgehen

Es wurde eine Extension geschrieben, die die TYPO3 eigene Datenbank API überschreibt und anstelle dessen eine eigene API anbietet, die via Doctrine DBAL auf die Datenbank zugreift. 

Zu Test- und Demonstrationszwecken wurde der Kern von TYPO3 an die neue API  angepasst.

