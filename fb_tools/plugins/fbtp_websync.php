<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "WebSync 0.12 (c) 23.03.2025 by Michael Engelke";
 $info = "Das AVM-Firmwareverzeichnis mit einen Lokalen Pfad Synchronisieren";
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.01 27.01.2018
 - Erste Version
0.02 17.07.2018
 - Verbesserte Debug-Ausgabe
0.03 28.03.2019
 - NEU: Option -dl für Wartezeit zwischen Requests
 - NEU: Option -fe Filter für Dateitypen
 - NEU: Unterstützung für https mit Portangabe
 - NEU: Local-Dir kann mit HTTP-Dir#Local-Dir geändert werden
0.04 10.04.2019
 - NEU: Option -fd für Dateiliste zu den Downloads erstellen
0.05 23.06.2019
 - NEU: GZip-Schnellvergleich
 - NEU: Unterstützung für benannte Parameter
 - NEU: Optionen -dt, -md, -st, -td implementiert
 - Benötigt fb_tools 0.25+
0.06 02.04.2020
 - NEU: Option -it für Dateizeit ignorieren
 - BUG: GZip-Schnellvergleich funktionierte nicht
 - FIX: Standard-Differenzzeit auf 121 Minuten erhöht
0.07 05.11.2020
 - Optionen können mit den Argumenten vermischt werden (fb_Tools 0.28+)
0.08 23.03.2021
 - Anpassung an fb_Tools 0.30+
0.09 08.08.2021
 - Anpassungen an PHP8 vorgenommen
0.10 01.12.2022
 - Anpassung an fb_Tools 0.32+
 - Anpassungen an PHP8.x vorgenommen
0.11 03.06.2024
 - Keine Fehler mit Variabeln beseitigt
0.12 23.03.2025
 - Anpassungen an fb_Tools 0.46+
