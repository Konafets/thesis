# TYPO3

## Geschichte

TYPO3 ist (eine modular aufgebautes) Content-Management-System, welches vom Dänen Kaspar Skårhøj zunächst für seine Kunden entwickelt wurde. Im Jahr [JAHR] veröffentlichte es Skårhøj unter der \gls{gnu2}, wordurch es einer breiten Öffentlichkeit bekannt wurde und recht schnell Anhänger fand. Bis zum Rückzug Skårhøjs aus dem Projekt im Jahr [Jahr einfügen] wurde das System unter seiner Leitung mit Hilfe vieler tausend freiwilliger Programmierer weiterentwickelt. Aktuell wird es von den Active Contributern entwickelt. Projektleiter des CMS ist Oliver Hader.

Laut der Website TYPO3 Census\footnote{http://t3census.org} ist TYPO3 aktuell (16.April 2014)  [Anzahl von TYPO3 Zensus einfügen] Mal installiert.

[Bild einfügen]

Für das Grundverständnis ist es wichtig zu wissen, dass sich TYPO3 in ein Backend und ein Frontend unterteilt, wobei letzteres naturgemäß für die Webseitenbenutzer sichtbar. Das Backend wird zur Konfiguration, Administration und der Pflege der Website benutzt und ist deshalb nur für einen internen Personenkreis verfügbar. 

Aus der Perspektive eines Programmierers, ist TYPO3 ein Framework und wird deshalb auch als Content-Manangement-Framework (CMF) [Abkürzungsverzeichnis] bezeichnet. 

Eine der großen Stärken des System ist seine nahezu unendliche Erweiterbarkeit durch ein Pluginsystem. Plugins werden in der TYPO3 Terminologie als Extensions bezeichnet, wobei man zwischen System- und „normalen“ Extensions unterscheidet. 

Systemextensions, sind für den Betrieb einer TYPO3 Instanz unverzichtbar - sie \emph{sind} das System, während mit normalen Extensions solche bezeichnet werden, die aus der Community kommen. Diese sind im TYPO3 Extension Repository (TER) [Abkürzungsverzeichnis] \footnote{http://ter.de} zu finden.

Die Datenbank-API ist eine der vielen APIs, die TYPO3 anbietet. Sie wird vom Core\footnote{Programmkern - eine Teilmenge von unverzichtbaren Systemextensions} genutzt und es wird den Entwicklern von Extensions sehr empfohlen diese API in ihrem Code zu verwenden anstelle von eigenen Queries.\footnote{Es ist aktuell möglich komplett an der Datenbank API vorbei mit der Datenbank zu kommunizieren.}



Seine Mächtigkeit erhält TYPO3 durch dessen Erweiterbarkeit über Extensions, durch die das System nahezu jeder Anforderung angepasst werden kann. Aus diesem Grund wird es auch oft als Content-Management-Framework bezeichnet, da es Drittparteien möglich ist - wie in der Einleitung schon angeklungen ist - das System durch eigene Extension zu erweitern. Dem sind fast keine Grenzen gesetzt.

TYPO3 ist eine klassische Datenbankanwendung, welche die Trennung von Inhalt, Struktur und Design befolgt, in dem es die Inhalte in einer Datenbank speichert, die Struktur in HTML Templates und das Design durch CSS Styles vorhält. 

Backend / Frontend Konzept

[Bild einfügen]

Das System unterscheidet zwischen einem Backend und einem Frontend, die strikt voneinander getrennt sind, jedoch beide auf die Datenbank zugreifen. Intern besteht das TYPO3 aus verschiedenen Systemextensions, die genauso aufgebaut sind, wie extene Extensions, mit dem Unterschied, dass es ohne sie nicht funktionieren würde. Sucht man den Kern von TYPO3, so findet man die Core Extension, die auch die Anbindung an die Datenbank bereitstellt.

Interner Aufbau durch Extensions