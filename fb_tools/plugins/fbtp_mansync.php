<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "ManSync 0.02 (c) 25.10.2025 by Michael Engelke";
 $info = "Alle FRITZ Handbücher herunterladen";
 $meta = '{fbt:0.46,php:5.3,ssl:1.1}'; /*

Plugingeschichte:
0.01 19.10.2025
 - Erste Version
0.02 25.10.2025
 - URLs mit Leerzeichen werden jetzt korrekt behandelt
*/
 if(ifset($cfg['help']) or !getArg(true)) {			// Hilfe Ausgeben
  out("$plugin\n$info\n\n$splug[0] <dir:Lokal-Dir> <lang:Sprache> <file:products-de.json> <Option>\n
{{{tt}Platzhalter:|{date}:|Änderungsdatum|Sprachen:|de:|Deutschland (default)
für <dir>|{ext}:|Extension||en:|English
und -st|{file}:|Dateiname.Extension||es:|España
|{group}:|Produkt-Gruppe (-pg)||fr:|Français
|{man}:|Handbuch (-mp)||it:|Italia
|{name}:|Dateiname||nl:|Nederland
|{product}:|Produkt (-np)||pl:|Polska
|{size}:|Dateigröße}}".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self plugin $plug lang:de -d
$self plugin $plug lang:de -fl -rd:products.json
$self plugin $plug . -pg:fritzbox -fl:manualfiles.txt
$self plugin $plug /media/stick/ -fp:repeater -st:{name}_%Y%m%d_%H%M%S.{ext}
$self plugin $plug c:/AVM-Handbuch/{group}/{product}/{man} -df -ow" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "MAN:|-dl:|[sec]|Wartezeit zwischen zwei Requests
|-fd:|<Datei>|Zu den Downloads ein Protokoll erstellen (CSV\|JSON\|TXT)
|-fl:|<Datei>|Nur eine Datei-Liste ausgeben (CSV\|JSON\|TXT)
|-ft:|[Strftime]|Eigenes Datum für Platzhalter {date}
|-rd:|[Datei]|RAW-Daten als JSON-Datei speichern
|-st:|[Strftime]|Alte Dateien mit Strftime oder mit Platzhalter markieren
Optionen:|-df||Duplikatsfilter (Keine Doppelten Handbücher herunterladen)
|-f||Fehler Ignorieren (Beim Downloaden)
|-ow||Alte Dateien überschreiben
MAN-Filter:|-pg:|[Gruppe]|Nur Produkt-Gruppe herunterladen (Level 1)
|-np:|[Produkt]|Nur dieses Produkt herunterladen (Level 2)
|-mp:|[Handbuch]|Nur diese Art der Beschreibung herunterladen (Level 3)
|-fp:|[pattern]|Nur diese Dateien herunterladen (Level 4)
|-lp:|[pattern]|Diese Links NICHT herunterladen (Level 4)";
 }
 else {
  $bug and dbug("Parse Parameter");
  $local = getArg('dir');					// [Lokal-Dir]
  $lang = getArg('lang','/^\w\w$/0','de');			// Sprache auswählen
  $file = getArg('file','file_exists');				// JSON-Datei Lokal bearbeiten (Nur zu Debug-Zwecken)
  if($group = getArg('-pg','/^[!\w-]+/0'))			// Product-Gruppe auswählen
   $group = "/".preg_quote($group,'/')."/i";
  if($pat = getArg('-np','/^[!\w-]+/0'))			// Product auswählen
   $pat = "/".preg_quote($pat,'/')."/i";
  if($man = getArg('-mp','/^.+$/s0'))				// Handbuch auswählen
   $man = "/".preg_quote($man,'/')."/i";
  if($pdf = getArg('-fp','/^.+$/s0'))				// PDF auswählen
   $pdf = "/".preg_quote($pdf,'/')."/i";
  if($dont = getArg('-lp','/^.+$/s0'))				// Link ignorieren
   $dont = "/".preg_quote($dont,'/')."/i";
  $date = getArg('-ft',0,'%Y-%m-%d_%H-%M-%S');			// Datum-Format
  $optsudo = getArg('-f');					// Fehler ignorieren
  $optsave = getArg('-fd');					// Ein Download-Protokoll erstellen
  $optlist = getArg('-fl');					// Nur Downloadliste erstellen
  $optmark = getArg('-st',0,"_$date");				// Neuer Name mit Strftime
  $optwait = getArg('-dl','/^\d+$/0');				// Delay nach einem Download
  $optover = getArg('-ow');					// Datei überschreiben
  $optdupe = getArg('-df');					// Dupefilter
  $port = 443;
  $host = 'assets.avm.de';					// AVM-Server
  $page = "/_/manual/";						// API-Parameter
  $data = false;
  $vars = array();						// Variabeln
  $list = array();						// Ausgabe Downloadliste
  $out = array();						// Ausgabe Umfangreiche Tabelle
  if($file)
   $data = file_contents($file);
  elseif($data = request(array('method' => 'GET', 'host' => $host, 'port' => $port, 'page' => $page.$lang))) {
   if($cfg['http']['HTTP_Code'] == 301 and preg_match('/'.preg_quote($host,'/').'[^\/]*(\/.*)$/',$cfg['http']['Location'],$var))// Reload erforderlich?
    $data = request(array('method' => 'GET', 'host' => $host, 'port' => $port, 'page' => $var[1]));				// Request wiederholen
   if($data and is_string($file = getArg('-rd')))				// RAW-Daten speichern
    file_contents($file,$data);
  }
  if($data and $json = json2array($data) and isset($json['data']['products'])) {
   foreach($json['data']['products'] as $gkey => $gvar) {			// Alle Produkt-Gruppen durchgehen (z.B. FRITZ!Box)
    if(is_array($gvar) and (!$group or preg_match($group,$gvar['name']))) {	// Produkt-Gruppe heraussuschen
     dbug("Produkt-Gruppe: $gvar[name]",9);
     $vars['{group}'] = $gvar['name'];
     foreach($gvar as $pkey => $pvar) {						// Alle Produkte durchgehen (z.B. FRITZ!Box 4020)
      if(is_array($pvar) and isset($pvar['data']) and isset($pvar['data']['fields']) and (!$pat or preg_match($pat,$pvar['name']))) {// Produkt heraussuchen
       dbug("Produkt: $pvar[name]",9);
       $vars['{product}'] = $pvar['name'];
       foreach($pvar['data']['fields'] as $mkey => $mvar) {			// Alle Handbucharten durchgehen (z.B. MAN)
        if(is_array($mvar) and isset($mvar['data']) and is_array($mvar['data']) and (!$man or preg_match($man,$mvar['name']))) {
         dbug("Manual: $mvar[name]",9);
         $vars['{man}'] = $mvar['name'];
         foreach($mvar['data'] as $data) {					// Alle Untervarianten durchgehen
          if((!$pdf or preg_match($pdf,$data['name'])) and (!$dont or !preg_match($dont,$data['url']))) {
           $vars['{file}'] = $data['name'];
           if(preg_match('!(?:^|[/\\\\])([^/\\\\]+?)(?:\.(\w*))?$!',$data['name'],$m)) {
            $vars['{name}'] = $m[1];
            $vars['{ext}'] = $m[2];
           }
           $vars['{size}'] = $data['size'];
           $vars['{date}'] = $strftime($date,$data['timestamp']);
           $key = $optdupe ? $data['hash'].$data['size'] : md5($data['url']);
           if(!$local and !$optlist)						// Nur Katalog als Tabelle ausgeben
            $out[$key] = "$gvar[name]|$pvar[name]|$mvar[name]|".$strftime($cfg['fstd'],$data['timestamp'])."| ".number_format($data['size'],0,',','.')."|$data[url]";
           elseif($optlist)							// Nur Link-Liste ausgeben
            $list[$key] = $data;
           elseif($local and !isset($list[$key]) and $data['size']) {		// Syncronieren
            $url = false;
            out("$data[name] ... ",2);
            $dir = strtr($local,$vars);
            if(!file_exists($dir))
             $dir = makedir($dir,false);
            if($dir and is_dir($dir)) {						// Gültiges Lokales Verzeichnis eingerichtet
             if(file_exists($file = realpath($dir)."/".$data['name'])) {	// Filename erstellt und Prüfung auf Exists
              if(filesize($file) != $data['size'] or hash_file('sha256',$file) != $data['hash']) {
               $url = $data['url'];
               if(!$optover) {							// Altes Handbuch sichern
                out("ist veraltet - ",2);
                $time = filemtime($file);
                $val = preg_match('/{\w+}/',$optmark)
		? realpath($dir)."/".$strftime(strtr($optmark,array(
			'{file}'=> $data['name'],
			'{name}'=> substr($data['name'],0,-strlen($data['ext'])-1),
			'{ext}'	=> $data['ext'],
			'{size}'=> filesize($file),
			'{date}'=> $date)),$time)
		: preg_replace('/(?=(\.\w+)?$)/',$strftime($optmark,$time),$file,1);
                rename($file,$val);
               }
              }
              else
               out("schon vorhanden");
             }
             else
              $url = $data['url'];						// Datei existiert nicht
             if($url and $http = request(str_replace(' ','%20',"$url#"))) {	// URL nur zerlegen
              if($head = request(array('method' => "GET-save:$dir/", 'host' => $http['host'], 'port' => $http['port'], 'page' => $http['page'])) and $head['HTTP_Code'] == 200) {
               if($optsave)							// -fd: URL in Download-Protokoll speichern
                $list[$key] = $data;
               $err = 0;
               if(file_exists($new = realpath("$dir/$data[name]")) and $err = 1 and filesize($new) == $data['size'] and $err = 2 and hash_file('sha256',$new) == $data['hash'])
                out('aktualisiert');
               elseif($optsudo)							// -f: Alles übernehmen, so wie es kommt
                out('fehlerhaft übernommen');
               else {
                if($err)
                 unlink($new);
                $var = ($err > 1) ? "Übertragene Daten sind fehlerhaft" : (($err == 1) ? "Dateilänge stimmt nicht überein" : "Keine Daten erhalten");
                out("fehlgeschlagen - $var ($url)");
               }
               if($optwait)
                sleep($optwait);
              }
              else {
               $head =  $cfg['http'];
               $var = ($head['HTTP_Code'] == 200) ? ($head['Content-Length'] ? "Datei konnte nicht erstellt werden" : "Keine Daten erhalten") : $head[0];
               out(errmsg("16:Fehler: $var ($url)"));
               $bug and dbug(compact(explode(',','data,http,head')));
              }
             }
            }
            else
             out(errmsg("16:$dir ist kein Verzeichnis"));
           }
          }
         }
        }
       }
      }
     }
    }
   }
   if($out)					// Tabellenausgabe
    out(textTable("Gruppe|Produkt|Handbuch|Datum| Größe|Url\n".implode("\n",$out),0,"|","\n",array('|','|','|','|','|')," "));
   $out = array();
   if(($optlist or $optsave) and $list) {	// -fl:Dateiliste ausgeben
    $file = $optlist ?: $optsave;
    if(is_bool($file))				// Fileliste nur auf dem Bildschirm ausgeben
     foreach($list as $var)
      out($var['url']);
    elseif(preg_match('/\.json$/i',$file)) {	// Fileliste als JSON-Datei speichern
     foreach($list as $var)
      $out[] = $var;
     file_contents($file,array2json($out)."\n");
    }
    elseif(preg_match('/\.csv$/i',$file)) {	// Fileliste als CSV-Datei speichern
     $sep = getArg('-cs',0,"\t");		// Seperator für CSV-Dateien
     $psep = preg_quote($sep,'/');
     $keys = array_keys(reset($list));
     foreach($list as $var) {
      $val = array();
      foreach($keys as $key)
       $val[$key] = isset($var[$key]) ? preg_replace("/$psep/",$sep,$var[$key]) : null;
      $out[] = implode($sep,$val);
     }
     file_contents($file,(getArg('-ch') ? implode($sep,preg_replace("/$psep/",$sep,$keys))."\n" : "").implode("\n",$out)."\n");
    }
    else {					// Fileliste als einfache TXT-Datei speichern
     foreach($list as $key => $var)
      $list[$key] = $var['url'];
     file_contents($file,implode("\n",$list)."\n");
    }
   }
  }
  else
   out(errmsg("16:Kein Handbuch-Katalog rehalten!"));
 }

?>
