<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "JUIS-Update 0.02 (c) 23.03.2025 by Michael Engelke";
 $info = 'JUIS Update-Prüfung für die Fritz!Box oder mit der Datei "juis_boxinfo.xml"';
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.01 01.12.2022
 - Erste Version
0.02 23.03.2025
 - BUG: Datenbank konnte nicht von MEngelke.de heruntergeladen werden
 - Anpassung an fb_Tools 0.46+

Voreinstellungen in fb_config.json:
{plugin: {

  "juis-update": {
   preset: {
    sn: "/path/.sndb.json.gz",
   }
  }

}}
*/
 function dcKey($a) {						// Decode Modellname
  if(is_array($a))
   return strtr(substr($a[0],-1),array('_' => '','l' => ' ','m' => '-','s' => '/'));
  elseif(preg_match('/^(\w)(W\d+V?|\d*)(?:(Typ)(\w))?(SL)?(Fon)?(AX|WLAN|LTE|Bridge)?(v\d)?(.+?)?(\d+)?(vDSL)?$/',$a,$m)) {
   $b = strtr($m[1],array_combine(explode(',','a,c,e,f,d,m,M,p,r,s,S,v'),
 	explode(',','Alice,Congstar,Eumex,Fritz!Box,Fritz!DECT,Fritz!Media,Fritz!Mini,Fritz!Powerline,Fritz!WLAN Repeater,Speedport,Sinus,AVM VoIP Gateway')));
   for($c=2; $c < count($m); $c++)
    if($m[$c])
     $b .= " " . $m[$c];
   return preg_replace_callback('/\s*_[lms]?/',__FUNCTION__,$b);
  }
 }
 if(ifset($cfg['help']) or !getArg(true)) {			// Hilfe Ausgeben bei -h oder ohne Parameter
  out("$plugin\n$info\n\n$splug[1] [func] <file|name> <dir> <xml>\n\n{{{tt,0,|,\n,; , }
[func:|check] |Prüft nach Updates
[func:|download] |Lädt die aktuelle Update-Datei herunter
<file:|juis_boxinfo.xml> |Entnimmt aus der Datei alle Daten zur Update-Prüfung
<name:|preset> |Die Daten zur Update-Prüfung aus der Datenbank entnehmen}}".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self $plug check
$self $plug download 7530ax -fw:7.39 -bt:inhouse
$self fritz.box $plug check -pv -rd:Debug-XML
$self $plug download file:fb7590/juis_boxinfo.xml dir:fb7590 xml:fb7590/juis_boxinfo.xml -bt:labor
$self $plug check 7312
$self $plug download name:'Fritz!Box 7590 AX' -bt:release -sn:'~/fb_tools/.sndb.json.gz'" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "JUIS-Update:|-bt:|[Kanal] |Update-Kanal ändern (normal\|release\|inhouse\|labor\|phone\|test\|plus)
|-fw:|[Version]|Firmware-Version (Nur bei Parameter 'name' wirksam)
|-pv||Privat-Modus (Keine übertragung der Seriennummer/Flags an AVM)
|-rd:|<dir>|Speichert die RAW-Daten für die Update-Abfrage
|-sn:|[File]|Speicherort der Datenbank
|-up||Aktualisert die Datenbank mit dem Internet";
 }
 elseif($arg = getArg('func','/^(?:(check)|(download))($)/i')) {// 'test'-Parameter überprüfen
  extract(array(
	'db'	=> '.sndb.json.gz',		// Default DB-Name
	'dblk'	=> '/fb_sndb.json.gz',		// URL der Datenbank
	'mage'	=> 60*60*24*1,			// Mindestalter der Datenbank
	'port'	=> 80,				// Einfache HTTP-Requests
	'host'	=> 'jws.avm.de',		// Update-Server
	'page'	=> '/Jason/UpdateInfoService',	// Update-Info-Service
	'link'	=> 'http://juis.avm.de/request',// URL für den XML-Request
	'path'	=> dirname($file),		// äquivalent zu __DIR__
	'xmlf'	=> getArg('file','file_exists'),// Alternative XML-Datei zur Updateprüfung
	'name'	=> getArg('name'),		// Presetname
	'dir'	=> getArg('dir'),		// Ausgabe-Verzechnis für Downloads festlegen
	'xml'	=> getArg('xml'),		// Aktuelle Boxinfos speichern
	'sn'	=> getArg('-sn'),		// Eigene Datenbankdatei
	'up'	=> getArg('-up'),		// Datenbank herunterladen
	'pv'	=> getArg('-pv'),		// Privatsphäre
	'raw'	=> is_dir($var = getArg('-rd')) ? preg_replace('![\\\\/]+$!','',$var)."/" : false,			// RAW-Daten Speichern
	'bt' => strtr(strtolower(getArg('-bt','/^(normal|release|labor|phone|inhouse|test|plus|100[01467]|1)$/i0')),	// Update-Kanal
		array('normal' => 1, 'release' => 1, 'inhouse' => 1000, 'labor' => 1001, 'phone' => 1004, 'test' => 1006, 'plus' => 1007))
  ),EXTR_SKIP);
  $fn = false;
  if($xmlf)
   $data = file_contents($xmlf);
  elseif($name) {								// Firmwaresuche mit der Datenbank
   $db = $sn ? $sn : "$path/$db";
   $bug and dbug("Datenbank: $db");
   $preg = '/^\{[\[\w,.:"\-\]]*\}$/';
   if(!$up)
    if(!file_exists($db) or !($data = file_contents($db)) or !ifset($data,$preg)) { // Datenbank vorhanden?
     $data = false;
     out(errmsg("8:Datenbank konnte nicht geladen werden"));
    }
   if($up and ifset($cfg['uplink']) and (!file_exists($db) or filemtime($db) + $mage < time())) { // Datenbank herrunterladen
    if(mytouch($db)) {
     $bug and dbug("Datenbank herunterladen ... ",0,2);
     foreach($cfg['uplink']['port'] as $port)
      if($sndb = request('GET-array',$dblk,0,0,$cfg['uplink']['host'],$port))
       break;
     if($sndb) {
      if((ifset($sndb['Content-MD5'],"/^(".preg_quote(base64_encode($var = hash('md5',$sndb[1],true)),'/')."|".bin2hex($var).")$/") or getArg('-f'))
	and $data = gzdecode($sndb[1]) and ifset($data,$preg)) {
       $bug and dbug("speichern ... ",0,2);						// Datenbank speichern
       if(file_contents($db,$sndb[1],0))
        $bug and dbug("ok");
       else {
        $bug and dbug("fail");
        out(errmsg("32:Datenbank konnte nicht geschrieben werden (Keine Schreibrechte?)\nDatei: $db"));
       }
       $sndb = $sndb[1];
      }
      else
       $sndb = $data = false;
     }
     else
      out(errmsg(0,'request'));
    }
    else
     out(errmsg("32:Keine Schreibrechte für die Datenbank\nDatei: $db"));
   }
   elseif($up)
    $bug and dbug(errmsg(ifset($cfg['uplink']) ? "1:Datenbank ist noch aktuell" : "8:Server deaktiviert"));
   if(ifset($data) and $sndb = json2array($data)) {					// Datenbank öffnen
    $data = false;
    $preg = '/'.preg_quote($name,'/').'/i';
    foreach($sndb as $key => $var) {
     if(preg_match($preg,$key) or preg_match($preg,dcKey($key))) {
      $pv = true;
      $fw = $cfg['fiwa'] % 100;
      $os = ($cfg['fiwa'] != 100) ? floor($cfg['fiwa'] / 100) : (($var[2] >= 200) ? 7 : (($var[2] >= 140) ? 6 : 4));
      $data = strtr('<e:BoxInfo xmlns:e="http://juis.avm.de/updateinfo" xmlns:q="http://juis.avm.de/request">
<q:Name>$keyname</q:Name>
<q:HW>$hwid</q:HW>
<q:Major>$fwid</q:Major>
<q:Minor>$os</q:Minor>
<q:Patch>$fw</q:Patch>
<q:Buildnumber>0</q:Buildnumber>
<q:Buildtype>1</q:Buildtype>
<q:Serial></q:Serial>
<q:OEM>avm</q:OEM>
<q:Lang>de</q:Lang>
<q:Country>049</q:Country>
<q:Annex>B</q:Annex>
<q:Flag></q:Flag>
<q:UpdateConfig>1</q:UpdateConfig>
<q:Provider></q:Provider>
<q:ProviderName></q:ProviderName></e:BoxInfo>',
	array('$keyname' => dcKey($key), '$fwid' => $var[1], '$hwid' => $var[2], '$os' => $os, '$fw' => $fw));
      break;
     }
    }
   }
  }
  elseif($var = request('GET-array',$fn = '/juis_boxinfo.xml') and $var['HTTP_Code'] == 200)	// Ab Fritz!OS 6.80
   $data = $var[1];
  elseif($var = request('GET-array',$fn = '/jason_boxinfo.xml') and $var['HTTP_Code'] == 200)
   $data = $var[1];
  else
   $data = false;
  if($data and $array = xml2array(preg_replace('!(?<=<|</)[ejq]:!','',$data))) {
   if($raw and $fn)
    file_contents($raw.substr($fn,1),$data);
   $juisbox = array();
   foreach($array as $key => $var) {
    if(preg_match('/^(?:(Version)|(Revision))($)/',$key,$m))
     if($m[1] and $m = ifset($var,'/^(\d+)\.(\d+)\.(\d+)(?:-\d+)?$/'))
      $juisbox += array('Major' => $m[1], 'Minor' => $m[2], 'Patch' => $m[3]);
     else#if($m[2])
      $juisbox += array('Buildnumber' => $var, 'Buildtype' => $bt ? $bt : 1);
    else
     $juisbox[$key] = $var;
   }
   if(!ifset($array['Provider']))
    $juisbox += array('Provider' => false, 'ProviderName' => false);
   if($pv) {									// Privatsphäre
    if($var = preg_match_all('/[\dA-F]{6}/',strtoupper(bin2hex(base64_decode(	// Zufällige AVM MAC-Adresse Generieren
	"AAQOABUMABpPABxKAB8/ACT+CJbXHO1vJGURLDr9LJGrNDHENIHEOBDVPDcSPKYvRE5tUOY2XEl5dEJ/fP9NmJvLnMemsPIIvAVDwCUGyA4UzM4e0BLL3BXI3Dlv4Cht6N9w8LAU"))),$avm)
	? preg_replace('/../','$0',$avm[0]) : 0)
     $juisbox['Serial'] = $var[array_rand($var)].substr(hash('sha1',serialize($_SERVER).time().rand()),-6);
    $juisbox['Provider'] = $juisbox['ProviderName'] = false;
    $juisbox['Flag'] = preg_match('/\b6[3-7]\d\d\b/',$juisbox['Name']) ? array('cable_retail') : array("");	// Cable-Boxen erkennen und Sonderflag setzen
   }
   if($bt) {									// Update-Kanal ändern
    $juisbox['Buildtype'] = $bt;
    if($xml)
     $data = preg_replace('!<(\w:Buildtype)>\d+</\1>!','<$1>'.$bt.'</$1>',$data);
   }
   $rp = array(array('/(\w+):([^;]*);?/','!(<(\w+)[^>]*)></\2>!'),array('<$1 xmlns="'.$link.'">$2</$1>','$1/>'));// Juis-Daten in XML Konvertieren
   $juis = array();
   foreach($juisbox as $key => $var)						// Juis-Daten kopieren
    if($key == "Flag")
     foreach($var as $v)
      $juis[] = "$key:$v";
    else
     $juis[] = "$key:$var";
   $data = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
	.'<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
	.'<BoxFirmwareUpdateCheck xmlns="http://juis.avm.de/updateinfo"><RequestHeader>'
	.preg_replace($rp[0],$rp[1],"Nonce:".base64_encode(hash('md5',serialize($_SERVER).time().rand(),1)).";UserAgent:Box;ManualRequest:true")
	.'</RequestHeader><BoxInfo>'.preg_replace($rp[0],$rp[1],implode(';',$juis)).'</BoxInfo></BoxFirmwareUpdateCheck></s:Body></s:Envelope>';
   if($raw)
    file_contents($raw.basename($page).'.xml',$data);
   if($info = request('POST-array',$page,$data,
	array('content-type' => 'text/xml; charset=utf-8', 'SOAPAction' => ''), $host, $port)) {
    if($var = xml2array($info[1]) and is_array($var) and $array = preg_array('/UpdateInfo$/',$var,17)) {	// Auf XML Prüfen
     if($raw)
      file_contents($raw.'BoxFirmwareUpdateCheck.xml',$info[1]);
     $array = array_combine(preg_replace('/^\w+:/','',array_keys($array)),array_values($array));		// Verschachtelungsmarker Entfernen
     if($array['Found'] == 'true') {
      out("Firmware-Update für $juisbox[Name]:\n\n{{{tt}Name:|$array[Name]\nVersion:|$array[Version]\nDownload-Link:|$array[DownloadURL]"
	.($array['InfoURL'] ? "\nInfo-Link:|$array[InfoURL]" : "").($array['InfoText'] ? "\nInfo:|$array[InfoText]" : "")."}}\n");
      if($xml and $m = ifset($array['Version'],'/^((\d+)\.(\d+)\.(\d+))(?:-(\d+))?(\b)/'))			// Aktualisierte XML-Datei speichern
       file_contents($xml,preg_replace(	array(	'!<(\w:Version)>[\d.-]+</\1>(\s*)<(\w:Revision)>[\d.-]+</\3>!',	// XML-Datei aktualisieren
						'!<(\w:Major)>\d+</\1>(\s*)<(\w:Minor)>\d+</\3>\s*<(\w:Patch)>\d+</\4>\s*<(\w:Buildnumber)>\d+</\5>!'),
					array(	'<$1>'.$m[1].'</$1>$2<$3>'.$m[5].'</$3>',
						'<$1>'.$m[2].'</$1>$2<$3>'.$m[3].'</$3>$2<$4>'.$m[4].'</$4>$2<$5>'.$m[5].'</$5>'),$data));
      if($arg[2] and $array['DownloadURL']) {					// Download der Firmware
       $links = array($array['DownloadURL']);
       if($array['InfoURL'])
        $links[] = $array['InfoURL'];
       $err = 0;
       if($dir) {								// Download-Verzeichnis vorbereiten
        if(!file_exists($dir))
         makedir($dir);
        elseif(is_dir($dir))
         chdir($dir);
       }
       foreach($links as $link) {
        if(!request(array('method' => "GET-save:./") + request("$link#"))) {
         $err++;
         break;
        }
       }
       out(!$err ? "Download war erfolgreich" : errmsg(0,'request'));
      }
     }
     else
      out(errmsg("1:Keine Firmware-Updates für '$juisbox[Name]' gefunden"));
    }
    else
     out(errmsg("16:Daten lassen sich nicht verarbeiten"));
   }
   else
    out(errmsg(0,'request'));
  }
  else
   out(errmsg("8:Keine Firmware-Daten erhalten"));
 }
 else										// 'test'-Parameter fehlt
  out(errmsg("2:Keine oder Unbekannte Parameter übergeben"));			// Fehlermeldung

?>
