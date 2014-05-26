# Fundus TYPO3

TYPO3 ist ein TYPO3 ist ein \gls{wcms} Web Content Management-System (WCMS) und wurde vom Dänen Kaspar Skårhøj zunächst für seine Kunden entwickelt - im Jahr 2000 von ihm unter der \gls{gnu2} veröffentlich. Dadurch wurde es einer breiten Öffentlichkeit bekannt und fand weltweit Beachtung. 

Im April 2007 hat sich Skårhøjs aus dem Projekt zurückgezogen um die Entwicklung in die Hände einer neuen Generation zu geben. Projektleiter des CMS ist Oliver Hader; für TYPO3 Flow and TYPO3 Neos Robert Lemke. 

\startchronology[startyear=1995, stopyear=2015]
	\chronoevent{1997}{Beginn der Entwicklung}
	\chronoevent[markdepth=45pt]{2001}{Version 3.0}
	\chronoevent{2006}{Versoin 4.0}
	\chronoevent[markdepth=25pt]{2011}{Versoin 4.5 LTS}
	\chronoevent[markdepth=55pt]{2014}{Version 6.2 LTS}
\stopchronology

Hinter der Marke TYPO3 steht keine Firma, sondern alle Projekte werden allein von der Community betreut und weiterentwickelt.

Laut der Website TYPO3 Census\footnote{http://t3census.org} existierten am 07.04.2014 weltweit 208.561 TYPO3 Installationen. 

In der Literatur und auf der Projektseite von TYPO3\footnote{http://typo3.org/} findet sich noch der Begriff \gls{ecms} Enterprise Content Management-System (ECMS), was auf den Einsatz von TYPO3 in großen Projekten hinweisen soll.


Neben dem Begriff \gls{wcms} wird TYPO3 durch die Literatur hinweg verschiedene Bezeichnungen
"Content-Management-Systeme (CMS) sind Anwendungen, die das Erstellen, die Kontrolle, die Freigabe, die Publikation, die Archivierung und die Individualisierung von Inhalten […] ermöglichen. Sie sind darauf ausgelegt einerseits dem Anwender einen einfachen Zugang zum Publikationsprozess zu verschaffen und anderseits eine systemtechnische Grundlage für die Verwaltung darzustellen."\cite[S. 2]{book:riggertEcm2009}

Web Content Management Systeme sind eine Spezialisierung davon, die ausschließlich zur Publizierung von Inhalten im Internet eingesetzt werden. Oft werden beide Begriffe synonym verwendet, was jedoch nicht korrekt ist. Ein WCMS ist immer ein CMS, ein CMS muß aber nicht immer ein WCMS sein.

Des weiteren taucht in der Literatur der Begriff \gls{ecms} Enterprise Content Management System (ECMS) auf. Tatsächlich wird TYPO3 auf der Website des Projekts\footnote{http://typo3.org/} ebenfalls als ECM bezeichnet. Hierbei handelt es sich um den Hinweis darauf, dass TYPO3 auch (oder gerade) für umfangreiche Projekte geeignet ist als für die Webvisitenkarte mit lediglich 5 statischen Seiten. 

Schaut man sich den HTML-Code an, den TYPO3 produziert, so findet man noch einen weiteren Begriff in einem HTML Kommentar:

    <!-- 
	    This website is powered by TYPO3 - inspiring people to share!
	    TYPO3 is a free open source \bf{Content Management Framework} initially created by Kasper Skaarhoj and licensed under GNU/GPL.
	    TYPO3 is copyright 1998-2012 of Kasper Skaarhoj. Extensions are copyright of their respective owners.
	    Information and contribution at http://typo3.org/
    -->
    
Während die ersten Begriffe auf den Einsatzort des Systems fokussiert sind, gibt der Begriff \gls{cmf} Content Manangement Framework (CMF) einen Hinweis auf die Architektur von TYPO3. 

TYPO3 bietet Entwicklern verschiedene \gls{apis} an, um TYPO3 zu erweitern. Diese kann werden in Backend API und Frontend API unterschieden. Zudem gibt es noch eine API die keinen Namen hat aber als eine Art Basis für alle APIs dient. In der Literatur findet man sie als Common API (vgl. \cite[S. 5 ff.]{book:dulepov2008}.

Ein Teil der Common API stellt die Datenbank API dar. Sie ist vollkommen unabhängig von anderen APIs und Klassen.

Dem Prinzip der Trennung von Inhalt, Struktur und Darstellung einer Website folgend, speichert TYPO3 die Inhalte in einer (MySQL)-Datenbank während die Struktur (HTML, XML, …) und die Gestaltung (CSS) im Dateisystem gespeichert werden.

### TYPO3 als CMS
\cite[Seite 2]{Content-Management-Systeme (CMS) sind Anwendungen, die das Erstellen, die Kontrolle, die Freigabe, die Publikation, die Archivierung und die Individualisierung von Inhalten im Inter-, Intra oder Extranet ermöglichen. Sie sind darauf ausgelegt einerseits dem Anwender einen einfachen Zugang zum Publikationsprozess zu verschaffen und anderseits eine systemtechnische Grundlage für die Verwaltung darzustellen.}

Die Frage was TYPO3 eigentlich ist, ist gar nicht so einfach zu beanworten, da es dabei auf die Sichweise ankommt. Allgemein wird es als Content-Management-System bezeichnet. Da es sich um den Inhalt von Webseiten kümmert, kann gesagt werden, dass TYPO3 ein Web Content Management System ist (WCMS). Fragt man das TYPO3 Marketing Team, so würde man wohl die Antwort erhalten, dass TYPO3 ein Enterprise Content Management System ist, da es vorwiegend für umfangreiche Webprojekte von Unternehmen eingesetzt wird, anstatt als Basis für die Webvisitenkarte.

### Was ist ein Framework

 
--- 
 
Eine der großen Stärken des System ist seine nahezu unendliche Erweiterbarkeit durch ein Pluginsystem. Plugins werden in der TYPO3 Terminologie als Extensions bezeichnet, wobei man zwischen System- und „normalen“ Extensions unterscheidet. 

---

Systemextensions, sind für den Betrieb einer TYPO3 Instanz unverzichtbar - sie \emph{sind} das System, während mit normalen Extensions solche bezeichnet werden, die aus der Community kommen. Diese sind im TYPO3 \gls{ter}\footnote{http://typo3.org/extensions/repository/} zu finden.

---

TYPO3 ist eine klassische Datenbankanwendung, welche die Trennung von Inhalt, Struktur und Design befolgt, in dem es die Inhalte in einer Datenbank speichert, die Struktur in HTML Templates und das Design durch CSS Styles vorhält. 