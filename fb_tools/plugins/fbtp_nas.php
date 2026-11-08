<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "NAS 0.03 (c) 02.10.2026 by Michael Engelke";
 $info = 'Auf die Dateien von MyFRITZ-NAS lesend zugreifen und Archivieren';
 $meta = '{fbt:0.48,fos:7.20}'; /*

Plugingeschichte:
0.01 30.03.2025
 - Erste Version für Fritz!OS 7.20+
0.02 01.04.2025
 - BUG: Wurde kein Limit angegeben wurde bei "List" nichts ausgegeben
0.03 02.10.2026
 - Kleine Verbesserungen vorgenommen
 - Anpassung an fb_Tool 0.48
*/
 extract(array(	// Überschreibbare Variabeln
	'max' => array('tar' => array(/* 'name' => 100, */ 'size' => pow(8,11)))
 ),EXTR_SKIP);

 function nas_name($name,$mode=0) {	// Ersatz für dirname() und basename()
  return preg_replace($mode ? '~^.*[\\\\/](?=[^\\\\/]+$)~' : '~((?<!^)[\\\\/])?[^\\\\/]+$~','',$name);
 }
 function nas_calcSize($size) {			// Dateigröße in Einheiten ausgeben
  global $kmg,$sb;
  if(!isset($kmg)) {
   $kmg = array();				// Dateigrößen vordefinieren
   $key = 'QRYZEPTGMK ';
   for($a=0;$a<strlen($key);$a++)
    $kmg[$key[$a]] = pow(1024,strlen($key)-1-$a);
  }
  if($size) {					// Größe berechnen
   if(ifset($sb))
    $size = (isset($kmg[$sb]) and is_float($var = $size/$kmg[$k = $sb])) ? number_format($var,1,'.','') : $var;
   else {
    foreach($kmg as $k => $v)
     if($size > $v)
      break;
    if($size > 1024)
     $size = ($size/$v < 10) ? number_format($size/$v,1,'.','') : floor($size/$v);
   }
  }
  else
   $k = '';
  if($sb != ' ')
   $size .= str_pad($k."B",3," ",STR_PAD_LEFT);	// Size in String umwandeln
  return $size;
 }
 if(ifset($cfg['help']) or !getArg(true)) {					// Hilfe Ausgeben bei -h oder ohne Parameter
  out("$plugin\n$info\n\n$splug[2] [func:List|Get|FileList|Export] <dir> <file> <limit> <sort:filename|type|size|mtime>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] $plug list
$self $cfg[fbhp] $plug list dir:$qt/FRITZ$qt file:./liste.json
$self $cfg[fbhp] $plug get file:$qt/Bilder/FRITZ-Picture.jpg$qt dir:$qt/home/User/Desktop$qt
$self $cfg[fbhp] $plug filelist dir:$qt/$qt file:./Desktop/nasliste.csv
$self $cfg[fbhp] $plug export dir:$qt/$qt file:/media/usb-drive/backup.tar.gz" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "NAS:|-ch||Schreibt in der Datei ein CSV-Header
|-cs:|[Char]|CSV-Separator festlegen (;)
|-fn:|[String]|Dateiname finden
|-ft:|[Strftime]|Eigenes Datumsformat ($cfg[fstr])
|-sb:|<K\|M\|G>|Präfixgröße";
 }
 elseif(login(false) >= 720 or getArg('-f')) {					// Firmware überprüfen
  if($func = getArg('func','/^(?:
	(list|l)							# 1: list
	|(get|file|download|Datei|[dfg])				# 2: file
	|((?:file|datei)liste?|[fd]l)					# 3: filelist
	|(backup|export|[be])						# 4: backup
	)($)/ix')) {							# 5: end
 #  $fw = $cfg['fiwa'] < 720;							// Versionsweiche (In Zukunft vielleicht)
   if($sid = (ifset($cfg['bsid'])) ? $cfg['bsid'] : login()) {			// Login durchführen
    if($cfg['bsid'] or isset($cfg['auth']['NAS'])) {
     $ftime = getArg('-ft',false,$cfg['fstr']);					// Benutzerdefiniertes Datum-Format
     $page = '/myfritz/api/data.lua';
     $down = '/nas/cgi-bin/luacgi_notimeout';
     $line = "";
#     $storage = array('internal_storage', 'webdav', 'usb');
#     $type = array('directory','other','document','picture','audio','video');
     if(($func[1] or $func[3] or $func[4]) and $path = getArg('dir',false,'/')) {// func:List / filelist / export
      if($path[0] != '/')
       $path = "/$path";
      $export = getArg('file');
      if($find = getArg('-fn') and strpos($find = preg_quote($find,'/'),'\*') !== false)// Suche in Ergebnis
       $find = preg_replace(array('/^(?!\\\\\*)/','/(?<!\\\\\*)$/','/\\\\\*/'),array('^','$','.*'),$find);
      $backup = $arc = $sep = $head = $js = false;
      if($export)								// file-Parameter weiter auswerten
       if($func[1] or $func[3]) {
        if(preg_match('/\.csv(\.gz)?$/i',$export)) {				// CSV
         $sep = str_replace('\t',"\t",getArg('-cs',false,';'));			// CSV-Sepatator
         $head = getArg('-ch');							// CSV-Header
        }
        $js = $export and preg_match('/\.json(\.gz|\.bz(ip2)?)?$/i',$export);	// JSON
       }
       elseif($func[4])								// func: export / backup
        if(is_dir($export)) {							// file ist ein Verzeichnis
         $backup = realpath($export)."/FRITZ!NAS_".time()."tar";
         $arc = 'tar';
        }
        elseif(ifset($export,'/\.tar(\.([bg]z|bz(ip)?2))?$|\.t[bg]z$/i')) {	// file ist ein TAR-Archiv
         $backup = $export;
         $arc = 'tar';
        }
        else									// file ist was unbekanntes
         $export = false;
      $limit = min(1000,max(0,getArg('limit','is_numeric',0)));			// Limitierung 1-1000: 100
      if($sb = getArg('-sb'))
       if(is_bool($sb))
        $sb = ' ';
       elseif($var = getArg('-sb','/^[QRYZEPTGMKB]$/i0')) {
        $var = strtoupper($var);
        $sb = ($var == 'B') ? " " : $var;
       }
       else
        $sb = false;
      if($sort = getArg('sort','/^([+-]?)\s*(?:((?:datei|file)(?:name)?|name)|(type?)|(size|groesse)|(mtime|date|datum)|(pfad|path))($)/i')) {	// Sortierung
       $var = $func[1] ? array('filename','type','size','mtime','filename') : array('name','type','size','date','path');			// Sortierung festlegen
       for($a=2; $a < count($sort); $a++)
        if($sort[$a]) {
         $sort = ($sort[1] ? $sort[1] : "+").$var[$a-2];
         break;
        }
      }
      if($func[1]) {								// List
       $array = array(
	'sid' => $sid,
	'path' => $path ? $path : '/',
	'c' => 'nas.files',
	'a' => 'browse');
       if($limit)
        $array['limit'] = $limit;	// 1000
       if($sort)
        $array['sort'] = $sort;		// "+filename"
       if($data = request('POST',$page,http_build_query($array)) and ifset($data,'/^\{.*\}$/') and $json = json2array($data)) {
       $bug and dbug(compact(explode(',','data,json')),9);
       $t = 0;
       $list = array();
       if(ifset($json['directories']))
        foreach($json['directories'] as $var)
         if($export and $sep and (!$find or preg_match("/$find/i",$var['path'])))
          $line .= implode($sep,str_replace(array($sep,'"'),array("\\$sep",'""'),array(nas_name($var['path']),$var['filename'],$var['type'],null,$strftime($ftime,$var['timestamp']))))."\n";
         elseif($js)
          $list[] = array('path' => nas_name($var['path']), 'name' => $var['filename'], 'type' => $var['type'], 'size' => null, 'date' => $var['timestamp']);
         else
          $line .= "$var[filename] |Dir |".$strftime($ftime,$var['timestamp'])."\n";
       if(ifset($json['files']))
        foreach($json['files'] as $file) {
         if(!$find or preg_match("/$find/i",$var['path'])) {
          $t += $file['size'];
          $size = nas_calcSize($file['size']);
          if($export and $sep)
           $line .= implode($sep,str_replace(array($sep,'"'),array("\\$sep",'""'),array(nas_name($file['path']),$file['filename'],$file['type'],$file['size'],$strftime($ftime,$file['timestamp']))))."\n";
          elseif($js)
           $list[] = array('path' => nas_name($file['path']), 'name' => $file['filename'], 'type' => $file['type'], 'size' => $file['size'], 'date' => $file['timestamp']);
          else
           $line .= "$file[filename] | $size|".$strftime($ftime,$file['timestamp'])."\n";
         }
        }
        if($line or $list) 
         if($export) {
          if($sep) {
           if($head)
            $line = implode($sep,array('path','name','type','size','date'))."\n".$line;
          }
          elseif($js)
           $line = array2json(array('list' => $list));
          if(!file_contents($export,$line))
           out(errmsg(0,'file_contents'));
         }
         else {
          out(textTable("Dateien | Größe|Datum\n".out($line,9),0,"|","\n",array("|","|")," "));
          if(ifset($json['diskInfo'])) {
           $line = array('listed' => $t) + $json['diskInfo'];
           foreach($line as $key => $var)
            $line[$key] = "$key: ".nas_calcSize($var);
           out("\n".implode(' / ',$line));
          }
         }
        else
         out(errmsg("8:Leeres Verzeichnis"));
        $bug and dbug(compact(explode(',','line,json,list,path,sort,sb,limit')),9);
       }
       elseif($var = ifset($cfg['http']['HTTP_Code'],''))
        out(errmsg(($var == 400) ? "8:Verzeichnis nicht gefunden" : (($var == 404) ? "64:NAS-Funktion nicht verfügbar" : "16:Unbekannte Daten erhalten")));
       else
        out(errmsg("2:Kommunikation mit Fritz!NAS fehlgeschlagen"));
      }
      elseif($func[3] or $func[4]) {						// func:filelist
       $list = array();
       if(!$path)
        $path = '/';
       else
        $path = preg_replace('!(?<=.)/$!','',$path);
       $dirs = array(array('path' => $path, 'timestamp' => 0));
       $a = $b = $t = $s = $n = $p = $l = $f = $d = 0;
       while($dir = array_shift($dirs)) {					// Verzeichnisse durchgehen und fileliste anlegen
        if($bug)
         dbug("Lese Verzeichnis: '$dir[path]' ... ",0,10);
        else
         out(".",10);
        if(isset($dir['filename'])) {
         $var = array('path' => nas_name($dir['path']), 'name' => $dir['filename'], 'type' => 'directory', 'size' => false, 'date' => $dir['timestamp']);
         $list[($sort ? $var[substr($sort,1)]."|" : "").$l++."-".$d++] = $var;
        }
        if($data = request('POST',$page,http_build_query(array(
	'sid' => $sid,
	'path' => $dir['path'],
#	'limit' => $limit,
#	'sorting' => $sort ? $sort : "+filename",
	'c' => 'nas.files',
	'a' => 'browse'))) and ifset($data,'/^\{.*\}$/') and $json = json2array($data)) {
         if($bug) {
          dbug(compact(explode(',','data,json')),9);
          $array = array();
          if($var = ifset($json['directories']))
           $array[] = "Dirs: $var";
          if($var = ifset($json['files']))
           $array[] = "Files: $var";
          dbug($array ? implode(" / ",$array) : "Leer",0,8);
         }

         if(ifset($json['directories'])) {					// Weitere Verzeichnisse erfassen
          $array = array();
          foreach($json['directories'] as $file)
           $array[] = array('path' => $file['path'], 'filename' => $file['filename'], 'timestamp' => $file['timestamp']);
          $dirs = array_merge($array,$dirs);
         }
         if(ifset($json['files']))						// Dateien erfassen
          foreach($json['files'] as $file) {
           if(!$find or preg_match("/$find/i",$file['path'])) {
            $var = array('path' => nas_name($file['path']), 'name' => $file['filename'], 'type' => $file['type'], 'size' => $file['size'], 'date' => $file['timestamp']);
            $list[($sort ? $var[substr($sort,1)]."|" : "").$l++."-".$f++] = $var;
            $p = max($p,strlen($file['path']));		// Maximale Pfadlänge
            $n = max($n,strlen($file['filename']));	// Maximale Dateinamenlänge
            $s = max($s,$file['size']);			// Maximale Dateigröße
            $t += $file['size'];			// Totale Dateigröße
           }
          }
        }
        else
         $bug and dbug("Fehlgeschlagen",0,8);
       }
       if($bug) {
        dbug(array(
		'total' => $t,
		'maxsize' => $s,
		'maxname' => $n,
		'maxpfad' => $p,
		'list' => $l,
		'dirs' => $d,
		'files' => $f));
        dbug(compact(explode(',','list,path,sort,sb,limit')),9);
       }
       else
        out("\n",8);
       if($arc and $backup and $list) {						// func:backup (Archiv erstellen)
        foreach($list as $file) {
         if($file['size'] and isset($max[$arc]['size']) and $file['size'] > $max[$arc]['size'] and $err = 1
		or isset($max[$arc]['name']) and strlen($file['path'].$file['name']) > $max[$arc]['name'] and $err = 2) {
          out(errmsg(0,--$err ? "64:Datei und Pfad ist für das Archiv zu lang" : "64:Datei ist für das Archiv zu groß"));
          $list = false;
          break;
         }
        }
        if($list and $fp = file_stream($backup,1)) {
         foreach($list as $file) {
          $name = (($file['path'] != '/') ? $file['path'] : "")."/$file[name]";
#          if($file['type'] == "directory")
#           out($name);
          if($file['size']) {
           $temp = tempnam($cfg['temp'],"$file[name]_");
           if(!$data = request("POST-save:$temp",$down,http_build_query(array('sid' => $sid, 'script' => 'api/data.lua', 'path' => $name, 'c' => 'files', 'a' => 'get'))))
            out(errmsg(0,'request'));
          }
          else
           $temp = false;
          if(!$file['size'] or $data) {
           if($file['type'] == "directory") {
            $name .= "/";
            $size = $file['size'];
           }
           else
            $size = is_array($data) ? intval($data['Content-Length']) : 0;
           if(substr($name,0,$var = strlen($path)) == $path)
            $name = substr($name,$var);
           $name = preg_replace('!^/!','',$name);
           file_stream($fp,data2tar($name,$size,$file['date']));		// TAR-Header
           if($size and $temp and file_exists($temp) and $tp = fopen($temp,'r')) {
            while($data = fread($tp,$cfg['sbuf'])) {
             file_stream($fp,$data);						// Daten
             if(!$bug and $t) {
              $a += strlen($data);
              $c = floor($a / $t * max($cfg['wrap']-1,10) -$b);
              $b += $c;
              out(str_repeat(".",$c),10);
             }
            }
            fclose($tp);
            unlink($temp);
            if($var = data2tar($size))						// TAR-FilePadding
             file_stream($fp,$var);
           }
          }
         }
         file_stream($fp,data2tar(null));					// TAR-Close
         file_stream($fp);
         if(!$bug)
          out("\n",8);
        }
        else
         out(errmsg(0,"32:Archiv konnte nicht geschrieben werden"));
       }
       elseif($list) {								// Dateiliste anzeigen oder exportieren
        $dirs = array_keys($list);						// Liste Sortieren
        if($sort) {
         natcasesort($dirs);
         if($sort[0] == '-')
          $dirs = array_reverse($dirs);
        }
        $line = "";
        $json = array();
        foreach($dirs as $key) {
         $file = $list[$key];
         if(!$find or preg_match("/$find/i",$file['name'])) 
          if($export and $sep)
           $line .= implode($sep,str_replace(array($sep,'"'),array("\\$sep",'""'),array($file['path'],$file['name'],$file['type'],$file['size'],$strftime($ftime,$file['date']))))."\n";
          elseif($js)
           $json[] = array('path' => $file['path'], 'name' => $file['name'], 'type' => $file['type'], 'size' => $file['size'], 'date' => $file['date']);
          elseif(!is_bool($file['size'])) {					// Nur Dateien von der Fileliste ausgeben
           $size = nas_calcSize($file['size']);
           $line .= "$file[path] |$file[name] | $size|".$strftime($ftime,$file['date'])."\n";
          }
        }
        if($export) {								// Dateiliste exportieren (CSV/JSON)
         if($sep) {
          if($head)
           $line = implode($sep,array('path','name','type','size','date'))."\n".$line;
         }
         elseif($js)
          $line = array2json(array('filelist' => $json));
         if(!file_contents($export,$line))
          out(errmsg(0,'file_contents'));
        }
        elseif($line)								// Consolenausgabe
         out(textTable("Pfad |Dateiname | Größe|Datum\n".out($line,9),0,"|","\n",array("|","|","|")," ")."\n\n"
		.implode(' / ',array('total: '.nas_calcSize($t), "dirs: $d", "files: $f")));
        else
         out(errmsg("8:Keine Dateien gefunden"));
       }
       else
        out(errmsg("8:Keine Dateien erhalten"));
       $bug and dbug(compact(explode(',','list,path,sort,sb,limit,find')),9);
      }
     }
     elseif($func[2] and $file = getArg('file')) {				// func:Download
      if($file[0] != '/')
       $file = "/$file";
      if(!$dir = getArg('dir','is_dir'))
       $dir = '.';
      if(!$data = request("POST-save:$dir",$down,http_build_query(array('sid' => $sid, 'script' => 'api/data.lua', 'path' => $file, 'c' => 'files', 'a' => 'get'))))
       out(errmsg(0,'request'));
     }
     else
      out(errmsg("2:Befehl konnte nicht ausgeführt werden"));
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für Fritz!NAS"));
    if(!ifset($cfg['bsid']))							// Abmelden
     logout($sid);
   }
   else
    out(errmsg(0,'login'));							// Login fehlgeschlagen
  }
  else
   out(errmsg("2:Fehler: Ungültigen Parameter übergeben!"));			// Fehlermeldung
 }
 else
  out(errmsg("64:Fehler: FritzOS zu alt!"));					// Fehlermeldung

?>
