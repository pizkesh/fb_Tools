<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "LaborSync 0.14 (c) 06.06.2026 by Michael Engelke";
 $info = "Neue AVM-Laborversionen mit einen Lokalen Pfad Synchronisieren";
 $meta = '{fbt:0.46,ssl:1.1}'; /*

Plugingeschichte:
0.01 28.03.2019
 - Erste Version
0.02 10.04.2019
 - NEU: Option -fd für Dateiliste zu den Downloads erstellen
 - Geändert: Option -fp für Download-Pattern
0.03 06.05.2019
 - Zusätzliche behandlung für Error 301 implementiert
0.04 24.05.2019
 - Bug: Fehlermeldung wurden nur im Debug-Modus ausgegeben
 - PHP Mindestversion auf 5.6 angehoben (Wegen AVMs HTTPS-Zertifikat)
0.05 23.06.2019
 - NEU: Unterstützung für benannte Parameter (fb_Tools 0.25+)
 - NEU: Option -md um gelöschte Dateien als "Gelöscht" zu markieren
 - Kleine Änderungen in der Fehlerbeschreibung
0.06 05.11.2020
 - Unterstützung von Arrays in Optionen (fb_Tools 0.28+)
0.07 23.03.2021
 - Anpassung an fb_Tools 0.30+
0.08 27.06.2021
 - Regulären Ausdruck an avm.de engepasst
0.09 08.08.2021
 - Anpassungen an PHP8 vorgenommen
0.10 01.12.2022
 - Anpassung an fb_Tools 0.32+
0.11 05.05.2024
 - Anpassung an avm.de
0.12 23.03.2025
 - avm.de in fritz.com geändert
 - Anpassung an fritz.com und fb_Tools 0.46+
0.13 04.10.2025
 - Anpassung an fritz.com
0.14 06.06.2026
 - Anpassung an fritz.com
*/
 if(ifset($cfg['help']) or !getArg(true)) {				// Hilfe Ausgeben
  out("$plugin\n$info\n\n$splug[0] [dir:Lokal-Dir] <Option>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self plugin $plug /Mirror -d
$self plugin $plug . -fl
$self plugin $plug . -fl:laborfiles.txt
$self plugin $plug /media/stick/ -fp:repeater -d
$self plugin $plug c:/AVM-Labor -fp:fritzbox -ow -d" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "LaborSync:|-dl:|[sec]|Wartezeit zwischen zwei Requests
|-f||Fehler Ignorieren
|-fd:|[Datei]|Zu den Downloads eine Datei-Liste erstellen
|-fp:|[pattern]|Nur diese Datei herunterladen
|-fl:|[Datei]|Nur eine Datei-Liste ausgeben
|-md:|<Datei>|Gelöschte Dateien markieren
|-ow||Dateien überschreiben";
 }
 else {
  $bug and dbug("Parse Parameter");
  $local = getArg('dir');						// [Lokal-Dir]
  if(!file_exists($local))
   makedir($local,0);
  if(file_exists($local) and is_dir($local)) {
   $local = str_replace('\\','/',realpath($local));
   $links = array();
   $host = 'fritz.com';	// avm.de
   $port = 443;
   $page = '/pages/fritz-labor/';
   if($html = request(array('method' => 'GET-array', 'host' => $host, 'port' => $port, 'page' => $page))) {
    if($html['HTTP_Code'] == 301 and preg_match('/'.preg_quote($host,'/').'[^\/]*(\/.*)$/',$html['Location'],$var))
     $html = request(array('method' => 'GET-array', 'host' => $host, 'port' => $port, 'page' => $var[1]));
    if($html and $html['HTTP_Code'] == 200 and preg_match_all('/<a[^>]+href=([\'"])(\/pages\/fritz-labor\b[\w-]+)\\1[^>]*>(.*?)<\/a>/is',$html[1],$pages)) {
     $pages = array_unique($pages[2]);
     foreach($pages as $url) {					// Verschiedene Labor Gruppen durch gehen
      if($url[0] != '/')
       $url = "/$url";
      if($html = request(array('method' => 'GET-array', 'host' => $host, 'port' => $port, 'page' => $url))) {
       if($html['HTTP_Code'] == 301 and preg_match('/'.preg_quote($host,'/').'[^\/]*(\/.*)$/',$html['Location'],$var))
        $html = request(array('method' => 'GET-array', 'host' => $host, 'port' => $port, 'page' => $var[1]));
       if($html and $html['HTTP_Code'] == 200 and (
		preg_match_all('/<button[^>]*?\(([\'"])(https:\/\/\S+?\.zip)\\1[^>]*>/is',$html[1],$link)
		or preg_match_all('/<form[^>]+method=([\'"])dialog\\1[^>]+data-download-url=\\1(\S+?\.zip)\\1[^>]*>/is',$html[1],$link)
		or preg_match_all('/<a[^>]+href=([\'"])(\S+?\.zip)\\1[^>]*>(.*?)<\/a>/is',$html[1],$link)
	)) {
        $dhost = $host;							// Jede Labor-Unterseite kann einen eigenen Download-Host bestimmen
        foreach($link[2] as $file)					// Labor-Download durch gehen
         if(!$var = getArg('-fp') or stristr($file,$var)) {		// Nicht filtern oder Filter trifft zu
          if(preg_match('!^https?://([\w.-]+)(?::(\d+))?(.+)$!',$file,$m)) {
           $dhost = $m[1];
           if($m[2])
            $port = $m[2];
           $file = $m[3];
          }
          if($file[0] != '/')
           $file = "/$file";
          if(getArg('-fl'))						// Nur eine Dateiliste erstellen
           $links[] = "https://$dhost$file";
          elseif(getArg('-ow') or !file_exists("$local/".basename($file))) {	// Labor ist noch nicht vorhanden oder darf überschrieben werden
           if(getArg('-fd'))
            $links[] = "https://$dhost$file";
           out(basename($file)." wird geladen");
           if($head = request(array('method' => "GET-save:$local/", 'host' => $dhost, 'port' => $port, 'page' => $file)) and $head['HTTP_Code'] == 200) {
            if($var = getArg('-dl','/^\d+$/0'))
             sleep($var);
           }
           elseif(!getArg('-f')) {
            out(errmsg("16:Fehler: ".$cfg['http'][0]));
            break;
           }
          }
          else
           out(basename($file)." ist schon vorhanden");			// Kein Fehler
         }
        if($var = getArg('-md') and $list = glob("$local/*.zip")) {	// Gelöschte Labor-Images Markieren
         $link = preg_replace('/^.*?[\\\\\/](?=[^\\\\\/]+$)/','',$link[2]);
         foreach($list as $file)
          if(!preg_match('/_DEL\.\w+$/',$file) and array_search(basename($file),$link) === false) {
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
       out(errmsg("8:Keine Dateien in $url zum herunterladen gefunden"));
     }
    }
    else
     out(errmsg("16:Labor hat keine Links"));
   }
   else
    out(errmsg("8:Kein Labor gefunden"));
  }
  else
   out(errmsg("8:Kein Lokales Verzeichnis gefunden"));
  if($links) {
   $links = implode("\n",$links);
   if($file = ($var = getArg('-fl') and is_string($var)) ? $var : (($var = getArg('-fd') and is_string($var)) ? $var : false))
    file_contents($file,$links);
   else
    out($links);
  }
 }

?>
