<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "Serial 0.06 (c) 24.03.2026 by Michael Engelke";
 $info = 'Entschlüsselt die Serienummer mit einer Datenbank';
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.01 01.12.2022
 - Erste Version
0.02 05.05.2024
 - Hilfe verbessert
0.03 08.10.2024
 - Datenbank wurde nicht von mengelke.de akzeptiert (Danke an Wolfgang N.)
 - Anpassung an fb_Tools 0.41+
0.04 04.11.2024
 - Hilfe verbessert
0.05 23.03.2025
 - Anpassung an fb_Tools 0.46+
0.06
 - Key2Name-Konverter zu der aktuellen Datenbank angepasst

Voreinstellungen in fb_config.json:
{plugin: {

  serial: {
   preset: {
    sn: "/path/.sndb.json.gz",
   }
  }

}}
*/
 function dcKey($a) {							// Decode Modellname
  if(is_array($a))
   return strtr(substr($a[0],-1),array('_' => ' ', 'g' => '', 'l' => ' ', 'm' => '-', 's' => '/'));
  elseif(preg_match('/^(\w)(W\d+V?|\d*(?:_?E(?!WE))?)(SL)?(Fon)?(AX|WLAN|LTE|_?[45]G|Bridge)?(v\d)?(?:(Typ)(\w))?(.+?)?(\d+)?(vDSL)?$/',$a,$m)) {
   $b = strtr($m[1],array(
	'a' => 'Alice',
	'b' => 'BlueFRITZ!',
	'c' => 'Congstar',
	'e' => 'Eumex',
	'f' => 'FRITZ!Box',
	'd' => 'FRITZ!DECT',
	'm' => 'FRITZ!Media',
	'M' => 'FRITZ!Mini',
	'p' => 'FRITZ!Powerline',
	'r' => 'FRITZ!WLAN Repeater',
	's' => 'Speedport',
	'S' => 'Sinus',
	'g' => 'FRITZ!Smart Gateway',
	'v' => 'AVM VoIP Gateway'));
   for($c=2; $c < count($m); $c++)
    if($m[$c])
     $b .= " ".$m[$c];
   return preg_replace_callback('/\s*_[glms]?/',__FUNCTION__,$b);
  }
 }
 if(ifset($cfg['help']) or !getArg(true)) {				// Hilfe Ausgeben
  out("$plugin\n$info\n\n$splug[1] [func|file|serial|version]\n\n{{{tt,0,|,\n,; , }
[serial:|FB-Serial] |Direktangabe der Seriennummer (A123.456.78.901.234)
[func:|import] |Die Seriennummer aus der Fritz!Box importieren
[file:|FRITZ!Box.assets.zip] |Die Seriennummer aus der Backupdatei auslesen
[version:|FB-Firmware] |Direktangabe der Versionsnummer der Firmware (123.04.56)}}".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self $plug serial:A123.456
$self $plug S011
$self $cfg[fbhp] $plug import -up
$self $plug file:FRITZ.Box.assets.zip
$self $plug version:147.07.29
$self $plug 5" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "Serial:|-sn:|[File]|Speicherort der SNDB
|-rd:|<dir>|Speichert die RAW-Daten aus der Fritz!Box
|-up||Aktualisert die Datenbank mit dem Internet";
 }
 else {
  extract(array(
	'db'	=> '.sndb.json.gz',	// Default DB-Name
	'rd'	=> getArg('-rd'),	// RAW-Daten Speichern
	'sn'	=> getArg('-sn'),	// Eigene Datenbankdatei
	'up'	=> getArg('-up'),	// Datenbank herunterladen
	'path'	=> dirname($file),	// äquivalent zu __DIR__
	'mage'	=> 60*60*24*1,		// Mindestalter der Datenbank
  ),EXTR_SKIP);
  $bug and dbug(compact(explode(',','db,rd,sn,up,path,mage')),3);
  $sd = $out = "";
  $json = $err = array();
  if(!($sno = getArg('serial',$preg = '/\b([A-FHJ-NPR-Y])(0[1-9]|[1-4]\d|5[0-3])([1-7])(?:\.?(\d{3}))?(?:\.?(?:(\w{2})\.?(\d{3})\.?(\d{3})))?(\b|$)/'))) {
   if($func = getArg('func','/\bimport\b/i'))
    if($sid = (ifset($cfg['bsid'])) ? $cfg['bsid'] : login()) {		// Login durchführen
     if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
      $bug and dbug("Exportiere Konfig");
      if(!($zip = request('POST','/cgi-bin/firmwarecfg',array('sid' => $sid, 'AssetsImportExportPassword' => false, 'AssetsExport' => false))))
       $err[] = "16:Kein Backup erhalten";
     }
     else
      $err[] = "8:Benutzer hat nicht das Recht für die Administration";
     if($zip and $rd) {							// RAW-Daten Speichern
      if(!is_bool($rd))
       if(!file_exists($rd))
        makedir($rd);
       elseif(is_dir($rd))
        chdir($rd);
      $name = ifset($cfg['http']['Content-Disposition'],'/filename="(.*?)"/1') or $name = "FRITZ.Box.assets.zip";
      file_contents($name,$cfg['body']);
     }
     if(!ifset($cfg['bsid']))						// Abmelden
      logout($sid);
    }
    else
     $err[] = errmsg(0,'login');					// Login fehlgeschlagen
   elseif($file = getArg('file','file_exists'))
    $zip = file_contents($file);
   if(ifset($zip) and $data = zip2array($zip) and $json = json2array($data['meta.json']['data']))
    if($sno = ifset($json['box_info']['serial'],$preg))
     $sno['name'] = $json['box_info']['product_name'];
    else
     $err[] = "16:Keine Serienummer erhalten";
    $fw = ifset($cfg['boxinfo']['Version'],'/^[\d.-]+$/0');
  }
  if($preg = '/^(\d+)(\.\d+\.\d+(-\d+)?)?$/' and $fw = ifset($fw,$preg) or $fw = getArg('version',$preg) or ifset($sno)) {
   if(!$sn)
    $sn = "$path/$db";
   $bug and dbug("Datenbank: $sn");
   $preg = '/^\{[\[\w,.:"\-\]]*\}$/';
   if(file_exists($sn) and $data = file_contents($sn) and ifset($data,$preg)) {
    if($sno and !preg_match("/\b(\w+)\s*:\s*\[\d+,\d+\b[^\[\]]*?$sno[4][^\[\]]*?\]/",$data,$var)) // Schnelltest
     if(ifset($sno['name']))
      $sd = "?$sno[4]=".urlencode($sno['name']);
   }
   else
    $data = false;
   if($up and ifset($cfg['uplink']) and (!file_exists($sn) or filemtime($sn) + $mage < time())) { // Datenbank herrunterladen
    if(mytouch($sn)) {							// Schreibrechte prüfen
     $bug and dbug("Datenbank herunterladen ... ",0,2);
     foreach($cfg['uplink']['port'] as $port)
      if($sndb = request('GET-array',"/fb_sndb.json.gz$sd",0,0,$cfg['uplink']['host'],$port))
       break;
     if($sndb) {
      if((ifset($sndb['Content-MD5'],"/^(".preg_quote(base64_encode($var = hash('md5',$sndb[1],true)),'/')."|".bin2hex($var).")$/") or getArg('-f'))
	and $data = gzdecode($sndb[1]) and ifset($data,$preg)) {
       $bug and dbug("speichern ... ",0,2);					// Datenbank speichern
       if(file_contents($sn,$sndb[1],0))
        $bug and dbug("ok");
       else {
        $bug and dbug("fail");
        $err[] = "32:Datenbank konnte nicht geschrieben werden (Keine Schreibrechte?)\nDatei: $sn";
       }
       $sndb = $sndb[1];
      }
      else {
       $err[] = "16:Fehlerhafte Daten erhalten";
       $sndb = false;
      }
     }
     else
      $err[] = errmsg(0,'request');
    }
    else
     out(errmsg("32:Keine Schreibrechte für die Datenbank\nDatei: $sn"));
   }
   elseif($up)
    $bug and dbug(errmsg(ifset($cfg['uplink']) ? "1:Datenbank ist noch aktuell" : "8:Server deaktiviert"));
   if($data and $sndb = json2array($data)) {				// Datenbank öffnen
    $idx = $id = false;
    if($sno) {								// Modus: Serienummer
     $id = intval($sno[4]);
     $max = array(0,0);
     foreach($sndb as $key => $var) {					// Datenbank durchgehen
      $hwid = array_slice($var,3);
      if(array_search($id,$hwid) !== false) {				// Hardware direkt suchen
       $idx = $key;
       break;
      }
      else {
       foreach($hwid as $hw)						// Alternativ das nächst älteste Gerät suchen
        if($hw <= $id and $max[0] < $hw)
         $max = array($hw,intval($var[0] / 100),$key);
      }
     }
     if($idx) {								// Jahr aus der Datenbank anpassen
      $jahr = $year = intval($sndb[$idx][0] / 100) + 2e3;
      $month = $sndb[$idx][0] % 100;
      $name = dcKey($idx);
     }
     elseif($id) {
      $jahr = $year = $max[1] + 2e3;
      $month = false;
      $err[] = "Keinen Eintrag für Hardware-ID $id gefunden".($up ? "" : " (ggf nochmal mit Option -up probieren)");
     }
     else
      $jahr = $year = 0;
     $din = $year - ($year % 20 + 10) % 20;				// Markteinführung auf (DIN EN 600626) ohne Offset herunterrechnen
     $set = strpos("ABCDEFHJKLMNPRSTUVWXY",strtoupper($sno[1])) % 20;	// Den Offset für das Jahr holen
     $year = $year ? (($year - 2 < $din + $set) ? $din : $din + 20) : 1990 + ($set < 14 ? 20 : 0);	// Das Jahr berechnen
     $time = strtotime(($year + $set)."-1-4");								// Wochentag bestimmen
     $time = $time - (date("w",$time) + 6) % 7 * 864e2 + ((($sno[2] | 0) -1) * 7 + ($sno[3] | 0) - 1) * 864e2;
    }
    elseif($fw) {							// Modus: Firmware-Version
     foreach($sndb as $key => $var)
      if($var[1] == $fw[1]) {
       $idx = $key;
       $jahr = $year = intval($sndb[$idx][0] / 100) + 2e3;
       $month = $sndb[$idx][0] % 100;
       $id = array_slice($sndb[$idx],3);
       break;
      }
     if(!$idx)
      $err[] = "Keinen Eintrag für die Firmware-Version $fw[1].xx.yy gefunden".($up ? "" : " (ggf nochmal mit der Option -up probieren)");
    }
    if($idx or $id)							// Ausgabe
     $out .= "Modell:|".($idx ? dcKey($idx) : "Unbekannt ($id)")."\n";
    if($idx and $sndb[$idx][1])
     $out .= "Firmware:|".$sndb[$idx][1].(ifset($fw[2]) ? $fw[2] : ".xx.yy")."\n";
    if(ifset($jahr))
     $out .= "Markteinführung:|".($month ? $strftime('%B %Y',"$jahr-$month-1") : $jahr).($month === false ? " (vermutlich)" : "")."\n";
    if(ifset($time))
     $out .= "Baudatum:|".$strftime('%A, %-d. %B %Y',$time).(date('Y',$time) < $jahr ? " (Die Daten können nicht stimmen)" : "")."\n";
    if($sno and $sno[5])
     $out .= "Typ:|$sno[5]\n";
    if($sno and $sno[6] and $sno[7])
     $out .= "Serienummer:|$sno[6]$sno[7]\n";
    if($idx and $sndb[$idx][2])
     $out .= "Hardware-ID:|{$sndb[$idx][2]}\n";
    if($id and is_array($id))
     $out .= "Serien-ID:|".implode(", ",$id)."\n";
    if($sno)
     out(substr($sno[0],0,4).($sno[4] ? ".".implode('.',preg_array('/^\w+$/',preg_array('/^[4-7]+$/',$sno,3),2)) : "")."\n\n");	// Seriennummer ausgeben
    if($out) {								// Tabelle ausgeben
     out("{{{tt}$out}}");
     if($err)								// Leerzeile für Fehler einfügen
      out("\n");
    }
   }
   else
    $err[] = "8:Keine Datenbank gefunden".($up ? "" : " (Bitte nochmal mit Option -up aufrufen)");
  }
  else
   $err[] = "2:Ungültige Parameter erhalten";
  foreach($err as $var)							// Fehler/Mitteilungen gesammelt ausgeben
   if($k = ifset($var,'/^(?:(\d+):)?(.*?)$/'))
    out($k[1] ? errmsg($k[0]) : $k[2]);
 }

?>
