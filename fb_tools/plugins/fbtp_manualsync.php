<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "ManualSync 0.06 (c) 19.10.2025 by Michael Engelke";
 $info = "Alle FRITZ!Schnittstellen Beschreibungen herunterladen";
 $meta = '{fbt:0.46,ssl:1.1}'; /*

Plugingeschichte:
0.01 23.06.2019
 - Erste Version
0.02 05.11.2020
 - Unterstützung von Arrays in Optionen (fb_Tools 0.28+)
0.03 23.03.2021
 - Anpassung an fb_Tools 0.30+
0.04 01.12.2022
 - Anpassung an fb_Tools 0.32+
 - Anpassung an PHP 8.x
0.05 23.03.2025
 - avm.de in fritz.com geändert
 - Anpassung an fb_Tools 0.46+
0.06 19.10.2025
 ! Aufgrund der geändert API, kann dieses Plugin KEINE FRITZ!Anleitungen mehr herunterladen
 ! Nutzen sie stattdessen dafür das neue Plugin: fbtp_MANSync.php
 - Vollständige Funktionialität auf Schnittstellen reduziert
 - Schleife für Multiple Gruppen entfernt
 - Links für die Schnittstellen in den verschiedenen Sprachen erweitert
 - Hilfe komplett überarbeitet
*/
 if(ifset($cfg['help']) or !getArg(true)) {			// Hilfe Ausgeben
  out("$plugin\n$info\n\n$splug[0] [dir:Lokal-Dir] <lang:Sprache> <Option>
{{{tt}Sprachen:	|de:|Deutsch	||it:|Italia
		|en:|English	||es:|España
		|at:|Österreich	||fr:|Français
		|lu:|Luxemburg	||be:|België
		|pl:|Polska	||nl:|Nederland}}"
.(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self plugin $plug /Mirror -d
$self plugin $plug . -fl
$self plugin $plug . -fl:manualfiles.txt
$self plugin $plug /media/stick/ -fp:tr-64 -d
$self plugin $plug c:/Schnittstellen -fp:aha -ow -d" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "Manual:|-dl:|[sec]|Wartezeit zwischen zwei Requests
|-dt:|[sec]|Erlaubte Differenzzeit zwischen Client/Server
|-f||Fehler Ignorieren
|-fd:|<Datei>|Zu den Downloads eine Datei-Liste erstellen
|-fl:|<Datei>|Nur eine Datei-Liste ausgeben
|-fp:|<pattern>|Nur diese Datei herunterladen
|-md:|<Datei>|Gelöschte Dateien markieren
|-ow||Dateien überschreiben
|-st:|[Strftime]|Doppelte Dateien mit Strftime umbenennen";
 }
 else {
  $bug and dbug("Parse Parameter");
  $local = getArg('dir');					// [Lokal-Dir]
  $cfg['sync'] = getArg('-dt','/^\d+$/0',2*60*60);		// Erlaube Differenzzeit in Sekunden
  $cfg['dupe'] = getArg('-st',0,"_%Y-%m-%d_%H-%M-%S");		// Neuer Name mit Strftime
  if(!file_exists($local))
   makedir($local,0);
  if(file_exists($local) and is_dir($local)) {
   $local = str_replace('\\','/',realpath($local));
   $links = array();
   $port = 443;
   $host = 'fritz.com';						// API-Host
   if($var = preg_array('/'.preg_quote(getArg('lang','/^\w+$/0','de'),'/').'/i',array(	// Weitere Sprachen
	'de.Deutsch'	=> 'pages/schnittstellen',
	'at.Österreich'	=> 'de-at/pages/schnittstellen',
	'lu.Luxemburg'	=> 'de-lu/pages/schnittstellen',
	'en.English'	=> 'en/pages/interfaces',
	'pl.Polska'	=> 'en-pl/pages/interfaces',
	'it.Italia'	=> 'it-it/pages/interfacce',
	'es.España'	=> 'es-es/pages/interfaces-1',
	'fr.Français'	=> 'fr-lu/pages/interfaces-2',
	'be.België'	=> 'nl-be/pages/interfaces-3',
	'nl.Nederland'	=> 'nl-nl/pages/interfaces-3'),1))
    $page = $var;
    if($html = request(array('method' => 'GET-array', 'host' => $host, 'port' => $port, 'page' => "/$page/"))) {
    if($html['HTTP_Code'] == 301 and preg_match('/'.preg_quote($host,'/').'[^\/]*(\/.*)$/',$html['Location'],$var))// Reload erforderlich?
     $html = request(array('method' => 'GET-array', 'host' => $host, 'port' => $port, 'page' => $var[1]));	// Request wiederholen
    if($html and $html['HTTP_Code'] == 200 and preg_match_all('/<a[^>]+href=([\'"])(\S+\.pdf)\\1[^>]*>(.*?)<\/a>/is',$html[1],$link)) {
     foreach($link[2] as $file)					// Handbuch-Download durch gehen
      if(!$var = getArg('-fp') or stristr($file,$var)) {	// Nicht filtern oder Filter trifft zu
       if(getArg('-fl'))					// Nur eine Dateiliste erstellen
        $links[] = $file;
       elseif(preg_match('!(https?://([\w.-]+)(?::(\d+))?)?(\S+)!',$file,$http)) {
        if(!$http[1]) {						// Sonderfall Schnittstellen
         $http[2] = $host;
         $http[4] = "/".$http[4];
        }
        if(!$http[3])
         $http[3] = 443;
        out(basename($file)." ... ",2);
        if(file_exists($lile = "$local/".basename($file))) {	// Handbuch existiert schon
         if($head = request(array('method' => "HEAD", 'host' => $http[2], 'port' => $http[3], 'page' => $http[4])) and $head['HTTP_Code'] == 200
		and $head['Content-Length'] == filesize($lile) and abs(strtotime($head['Last-Modified']) - filemtime($lile)) < $cfg['sync']) {
          $http = false;
          out("ist aktuell");					// Handbuch ist noch immer aktuell
         }
         elseif(!getArg('-ow')) {				// Altes Handbuch sichern
          $val = preg_replace('/(?=(\.\w+)?$)/',@strftime($cfg['dupe'],filemtime($lile)),$lile,1);
          out("ist veraltet - ",2);
          rename($lile,$val);
         }
        }
        if($http) {
         out("starte Download");
         if($head = request(array('method' => "GET-save:$local/", 'host' => $http[2], 'port' => $http[3], 'page' => $http[4])) and $head['HTTP_Code'] == 200) {
          if(getArg('-fd'))
           $links[] = $file;
          if($var = getArg('-dl','/^\d+$/0'))
           sleep($var);
         }
         elseif(!getArg('-f')) {
          out(errmsg("16:Fehler: ".$cfg['http'][0]));
          break;
         }
        }
       }
      }
     if($var = getArg('-md') and $list = glob("$local/*.zip")) {// Gelöschte Handbücher markieren
      $link = preg_replace('/^.*?[\\\\\/](?=[^\\\\\/]+$)/','',$link[2]);
      foreach($list as $file)
       if(!preg_match('/_(DEL|\d{4}(-\d\d){2}_\d\d(-\d\d){2})\.\w+$/',$file) and array_search(basename($file),$link) === false) {
        $bug and dbug("$file wurde gelöscht");
        if(is_bool($var))
         rename($file,preg_replace('/(?=(\.\w+)?$)/',"_DEL",$file,1));
        elseif($var == ':')
         out($file);
        else
         file_contents($var,"$file\n",8);
       }
     }
    }
   }
   else
    out(errmsg("8:Kein Handbuch gefunden!"));
  }
  else
   out(errmsg("8:Kein Lokales Verzeichnis gefunden!"));
  if($links) {
   $links = implode("\n",$links);
   if($file = ($var = getArg('-fl') and is_string($var)) ? $var : (($var = getArg('-fd') and is_string($var)) ? $var : false))
    file_contents($file,$links);
   else
    out($links);
  }
 }

?>