*/
 if(ifset($cfg['help']) or $var = getArg(true) and count($var) < 2) {			// Hilfe Ausgeben
  out("$plugin\n$info\n\n$splug[0] [dir:Lokal-Dir] [web:HTTP-Dir] <web:HTTP-Dir> ... <Option>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self $plug /Mirror //download.avm.de/fritzbox/fritzbox-7490 /fritzbox/fritzbox-7590 -gm -d
$self $plug c:/Mirror https://service.avm.de/downloads/beta/fritzbox-7560 /downloads/beta/fritzbox-7590 -gm
$self $plug /media/stick/source //osp.avm.de/fritzbox/fritzbox-7530 -gm -d" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "WebSync:|-dl:|[sec]|Wartezeit zwischen zwei Requests
|-do||Keine Unterverzeichnisse
|-dt:|[sec]|Erlaubte Differenzzeit zwischen Client/Server
|-f||Fehler Ignorieren
|-fd:|<Datei>|Zu den Downloads eine Datei-Liste erstellen
|-fe:|<ext,ext,ext>|Nur die angegebenen Datei-Typen
|-fl:|<Datei>|Nur eine Datei-Liste ausgeben
|-gm||Greenwich Mean Time
|-it||Zeit Ignorieren
|-md:|<Datei>|Gelöschte Dateien markieren
|-ow||Dateien überschreiben
|-st:|[Strftime]|Doppelte Dateien mit Strftime umbenennen
|-td||Datum der Mutterverzeichnisse ändern";
 }
 else {
  $bug and dbug("Parse Parameter");
  $cfg['frep'] = '';		// Illegale Zeichen löschen
  $cfg['sync'] = getArg('-dt','/^\d+$/0',2*60*60+60);				// Erlaube Differenzzeit in Sekunden
  $cfg['dupe'] = getArg('-st',0,"%Y-%m-%d_%H-%M-%S");				// Neuer Name mit Strftime
  $var = getArg('dir');								// [Lokal-Dir]
  if(!file_exists($var))
   makedir($var,0);
  if(file_exists($var) and is_dir($var)) {
   $cfg['sync_local_path'] = $var;						// Destination
   $http = 'download.avm.de';							// Default Host
   $array = getArg('web',array(),0) or $array = getArg(0,array());		// [Web-Dir]
   foreach($array as $key => $var)
    if(preg_match('!^(?:((?:ht|f)tps?:)?//([\w.-]+)(:\d+)?)?((?:/[\w.%?=-]+)*)/?(#.*)?$!i',$var,$val)) {
     if(ifset($val[2]))			// Host
      $http = $val[2];
     if(ifset($val[3]))			// Path
      $http .= $val[3];
     elseif(ifset($val[1],'https:'))	// Protokoll
      $http .= ":443";
     $array[$key] = "$http$val[4]/".(isset($val[5]) ? $val[5] : "");
    }
    else
     unset($array[$key]);
   if($cfg['sync_remote_path'] = array_values($array)) {			// Source
    $links = array();
    while($var = array_shift($cfg['sync_remote_path'])) {			// Verzeichnisliste durchgehen
     if(preg_match('!^([^/:]+)(?::(\d+))?([^#]+)(?:#(.+))?$!',$var,$link)) {	// Domain:Port/Path#Local-Dir
      if(ifset($link[4])) {
       $cfg['sync_local_path'] = $link[4];					// Destination
       $bug and dbug("Neues Lokal-Verzeichnis: $cfg[sync_local_path]");
       $link[0] = preg_replace('/#.*$/','',$link[0]);
      }
      $dir = preg_replace($cfg['desc'],'',str_replace('\\','/',realpath($cfg['sync_local_path']))."$link[3]");	// Lokalen Pfad erstellen
      if(!file_exists($dir))
       makedir($dir,0);
      out("Dir: $link[3] (".count($cfg['sync_remote_path'])." todo)");
      $down = 0;
      $files = array();
      if($page = request(array('method' => 'GET-array', 'host' => $link[1], 'port' => ($link[2] ? $link[2] : $cfg['port']), 'page' => $link[3]))
	and $page['HTTP_Code'] == 200 and preg_match_all('!<a\s+href=([\'"])([^.][^\'"]+)\1>.*?</a>.*?(\d\d[-/]\w\w\w?[-/]\d{4}|\d{4}(?:-\d\d){2}).*?(\d\d:\d\d(?::\d\d)?).*?(-|[\d.]+)\s*([BKMGT]?)!i',$page[1],$array)) {
       foreach($array[2] as $key => $var) {					// Alle Links des Verzeichnis durchgehen
        $var = urldecode($var);
        $date = strtotime($array[3][$key]." ".$array[4][$key].((getArg('-gm')) ? " GMT" : ""));
        $size = floor(floatval($array[5][$key]) * pow(2,max(0,strpos('BKMGT',strtolower($array[6][$key]))) * 10));
        $ext = preg_replace('/^.*?(\w*)$/','$1',$var);
        if(substr($var,-1) == '/' and !getArg('-do'))				// Weitere Unter-Verzeichnisse gefunden
         array_unshift($cfg['sync_remote_path'],$link[$var[0] == '/'].$var);
        elseif($ext and getArg('-fe') and !getArg('-fe',"/(?<!\w)$ext(?!\w)/"))
         $bug and dbug("Überspringe: $link[3]");
        elseif(getArg('-fl'))							// Datei-Liste erstellen
         $links[] = date('Y-m-d H:i:s',$date).str_pad($size,10," ",STR_PAD_LEFT)." ".$link[$var[0] == '/'].$var;
        else {									// Dateien herunterladen
         $files[] = $file = $dir.preg_replace($cfg['fesc'],'',preg_replace('/^.*?([^\/?]+)$/','$1',$var));	// Lokalen Dateinamen erstellen
         if(!file_exists($file) or !getArg('-it') and abs(filemtime($file)-$date) > $cfg['sync'] or !$array[6][$key] and filesize($file) != $size) {// Prüfen ob vorhanden und uptodate
          $chk = true;
          $pname = strtr((($var[0] != '/') ? "$link[3]/" : "").$var,array(' ' => '%20'));
          if(file_exists($file)) {						// Datei vor dem Überschreiben sichern
	   if(ifset($file,'/\.t?gz$/i') and $data = file_contents($file,-8,8)	// GZip Schnellvergleich
		and $meta = request(array('method' => "head-array", 'host' => $link[1], 'page' => $pname)) and ifset($meta['Content-Length'],'/^\d+$/')
		and ifset($meta['Accept-Ranges'],'/bytes/i') and $meta = request(array('method' => "GET", 'host' => $link[1], 'page' => $pname, 'head' => array_merge(	$cfg['head'],
			array('Range' => 'bytes='.($meta['Content-Length']-8).'-'.($meta['Content-Length']-1)))))) {
            if($chk = ($meta != $data))						// True wenn Verschieden
             touch($file,$date);
            $bug and dbug("GZip-Check: ".basename($file)." ... ".($chk ? "Nicht " : "")."gleich");
           }
           if($chk and !getArg('-ow')) {					// Überschreiben oder Sichern
            $vas = preg_replace('/(?=(\.\w+)?$)/',"_".@strftime($cfg['dupe'],filemtime($file)),$file,1);
            $bug and dbug("Sichere: $vas");
            rename($file,$vas);
           }
          }
          if($chk) {								// Datei herunterladen
           if(getArg('-fd'))							// Datei-Liste erstellen
            $links[] = date('Y-m-d H:i:s',$date).str_pad($size,10," ",STR_PAD_LEFT)." ".$link[$var[0] == '/'].$var;
           if($var = getArg('-dl','/^\d+$/0'))
            sleep($var);
           out("Lade: ".basename($file));	// $var
           request(array('method' => "GET-save:$dir", 'host' => $link[1], 'page' => $pname));
           $down = max($down,$date);
          }
         }
        }
       }
       if($var = getArg('-md') and $list = glob("$dir*")) {			// Gelöschte Labor-Images Markieren
        $files = preg_replace('/^.*?[\\\\\/](?=[^\\\\\/]+$)/','',$files);
        foreach($list as $file)
         if(is_file($file) and !preg_match('/_(DEL|\d{4}(-\d\d){2}_\d\d(-\d\d){2})(\.tar\.gz|\.\w+)$/',$file) and array_search(basename($file),$files) === false) {
          $bug and dbug("$file wurde gelöscht");
          if(is_bool($var))
           rename($file,preg_replace('/(?=(\.tar\.gz|\.\w+)?$)/',"_DEL",$file,1));
          elseif($var == ':')
           out($file);
          else
           file_contents($var,"$file\n",8);
         }
       }
       if($down and getArg('-td')) {						// Veränderte Verzeichnisse auf letzte Änderung setzen
        $bug and dbug("Setzte $link[3] auf ".date('d.m.Y H:i:s',$date));
        $dir = str_replace('\\','/',$link[3])."./";
        while(($dir = preg_replace('![^/]+/*$!','',$dir)) != '/')
         touch(str_replace('\\','/',realpath($cfg['sync_local_path'])).$dir,$date);
       }
      }
      elseif($page['HTTP_Code'] != 200 and !getArg('-f')) {			// Fehler aufgetreten
       out($page);
       break;
      }
      if($var = getArg('-dl','/^\d+$/0'))
       sleep($var);
     }
    }
   }
   else
    out(errmsg("10:Keine gültigen Web-Verzeichnisse angegeben!"));
  }
  else
   out(errmsg("8:Kein Lokales Verzeichnis gefunden"));
  if(ifset($links)) {
   $links = implode("\n",$links);
   if($file = ($var = getArg('-fl') and is_string($var)) ? $var : (($var = getArg('-fd') and is_string($var)) ? $var : false))
    file_contents($file,$links);
   else
    out($links);
  }
 }

?>
