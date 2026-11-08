::#!/usr/bin/php
@set 0=%0&set 1=%~f0&set 2=%cd%&::%~d0:cd %~p0
@if exist ext set phpext=ext
@if exist php.exe set php=php
@if exist php.ini set phpopt=-cphp.ini
@if "%php%"=="" set php=php
@if "%phpopt%"=="" set phpopt=-dextension_dir=./%phpext%
@"%php%" "%phpopt%" -r"eval(preg_replace('/^[@:].*$(?=\C*<\?)|^<\?\w*|^\?>\s*$/m','',file_get_contents($_SERVER['argv'][0]=$argv[0]=getenv(1))));if(strchr(getenv(0),chr(34))and!strpos(getenv('PSModulePath'),getenv('USERNAME')))passthru('pause');" -- %*&goto:eof
<?php # {charset:"iso-8859-1", tabs:8, lines:"cr+lf", lang=de}
/*	This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. */
if($ver = "fb_tools 0.48 (c) GPL 10.10.2026 by Michael Engelke <https://mengelke.de/.dg>") {
 if(!(isset($cfg) and is_array($cfg)))	// Testen ob $cfg existiert und ein array ist
  $cfg = array();			// Config-Variable anlegen
 foreach(array(				// Vorkonfiguration einzeln durchgehen
	'sock'	=> 'auto',		// -p	Socket: http, https, ssl, tls
	'host'	=> 'fritz.box',		// -fb	Fritz!Box-Addresse
	'pass'	=> 'password',		// -pw	Fritz!Box Kennwort
	'uipw'	=> false,		// -ui	Fritz!Box Anmeldekennwort (F!OS 4/5) oder ab F!OS 6: 2FA
	'user'	=> false,		// -un	Fritz!Box Username (Optional)
	'totp'	=> false,		// -tf	Zweite-Faktor-Authentifizierung (2FA)
	'fbhp'	=> 'Fritz.Box',		//	Fritz!Box-Angabe
	'fbnp'	=> 1,			//	Welcher Parameter die Fritz!Box angabe enthält
	'port'	=> 80,			// -pt	Fritz!Box HTTP-Port (Normalerweise immer 80)
	'fiwa'	=> 1e2,			// -fw	Fritz!Box Firmware (Nur Intern)
	'livs'	=> 0,			// -li	Login-Version (0 -> Auto, 1 -> MD5, 2 => PBKDF2)
	'upnp'	=> array(49e3,49443),	// -u	Fritz!Box UPnP-Port (Normalerweise immer 49000)
	'jsdp'	=> 512,			//	Maximale Verschachtelung beim parsen von JSON-Daten
	'sbuf'	=> 4096,		// -b	TCP/IP Socket-Buffergröße oder file-Buffer
	'tout'	=> 30,			// -t	TCP/IP Socket-Timeout
	'pcre'	=> 64*1<<20,		//	pcre.backtrack_limit (RegEx)
	'meli'	=> 128*1<<20,		//	Memory Limit
	'upda'	=> 60*60*24*100,	// -nu	Auto-Update-Check Periode (Kein Update-Check: 0)
	'uptp'	=> 60*60*24,		//	Auto-Update-Check Touch-Periode
	'json'	=> 0,			// -oj	Nutze json_(en/de)code (0: never, 1:try, 2:force)
	'wrap'	=> 'auto',		// -w	Manueller Wortumbruch (Kein Umbruch: 0)
	'char'	=> 'auto',		// -c	Zeichenkodierung der Console (auto/ansi/oem/utf8)
	'dbfn'	=> 'debug#.txt',	//	Template für Debug-Dateien
	'zone'	=> 'Europe/Berlin',	//	Zeitzone festlegen
	'fstr'	=> '%d.%m.%Y %H:%M:%S',	//	%c Lokales Datum & Zeitformat
	'flog'	=> '%Y-%m-%d %H:%M:%S',	//	%F %X Logzeit-Format
	'fstd'	=> '%d.%m.%Y',		//	%x Lokales Datumsformat
	'fstt'	=> '%H:%M:%S',		//	%X Lokales Zeitformat
	'slct'	=> 'de_DE',		//	Locales Datumsformat nach Land festlegen
	'fesc'	=> '|<>?*+"/\\:',	//	Illegale Dateizeichen
	'frep'	=> '_',			//	Ersetzungszeichen für Illegale Dateizeichen
	'fbtg'	=> 'fbtp_*.php',	//	Plugin Glob-Pattern
	'fbtm'	=> 'fbtp_([\w-]+)\.php',//	Plugin Preg_Match-Pattern
	'fbtp'	=> 'plugins',		//	Plugin-Pfad
	'libs'	=> 'libs',		//	PHP-Bibliotheken
	'argn'	=> '\w+:\/\/|\w:|[\da-f]{2}:',#	Args-Filter (Wird nur im Hauptscript beachtet)
	'load'	=> '_%s.tmp',		//	Temporärer Download-Namenserweiterung (strftime)
	'coki'	=> true,		// -nc	Cookies anzeigen
	'help'	=> false,		// -h	Hilfe ausgeben
	'dbug'	=> false,		// -d	Debuginfos ausgeben
	'oput'	=> false,		// -o	Ausgaben speichern
	'cron'	=> false,		// -cm	Cron oder Sicherheits-Modus
	'zlib'	=> array('mode' => -1),	// -gz	ZLib-Funktionen (mode: packlevel)
	'drag'	=> array('*'=> 'i h *'),//	Drag'n'Drop-Modus
	'error'	=> array(),		//	Fehler Pool Defininieren
	'proxy'	=> false,		// -px	HTTP-Proxy ohne Authentifizierung (proxy.tld:port)
	'uport'	=> array(443,80),	//	Ports für die Update-Verbindung
	'touch'	=> ".touch",		//	Workaround, wenn fb_Tools nicht schreiben kann/darf
	'usrcfg'=> 'fb_config',		// -uc	Name der Benutzerkonfiguration
	'usrsys'=> '/^(root|systemd?)$/i',//	Systemuser die häufig für Crondienste benutzt werden
	'usrfmt'=> array('json','php'),	//	Weitere Unterstützte Formate für die User-Konfig
	'cfgall'=> false,		//	Nur die erste Konfig-Datei laden oder ALLE laden
	'gz'	=> 9,			// -gz	ZIP Deflate Pack Level
 ) as $key => $var)
  if(!isset($cfg[$key]))		//	Existiert die Variable schon
   $cfg[$key] = $var;			//	Wenn nicht - dann anlegen
 $strftime = 'str_ftime';		// -ot	Datumfunktion festlegen
 $bug = $cfg['dbug'];			// -d	Verhindern dass Debug-Meldungen generiert werden
}
if(!function_exists('array_combine')) {			// http://php.net/array_combine [PurePHP]
 function array_combine($key,$val,$out=array()) {
  if(count($key = array_values($key)) == count($val = array_values($val)))
   foreach($val as $k => $v)
    $out[$key[$k]] = $v;
  return $out ? $out : false;
 }
}
if(!function_exists('gzdecode')) {			// http://php.net/gzdecode (Workaround & PurePHP)
 function gzdecode($data,$len=0,$out='') {
  global $cfg;
  if(preg_match('/^\x1f\x8b\x08([\x00-\x1f])[\x00-\xff]{4}\x02[\x00-\xff]([\x00-\xff]+)([\x00-\xff]{4})([\x00-\xff]{4})$/s',$data,$gz)) {
   $flag = ord($gz[1]);						// Flags lesen
   $tmp = $gz[2];
   while($flag >>= 1)						// Extra-Header überspringen
    $tmp = substr($gz[2],strpos($gzip[2],"\0")+1);
   $tmp = gzinflate($tmp);					// Deflate-Daten entpacken
   if(strlen($tmp) == hexdec(bin2hex(strrev($gz[4]))) and hash('crc32b',$tmp,1) == strrev($gz[3]))	// Alles Prüfen (Länge & CRC32)
    if($len)
     $out = substr($data,0,$len);
  }
  if(!$out and $fp = fopen($tmp = tempnam($cfg['temp'],'gz'),'w')) {// Gepackte Daten speichern
   fwrite($fp,$data);
   fclose($fp);
   if($fp = $cfg['zlib']['open']($tmp,'rb')) {			// Daten entpackt lesen
    while(!$cfg['zlib']['eof']($fp))
     $out .= $cfg['zlib']['read']($fp,$cfg['sbuf']);
    $cfg['zlib']['close']($fp);
    if($len)
     $out = substr($out,0,$len);
   }
   @unlink($tmp);						// Überreste löschen
  }
  return $out;
 }
}
if(!function_exists('hash')) {				// http://php.net/hash (Workaround für crc32b, md5, sha1 und optional sha256 [PurePHP])
 function hash($algo,$data,$raw=false) {
  return ($algo == 'sha256' and function_exists('mhash') and $a = mhash(MHASH_SHA256,$data)) ? ($raw ? $a : bin2hex($a))
	: ((preg_match('/^(md5|sha\d+)$/',$algo) and function_exists($algo) and $a = $algo($data) or $algo == 'crc32b' and $a = sprintf('%08x',crc32($data))) ? ($raw ? pack("H*",$a) : $a) : false);
 }
}
if(!function_exists('http_build_query')) {		// http://php.net/http_build_query [PurePHP]
 function http_build_query($array,$pre=null,$sep=null,$mode=1) {
  if(!$sep and !$sep = ini_get("arg_separator.output"))	// Separator festlegen
   $sep = '&';
  $enc = (($mode == 2) ? 'raw' : '').'urlencode';	// Funktion bestimmen
  $out = array();
  foreach($array as $key => $var)
   $out[] = call_user_func($enc,($pre and is_numeric($key)) ? $pre.$key : $key)."=".call_user_func($enc,$var);
  return implode($sep,$out);
 }
}
if(!function_exists('strftime')) {			// http://php.net/strftime
 function strftime($data,$time=false) {
  return str_ftime($data,$time);
 }
}
function char($a) {					// Erstellt einfache Zeichenfolgen [PurePHP]
 if(is_array($a))
  for($c = "", $b=ord($a[2]), $a=ord($a[1]); $a <= $b; $c .= chr($a++));
 else
  $c = preg_replace_callback('/(\w)-?(\w)/',__FUNCTION__,$a);
 return $c;
}
function str_ftime($data,$time=false,$mic=0,$last=0) {	// Ersatz für strftime [PurePHP - Nicht ganz]
 global $cfg;
 if(is_int($data)) {
  for($c = count($time), $b = explode(',',"Sagittarius,Capricorn,Aquarius,Pisces,Aries,Taurus,Gemini,Cancer,Leo,Virgo,Libra,Scorpio,Ophiuchus"), $a = 0; 0 <= ($data -= $time[$a]);$a++);
  return $b[($c % 14 + $a) % --$c];
 }
 elseif(is_string($time)) {
  if(preg_match('/^\d+(?:\.(\d+))?($)/',$time,$m)) {	// Prüfen ob Int oder Float als String übergeben würde
   if($m[1] !== '')
    $mic = intval($m[1]) * 1e3;
   $time = intval($time);
  }
  else
   $time = strtotime($time);
 }
 if(!$time)
  $time = time();
 elseif(is_float($time)) {
  $mic = floor(($time - floor($time)) * 1e3);
  $time = intval($time);
 }
 $fn = __FUNCTION__;
 if(preg_match_all('/(\w)(\w(?=\w)|\w.*?(?=;|$))/',"AlBFHHIhMiPaSsVWYYaDbMddmmpAsUyyzOKBDm/d/y;FY-m-d;RH:i;TH:i:s;rh:i:s A;Oj.n.Y, H:i:s;qj.n.Y;QH:i:s",$m))
  $c = array_combine($m[1],$m[2]);
 while(preg_match('/%(!?)(-?)(?:([!+#^])|([0_.]?)([1-9]?))([a-z]|%)/i',substr($data,$last),$m,PREG_OFFSET_CAPTURE) and $a = $m[6][0]) {
  $new = $m[1][0] ? date($m[6][0],$time)			// Date anstelle von strftime
	: (isset($c[$a]) ? date($c[$a],$time)			// Entsprechende Date-Formate
	: (($a == 'f') ? substr("00".$mic,-3)			// Microtime
	: (($a == 'C') ? floor(date('Y',$time) / 1e2)		// Jahrtausend
	: (($a == 'Z') ? date($m[2][0] ? 'e' : 'T',$time)	// Name der Zeitzone
	: (($a == 'w') ? ($m[2][0] ? date('I',$time) : date('w',$time))	// Wochentag 0-6
 	: (($a == 'u') ? ($m[2][0] ? date('L',$time) : (($b = date('w',$time)) ? $b : 7))	// Wochentag 1-7
	: (($a == 'v') ? ($m[2][0] ? preg_replace('/..$/',':$0',date('O',$time)) : date('Z',$time))		// Zeitzone und in Sekunden
	: (($a == 'J') ? ($m[2][0] ? call_user_func($fn,'%Y-%m-%dT%H:%M:%S%-v',$time) : date('r',$time))// ISO-RFC* Datum
	: (($a == 'E') ? (date('U',$time) + date('Z',$time)) % 864e2						// Sekunden des Tages*
	: (($a == 'j') ? ($m[2][0] ? date('z',$time) : substr("00".(date('z',$time) + 1),-3))			// Tage vom Jahr vergangen
	: (($a == 'G' or $a == 'g') ? date(strtr($a,'Gg','Yy'),$time + (3-((date('w',$time) + 6 ) % 7)) * 864e2)// Jahr nach ISO-8601
	: (($e = strpos(' ekl',$a)) ? substr(" ".date(substr(" jGg",$e,1),$time),-2)				// Tag des Monats & Stunde (24/12) mit Leerzeichen
	: (($a == 'h') ? ($m[2][0] ? date('d',strtotime(date('Y',$time).'-'.(date('m',$time)+1)."-0")) : date('M',$time))	// Tage im Monat | Monate
	: (($a == 'U') ? substr("0".floor((date('z',$time) + (($b = date('w',strtotime(date('Y',$time)."-01-01"))) ? $b : 7)) / 7),-2)	// Kalenderwoche (Sonntag)
 	: (($a == 'W') ? substr("0".floor((date('z',$time) + (($d = (($b = date('w',strtotime(date('Y',$time)."-01-01"))) ? $b : 7) - 1 % 7) ? $d : 7)) / 7),-2)// Kalenderwoche (Montag)
	: (($a == 'o') ? ($m[2][0] ? (($y = date('Y',$time) and $b = floor(1 + $y / 1e2) and $d = $y % 19 + 1 and $e = floor(3 * $b / 4) - 12
		and $f = (11 * $d + 20 + floor((8 * $b + 5 ) / 25) - 5 -$e) % 30 and $f = 44 - $f - ($f == 25 and $d > 11 or $f == 24 | 0)
		and $f += ($f < 21 | 0) * 30) ? date('z',strtotime("$y-03-00 +".($f + 7 - (floor(5 * $y / 4) - $e - 10 + $f) % 7)." days")) + 1 : 0)	// Tage im Jahr bis Ostern
		: (($d = array("th","st","nd","rd") and $e = date('d',$time)) ? $d[(($f = substr("$e",-1)) > 3 or substr("$e",-2,-1) == 1) ? 0 : $f] : 0))
	: (strpos("-cXx",$a) ? ($m[2][0] ? date(strtr($a,array('c' => 'D M j H:i:s Y', 'X' => 'H:i:s', 'x' => 'm/d/y'))) : call_user_func($fn,$cfg['fst'.strtr($a,"cXx","rtd")],$time))
	: (($e = strpos(' LN',$a)) ? call_user_func($fn,call_user_func($fn,"%-j",$time) % 366,// Sternzeichen (https://ui.adsabs.harvard.edu/abs/2010JRASC.104..103T/abstract)
		--$e ? array(20,27,24 + date('L',$time),38,25,39,29,21,37,45,23,6,18,13) : array(20,30,29 + date('L',$time),31,31,31,32,31,31,30,30,29,10))
	: preg_replace('/^%\w$/','',strtr($m[0][0],array("%n" => "\n", "%t" => "\t", "%-n" => "\n", "%-t" => "\t", "%%" => "%")))))))))))))))))))));
  if(preg_match('/^[a-z]$/i',$new))
   $new = "";
  elseif(!$m[2][0] and strpos("-abABLN",$a))
    $new = strtr($new,json2array('{Tue:Die,Wed:Mit,Thu:Don,Fri:Fre,Sat:Sam,Sun:Son,Mar:"Mär",May:Mai,Oct:Okt,Dec:Dez,Monday:Montag,Tuesday:Dienstag,Wednesday:Mittwoch,Thursday:Donnerstag,
	Friday:Freitag,Saturday:Samstag,Sunday:Sonntag,January:Januar,February:Februar,March:"März",May:Mai,June:Juni,July:Juli,October:Oktober,December:Dezember,Sagittarius:"Schütze",
	Capricorn:Steinbock,Aquarius:Wassermann,Pisces:Fische,Aries:Widder,Taurus:Stier,Gemini:Zwillinge,Cancer:Krebs,Leo:"Löwe",Virgo:Jungfrau,Libra:Waage,Scorpio:Skorpion,Ophiuchus:"Schlangenträger"}'));
  elseif($m[2][0])
   $new = preg_replace('/^([+-]?)[0\s]*(\d+?)$/','$1$2',$new);
  $new = ($m[3][0] and $b = strpos('-+#^',$m[3][0])) ? ((!--$b) ? preg_replace('/^\d+$/','+$0',$new) : ((!--$b) ? strtolower($new) : ((!--$b) ? strtoupper($new) : $new)))
	: ((($m[4][0].$m[5][0]) and preg_match('/^([. 0]*)(.+)$/s',$new,$b)) ? str_pad($b[2],$m[5][0]
	? $m[5][0] : strlen($new),strtr(($m[4][0] != "") ? $m[4][0] : (($b[1] != "") ? $b[1] : "0"),"_"," "),STR_PAD_LEFT) : $new);
  $data = substr_replace($data,$new,$last + $m[0][1],strlen($m[0][0]));	// Replace durchführen
  $last += strlen("$new") + $m[0][1];					// Offset anpassen
 }
 return ($data !== "") ? (preg_match('/^(?!0\d)\d+$/',$data) ? intval($data) : $data) : false;
}
function glob_brace($pat,$flags=0) {			// Ersatz für Glob mit GLOB_BRACE [PurePHP]
 if(($brace = defined('GLOB_BRACE') ? constant('GLOB_BRACE') : 0) or !preg_match('/\{.*\}/',$pat))	// glob Testen
  $out = glob($pat,$flags | $brace);	// Glob normal ausführen
 if(!isset($out) or !$out) {
  $pat = array($pat);			// Pattern in ein Array imwandeln
  $flags &= ~$brace;			// GLOB_BRACE aus den Flags entfernen
  $len = 0;
  while(($var = count($pat)) != $len) {	// Weitermachen, wenn neue Einträge dazugekommen sind
   $len = $var;
   foreach($pat as $key => $var)
    if(preg_match('/^.*?\{([^{}]*?)\}.*$/',$var,$m,PREG_OFFSET_CAPTURE)) {	// Nach Brace suchen
     unset($pat[$key]);
     $n = ($flags & GLOB_NOESCAPE) ? explode(',',$m[1][0]) : preg_split('/(?<!\\\\),/',$m[1][0]);	// Brace zerteilen
     foreach($n as $name)
      $pat[] = substr_replace($var,$name,$m[1][1]-1,strlen($m[1][0])+2);	// Brace-Eintrag im Array hinzufügen
    }
  }
  $out = array();
  foreach($pat as $var)				// Die Glob-liste durchgehen
   $out = array_merge($out,glob($var,$flags));	// Ergebnisse hinten dranhängen
  if(!($flags & GLOB_NOSORT))			// Prüfen ob eine nachträgliche Sortierung erwünscht ist
   sort($out);
 }
 return $out;
}
function utf8($str,$mode=0) {				// UTF-8 Tool mode: Bit0 -> 0:decode 1:encode | Bit1 -> Escape decode [PurePHP]
 $fn = __FUNCTION__;
 if(is_array($str) and (isset($str[0]) and count($str) == 1 or preg_array('/[deuhx]|u[0-3]/',$str,5))) {
  if(isset($str['u0'])) {						// Entwertete Zeichen in UTF8 umwandeln
   if(($a = $str['u0']) != "" or ($a = ifset($str['u3'],"")) != "" or ($a = ifset($str['x'],"")) != "")	// hex -> Int
    $a = hexdec($a);
   elseif($a = ifset($str['u1'],"") and $b = ifset($str['u2'],""))		// hex 20 Bit -> Int
    $a = (hexdec($a) & 1023) * 1024 + (hexdec($b) & 1023) + 65536;
   elseif($a = ifset($str['h'],""))					// Dec -> Int
    $a = intval($a);
   else									// Fehler
    $a = false;
  }
  else
   $a = $str[0];
  if(isset($str['e']) or is_int($a)) {	// Ansi -> UTF8
   if(($a = is_int($a) ? $a : ord($a)) < 128)
    return chr($a);
   $b = "";
   $c = 6;
   while($a >= 1 << $c and --$c) {
    $b = chr($a & 63 | 128).$b;
    $a >>= 6;
   }
   return chr((1 << 7 - $c) -1 << ++$c | $a).$b;
  }
  elseif(isset($str['d'])) {		// UTF8 -> Ansi
   for($b = ord($a[0]) % (1 << 7 - strlen($a)), $c = 1; $c < strlen($a); $c++)
    $b = $b * 64 + (ord($a[$c]) & 63);
   return ($b < 256) ? chr($b) : "\\u".(($b < 65536) ? str_pad(dechex($b),4,0,STR_PAD_LEFT)
	: str_pad(dechex(($b - 65536) >> 10 | 55296),4,0,STR_PAD_LEFT)."\\u".str_pad(dechex(($b - 65536) & 1023 | 56320),4,0,STR_PAD_LEFT));
  }
  return $a;
 }
 elseif(is_array($str)) {		// Array -> utf8[mode]
  foreach($str as $key => $var)
   if(is_string($var) or is_array($var))
    $str[$key] = call_user_func($fn,$var,$mode);
 }
 else {
  $p = "[\x80-\xbf]";
  $p = "[\xc0-\xdf]$p|[\xe0-\xef]$p{2}|[\xf0-\xf7]$p{3}|[\xf8-\xfb]$p{4}|[\xfc-\xfd]$p{5}|\xfe$p{6}";
  $p = "/".(($mode & 1) ? "(?P<u>$p)|(?P<e>[\x80-\xff])".(($mode & 2)
	? '|\\\\(?:u\{(?P<u0>[\da-f]+)\}|(?:u(?P<u1>[dD][89abAB][\da-fA-F]{2})\\\\u(?P<u2>[dD][c-fC-F][\da-fA-F]{2}))|u(?P<u3>[\da-fA-F]{4}))|(?:&\#(?:(?P<h>\d+)|x(?P<x>[\da-fA-F]+));)'
	: '') : "(?P<d>$p)")."/";
  if((float)phpversion() > 5.2)
   return preg_replace_callback($p,$fn,$str);
  elseif(preg_match_all($p,$str,$match,PREG_OFFSET_CAPTURE)) {	// Workaround PHP 4.3 - 5.2
   for($a=count($match[0])-1; $a >= 0; $a--) {
    $var = array($match[0][$a][0]);
    $var[(isset($match['e']) and $match['e'][$a][1] > -1) ? 'e' : ((isset($match['d']) and $match['d'][$a][1] > -1) ? 'd' : 'u')] = $var[0];
    $str = substr_replace($str,call_user_func($fn,$var),$match[0][$a][1],strlen($match[0][$a][0]));
   }
  }
 }
 return $str;
}
function file_contents($file,$data=false,$mode=false,$ct=null){// (Gepackte) Datei lesen/schreiben|mode: Bit1 -> Lock, Bit3 -> Append
 global $cfg,$strftime,$bug;
 if(!$ct and !$data and preg_match('/^https:/i',$file))
  $ct = array('ssl' => array('verify_peer' => false, 'verify_peer_name' => false));
 if(is_array($ct))
  $ct = stream_context_create($ct);
 if(is_string($data)) {						// Datei schreiben
  if($file == ':')						// Bei nur ":" nichts schreiben
   return true;
  if(strpos($file,'%') !== false)				// strftime auflösen
   $file = @$strftime($file);
  if(is_bool($mode) and !$mode) {
   if(preg_match('/\.t?gz$/i',$file) and $fp = $cfg['zlib']['open']($file,'w'.$cfg['zlib']['mode'])) {// Write GZip
    $bug and dbug("Schreibe GZip-File: $file",9);
    $data = $cfg['zlib']['write']($fp,$data);
    $cfg['zlib']['close']($fp);
    return $data;
   }
   elseif(preg_match('/\.t?bz(ip)?2?$/i',$file) and ifset($cfg['bzip']) and $fp = bzopen($file,'w')) {	// Write BZip2
    $bug and dbug("Schreibe BZip2-File: $file",9);
    $data = bzwrite($fp,$data);
    bzclose($fp);
    return $data;
   }
   elseif(preg_match('/\.zip$/i',$file) and !preg_match('/^PK\x03\x04/',$data))
    $data = data2zip(array(preg_replace('/.*?([^\/]*)\.zip$/','$1',$file) => $data));
   $file = preg_replace('/\.(t?gz|t?bz(ip)?2?)$/i','',$file);	// Pack-Extension löschen
  }
  if(function_exists('file_put_contents'))
   return file_put_contents($file,$data,$mode,$ct);		// Ungepackt schreiben
  else {							// file_put_contents ($mode ist nicht vollständig implemmentiert)
   if($fp = fopen($file,($mode & 1<<3) ? 'a' : 'w')) {		// FILE_APPEND -> 8
    if(is_array($data))
     $data = implode('',$data);
    if($mode & 1<<1) {	// LOCK_EX -> 2
     if(flock($fp,2)) {	// flock LOCK_EX
      fputs($fp,$data);
      flock($fp,3);	// flock LOCK_UN
     }
     else {
      fclose($fp);
      return null;
     }
    }
    else
     fputs($fp,$data);
    fclose($fp);
    $fp = strlen($data);
   }
   return $fp;
  }
 }
 elseif(!$data and !$mode and !preg_match('/\.t?(gz(ip)?|bz(ip)?2?)$/i',$file))	// Datei vollständig lesen (data:0)
  return ($cfg['php'][3] < 5) ? file_get_contents($file,$mode) : file_get_contents($file,$mode,$ct);
 elseif(is_int($data) and $cfg['php'][3] >= 5.1) {		// Datei ab Offset lesen (data:offset, mode:length) & PHP 5.1+
  $data = array($file,false,$ct,filesize($file) + (($data < 0) ? max($data,-filesize($file)) : min($data,filesize($file))));
  if($mode)
   $data[] = $mode;
  return call_user_func_array('file_get_contents',$data);
 }
 elseif(is_int($data) and $fp = fopen($file,'r')) {		// Datei ab Offset lesen (data:offset, mode:length)
  $bug and dbug("Lese File: $file ($data/$mode)",9);
  fseek($fp,$data,($data < 0) ? SEEK_END : SEEK_SET);
  $data = "";
  if($mode)
   $data = fread($fp,$mode);
  else
   while(!feof($fp))
    $data .= fread($fp,$cfg['sbuf']);
  fclose($fp);
  return $data;
 }
 elseif(preg_match('/\.t?bz(ip)?2?$/i',$file) and ifset($cfg['bzip']) and $fp = bzopen($file,'r')) {	// BZip2 lesen
  $bug and dbug("Lese BZip2-File: $file",9);
  $data = "";
  while($var = bzread($fp,$cfg['sbuf'])) //  !== false
   $data .= $var;
  bzclose($fp);
  return $data;
 }
 elseif($fp = $cfg['zlib']['open']($file,'r')) {		// (gz)Datei entpackt lesen
  $bug and dbug("Lese gzFile: $file",9);
  $data = "";
  while(!$cfg['zlib']['eof']($fp))
   $data .= $cfg['zlib']['read']($fp,$cfg['sbuf']);
  $cfg['zlib']['close']($fp);
  return $data;
 }
 return false;
}
function file_stream($file,$data=false) {		// Datei-Stream Zeilenweise Lesen/Schreiben - Optional mit GZip/BZip2 (Mode: 0:rw, 1:gz, 2:bz)
 global $cfg,$fsData,$strftime,$bug;
 $out = $fs = false;
 if(!(isset($fsData) and is_array($fsData)))				// Globale Variabel vorhanden?
  $fsData = array('bs' => $cfg['sbuf'], 'pt' => 0, 'fs' => array());	// Globale Variable anlegen
 if(is_string($file)) {							// OPEN (file)
  if(strpos($file,'%') !== false)					// strftime auflösen
   $file = @$strftime($file);
  $fs = array('file' => $file, 'seek' => 0, 'data' => '', 'mode' => is_int($data) ? $data : ($data ? 1 : 0));		// Init
  $rw = ($fs['mode'] & 1) ? 'w' : 'r';
  $mode = $fs['mode'] & 6;
  $bug and dbug("file_stream: open ",9,6);
  if(($mode == 2 or preg_match('/\.t?gz$/i',$file)) and $fp = $cfg['zlib']['open']($file,$rw.$cfg['zlib']['mode'])) {	// GZip
   $bug and dbug("GZip-File",9,12);
   $fs['mode'] |= 2;
   $fs['fp'] = $fp;
  }
  elseif($mode == 4 or preg_match('/\.t?bz(ip)?2?$/i',$file) and ifset($cfg['bzip']) and $fp = bzopen($file,$rw)) {	// BZip2
   $bug and dbug("BZip2-File",9,12);
   $fs['mode'] |= 4;
   $fs['fp'] = $fp;
  }
  elseif($fp = fopen(preg_replace('/\.(t?gz|t?bz(ip)?2?)$/i','',$file),$rw)) {						// Normal
   $bug and dbug("File",9,12);
   $fs['fp'] = $fp;
  }
  else {
   $bug and dbug("Fail",9,12);
   $file = $fs = false;
  }
  if($fs)						// Neuen FileStream ablegen
   $fsData['fs'][$file = ++$fsData['pt']] = $fs;
  $out = $file;
 }
 elseif($file and is_int($file) and isset($fsData['fs'][$file]) and $fs = $fsData['fs'][$file]) {	// Daten lesen / schreiben
  $mode = $fs['mode'] & 6;				// GZip/BZip2/Std
  if(!($fs['mode'] & 1)) {				// LESEN
   if(is_int($data)) {					// Byteweise
    if($mode == 2)					// GZip
     $out = $cfg['zlib']['read']($fs['fp'],$data);
    elseif($mode == 4) {				// BZip
     if(($len = strlen($fs['data'])) < $data)
      $fs['data'] .= bzread($fs['fp'],$data-$len);
     $out = substr($fs['data'],0,$data+1);
     $fs['data'] = substr($fs['data'],strlen($out));
    }
    elseif(!$mode)					// Normal
     $out = fread($fs['fp'],$data);
   }
   elseif($mode == 2)					// GZip (Zeilenweise)
    $out = $cfg['zlib']['gets']($fs['fp'],$fsData['bs']);
   elseif($mode == 4) {					// BZip (Zeilenweise)
    if(($len = strlen($fs['data'])) < $fsData['bs']) {
     $var = bzread($fs['fp'],$fsData['bs'] - $len);
     $fs['data'] .= $var;
     $fs['seek'] += strlen($var);
    }
    if(($pos = strpos($fs['data'],"\n")) === false)
     $pos = strlen($fs['data']);
    $out = substr($fs['data'],0,$pos+1);
    $fs['data'] = substr($fs['data'],strlen($out));
   }
   elseif(!$mode)					// Normal (Zeilenweise)
    $out = fgets($fs['fp'],$fsData['bs']);
   $fs['seek'] += strlen($out);
  }
  elseif(($fs['mode'] & 1) and $data) {			// SCHREIBEN (Byteweise)
   if($mode == 2)					// GZip
    $out = $cfg['zlib']['write']($fs['fp'],$data);
   elseif($mode == 4)					// BZip
    $out = bzwrite($fs['fp'],$data);
   elseif(!$mode)					// Normal
    $out = fwrite($fs['fp'],$data);
   $fs['seek'] += $out;
  }
  if(!$out or $fs['mode'] & 1 and !$data) {		// CLOSE
   if($mode == 2)					// GZip
    $cfg['zlib']['close']($fs['fp']);
   elseif($mode == 4)					// BZip
    bzclose($fs['fp']);
   elseif(!$mode)					// Normal
    fclose($fs['fp']);
   unset($fsData['fs'][$file]);				// Pointer löschen
   $file = $fs = false;					// Variabeln löschen
  }
 }
 if($file and $fs)
  $fsData['fs'][$file] = $fs;
 return $out;
}
function listDir($pat,$dirs='',$mode=0,$list=array()) {	// Liest ein Verzeichnis aus (Pattern, Verzeichnis(e), Modus)	// Bit0 > Pattern, Bit1 > PathPat [PurePHP]
 if(!($mode & 1<<0)) {		// Simple-Pattern			// Bit2 > basename, Bit3 > noFile, Bit4 > noDir, Bit5 > Recusiv, Bit6 > Sort
  if(!$dirs) {			// Kein Verzeichnis angegeben
   if(file_exists($pat))	// Pattern existiert
    if(is_file($pat)) {		// Pattern ist ein File
     $dirs = dirname($pat);
     $pat = basename($pat);
    }
    else {			// Pattern ist ein Verzeichnis
     $dirs = $pat;
     $pat = '*';
    }
   elseif($var = ifset($pat,'/^(.*?)([^\\\\\/]*[*?][^\\\\\/]*)$/')) {	// Pattern besteht aus Verzeichnis und Pattern (glob)
    $dirs = $var[1];
    $pat = $var[2];
   }
   if(!$dirs)
    $dirs = '.';
  }
  if($pat and !function_exists('fnmatch')) {		// Workaround wenn fnmatch() nicht verfügbar ist
   $pat = "/^".strtr(preg_quote($pat,'/'),array('\*' => '.*', '\?' => '.', '\[' => '[', '\]' => ']'))."$/i";
   $mode |= 1<<0;
  }
 }
 foreach(array_unique((array)$dirs) as $dir) {		// Alle Verzeichnisse durchgehen
  if(file_exists($dir) and $dp = opendir($dir)) {
   $dir = preg_replace('/[\\\\\/]$/','',$dir);		// Letzten Slash entfernen
   while(($file = readdir($dp)) !== false)
    if(!preg_match('/^\.\.?$/',$file)) {		// Kein Current oder Parent
     $fn = (($mode & 1<<1) ? "$dir/" : '').$file;	// Bit 1 -> Filename für Pattern
     if(!$pat or $mode & 1<<0 and preg_match($pat,$fn) or !($mode & 1<<0) and fnmatch($pat,$fn,FNM_CASEFOLD)	// Bit 0 -> Patterncheck
	and (!($mode & (1<<3 | 1<<4)) or $mode & 1<<3 and !is_file("$dir/$file") or $mode & 1<<4 and !is_dir("$dir/$file"))) {	// Bit3 -> file / Bit4 -> dir
      $fn = ($mode & 1<<2) ? $file : (($dir != '.') ? "$dir/" : "").$file.(is_dir("$dir/$file") ? '/' : '');
      if($mode & 1<<2)
       $list[realpath("$dir/$file")] = $fn;
      else
       array_push($list,$fn);
      if($mode & 1<<5 and is_dir("$dir/$file") and $array = call_user_func(__FUNCTION__,$pat,"$dir/$file",$mode))	// Bit 5 -> Rekursiv
       if($mode & 1<<2)							// Bit 2 -> Basename
        $list[($mode & 1<<2) ? realpath($file) : $file] = $array;	// Assoc
       else
        $list = array_merge($list,$array);				// List
     }
    }
   closedir($dp);
  }
 }
 if(!$mode & 1<<2)
  $list = array_unique($list);
 if($mode & 1<<6)							// Bit 6 -> Sortieren
  natcasesort($list);
 return $list ? $list : false;
}
function ifset(&$x,$y=false) {				// Variabeln prüfen und Optional vergleichen (var,test) [PurePHP]
 return (isset($x) and ($x or $x != '')) ? ($y ? ((is_string($y) and preg_match('!^(([^\w\s]).*\2[imsuxADU]{0,8})((\d)|(a))?($)!Us',$y,$w) and is_string($x)
	and ($w[5] and preg_match_all($w[1],$x,$z) or preg_match($w[1],$x,$z))) ? (($z and $w[4] != "") ? $z[(int)$w[4]] : $z) : (is_array($x)
	? ((is_string($y) and $w) ? preg_grep($y,$x) : (is_int($y) ? count($x) == $y : (is_bool($y) ? $x : array_search($y,$x))))
	: (((is_callable($y) and $z = call_user_func($y,$x)) ? (is_bool($z) ? $x : $z) : ((!is_bool($x) or is_bool($y)) and $x == $y)))))
	: (is_string($x) ? (is_string($y) ? $x : strlen($x)) : ((is_numeric($x) or is_bool($x)) ? $x : (is_array($x) ? count($x) : !$y)))) : false;
}
function preg_array($x,$y,$z=0) {			// Durchsucht einen Array mit Regulären Ausdruck (preg,array,mode) [PurePHP]
 $w = ($z & 1<<1) ? array() : false;	// Return All/First				// Set -	 0	1	-
 foreach($y as $k => $v)								// Bit 0: Search value	key	1
  if(($z & (1<<4)) and is_array($v) and $u = call_user_func(__FUNCTION__,$x,$v,$z))	// Bit 1: Result first	all	2
   if($z & 1<<1)			// Result All					// Bit 2: Result value	key	4
    $w[$k] = $u;									// Bit 3: Search found	n.found	8
   else					// Result First					// Bit 4: iterativ	rekusiv	16
    return ($z & 1<<2) ? $k : $u;	// Return Key/Value				// Bit 5: Result found	match	32
  elseif(($z & 1<<3) xor preg_match($x,($z & 1<<0) ? $k : (is_array($v) ? "" : $v),$u))	// (not)Found & Key/Value
   if($z & 1<<1)			// Result All
    $w[$k] = ($z & 1<<5) ? $u : $v;	// Result All-Match
   else					// Result First
    return ($z & 1<<2) ? $k : (($z & 1<<5) ? $u : $v);	// Return Key/Value/Match
 return $w;
}
function unBase($data,$base=false,$bits=false) {	// unBase2-128 (data-string, base-chars[Default: AVM-Base32], input-bits) [PurePHP]
 for($base = $base ? $base : char('AZ16'), $bits = $bits ? $bits : intval(log(strlen($base),2)), $a=$b=$c=0, $out=""; $a < strlen($data); )
  if(($e = strpos($base,$data[$a++])) !== false)
   for($c = ($c << $bits) + $e, $b += $bits; $b >= 8; $c %= 1 << $b)
    $out .= chr($c >> ($b -= 8));
 return $out;
}
function getArg($name=false,$preg=false,$arg=null) {	// Nächsten Parameter holen (argname, /preg_match/, argname-only & return@false)
 global $cfg;	// args,argc,argn,arg,$opts
 $tst = $arg;									// Parameter retten für TEST-Modus
 if(is_string($name) and $name[0] == '-') {					// Optionen abfragen
  $def = 'opts';
  $name = substr($name,1);
 }
 else										// Argumente abfragen
  $def = 'args';
 if($name) {									// Benanntes Argument (name)
  if(is_bool($name))								// Ungeprüfte oder Benannte Parameter vorhanden? (name -> true)
   $arg = preg_array("/^(".str_replace('\|','|',preg_quote(implode('|',array_keys($cfg['argk'])),'/')).")$/",$cfg['arg'],11);
  elseif(isset($cfg[$def][$name]) and is_array($var = $cfg[$def][$name])) {	// Benanntes Argument ist ein Array
   if(is_string($preg) and strlen($preg) == 1)					// Array als CSV zurückgeben? (preg -> .)
    $arg = implode($preg,str_replace($preg,$preg.$preg,$var));
   elseif(!is_array($preg) and $var = current($cfg[$def][$name]) and ifset($var,$preg))	// Aktuelles Argument aus Array zurückgeben (preg)
    $arg = $preg ? $var : current($cfg[$def][$name]);
   elseif(is_array($preg))							// Nur Argumente zurückgeben, die auf [preg] passen oder alle
    $arg = (isset($preg[0]) and $preg[0]) ? preg_array($preg[0],$cfg[$def][$name],isset($preg[1]) ? $preg[1] : 2) : $cfg[$def][$name];
  }
  elseif(isset($cfg[$def][$name]))						// Benannter Parameter
   $arg = $preg ? ifset($cfg[$def][$name],$preg) : $cfg[$def][$name];
 }
 elseif(is_null($arg) and is_array($preg) and $cfg['argc'])			// Alle restlichen Nummerischen Parameter zurückgeben
  for($arg=array(); $name = array_shift($cfg['argc']);)
   $arg[] = $cfg['arg'][$name];
 if($def == 'opts')								// Optionen sofort zurückgeben
  return is_null($arg) ? false : (is_array($preg) ? (array)$arg : $arg);	// Vorgabe oder false zurückgeben
 elseif($tst === true)								// Parameter nur Testweise zurückgeben
  return ($arg === true) ? (($var = ifset($cfg['arg'][$name = reset($cfg['argc'])],$preg)) ? ($preg ? $var : $cfg['arg'][$name]) : false) : $arg;
 elseif(is_null($arg) or $arg == $tst and $cfg['argc']) {			// Nummerierter/Unbenannter Parameter
  foreach($cfg['argc'] as $val => $name)					// Auf Inhaltprüfen
   if(($var = ifset($cfg['arg'][$name],$preg)) != "")
    break;
  if(ifset($var) != "") {							// Wurde ein Nummerierter/Unbenannter Parameter gefunden?
//   if(!$cfg['argn'])								// Übergabe/Abfrage vom alten Parameter-System ermöglichen
//    $pset++;
   unset($cfg['argc'][$val]);							// Parameter löschen
   $arg = $preg ? $var : $cfg['arg'][$name];
  }
 }
 return (is_null($arg) or !$arg and (is_array($arg) or is_string($arg) and is_bool($arg))) ? false : $cfg['argk'][$name] = (is_array($preg) ? (array)$arg : $arg);	// Vorgabe oder false zurückgeben
}
function out($str,$mode=0,$lf=PHP_EOL) {		// Textconvertierung vor der ausgabe (mode: 0 -> echo / 1 -> noautolf / 2 -> debug)
 global $cfg;
 $cp = ifset($cfg['char']) ? (array)$cfg['char'] : array('c' => 1);
 if(ifset($cp['n']))						// Char:none
  return "";							// Keine Ausgabe
 if(is_array($str))
  $str = print_r($str,true);
 if(is_string($str) and $str != "") {
  if(!($mode & 1<<1) and preg_match('/\S$/D',$str))		// AutoLF
   $str .= $lf;
  if($mode & 1<<2)						// Unnötige Whitespaces im Debug-Modus löschen
   $str = preg_replace('/(?<=\n\n|\r\n\r\n)\s+$/','',$str);
  if(isset($cfg['anon']) and is_array($cfg['anon']))		// Möglichkeit die Ausgabe zu anonymisieren
   $str = preg_replace(array_keys($cfg['anon']),array_values($cfg['anon']),$str);
  if($cfg['oput'] and !($mode & 1<<2))				// Ausgabe speichern
   file_contents($cfg['oput'],textTable($str,-1),8);
  if(ifset($cp['d']) and preg_match_all('/(.)(.)/',base64_decode(
	"thSnFceA/IHpguKD5ITgheWG54fqiOuJ6Irvi+6M7I3EjsWPyZDmkcaS9JP2lPKV+5b5l/+Y1pncmqOc4aDtofOi+qPxpNGlqqa6p7+orKq9q7ysoa2rrruv3+G15rHx9/aw+Lf6sv2g/"
	.((substr($cp['d'],-3) == 437) ? "6KbpZ0=" : "/ib2J3Xnq6pwbXCtsC3qbiivaW+48bDx6TP8NDQ0crSy9PI1M3WztfP2KbdzN7T4NTi0uP15NXl/ufe6Nrp2+rZ6/3s3e2v7rTvrfC+87b0p/W496j5ufuz/A==")),$m))
   $str = strtr(utf8($str),array_combine($m[1],$m[2]));		// DOS
  elseif(ifset($cp['m']) and preg_match_all('/(.)(.)/',"Ç€üé‚âƒä„ç‡ë‰îŒÄŽÉô“ö”Ö™Üš×žá í¡ó¢ú£¬ª«®»¯ÁµÂ¶¤ÏËÓÍÖÎ×ÓàßáÔâÚéýìÝí´ï­ð§õ÷ö¸÷°ø¨ù ÿ",$m))
   $str = strtr(utf8($str),array_combine($m[1],$m[2]));		// cp852
  elseif(ifset($cp['u']))
   $str = utf8($str,3);						// UTF8
  elseif(ifset($cp['h']) and preg_match_all('/(.)([\da-z#]+)/','&amp<lt>gt"quot\'#39äaumlöoumlüuumlßszligÄAumlÖOumlÜUuml',$m))
   $str = strtr($str,array_combine($m[1],preg_replace('/.+/','&$0;',$m[2])));	// HTML
  elseif((ifset($cp['c']) or ifset($cp['l']) or ifset($cp['r']) or !ifset($cp['a']))
	and preg_match_all('/([^ -~]+)([ -~]+)/','¡!£GBPŠ|§\\Sš"©(c)«<<¬-®(R)º°\'¯^±+-²2³3Ž\'µu¶I·\''
	.'ž.¹1»>>Œ1/4œ1/2Ÿ3/4¿?ÆAEÄAeÖOeÜUeæäaeöoeüueßssÀÁÂÃÅAÇCÈÉÊËEÌÍÎÏIÐDÑNÒÓÔÕØOÙÚÛUÝ¥YÞpàáâãåªaç¢cèéêëeìíîïiñnðòóôõø€oùúûuþPýÿy×x÷:',$m)) {
   $a = array();						// 7 Bit ASCII
   foreach($m[1] as $key => $var)
    for($b=0; $b < strlen($var); $b++)
     $a[$var[$b]] = $m[2][$key];
   $str = strtr(utf8($str),$a);
  }
  else								// Ansi
   $str = utf8($str);
  $str = textTable($str,-1);					// Tabelle im String
  if($var = ifset($cp['l'],"") and preg_match_all('/([a-z\d])(.)/i','1I2Z3E4A5S6G7T8B9g0Oa4A4b8B8e3E3g6G6l1L1o0O0q9Q9s5S5t7T7z2Z2'.(is_numeric($var) ? '' : 'c<C(h#H#i!I!x+X+'),$m))
   $str = strtr($str,array_combine($m[1],$m[2]));
  elseif(ifset($cp['r']))
   $str = str_rot13($str);
  if(!($mode & 1<<3) and $col = (int)$cfg['wrap'] and --$col) {	// My WordWrap
#   $str = wordwrap($str,$cfg['wrap']-1,$lf,true);
   $esc = array();						// Mutibytes Entwerten
   $pos = 0;
   $p = "[\x80-\xbf]";
   while(preg_match("/\x7f|[\xc0-\xdf]$p|[\xe0-\xef]$p{2}|[\xf0-\xf7]$p{3}|[\xf8-\xfb]$p{4}|[\xfc-\xfd]$p{5}|\xfe$p{6}
	|\\\\(u\{[\da-fA-F]+\}|u[dD][89abAB][\da-fA-F]{2}\\\\u[dD][c-fC-F][\da-fA-F]{2}|u[\da-fA-F]{4})|(&\#(\d+|x[\da-fA-F]+);)/x",substr($str,$pos),$m,PREG_OFFSET_CAPTURE)) {
    $str = substr_replace($str,"\x7f",$pos + $m[0][1], strlen($m[0][0]));
    $esc[] = $m[0][0];
    $pos += $m[0][1] + 1;
   }
   $inp = str_replace("\x0b"," ",$str);				// WordWrap vorbereiten
   $len = strlen($inp);
   $str = "";
   $pos = 0;
   while(preg_match('/^([ \t]*)(.*?(?:\r?\n|$))/',substr($inp,$pos),$m) and $pos < $len) {
    if(($col-($spc = strlen($m[1]))) < 16) {
     $spc = 0;
     $m[1] = "";
    }
    $str .= preg_replace(array("/^/","/\x0b/"),array($m[1],"$lf$m[1]"),wordwrap($m[2],$col-$spc,"\x0b",true));
    $pos += strlen($m[0]);
   }
   $m = 0;							// Entwertete Zeichen wieder zurückholen
   while(($m = strpos($str,"\x7f",$m)) !== false) {
    $str = substr_replace($str,$esc[0],$m,1);
    $m += strlen(array_shift($esc));
   }
  }
 }
 elseif(is_array($str))						// Leeres Array
  $str = "";
 return ($mode & 1<<0) ? $str : print $str;
}
function dbug($str,$level=0,$mode=4) {			// Debug-Daten ausgeben/speichern (mode: 4 -> Debug) # dbug(compact(explode(',','array,key,var')));
 global $cfg,$bug;
 if(floor($cfg['dbug']/(1<<$level))%2) {		// Nur Entsprechenden Debug-Level ausgaben
  if(is_string($mode))					// Entweder Mode-Angabe oder Dateiname
   if(preg_match('/^(\d+),(.+)$/',$mode,$var)) {
    $mode = $var[1];
    $file = $var[2];
   }
   else {
    $file = $mode;
    $mode = 4;
   }
  else
   $file = false;
  $time = ($cfg['dbug'] & 1<<2 and !($mode & 1<<3)) ? number_format(array_sum(explode(' ',microtime()))-$cfg['stim'],3,',','.').' ' : '';
  if($cfg['dbug'] & 1<<1 and $cfg['dbfn'] and $file)	// Debug: Array in separate Datei sichern
   if(strpos($file,'#') and is_array($str))
    foreach($str as $key => $var)			// Debug: Array in mehrere separaten Dateien sichern
     file_contents($cfg['dbcd'].str_replace('#',"-".str_replace('#',$key,$file),$cfg['dbfn']),$time.(is_array($var) ? print_r($var,true) : $var),8);
   else
    file_contents($cfg['dbcd'].str_replace('#',"-$file",$cfg['dbfn']),$time.(is_array($str) ? print_r($str,true) : $str),8);	// Alles in EINE Datei Sichern
  else {
   if(is_string($str)) {
    if(preg_match('/^\$(\w+)$/',$str,$var) and isset($GLOBALS[$var[1]]))	// GLOBALS Variable ausgeben
     $str = "$str => ".(is_array($GLOBALS[$var[1]]) ? print_r($GLOBALS[$var[1]],true) : $GLOBALS[$var[1]]);
    elseif(!($mode & 1<<1) and preg_match('/\S$/D',$str))// AutoLF
     $str .= "\n";
   }
   elseif(is_array($str))
    $str = print_r($str,true);
   if($cfg['dbug'] & 1<<1 and $cfg['dbfn']) {		// Debug: Ausgabe/Speichern
    file_contents($cfg['dbcd'].str_replace('#','',$cfg['dbfn']),$time.$str,8);
    if(!$level)						// Nur Level 0 Ausgeben!
     out($time.$str,($mode | 4) & 7);
   }
   else
    out($time.$str,($mode | 4) & 7);
  }
 }
}
function errmsg($msg=0,$name='main',$opt=false) {	// Fehlermeldung(en) Sichern
 global $cfg,$bug;
 if(!ifset($cfg['errmute']))	// Fehleraufzeichnung pausieren?
  if($msg) {			// Fehlermeldung speichern
   $bug and dbug("Fehler: $msg",9);
   if($opt and is_array($opt) and count($opt) == 1) {	// Sonderfunktion Zeile Berechnen
    $poi = key($opt);
    $str = $opt[$poi];
    $line = substr_count($str,"\n",0,$poi)+1;
    $col = $poi-strrpos(substr($str,0,$poi),"\n");
    $msg = trim($msg)." (Ab Zeichen: $poi".(($poi != $col) ? " oder Zeile: $line / Spalte: $col" : "").")";
   }
   $cfg['error'][$name][] = trim($msg);
  }
  else {			// Letzte Fehlermeldung abrufen
   $bug and dbug("Suche Fehler von Funktion: $name",9);
   if($name == "*" and $var = array_keys($cfg['error']))
    $name = end($var);		// Letzte Fehlermeldung finden
   while(isset($cfg['error'][$name]) and is_array($cfg['error'][$name]))// Fehlermeldung vorhanden?
    if($val = end($cfg['error'][$name]) and preg_match('/^\w+$/',$val))	// Möglicher Rekusive Fehlermeldung?
     $name = $val;							// Nächste Fehlermeldung suchen
    else {
     if($name != 'main')
      $cfg['error']['main'][] = $val;
     return (substr($val,0,2) != '1:' or $opt) ? preg_replace('/^\d+:/','',$val) : false;// Nur Fehlermeldung ohne Error-Code ausgeben
    }
  }
 return ($msg and $name == 'main') ? preg_replace('/^\d+:/','',$msg) : false;	// Ohne Funktionsname: Fehler ausgeben oder failat
}
function phperr($no,$str,$file,$line) {			// PHP-Fehler Debuggen
 foreach(json2array("[ERROR,WARNING,PARSE,NOTICE,CORE_ERROR,CORE_WARNING,COMPILE_ERROR,COMPILE_WARNING,
	USER_ERROR,USER_WARNING,USER_NOTICE,STRICT,RECOVERABLE_ERROR,DEPRECATED,USER_DEPRECATED,UNKNOWN]") as $b => $c)
  if($no == 1 << $b)
   break;
 $a = "$str on line $line";
 $b = &$GLOBALS["cfg"]["error"][$c][$file];
//  $b["backtrace"][] = debug_backtrace();
 if(!isset($a,$b) or array_search($a,$b) === false)
  $b[] = $a;
 return false;
}
function makedir($dir,$mode=1) {			// Erstellt ein Verzeichnis und wechselt dorthin
 global $strftime,$bug;
 if(!$dir or ifset($dir,$GLOBALS['cfg']['ptar']) or ifset($dir,'/^php:/i'))	// Self-Dir, php: und Archive nicht bearbeiten
  return true;
 $dir = preg_replace('/[\\\\\/]+$/','',$dir);		// Abschlussshlash entfernen
 if(strpos($dir,'%') !== false)				// strftime auflösen (Problematische Zeichen werden umgewandelt)
  $dir = @$strftime($dir);
 if(preg_match('/^(\w:)?(.*)$/',$dir,$var))		// Windows Verzeichnis Prüfen
  $dir = $var[1].preg_replace('/[<:*|?">]+/','-',$var[2]);
 if(!file_exists($dir)) {				// Neues Verzeichniss erstellen
  if($mode)						// Debug-Meldung unterdrücken
   $bug and dbug("Erstelle Ordner $dir");
  $dirs = preg_split('/[\\\\\/]/',$dir);		// Verzeichniskette erstellen
  $val = '';
  foreach($dirs as $var) {
   $val .= $var;
   if($val and !file_exists($val))
    mkdir($val);
   $val .= '/';
  }
 }
 if($mode and is_dir($dir)) {				// Aktuelles-Dir setzen
  $bug and dbug("Wechsle zu Ordner $dir");
  chdir($dir);
 }
 return is_dir($dir) ? $dir : false;
}
function mytouch($mode=false) {				// Ermitteln ob fb_Tools wieder nach Updates suchen soll
 global $cfg,$script,$strftime,$bug;
 $rt = false;
 if(is_string($mode)) {					// Prüfen, ob eine Datei geschrieben werden kann
  $file = $mode;
  if(file_exists($file)) {				// Test mit einer Datei, die schon da ist
   $new = preg_replace('/(?=\.\w+$)|$/','_test',$file);
   if(rename($file,$new)) {
    if(file_contents($file,$file) and unlink($file))
     $rt = true;
    rename($new,$file);
   }
  }
  elseif(file_contents($file,$file) and unlink($file))	// Einfacher Schreibtest
   $rt = true;
 }
 else {
  $dbg = ($cfg['upda'] < 0) ? 0 : 9;			// Debug-Modus festlegen
  $time = time();					// Aktuelle Uhrzeit
  $data = is_array($mode) ? array2json($mode) : "$time";// Touchinhalt festlegen
  $name = "/$cfg[touch]-$cfg[cu]";			// Touch-Dateinamen aus der Konfig holen
  $array = array();
  if($cfg['usrcfg'] and $cfg['usrfmt'])
   foreach(glob_brace("{".implode(',',str_replace(',','\,',array('.',$cfg['home'],$cfg['dir'])))."}/{.,}$cfg[usrcfg].{".implode(',',$cfg['usrfmt'])."}") as $var)
    $array[] = realpath($var);
  $array = array_unique(array_merge(array_reverse(array_slice($cfg['fbta'],2)),array_reverse(array_slice($cfg['fbtl'],2)),array_slice($cfg['fbta'],1,1),
 	array_slice($cfg['fbtl'],1,1),array($script),$array,array($cfg['dir'],$cfg['home'],".",$cfg['temp'])));
  if($mode) {						// Datum setzen
   foreach($array as $file)				// Verschiedene Speicherorte probieren
    if(file_exists($file = realpath($file)) and (is_file($file) and @touch($file,$time) or is_dir($file) and @file_contents($file .= $name,$data) and file_exists($file)) and filemtime($file) == $time) {
     $bug and dbug("Touch-Datei: '$file' erfolgreich auf '".$strftime($cfg['fstr'],$time)."' gesetzt",$dbg);
     $rt = true;
     break;
    }
  }
  elseif($cfg['upda'] > 0) {				// Datum abfragen
   $max = filemtime($script);				// Das Script selber
   $data = array();					// Leere Daten
   array_push($array,$cfg['dir'],$cfg['home']);		// Touch-Datei
   if(ifset($cfg['loadcfg']))				// Geladene Konfig-Datei
    $array = array_merge((array)explode('|',$cfg['loadcfg']),$array);
   array_push($array,$cfg['temp']);
   $dir = array();					// Pfade auf echte Pfade reduzieren
   foreach($array as $file)
    if($var = realpath($file))
     $dir[$var] = 1;
   $array = array_keys($dir);
   foreach($array as $var)
    if($var and file_exists($var) and (is_dir($var) and $files = glob(realpath($var)."/$cfg[touch]-*") or is_file($var) and $files = array($var)))
     foreach($files as $file) {
      $val = filemtime($file);
      $bug and dbug("Touch-Datei gefunden: $file (Datum: ".$strftime($cfg['fstr'],$val).")",$dbg);
      if($max < $val) {					// Neuere Touch-Datei gefunden
       $max = $val;					// Das neuste Datum sichern
       if(substr(basename($file),0,strlen($cfg['touch'])) == $cfg['touch'] and preg_match('/^\{.*\}$/',$val = file_contents($file)))
        $data = json2array($val);			// Daten aus der Touchdatei holen
      }
     }
   $bug and dbug("Letztes Touch-Datum: ".$strftime($cfg['fstr'],$max),$dbg);
   $rt = $time - $max > $cfg['upda'];			// Array zurückgeben oder Vergleichen
  }
 }
 $rt = ($mode === 0 and $data) ? array('chk' => $rt) + $data :  $rt;	// Rückgabe
 return $rt;
}
function otpauth($key,$rep=1,$time=0,$digit=6,$sec=30) {// OTP-Token Generieren für Zweite-Faktor-Authentifizierung
 global $cfg,$strftime,$bug;
 if(!$time)			// Uhrzeit prüfen
  $time = time();		// Uhrzeit auf Rechner-Zeit setzen
 $bug and dbug("OATH-TOTP-Secret: $key (".@$strftime($cfg['fstr'],$time).")",9,2);
 $otp = array();
 if(function_exists('hash_hmac') or init(5,'hashtool')) {
  $time = floor($time / $sec);	// Zeit auf $sec Sekunden runden
  while($rep--) {
   $hash = hash_hmac('sha1',str_pad(pack('N*',$time),8,"\0",STR_PAD_LEFT),unBase(strtoupper($key),'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'),true); // Hash aus Zeit und Secret berechnen
   $hash = unpack('N',substr($hash,ord(substr($hash,-1)) & 15, 4));			// Hash auf 32 Bits reduzieren
   $otp[$time++*$sec] = str_pad(($hash[1] & (1 << 31) - 1) % 1e6,$digit,0,STR_PAD_LEFT);// fertigen Code ausgeben
  }
 }
 else
  return errmsg("hash_hmac steht nicht zur verfügung",__FUNCTION__);
 $bug and dbug(" -> Token: ".implode(", ",$otp),9);
 return (count($otp) == 1) ? reset($otp) : $otp;
}
function xml2array($xml,$attr="_attribute") {		// Konvertiert eine XML-Datei in ein Array
 if(preg_match_all('/<([\w:.-]+)([^\/>]*)(?:\/>|>\s*((?:[^<]|<(?!\/?\1>)|(?R))*)\s*<\/\1>)/x',$xml,$val)) {
  $xml = array();
  foreach($val[1] as $key => $var) {
   $sub = call_user_func(__FUNCTION__,$val[3][$key],$attr);// Untertag einlesen
   if($val[2][$key] and preg_match_all('/([\w:.-]+)="((?:[^"]+|\\\\")*)"/',$val[2][$key],$m))
    foreach($m[1] as $k => $v) {			// Attribute einlesen
     if(is_string($sub))
      $sub = $sub ? array($sub) : array();
     if($attr)
      $sub[$attr][$v] = $m[2][$k];
     else
      $sub[$v] = $m[2][$k];
    }
   if(isset($xml[$var])) {				// Tag schon vorhanden
    if(!isset($xml[$var][0]) or !is_array($xml[$var]))	// Noch nicht Nummeriert?
     $xml[$var] = array($xml[$var]);			// Einträge in Nummer 0 verschieben
    elseif(isset($xml[$var][0]) and !is_array($xml[$var][0]) and isset($xml[$var][$attr])) {
     $xml[$var][0] = array($xml[$var][0],$attr => $xml[$var][$attr]);
     unset($xml[$var][$attr]);
    }
    $xml[$var][] = $sub;				// Tag hinten dran hängen
   }
   else
    $xml[$var] = $sub;					// Tag normal speichern
  }
 }
 return $xml;
}
function tar2array($file,$preg=false) {			// Liest ein Tar-Archiv vom File als Array ein
 global $cfg,$bug;
 $fn = __FUNCTION__;
 if(file_exists($file) and preg_match($cfg['ptar'],$file,$var) and $func = ($cfg['bzip'] and ifset($var[3])) ? array('bzopen','bzread','bzclose')
	: array($cfg['zlib']['open'],$cfg['zlib']['read'],$cfg['zlib']['close']) and $fp = call_user_func($func[0],$file,'r')) {
  $bug and dbug("Entpacke Tar-Archiv aus Datei",9);
  $long = "";
  $tar = array();
  while($meta = call_user_func($func[1],$fp,512) and preg_match('/^[^\0]{1,100}/',$meta,$name)) {
   for($a = 0,$cu = $cs = 256; $a < 512; $a += ($a == 147) ? 9 : 1) {
    $cu += $b = ord($meta[$a]);
    $cs += $b << 24 >> 24;
   }
   $b = octdec(substr($meta,148,7));
   if($cu != $b and $cs != $b)
    return errmsg("16:Defektes Tar-Archiv",$fn);
   if($size = octdec(substr($meta,124,11)))
    for($data = "", $a = $size + 512 - $size % 512; $a and ($var = call_user_func($func[1],$fp,$a)) !== false; $a -= strlen($var))
     $data .= $var;
   $a = $meta[156];
   if($a == 'L' and $size)
    $long = substr($data,0,$size);
   elseif(!$a and $name = $long ? $long : $name[0] and (!$preg or preg_match($preg,$name))) {
    $tar[$name] = substr($data,0,$size);
    $long = "";
   }
  }
  call_user_func($func[2],$fp);
  $bug and dbug($tar,9,'8,tar2array-#');
  return $tar;
 }
 return errmsg("8:TAR-Archiv nicht gefunden oder läßt sich nicht öffnen",$fn);
}
function datatar2array($tar,$preg=false) {		// Parst aus einer Variable ein Tar-Archiv mit Meta-Daten als Array
 global $bug;
 $bug and dbug("Entpacke Tar-Archiv aus Variable",9);
 if(preg_match_all('/(\D+)(\d+)/',"name100mode8UID8GID8SIZE12MTIME12CHKSUM8TYPEFLAG1linkname100magic6VERSION2uname32gname32devmajor8devminor8prefix155",$array))
  $array = array_combine($array[1],$array[2]);
 $long = "";
 $out = array();
 $pos = 0;
 while($pos < strlen($tar) and $tar[$pos] != "\0") {
  $meta = array();
  for($a = 0, $cu = $cs = 256; $a < 512; $a += ($a == 147) ? 9 : 1) {
   $cu += $b = ord($tar[$pos + $a]);
   $cs += $b << 24 >> 24;
  }
  $b = octdec(substr($tar,$pos + 148,7));
  if($cu != $b and $cs != $b)
   return errmsg("16:Defektes Tar-Archiv",__FUNCTION__);
  $a = $pos;
  foreach($array as $key => $var) {
   if($data = preg_replace('/\0+$/','',substr($tar,$a,$var)))
    $meta[strtolower($key)] = (strtoupper($key) == $key and preg_match('/^[0-7]+$/',$data)) ? octdec($data) : $data;
   $a += $var;
  }
  $meta['data'] = substr($tar,$pos + 512,$meta['size']);
  if($size = $meta['size'])
   $pos += $size + 512 - $size % 512;
  $pos += 512;
  $a = ifset($meta['typeflag'],"");
  if($a == 'L' and ifset($meta['data']))
   $long = $meta['data'];
  elseif(!$a and $name = $long ? $long : $meta['name'] and (!$preg or preg_match($preg,$name))) {
   $out[$name] = $meta;
   $long = "";
  }
 }
 return $out;
}
function data2tar($name,$data='',$vars=array()) {	// Erstellt ein Tar-Header [PurePHP]
 $n = "\0";
 $pre = "";
 $mtime = $type = $size = $uid = $gid = 0;
 $perms = 436;						// 0664
 if(is_array($vars))
  extract($vars);
 else
  $mtime = $vars;
 if(!is_string($name))					// Pad Entry (true,size)
  return str_repeat($n,is_int($name) ? (512 - $name % 512) % 512 : 512);
 elseif(is_int($data)) {				// Only TAR-Header
  $size = $data;
  $data = "";
 }
 elseif(!$data and substr($name,-1) == '/') {		// Dir-Header
  $type = 5;
  $size = 0;
  $data = "";
 }
 elseif(!$size and $data)				// File-Header mit Daten
  $size = strlen($data);
 if(strlen($name) > 100) {				// Long Filename
  $pre = call_user_func(__FUNCTION__,"././@LongLink",$name.$n,array('mtime' => $mtime, 'type' => 'L'));
  $name = substr("@PathCut/$name",0,100);
 }
 for($a=1, $b = array($name,$perms,$uid,$gid,$size,$mtime), $tar = str_pad($b[0],100,$n); $a < count($b); $a++)
  $tar .= str_pad(decoct($b[$a] & pow(2,($c = 7 + ($a & 4))*3)-1),$c,0,STR_PAD_LEFT).$n;
 $tar .= "        $type".str_repeat($n,100)."ustar  ".str_repeat($n,248);
 if($data)
  $tar .= $data.call_user_func(__FUNCTION__,$size);
 for($a=$b=0; $a<512; $a++)				// Calc TAR-Checksum
  $b += ord($tar[$a]);
 return $pre.substr_replace($tar,str_pad(decoct($b),6,"0",STR_PAD_LEFT).$n." ",148,8);
}
function zip2array($data,$pass=array(),$zip=array(),$x=0) {// Liest ein ZIP-Archiv auf einer Variable als Array ein
 global $cfg,$bug;
 $fn = __FUNCTION__;
 if(is_int($pass)) {				// Unterfunktionen für zip2array
  if($pass >=0) {				// le2int (str,pos,len,raw)
   $data = strrev(substr($data,intval($pass),$zip ? intval($zip) : 2));
   $zip = $x ? $data : hexdec(bin2hex($data));
  }
  elseif($pass >= -2) {				// zipcrypto (str,-[12],array(zipcrc))
   $nhash = "";
   for($a = 0; $a < strlen($data); $a++) {
    if($pass == -2)
     $nhash .= chr(ord($data[$a]) ^ call_user_func($fn,$b = $zip[2] | 2,-5,$b ^ 1) >> 8 & 255);
    $zip[0] = call_user_func($fn,call_user_func($fn,$nhash ? $nhash[$a] : $data[$a],-3,$zip[0]),-4,0);
    $zip[1] = call_user_func($fn,call_user_func($fn,$zip[1] + ($zip[0] & 255),-5,0x8088405) + 1,-4,0);
    $zip[2] = call_user_func($fn,call_user_func($fn,chr(call_user_func($fn,$zip[1],-4,24)),-3,$zip[2]),-4,0);
   }
   if($pass == -2)
   $zip = $nhash;
  }
  elseif($pass == -3) {				// crc32 (str,-3,crc)
   if(!isset($cfg['czip']))
    for($a=0; $a < 256; $cfg['czip'][$a++] = $c)
     for($b=0,$c=$a; $b < 8; $b++)
      $c = ($c>>1) & 0x7FFFFFFF ^ ($c & 1) * 0xEDB88320;
   for($zip = intval($zip), $a=0; $a < strlen($data); $a++)
    $zip = $cfg['czip'][($zip ^ ord($data[$a])) & 255] ^ ( $zip >> 8 ) & 0xFFFFFF;
  }
  elseif($pass == -4) {				// urShift (a,-4,b)
   if($zip >= 32 or $zip < -32)
    $zip %= 32;
   elseif($zip < 0)
    $zip += 32;
   $zip = !$zip ? ($data>>1 & 0x7FFFFFFF) * 2 + ($data>>$zip & 1) : (($data < 0) ? ($data >> 1 & 0x7FFFFFFF | 0x40000000) >> $zip - 1 : $data >> $zip);
  }
  elseif($pass == -5)				// imul (a,-5,b)
   $zip = call_user_func($fn,($data >> 16 & 65535) * ($c = $zip & 65535) + ($data &= 65535) * ($zip >> 16 & 65535) << 16,-4,0) + $data * $c;
 }
 else {						// data2zip
  if(!$pass and ifset($cfg['zp']))
   $pass = $cfg['zp'];
  if($pass and (!($aes = init(5,'aes')) or !preg_array('/^(openssl|mcrypt)$/i',$aes,1) or !(function_exists('hash_pbkdf2') or init(5,'hashtool'))
	or !(function_exists('hash_algos') or !init(5,'mhash') or !init(5,'sha256'))))					// Ist Verschlüsslung möglich?
   return errmsg("Keine AES-CTR Funktion gefunden",$fn);
  for($pos = $d = 0; $pos < strlen($data)
	and preg_match('/^PK(?:(\x03\x04)|(\x01\x02)|\x05(?:(\x05)|(\x06))|\x06(?:(\x06)|(\x07)|(\x08))|(\x07\x08))()/',substr($data,$pos),$c); $pos += $d) {
   if($c[1] and call_user_func($fn,$data,$pos + 4,1) < 52) {								// \x03\x04 (Local file header) Bis Version 5.1
    $g = (call_user_func($fn,$data,$pos + 6) & 8 and preg_match('/PK\x07\x08.{12}PK[\x01-\x09]{2}/s',substr($data,$pos),$h)) ? $h : 0; // Stream-ZIP Ersatz-Header suchen
    $i = substr($data,$pos + 30,$d = $h = call_user_func($fn,$data,$pos + 26));						// Dateiname
    $j = strtotime((1980 + (($e = call_user_func($fn,$data,$pos + 10,4))>>25))."-".($e>>21 & 15)."-".($e>>16 & 31)." ".($e>>11 & 31).":".($e>>5 & 63).":".(($e & 31) * 2));// Datum
    $e = substr($data,$pos + 30 + ($d += call_user_func($fn,$data,$pos + 28)),($f = $g ? call_user_func($fn,$g[0],8,4) : call_user_func($fn,$data,$pos + 18,4)));// Gepackte Daten holen (f = länge)
    $d += 30 + $f;													// Offset um Header mit Daten zu überspringen
    if(!(call_user_func($fn,$data,$pos + 6) & ~2078)	and (!$e or ($e = (($f = call_user_func($fn,$data,$pos + 8)) == 8) ? gzinflate($e)// Flags abfragen
	: (($f == 12 and $cfg['bzip']) ? bzdecompress($e) : (!$f ? $e : ""))) or $e === "")				// UnZip
	and strlen($e) == ($g ? call_user_func($fn,$g[0],12,4) : call_user_func($fn,$data,$pos + 22,4))			// Stimmt die Länge?
	and (hash('crc32b',$e,1) == ($g ? call_user_func($fn,$g[0],4,4,1) : call_user_func($fn,$data,$pos + 14,4,1)))) {// Entpackte Daten korrekt?
     if(substr($i,-1) != "/")
      $zip[$i] = $x ? $e : array('data' => $e, 'mtime' => $j);								// Entpackte Daten & Datum sichern
     $i = 0;
    }
    else if(!$g and !(($g = call_user_func($fn,$data,$pos + 6)) & ~2055) and $g % 2 and call_user_func($fn,$data,$pos + 8) == 99 and substr($data,$g = $pos + 30 + $h,2) == "\x01\x99"		// AES-ZIP
	and (($f = call_user_func($fn,$data,$g + 4)) == 2 and !call_user_func($fn,$data,$pos + 14,4) or $f == 1) and $f = call_user_func($fn,$data,$g + 8,1) and $f = ++$f * 64) {		// f: AES-Bits / g: offset extra-header
     if(!$pass)
      return errmsg("Archiv benötigt ein Kennwort (-zp:'password')",$fn);
     foreach($pass as $pw)												// Password-manager befragen
      if(substr(($c = hash_pbkdf2("sha1",$pw,substr($e,0,$f >> 4),1e3,$f / 4 + 16,1)),$f / 4,2) == substr($e,$f >> 4,2))// Kennwort-Hash erstellen und testen
       break;
      else
       $pw = false;
     if($c and $pw and substr($c,$f / 4,2) == substr($e,$f >> 4,2) and substr(hash_hmac("sha1",$h = substr($e,$f / 16 + 2, strlen($e) - ($f / 16 + 2) - 10),substr($c,$f / 8, $f / 8),1),0,10) == substr($e,-10)) {
      for($e = ""; strlen($e) < strlen($h); ) {
       $b = array(substr($h,strlen($e),16),substr($c,0,$f/8),str_pad(pack('V',(strlen($e) >> 4) + 1),16,chr(0)));
       if(isset($aes['openssl']))
        $e .= openssl_decrypt($b[0],"aes-$f-ctr",$b[1],OPENSSL_RAW_DATA,$b[2]);
       elseif(isset($aes['mcrypt']))											// Extension: MCrypt
        $e .= mcrypt_decrypt(MCRYPT_RIJNDAEL_128,$b[1],$b[0],'ctr',$b[2]);
       else
        break;
      }
      if(($e = (($c = call_user_func($fn,$data,$g + 9)) == 8) ? gzinflate($e) : (($c == 12 and $cfg['bzip']) ? bzdecompress($e) : (!$c ? $e : "")) or $e === "")// UnZip
	and strlen($e) == call_user_func($fn,$data,$pos + 22,4) and (($c = call_user_func($fn,$data,$g + 4)) == 1 and call_user_func($fn,$data,$pos + 14,4,1) == hash('crc32b',$e,1) or $c == 2)) {	// Länge & Optional CRC32 überprüfen
       if(substr($i,-1) != "/")												// Nur Dateien eintragen
        $zip[$i] = $x ? $e : array('data' => $e, 'mtime' => $j, 'pass' => $pw, 'bits' => $f);				// Entpackte Daten & Datum sichern
       $i = 0;
      }
      else
       return errmsg("Entschlüsselung ist fehlgeschlagen",$fn);
     }
     else
      return errmsg("Das Kennwort ist falsch",$fn);
    }
    else if(($g = call_user_func($fn,$data,$pos + 6)) % 2 and !($g & ~2063) and (call_user_func($fn,$data,$pos + 14,4) or !call_user_func($fn,$data,$pos + 22,4))) { // Crypto-ZIP
     if(!$pass)
      return errmsg("Archiv benötigt ein Kennwort (-zp:'password')",$fn);
     foreach($pass as $pw) {// Password-manager befragen
      $f = call_user_func($fn,$pw,-1,array(0x12345678,0x23456789,0x34567890));
      if(substr($data,$pos + ($g & 8 ? 11 : 17),1) == substr($f = call_user_func($fn,$e,-2,$f),11,1))			// Kennwort-Hash erstellen und testen
       break;
      else
       return errmsg("Das Kennwort ist falsch",$fn);
     }
     if($f and (!($e = substr($f,12)) or ($e = ($f = call_user_func($fn,$data,$pos + 8)) == 8 ? gzinflate($e) : (($f == 12) ? bzdecompress($e) : (!$f ? $e : "")))// UnZip
	and strlen($e) == call_user_func($fn,$data,$pos + 22,4) and hash('crc32b',$e,1) == call_user_func($fn,$data,$pos + 14,4,1))) { // Länge & CRC32 überprüfen
       if(substr($i,-1) != "/")												// Nur Dateien eintragen
        $zip[$i] = $x ? $e : array('data' => $e, 'mtime' => $j, 'pass' => $pw, 'bits' => $f);				// Entpackte Daten & Datum sichern
       $i = 0;
      }
    }
    if($i) {
     $bug and dbug("ZIP-Fehler: $pos");
     $data .= 0;													// Fehler erkennen (Sourcelänge verändern)
    }
   }
   else															// Alle Header werden übersprungen (Ignoriert)
    $d = $c[2] ? 46 + call_user_func($fn,$data,$pos + 28) + call_user_func($fn,$data,$pos + 30) + call_user_func($fn,$data,$pos + 32)// \x01\x02 (Central directory file header)
	      : ($c[3] ? call_user_func($fn,$data,$pos + 4) + 6								// \x05\x05 (Digital signature)
		      : ($c[4] ? call_user_func($fn,$data,$pos + 20) + 22						// \x05\x06 (End of central directory record)
			      : ($c[5] ? call_user_func($fn,$data,$pos + 4,8) + 12					// \x06\x06 (Zip64 end of central directory record)
				      : ($c[6] ? 20									// \x06\x07 (Zip64 end of central directory locator)
					      : ($c[7] ? call_user_func($fn,$data,$pos + 4,4) + 8			// \x06\x08 (Archive extra data record)
						      : ($c[8] ? 16 : 1))))));						// \x07\x08 (Stream-Header: crc32, df-len, if-len)
  }
#  $bug and dbug($zip,9,'8,zip2array-#');
  if($pos != strlen($data))
   $zip = errmsg("Archiv ist beschädigt oder wird nicht unterstützt",$fn);
 }
 return $zip;
}
function data2zip($files,$pass=false,$time=false) {	// Erstellt aus ein Array ein ZIP-Archiv
 global $cfg;
 $fn = __FUNCTION__;
 if(!is_array($files))
  return errmsg("Unbekannte Parameter",$fn);
 if(!$pass and ifset($cfg['zp']))	// Password von Optionen übernehmen
  $pass = $cfg['zp'] ? reset($cfg['zp']) : false;
 if($pass)				// Prüfen ob Verschlüsselung überhaupt möglich ist
  if(!$aes = init(5,'aes') or !preg_array('/^(openssl|mcrypt)$/i',$aes,1) or !(function_exists('hash_pbkdf2') or init(5,'hashtool'))
	or !(function_exists('hash_algos') or !init(5,'mhash') or !init(5,'sha256')) or !$cfg['zb'])	// Ist Verschlüsslung möglich?
   return errmsg("Keine möglichkeit gefunden die AES-CTR Funktion auszuführen",$fn);
 $zip = $dir = "";			// Leeres Zip-Archiv
 foreach($files as $file => $meta) {	// Array durchgehen
  if(!is_array($meta))
   $meta = array('data' => $meta);
  $time = isset($meta['time']) ? $meta['time'] : ($time ? $time : time());
  $m = "";
  $i = strlen($meta['data']) ? ($cfg['bz'] ? bzcompress($meta['data'],$cfg['bz']) : ($cfg['gz'] ? gzdeflate($meta['data'],$cfg['gz']) : "")) : "";	// Deflate Data
  if(!$i or strlen($i) > strlen($meta['data']))				// Store Data?
   $i = $meta['data'];
  if($pass) {								// Verschlüsselung AES-AE2 (128/192/256)
   $jk = function_exists("openssl_random_pseudo_bytes") ? openssl_random_pseudo_bytes($cfg['zb']/8) : sha1(mt_rand().time());	// key
   $js = substr(hash_hmac('sha256',$file.time().serialize($meta).$pass,$jk,1),0,$cfg['zb']/16);
   $jh = hash_pbkdf2("sha1",$pass,$js,1e3,$cfg['zb']/4+16,1);		// (48,64,80)
   for($k = $m; strlen($k) < strlen($i);) {
    $b = array(	substr($i,strlen($k),16),				// Data
		substr($jh,0,$cfg['zb'] / 8),				// Key
		str_pad(pack('V',(strlen($k) >> 4) + 1),16,"\0"));	// Counter
    if(isset($aes['openssl']))
     $k .= openssl_encrypt($b[0],"aes-$cfg[zb]-ctr",$b[1],OPENSSL_RAW_DATA,$b[2]);
    elseif(isset($aes['mcrypt']) and $x = mcrypt_module_open(MCRYPT_RIJNDAEL_128,'','ctr','')) { // Extension: MCrypt
     mcrypt_generic_init($x, $b[1], $b[2]);				// https://github.com/beyonderyue/aes-ctr-php
     $k .= mcrypt_generic($x, $b[0]);
     mcrypt_generic_deinit($x);
     mcrypt_module_close($x);
    }
    else
     break;
   }
   $m = "\1\x99\7\0\2\0AE".chr($cfg['zb']/64-1).chr((strlen($k) == strlen($meta['data'])) ? 0 : ($cfg['bz'] ? 12 : 8))."\0";	// Extra-Data Header
   $i = $js.substr($jh,$cfg['zb'] / 4,2).$k.substr(hash_hmac("sha1",$k,substr($jh,$cfg['zb'] / 8,$cfg['zb'] / 8),1),0,10);// Salt + Chk + Cipher + Hash
  }
  $k = (($k = utf8($file)) != $file) ? $k : $file;
  $j = ($m ? "\x33" : (($i != $meta['data']) ? chr($cfg['bz'] ? 46 : 20) : "\n"))."\0"
	.pack("v",(($k != $file) ? 2048 : 0) | ($m ? 1 : 0)).($m ? "c" : chr(($i != $meta['data']) ? ($cfg['bz'] ? 12 : 8) : 0))."\0"
	.pack('v*',intval(date('G',$time)) * (1<<11) + intval(date('i',$time)) * (1<<5) + (intval(date('s',$time)) >>1),	// Time
	(max(intval(date('Y',$time)),1980) - 1980) * (1<<9) + intval(date('n',$time)) * (1<<5) + intval(date('j',$time)))	// Date
	.strrev(!$m ? hash("crc32b",$meta['data'],1) : pack("V",0))								// CRC32
	.pack('V*',strlen($i),strlen($meta['data'])).pack('v*',strlen($k),strlen($m));
  $dir .= "PK\1\2\0\0$j".str_repeat("\0",10).pack('V',strlen($zip)).$k.$m;	// Central directory file header
  $zip .= "PK\3\4$j$k$m$i";							// Local file header
 }
 return $zip.$dir."PK\5\6\0\0\0\0".str_repeat(pack('v',count($files)),2).pack('V*',strlen($dir),strlen($zip))."\0\0";
}
function array2json($array,$opt=0,$c=0) {		// Macht aus einem Array eine JSON-Textdatei (opt: 1:utf8, 2:jsmode, 4:utfesc, 8:noGLOBALS)
 global $cfg;
 $fn = __FUNCTION__;
 if(is_array($array)) {
  if($cfg['json'] > 0 and is_callable("json_encode"))
   if($str = json_encode($array))
    return $str;
   elseif($cfg['json'] == 2)
    return errmsg(json_last_error_msg(),$fn);
  if(isset($array[0]) and is_string($array[0]) and strlen($array[0]) == 1 and isset($array[1])
	and (isset($array['s']) or isset($array['u']) or count($array) == 2 and $array[0] == $array[1]))
   $str = '\\'.((($a = ord($array[0])) < 14 and isset($array['s'])) ? substr("01234567btnvfr",$a,1) : (($a < 32) ? 'u'.str_pad(dechex($a),4,0,STR_PAD_LEFT) : $array[0]));
  else {
   $ac = array_keys($array) === array_keys(array_keys($array));
   $str = "";
   foreach($array as $key => $var)
    $str .= ($ac ? "" : (($opt&2 and preg_match('/^(?!\d)\w+$/',$key)) ? $key : '"'.$key.'"').":").(is_bool($var) ? ($var ? "true" : "false")
	: (is_string($var) ? '"'.preg_replace_callback('/(?P<'.($opt&4 ? 'u' : 's').'>[\x00-\x1f"\\\\\/])/',$fn,$opt&1 ? utf8($var,1) : $var).'"'
	: (is_numeric($var) ? $var : ((is_array($var) and $key !== 'GLOBALS' and $c < $GLOBALS['cfg']['jsdp'])
	? call_user_func($fn,$var,$opt,$c+1) : "null")))).",";
   $str = ($ac ? "[" : "{").substr($str,0,-1).($ac ? "]" : "}");
  }
 }
 return isset($str) ? $str : false;
}
function json2array($str,$opt=2,$obj=array()) {		// JSON-Parser mit UTF8-Decoder (opt: 0: JSON, 1: js, 2: fbt)
 global $cfg,$bug;
 $fn = __FUNCTION__;
 if(!$opt and $cfg['json'] > 0 and is_callable("json_decode") and !$val = json_decode($str,constant('JSON_OBJECT_AS_ARRAY')) and $cfg['json'] == 2)
  return errmsg(json_last_error_msg(),__FUNCTION__);
 elseif(!isset($val) or !$val) {
  $bug and dbug($str,17);
  $char = char("09AZaz_");						// Zeichentabelle
  $name = $val = null;							// Name und Value
  $mode = $typ = $sp = 0;						// Mode und Type des Values, sowie Pointer
  $stack = array();							// Stack initialiseren
  while($sp < strlen($str)) {
   if(strpos("\0 \t\r\n",$str[$sp]))					// Whitespace
    $sp += strspn($str," \t\r\n",$sp);					// Zusammenhängenen Whitespace überspringen
   elseif($opt == 2 and $str[$sp] == '#' or $opt and substr($str,$sp,2) == '//')// Einzeiliger Kommentar
    if(($rs = strpos(substr($str,$sp),"\n")) !== false)
     $sp += $rs + strspn($str," \t\r\n",$sp + $rs);
    else
     $sp = strlen($str);
   elseif($opt and substr($str,$sp,2) == '/*')				// Mehrzeiliger Kommentar
    if(($rs = strpos(substr($str,$sp),"*/")) !== false)
     $sp += $rs + 2;
    else
     return errmsg("Kommentar wurde nicht geschlossen",$fn,array($sp => $str));
   elseif(($mode != 2 or !is_null($name)) and !$typ and $rx = strspn($str,"FNTtnf",$sp)	// Bool/Null
 	and (!strcasecmp($rs = substr($str,$sp,5),'false') or !strcasecmp($rs = substr($rs,0,4),$rx = 'true') or !strcasecmp($rs,$rx = 'null'))) {
    $val = ($rx == 'null') ? null : ($rx == 'true');
    $typ = 1;
    $sp += strlen($rs);
   }
   elseif(($opt == 2 or $opt and $mode == 2 and is_null($name)) and !$typ and strspn($str[$sp],substr($char,10)) and $rs = strspn($str,$char,$sp)) {	// Key-String
    $val = substr($str,$sp,$rs);
    $typ = 1;
    $sp += $rs;
   }
   elseif(!$typ and strspn($str,$opt ? '"\'' : '"',$sp)) {		// "String"
    $rs = $sp + 1;
    while($rs = $rx = strpos($str,$str[$sp],$rs)) {			// Nächstes Ende suchen
     while($str[--$rx] == '\\');					// Entwertungszeichen zählen
     if(!(($rs - $rx - 1) % 2))
      break;								// Gerade: Abbruch
     else
      $rs++;								// Ungerade: Weitersuchen
    }
    if($rs) {
     $val = substr($str,$sp+1,$rs-$sp-1);				// RAW-String
     if($opt == 2 and $str[$sp] == "'")					// 'escape'
      $val = str_replace(array("\\\\","\'"),array("\\","'"),$val);
     else {
      if(strcspn($val,"\r\n") != strlen($val))
       return errmsg("Unerlaubter Zeilenumbruch",$fn,array($sp => $str));
      $rx = 0;
      $rz = false;
      while(($rx = strpos($val,"\\",$rx)) !== false) {
       if($ry = strpos("\0/\\\"btnvfr",$val[$rx+1])) {			// Statische Ersetzung
        $rz = substr("\0/\\\"\x08\t\n\v\f\r",$ry,1);
        $ry = 2;
       }
       elseif($opt and $ry = min(strspn($val,substr($char,0,8),$rx+1),3))// Octal-Escape
        $rz = chr(octdec(substr($val,$rx+1,$ry++)));
       elseif($opt and $val[$rx+1] == 'x' and min(strspn($val,substr($char,0,16)."abcdef",$rx+2),2) == 2) {
        $rz = chr(hexdec(substr($val,$rx+2,2)));			// Hex-Escape
        $ry = 4;
       }
       elseif($val[$rx+1] == 'u') {					// UTF-8 Escape
        if($opt and $val[$rx+2] == '{' and $ry = strspn($val,substr($char,0,16)."abcdef",$rx+3) and $val[$rx+3+$ry] == '}') {
         $rz = utf8(array('u0' => substr($val,$rx+3,$ry)));		// Variable
         $ry += 4;
        }
        elseif(strspn($val[$rx+2],"dD") and strspn($val[$rx+3],"89ABba") and min(strspn($val,substr($char,0,16)."abcdef",$rx+4),2) == 2
	and substr($val,$rx+6,2) == '\\u' and strspn($val[$rx+8],"dD") and strspn($val[$rx+9],"CDEFcdef") and min(strspn($val,substr($char,0,16)."abcdef",$rx+10),2) == 2) {
         $rz = utf8(array('u0' => "", 'u1' => substr($val,$rx+2,4), 'u2' => substr($val,$rx+8,4)));
         $ry = 12;							// High & Low
        }
        elseif(min(strspn($val,substr($char,0,16)."abcdef",$rx+2),4) == 4) {// Fixed
         $rz = utf8(array('u0' => substr($val,$rx+2,4)));
         $ry = 6;
        }
       }
       if($rz !== false) {						// Replace
        $val = substr_replace($val,$rz,$rx,$ry);
        $rx += strlen($rz);
        $rz = false;
       }
       else
        $rx++;								// Fail
      }
     }
     $typ = 1;
     $sp = $rs + 1;
    }
    else
     return errmsg("Anführungszeichen nicht abgeschlossen",$fn,array($sp => $str));
   }
   elseif($opt and !$typ and $str[$sp] == '/' ) {			// /Reg/ex
    $rs = $sp + 1;
    while($rs = strpos($str,'/',$rs) and $str[$rs-1] == '\\')
     $rs++;
    if($rs += strspn($str,substr($char,10,52),++$rs)) {
     if(strpos($val = substr($str,$sp,$rs-$sp),"\n") !== false)
      return errmsg("RegEx enthält unerlaubten Zeichenumbruch",$fn,array($sp => $str));
     $typ = 1;
     $sp = $rs;
    }
    else
     return errmsg("RegEx nicht abgeschlossen",$fn,array($sp => $str));
   }
   elseif(($opt or !is_null($name) or $mode < 2) and !$typ and $rs = strspn($str,substr($char,0,10)."+-.eE",$sp)) {	// Number
    $rx = 0;
    if($str[$sp] == '-')						// Negativ-Zeichen
     $rx++;
    if($str[$sp+$rx] == '0')						// Null (Zahl)
     $rx++;
    elseif(strspn($str,substr($char,1,9),$sp+$rx) and $ry = strspn($str,substr($char,0,10),$sp+$rx))	// Int
     $rx += $ry;
    if($str[$sp+$rx] == '.' and $ry = strspn($str,substr($char,0,10),$sp+$rx+1))// Float
     $rx += $ry + 1;
    if(!strcasecmp($str[$sp+$rx],'e') and $rx += strspn($str,"+-",$sp+$rx+1) ? 2 : 1 and $ry = strspn($str,substr($char,0,10),$sp+$rx))	// Ext
     $rx += $ry;
    if($rs == $rx) {							// Alles korrekt gefunden
     $val = substr($str,$sp,$rs) + 0;					// Nummer Finalisieren
     $typ = 1;
     $sp += $rs;
    }
    else
     return errmsg("Keine gültige Zahl",$fn,array($sp => $str));
   }
   elseif($typ and is_null($name) and $str[$sp] == ':') {		// name:
    if($mode == 2 and is_string($val) or $opt == 2 and $mode == 1 and is_int($val)) {
     $name = $val;
     $val = null;
     $typ = 0;
     $sp++;
    }
    else
     return errmsg("Keyname ist kein String oder Zahl (Array)",$fn,array($sp => $str));
   }
   elseif($str[$sp] == ',')						// value,
    if($typ or $mode == 1) {						// Im Array oder Object
     if(!is_null($name))
      $obj[$name] = $val;
     elseif($mode == 1)
      $obj[] = $val;
     else
      return errmsg("Inhalt lässt sich nicht anbinden",$fn,array($sp => $str));
     $name = $val = null;
     $typ = 0;
     $sp++;
    }
    else
     return errmsg("Keinen Wert definiert",$fn,array($sp => $str));
   elseif($rs = strpos("\0\0[]{}",$str[$sp])) {				// Objekte / Arrays
    if(!($rs&1)) {							// open Object
     if(count($stack) > $cfg['jsdp'])					// Maximale tiefe erreicht?
      return errmsg("Stapelüberlauf",$fn,array($sp => $str));		// ABBRUCH!
     $stack[] = array($obj,$name,$mode << 2 | $rs >> 2 | 2);		// Werte auf Stack sichern
     $obj = array();							// Neues Object
     $name = $val = null;						// Name/Value löschen
     $mode = ($rs >> 2) +1;
     $typ = 0;
    }
    else {								// close Object
     if(!$stack or !$end = array_pop($stack))				// Letzter Eintrag vom Stack
      return errmsg("Verschachtelung ist fehlerhaft",$fn,array($sp => $str));
     if($end[2] & 3 == 2 and $rs != 3 or $end[2] & 3 == 3 and $rs != 5)	// Objekt korrekt geschlossen
      return errmsg("Object/Array wurde falsch geschlossen",$fn,array($sp => $str));
     if($typ)								// Letzter Wert wurde nicht mit einem "," abgeschlossen
      if(!is_null($name))
       $obj[$name] = $val;
      elseif($mode == 1)
       $obj[] = $val;
      else
       return errmsg("Inhalt lässt sich nicht an das Ende des Objekts anbinden",$fn,array($sp => $str));
      $val = $obj;
      $obj = $end[0];							// Object aus dem Stack setzen
      $name = $end[1];
      $typ = $end[2] & 3;
      if(!$mode = $end[2] >> 2)
       return $obj += $val;						// Den Rest ignorieren
    }
    $sp++;								// Stringzeiger erhöhen
   }
   else
    return errmsg("Unbekanntes oder nicht erlaubtes Zeichen",$fn,array($sp => $str));
  }
 }
 return $obj ? $obj : $val;
}
function textTable($table,$cols=0,$col="|",$row="\n",$tab=" ",$sp=" ") { // Text als Text-Tabelle konvertieren [PurePHP]
 $fn = __FUNCTION__;
 if($cols == -1)		// Creole-Aufruf
  return preg_replace_callback('/\{\{\{(?:tt|77)((?:,[^,\}]*)*)\}(.*?)\}\}/s',$fn,$table);
 elseif(is_array($table)) {	// Creole-Funktion
  if($var = ifset($table[1],'/,([^,]*)/a')) {
   array_unshift($var[1],$table[2]);
   $opts = $var[1];
   if(ifset($opts[4],'/;/'))
    $opts[4] = explode(';',$opts[4]);
   if(ifset($opts[5],'/;/'))
    $opts[5] = explode(';',$opts[5]);
  }
  else
   $opts = array($table[2]);
  return call_user_func_array($fn,$opts);
 }
 elseif(!$cols and $cols = $GLOBALS['cfg']['wrap'])
  $cols -= trim(is_array($tab) ? $tab[0] : $tab) ? 3 : 2;
 $esc = array();
 $pos = 0;
 $p = "[\x80-\xbf]";
 while(preg_match("/\x7f|[\xc0-\xdf]$p|[\xe0-\xef]$p{2}|[\xf0-\xf7]$p{3}|[\xf8-\xfb]$p{4}|[\xfc-\xfd]$p{5}|\xfe$p{6}
	|\\\\(u\{[\da-f]+\}|u[dD][89abAB][\da-fA-F]{2}\\\\u[dD][c-fC-F][\da-fA-F]{2}|u[\da-fA-F]{4})|(&\#(\d+|x[\da-fA-F]+);)/x",substr($table,$pos),$m,PREG_OFFSET_CAPTURE)) {
  $table = substr_replace($table,"\x7f",$pos + $m[0][1], strlen($m[0][0]));
  $esc[] = $m[0][0];
  $pos += $m[0][1] + 1;
 }
 $lines = explode($row,trim($table));
 $lens = $max = $min = $ali = $table = array();
 $col = array('/(?<!\\\\)'.preg_quote($col,'/').'/','/\\\\(?='.preg_quote($col,'/').')/');
 foreach($lines as $kl => $line) {
  $table[$kl] = preg_replace($col[1],'',preg_split($col[0],$line));
  foreach($table[$kl] as $kr => $rift)
   if(preg_match('/^(\s*)(.*?)(\s*)$/',$rift,$var)) {
    $table[$kl][$kr] = $var[2];
    $ali[$kl][$kr] = ($var[1] and $var[3]) ? STR_PAD_BOTH : (($var[1] and !$var[3]) ? STR_PAD_LEFT : STR_PAD_RIGHT);
    $max[$kr] = max(isset($max[$kr]) ? $max[$kr] : 0, strlen($var[2]));
   }
 }
 if($cols and array_sum($max) + count($max) -1 > $cols) {
  $cols = max($cols,count($max) * 2);
  foreach($table as $kl => $line)
   foreach($line as $kr => $rift)
    $min[$kr] = max(isset($min[$kr]) ? $min[$kr] : 0,max($lens[$kl][$kr] = array_map('strlen',explode(is_array($sp) ? $sp[$kr] : $sp,$table[$kl][$kr]))));
  while(($cols and array_sum($max) + count($max) -1 > $cols) and array_sum($max) > array_sum($min)) {
   $mlen = array();
   foreach($lens as $kl => $line) {
    $var = count($line) -1;
    $key = array();
    foreach($line as $kr => $rift) {
     $var += array_sum($rift) + count($rift) -1;
     if(!$key or $key[1] < count($rift))
      $key = array($kr,count($rift));
    }
    if(!$mlen or $mlen[1] <= $var and $mlen[3] < $key)
     $mlen = array_merge(array($kl,$var),$key);
   }
   if($mlen)
    array_pop($lens[$mlen[0]][$mlen[2]]);
   else
    break;
   $max = $min;
   foreach($lens as $kl => $line)
    foreach($line as $kr => $rift)
     $max[$kr] = max(isset($max[$kr]) ? $max[$kr] : 0, array_sum($rift) + count($rift) -1);
  }
  while(array_sum($max) + count($max) -1 > $cols)
   $max[array_search(max($max),$max)]--;
 }
 $out = array();
 foreach($table as $tk => $line) {
  $wrap = 0;
  foreach($line as $key => $var) {
   $line[$key] = explode($row,wordwrap($var,$max[$key],$row,true));
   $wrap = max($wrap,count($line[$key]));
  }
  for($a=0; $a < $wrap; $a++) {
   $buf = "";
   foreach($line as $key => $var)
    $buf .= str_pad( isset($line[$key][$a]) ? $line[$key][$a] : "",$max[$key],is_array($sp) ? $sp[$key] : $sp,$ali[$tk][$key])
	.(is_array($tab) ? (isset($tab[$key]) ? $tab[$key] : "") : $tab);
   $out[] = rtrim($buf);
  }
 }
 $table = implode($row,$out);
 $m = 0;
 while(($m = strpos($table,"\x7f",$m)) !== false) {
  $table = substr_replace($table,$esc[0],$m,1);
  $m += strlen(array_shift($esc));
 }
 return $table;
}
function request($method,$page='/',$body=0,$head=0,$host=0,$port=0,$sock=0,$user=0,$pass=0) { // HTTP-Request durchführen
 global $cfg,$bug,$strftime;
 if(!$method) {								// Unterfunktion: HTTP Auth zusammenstellen ($page,$arg,$auth)
  if(is_string($head) and preg_match('/^(\w+)\s+(.*)$/',$head,$m)) {	// Erste Anmeldung
   $head = array();
   $m[1] = strtolower($m[1]);
   if($m[1] == 'basic') {
    $head['username'] = $body['user'];
    $head['password'] = $body['pass'];
    $head[$m[1]] = "Basic ".base64_encode(implode(":",$head));		// Absolut unknackbar ;-)
    $cfg['auth'] = $head;
   }
   elseif($m[1] == 'digest' and preg_match_all('/(\w+)\s*=\s*(\\\\?["\']?)(.*?)\2(,\s*|\s*$)/',$m[2],$m)) {// HTTP Auth Digest
    $bug and dbug($m,4);
    $head = array_merge(array(
	'username' => $body['user'],
	'nc' => 0,
	'cnonce' => substr(hash('md5',time().rand()),16),
    ),array_combine($m[1],$m[3]));
   }
   if(isset($head['username']))
    $bug and dbug("HTTP Auth ".(isset($head['basic']) ? "Basic" : "Digest")." für $head[username]",5);
  }
  if(is_array($head))
   if(isset($head['basic']))						// HTTP Auth Basic
    $method = $head['basic'];
   elseif(isset($head['username'])) {					// HTTP Auth Digest
    $head['nc'] = str_pad(intval($head['nc']) + 1,8,0,STR_PAD_LEFT);	// Zähler erhöhen
    $head['uri'] = $page;						// Aktuelle Seite
    $hash = ifset($head['algorithm']) ? strtolower(str_replace('-','',$head['algorithm'])) : 'md5';// Hash Methode festlegen
    if($head['response'] = hash($hash,hash($hash,"$head[username]:$head[realm]:$body[pass]")
	.":$head[nonce]:$head[nc]:$head[cnonce]:$head[qop]:".hash($hash,strtoupper(preg_replace('/-.*/','',$body['method'])).":$page"))) {
     $cfg['auth'] = $head;				// Werte sichern
     foreach($head as $key => $var)
      $head[$key] = "$key=\"$var\"";
     $method = "Digest ".implode(', ',$head);		// Anmeldedaten zusammenstellen
    }
   }
  return $method;
 }
 elseif(is_array($method))				// Parameter aus Array holen
  extract($method);
 elseif(is_string($method) and $val = ifset($method,	// Parameter aus String holen (GET-array)
	'/^(https?):(?:\[([^\[\s\]]+)\])?\/\/(?:([^@:\s]+):)?(?:([^@\s]+)@)?
	((?:(?!-)[a-z\d-]+(?<!-)\.)+(?!-)[a-z\d-]+(?<!-)|0*(?:\d{1,2}|1\d{2}|2[0-4]\d|25[0-5])(?:\.0*(?:\d{1,2}|1\d{2}|2[0-4]\d|25[0-5])){3}
	|\[:?(?:[\da-f]{0,4}:){0,7}[\da-f]{0,4}\])(?::(\d{1,5}))?(\/[^\#?\s]*)?(?:\?([^\s]*))?(?:\#(.+?))?(\#?$)/ix')) {
  $arg = array();
  foreach(explode(',','sock,mode,user,pass,host,port,page,body,uipw') as $key => $var)
   if($var and ifset($val[$key+1]))
    $$var = $arg[$var] = ($var == 'host') ? preg_replace('/^\[|\]$/','',$val[$key+1]) : $val[$key+1];
  $method = ifset($mode) ? $mode : 'GET';
  if(!$port)						// Port festlegen
   $port = $arg['port'] = ($sock == 'http') ? 80 : 443;
  if($val[10])
   return $arg;
 }
 $fn = __FUNCTION__;
 foreach(explode(',','sock,host,port,user,pass') as $var)// Host, Port, user & pass setzen
  if(!$$var)
   $$var = $cfg[$var];
 if(!$head)						// Head Initialisieren
  $head = $cfg['head'];
 if($mode = preg_match('/^(\w+)(?:-(.+))?/',$method,$var)) {
  $method = strtoupper($var[1]);
  $mode = isset($var[2]) ? $var[2] : (($var[1] == strtolower($var[1])) ? 'array' : false);// Result-Modus festlegen
 }
 $arg = array_flip(explode(',','method,mode,sock,host,port,page,head,body,user,pass'));// Parameter sichern
 foreach($arg as $key => $var)
  $arg[$key] = $$key;
 $http = $sock;
 if($sock = ($sock == 'auto' and (floor($port/10) == 8 or $port == 8080 or $port == $cfg['upnp'][0]) or $sock == 'http') ? '' : (ifset($sock,'/^(ssl|tls)$/') ? "$sock://" : 'ssl://'))
  if(!$cfg['ssl'])
   if($var = init(5,'openssl')) {
    $cfg['ssl'] = $var;
    $bug and dbug("OpenSSL nachgeladen: $var",9);
   }
   else
    return errmsg("8:OpenSSL nicht verfügbar",$fn);
 if($var = ifset($cfg['proxy'],'/^([\w.-]+):(\d+)$/')) {// Primitive Proxy-Umleitung - Ohne Anmeldung
  if(!isset($cfg['http']))
   $bug and dbug("Benutze Proxy: $var[0]",9);
  $page = "http".($sock ? "s" : "")."://$host:$port$page";
  $head['host'] = $host; // .($sock ? ":$port" : "");
  $host = $var[1];
  $port = $var[2];
 }
 $bug and dbug("$sock$host:$port",5);
 if(!isset($cfg['fail']["$host:$port"]) and function_exists('stream_socket_client')
	and $fp = @stream_socket_client(($sock ? $sock : "tcp://")."$host:$port",$errnr,$errstr,$cfg['tout'],
	STREAM_CLIENT_CONNECT,stream_context_create(ifset($http,'/auto|https/i')
	? array('ssl' => array('verify_peer' => false, 'verify_peer_name' => false)) : array()))
	or $fp = @fsockopen($sock.$host,$port,$errnr,$errstr,$cfg['tout'])) {// Verbindung aufbauen
  if($cfg['tout'])
   stream_set_timeout($fp,$cfg['tout']);		// Timeout setzen
//  stream_set_blocking($fp,0);
  if($method == 'POST') {				// POST-Request vorbereiten
   if(is_array($body)) {				// Multipart-Post vorbereiten
    $row = "---".hash('md5',rand().time());
    foreach($body as $key => $var) {
     $val = array('','');
     if(is_array($var))					// Unter-Header im Header
      foreach($var as $k => $v)
       if($k == '')					// Content
        $var = $v;
       elseif($k == 'filename')				// Weitere Angaben im Header
        $val[0] .= "; $k=\"$v\"";
       else						// Sub-Header
        $val[1] = "$k: $v\r\n";
     $body[$key] = "$row\r\nContent-Disposition: form-data; name=\"$key\"$val[0]\r\n$val[1]\r\n$var\r\n";
    }
    $body = implode('',$body)."$row--\r\n";
    $var = "multipart/form-data; boundary=$row";
   }
   else
    $var = 'application/x-www-form-urlencoded';		// Standard Post
   if(!isset($head['content-type']))
    $head['content-type'] = $var;
   if(!isset($head['content-length']))
    $head['content-length'] = strlen($body);
   $body = "\r\n$body";
  }
  elseif($method == 'GET' and $body) {			// GET-Request vorbereiten
   if(is_array($body))
    $body = http_build_query($body);
   $page .= "?$body";
   $body = "\r\n";
  }
  elseif($method == 'PUT' and $body) {			// PUT-Request vorbereiten
   if(!isset($head['content-type']) and preg_match('/^\{.*\}$/s',$body))
    $head['content-type'] = 'application/json';
   if(!isset($head['content-length']))
    $head['content-length'] = strlen($body);
   $body = "\r\n$body";
  }
  else
   $body = "\r\n";
  if(!isset($head['host']))				// Host zum Header hinzufügen
   $head['host'] = $host;
  if($cfg['auth'] and $auth = call_user_func($fn,0,$page,$arg,$cfg['auth']))// HTTP Auth in folge
   $head['Authorization'] = $auth;
  if(!isset($head['connection']))			// Connection zum Header hinzufügen
   $head['connection'] = "close";
  foreach($head as $key => $var) {			// Header vorbereiten
   $k = $key;
   if($cfg['php'][3] > 5.3)
    $k = ucwords($key,'-');
   elseif(preg_match_all('/(?<=^|-)[a-z]/',$k,$m,PREG_OFFSET_CAPTURE))	// ucwords für PHP 5.3 und älter
    for($a=count($m[0])-1; $a >= 0; $a--)
     $k = substr_replace($key,strtoupper($m[0][$a][0]),$m[0][$a][1],strlen($m[0][$a][0]));
   $head[$key] = "$k: $var";
  }
  $head = "HTTP/1.1\r\n".implode("\r\n",$head)."\r\n";	// Header Finalisieren
  $bug and dbug("$method $page".(($cfg['dbug'] & 1<<7) ? " $head$body\n\n" : ''),5,$fn);// Debug Request
  fwrite($fp,"$method $page $head$body");		// Request Absenden
  if($mode == 'putonly')				// Nur Upload durchführen
   return fclose($fp);
  $head = array();
  $header = "";
  while($a = trim($b = fgets($fp,$cfg['sbuf']))) {	// Alle Header herunterladen
   $header .= $b;
   if(preg_match('/^([\w-]+):\s*(.*)$/',$a,$b))
    $head[ucwords($b[1])] = $b[2];
   elseif(preg_match('!^HTTP/[\d.]+\s*(\d+)\s*(.+?)\s*$!im',$a,$b)) {// HTTP_Code abfangen
    $head[] = $a;
    $head['HTTP_Code'] = $b[1];	// Error-Code
    $head['HTTP_Info'] = $b[2];	// Error-Name
   }
  }
  if(!isset($head['HTTP_Code'])) {			// Request fehlgeschlagen und als Timeout Kennzeichnen
   $head['HTTP_Code'] = 504;
   $head['HTTP_Info'] = "Timeout";
  }
  $cfg['http'] = $head;					// Header Global sichern
  if($method == 'HEAD' or $mode == 'header') {		// Nur Header herunterladen
   fclose($fp);
   return $head;
  }
  if($head['HTTP_Code'] >= 400) {			// Blacklist erkennen
   fclose($fp);
   if($head['HTTP_Code'] == 401 and !isset($arg['head']['Authorization']) and isset($head['WWW-Authenticate'])
	and $auth = call_user_func($fn,0,$page,$arg,$head['WWW-Authenticate'])) {// HTTP Auth
    $arg['head']['Authorization'] = $auth;
    return call_user_func($fn,$arg);
   }
   $bug and dbug((($cfg['dbug'] & 1<<7) ? $header : preg_replace('/\n.*$/s','',$header))."\n\n",6,$fn);// Debug Response
   return errmsg("16:HTTP-Fehler: $head[HTTP_Code] $head[HTTP_Info] $page",$fn);
  }
  $size = ifset($head['Content-Length']) ? $head['Content-Length'] : 0;
  $sm = $rp = "";
  if(preg_match('/^(?:save|down(?:load)?|(stream)):(.*?(\.gz)?)($)/i',$mode,$file)) {	// Download -> Datei
   if(!feof($fp)) {					// Nur weitermachen wenn noch Daten kommen
    $var = ifset($head['Content-Disposition'],'/^(?:attachment;\s*)?filename=(["\']?)(.*?)\1$/mi');
    $gz = $file[3];					// GZip komprimieren?
    if($file[1] and isset($GLOBALS[$file[2]])) {
     $sm = $GLOBALS[$file[2]];
     $file = $var ? $var[2] : 'STREAM-DATA';
    }
    elseif(is_dir($file = $file[2]))
     $file = realpath($file)."/".preg_replace($cfg['fesc'],$cfg['frep'],$var ? $var[2] : basename(urldecode($page)));
    $bug and dbug("Downloade '".basename($file)."'".($size ? " ".number_format($size,0,'.',',')." Bytes" : ""));
    $a = $b = 0;					// Antwort vorbereiten
    $temp = $cfg['load'] ? $file.$strftime($cfg['load']) : $file;	// Dateiname erweitern
    if($sp = $sm or ($sp = $gz ? $cfg['zlib']['open']($temp,'w'.$cfg['zlib']['mode']) : fopen($temp,'w'))) {
     if(ifset($head['Transfer-Encoding'],'chunked'))	// Chunked decodieren
      while(!feof($fp) and $var = fgets($fp,$cfg['sbuf'])) {				// Chunk-Länge holen
       $len = preg_match('/^([\da-f]+)\s*$/i',$var,$m) ? hexdec($m[1]) : 0;		// Chunk-Länge ermitteln
       while(!feof($fp) and $buf = ($len > $cfg['sbuf']) ? $cfg['sbuf'] : $len) {	// Buffer-Länge nicht überschreiten
        $len -= $buf;					// Restlänge bestimmen
        $var = "";					// Buffer setzen
        while(strlen($var) < $buf)			// Soll-Daten WIRKLICH gelesen?
         $var .= fread($fp,$buf-strlen($var));		// Daten in Buffer lesen
        if($gz)						// Buffer schreiben
         $cfg['zlib']['write']($sp,$var);
        else
         fwrite($sp,$var);
        $a += strlen($var);				// Fortschritts-Anzeige berechnen
        $c = $size ? floor($a / max($a,$size) * max($cfg['wrap']-1,10)) - $b : 1;
        $bug and dbug(str_repeat(".",$c),0,10);		// Download-Anzeige
        $b += $c;
       }
       fgets($fp,$cfg['sbuf']);				// Pad-Daten überspringen
      }
     else						// Normaler Download
      while(!feof($fp) and $var = fread($fp,$cfg['sbuf'])) {
       if($gz)
        $cfg['zlib']['write']($sp,$var);
       else
        fwrite($sp,$var);
       $a += strlen($var);
       $c = $size ? floor($a / max($a,$size) * max($cfg['wrap']-1,10)) - $b : 1;
       $bug and dbug(str_repeat(".",$c),0,10);		// Download-Anzeige
       $b += $c;
     }
     if(!$sm)						// Im Stream den File-Handler nicht schließen
      if($gz)
       $cfg['zlib']['close']($sp);
      else
       fclose($sp);
     $bug and dbug("\n",0,8);				// Download-Anzeige abschließen
     if(!$a) {						// Wurde wirklich was heruntergeladen?
      unlink($temp);
      return errmsg("8:Download Fehlgeschlagen: Keine Daten erhalten",$fn);
     }
     else {
      if($cfg['load']) {
       if(file_exists($file))
        unlink($file);
       rename($temp,$file);				// Vollständige Datei richtig umbenennen
      }
      touch($file,isset($head['Last-Modified']) ? strtotime($head['Last-Modified']) : time());
     }
    }
    else
     return errmsg("32:$file kann nicht zum Schreiben geöffnet werden",$fn);
   }
   else
    return errmsg("8:Download abgebrochen: Keine Daten erhalten",$fn);
  }
  else {						// Daten nur lesen
   if(preg_match('/^seek:([-+]?)(\d+)(?:-(\d+))?$/i',$mode,$var)) {// Nur einen Teil lesen (Seek:-+<offset>-<size>)
    fseek($fp,intval($var[2]),ifset($var[1]) ? SEEK_CUR : SEEK_SET);
    if(ifset($var[3]))
     $size = intval($var[3]);
   }
   while(!feof($fp) and $var = fread($fp,$cfg['sbuf'])) {
    $rp .= $var;
    $bug and dbug(".",6,10);				// Download-Anzeige
   }
   $meta = stream_get_meta_data($fp);
   if($meta['timed_out'] )
    $err = "Timeout: Keine Reaktion nach $cfg[tout] Sekunden";
   elseif(!$meta['eof'])				// Sollte nie auftreten und macht bei ssl probleme
    while($meta = stream_get_meta_data($fp) and !$meta['eof'])	// Solange was runterladen bis es NICHTS mehr gibt
     while(!feof($fp) and $var = fread($fp,$cfg['sbuf'])) {
      $rp .= $var;
      $bug and dbug(".",6,10);				// Download-Anzeige
     }
   if(ifset($head['Transfer-Encoding'],'chunked'))	// Chunked decodieren
    for($vas=$rp, $rp=''; $vas; $vas=trim($vas)) {
     $rp .= substr($vas,$pos = strpos($vas,"\r\n") +2,$len = intval($vas,16));
     $vas = substr($vas,$pos + $len);
    }
  }
  if(ifset($err))
   $bug and dbug($meta,7,'Stream-Metadata');
  fclose($fp);
  $bug and dbug("\n",6,8);				// Download-Anzeige abschließen
  $bug and dbug((($cfg['dbug'] & 1<<7) ? "$header$rp" : preg_replace('/\n.*$/s','',"$header\n$rp"))."\n\n",6,$fn);// Debug Response
  $cfg['body'] = $rp;					// Download-Content in Globale Variable sichern
  if($mode == 'array') {				// Ausgabe mit HTTP-Header
   $fp = $head;
   $fp[1] = $rp;
  }
  elseif(substr($mode,0,4) == 'save')
   $fp = $head;
  else							// Nur Netto-Daten zurückgeben
   $fp = $rp;
 }
 else {
  $err = "$host:$port - Fehler $errnr: $errstr";
  if(!isset($cfg['fail']["$host:$port"]))
   $cfg['fail']["$host:$port"] = "$errnr: $errstr";
 }
 if(ifset($err))
  errmsg("16:$err",$fn);
 return $fp;
}
function login($pass=0,$user=0,$uipw=0,$sid=0) {	// In der Fritz!Box einloggen
 global $cfg,$bug;
 $fn = __FUNCTION__;
 if(is_array($pass)) {					// Login-Response berechnen
  $bug and dbug($pass[0],6);
  $preg = "(2(\\$\\d+\\$[\\da-f]+){2}|[\\da-f]+)";	// Ausdruck um Challenge zu erhalten
  if(preg_match("!<Challenge>$preg</Challenge>!i",$pass[0],$var)
	or preg_match("/(?:security:status\/challenge.*?|\"?challenge\"?:)\"?$preg\"?,?\s*(\"|$)/mi",$pass[0],$var)) {
   $bug and dbug("Kodiere Kennwort aus Challenge: $var[1] - OS ".(($var[1][1] == '$') ? '7.24' : '4.74'),9);
   $hash = (function_exists('hash_pbkdf2') and substr($var[1],0,2) == '2$' and $var = explode('$',$var[1]))
	? "response=$var[4]$".hash_pbkdf2('sha256',hash_pbkdf2('sha256',utf8($pass[1],1),pack("H*",$var[2]),$var[1],32,true),pack("H*",$var[4]),$var[3],64,false)	// Ab OS7.24
	: "response=$var[1]-".hash('md5',preg_replace('!.!',"\$0\0","$var[1]-$pass[1]")); // Ab OS4.74
   if($pass[2] and $cfg['fiwa'] == 100)
    $cfg['fiwa'] = (substr($pass[2],-4) == '.lua') ? (isset($var[4]) ? '724' : '530') : '474';
   $bug and dbug($hash,9);
   return $hash;
  }
  else
   return errmsg("12:Keine Challenge erhalten (".((substr($pass[2],-4) == '.lua') ? 'lua' : 'xml').")",$fn);
 }
 elseif(is_bool($pass) and !$pass and !$sid) {		// Firmware-Version ermitteln
  if($cfg['fiwa'] == 100) {
   $bug and dbug("Ermittle Boxinfos");
   if($data = request('GET','/jason_boxinfo.xml')) {	// BoxInfos holen
    $bug and dbug($data,4);
    $cfg['boxinfo'] = xml2array(preg_replace('/\b[jeq]:(?=\w)/','',$data));
    $cfg['boxinfo']['Time'] = strtotime($cfg['http']['Date']);
    if(preg_match('/^\d+\.0*(\d+?)\.(\d+)(-\d+)?$/',$cfg['boxinfo']['Version'],$var)) // Firmware-Version sichern
     $cfg['fiwa'] = $var[1].$var[2];
   }
  }
  return (($fw = $cfg['fiwa']) != 100 and ($user and $fw < $user or $uipw and $fw > $uipw)) ? false : $fw; // Optional: min:$user & max:$uipw
 }
 else {							// Normaler Aufruf
  $login = array("/login_sid.lua","/cgi-bin/webcm",array('getpage' => "../html/login_sid.xml"),"/login.lua","/twofactor.lua");
  $preg = '/<SID>(\w+)<\/SID>/i';
  if($sid) {						// SID-Session bestätigen lassen
   if($rp = request('GET',"$login[0]?sid=$sid") and preg_match($preg,$rp,$var) and $var[1] == $sid) {
    if($cfg['fiwa'] == 100)
     $cfg['fiwa'] = 530;
   }
   elseif($rp = request('GET',$login[1],$login[2] + array('sid' => $sid)) and preg_match($preg,$rp,$var) and $var[1] == $sid) {
    if($cfg['fiwa'] == 100)
     $cfg['fiwa'] = 474;
   }
   else
    $sid = false;					// SID ist ungültig
   return $sid;						// SID zurückgeben
  }
  else
   $sid = $rp = $err = false;
  call_user_func($fn,false);				// Firmware ermitteln
  if(isset($cfg['fail']["$cfg[host]:$cfg[port]"]))
   return errmsg("8:Host '$cfg[host]:$cfg[port]' antwortet nicht",$fn);
  foreach(array('user','pass','uipw') as $var)		// User & Pass setzen
   if(($var != 'uipw' or $cfg['fiwa'] < 500) and !$$var)
    $$var = $GLOBALS['cfg'][$var];
  if($cfg['fiwa'] < 500 and $uipw) {			// Passwordanmeldung mit Fernwartung
   $pass = $uipw;
   $user = false;
  }
  if($cfg['fiwa'] > 723 and !$user) {			// Anmeldung ab Fritz!OS 7.24+ ohne Benutzernamen
   $bug and dbug("Suche Benutzernamen");
   if($rp = request('GET',$login[0]) and (preg_match_all('!<User[^>]*>(fritz\d+)</User>!i',$rp,$var) and count($var[1]) == 1
	or preg_match_all('!<User[^>]*>([\w\s,.-]+)</User>!i',$rp,$var) and count($var[1]) == 1)) {
    $bug and dbug("Nutze: ".$var[1][0]);
    $user = $cfg['user'] = $var[1][0];
   }
   else
    return errmsg("12:Keinen Benutzernamen angegeben",$fn);
  }
  $txt = ($user ? " $user@" : " ")."$cfg[host] - Methode";
  if(!$sid and ($cfg['fiwa'] == 100 or $cfg['fiwa'] > 529)) { // Login lua ab 05.29 und 7.24
   $bug and dbug("Login$txt SID.lua (5.30)");
   if($rp = request('GET',$login[0].(($cfg['fiwa'] >= 724 and $cfg['livs'] != 1 and (function_exists('hash_pbkdf2') or init(5,'hashtool'))
	and (function_exists('hash_algos') or init(5,'mhash') or init(5,'sha256'))) ? "?version=2" : ""))
	and ($auth = call_user_func($fn,array($rp,$pass,$login[0]))) and $rp = request('POST',$login[0],($user ? "$auth&username=$user" : $auth)) and preg_match($preg,$rp,$var)) {
    if($auth = ifset($rp,'/<Name>(\w+)<\/Name>\s*<Access>(\w+)<\/Access>/ia')) {
     $cfg['auth'] = array_combine($auth[1],$auth[2]);
     $bug and dbug("Benutzerrechte: ".implode(", ",$auth[1]),9);
    }
    if($cfg['fiwa'] == 100)
     $cfg['fiwa'] = 530;
    if(hexdec($var[1]) != 0)
     $sid = $var[1];
    else
     $err = ", SID.lua ist ungültig";
   }
   elseif(!$rp and !$err)
    $err = ", keine Antwort";
  }
  if(!$sid and ($cfg['fiwa'] == 100 or $cfg['fiwa'] > 473) and $cfg['livs'] < 2) { // Login cgi ab 04.74 (Zwischen 4.74 bis 5.29)
   $bug and dbug("Login$txt SID.xml (4.74)");
   if(($rp = request('GET',$login[1],$login[2]) and $auth = call_user_func($fn,array($rp,$pass,$login[1])) or $rp = request('GET',$login[3]) and $auth = call_user_func($fn,array($rp,$pass,$login[1])))
	and $rp = request('POST',$login[1],http_build_query($login[2])."&login:command/$auth") and preg_match($preg,$rp,$var)) {
    if($cfg['fiwa'] == 100)
     $cfg['fiwa'] = 474;
    if(hexdec($var[1]) != 0)
     $sid = $var[1];
    elseif(!$err)
     $err = ", SID.xml ist ungültig";
   }
  }
  if(!$sid and ($cfg['fiwa'] == 100 or $cfg['fiwa'] < 490) and $cfg['livs'] < 1) { // Login classic bis 4.89 (z.B. FRITZ!Repeater N/G)
   $bug and dbug("Login$txt PlainText");
   if($var = request('POST',$login[1],http_build_query(array('login:command/password' => $pass))) and !preg_match('/Anmeldung|logincheck\.lua/',$var))
    $sid = true;
   elseif(!$var and !$err)
    $err = ", keine Antwort";
  }
  elseif($sid and $var = xml2array($rp) and ifset($var['SessionInfo']))
   $cfg['sessioninfo'] = $var['SessionInfo'];
  if($cfg['fiwa'] > 668 and $sid and $tfa = (($uipw and is_bool($uipw) or !$uipw) and $cfg['totp'] and (is_string($cfg['totp']) or !$cfg['uipw'])) ? $cfg['totp']
	: ((($uipw and is_bool($uipw) or is_bool($cfg['totp']) and $cfg['totp']) and $cfg['uipw']) ? $cfg['uipw'] : $uipw)) {	// Zwei-Faktor-Authentisierung
   $done = $cfg['2fa'] = false;	# Besten Dank an Alexander Palm: (https://www.alexander-palm.de/2022/10/29/fritzbox-tools-mein-retter/)
   if(is_string($tfa)) {
    if(strlen(preg_replace('/\W/','',$tfa)) != 32 and file_exists($tfa)) { // Prüfen ob Token/Key ein Datei ist
     $bug and dbug("Lade $tfa nach");
     $tfa = file_contents($tfa);			// Token/Key von Datei laden
    }
    if(!ifset($tfa,'/^\d{6}$/')) {			// Prüfen ob es kein Token ist
     $tfa = otpauth($tfa,1,(ifset($cfg['date']) and $cfg['stim'] == $cfg['time']) ? $cfg['date'] : $cfg['time']);	// Token aus Key erstellen
     $bug and dbug("Generiere 2fa-Token: $tfa");
    }
    else
     $bug and dbug("Token: $tfa");
   }
   $bug and dbug("Starte Zwei-Faktor-Authentisierung");
   if($rp = request('POST',$login[4],http_build_query(array('xhr' => 1, 'sid' => $sid, 'tfa_start' => "", 'no_sidrenew' => ""))) and $m = ifset($rp,'/"state":"([^"]*?\\b(button|googleauth|dtmf;\d+)\\b[^"]*?)"/')) {
    $d = 0;
    $info = "Bitte an der Fritz!Box in den nächsten $cfg[tout] Sekunden mit einer Taste bestätigen"
	.(($var = ifset($m[1],'/\bdtmf;(\d+)\b/')) ? " oder wählen Sie *1$var[1] mit dem Telefon" : "")."!";
    if($cfg['fiwa'] > 689 and ifset($m[1],'/\\bgoogleauth\\b/') and ifset($tfa,'/^\d{6}$/')) { // Google Authenticator (Funktioniert ohne https:// erst ab Fritz!OS 7.20)
     sleep(1);
     request('POST',$login[4],http_build_query(array('xhr' => 1, 'sid' => $sid, 'tfa_googleauth' => $tfa, 'no_sidrenew' => "")));
     $d++;
    }
    else
     out($info);
    for($a=$b=0; $a < $cfg['tout']; $a++) {		// Warten
     if($d and $a == 1)					// Fallback, falls der Token vom Google Authenticator falsch ist
      out($info);
     sleep(1);
     if($rp = request('POST',$login[4],http_build_query(array('xhr' => 1, 'sid' => $sid, 'tfa_active' => "", 'no_sidrenew' => ""))) and $done = ifset($rp,'/"done":true/'))	// Prüfen ob ok
      break;
     else {						// Warte-Anzeige
      $c = $cfg['tout'] ? floor($a / max($a,$cfg['tout']) * max($cfg['wrap']-1,10)) - $b : 1;
      out(str_repeat(".",$c),2);
      $b += $c;
     }
    }
    if($b)						// Warte-Anzeige abschließen
     out("\n",2);
   }
   elseif($done = ifset($rp,'/"state":""/'))
    $bug and dbug("Zwei-Faktor-Authentisierung ist nicht erforderlich!");
   else
    $bug and dbug("Zwei-Faktor-Authentisierung konnte nicht initiiert werden!");
   if($done or isset($cfg['opts']['f']) and $cfg['opts']['f']) // 2FA war erfolgreich oder wurde mit -f erzwungen
    $cfg['2fa'] = $done;
   else {						// Fehlschlag
    logout($sid);
    return errmsg("Zwei-Faktor-Authentisierung fehlgeschlagen",$fn);
   }
  }
  return ($cfg['sid'] = $sid) ? $sid : errmsg(($var = ":Anmeldung fehlgeschlagen$err".($pass ? " (Kennwort abgewiesen)" : "") and !ifset($pass,'/^[ -~]+$/')) ?
	"5$var\nHinweis: Das Login-Kennwort enthält Sonderzeichen, die bei unterschiedlicher Zeichenkodierung Probleme bereiten können" : "4$var",$fn);
 }
}
function logout($sid=0) {				// Aus der Fritz!Box ausloggen
 global $bug;
 if(!$sid)
  $sid = $GLOBALS['cfg']['sid'];
 $bug and dbug("Logout ".$GLOBALS['cfg']['host']);
 if(is_string($sid) and $sid)				// Ausloggen
  request('GET',(($GLOBALS['cfg']['fiwa'] < 529) ? "/cgi-bin/webcm" : "/login_sid.lua"),array('security:command/logout' => 1, 'logout' => 1, 'sid' => $sid));
}
function supportcode($str = false) {			// Supportcode aufschlüsseln
 global $bug;
 $bug and dbug("Entschlüssele Supportcode");
 if(!$str)
  $str = request('GET','/cgi-bin/system_status');
 if($str and preg_match('/^\s*(?:(?:<[^>]+>\s*)*|System Status[^-]*-*[\s\r\n]*)?([^<>\r\n]+)/',$str,$m)
	and preg_match('/^([^-]+(?:-C)?)-(-(?=-)|(?:[AB]|Ohne)[^-]*|[CK]ab[le]{2})-(.*)$/',$m[1],$m[]) and count($m[] = preg_split('/(?<!-)-|-(?=\w)/',$m[2][3])) > 3) {
  $m = array_merge(array($m),array_slice($m[2],1,2),$m[3]);	// Alles zusammenführen
  $bug and dbug($m,4);
  $out = "Modell|$m[1]";				// Modell
  if($b = ifset($m[8],'/^(\d{2,3})(\d\d)(\d\d)$/')) {	// Firmware
   $out .= "\nFirmware|".implode('.',array_slice($b,1));
   if(ifset($m[9],'is_numeric'))
    $out .= "\nVersion|$m[9]";
  }
  if(ifset($m[11],'/^\w\w$/'))				// Sprache
   $out .= "\nSprache|".strtr($m[11],json2array('{en:"Englisch",de:"Deutsch",es:"Spanisch",fr:"Französisch",gr:"Griechisch",it:"Italienisch",nl:"Niederländisch",pl:"Polnisch"}'));
  if(ifset($m[10],'/^\w+$/'))				// Branding
   $out .= "\nMarke|$m[10]";
  if($var = ifset($m[2],'/^([AB]|Kabel|Cable|Ohne|Annex\s+(\w+))(?:,(g?[ap]on))?($)/i'))	// Annex
   $out .= "\nAnnex|".ucwords($var[2] ? $var[2] : $var[1])
	.($var[3] ? " (".trim(strtr(strtolower($var[3]),array('g' => 'Gigabit', 'a' => 'Active ', 'p' => 'Passive ', 'o' => 'Optical ', 'n' => 'Network '))).")" : "");
  if(ifset($m[3]) and ifset($m[4]) and preg_match('/^([01]\d|2[0-3])([0-2]\d|3[01])(0\d|1[01])(\d\d)(\d\d)([0-2]\d|3[01])?/',$m[3].$m[4],$b)) {	// Laufzeit & Neustarts
   $out .= "\n|\nLaufzeit|".preg_replace(array('/\b0*(\d+)(\D+)/','/(\b1\D+?)\D(?=,|$)/','/\b0+\D+/','/^\s+|,\s*$/','/^\s*$/'),array(' $1 $2','$1','','',0),"$b[4]Jahre,$b[3]Monate,$b[2]Tage,$b[1]Stunden,");
   if(ifset($b[5]) and ifset($b[6]))			// Neustarts
    $out .= "\nNeustarts|".($b[5] * 32 + $b[6]);
  }
  if(ifset($m[5]) and ifset($m[6]) and preg_match('/^([0-7]{6})([0-7]{6})$/',$m[5].$m[6],$b))	// CRC32 Hash
   $out .= "\n|\nCRC32 (Bootloader)|".strtoupper(str_pad(dechex((intval($b[1],8) >> 2) ^ 65535).str_pad(substr(dechex(intval($b[2],8) ^ 65535),-4),4,0,STR_PAD_LEFT),8,0,STR_PAD_LEFT))
		. " (".str_pad(decbin(intval(substr($b[1],-1).$b[2][0],8) >> 1 & 15),4,0,STR_PAD_LEFT).")";
  if($b = ifset($m[7],'/^(1[49]|21|78|8[35])(67|79)(\d\d)$/'))
   $out .= "\n|\ndebug.cfg|".(($b[1] % 64 == 14) ? "Nicht v" : "V")."erfügbar"
	."\nFirmware-Attribut|".(($b[1] < 64) ? "Geändert" : "Unverändert")
	."\n|\nOEM|".(($b[2] == 67) ? "Custom" : "Original")
	."\nRunClock|$b[3]";
  return $m[0][2][0]."\n\n".textTable($out);
 }
 else
  return errmsg(($var = ifset($str,'/<(\w+)>\s*([^<>]*)\s*<\/\1>/2')) ? "16:Fehler: $var" : "16:Unbekannt: $str",__FUNCTION__);
}
function boxinfo($data=false,$mode=false) {		// jason_boxinfo.xml / juis_boxinfo.xml auslesen und auswerten
 global $cfg,$strftime,$bug;
 if(!$data and login(false) and ifset($cfg['http'])) {	// Boxinfo aus der Fritz!Box auslesen
  $body = array('jason_boxinfo.xml' => $cfg['http'] + array(1 => $cfg['body']));
  $data = $cfg['body'];
  if($date = isset($cfg['http']['Date']) ? $cfg['http']['Date'] : 0)
   $cfg['date'] = strtotime($date);
  if($var = request('GET','/juis_boxinfo.xml')) {
   $body['juis_boxinfo.xml'] = $cfg['http'] + array(1 => $var);
   $data .= $var;
  }
 }
 $bug and dbug($cfg['http'],6);
 $bug and dbug($data,6);
 if(preg_match_all('/<([ejqs]:(\w+))>([^<>]+)<\/\1>/m',$data,$array)) {
  $bug and dbug($array,4);
  $jason = json2array('{
	Name:	Modell,
	HW:	"Hardware-Version",
	Version:"Firmware-Version",
	Revision:"Firmware-Revision",
	OEM:	Marke,
	Annex:	"Annex (Festnetz)",
	Lab:	Labor,
	Country:"Land-Vorwahl",
	Major:	Hauptversion,
	Minor:	Nebenversion,
	Patch:	Unterversion,
	Buildnumber:	"Firmware-Revision",
	Firmware_attrib:"Firmware-Attribut",
	Serial:		["MAC-Adresse (LAN)",[/\w\w(?!$)/,"$0:"]],
	Buildtype:	["Firmware-Typ",[[1007:"PLUS Beta",1006:"TEST Beta",1004:Phone,1001:"Frisch aus der Entwicklung",1000:Inhouse,1:Normal]]],
	UpdateConfig:	[Aktualisierung,[["-/-",Benachrichtigen,"Benachrichtigen & Sicherheitsaktualisierungen","Automatische Aktualisierungen"]]],
	Lang:		[Sprache,[{de:Deutsch,en:English,es:"Español",fr:"Français",it:Italiano,pl:Polski}]],
	Flag:		[Flags,[{mesh_repeater_no_trusted:"Einsamer Mesh-Teilnehmer",mesh_master_no_trusted:"Einsame Mesh-Zentrale","2nd_factor_disabled":"Kein zweiter Faktor",
			terms_of_use_not_used:"Nutzungsbedingungen nicht verwendet",terms_of_use_rejected:"Nutzungsbedingungen abgelehnt",terms_of_use_agreed:"Nutzungsbedingungen zugestimmt",
			remote_login_service:Fernwartung,myfritz_letsencrypt:"HTTPS mit LetsEncrypt",botnet_detection:"Viren Erkennung",crashreport:Absturzbericht,avm_acs:"TR-069 (AVM)",
			prov_acs:"TR-069 (Provider)",mesh_master:"Mesh mit Teilnehmern",mesh_repeater:"Mesh-Teilnehmer",nomini:	"Kein FRITZ!Mini",medium_dsl:"DSL-Internet",
			medium_fiber:"Glasfaser-Internet",medium_lan:"LAN-Internet"}]]}');
  $boxinfo = array();
  foreach($array[2] as $key => $var)
   $boxinfo[$var][] = html_entity_decode($array[3][$key]);
  if(isset($boxinfo['Annex']))			// Fiber-Annex
   foreach($boxinfo['Annex'] as $key => $var)
    if(preg_match('/^([^,]+),(g?[ap]on)$/i',$var,$m))
     $boxinfo['Annex'][$key] = "$m[1] (".trim(strtr(strtolower($m[2]),array('g' => 'Gigabit', 'a' => 'Active ', 'p' => 'Passive ', 'o' => 'Optical ', 'n' => 'Network '))).")";
  $array = array();
  foreach($boxinfo as $key => $var) {
   $var = array_unique($var);
   if(isset($jason[$key]))
    if(is_array($jason[$key])) {
     if(ifset($jason[$key][1]))
      $var = (count($jason[$key][1]) == 2) ? preg_replace($jason[$key][1][0],$jason[$key][1][1],$var)
	: str_replace(array_keys($jason[$key][1][0]),array_values($jason[$key][1][0]),$var);
     $title = $jason[$key][0];
    }
    else
     $title = $jason[$key];
   else
    $title = $key;
   $array[$title] = "$title|".implode(", ",$var);
  }
  if($cfg['fiwa'] >= 680) {					// Erweitere Daten aus login_sid.lua auslesen
   if($rp = request('GET','/login_sid.lua') and preg_match_all('!<(User)([^>]*)>([ \w,.-]+)</\1>!i',$rp,$user)) {	// XML-Login
    $body['login_sid.xml'] = $cfg['http'] + array(1 => $rp);
    if($var = ifset($rp,'/<(BlockTime)>(\d+)<\/\1>/i') and $var[2])// Ist immer 0?
    $array['blocktime'] = "Sperrzeit|$var[2] Sekunden";
    if(count($user[3]) > 1 and ($last = preg_array('/./',$user[2],4)) !== false)
     $array['lastuser'] = "Letzter Benutzer|".$user[3][$last];
    $array['admin'] = "Benutzer (Admin)|".implode(", ",$user[3]);
   }
   else
    $user = false;
   $flag = array();
   if($rp = request('GET','/nas/api/login.lua') and $js = json2array($rp) and $b = ifset($js['session'],true)) {	// NAS-Login
    $body['login_nas.json'] = $cfg['http'] + array(1 => $rp);
    $flag += $b;
    if($a = ifset($js['session']['activeUsers'],true) and (!$user or array_diff($user[3],$a) or array_diff($a,$user[3])))// NAS-User
     $array['nas'] = "Benutzer (NAS)|".implode(", ",$a);
   }
   if($rp = request('GET','/myfritz/api/login.lua') and $js = json2array($rp) and $b = ifset($js['session'],true)) {	// MyFritz-Login
    $body['login_myfritz.json'] = $cfg['http'] + array(1 => $rp);
    $flag += $b;
    if($b = ifset($js['session']['activeUsers'],true) and (!ifset($user) or array_diff($user[3],$b) or array_diff($b,$user[3]))
	and (!ifset($a) or array_diff($a,$b) or array_diff($b,$a)))							// MyFritz-User
     $array['myfritz'] = "Benutzer (MyFritz)|".implode(", ",$b);
   }
   if(isset($array['admin']) and !isset($array['myfritz']) and !isset($array['nas']))
    $array['admin'] = preg_replace('/^(\w+)[^|]*/','$1',$array['admin']);
   $flags = "";
   if(ifset($flag['fromInternet']))
    $flags .= ", Internet-Zugang";
   if(ifset($flag['noUserList']))
    $flags .= ", Keine Benutzerliste";
   if(isset($flag['firstStartWizardDone']) and !$flag['firstStartWizardDone'])
    $flags .= ", Assistent beim Start";
   if(isset($flag['nasActive']))
    $flags .= ", NAS ist a".($flag['nasActive'] ? "n" : "us");
   if($key = ifset($flag['viewMode'],""))
    $flags .= ", ".(($key == "loginOnlyWithPwd") ? "Login nur mit Kennwort" : "Benutzer-Login" );
   if($key = ifset($flag['migratedUser'],""))
    $array['migrated'] = "Migrierter Benutzer|$key";
   if($data = request('GET','/') and preg_match_all('!<script[^>]*>(.*?)</script>!si',$data,$m)) {
    $json = array();
    $body['login.html'] = $cfg['http'] + array(1 => $data);
    foreach($m[1] as $sect)
     if(preg_match_all('/[\w =]+\(?(\{.*\})\)?;/',$sect,$n))
      foreach($n[1] as $line)
       $json += json2array($line);
    $bug and dbug($json,6);
    foreach($json as $key => $var)			// JSON-Liste filtern
     if(ifset($key,'/txt$|title|url|^pages|^menu/i'))	// Texte, Titel und Url löschen
      unset($json[$key]);
     elseif(is_array($var) and $key != 'activeUsers') {	// Arrays in Liste umwandeln
      if($key != 'txt')
       foreach($var as $k => $v)
        $json[$key."_".$k] = $v;
      unset($json[$key]);				// Array löschen
     }
     $trans = json2array('{				// Übersetzungstabelle
	frominternet:		"Internet-Zugang",
	defaultpassword:	"Standard Kennwort",
	firsttenmin:		"Erste 10 Minuten",
	abortconfig:		"Konfiguration abgebrochen",
	showuser:		"Zeige Benutzer",	// immer true
	pushmailenabled:	"Pushmail aktiv",	// immer true
	gui_is_gateway:		"Gateway-Gerät",
	gui_is_repeater:	"Repeater-Gerät",
	gui_is_powerline:	"Powerline-Gerät",
	firstwizdone:		"Ersteinrichtung abgeschlossen",
	nofirstwiz:		"Keine Ersteinrichtung",
	zigbee:			Zigbee,
	isdebug:		Debug,
	pushbtnlogin:		"Login mit Knopfdruck",
	wlan_has_5ghz_band:	"WLAN im 5GHz-Band",
	wlan_has_wpa2_support:	"WLAN mit WPA2",
	wlan_is_triband:	"Triband-WLAN",
	wlan_is_double_wlan:	"Doppeltes WLAN",
	wlan_has_wpa3_support:	"WLAN mit WPA2",
	wlan_has_6ghz_band:	"WLAN im 5GHz-Band",
	hideforgotpasswordlink:	"Verstecke Kennwort-Vergessen",
	showfactorypasswordhint:"Hinweis zum Werkskennwort",
	gui_is_inhaus_or_labbeta:	"InHaus/LabBeta",
	wlan_has_wpa_tkip_support:	"WLAN mit WPA/TKIP",
	wlan_has_wpa_wpa2_mixed_support:"WLAN mit WPA/WPA2",
	wlan_has_wpa2_wpa3_mixed_support:"WLAN mit WPA2/WPA3",
/*	gui_hide_teaser:"",
	medium_wlan:	"",
	myfritz_usp:	"",
	loginreason:	"",
	gu_type:	"",
	blockTime:	"",
	lastPage:	"",
	falseUsername:	"",*/}');
     foreach($json as $key => $var)			// Flags dazu nehmen
      if(is_bool($var) and $var)
       $flags .= ", ".(isset($trans[$k = strtolower($key)]) ? $trans[$k] : $k);
   }
   if($flags)
    $array['Flags'] = ifset($array['Flags']) ? $array['Flags'].$flags : substr($flags,2);
  }
  if($date)
   $array['Boxtime'] = 'Aktuelle Uhrzeit|'.$strftime($cfg['fstr'],$cfg['date']);
  $data = textTable(out(implode("\n",$array),9));
  $bug and dbug($body,6);
  if($mode) {						// RAW-Daten mit zurückgeben
   array_unshift($body,$data);
   $data = $body;
  }
  return $data;
 }
 else
  return '';
}
function upnprequest($page,$ns,$rq,$exp=false) {	// UPnP Request durchführen
 global $cfg,$bug;
 $fn = __FUNCTION__;
 $bug and dbug("Setzte UPnP request ab: $page - $rq",9);
 if($rp = request(array(
	'method' => 'POST-array',
	'page' => $page,
	'body' => utf8("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
	."<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
	."<s:Body><u:$rq xmlns:u=$ns /></s:Body>\n</s:Envelope>",1),
	'head' => array_merge($GLOBALS['cfg']['head'],array('content-type' => 'text/xml; charset="utf-8"', 'soapaction' =>  "\"$ns#$rq\"")),
	'port' => $GLOBALS['cfg']['upnp'][0]))) {
  if($cfg['fiwa'] != 100 and $var = ifset($rp['SERVER'],'/0*([1-9])\.(\d{2})\s*$/'))	// Firmware-Version auslesen
   $cfg['fiwa'] = intval($var[1].$var[2]);
  if($exp and is_string($exp))				// Nur einen Wert extrahieren
   return (preg_match("!<$exp>(.*?)</$exp>!",$rp[1],$var)) ? $var[1] : errmsg('16:Kein Erwartetes Ergebnis erhalten',$fn);
  elseif(is_array($exp) and preg_match_all('!<(\w+)>(.+?)</\1>!',$rp[1],$array)) {	// Alle Werte in ein Array packen
   $bug and dbug($array,4,$fn);
   foreach($array[1] as $key => $var)			// Ergebnisse zusammenstellen
    $exp[$var] = $array[2][$key];
   return $exp;
  }
  else							// Response RAW zurückgeben
   return $rp;
 }
 else							// Fehler aufgetreten
  return errmsg('request',$fn);
}
function getupnppath($urn) {				// Helper für UPnP-Requests
 global $bug;
 $bug and dbug("Ermittle UPnP Pfad: $urn",9);
 if($rp = request(array('method' => 'GET', 'page' => '/igddesc.xml', 'port' => $GLOBALS['cfg']['upnp'][0]))
	and preg_match("!<(service)>.*?<(serviceType)>(urn:[^<>]*".$urn."[^<>]*)</\\2>.*?<(controlURL)>(/[^<>]+)</\\4>.*?</\\1>!s",$rp,$var)) {
  $bug and dbug($var,4);
  $rp = array($var[3],$var[5]);
 }
 else
  $rp = errmsg('request',__FUNCTION__);
 return $rp;
}
function getexternalip() {				// Externe IPv4-Adresse über UPnP ermitteln
 global $cfg,$bug;
 $bug and dbug("Ermittle IP-Adresse über UPnP für OS:".($cfg['fiwa']/100));
 $ip = array();
 if($val = getupnppath('WANIPConnection')) {
  if($var = upnprequest($val[1],$val[0],'GetExternalIPAddress','NewExternalIPAddress'))
    $ip['IPv4'] = $var;
  if($cfg['http']['HTTP_Code'] == 200 and ($cfg['fiwa'] >= 550 or $cfg['fiwa'] == 100)) {	// IPv6 und DNS bei neueren Boxen
   $k = "X_AVM_DE_Get";
   if($var = upnprequest($val[1],$val[0],$k.'ExternalIPv6Address','NewExternalIPv6Address'))
    $ip['IPv6'] = $var;
   if($var = upnprequest($val[1],$val[0],$k.'IPv6Prefix',array()) and ifset($var['NewIPv6Prefix']))
    $ip['IPv6-Prefix'] = "$var[NewIPv6Prefix]/$var[NewPrefixLength]";
   if($var = upnprequest($val[1],$val[0],$k.'DNSServer',array()) and $var = preg_array('/New(IPv4)?DNSServer/',$var,3))
    $ip['DNSv4'] = $var;
   if($var = upnprequest($val[1],$val[0],$k.'IPv6DNSServer',array()) and $var = preg_array('/NewIPv6DNSServer/',$var,3))
    $ip['DNSv6'] = $var;
  }
  if($ip)
   return $ip;
 }
 return errmsg('request',__FUNCTION__);
}
function forcetermination() {				// Internetverbindungen über UPnP neu aufbauen
 global $cfg,$bug;
 $bug and dbug("WAN Neueinwahl über UPnP");
 if(!($val = getupnppath('WANIPConnection') and $var = upnprequest($val[1],$val[0],'ForceTermination'))) {
  $var = errmsg('request',__FUNCTION__);
  if($cfg['http']['HTTP_Code'] == 500)
   out("Dieser Host hat ab Fritz!OS 8.25 nicht das Recht über UPnP Befehle zu senden!");
 }
 return $var;
}
function saverpdata($file,$data,$name) {		// HTTP-Downloads in Datei speichern
 global $cfg,$bug;
 if(!$file or is_bool($file)) {						// File ist leer
  $dir = "./";
  $file = "";
 }
 elseif($file == ':')							// Es soll nichts geschrieben werden
  return true;
 elseif(file_exists($file) and is_dir($file)) {				// file ist ein Verzeichnis
  $dir = str_replace('\\','/',realpath($file))."/";
  $file = false;
 }
 elseif($dir = dirname($file)."/" and file_exists($dir) and is_dir($dir))// file enthält ein Verzeichnis
  $file = basename($file);
 else {									// file ist nur eine Datei...
  $dir = "./";
  if(!file_exists($file))						// ...dass nicht existiert
   $file = basename($file);
 }
 if(!is_array($data))
  $data = $cfg['http'] + array(1 => $data);
 $cfg['file'] = $file = preg_replace($cfg['fesc'],$cfg['frep'],(!$file and isset($data['Content-Disposition']) and preg_match('/filename="(.*)"/',$data['Content-Disposition'],$var)) ? $var[1] : ($file ? $file : $name));
 $bug and dbug("Speichere Daten in $dir$file",9);
 return file_contents($dir.$file,$data[1]);
}
function supportdata($file=false,$tm=false,$sid=0) {	// Supportdaten anfordern
 global $bug;
 $bug and dbug("Hole Supportdaten");
 if(!$sid)
  $sid = $GLOBALS['cfg']['sid'];
 $array = array();
 if(!is_bool($sid))
  $array['sid'] = $sid;
 $mode = 'SupportData';
 if($tm !== false) {
  if($GLOBALS['cfg']['fiwa'] < 680 and $GLOBALS['cfg']['fiwa'] >= 650) {	// Telemetrie ab OS6.5 aktivieren
   $bug and dbug("Telemetrie wird ".($tm ? '' : 'de') ."aktiviert");
   $data = array(
	'xhr' => 1,
	'sid' => $sid,
	'lang' => 'de',
	'no_sidrenew' => '',
	'support_plus' => '',
	'oldpage' => '/support.lua');
   if($tm)
    $data['supportdata_enhanced'] = 'on';
   request('POST','/data.lua',http_build_query($data));
  }
  elseif($GLOBALS['cfg']['fiwa'] >= 680 and !$tm) {
   $bug and dbug("Aktiviere Telemetrie");
   $mode .= 'Enhanced';
  }
 }
 $array[$mode] = '';
 $data = $file ? (bool)request("POST-save:$file",'/cgi-bin/firmwarecfg',$array) : request("POST-array",'/cgi-bin/firmwarecfg',$array);
 return $data ? $data : errmsg('request',__FUNCTION__);
}
function supportdataextrakt($data,$mode=0,$file='') {	// Supportdaten extrahieren
 global $cfg,$bug;
 $fn = __FUNCTION__;
 $info = array();
 if(is_array($mode) and $mode[0] == 'sec') {
  $preg = '/^#{5} +BEGIN +SECTION +(\S+) *([^\r\n]+\s*)?(.*?)^#{5} +END +SECTION +\1\s+/sim';
  if(preg_match_all($preg,$data,$array)) {
   $bug and dbug($array,4,'SupportDataExtrakt-#');
   foreach($array[1] as $key => $var)
    if(trim($array[3][$key]))
     $info = array_merge($info,(($val = trim(preg_replace($preg,'',$array[3][$key]))) ? array(preg_replace(array('/^("|\')[\\\\\/]?(.*)\1$/',$cfg['fesc']),array('$2',$cfg['frep']),$var) => $array[2][$key].$val) : array()),call_user_func($fn,$array[3][$key],array('sec')));
  }
 }
 else {
  $bug and dbug("Zerlege Supportdaten");
  $mstr = $mlen = array(0,0);
  $val = $list = array();
  if(substr($data,0,5) == '#####')
   $array = call_user_func($fn,$data,array('sec'));
  elseif(preg_match('/^Support Data\n-+\n/',$data)
	and preg_match_all('/([()\/\w@:. -]+)\n-+\n([\s\S]+?)(?=End Of Support Data\s*$|\n\n[()\/\w@:. -]+\n-+\n|$)/i',$data,$array))
   $array = array_combine($array[1],$array[2]);
  if($array) {
   if(ifset($file,'/\.zip$/i')) {
    if($zip = data2zip($array)) {
     file_contents($file,$zip);
     foreach($array as $key => $var)			// Archivinhalt ausgeben
      $list[] = array($key,number_format(strlen($var),0,",","."));
    }
   }
   else {						// Tar-Archiv
    if($mode and $file)					// Tar-Archiv Initialisieren
     $fp = ($mode == 2) ? $cfg['zlib']['open']($file,'w'.$cfg['zlib']['mode']) : call_user_func(($cfg['bzip'] and $mode == 3) ? 'bzopen' : 'fopen',$file,'w');
    foreach($array as $key => $var) {			// Maximale Längen ermitteln
     $list[] = array($key,number_format(strlen($var),0,",","."));
     if($mode == 3 and $fp)
      bzwrite($fp,data2tar("$key.txt",$var,$date));
     elseif($mode == 2 and $fp)
      $cfg['zlib']['write']($fp,data2tar("$key.txt",$var,$date));
     elseif($mode == 1 and $fp)
      fwrite($fp,data2tar("$key.txt",$var,$date));
     elseif($file)
      file_contents("$key.txt",$var);
    }
    if($mode and $fp) {					// Tar-Archiv abschließen
     $data = data2tar(null);
     if($mode == 3) {
      bzwrite($fp,$data);
      bzclose($fp);
     }
     elseif($mode == 2) {
      $cfg['zlib']['write']($fp,$data);
      $cfg['zlib']['close']($fp);
     }
     else {
      fwrite($fp,$data);
      fclose($fp);
     }
    }
   }
   for($a=0; $a < ceil(count($list)/2); $a++)
    foreach(array($a,$a+ceil(count($list)/2)) as $b)
     if(isset($list[$b]))
      $val[$a] = (isset($val[$a]) ? $val[$a]."||" : "").$list[$b][0]."| ".$list[$b][1]." Bytes";
   $info = textTable(out(implode("\n",$val),9));
  }
  else
   $bug and dbug("Das zerlegen der Supportdaten ist fehlgeschlagen");
 }
 return $info;
}
function getuptime($sid=0) {				// Betriebszeit ermitteln
 global $cfg,$bug;
 $bug and dbug("Ermittle UpTime für OS:".($cfg['fiwa']/100));
 if(!$sid)
  $sid = $cfg['sid'];
# $sid = (!is_bool($sid)) ? "&sid=$sid" : ''; // Veraltet
 if($cfg['fiwa'] >= 650 and $data = request('POST','/data.lua',http_build_query(array(
	'xhr' => 1,
	'lang' => 'de',
	'page' => 'energy',
	'xhrld' => 'all',
	'sid' => $sid)))
	and (preg_match('/^\s*\{.*\}\s*$/s',$data) and $array = json2array($data) and $line = preg_array('/^statuses$/',$array,17)	// UpTime heraussuchen
	or $line = ifset($data,'/<td>(aktiv seit [\w\s,]+)<\/td>/1')) and preg_match('/^\D+(?:(\d+)\sTag\w*)?(?:, )?(?:(\d+) Stund\w*)?(?:, )?(?:(\d+) Minute\w*)?($)/',$line,$m) and $t = array_slice($m,1,3))
  $bug and dbug("OS: 6.50+ -> ".implode(',',$t));
 elseif($cfg['fiwa'] >= 481 and $data = request('GET',"/system/energy.lua",array('sid' => $sid))
	and preg_match('!^(?:<[^>]*>)?\s*\[?(["\']?)(logic:status/uptime_)hours\1\]? = \1(\d+)\1,?\s*(?:<[^>]*>)?\s*\[?\1\2minutes\1\]? = \1(\d+)\1,?\s*$!m',$data,$m) and $t = array(0,$m[3],$m[4]))
  $bug and dbug("OS: 4.81-6.50 -> ".implode(',',$t));
 elseif($cfg['fiwa'] <= 480 and $data = request('GET',"/cgi-bin/webcm",array(
	'sid' => $sid,
	'getpage' => '../html/de/menus/menu2.html',
	'var:lang' => 'de',
	'var:pagename' => 'energy',
	'var:menu' => 'system'))	// Ab Fritz!OS 4.33
	and preg_match('/^\s*var uph = (["\'])(\d*)\1;\s*var upm = \1(\d*)\1;$/m',$data,$m) and $t = array(0,$m[2],$m[3]))
  $bug and dbug("OS: 4.33-4.80 -> ".implode(',',$t));
 else
  return errmsg("16:Kein Uptime gefunden",__FUNCTION__);
 foreach($t as $k => $v)	// Strings in INT konvertieren
  $t[$k] = intval($v);
 $t[0] += floor($t[1] / 24);	// Stunden zu Tage umrechnen
 $t[1] %= 60;			// Weniger als ein Tag in den Stunden
 $t[] = (($t[0] * 24 + $t[1]) * 60 + $t[2]) * 60;	// Betriebszeit
 $t[] = time();
 $t[4] -= $t[3] % 60 + $t[3];	// Startseit berechnen
 return $t;			// Array zurückgeben (days,hours,minutes,time,start)
}
function dial($dial,$fon=false,$sid=0,$tfa=0) {		// Wahlhilfe
 global $cfg,$bug;
 if(!$sid)
  $sid = $cfg['sid'];
# $sid = (!is_bool($sid)) ? "&sid=$sid" : ''; // Veraltet
 if(preg_match('/^\$
	(?:((wlan|capi(?:-?over-?tcp)?|call(?:monitor|forward|through)|dtrace|fax(?:weiche|switch)?|busy(?:-?on-?busy)?|noise(?:reduction)?)
	|(telnetd?|mwi|recall))[\s_-]?(on|off|an|aus)
	|(fon[1-3]?|isdn[1-8]?|voip(?:[1-9]|10)?|ab[1-5]?|memo[1-5]?|dect[1-6]?)
	|(reset|factoryreset|broadcast))$/ix',$dial,$x))
  if($x[4]) {
   $set = json2array($x[2] ? '{wlan:"#96*0*",capi:"#96*2*",callm:"#96*4*",dtrace:"#97*2*",callf:"#961*0*",busy:"#961*2*",fax:"#961*4*",noise:"#614*0*",callt:"#564*0*"}'
		: '{mwi:"#97*1*",telnet:"#96*8*",recall:"#960*5*"}');
   foreach($set as $key => $var)
    if(strtolower(substr($x[1],0,strlen($key))) == $key and preg_match('/.*(\d)\D*$/i',$var,$y,PREG_OFFSET_CAPTURE)) {
     $dial = substr_replace($var,intval($y[1][0]) + ((strlen($x[4]) == 2) ? ($x[2] ? 1 : -1) : 0),$y[1][1],1);
     break;
    }
  }
  elseif(preg_match('/^(\w+?)(\d*)$/',$x[5],$y)) {
   $set = json2array('{fon:1,isdn:51,ab:600,memo:605,dect:610,voip:620}');
   foreach($set as $key => $var)
    if(strtolower($y[1]) == $key) {
     $dial = '**'.($var + ($y[2] ? intval($y[2]) -1 : 0));
     break;
    }
  }
  else {
   $set = json2array('{broadcast:"**9",reset:"#990*15901590*",factoryreset:"#991*15901590*"}');
   foreach($set as $key => $var)
    if(strtolower(substr($x[6],0,strlen($key))) == $key) {
     $dial = $var;
     break;
    }
  }
 else
  while(preg_match('/[a-z]/i',$dial,$x,PREG_OFFSET_CAPTURE))
   $dial = substr_replace($dial,min(floor((ord($x[0][0])-32&31)/3.2),7)+2,$x[0][1],1);
 $dial = preg_replace('/[^\d*#]+/','',$dial);
 $rdial = urlencode($dial);
 $fon = ($var = ifset($fon,'/^((?P<i>[1-4]|5[0-8]|6[0-5])|(?P<s>fon[1-4]?|isdn[0-8]?|dect[0-6]?))($)/i'))
	? ($var['i'] ? intval($var['i']) : (($var = ifset($var['s'],'/(\D+)(\d?)/')) ? (ifset($var[1],'/fon/i') ? ($var[2] ? intval($var[2]) : 1)
	: (ifset($var[0],'/isdn|dect0?$/i') ? 50 : 59) + intval($var[2])) : 0)) : false;
 if($cfg['fiwa'] >= 530) {
  if($fon) {
   $bug and dbug("Dial: Ändere Anruf-Telefon auf $fon");
   $data = array(
	'port' => $fon,
	'btn_apply' => '',
	'sid' => $sid);
   if($tfa or $cfg['fiwa'] < 680)
    $data['clicktodial'] = 'on';
   request('POST',"/fon_num/dial_fonbook.lua",http_build_query($data));
  }
  $bug and dbug("Dial: ".($dial ? "Wähle $dial" : "Auflegen"));
  $data = array('sid' => $sid);
  if($dial)
   $data['dial'] = $rdial;
  else
   $data += array(
	'hangup' => '',
	'orig_port' => $fon);
  if($cfg['fiwa'] >= 739)
   $data['useajax'] = 1;
  request((($cfg['fiwa'] >= 708) ? 'POST' : 'GET'),"/fon_num/fonbook_list.lua",http_build_query($data));
 }
 else {	// Classic
  $data = array('telcfg:settings/UseClickToDial' => 1, 'sid' => $sid);
  if($dial)
   $data['telcfg:command/Dial'] = $rdial;
  else
   $data['telcfg:command/Hangup'] = '';
  if($fon)
   $data['telcfg:settings/DialPort'] = $fon;
  request('POST',"/cgi-bin/webcm",http_build_query($data));
  $bug and dbug("Dial: ".($dial ? "Wähle $dial".($fon ? " für Telefon $fon" : "") : "Auflegen"));
 }
 return $dial ? $dial : "-";
}
function cfgexport($mode,$pass=false,$sid=0) {		// Konfiguration Exportieren (NUR Exportieren)
 global $bug;
 $bug and dbug("Exportiere Konfig");
 $body = array('ImportExportPassword' => $pass, 'ConfigExport' => false);
 $path = '/cgi-bin/firmwarecfg';
 if(!$sid) {
  $sid = $GLOBALS['cfg']['sid'];
  if(!is_bool($sid))
   $body = array_merge(array('sid' => $sid),$body);
 }
 return $mode	? (($mode === 'array')	? request('POST-array',$path,$body)
					: request('POST-save:'.(($mode === true) ? './' : $mode),$path,$body))
		: request('POST',$path,$body);
}
function cfgcalcsum($data) {				// Checksumme für die Konfiguration berechnen
 global $bug;
 if(preg_match_all('/^(\w+)=(\S+)\s*$|^(\*{4}) (?:CRYPTED)?(CFG|BIN|B64)FILE:(\S+)\s*(.*?)\3 END OF FILE \3\s*$/sm',$data,$array)) {
  cfgcheck($data);
  $bug and dbug("Berechne Konfig-Checksumme",9);
  $bug and dbug($array,4,'CfgCalcSum-#');
  foreach($array[4] as $key => $var)
   $array[0][$key] = ($array[1][$key]) ? $array[1][$key].$array[2][$key]."\0" : $array[5][$key]."\0".(($var == 'BIN')
	? pack('H*',preg_replace('/[^\da-f]+/i','',$array[6][$key])) : (($var == 'B64') ? base64_decode($array[6][$key])
	: preg_replace('/\r|\\\\(?=\\\\)/','',substr($array[6][$key],0,-1))));
  $bug and dbug($array[0],4,'8,CfgCalcSumArray-#');
  $bug and dbug(join('',$array[0]),4,'8,CfgCalcSumData');
 }
 return ($array and preg_match('/(?<=^\*{4} END OF EXPORT )[A-Z\d]{8}(?= \*{4}\s*$)/m',$data,$key,PREG_OFFSET_CAPTURE))
	? array($key[0][0],$var = strtoupper(hash('crc32b',join('',$array[0]))),substr_replace($data,$var,$key[0][1],8)) : errmsg('16:Keine Konfig-Datei',__FUNCTION__);
}
function cfgcheck($data) {				// Konfiguration auf Syntaxfehler überprüfen
 global $bug;
 $bug and dbug("Überprüfe Konfig-Syntax",9);
 $parse = array(
	'line'	=> 0,	// Letzte korrekt geparste Zeile
	'index'	=> 0,	// Letzter Index (Zeichenposition)
	'stack'	=> 0,	// Klammer-Ebene {}
	'mode'	=> 0,	// Lese-Modus
	'alen'	=> 0,	// WhiteSpace-Länge bei Array-Strings
	'last'	=> 0,	// Letzte länge von Hex/Base64
	'section'=>"",	// Aktuelle Sektionstype (BIN|B64|CFG)
	'error'	=> "",	// Letzter Fehler
	'preg'	=> '/^(\*{4} (.* EXPORT|(?:CRYPTED)?(B64|BIN|CFG)FILE:[\w.]+|END OF (FILE|EXPORT [\dA-F]{8}) \*{4})|((?:(?:[A-Z][a-z_]+|[A-Z_]+){1,3}\d?|\w+:[\w\/]+)=[\w.$]+|meta \{ \w+ = ".+"; \})'
		.'|(\/\*| \* .*| \*\/|\/\/ EOF)|( *(\w+ \{|\w+ =((?: (?:[\w.:-]+|".*")[,;])*)|\}|\} \{|(?: (?:[\w.:-]+|".*")[,;])*|"Base64:[\w+\/]{76}) ?)|(((?:[\dA-F]{2}){1,40})|[\w+\/=]{1,80})(";)?)?(\r?\n)/');
 while(!$parse['error'] and preg_match($parse['preg'],substr($data,$parse['index']),$m) and $m[0] != '') {
  $bug and dbug(compact(explode(',','parse,m')),9);
  if(!$parse['mode']) {								// Mode 0: Universal/Root
   if(!$parse['stack'] and $parse['section'] == "CFG" and $m[6] == "/*")	// Kommentar beginnt
    $parse['mode'] = 1;
   elseif(!$parse['stack'] and $parse['section'] == "CFG" and $m[6] and substr($m[6],0,2) == "//"); // Kommentar für End of Line
   elseif(!$parse['stack'] and $m[2]) {						// Sectionen
    if($m[3] and !$parse['section'])						// Section beginnt
     $parse['section'] = $m[3];
    elseif($m[4] and $parse['section']) {					// Section Endet
     $parse['section'] = "";
     $parse['last'] = 0;
    }
    elseif($m[4] and !$parse['section'] and substr($m[4],0,6) == "EXPORT");	// Export end
    elseif(substr($m[2],-7) == " EXPORT" and !$parse['section'] and !$parse['mode']); // Konfig Begin
    else
     $parse['error'] = "Fehler in der Section";
   }
   elseif($m[7]) {								// object/vars
    if(!$m[8] or $m[8][0] != "}" and strlen($m[7]) < strlen($m[8]) + $parse['stack'] * 8 or $m[8] == "}" and strlen($m[7]) < strlen($m[8]) + ($parse['stack'] - 1) * 8)
     $parse['error'] = "Fehler mit den Leerzeichen";				// Fehlerhafte Leerzeichen
    elseif($m[8] == "} {");
    elseif(substr($m[8],-1) == "{")						// Eine Ebene tiefer
     $parse['stack']++;
    elseif($m[8] == "}")							// Eine Ebene höher
     $parse['stack']--;
    elseif(substr($m[8],0,8) == '"Base64:') {					// Base64 im String über mehrere Zeilen
     $parse['mode'] = 3;
     $parse['last'] = strlen($m[8]) - 8;					// Zeichen pro Zeile
    }
    elseif($m[9]) {
     if(substr($m[8],-1) == ",") {						// Mode 2:Array-String
      $parse['mode'] = 2;
      $parse['alen'] = strlen($m[7]) - strlen($m[9]);				// Whitespace-Zeichen berechnen
     }
    }
    else if(substr($m[8],-1) == "=") {						// Mode 2 ohne Daten
     $parse['mode'] = 2;
     $parse['alen'] = strlen($m[7]) + (substr($m[7],-1) != " ");
    }
    else									// Parsingfehler bei Mode 0
     $parse['error'] = "Unbekannte Variable";
   }
   elseif(!$parse['stack'] and (!$parse['section'] or $parse['section'] == "CFG") and ($m[5] || !$m[1]));	// Root-Vars/charcode & ln
   elseif(($parse['section'] == "BIN" or $parse['section'] == "B64") and !$m[1]);// Non Binaer (ln)
   elseif($parse['section'] == "BIN" and $m[11] and preg_match("/^([\dA-F]){1,".($parse['last'] ? $parse['last']: "")."}$/",$m[11]))
    $parse['last'] = strlen($m[11]);
   elseif($parse['section'] == "B64" and $m[10] and preg_match("/^[\w\/+]{1,".($parse['last'] ? $parse['last']: "")."}={0,2}$/",$m[10]))
    $parse['last'] = strlen($m[10]);
   else
    $parse['error'] = "Fehler in der Syntax";
  }
  elseif($parse['mode'] == 1 and !$parse['stack'] and $parse['section'] == "CFG" and $m[6]) {	// Mode 1: Kommentare
   if($m[6] == " */")								// Kommentar endet
    $parse['mode'] = 0;
   elseif($m[6] == "/*")							// Fehler bei Kommentar im Kommentar
    $parse['error'] = "Fehler im Kommentar";
  }
  elseif($parse['mode'] == 2 and $parse['alen'] and $m[8] and substr($m[7],0,$parse['alen']) == str_repeat(" ",$parse['alen'])) {	// Mode 2: Array-Strings
   if(substr($m[8],-1) == ";")
    $parse['mode'] = $parse['alen'] = 0;
   elseif(substr($m[8],0,8) == '"Base64:') {					// Mode 2 wird zu Mode 3
    $parse['mode'] = 3;
    $parse['last'] = strlen($m[8]) - 8;						// Zeichen pro Zeile
    $parse['alen'] = 0;
   }
  }
  elseif($parse['mode'] == 3 and $m[10] and preg_match("/^[\w\/+]{1,$parse[last]}={0,2}$/",$m[10]))	// Mode 3: Base64-String
   $parse['last'] = $m[12] ? ($parse['mode'] = 0) : strlen($m[10]);
  else
   $parse['error'] = "Unbekannter Modus";
  $parse['index'] += strlen($m[0]);						// Letzte Funde dazuzählen
  $parse['line']++;
 }
 $bug and dbug(compact(explode(',','parse,m')),9);
 return ($parse['error'] or $parse['index'] != strlen($data)) ? errmsg('1:'.($parse['error'] ? $parse['error'] : "Unbekannte Syntax")." ab Zeile $parse[line]",__FUNCTION__) : true; // Prüfenergebnis zurückgeben
}
function cfgimport($file,$pass='',$mode=false,$sid=0) {	// Konfiguration importieren (Wird vermutlich bald überarbeitet)
 global $cfg,$bug;
 $fn = __FUNCTION__;
 if($file and (	is_file($file) and preg_match($cfg['ptar'],$file,$var) and ($data = cfgmake($var[4] ? zip2array(file_contents($file)) : tar2array($file)))
		or is_file($file) and ($data = file_contents($file))
		or is_dir($file) and ($data = cfgmake($file))
	) or !$file and $data = $mode and substr($mode,0,4) == '****') {
  if($mode and $var = cfgcalcsum($data)) {
   $data = $var[2];
   if($var = errmsg(0,'cfgcheck',1))
    out("Warnung: $var");
  }
  $bug and dbug("Upload Konfig-File an ".$cfg['host']);
  $body = array('ImportExportPassword' => $pass,
	'ConfigImportFile' => array('filename' => $file, 'Content-Type' => 'application/octet-stream', '' => $data),
	'apply' => false);
  if(!$sid) {
   $sid = $cfg['sid'];
   if(!is_bool($sid))
    $body = array_merge(array('sid' => $sid),$body);
  }
  if($cfg['fiwa'] >= 724)
   request('POST','/data.lua',http_build_query(array(
	'xhr' => 1,
	'recovery' => '',
	'sid' => $sid,
	'ImportExportPassword' => urlencode($pass),
	'uiPass' => urlencode($pass),
	'cfgtakeover' => 'all',
	'restore' => '',
	'lang' => 'de',
	'page' => 'sysImp')));
  return ($res = request('POST','/cgi-bin/firmwarecfg',$body)) ? $res : errmsg('request',$fn);
 }
 else
  return errmsg('8:Import-Datei/Ordner nicht gefunden',$fn);
}
function cfginfo($data,$mode=0,$file='',$text=false) {	// Konfiguration in Einzeldateien sichern (mode: 0->show, 1->Dir, 2->Tar, 3->tgz, 4->tbz)
 global $cfg,$strftime,$bug;
 if(preg_match_all('/^(?:
	\*{4}\s(.*?)\sCONFIGURATION\sEXPORT|(\w+=\S+))\s*$			# 1 Fritzbox-Modell, 2 Variablen
	|^\*{4}\s(?:CRYPTED)?(CFG|BIN|B64)FILE:(\S+)\s*?\r?\n(.*?)\r?\n	# 3 Typ, 4 File, 5 Data
	^\*{4}\sEND\sOF\sFILE\s\*{4}\s*?$/msx',$data,$array) and $array[1][0] and $crc = cfgcalcsum($data)) {
  $list = $val = $vars = array();
  $mstr = $mlen = array(0,0);
  $bug and dbug($array,4,'CfgInfo-#');
  if($mode == 4 and !$cfg['bzip']) {
   $mode -= 2;
   $file = preg_replace('/(\.tar)?\.t?bz(ip)?2?|/i','.tar',$file);
  }
  elseif($mode == 5)
   $zip = array();
  elseif($mode == 1 and !file_exists($file))
   makedir($file);
  $fp = ($mode < 5 and $mode >= 2 and $file) ? (($mode == 3) ? $cfg['zlib']['open']($file,'w'.$cfg['zlib']['mode']) : call_user_func(($mode == 4) ? 'bzopen' : 'fopen',$file,'w')) : false;	// tar/tgz initialisieren
  foreach($array[3] as $key => $var)		// Config-Dateien aufteilen
   if($var) {
    if($array[3][$key] == 'CFG') {
     $bin = preg_replace('/\r|\\\\(?=\\\\)/','',$array[5][$key]);
     if(!isset($vars['Date']) and preg_match('/^\s\*\s([\s:\w]+)$/m',$bin,$var))
      $vars['Date'] = strtotime($var[1]);
    }
    else
     $bin = ($array[3][$key] == 'B64') ? base64_decode($array[5][$key]) : pack('H*',preg_replace('/[^\da-f]+/i',"",$array[5][$key]));
    $list[] = array($array[3][$key],$array[4][$key],number_format(strlen($bin),0,",","."));
    if($mode == 5)
     $zip[$array[4][$key]] = array('data' => $bin, 'date' => $vars['Date']);
    elseif($fp and $mode == 4)
     bzwrite($fp,data2tar($array[4][$key],$bin,$vars['Date']));
    elseif($fp and $mode == 3)
     $cfg['zlib']['write']($fp,data2tar($array[4][$key],$bin,$vars['Date']));
    elseif($fp and $mode >= 2)
     fwrite($fp,data2tar($array[4][$key],$bin,$vars['Date']));
    elseif($mode >= 1)
     file_contents($array[4][$key],$bin);
    unset($array[2][$key]);
   }
   elseif($var = ifset($array[2][$key],'/^(\w+)=(.*)$/'))
    $vars[$var[1]] = $var[2];
   else
    unset($array[2][$key]);
  $name = "index.txt";				// Konfig-Schablone sichern
  $data = preg_replace('/^(\*{4}\s(?:CRYPTED)?(?:CFG|BIN|B64)FILE:\S+\s*?\r?\n).*?\r?\n(^\*{4}\sEND\sOF\sFILE\s\*{4}\s*?)$/msx','$1$2',$data);
  $list[] = array("TXT",$name,number_format(strlen($data),0,",","."));
  if($mode == 5)
   $zip[$name] = array('data' => $data, 'date' => $vars['Date']);
  elseif($fp and $mode == 4)
   bzwrite($fp,data2tar($name,$data,$vars['Date']));
  elseif($fp and $mode == 3)
   $cfg['zlib']['write']($fp,data2tar($name,$data,$vars['Date']));
  elseif($fp and $mode >= 2)
   fwrite($fp,data2tar($name,$data,$vars['Date']));
  elseif($mode >= 1)
   file_contents($name,$data);
  if($text) {					// Zugangsdaten sichern
   $name = "zugangsdaten.txt";
   $list[] = array("TXT",$name,number_format(strlen($text),0,",","."));
  if($mode == 5)
   $zip[$name] = array('data' => $text, 'date' => $vars['Date']);
   if($fp and $mode == 4)
    bzwrite($fp,data2tar($name,$text,$vars['Date']));
   elseif($fp and $mode == 3)
    $cfg['zlib']['write']($fp,data2tar($name,$text,$vars['Date']));
   elseif($fp and $mode >= 2)
    fwrite($fp,data2tar($name,$text,$vars['Date']));
   elseif($mode >= 1)
    file_contents($name,$text);
  }
  if($mode == 5 and $zip = data2zip($zip))
    file_contents($file,$zip);
  elseif($fp) {					// tar/tgz finalisieren
   $data = str_repeat("\0",512);
   if($mode == 4) {
    bzwrite($fp,$data);
    bzclose($fp);
   }
   elseif($mode == 3) {
    $cfg['zlib']['write']($fp,$data);
    $cfg['zlib']['close']($fp);
   }
   elseif($mode == 2) {
    fwrite($fp,$data);
    fclose($fp);
   }
  }
  for($a=0; $a < ceil(count($list)/2); $a++)
   foreach(array($a,$a+ceil(count($list)/2)) as $b)
    if(isset($list[$b]))
     $val[$a] = (isset($val[$a]) ? $val[$a]."||" : "").$list[$b][0].":|".$list[$b][1]."| ".$list[$b][2]." Bytes";
  $list = "\nModell:   {$array[1][0]}\n";
  if(ifset($vars['Date']))
   $list .= "Datum:    ".$strftime($cfg['fstr'],$vars['Date'])."\n";
  if(ifset($vars['FirmwareVersion']))
   $list .= "Firmware: $vars[FirmwareVersion]\n";
  return $list."Checksum: $crc[0]".((!$mode and $text) ? "" : " (".(($crc[0] == $crc[1]) ? "OK" : "Inkorrekt! - Korrekt: $crc[1]").")")
	.(($var = errmsg(0,'cfgcheck',1)) ? "\nWarnung:  $var" : "")."\n\n".textTable(out(implode("\n",$val),9))."\n".((!$mode and $text) ? $text : '');
 }
 else
  return errmsg('16:Keine Konfig-Datei',__FUNCTION__);
}
function cfgmake($dir,$mode='',$file=false) {		// Konfiguration wieder zusammensetzen
 global $bug;
 $fn = __FUNCTION__;
 if(is_array($dir) and isset($dir[0]) and !$mode and !$file) {	// Helper für Preg_Replace CfgMake
  if(is_array($GLOBALS['val']) and isset($GLOBALS['val'][$dir[3]]))
   $mode = $GLOBALS['val'][$dir[3]];
  elseif(file_exists("$GLOBALS[val]/$dir[3]"))
   $mode = file_contents("$GLOBALS[val]/$dir[3]");
  return $dir[1].(($dir[2] == 'CFG') ? str_replace("\\","\\\\",$mode)
	: wordwrap(($dir[2] == 'BIN') ? strtoupper(implode('',unpack('H*',$mode))) : base64_encode($mode),80,$dir[4],1)).$dir[4].$dir[5];
 }
 elseif($dir and (is_array($dir) and $data = preg_array('/^(index|pattern)\.txt$/',$dir,1)
	or $var = glob_brace("$dir/{index,pattern}.txt") and $data = file_contents($var[0])) and preg_match('/^\*{4}\s+\w+.*CONFIGURATION EXPORT/',$data,$array)) {
  $bug and dbug("Setze Konfig-Daten zusammen");
  $GLOBALS['val'] = $dir;
  $data = preg_replace_callback('/(^\*{4}\s(?:CRYPTED)?(CFG|BIN|B64)FILE:(\S+)\s*?(\r?\n))(^\*{4}\sEND\sOF\sFILE\s\*{4}\s*?$)/m',$fn,$data);
  if(preg_match('/^\*{4}\s(.*?)\sCONFIGURATION\sEXPORT.*?FirmwareVersion=(\S+)/s',$data,$array) and $crc = cfgcalcsum($data)) {
   $val = "Modell:   $array[1]\nFirmware: $array[2]\nChecksum: $crc[0] ";
   $val .= (($crc[0] == $crc[1]) ? "(OK)" : "Inkorrekt! - Korrekt: $crc[1]")."\n";
   if($var = errmsg(0,'cfgcheck',1))
    $val .= "Warnung:  $var\n";
   $data = $mode ? $crc[2] : $data;
   if($file)
    file_contents($file,$data);
   return $file ? $val : $data;
  }
 }
 return errmsg("8:Keine Konfig-Daten - Konfig-Schablone nicht gefunden",$fn);
}
function cfgdecrypt($data=false,$pass=false) {		// Konfig-Datei entschlüsseln
 global $cfg,$bug;
 $fn = __FUNCTION__;
 if(is_array($pass) and substr($copy = $data,0,4) == '$$$$') {	// Fritz Decrypt
  $a = substr($d = unBase($data),0,16);				// AES iv
  $b = substr($d,16).str_pad("\0",16 - strlen($d) % 16);	// AES data.pad
  foreach($cfg['aes'] as $aes => $var) {			// Alle AES-Bibliotheken durchprobieren
   for($c=count($pass)-1; $c >= 0; $c--) {			// Alle Kennwörter durchprobieren
    if($pass[$c] == 1)						// Letzter Schlüssel im Bund
     $data = false;
    elseif($aes == 'openssl')					// Extension: OpenSSL
     $data = openssl_decrypt($b, "AES-256-CBC", $pass[$c], OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING, $a);
    elseif($aes == 'mcrypt')					// Extension: MCrypt
     $data = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $pass[$c], $b, MCRYPT_MODE_CBC, $a);
    elseif($aes == 'aes5')					// Script: Aes.php
     $data = eval('$d = new PhpAes\Aes($pass[$c], "CBC", $a); return $d->decrypt($b);');
    elseif($aes == 'aes4') {					// Script: AES_4.class.php
     $d = new Aes($pass[$c], "CBC", $a);
     $data = $d->decrypt($b);
    }
    if(substr(hash('md5',substr($data,4,strlen($data) - 20),true),0,4) == substr($data,0,4)) {			// Checksum
     $data = substr($data,8,hexdec(bin2hex(substr($data,4,4))));						// Extract
     return (end($pass) == 1) ? preg_replace(array('/\0?$/','/[\\"]/'),array('','\\\\$0'),$data) : $data;
    }
   }
  }
  $bug and dbug("Fail: $copy",4);
  return false;
 }
 elseif(preg_match('/^\*{4} .*? CONFIGURATION EXPORT$/mi',$data) and $pass) {	// Konfig einlesen und zur entschlüsselung vorbereiten
  $bug and dbug($data,4,'12,CfgDeCrypt-Crypted');
  if(preg_match('/^\s*(?:([A-Z](?:0[1-9]|[1-4]\d|5[0-3])[1-7]\.?\d{3}\.?\d{2}(?:\.?\d{3}){2})\W)?((?:[\dA-F]{2}([:-]|(?=\s*$))){6})\s*$/i',$pass,$var)) // Alternative zur Konfiguationen ohne Kennwort
   $pass = (ifset($var[1]) ? str_replace('.','',$var[1]) : str_repeat('0',16))."\n".strtoupper(str_replace('-',':',$var[2]))."\n";	// Seriennummer und MacA-Adresse als Kennwort
  $pass = array(str_pad(hash('md5',$pass,true),32,"\0"));
  if(preg_match_all('/(Password\d*=)(\${4}\w+)/i',$data,$match,PREG_OFFSET_CAPTURE))
   for($a=count($match[0])-1; $a >= 0; $a--)
    if($key = call_user_func($fn,$match[2][$a][0],$pass) and strlen($key) == 32 and substr($key,0,16) == substr($key,16)) {	// Schlüssel extraieren
     $pass[] = str_pad(substr($key,16),32,"\0");									// Schlüssel merken
     $data = substr_replace($data,strtoupper(bin2hex(substr($key,16))),$match[2][$a][1],strlen($match[2][$a][0]));	// Schlüssel in Plaintext
    }
  if(count($pass) > 1 and preg_match_all('/(\${4}\w+)(?="|$)|^(\*{4}\sB(64|IN)FILE:.*\s*)([\dA-F\s]*?(?:24\s*){4}(?:[46][1-9A-F]|[57][0-9A]|3\d|\s*)+[\dA-F\s]*|[\w+\/\s]*?(?:JCQkJ|QkJC|kJCQk)[\w+\/\s=]+)(?=\s+\*{4})|^(\*{4}\sCRYPTEDB(64|IN)FILE:.*\s*)([\dA-F\s]+)(?=\s+\*{4})/mi',$data,$match,PREG_OFFSET_CAPTURE)) {
   $bug and dbug($match,4,'CfgDecrypt-#');
   $pass[] = 1;							// Schlüsselring anschließen
   for($a=count($match[0])-1; $a >= 0; $a--) {
    if($match[1][$a][0])
     $data = substr_replace($data,call_user_func($fn,$match[1][$a][0],$pass),$match[1][$a][1],strlen($match[1][$a][0]));
    else {
     if($match[5][$a][0]) {
      $match[2][$a] = $match[5][$a];
      $match[3][$a] = $match[6][$a];
      $match[4][$a] = $match[7][$a];
     }
     $b = $match[2][$a][0];
     $c = ($match[3][$a][0] == 64) ? base64_decode($match[4][$a][0]) : pack("H*", preg_replace('/\W+/','',$match[4][$a][0]));
     if(isset($match[5][$a][0]) and $match[5][$a][0] == $b) {	// CryptedBin
      foreach($cfg['aes'] as $aes => $var) {
       $d = $c.str_repeat("\0",16 - strlen($c) % 16);
       if($aes == 'openssl')
        $d = openssl_decrypt($d, "AES-256-ECB", $pass[0], OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING);
       elseif($aes == 'mycrypt')
        $d = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $pass[0], $d, MCRYPT_MODE_ECB, substr($d,0,16));
       elseif($aes == 'aes5')
        $d = eval('$d = new PhpAes\Aes($pass[0], "ECB"); return $d->decrypt($d);');
       elseif($aes == 'aes4') {
        $f = new Aes($pass[0], "ECB");
        $d = $f->decrypt($d);
       }
       $f = -1;							// Workaround für strrpos
       while($e = strpos($d,"AVM\0",$f + 1))
        $f = $e;
       if($aes and $f > 0) {					// $f = strrpos($d,"AVM\0")
        $c = substr($d,4,hexdec(bin2hex(substr($d,$f + 12,4))));
        $b = str_replace('CRYPTED','',$b);
        break;
       }
      }
     }
     elseif(preg_match_all('/\${4}\w+(?="|$)/',$c,$var,PREG_OFFSET_CAPTURE))
      for($d=count($var[0])-1; $d >= 0; $d--)
       $c = substr_replace($c,call_user_func($fn,$var[0][$d][0],$pass),$var[0][$d][1],strlen($var[0][$d][0]));
      $data = substr_replace($data,$b.preg_replace('/.{80}/',"\$0\n",($match[3][$a][0] == 64) ? base64_encode($c) : strtoupper(bin2hex($c))),$match[0][$a][1],strlen($match[0][$a][0]));
    }
   }
   return $data;
  }
  else
   return errmsg('4:Falsches Konfig-Kennwort',$fn);
 }
 else
  return $pass ? errmsg('16:Keine Konfig-Datei',$fn) : false;
}
function konfig2array($data) {				// FRITZ!Box-Konfig -> Array
 global $bug;
 $fn = __FUNCTION__;
 $config = array();
 if($data[0] == '*')
  $bug and dbug("Konvertiere Fritz!Konfig...");
 if($data[0] == '*' and preg_match_all('/^(?:\*{4}\s(.*?)\sCONFIGURATION\sEXPORT|(\w+)=(\S+))\s*$
	|^\*{4}\s(?:CRYPTED)?(CFG|BIN|B64)FILE:(\S+)\s*?\r?\n(.*?)\r?\n^\*{4}\sEND\sOF\sFILE\s\*{4}\s*?($)/msx',$data,$array)) {
  $bug and dbug($array,4,'Konfig2Array-#');		// Debugdaten Speichern
  foreach($array[4] as $key => $var)
   if($array[1][$key])					// Routername
    $config['Name'] = $array[1][$key];
   elseif($array[2][$key])				// Variablen
    $config[$array[2][$key]] = $array[3][$key];
   elseif(ifset($array[4][$key],'B64'))			// Base64 Data
    $config[$array[5][$key]] = base64_decode($array[6][$key]);
   elseif(ifset($array[4][$key],'BIN'))			// Bin Data
    $config[$array[5][$key]] = pack('H*',preg_replace('/[^\da-f]+/i','',$array[6][$key]));
   elseif(ifset($array[4][$key],'CFG') and preg_match_all('/^(\w+)\s(\{\s*$.*?^\})\s*$/smx',
	str_replace(array("\r","\\\\"),array("","\\"),$array[6][$key]),$match))	// CfgData
    foreach($match[1] as $k => $v)
     $config/*[$array[5][$key]]*/[$v] = call_user_func($fn,$match[2][$k]);
  $bug and dbug($config,4,'Konfig2Array');		// Debugdaten Speichern
 }
 elseif($data[0] == '{' and preg_match_all('/\{\s*?$.*?^\}/msx',$data,$array)) {
  $bug and dbug($array,4,'Konfig2Array-Multi-#');	// Debugdaten Speichern
  if(count($array[0]) > 1)				// Ein oder Multi-Array
   foreach($array[0] as $var)				// Weitere Matches auf selber Ebene
    $config[] = call_user_func($fn,$var);
  elseif(preg_match_all('/^\s{8}(?:(\w+)\s(?:=\s(?:([^\s"]+)|(".*?(?<!\\\\)"(?:,\s*)?));|(\{\s*$.*?^\s{8}\}))\s*($))$/msx',$data,$match)) {
   $bug and dbug($match,4,'Konfig2Array-Sub-#');	// Debugdaten Speichern
   foreach($match[1] as $key => $var)			// Array durch arbeiten
    if($match[2][$key])					// Einfache Werte
     $config[$var] = ($match[2][$key] == 'yes') ? true  : (($match[2][$key] == 'no') ? false : (is_numeric($match[2][$key]) ? (int)($match[2][$key]) : $match[2][$key]));
    elseif($match[3][$key] and preg_match_all('/"(.*?)(?<!\\\\)"/',$match[3][$key],$val))	// String(s)
     $config[$var] = str_replace('\"','"',(count($val[1]) > 1) ? $val[1] : $val[1][0]);
    elseif($match[4][$key])				// Verschachteltes Array
     $config[$var] = call_user_func($fn,preg_replace('/^\s{8}/m','',$match[4][$key]));
  }
 }
 else
  return errmsg('16:Keine Konfig-Datei',$fn);
 return $config;
}
function showaccessdata($data) {			// Die Kronjuwelen aus Konfig-Daten heraussuchen
 global $bug;
 if(is_array($data))
  return chr(intval($data[1],8));
 $text = '';
 $config = array();
 if($konfig = konfig2array($data)) {		// Konfig als Array umwandeln
  $bug and dbug("Stelle Zugangsdaten zusammen...");
  $access = array(
   'Mobile-Stick'		=> array(&$konfig['ar7cfg']['serialcfg'],'=number,provider,username,passwd'),
   'DSL'			=> array(&$konfig['ar7cfg']['targets'],'-name,>local>username,>local>passwd'),
   'IPv6'			=> array(&$konfig['ipv6']['sixxs'],'=ticserver,username,passwd,tunnelid'),
   'DynamicDNS'			=> array(&$konfig['ddns']['accounts'],'=domain,username,passwd'),
   'MyFRITZ!'			=> array(&$konfig['jasonii'],'=user_email,user_password,box_id,box_id_passphrase,dyn_dns_name'),
   'FRITZ!Box-Oberfläche'	=> array(&$konfig['webui'],'=username,password'),
   'Fernwartung'		=> array(&$konfig['websrv']['users'],'=username,passwd'),
   'GUI-Unterordner'		=> array(&$konfig['websrv.subfolder']['=name,passwd']),
   'TR-064'			=> array(&$konfig['TR_064'],'=username,password'),
   'TR-069-Fernkonfiguration'	=> array(&$konfig['tr069cfg']['igd']['managementserver'],'=url,username,password,ConnectionRequestUsername,ConnectionRequestPassword'),
   'Diagnose/Wartung'		=> array(&$konfig['tr069cfg']['lab'],'=CRUsername,CRPassword','+username,password,domain_name,update_url'),
   'Netzwerkumgebung'		=> array(&$konfig['landevices']['landevices'],'-ip,name,neighbour_name,remotelogin_username,remotelogin_password'),
   'Telekom-Mediencenter'	=> array(&$konfig['t_media'],'=refreshtoken,accesstoken'),
   'Google-Play-Music'		=> array(&$konfig['gpm'],'=emailaddress,password,partition,servername'),
   'Onlinespeicher'		=> array(&$konfig['webdavclient'],'=host_url,username,password'),
   'WLAN'			=> array(&$konfig['wlancfg'],'/^(((guest|sta)_)?(ssid(_(scnd|thrd|frth))?|pskvalue)|(sta_)?key_value\d|wps_pin|wds_(key|ssid))$/i'),
   'Push-Dienst'		=> array(&$konfig['emailnotify'],'=From,To,SMTPServer,accountname,passwd','+To,arg0'),
   'DECT-eMail'			=> array(&$konfig['configd'],'!<\?xml.*?<list>.*?<email>.*?<pool>(.*?)</pool>!s','!((name)|user_name|(?:smtp_)?server|user|pass|uipin|port)="([^"]+)"!s'),
   'FRITZ!Box-Benutzer'		=> array(&$konfig['boxusers']['users'],'-name,email,passwd,password,googleauth_sharedsecret,googleauth_devicename'),
   'Apps'			=> array(&$konfig['apps']['apps'],'-displayname,username,password,id,appavmaddress'),
   'Apps2'			=> array(&$konfig['apps'],'=box_senderid,enc_secret,box_auth_id,box_auth_pwd'),
   'InternetTelefonie'		=> array(&$konfig['voipcfg'],'_name,username,authname,passwd,registrar,stunserver,stunserverport,gui_readonly'),
   'IP-Telefon'			=> array(&$konfig['voipcfg']['extensions'],'-extension_number,username,authname,passwd,clientid'),
   'Online-Telefonbuch'		=> array(&$konfig['voipcfg']['onlinetel'],'-pbname,url,serviceid,username,passwd,refreshtoken,accesstoken'),
   'FRITZ!NAS Share'		=> array(&$konfig['usbhost.filelinks'],'-id,path'),
   'Virtual-Privat-Network'	=> array(&$konfig['vpncfg']['connections'],'-name,>localid<fqdn,>remoteid<fqdn,>localid<user_fqdn,>remoteid<user_fqdn,key,>xauth>username,>xauth>passwd'),
   'WireGuard-Interface'	=> array(&$konfig['vpncfg']['global'],'/^wg_(private_key|public_key|listen_port)$/i'),
   'WireGuard-Peer:'		=> array(&$konfig['vpncfg']['connections'],'-name,wg_public_key,wg_preshared_key'),
   'Tickets'			=> array(&$konfig['usercfg']['valid_tickets'],'-#ticket'),
  );
  foreach($access as $key => $var)		// Accessliste durcharbeiten
   if(ifset($var[0])) {
    if($var[1][0] == '/') {			// Reguläre Ausdrücke verwenden (Schlüsselname)
     foreach($var[0] as $k => $v)
      if(preg_match($var[1],$k) and $var[0][$k])// Schlüssel Suchen und Prüfen
       $config[$key][$k] = $var[0][$k];
    }
    elseif($var[1][0] == '!' and preg_match($var[1],$var[0],$val) and preg_match_all($var[2],$val[1],$val)) {	// Reguläre Ausdrücke verwenden (Inhalt)
     foreach($val[3] as $k => $v)
      if(ifset($val[2][$k]))
       $name = $v;
      else
       $config[$key][$name][$val[1][$k]] = $v;
    }
    elseif($var[1][0] == '=') {			// Normal abfragen
     $keys = explode(',',substr($var[1],1));
     foreach($keys as $k)
      if(ifset($var[0][$k]))			// Schlüssel Testen
       $config[$key][$k] = $var[0][$k];
    }
    if(preg_match('/^([-+_])(.+)$/',$var[isset($var[2]) ? 2 : 1],$keys)) {	// Eine Schlüssel-Ebene überspringen
     if($keys[1] == '-' and count(array_filter(array_keys($var[0]),'is_string')) > 0)
      $var[0] = array($var[0]);
     $keys[3] = explode(',',$keys[2]);
     foreach($var[0] as $k => $v)
      if((preg_match('/\d+\s*$/',$k,$val) or $keys[1] == '+') and is_array($v)) {// Neue Ebene gefunden
       $name = $val ? false : $k;
       foreach($keys[3] as $val)
        if($val[0] == '>' and preg_match('/(\w+)([<>])(\w+)/',$val,$va1) and ifset($var[0][$k][$va1[1]][$va1[3]]))	// Mit Reguläre Ausdrücke noch eine Ebene überspringen
         if($name === false)
          $name = (string)$var[0][$k][$va1[1]][$va1[3]];
         else
          $config[$key][$name][(($va1[2] == '<') ? $va1[1] : $va1[3])] = $var[0][$k][$va1[1]][$va1[3]];	// Den Vorigen Schlüssel verwenden?
        elseif($val[0] == '#' and ifset($var[0][$k][$kk = substr($val,1)])) {	// Ketten-Werte
         if(!isset($config[$key][$kk]))						// Objekt schon vorhanden
          $config[$key][$kk] = array();						// Leere Kette anlegen
         $config[$key][$kk][] = $v[$kk];					// Kettenglied dranhängen
        }
        elseif(ifset($var[0][$k][$val]))					// Auf der neuen Ebene Prüfen
         if($name === false)
          $name = (string)$var[0][$k][$val];
         else
          $config[$key][$name][$val] = $var[0][$k][$val];
      }
    }
   }
  $bug and dbug($config,4,'ShowAccessData');		// Alle Fundstücke ungefiltert sichern
  foreach($config as $key => $var)			// Filter: Doppelte Kategorien zusammenfassen
   if($val = ifset($key,'/^([\w-]+)\d+$/') and isset($config[$val[1]])) {
    $config[$val[1]] = array_merge($config[$val[1]],$var);
    unset($config[$key]);
   }
  if(ifset($config['InternetTelefonie']))		// Filter: StunServerPort 3478 filtern
   foreach($config['InternetTelefonie'] as $key => $var)
    if(ifset($var['stunserverport'],3478))
     unset($config['InternetTelefonie'][$key]['stunserverport']);
  if(ifset($config['IPv6']) and ifset($config['IPv6']['ticserver']) and count($config['IPv6']) == 1)	// Filter: IPv6 tivserver
   unset($config['IPv6']);
  if(ifset($config['TR-069-Fernkonfiguration']) and ifset($config['TR-069-Fernkonfiguration']['url']) and count($config['TR-069-Fernkonfiguration']) == 1)	// Filter: TR069 url
   unset($config['TR-069-Fernkonfiguration']);
  if(ifset($config['Mobile-Stick']) and ifset($config['Mobile-Stick']['username'],'ppp') and ifset($config['Mobile-Stick']['passwd'],'ppp'))	// Filter: Surf-Stick ppp
   unset($config['Mobile-Stick']);
  if(ifset($config['Onlinespeicher']) and !ifset($config['Onlinespeicher']['password']))		// Filter: Onlinespeicher
   unset($config['Onlinespeicher']);
  if(ifset($config['DECT-eMail']))									// Filter: DECT-eMail
   foreach($config['DECT-eMail'] as $key => $var) {
    if(ifset($var['server']) and ifset($var['port'])) {	// Server & Port zusammenführen
     $config['DECT-eMail'][$key]['server'] .= ":$var[port]";
     unset($config['DECT-eMail'][$key]['port']);
    }
    if(ifset($var['user'],$key))			// Doppelte Namen
     unset($config['DECT-eMail'][$key]['user']);
    if(ifset($var['user_name'],$key))
     unset($config['DECT-eMail'][$key]['user_name']);
   }
  if(ifset($config['Netzwerkumgebung']))		// Filter: Netzwerkumgebung
   foreach($config['Netzwerkumgebung'] as $key => $var)	// Hosts ohne Kennwort
    if(!ifset($var['remotelogin_password']))
     unset($config['Netzwerkumgebung'][$key]);
  if(ifset($config['TR-064']) and !ifset($config['TR-064']['password']))	// Filter: TR-064
   unset($config['TR-064']);
  if(is_null($config['TR-069-Fernkonfiguration']))				// Filter: TR-069
   unset($config['TR-069-Fernkonfiguration']);
  elseif(is_null($config['TR-069-Fernkonfiguration']['url']))			// Filter: TR-069
   unset($config['TR-069-Fernkonfiguration']['url']);
  if(isset($config['WLAN']))							// Filter: WLAN
   foreach(array('','WDS_','STA_') as $key)
    if(isset($config['WLAN'][$key."ssid"])) {		// Doppelte SSID
     if(isset($config['WLAN'][$key."ssid_thrd"]) and ($config['WLAN'][$key."ssid"] == $config['WLAN'][$key."ssid_thrd"]
	or isset($config['WLAN'][$key."ssid_scnd"]) and $config['WLAN'][$key."ssid_thrd"] == $config['WLAN'][$key."ssid_scnd"]))
      unset($config['WLAN'][$key."ssid_thrd"]);
     if(isset($config['WLAN'][$key."ssid_scnd"]) and $config['WLAN'][$key."ssid"] == $config['WLAN'][$key."ssid_scnd"])
      unset($config['WLAN'][$key."ssid_scnd"]);
     if($key)
      foreach(array('ssid','key','pskvalue') as $var)	// Doppelte Kennwörter
       if(isset($config['WLAN'][$var]) and isset($config['WLAN'][$key.$var]) and $config['WLAN'][$var] == $config['WLAN'][$key.$var]
	or isset($config['WLAN']['pskvalue']) and isset($config['WLAN'][$key.$var]) and $config['WLAN']['pskvalue'] == $config['WLAN'][$key.$var])
        unset($config['WLAN'][$key.$var]);
    }
  $a = array('/^\${4}\w+/','(Verschlüsselt)');		// Verschlüsselte Einträge umschreiben
  foreach($config as $key => $var)
   if($var) {
    if($val = preg_array($a[0],$var,3)) {		// Array-Schlüssel umbennenen
     foreach($val as $k => $v) {
      $config[$key][] = $v;
      unset($config[$key][$k]);
     }
     $var = $config[$key];
    }
    foreach($var as $k => $v)
     if(is_array($v)) {					// Unterwert umschreiben
      foreach($v as $kk => $vv)
       if(ifset($vv,$a[0]))
        $config[$key][$k][$kk] = $a[1];
     }
     elseif(ifset($v,$a[0]))				// Hauptwert umschreiben
      $config[$key][$k] = $a[1];
   }
  foreach($config as $name => $keys)			// Array in Text Umwandeln
   if($keys) {
    foreach($keys as $key => $data) {
     if(is_array($data) and array_values($data) !== $data)// Assoc-Array
      foreach($data as $k => $v)
       $data[$k] = "$k=$v";
     $keys[$key] = "|$key|->|".str_replace('|','\|',implode(', ',(array)$data));
    }
    $text .= "\n$name\n".textTable(out(implode("\n",$keys),9))."\n";
   }
 }
 else
  $bug and dbug("showaccessdata fehlgeschlagen");
 return preg_replace_callback('/\\\\([0-7]{3})/',__FUNCTION__,$text);					// Zum Schluss noch Oktale-Ansi-Zeichen decodieren
}
function getevent($filter='aus',$sid=0) {		// Ereignisse abrufen
 global $cfg,$bug;
 $filters = array('aus','system','internet','telefon','wlan','usb');
 $jfilter = array('all','sys','net','fon','wlan','usb');
 $filter = (($var = ifset($filters,$filter)) !== false and $var != count($filters)) ? $var : 0;
 $bug and dbug("Hole Ereignisse (Filter: {$filters[$filter]})");
 if(!$sid)
  $sid = $cfg['sid'];
# $sid = (!is_bool($sid)) ? "&sid=$sid" : '';	// Veraltet
 if($cfg['fiwa'] < 500)
  $data = request('POST-array','/cgi-bin/webcm',http_build_query(array(
	'getpage' => '../html/de/system/ppSyslog.html',
	'logger:settings/filter' => $filter,
	'sid' => $sid)));
 elseif($cfg['fiwa'] < 669)
  $data = request('GET-array',"/system/syslog.lua",http_build_query(array(
	'tab' => $filters[$filter],
	'event_filter' => $filter,
	'stylemode' => 'print',
	'sid' => $sid)));
 $array = array(); // Date,Time,Text,Code,View,Help
 if(ifset($data) and preg_match('!\["[\w:/]+log_separate"\]\s*=\s*\{((\s*\[\d+\]\s*=\s*\{(\s*\[\d+\]\s*=\s*".*?",?)+\s*\},?)+)\s*\}!',$data[1],$code)
	and preg_match_all('!\s*\[(\d+)\]\s*=\s*\{((\s*\[\d+\]\s*=\s*".*?",?)+)\s*\}!',$code[1],$lines)) {
  foreach($lines[2] as $key => $line)
   if(preg_match_all('/"(.*?)(?<!\\\\)"/',$line,$cols))
    $array[] = $cols[1];
 }
 elseif(ifset($data) and preg_match_all(($cfg['fiwa'] < 500) ? '!<p class="log">(\S*)\s*(\S*)\s*(.*?)</p>!'
	: '!<tr><td[^>]*>(?:<div>)?(.*?)(?:</div>)?</td><td[^>]*>(.*?)</td><td[^>]*><a[^>]*?href="(.*?(\d+)\.html?)"[^>]*?>(.*?)</a></td></tr>!',$data[1],$lines)) {
  if(count($lines) < 5)
   foreach($lines[3] as $key => $line)
    $array[] = array(0 => $lines[1][$key], 1 => $lines[2][$key], 2 => $line);
  else
   foreach($lines[5] as $key => $line)
    $array[] = array(0 => $lines[1][$key], 1 => $lines[2][$key], 2 => $line, 3 => $lines[4][$key], 5 => $lines[3][$key]);
 }
 elseif($cfg['fiwa'] >= 669 and $data = request('POST-array','/data.lua',http_build_query(array(
	'xhr' => 1,
	'sid' => $sid,
	'lang' => 'de',
	'page' => 'log',
	'xhrId' => 'log',
	'filter' => (($cfg['fiwa'] < 739) ? $filter : $jfilter[$filter]),
	'no_sidrenew' => ''))) and $js = json2array($data[1]) and $log = ifset($js['data']['log'],true)) {
  $group = array_flip($jfilter);
  foreach($log as $key => $var) {
   $var = preg_replace('/sid=[\da-f]+&|[?&]sid=[\da-f]+$|\\\\(?=\/)/','',$var);
   $array[] = ($cfg['fiwa'] >= 739)
    ? array($var['date'],$var['time'],$var['msg'],$var['id'],$group[$var['group']],$var['helplink'])
    : $var;
  }
 }
 else {
  if(ifset($data))
   $bug and dbug($data,4,'GetEvent-data');
  return errmsg("8:Keine Ereignisse bekommen".(($var = errmsg(0,'request')) ? " ($var)" : ""),__FUNCTION__);
 }
 $event = array();
 $a = count($array);
 $b = 1;
 while($a)
  $event[strtotime("20".implode('-',array_reverse(explode('.',$array[--$a][0])))." ".$array[$a][1]).".".$b++] = $array[$a];
 $bug and dbug($event,4,'GetEvent_array');
 return $event;
}
function getcall($mode='call',$sid=0) {			// Anrufliste auslesen (mode: array,call,data)
 global $cfg,$bug;
 if(!$sid)
  $sid = $cfg['sid'];
 if($cfg['fiwa'] > 530 and $data = request('get','/fon_num/foncalls_list.lua',http_build_query(array(
	'sid' => $sid,
	'apply' => '',
	'csv' => '')))	// Download der Anrufliste
	or $data = request('get','/cgi-bin/webcm',http_build_query(array(
	'getpage' => '../html/de/FRITZ!Box_Anrufliste.csv',
	'sid' => $sid)))) {
  $sep = (preg_match('/^sep=(.+)/',$data[1],$var)) ? $var[1] : ';';
  $psep = preg_quote($sep,'/');
  if(preg_match_all("/^".($preg = "([0-4]$psep((0[1-9]|[12]\d|3[10])\.(0[1-9]|1[0-2])\.(?:20)?(\d\d)\s+([\d:]+)|[\w .:\/+-]+)($psep(.*?)){4,5})\s*$/")."m",$data[1],$array)) {
   $bug and dbug($array,4);
   if($mode == 'data')
    return $data[1];
   foreach($array as $key => $var)	// Komplette Matchliste umdrehen
    $array[$key] = array_reverse($var);
   $call = array();
   foreach($array[1] as $key => $var)
    if($time = strtotime(($array[3][$key]) ? "20{$array[5][$key]}-{$array[4][$key]}-{$array[3][$key]} {$array[6][$key]}" : $array[2][$key]))
     $call["$time.$key"] = preg_split("/(?<!\\\\)$psep/",$var);
   if($mode == 'call')
    return $call;
   return array('sep' => $sep, 'csv' => preg_replace('/\d[\s\S]*$/','',$data[1]), 'call' => $call, 'data' => $data[1]);
  }
  else
   return errmsg("8:Keine Anrufliste bekommen",__FUNCTION__);
 }
 else
  return errmsg("8:Anforderung der Anrufliste fehlgeschlagen".(($var = errmsg(0,'request')) ? " ($var)" : ""),__FUNCTION__);
}
function gettraffic($sid=0) {				// Traffic-Zähler als array auslesen
 global $cfg,$bug;
 if(!$sid)
  $sid = $cfg['sid'];
 $out = array();
 $bug and dbug("Hole Traffic-Daten ",0,2);
 if($cfg['fiwa'] < 550	// Fritz!OS 4 - 5.49
	and $rp = request('GET','/cgi-bin/webcm',http_build_query(array(
	'getpage' => '../html/de/menus/menu2.html',
	'var:lang' => 'de',
	'var:pagename' => 'inetstat',
	'var:menu' => 'home',
	'var:tabInetstat' => 1,
	'sid' => $sid)))
	and preg_match_all('/(?:^\s*(?:var\s)?(?:time|v?(?:in|out)[hl]|ap2ap)\s*=\s*[^;]*;\s*)+SetRow\(.*?\);|^\s*(?:var\s)?(?:max|rec|sent)(?:low|high)\s*=\s*\d*;/sm',$rp,$array)) {
  $bug and dbug("für OS 4 - 5.49");
  $bug and dbug($array,4);
  foreach($array[0] as $line)
   if(preg_match('/(time)\s=*\s*(\d*).*?SetRow\("(\w+)"/s',$line,$var)) {
    $key = $var[3];
    $out[$key][$var[1]] = intval($var[2]);
    if(preg_match('!<span\s*id="span'.$key.'\w+">.*?</span></td>\s*<td\s*class="c23">(\d*)</td>!',$rp,$var))
     $out[$key]['connect'] = intval($var[1]);
    if(preg_match_all('/(in|out)([hl])\s*=\s*(\d*);/',$line,$m))
     foreach($m[3] as $k => $v) {
      if(!isset($out[$key][$m[1][$k]]))
       $out[$key][$m[1][$k]] = 0;
      $out[$key][$m[1][$k]] += ($m[2][$k] == 'h') ? pow(2,32) * intval($v) : intval($v);
     }
    $out[$key]['sum'] = (ifset($out[$key]['in']) and ifset($out[$key]['out'])) ?  $out[$key]['in'] + $out[$key]['out'] : 0;
   }
   elseif(preg_match('/(\w+?)(low|high)\s*=\s*(\d*);/',$line,$m)) {	// Online-Zähler (Traffic)
    if(!isset($out['Counter'][$m[1]]))
     $out['Counter'][$m[1]] = 0;
    $out['Counter'][$m[1]] += ($m[2] == 'high') ? pow(2,32) * intval($m[3]) : intval($m[3]);
   }
  if(preg_match_all('!^\s*(?:var\s)?(cur|max)\s*=\s*Math.ceil\((\d+)/60\);!m',$rp,$m)) {
   $bug and dbug($m,4);
   $array = array('max' => 'maxtime', 'cur' => 'time');
   foreach($m[1] as $key => $var)
    if($m[2][$key])
     $out['Counter'][$array[$var]] = floor(intval($m[2][$key]) / 60);
  }
  $out['Counter']['sum'] = (ifset($out['Counter']['rec']) and ifset($out['Counter']['sent'])) ?  $out['Counter']['rec'] + $out['Counter']['sent'] : 0;
 }
 elseif($cfg['fiwa'] >= 550 and $cfg['fiwa'] < 650 and $rp = request('GET','/internet/inetstat_counter.lua',array('sid' => $sid)) and preg_match_all('!\["inetstat:status/(\w+)/(\w+)"\]\s*=\s*"(\d*)",!',$rp,$m)) {	// OS 5.50 - 6.49
  $bug and dbug("für OS 5.50 - 6.49");
  $bug and dbug($m,4);
  $array = array('BytesReceived' => 'in', 'BytesSent' => 'out', 'OutgoingCalls' => 'connect', 'PhyConnTimeOutgoing' => 'time');
  foreach($m[3] as $key => $var)
   if(preg_match('/^(.*?)((High)|Low)$/',$m[2][$key],$x)) {
    if(!isset($out[$m[1][$key]][$array[$x[1]]]))
     $out[$m[1][$key]][$array[$x[1]]] = 0;
    $out[$m[1][$key]][$array[$x[1]]] += isset($x[3]) ? pow(2,32) * $var : $var;
   }
   else
    $out[$m[1][$key]][$array[$m[2][$key]]] = $var;
  foreach($out as $key => $var)
   $out[$key]['sum'] = $out[$key]['in'] + $out[$key]['out'];
  $bug and dbug("Hole Budget-Zähler");
  if($rp = request('GET','/internet/inetstat_budget.lua',array('sid' => $sid)) and preg_match_all('!\["(?:inetstat:status/ThisMonth|connection\d:settings/Budget)/(\w+?)(Low|High)?"\]\s*=\s*"(\d*)",!',$rp,$m)) {
   $bug and dbug($m,4);
   $array = array('ConnectionTime' => 'maxtime', 'Volume' => 'max', 'BytesReceived' => 'rec', 'BytesSent' => 'sent', 'PhyConnTimeOutgoing' => 'time');
   foreach($m[3] as $key => $var)
    if(preg_match('/^((High)|Low)$/',$m[2][$key],$x)) {
     if(!isset($out['Counter'][$array[$m[1][$key]]]))
      $out['Counter'][$array[$m[1][$key]]] = 0;
     $out['Counter'][$array[$m[1][$key]]] += isset($x[3]) ? pow(2,32) * $var : $var;
    }
    elseif(isset($array[$m[1][$key]]))
     $out['Counter'][$array[$m[1][$key]]] = $var;
   $out['Counter']['sum'] = (ifset($out['Counter']['rec']) and ifset($out['Counter']['sent'])) ?  $out['Counter']['rec'] + $out['Counter']['sent'] : 0;
  }
 }
 elseif($cfg['fiwa'] >= 650 and $cfg['fiwa'] < 724 and $rp = request('POST','/data.lua',http_build_query(array(
	'xhr' => 1,
	'sid' => $sid,
	'lang' => 'de',
	'no_sidrenew' => '',
	'page' => 'netCnt'))) and preg_match_all('!<tr><td[^>]*>[^<>\n]+</td>\s*(?:<td[^>]*>[\d:]+</td>\s*){5}</tr>!x',$rp,$m)) {	// OS 6.50 - 7.23
  $bug and dbug("für OS 6.50+");
  $bug and dbug($m,4);
  $cols = array('label','time','sum','out','in','connect');
  $rows = array('Today','Yesterday','ThisWeek','ThisMonth','LastMonth');
  foreach($m[0] as $key => $var)
   if(preg_match_all('!<td[^>]*>([^<>]+)</td>!',$var,$line))
    foreach($line[1] as $k => $v)
     if($k)
      $out[$rows[$key]][$cols[$k]] = ($k < 5 and $k > 1) ? $v * 1024 * 1024 : (($k == 1 and $x = explode(':',$v)) ? intval($x[0]) * 60 + intval($x[1]) : $v);
  if(preg_match('!<tr>\s*<td[^>]*>[^<>]*</td>\s*<td[^>]*><div[^>]*>(?:<span[^>]*>\s*</span>)+\s*</div>\s*</td>\s*<td>(?:(\d+)\D+(\d+)\sMB|(\d+)\D+(\d+)\D+(\d+)\D+)</td>\s*</tr>!',$rp,$m)) {
   $bug and dbug($m,4);
   if($m[2]) {
    $out['Counter']['sum'] = intval($m[1]) * 1024 * 1024;
    $out['Counter']['max'] = intval($m[2]) * 1024 * 1024;
   }
   else {
    $out['Counter']['time'] = intval($m[3]) * 60 + intval($m[4]);
    $out['Counter']['maxtime'] = intval($m[5]) * 60;
   }
  }
 }
 elseif($cfg['fiwa'] >= 724 and $rp = request('POST','/data.lua',http_build_query(array(
	'xhr' => 1,
	'sid' => $sid,
	'lang' => 'de',
	'no_sidrenew' => '',
	'page' => 'netCnt'))) and preg_match_all('!<tr[^>]*>\s*<td[^>]*>[^<>\n]+</td>\s*(?:<td[^>]*>[\d:\s]+</td>\s*)+</tr>!x',$rp,$m) and preg_match_all('/"(\w+)":\{((?:"\w+":"\d+",?)+)\}/sx',$rp,$n)) {	// OS 7.24+
  $bug and dbug("für OS 7.24+");
  foreach($m[0] as $var)
   if(preg_match('!<tr id="ui(\w+)">\s*(?:<td[^>]*>(?:(\d+):)?([\w\s]+)</td>\s*){2}(?:<td[^>]*>([\s\d]+)</td>\s*){4}!',$var,$v)) {
    $out[$v[1]]['time'] = $v[2] * 60 + $v[3];
    $out[$v[1]]['connect'] = intval($v[4]);
    $out[$v[1]]['in'] = $out[$v[1]]['out'] = $out[$v[1]]['sum'] = 0;
   }
  $cols = array('Sent' => 'out', 'Received' => 'in');
  foreach($n[2] as $key => $var)
   if(preg_match_all('/"Bytes(Sent|Received)(High|Low)":"(\d+)"/',$var,$x))
    foreach($x[1] as $k => $v) {
     $k = $x[3][$k] * (($x[2][$k] == 'Low') ? 1 : pow(2,32));
     $out[$n[1][$key]][$cols[$v]] += $k;
     $out[$n[1][$key]]['sum'] += $k;
    }
  if(preg_match('!<tr>\s*<td[^>]*>\w+</td>\s*<td>\s*<div\s*class="meter">\s*<span\sclass="bar\sused\w*"[^>]*></span>\s*<span[^>]*></span>\s*</div>\s*</td>\s*<td>(?:(\d+)\D+(\d+)\sMB|(?:(\d+)\s\w+\s)?(?:(\d+)\s\w+)?\D+(\d+)\s\w+)</td>\s*</tr>!sx',$rp,$v))
   if($v[1].$v[2]) {
    $out['Counter']['sum'] = intval($v[1]) * 1024 * 1024;
    $out['Counter']['max'] = intval($v[2]) * 1024 * 1024;
   }
   else {
    $out['Counter']['time'] = intval($v[3]) * 60 + intval($v[4]);
    $out['Counter']['maxtime'] = intval($v[5]) * 60;
   }
 }
 else {
  $bug and dbug("- fehlgeschlagen");
  $out = errmsg("8:Traffic konnte nicht ermittelt werden",__FUNCTION__);
 }
 if($out) {
  foreach($out as $key => $var)				// Strings in INT Convertieren
   if(is_array($var))
    foreach($var as $k => $v)
     if(is_string($v) and is_numeric($v))
      $out[$key][$k] = intval($v);
  $out['Time'] = ifset($cfg['http']['Date']) ? strtotime($cfg['http']['Date']) : 0;
  $bug and dbug($out,9);
 }
 return $out;
}
function smarthome($cmd=0,$ain=0,$set=array(),$sid=0) {	// SmartHome Geräteliste, Infos, Schalten (cmd:string/array, ain, set:array, sid)
 global $cfg,$strftime,$bug;
 $fn = __FUNCTION__;
 if($cmd == 'temp')						// temp: Temperatur entschlüsseln
  $out = ($ain == 0 or $ain == 253) ? "aus" : (($ain == 1 or $ain == 254) ? "an" : (($ain == 2) ? 'um' : ($ain/2)."°C"));
 elseif($cmd == 'functionbit') {				// functionbit: functionbitmask Entschlüsseln
  $name = explode(',',"HANFUN Gerät,Bit1,Lampe,Bit3,Alarm-Sensor,Taster,Heizkörperregler,Energie Messgerät,Temperatursensor,Schaltsteckdose,"
	."DECT Repeater,Mikrofon,Gruppe,HANFUN Unit,Bit14,Schaltbar,Dimmbar,Farblampe,Rollladen,Bit19,Luftfeuchtigkeitssensor"); // (5-7,9-11 für AVM-Aktoren)
  foreach($name as $key => $var) {
   if($ain % 2)
    $set[$key] = $var;
   $ain >>= 1;
  }
  return $set;
 }
 elseif($cmd == 'template') {					// Templates suchen
  foreach($set as $var)
   if(ifset($var['identifier'],'/^tmp[\w-]+$/') and ($ain == $var['id'] or $ain == $var['identifier'] or strtolower($ain) == strtolower($var['name'])))
    return $var;
  return false;
 }
 elseif($ain === true and is_array($cmd) and !$set) {		// Type STRING aus Array weitgehend in INT/FLOAT umwandeln
  foreach($cmd as $key => $var)
   $set[is_numeric($key) ? intval($key) : $key] = is_array($var) ? call_user_func($fn,$var,true)
	: ((is_string($var) and preg_match('/^(?:(\d{1,7})|((?!0\.0$)\d{1,7}\.\d+))($)/',$var,$val))
	? (($val[1] != '') ? intval($var) : (($val[2] != '') ? floatval($var) : $var)) : $var);
  return $set;
 }
 else {
  $bug and dbug(compact(explode(',','cmd,ain,set,sid')),9);
  if(!$sid)
   $sid = $cfg['sid'];
  $out = false;
  $link = '/webservices/homeautoswitch.lua';
  $parm = "sid=$sid&switchcmd=";
  $device = array();
  $hfu = array();
  if($ain and $set === true) {	// Force-Modus
   if(preg_match('/on|off|trip/',$cmd)) {	// Nur einfaches Schalten
    $do = array('Aktor wurde ausgeschaltet','Aktor wurde eingeschaltet','on' => 'setswitchon', 'off' => 'setswitchoff', 'trip' => 'setswitchtoggle');
    if($out = request('GET',$link,$parm.$do[$cmd]."&ain=$ain")) {
     if(ifset($out,'/^\d+\s*$/') and isset($do[(int)$out]))
      $out = $do[(int)$out];
    }
    else
     $out = errmsg("8:Aktor '$ain' nicht gefunden",$fn);
   }
   elseif($cmd == 'set') {	// Template setzen
    $bug and dbug("Setze Template");
    $out = ($var = request('GET',$link,$parm."applytemplate&ain=$ain")) ? "Template-ID '".trim($var)."' wurde gesetzt" : errmsg("8:Template '$ain' nicht gefunden",$fn);
   }
   else
    $out = errmsg("64:Force-Modus nur für on/off/switch/set mit AIN verfügbar",$fn);
  }
  elseif($xml = request('GET',$link,$parm."getdevicelistinfos") and preg_match_all('!<(device|group)\s([^>]+)>(.*?)</\1>!s',preg_replace('/[\r\n]+/','',$xml),$list)) {
   $bug and dbug("Werte SmartHome Geräteliste aus");
   if($cmd == 'xml')						// xml: Gebe ROH-Daten zurück
    return $xml;
   $bug and dbug($xml,9);
   $bug and dbug($list,4);
   foreach($list[2] as $k => $v) {				// Devices und Gruppen durchgehen
    $device[$k] = xml2array($list[3][$k],false);		// Device Infos einlesen
    if(preg_match_all('/([\w-]+)="([^"]+)"/',$v,$m))		// Device Attribute einlesen
     foreach($m[1] as $key => $var)
      $device[$k][$var] = $m[2][$key];
    if(ifset($device[$k]['functionbitmask']))			// Device Bitmaske entschlüsseln
     $device[$k]['functionbitname'] = call_user_func($fn,'functionbit',$device[$k]['functionbitmask']);
    if(isset($device[$k]['etsiunitinfo']) and $var = $device[$k]['etsiunitinfo']) {	// HAN-FUN Unit/Gerät
     $units = json2array("[	266:DIMMER_SWITCH,	278:DIMMABLE_COLOR_BULB,
	281:BLIND,		273:SIMPLE_BUTTON,	519:GLAS_BREAK_DETECTOR,
	640:SIREN,		518:FLOOD_DETECTOR,	257:SIMPLE_ON_OFF_SWITCH,
	282:LAMELLAR,		265:DIMMABLE_LIGHT,	256:SIMPLE_ON_OFF_SWITCHABLE,
	262:AC_OUTLET,		512:SIMPLE_DETECTOR,	513:DOOR_OPEN_CLOSE_DETECTOR,
	277:COLOR_BULB,		515:MOTION_DETECTOR,	514:WINDOW_OPEN_CLOSE_DETECTOR,
	264:SIMPLE_LIGHT,	520:VIBRATION_DETECTOR,	263:AC_OUTLET_SIMPLE_POWER_METERING]");
     $types = json2array("[	277:KEEP_ALIVE,		256:ALERT,	512:ON_OFF,	772:SIMPLE_BUTTON,
	517:OPEN_CLOSE_CONFIG,	516:OPEN_CLOSE,		513:LEVEL_CTRL,	514:COLOR_CTRL,	1024:SUOTA_Update]");
     $hfu[$device[$k]['id']] = $var['etsideviceid'];
     if(ifset($var['unittype']) and $units and isset($units[$var['unittype']]))
      $device[$k]['etsiunitinfo']['unittypename'] = $units[$var['unittype']];
     if($types and ifset($var['interfaces']))
      $device[$k]['etsiunitinfo']['interfacename'] = preg_array('/^('.str_replace(',','|',$var['interfaces']).')$/',$types,3);
    }
    if(isset($device[$k]['functionbitname'][2])) {		// Einstellbare Vorgabe-Farben ermitteln
     if($xml = request('GET',$link,$parm."getcolordefaults") and preg_match_all('/<hs\b[^>]*>.*?<\/hs>/s',$xml,$array))	// Farbwerte extrahieren
      foreach($array[0] as $var)
       if(is_array($val = xml2array($var,-1)) and $device[$k]['defaults']['hue'][$val['hs']['color'][0][-1]['hue']] = $val['hs']['name'][0])
        foreach($val['hs']['color'] as $v)
         $device[$k]['defaults']['color'][$val['hs']['name'][0]][$v[-1]['sat_index']] = array('hue' => $v[-1]['hue'], 'sat' => $v[-1]['sat'], 'val' => $v[-1]['val']);
     if(preg_match_all('/<temp\b[^\d>]*(\d+)[^>]*\/>/s',$xml,$array))	// Farbtemperatur extrahieren
      $device[$k]['defaults']['temperature'] = $array[1];
    }
    if(isset($device[$k]['template']) and $device[$k]['template'] === array(null))	// Unnötige Einträge entfernen
     $device[$k]['template'] = array();
   }
   $template = array();						// Templates ohne Devices
   if($xml = request('GET',$link,$parm."gettemplatelistinfos") and preg_match_all('!<(template)\s([^>]+)>(.*?)</\1>!s',preg_replace('/[\r\n]+/','',$xml),$list))
    foreach($list[2] as $key => $var)				// Templates durchgehen
     if(preg_match_all('/(\w+)="([^"]*)"/',$var,$array)) {
      $array = array_combine($array[1],$array[2]);
      $array['key'] = $key;
      if(isset($array['functionbitmask']))
       $array['functionbitname'] = call_user_func($fn,'functionbit',$array['functionbitmask']);
      $array['name'] = preg_match('/<name>(.*?)<\/name>/',$list[3][$key],$m) ? $m[1] : false;
      $array['device'] = preg_match_all('/<device identifier="([^"]*)"\s*\/>/',$list[3][$key],$m) ? $m[1] : array();
      $array['devices'] = array();
      $c = count($template);
      if($array['device']) {
       foreach($array['device'] as $k => $v)
        foreach($device as $key => $var) {
         if($var['identifier'] == $v) {
          $device[$key]['template'][] = $c;			// Eintragen
          $array['devices'][] = $device[$key]['name'];
         }
       }
      }
      $template[$c] = $array;
     }
   $idx = array();						// ID-Index anlegen
   foreach($device as $key => $var)
    $idx[$var['id']] = $key;
   foreach($hfu as $key => $var) {				// Doppelte HAN-FUN Units/Geräte zusammenlegen
    if((float)$device[$idx[$key]]['fwversion'] == 0)
     $device[$idx[$key]]['fwversion'] = $device[$idx[$var]]['fwversion'];
    $device[$idx[$key]]['link'] = $device[$idx[$var]];		// Kopie sichern
    unset($device[$idx[$var]]);					// Device löschen
    unset($hfu[$key]);						// Link zum Device löschen
   }
   $bug and dbug($device,9);
   $device = call_user_func($fn,$device,true);
   if(!$ain and $cmd == 'array')
    return $device;
   if($ain) {							// Einzelnen Aktor Schalten oder auslesen
    $tmp = array();
    foreach($device as $v)
     if($ain == $v['id'] or preg_replace('/\W/','',strtoupper($ain)) == preg_replace('/\W/','',$v['identifier']) or strtolower($ain) == strtolower($v['name'])) {
      $bug and dbug("Aktor/Gruppe '$ain' gefunden",9);
      $ain = $v;
      break;
     }
    if(!is_array($ain))						// Ist Template
     $tmp = call_user_func($fn,'template',$ain,$template);
    if($cmd == 'array')
     return $ain;
    if(is_array($ain))
     if($cmd == 'info') {					// Aktordaten	(Info Ausgeben)
      $out = "Hauptdaten|Name:|$ain[name]
|AIN:|$ain[identifier]
|ID:|$ain[id]
|Hersteller:|$ain[manufacturer]".(ifset($ain['productname']) ? "\n|Modell:|$ain[productname]" : "")."
|Funktionen:|".implode(", ",$ain['functionbitname'])."
|Verbindung:|".($ain['present'] ? "Online" : "Offline")
.((ifset($ain['fwversion']) and (float)$ain['fwversion']) ? "\n|Firmware:|$ain[fwversion]" : "")
.(isset($ain['txbusy']) ? "\n|Beschäftigt:|".($ain['txbusy'] ? "Ja" : "Nein") : "")
.(ifset($ain['simpleonoff']) ? "\n|Schaltzustand:|A".($ain['simpleonoff']['state'] ? "n" : "us") : "")
.(($a = ifset($ain['battery']) or isset($ain['link']) and $a = ifset($ain['link']['battery'])) ? "\n|Batterie:|$a%"
	.(($ain['batterylow'] or isset($ain['link']) and ifset($ain['link']['batterylow'])) ? " (Schwach)" : "") : "")."\n";
      if(ifset($ain['template'])) {
       $array = array();
       foreach($ain['template'] as $var)
        $array[] = $template[$var]['name'];
       $out .= "|Template:|".implode(", ",$array)."\n";
      }
      if(ifset($ain['groupinfo'])) {
       $array = explode(',',$ain['groupinfo']['members']);
       foreach($array as $key => $var) {
        $val = $device[$idx[intval($var)]];
        $array[$key] = ifset($val['name']) ? $val['name'] : $val['identifier'];
       }
       $out .= "Gruppe|Mitglieder:|".implode(", ",$array)."\n";
       if(ifset($ain['groupinfo']['masterdeviceid'])) {
        $var = $device[$idx[$ain['groupinfo']['masterdeviceid']]];
        $out .= "|Master:|".($var['name'] ? $var['name'] : $var['identifier'])."\n";
       }
      }
      if(ifset($ain['switch']) and $x = $ain['switch'] or ifset($ain['hkr']) and $x = $ain['hkr'])
       $out .= "Schloss|Taster:|".($x['devicelock'] ? "Gesperrt" : "Frei")."
|Fernsteuerung:|".($x['lock'] ? "Gesperrt" : "Frei")."\n";
      if(ifset($ain['powermeter']) and $x = $ain['powermeter'])
       $out .= "Energie Messgerät|Spannung:|".number_format(intval($x['voltage'])/1e3,2,",",".")." Volt
|Leistung:|".number_format(intval($x['power'])/1e3,3,",",".")." Watt
|Stromzähler:|".number_format(intval($x['energy'])/1e3,3,",",".")." KiloWattStunden\n";
      if(ifset($ain['switch']) and $x = $ain['switch'])
       $out .= "Schaltsteckdose|Schaltzustand:|".($x['state'] ? "An" : "Aus")."
|Modus:|".ucfirst($x['mode'])."\n";
      if(ifset($ain['temperature']) and $x = $ain['temperature'])
       $out .= "Temperatur|Sensor:|".(intval($x['celsius'])/10)."°C".($x['offset'] ? "\n|Offset:|".preg_replace('/^(?=\d)/','+',$x['offset']/10) : "")."\n";
      if(ifset($ain['humidity']) and (int)$x = ifset($ain['humidity']['rel_humidity']))
       $out .= "Luftfeuchtigkeit|Sensor:|$x%\n";
      if(ifset($ain['hkr']) and $x = $ain['hkr'])
       $out .= "Heizregler|Aktuell:|".call_user_func($fn,'temp',$x['tist'])."
|Eingestellt:|".call_user_func($fn,'temp',$x['tsoll'])."
|Spar:|".call_user_func($fn,'temp',$x['absenk'])."
|Komfort:|".call_user_func($fn,'temp',$x['komfort'])."
|Nächste Änderung:|".$strftime($cfg['fstr'],$x['nextchange']['endperiod'])." auf ".call_user_func($fn,'temp',$x['nextchange']['tchange'])."
|Fenster:|".($x['windowopenactiv'] ? "Offen" : "Geschlossen")."
|Sommerpause:|".($x['summeractive'] ? "Aktiviert" : "Aus")."
|Urlaub:|".($x['holidayactive'] ? "Aktiv" : "Aus")."
|Letzter Fehler:|".(($y = explode("\n","Kein Fehler
Keine Adaptierung möglich
Ventilhub zu kurz oder Batterieleistung zu schwach
Keine Ventilbewegung möglich
Die Installation wird gerade vorbereitet
Der Heizkörperregler ist im Installationsmodus und kann auf das Heizungsventil montiert werden
Der Heizkörperregler passt sich nun an den Hub des Heizungsventils an")) ? (ifset($y[$x['errorcode']]) ? $y[$x['errorcode']] : "Unbekannt ($x[errorcode])") : "")."\n";
      if(isset($ain['functionbitname'][2])) {			// Lampe
       $out .= "Lampe";
       if(ifset($ain['levelcontrol']) and $x = $ain['levelcontrol'])
        $out .= "|Helligkeit:|".($v = (isset($x['levelpercentage']) ? intval($x['levelpercentage']) : (isset($x['level']) ? floor($x['level']/2.55) : 'Unbekannt')))."%\n";
       if(ifset($ain['colorcontrol']) and $x = $ain['colorcontrol']) {
        if(isset($x['hue']) and $h = $x['hue'] and isset($ain['defaults']['hue'])) {
         if(isset($ain['defaults']['hue'][$h]))
          $hue = $ain['defaults']['hue'][$h];
         else {
          $var = array_values($ain['defaults']['hue']);
          $hue = $var[round($h/30)%12];
         }
         $out .= "|Farbwinkel:|{$h}° ($hue)\n";
        }
        $var = array('Warm','Neutral','Kalt');
        if(isset($x['saturation']))
         $out .= "|Farbsättigung:|".floor($s = intval($x['saturation']) / 2.55)."%\n";
        if(isset($x['temperature']) and $y = $x['temperature'])
         $out .= "|Farbtemperatur:|$y K (".(($z = preg_array('/'.preg_quote($y,'/').'/',$ain['defaults']['temperature'],4)) ? $var[floor($z / 3)]." ".($z % 3 + 1)
		: (($y >= 2700 and $y <= 3400) ? "Warm" : (($y >= 3800 and $y <= 4700) ? "Neutral" : (($y >= 5300 and $y <= 6500) ? "Kalt" : "Unbekannt")))).")\n";
        if(isset($ain['defaults']['hue']))
         $out .= "|Vorgabefarben:|".implode(', ',array_merge($var,$ain['defaults']['hue']))."\n";
        if(isset($ain['defaults']['temperature']))
         $out .= "|Temperaturwerte|".implode(", ",$ain['defaults']['temperature'])." (Kelvin)\n";
       }
       if(isset($h) and isset($s) and isset($v)) {		// HSV in RGB umrechnen
        for($c = array(0,0,0), $i = 0; $i < 4; $i++)
         if(abs(intval($h) - $i * 120) < 120)
          $c[$i % 3] = 1 - ((max(60,abs(intval($h) - $i * 120)) - 60) / 60);
        for($h = max($c), $i = 0; $i < 3; $i++)
         $c[$i] = round(($c[$i] + ($h - $c[$i]) * (1 - intval($s) / 100)) * 255 * (intval($v) / 100));
        $out .= sprintf("|RGB-Farbwert:|#%02X%02X%02X\n",$c[0],$c[1],$c[2]);
       }
      }
      if(ifset($ain['button'])) {				// Taster
       $array = ifset($ain['button'][0]) ? $ain['button'] : array($ain['button']);
       foreach($array as $k => $v)
        $out .= "Schalter #".($k + 1)."|Name:|$v[name]
|AIN:|$v[identifier]
|ID:|$v[id]".(ifset($v['lastpressedtimestamp']) ? "\n|Zuletzt betätigt:|".$strftime($cfg['fstr'],$v['lastpressedtimestamp']) : "")."\n";
      }
      if(isset($ain['functionbitname'][4]) and isset($ain['alert']))	// Alarmsensor (Fenster Kontakt)
       $out .= "Alarm-Sensor|Fenster:|".($ain['alert']['state'] ? "Geöffnet" : "Geschlossen")."\n";
      if(ifset($ain['etsiunitinfo']) and $x = $ain['etsiunitinfo'])// HAN-FUN Unit/Gerät
       $out .= "HAN-FUN Unit|Type:|$x[unittypename]\n|Interfaces:|".implode(", ",$x['interfacename'])."\n";
      if($cfg['dbug'])						// Debug-Modus
       foreach($ain as $key => $var)
        if(is_null($ain[$key]))
         unset($ain[$key]);
      $bug and dbug($ain,9);
     }
     elseif($ain['present']) {					// Verschiedene Kommandos
      $do = array('on' => 'setswitchon', 'off' => 'setswitchoff', 'trip' => 'setswitchtoggle');
      $d0 = array_flip(array('off','on','trip'));
      $aid = str_replace(' ','',$ain['identifier']);
      if(ifset($ain['txbusy']))					// Beschäftigt
       $out = "$ain[name] ist noch mit der letzten Aktion beschäftigt!";
      elseif(ifset($ain['simpleonoff']) and ifset($cmd,'/test/')) {// Universal Schnelltest für on / off
       $out = "$ain[name] ist A".(($ain['simpleonoff']['state']) ? "N" : "US")." geschaltet!";
       if($ain['simpleonoff']['state'])
        errmsg("1:$out",$fn);
      }
      elseif(ifset($ain['simpleonoff']) and ifset($cmd,'/on|off/'))// Universal an / aus
       $out = request('GET',$link,$parm."setsimpleonoff&onoff=".$d0[$cmd]."&ain=$aid");
      elseif((ifset($ain['functionbitname'][9]) or ifset($ain['functionbitname'][15]))		// Schaltsteckdosen
	and (ifset($cmd,'/test/') and $a = 1 or ifset($ain['switch']['lock']) and $a = 2 or ifset($cmd,'/on|off|trip/') and $a = 3)) {
       if(!--$a) {				// test
        $out = "$ain[name] ist A".(($ain['switch']['state']) ? "N" : "US")." geschaltet!";
        if($ain['switch']['state'])
         errmsg("1:$out",$fn);
       }
       elseif(!--$a)
        $out = errmsg("8:Aktor ist für die Fernwartung gesperrt!",$fn);
       elseif(!--$a)						// on / off / trip
        $out = request('GET',$link,$parm.$do[$cmd]."&ain=$aid");
      }
      elseif(ifset($ain['functionbitname'][6])) {		// Heizkörperregler
       if($cmd == 'test') {
        $out = "$ain[name] ist ".preg_replace('/^(?=\d)/','auf ',call_user_func($fn,'temp',$ain['hkr']['tsoll']))." gestellt";
        if(!$ain['hkr']['tsoll'] and $ain['hkr']['tsoll'] != 253)
         errmsg("1:$out",$fn);
       }
       elseif(ifset($ain['hkr']['lock']))
        $out = errmsg("8:Aktor ist für die Fernwartung gesperrt!",$fn);
       elseif(ifset($cmd,'/on|off|trip|set/')) {
        $var = isset($set['hkr']) ? $set['hkr'] : false;
        $do = array('on' => 254, 'off' => 253, 'trip' => ($ain['hkr']['tsoll'] == 253) ? 254 : 253, 'set' => ($var == 'spar')
	? $ain['hkr']['absenk'] : (($var == 'komfort') ? $ain['hkr']['komfort'] : (($var == 'an' or $var == 'on') ? 254
	: ((!$var or $var == 'aus' or $var == 'off') ? 253 : floor(floatval($var)*2)))));
        $out = request('GET',$link,$parm."sethkrtsoll&param=".$do[$cmd]."&ain=".urlencode($ain['identifier']));
       }
      }
      elseif(ifset($ain['functionbitname'][2]) and $cmd == 'set') {	// Lampe
       $hue = $sat = $val = $kel = $col = $a = 0;
       $delay = "&duration=".(ifset($set['delay']) ? $set['delay'] : 0);
       if($hsv = ifset($set['hsv'],'/\d+/a'))				// HSV-Angaben
        foreach($xxx = array_combine(array('hue','sat','val'),array_pad($hsv[0],3,0)) as $key => $var)
         $$key = round($var * (($a++) ? 2.55 : 1));
       if($var = ifset($set['color'],'/^(?:(warm)|(neutral)|(cold|kalt)|([\w\s]*?))([1-3]?)($)/ui') or $var = ifset($set['color'],'/(^)()()([\w\säöüßÄÖÜ]+)([1-3]?)($)/'))
        if($var[1] or $var[2] or $var[3])
         $kel = $ain['defaults']['temperature'][($var[1] ? 0 : ($var[2] ? 3 : ($var[3] ? 6 : 0))) + ($var[5] ? $var[5]-1 : 0)];
        elseif($var[4] and $col = preg_array('/^'.preg_quote(utf8($var[4],1),'/').'/i',array_combine(array_keys($ain['defaults']['color']),preg_replace('/\s+/','',array_keys($ain['defaults']['color']))),4))
         extract($ain['defaults']['color'][$col][$var[5] ? $var[5] : 1]);
       if(ifset($set['dimm']))
        $val = round($set['dimm'] * 2.55);
       if(ifset($set['kelvin']))
        $kel = (int)$set['kelvin'];
       if(($hue and $sat or $hsv)) {
        $bug and dbug("Setzte Farbe {$hue}° und Sättigung $sat/255 auf $ain[name]");
        if(request('GET',$link,$parm."setcolor&hue=$hue&saturation=$sat$delay&ain=$aid"))
         $out = "$ain[name] wurde auf ".($col ? "die Farbe $col" : "den Farbwinkel {$hue}°")." mit ".round($sat/2.55)."% Farbsättigung eingestellt";
       }
       elseif($kel) {
        $bug and dbug("Setzte $kel Kelvin auf $ain[name]");
        $out = (trim(request('GET',$link,$parm."setcolortemperature&temperature=$kel$delay&ain=$aid")) == $kel) ? "$ain[name] wurde auf $kel Kelvin gestellt" : "";
       }
       if($val) {
        while($var = call_user_func($fn,'array',$aid) and ifset($var['txbusy'])) {			// Warten bis die Lampe fertig ist
         $bug and dbug("Warte...");
         sleep(1);
        }
        $bug and dbug("Setze Helligkeit $val auf $ain[name]");
        if(request('GET',$link,$parm."setlevel&level=$val$delay&ain=$aid"))				// Helligkeit setzen
         $out = ($out ? "$out und" : "$ain[name] wurde")." auf ".round($val/2.55)."% Helligkeit gesetzt";
       }
      }
      elseif(ifset($cmd,'/open|close|stop/i') and isset($ain['etsiunitinfo']['interfacename'][281]))	// Rollläden
       $out = (request('GET',$link,$parm."setblind&target=".strtolower($cmd)."&ain=$aid")) ? "$ain[name] wurde geschaltet" : "";
      elseif(isset($ain['functionbitname'][4]) and ifset($cmd,'/test/') and isset($ain['alert'])) {	// Alarmsensor (Fenster Kontakt)
       $var = $ain['alert']['state'];
       $out = "Alarm-Sensor:".($var ? "Geöffnet" : "Geschlossen")."\n";
       if($var)
        errmsg("1:$out",$fn);
      }
      if(!$out)
       $out = errmsg("64:Aktor unterstützt diese Funktion nicht!",$fn);
      elseif(ifset($out,'is_numeric'))
       $out = "$ain[name] wurde ".preg_replace('/^(?=\d)/','auf ',call_user_func($fn,'temp',$out))." geschaltet!";
     }
     else
      $out = errmsg("8:Aktor ist nicht verbunden bzw. OFFLINE!",$fn);
    elseif($cmd == 'set' and $tmp = call_user_func($fn,'template',$ain,$template)) {	// Template setzen
     $bug and dbug("Setze Template: '$tmp[name]'");
     request('GET',$link,$parm."applytemplate&ain=$tmp[identifier]");
    }
    elseif(ifset($cmd,'/on|off|trip/')) {
     $do = array('on' => 'setswitchon', 'off' => 'setswitchoff', 'trip' => 'setswitchtoggle');
     $out = request('GET',$link,$parm.$do[$cmd]."&ain=".urlencode($ain));
    }
    elseif($tmp and $cmd == 'info') {				// Template Infos ausgeben
     $out = "Template|Name:|$tmp[name]\n|AIN:|$tmp[identifier]\n|ID:|$tmp[id]\n";
     if($tmp['functionbitname'])
      $out .= "|Funktionen:|".implode(", ",$tmp['functionbitname'])."\n";
     if($tmp['devices'])					// Aktoren-Liste ausgeben
      $out .= "|Aktor".((count($tmp['devices']) > 1) ? "en" : "").":|".implode(", ",$tmp['devices'])."\n";
    }
    else
     $out = errmsg("8:Aktor/Vorlage '$ain' nicht gefunden!",$fn);
   }
   elseif($cmd == 'json')
    $out = array2json(array('device' => $device, 'template' => $template),5)."\n";
   else {							// Device-Liste zurückgeben
    $list = array();
    $spar = array(0,0);
    foreach($device as $k => $v) {
     $array = array('ID' => 'id', 'AIN' => 'identifier', 'Name' => 'name', 'Modell' => 'productname', 'OS' => 'fwversion');
     foreach($array as $key => $var)
      $list[$k][$key] = ifset($v[$var]) ? $v[$var] : false;
     if(!$list[$k]['Modell'] and ifset($v['groupinfo'])) {
      $var = count(explode(',',$v['groupinfo']['members']));
      $list[$k]['Modell'] = "Gruppe ($var Mitglied".(($var == 1) ? "" : "er").")";
     }
     $list[$k]['Batterie'] = isset($v['battery']) ? ($spar[0] = "$v[battery]%") : "-";
     $val = "-";
     if(ifset($v['temperature'])) {				// Temperatur
      $x = $v['temperature'];
      if(isset($x['celsius']))
       $val = (intval($x['celsius'])/10)."°C";
      if(isset($x['offset']) and $x['offset'])
       $val .= " (".preg_replace('/^(?=\d)/','+',$x['offset']/10).")";
      $spar[1] = $val;
     }
     elseif(ifset($v['hkr']) and ifset($v['hkr']['tist']))	// Alternative Möglichkeit über HKR
      $val = call_user_func($fn,'temp',$v['hkr']['tist']);
     $list[$k]['Temperatur'] = $val;
     $val = "offline";						// Status
     if($v['present']) {
      if(isset($v['switch']['state'])) {			// Schaltsteckdose
       if(($val = ($v['switch']['state']) ? "an" : "aus") == 'on' and isset($v['powermeter']['power']))
        $val .= " (".($v['powermeter']['power']/1e3)."W)";
      }
      elseif(isset($v['hkr']['tsoll']))				// Heizkörperregler
       $val = call_user_func($fn,'temp',$v['hkr']['tsoll']);
      elseif(isset($v['simpleonoff']['state']))			// Schaltlampe
       $val = ($v['simpleonoff']['state']) ? "an" : "aus";
      elseif(isset($v['alert']))				// Alarm-Sensor (Fenster Kontakt)
       $val = ($v['alert']['state']) ? "offen" : "geschlossen";
      else
       $val = "online";						// Unbekannt
     }
     $list[$k]['Status'] = $val;
    }
    foreach($template as $k => $v)				// Templates ohne Devices
     $list[] = array(
	'ID' => $v['id'],
	'AIN' => $v['identifier'],
	'Name' => $v['name'],
	'Modell' => 'Template');
    if(!array_sum(preg_replace('/\D+/','',$spar)))		// Unnütze Spalten einsparen
     foreach($list as $key => $var) {
      if(!$spar[0])
       unset($list[$key]['Batterie']);
      if(!$spar[1])
       unset($list[$key]['Temperatur']);
     }
    if($cmd == 'csv') {						// CSV-Ausgabe
     $s = ifset($set['csv']) ? $set['csv'] : ";";
     $out = implode($s,array_keys(reset($list)))."\n";
     foreach($list as $var)
      $out .= implode($s,preg_replace('/'.preg_quote($s,'/').'/','\\$0',$var))."\n";
    }
    elseif($cmd == 'list') {					// Text-Ausgabe
     $out = implode('|',array_keys(reset($list)))."\n";
     foreach($list as $var)
      $out .= implode('|',preg_replace('/'.preg_quote('|','/').'/','\\$0',$var))."\n";
    }
    else							// RAW-Ausgabe
     $out = $list;
   }
  }
  else
   $out = errmsg("8:Keine Aktoren gefunden!",$fn);
 }
 return $out;
}
function init($ver,$x=0,$y=0,$rc=false) {		// Fritz!Box Tools Initialisieren (1:preinit, 2:Parameter, 3:fritz.box, 4:postinit, 5:AES/PHP-Plugins)
 global $cfg,$script,$self,$Self,$qt,$bug;
 if((float)phpversion() > 4.3 and is_string($ver)	// Init L1 (VOR dem Parsen der Parameter)
	and $ver = ifset($ver,'/^(\w+) ([\d.]+) \(c\) (?:GNU )?GPL (\d\d)\.(\d\d)\.(\d{4}) by ([\w ]+?) <(\w+:\/\/[\w.-]+)(.*?)>$/') and $rc = 1) {
  $cfg['time'] = $cfg['stim'] = ifset($_SERVER['REQUEST_TIME_FLOAT']) ? $_SERVER['REQUEST_TIME_FLOAT'] : array_sum(explode(' ',microtime()));	// Startzeit sichern
  define($ver[1],1);					// Feste Kennung für Plugins etc.
  $ver[] = intval($ver[5].$ver[4].$ver[3]);		// fb_tools Datum (9)
  $ver[] = floatval($ver[2]);				// fb_tools Version (10)
  $cfg['ver'] = $ver;					// FB_Tools Versionsstring
  $cfg['uplink'] = array(
	'host' => preg_replace('/^.*?(?=[\w.-]+$)/','',$ver[7]),
	'path' => "/Projekte/FritzBox-Tools;",
	'fbts' => $ver[1],
	'fbtp' => "fbt_plugins");
  $cfg['php'] = array(phpversion(),php_uname(),php_sapi_name(),(float)phpversion(),defined('PHP_INT_SIZE') ? PHP_INT_SIZE * 8 : 32);
  if(function_exists('php_ini_loaded_file') and $var = php_ini_loaded_file())	// PHP.ini Location speichern
   $cfg['php'][] = $var;
  $gz = (function_exists("gzopen") or function_exists("gzopen64")) ? true : false;	// ZLib Funktionen initialisieren
  foreach(explode(',','open,close,eof,file,gets,puts,read,write,seek,tell,encode,decode,deflate,inflate') as $key)
   $cfg['zlib'][$key] = $gz ? (function_exists("gz$key") ? "gz$key" : (function_exists("gz{$key}64") ? "gz{$key}64" : 'init'))
	: (function_exists($key) ? $key : (function_exists("f$key") ? "f$key" : 'init'));
  $cfg['ssl'] = defined('OPENSSL_VERSION_TEXT') ? OPENSSL_VERSION_TEXT : false;
  $cfg['osn'] =  ($var = ifset($cfg['ssl'],'/[\d.]+/')) ? (float)$var[0] : false;
  $cfg['ptar'] = '/\.(?:(tar)|(t(?:ar\.)?gz)|(t(?:ar\.)?bz(?:ip)?2?)|(zip))($)/i';	// Tar-Ausdruck (1: .tar | 2: t?GZip | 3: tBZip2 | 4: ZIP)
  $cfg['dbcd'] = realpath('.').'/';			// Current_Dir für Debug-Daten
  $cfg['desc'] = '/['.preg_quote(preg_replace('!/.*$!','',$cfg['fesc']),'/').']+/';
  $cfg['fesc'] = '/['.preg_quote($cfg['fesc'],'/').']+/';
  if(ifset($_SERVER['argc']) and !preg_match('/cli/',$cfg['php'][2]) and function_exists('header_remove')) {	// HTTP-Header löschen wenn PHP-CGI eingesetzt wird
   header('Content-type:');
   header_remove('Content-type');
   header_remove('X-Powered-By');
  }
  foreach(explode(',','aes,arg,opt,argc,argk,args,opts,auth,mods,fail') as $var)	// Leeres Array setzen
   $cfg[$var] = array();
  $var = $_SERVER['argv'][0];
  $self = basename($var);				// Exec-Script (Wie von der Konsole aufgerufen)
  $script = realpath(ifset($_SERVER['PHP_SELF'],'/^(Standard input code|-?)$/')
	? (($Self = getenv(1) and realpath(getenv(2)."/".getenv(0)) == realpath(getenv(1))) ? $Self : (realpath($var) ? $var:((realpath($var .= ".bat")) ? $var : false)))
	: (realpath($_SERVER['PHP_SELF']) ? $_SERVER['PHP_SELF'] : (realpath($_SERVER['SCRIPT_NAME']) ? $_SERVER['SCRIPT_NAME'] : $var)));
  $Self = basename($script);				// Script_Name
  $cfg['dir'] = preg_replace(array('/\\\\/','/\/$/'),array('/',''),dirname($script));
  $cfg['ext'] = strtolower(preg_replace('/\W+/','',pathinfo($script,PATHINFO_EXTENSION))); // Extension für Unix/Win32 unterscheidung
  $cfg['temp'] = function_exists('sys_get_temp_dir') ? sys_get_temp_dir() : (($var = getenv('TEMP')) ? $var : (is_dir("/tmp") ? "/tmp" : "."));
  $cfg['head'] = array('User-Agent' => "$Self $ver[2] {$cfg['php'][1]} PHP {$cfg['php'][0]}/{$cfg['php'][2]} ({$cfg['php'][4]} Bit) $cfg[ssl]"); // Fake UserAgent
  $cfg['cu'] = ($var = getenv('USER') or $var = getenv('USERNAME')) ? $var
	: ((is_callable('posix_geteuid') and is_callable('posix_getpwuid') and $var = posix_getpwuid(posix_geteuid())) ? $var['name']
	: false);
 }
 elseif(is_int($ver)) {
  if($ver == 2 and is_array($x) and $x and $rc = $ver) {// Init L2 (Parameter parsen)
   $y = $y ? $y : count($x);				// $argc
   for($a=1; $a < $y; $a++)
    if(preg_match("/^(?!$cfg[argn])(-{0,2})(\w+)(?:(?:\[(.)\])?([:=])([\"']?)(.*?)\\5)?($)/si",$x[$a],$var) and ($var[1] != "" or $var[6] != "")) {	// Benanntes Argument
     if($var[3] and preg_match_all('/(?:[^'.preg_quote($var[3],'/').'\\\\]+|\\\\'.preg_quote($var[3],'/').'?)+/',$var[6],$array))	// Ketten-Argumente (test[,]=foo,bar)
      $var[6] = $array[0];
     if($var[1]) {					// Optionen
      $val = 'opts';
      if($var[6] == '')
       $var[6] = true;
     }
     else						// Argumente
      $val = 'args';
     if(isset($cfg[$val][$var[2]]))			// Existiert schon?
      if(is_array($cfg[$val][$var[2]]))			// Ein Array?
       if(is_array($var[6]))
        $cfg[$val][$var[2]] = array_merge($cfg[$val][$var[2]],$var[6]);
       else
        $cfg[$val][$var[2]][] = $var[6];		// Array erweitern
      else
       $cfg[$val][$var[2]] = is_array($var[6]) ? array_merge(array($cfg[$val][$var[2]]),$var[6]) : array($cfg[$val][$var[2]],$var[6]);	// In Array umwandeln
     else
      $cfg[$val][$var[2]] = $var[6];			// Normal speichern
    }
    elseif($var and !$var[1] and $var[2] and $var[4] and !$var[6])	// Leeres Argument
     if(!isset($cfg['args'][$var[2]]))
      $cfg['args'][$var[2]] = $var[6];			// Normal speichern
     elseif(is_array($cfg['args'][$var[2]]))
      $cfg['args'][$var[2]][] = $var[6];		// In ein Array dranhängen
     else
      $cfg['args'][$var[2]] = array($cfg['args'][$var[2]],$var[6]);	// Ein neues Array erstellen und dranhängen
    elseif(isset($x[$a][0]) and $x[$a][0] != '-')	// Nummeriertes Argument
     $cfg['arg'][$a] = $x[$a];
   $cfg['argc'] = array_keys($cfg['arg']);
   if($cfg['args'])
    $cfg['arg'] += $cfg['args'];			// Alle Argumente zusammenführen
   else
    $cfg['argn'] = false;				// Alten Parametermodus aktivieren
  }
  elseif($ver == 3 and $x				// Init L3 (Fritz!Box-Anmeldedaten aus einem Parameter extrahieren)
	and @preg_match('/^(?!-) (?:(?P<us>https?):\/\/)? (?:(["\']?)(?P<un>.+)\2:)? (?:(["\']?)(?P<pw>.+)\4@)? (?P<fb>'
	.strtr(preg_quote(implode("\t",array_keys($cfg['preset'])),'/'),"\t",'|').'|(?:[\w-]+\.)+[\w-]+|(?<=@)[\w.-]+|\[[a-f\d:]+\]|[\w-]+::(["\']?)(?P<cf>.+)\7)'
	.' (?::(?P<pt>\d{1,5}))? (?:\#(["\']?)(?P<ui>.+)\g{10})? ($)/ix',$x,$m) and $rc = $ver) {	// Fritz!Box Anmeldedaten
   $bug and dbug($m,3);
   $cfg['fbhp'] = isset($cfg['opts']['fb']) ? "-fb:$qt$m[0]$qt" : $m[0];
   if(ifset($m['cf']) and file_exists($m['cf'])) {// Kurzschreibweise: [name]::'[/path/fb_config.php]'
    $bug and dbug("Lade Konfig-Datei: $m[cf]");
    $cfg['loadcfg'] = ifset($cfg['loadcfg']) ? "$cfg[loadcfg]|$m[cf]" : $m['cf'];
    if(ifset($m['cf'],'/\.php$/i'))
     include_once $m['cf'];	// PHP ausführen
    elseif(ifset($m['cf'],'/\.json$/i'))
     if($var = json2array(file_contents($m['cf'])))
      $cfg = init(6,$cfg,$var);
     else
      errmsg("16:".errmsg(0,'json2array'),'init');
    $m['fb'] = preg_replace('/:.*$/','',$m['fb']);// Die Konfig-Datei abschneiden
   }
   $cfg['host'] = $m['fb'];	// fb:Host
   if(isset($cfg['preset'][$m['fb']])) {	// Voreingestellte Fritz!Boxen Erkennen und Eintragen
    $bug and dbug("Übernehme Preset: $m[fb]");
    if(is_string($cfg['preset'][$m['fb']]) and $key = request($cfg['preset'][$m['fb']].'#'))
     $cfg['preset'][$m['fb']] = $key;
    if(is_array($cfg['preset'][$m['fb']]))
     $cfg = init(6,$cfg,$cfg['preset'][$m['fb']]);
   }
   if($m['us']) {		// us: Protokoll
    $cfg['sock'] = $m['us'];
    if($m['us'] == 'https')
     $cfg['port'] = 443;
   }
   if($m['un'])			// un:Username
    $cfg['user'] = $m['un'];
   if($m['pw'])			// pw:Password
    $cfg['pass'] = $m['pw'];
   if($m['pt'])			// pt:Port
    $cfg['port'] = $m['pt'];
   if($m['ui'])			// ui:Password2
    $cfg['uipw'] = $m['ui'];
  }
  elseif($ver == 4 and $rc = $ver) {			// Init L4 (OS Erkennung, Konfig-Datei)
   $cfg['HOME'] = ($var = getenv('HOME') or $var = getenv('USERPROFILE')) ? $var : ".";	// Home-Verzeichnis
   $qt = "'";
   if(($cfg['os'] = strtolower(PHP_OS)) == 'winnt') {	// Sonderarten von Windows erkennen
    $cfg['os'] .= (count(preg_array('/^(HOME|SYSTEM(DRIVE|ROOT)|APPDATA|WINDIR)$/',$_SERVER,3)) == 5) ? '-busybox'
 	: ((count(preg_array('/^(SystemDrive|SYSTEMROOT|APPDATA|windir|WINE(LOADER|SERVER)?)$/',$_SERVER,3)) == 7) ? '-wine' : '');
    $qt = '"';
    if($var = getenv('APPDATA'))						// Das Home-Verzeichnis aus der ENV-Variable setzen
     $cfg['home'] = $var;
   }
   elseif(file_exists($var = "$cfg[HOME]/.config") and is_dir($var))		// Das Home-Verzeichnis zu dem .config-Verzeichnis setzen
    $cfg['home'] = $var;
   else
    $cfg['home'] = $cfg['HOME'];
   foreach(array('l' => $cfg['libs'], 'a' => $cfg['fbtp']) as $key => $var)	// Verzeichnisliste für Libs/Plugins vorab berechnen in $cfg[fbtl/fbta]
    if(!isset($cfg["fbt$key"]))
     $cfg["fbt$key"] = array(".","$cfg[dir]",$var,strtoupper($var),ucwords($var),"$cfg[dir]/$var","$cfg[dir]/".strtoupper($var),"$cfg[dir]/".ucwords($var));
   if(ifset($cfg['usrcfg']) and ifset($cfg['usrfmt'])				// Benutzer-Konfig laden
	and $array = glob_brace("{".implode(',',str_replace(',','\,',array('.',$cfg['home'],$cfg['dir'],$cfg['HOME'])))."}/{.,}$cfg[usrcfg].{".implode(',',$cfg['usrfmt'])."}"))
    while($file = array_shift($array))
     if(file_exists($file) and $file = realpath($file)) {
      $bug and dbug("Lade Benutzer-Konfig: $file");
      if(ifset($file,'/\.php$/i'))
       include_once $file;							// Benutzer-Konfig ausführen
      elseif(ifset($file,'/\.json$/i'))
       if($var = json2array(file_contents($file)))
        $cfg = init(6,$cfg,$var);
       else
        errmsg("16:".errmsg(0,'json2array'),'init');
      $cfg['loadcfg'] = ifset($cfg['loadcfg']) ? "$cfg[loadcfg]|$file" : $file;
      if(!$cfg['cfgall'] or is_int($cfg['cfgall']) and !--$cfg['cfgall'])
       break;
     }
   foreach(array('preset','plugin') as $var)					// Sicherstellen dass preset/plugin ein Array ist
    if(!isset($cfg[$var]) or !is_array($cfg[$var]))
     $cfg[$var] = array();
   if(!isset($cfg['bzip'])) {							// BZip2 Funktionen initialisieren
    $cfg['bzip'] = (function_exists("bzopen") or function_exists("bzopen64")) ? true : init(5,'bzip2');
    $cfg['bz'] = 0;
   }
  }
  elseif($ver == 5) {					// Init	L5 (AES or PHP-Plugins)
   if(!ifset($cfg['php'][5])) {
    ob_start();
    phpinfo();
    if(preg_match('/^Configuration File.*?=>\s*(.*)$/m',ob_get_contents(),$array))
     $cfg['php'][5] = $array[1];
    ob_end_clean();
   }
   $ext = array();
   foreach(json2array('{
	openssl:{ext:1, min:5.4,	func:openssl_decrypt,	preg:/\b(php_)?openssl\.(so|dll)/i},
	mcrypt:	{ext:1,			func:mcrypt_decrypt,	preg:/\b(php_)?mcrypt\.(so|dll)/i},
	mhash:	{ext:1,		max:5.1,func:mhash,		preg:/\b(php_)?mhash\.(so|dll)/i},
	zlib:	{ext:1,			func:gzread,		preg:/\b(php_)?zlib\.(so|dll)/i},
	bzip2:	{ext:1,			func:bzread,		preg:/\b(php_)?bz2\.(so|dll)/i},
	mysqli:	{ext:1, min:5.0,	obj: mysqli,		preg:/\b(php_)?mysqli\.(so|dll)/i},
	sqlite3:{ext:1, min:5.3,	obj: SQLite3,		preg:/\b(php_)?sqlite3\.(so|dll)/i},
	aes5:	{php:1, min:5.3,max:8.11,obj:"PhpAes\\Aes",	preg:/\baes\.php/i},
	aes4:	{php:1,		max:7.1,obj: Aes,		preg:/\baes_?4.*?\.php/i},
	sha256:	{php:1,		max:5.2,func:sha256,		preg:/\bsha.?256\.php/i},
	sha512:	{php:1,		max:5.2,func:sha512,		preg:/\bsha.?512\.php/i},
	hashtool:{php:1,	max:5.6,func:hash_pbkdf2,	preg:/\bhashtool\.php/i}}') as $key => $var)
    if(!isset($ext[$key]) and (!$x or $x == 'aes' or strstr($x,$key))
	and ($x and $x != 'aes' and strstr($x,$key) or (!isset($var['min']) or $cfg['php'][3] >= $var['min']) and (!isset($var['max']) or $cfg['php'][3] < $var['max']))
	and ((isset($var['ext']) and ((isset($var['func']) and $val = function_exists($var['func']) or isset($var['obj']) and $val = class_exists($var['obj']))
	or @ini_get('enable_dl') and (defined('PHP_BINARY') and $val = listDir($var['preg'],dirname(PHP_BINARY),1)
	or $cfg['php'][5] and $val = listDir($var['preg'],dirname($cfg['php'][5]),1) or $val = listDir($var['preg'],realpath(@ini_get('extension_dir')),1))))
	or (isset($var['php']) and ((isset($var['func']) and $val = function_exists($var['func']) or isset($var['obj']) and $val = class_exists($var['obj']))
	or $val = listDir($var['preg'],$cfg['fbtl'],1)))) and (is_bool($val) or $val = ifset($val,$var['preg']))) {
     if(is_array($val)) {
      $val = array_values($val);
      if(isset($var['ext'])) {
       if(realpath(@ini_get('extension_dir')) != dirname($val[0]))
        @ini_set('extension_dir',dirname($val[0]));
       @dl(basename($val[0]));
      }
      if(isset($var['php']))
       include_once $val[0];
     }
     if(isset($var['func']) and function_exists($var['func']) or isset($var['obj']) and class_exists($var['obj'])) {	// Erweiterung einrichten
      $ext[$key] = is_array($val) ? ((count($val) > 1) ? $val : $val[0]) : $val;
      $bug and dbug($key." nachgeladen",9);
     }
    }
   if($x == 'openssl' and $ext['openssl'] = defined('OPENSSL_VERSION_TEXT') ? OPENSSL_VERSION_TEXT : (defined('OPENSSL_NO_PADDING') ? "OpenSSL 0.9x" : false)) {
    if(substr($cfg['head']['User-Agent'],-1) == ' ')
     $cfg['head']['User-Agent'] .= $ext['openssl'];
    $cfg['osn'] = ($var = ifset($ext['openssl'],'/[\d.]+/')) ? (float)$var[0] : false;
   }
   if(isset($cfg['aes']))
    $cfg['aes'] = array_merge($cfg['aes'],$ext);
   foreach($ext as $key => $var)
    if(!isset($cfg['mods'][$key]))
     $cfg['mods'][$key] = $var;
   $rc = ($x == 'aes') ? preg_array('/aes\d+|openssl|mcrypt/',$ext,3) : ((count($ext) == 1 and isset($ext[$x])) ? $ext[$x] : $ext);
  }
  elseif($ver == 6 and is_array($x) and is_array($y)) {	// Init L6 (joinArray[$x <= $y])
   foreach($y as $k => $v)
   if(isset($x[$k])) {
    if(is_array($v) and is_array($x[$k]))
     $x[$k] = call_user_func(__FUNCTION__,$ver,$x[$k],$y[$k]);
    elseif($x[$k] != $v)
     $x[$k] = $v;
   }
   else
    $x[$k] = $v;
   $rc = $x;
  }
  elseif($ver == 7) {					// init L7 (cleanup)
   foreach($cfg['preset'] as $key => $var)						// Preset-Daten werden nicht mehr benötigt!
    $cfg['preset'][$key] = false;
   if(!isset($cfg['pscm']) or !is_array($cfg['pscm']))					// Preset für den Cron-Modus
    $cfg['pscm'] = array('upda' => 0, 'uport' => 443);
   if($cfg['usrsys'] and ifset($cfg['cu'],$cfg['usrsys']))				// Automatischer Cron-Modus
    $cfg['cron'] = $cfg['cu'];
   if(ifset($cfg['cron']) and ifset($cfg['pscm']))					// Verschiedene Funktionen einfach für Cron-Dienste abschalten
    $cfg = init(6,$cfg,$cfg['pscm']);
   if($cfg['uplink'] and is_array($cfg['uplink']) and !isset($cfg['uplink']['port']))	// Port(s) für Updates festlegen
    if($array = ifset($cfg['uplink']['host'],'/[:,](\d+)/a')) {				// Einen Speziellen Port benutzen?
     $cfg['uplink']['port'] = $array[1];
     $cfg['uplink']['host'] = preg_replace('/:.*$/','',$cfg['uplink']['host']);
    }
    else
     $cfg['uplink']['port'] = is_array($cfg['uport']) ? $cfg['uport'] : array($cfg['uport']);
   if(!$cfg['cu'])									// Letzter Versuch Current-User zu ermitteln
    $cfg['cu'] = (!$cfg['cron'] and ($var = getenv('windir') and file_exists("$var/system32/whoami.exe")
	or file_exists("/bin/whoami") or file_exists("/usr/bin/whoami")) and $var = @exec('whoami')) ? basename($var) : get_current_user();
   if(!ifset($cfg['head']['User-Agent'],'/\b'.preg_quote($cfg['ver'][1]).'(_\w+)?\b/i'))// Kein Zugriff auf mengelke, wenn fb_Tools nicht im User-Agent steht
    $cfg['upda'] = $cfg['uplink'] = 0;

   if(@ini_get('pcre.backtrack_limit') < $cfg['pcre'])	// Für Große RegEx-Ergebnisse
    @ini_set('pcre.backtrack_limit',$cfg['pcre']);
   if(@ini_get('memory_limit') < $cfg['meli'])		// Speicher-Buffer
    @ini_set('memory_limit',$cfg['meli']);
   if($cfg['zone'])					// Zeitzone festlegen
    @ini_set('date.timezone',$cfg['zone']);
   if($cfg['slct'])					// Zeitformat festlegen
    @setlocale(LC_TIME,$cfg['slct']);
   $cfg['a1st'] = (date('nj') == 41 and $x = $cfg['zlib']['inflate'](base64_decode(	/* Test-Funktion */"
	XZBBT8JAEIXv/IrxtpsICdFTNTRFIwejaZDogXBYu9N2adnW2SkiIf3ZnnpwC3LQ45s3+d68GczRIcfKuc+K9GF4eEHeM9iGQCsHkd1gqbFAa73PoJoU3pAK
	h8Y6xrJsbIYW9g11SSHGcrAwSYE8Q4ukuCIPnCJhkltkyLqSTYZw2nGQdj7EIDwaq5GcSXIkzxNXl9eyPYgwvqV6Mhf9gTKMxe+NMpRHj7PJQhxJMpyJc6B3
	22VKhvej92q3guWm0hj8LVlrP6+9Cu4xVU3JcLZW7Wn/fwvOepJKVPDQoy+m1Q6eorthpAmdw1X7Wjew7lRa+79R7gVtFSlY5+qD0E+/ezUewXOC2y+4Gcof"))) ? explode("~",$x) : false;
  }
 }
 return $rc;
}

# Eigentlicher Programmstart
if(isset($argc) and isset($argv) and init($ver)) {	## CLI-Modus ##
 $opts = "";				// Kontext-Optionen
 init(2,$argv,$argc);			// Parameter sehr früh parsen
 foreach($cfg['opts'] as $key => $var) {// Optionen auswerten und setzen
  $var = is_array($var) ? $var[0] : $var;	// Bei mehreren Argumenten, nur das erste benutzen - entspreche getArg("-$key")
  if($key == 'h' or $key == "help")	// help
   $cfg['help'] = $var;
  elseif($key == 'd') {// Debug
   $bug = $cfg['dbug'] = ($val = ifset($var,'/^(\d+)(?:.(.+))?($)/')) ? intval($val[1]) : true;
   if($val and $val[2] and (file_exists($val[2]) and is_dir($val[2]) or !file_exists($val[2]) and $val[2] = makedir($val[2],0)))
    $cfg['dbcd'] = realpath($val[2]).'/';	// CD Setzen
  }
  elseif($key == 'w')	// Wrap
   $cfg['wrap'] = ifset($var,'is_numeric') ? intval($var) : 80;
  elseif($key == 'c')	// Char
   $cfg['char'] = strtolower($var);
  elseif($key == 't')	// Timeout
   $cfg['tout'] = ifset($var,'is_numeric') ? intval($var) : 0;
  elseif($key == 'b')	// Buffer
   $cfg['sbuf'] = ifset($var,'/^[1-9]\d{2,}$/') ? intval($var) : 4096;
  elseif($key == 'p')	// Protokoll
   $cfg['sock'] = ($v = ifset($var,'/^(auto|https?|ssl|tls)$/i')) ? strtolower($v[0]) : 'auto';
  elseif($key == 's') {// SID
   if($val = ifset($var,'/^[\da-f]{16}$/i0'))			// SID direkt übernehmen
    $cfg['sid'] = $val;
   elseif(file_exists($var) and preg_match('/^\s*([\da-fA-F]{16}|(a:\d+:)?(\{.*\}))\s*($)/s',file_contents($var),$val)) {
    if($val[3])
     $cfg = array_replace($cfg,$val[2] ? unserialize($val[1]) : json2array($val[3]));	// Sämtliche Variabeln aus der Datei in $cfg übernehmen/überschreiben
    else
     $cfg['sid'] = $val[1];					// NUR die SID übernehmen
   }
   else
    errmsg("2:Ungültige SID übergeben");
   if(ifset($cfg['sid']) and $sid = login(0,0,0,$cfg['sid'])) {// Sid bestätigen lassen
    $cfg['bsid'] = $cfg['sid'] = $sid;				// Festlegen, dass die Funktionen die Firmware-Abfragen und das Logout überspringen sollen
    $bug and dbug("Recycle Login-SID: $sid von $cfg[host]");
   }
   else
    errmsg("20:SID ist ungültig");
  }
  elseif($key == 'u' and $val = ifset($var,'/\b(?:[1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])\b/a'))	// UPnP-Port
   foreach($val[0] as $key => $var)
    $cfg['upnp'][$key] = intval($var);
  elseif($key == 'gz') {					// GZip Crunchlevel
   $cfg['zlib']['mode'] = ($v = ifset($var,'/^-?(\d)[fhR]?$/')) ? $v[0] : -1;
   $cfg['gz'] = $v ? $v[1] : 0;
  }
  elseif($key == 'zb')						// ZIP-AES Bits
   $cfg['zb'] = intval(ifset($var,'/^(128|192|256)$/0')) or $cfg['zb'] = 256;
  elseif($key == 'zp') {					// ZIP Kennwort
   if(!is_array($var = $cfg['opts'][$key]))			// Sicherstellen dass die ZIP-Kennwörter ein Array sind
    $var = array($var);
   $cfg['zp'] = $var;
   if(!ifset($cfg['zb']))					// Gleich noch die Bits prüfen oder festlegen
    $cfg['zb'] = 256;
  }
  elseif($key == 'bz')						// BZip2 Crunchlevel
   $cfg['bz'] = ifset($var,'/^\d$/0');
  elseif($key == 'pe' and $var)					// PHP-Extension nachladen
   @dl($var);
  elseif($key == 'fw' and $v = ifset($var,'/^(\d+\.0)?([1-9])\.?(\d{2})(-\d+)?$/'))	// Fritz!Box Firmware-Version
   $cfg['fiwa'] = (int)($v[2].$v[3]);
  elseif($key == 'li' and $v = ifset($var,'/^[102]$/'))		// Login-Version verwenden
   $cfg['livs'] = (int)$v[0];
  elseif($key == 'px' and ifset($var,'/^[\w.-]+:\d+$/'))	// Proxy & Port
   $cfg['proxy'] = $var;
  elseif($key == 'pp' and is_dir($var))				// Plugin-Path setzen
   $cfg['fbta'] = array(realpath($var));
  elseif($key == 'nc')						// Keine Cookies Anzeigen
   $cfg['coki'] = intval(ifset($var,'/^[0-1]$/0'));
  elseif($key == 'nu')						// Kein Update-Check
   $cfg['upda'] = is_bool($var) ? -1 : intval($var);
  elseif($key == 'ot')						// Strftime auf Original setzen
   $strftime = 'strftime';
  elseif($key == 'oj')
   $cfg['json'] = ifset($var,'/^[0-2]$/') ? intval($var) : 1;	// json_decode auf Original setzen
  elseif($key == 'ts' and ifset($var,'/^[\w\s.:\/+-]+$/'))	// Aktuelle Uhrzeit setzen
   $cfg['time'] = strtotime($var);
  elseif($key == 'uc')						// User-Config
   $cfg['usrcfg'] = is_bool($var) ? false : $var;
  elseif($key == 'cc') {					// Include BenutzerKonfig
   $bug and dbug("Lade Benutzer-Konfig: $var");
   if(ifset($var,'/\.php$/i') and file_exists($var))
    include_once $var;						// PHP ausführen
   elseif($m = ifset($var,'/^(?:(.*\.json)|\s*(\{.*\})\s*)($)/si'))
    if($m[1] and file_exists($var) and $array = json2array(file_contents($var))
	or $m[2] and $array = json2array($var) and $var = '{json:"direkt"}')
     $cfg = init(6,$cfg,$array);
    else {
     $var = false;
     errmsg(0,'json2array');
    }
   if($var)
    $cfg['loadcfg'] = ifset($cfg['loadcfg']) ? "$cfg[loadcfg]|$var" : $var;
  }
  elseif($key == 'ua' and $v = ifset($var,'/^[[:print:]]+$/')) {// UserAgent setzen
   $cfg['head']['User-Agent'] = $v[0];
   $cfg['head']['VIA'] = implode(" ",array_slice($cfg['ver'],1,2));// fb_Tools in dem Header setzen
   $cfg['upda'] = $cfg['uplink'] = false;			// Updates abschalten
  }
  elseif($key == 'cm') {					// Cron-Modus: Einige Funktionen deaktivieren
   if(!$cfg['cron'] = $var)
    $cfg['usrsys'] = $var;					// Automatischer Cron-Modus deaktivieren
  }
  elseif($key == 'ps' and isset($cfg['preset'][$var])) {
   $bug and dbug("Übernehme Preset: $var");
   if(is_string($cfg['preset'][$var]) and $key = request($cfg['preset'][$var].'#'))
    $cfg['preset'][$var] = $key;
   if(is_array($cfg['preset'][$var]))
    foreach($cfg['preset'][$var] as $k => $v)
     $cfg[$k] = $v;
  }
#  elseif($key == 'fb')			// Fritz!Box Host übernehmen
#   init(3,$var);			// In "Host" nach weiteren Fritz!Box-Daten im URL-Schema suchen
  else
   foreach(array('o' => 'oput', 'un' => 'user', 'pw' => 'pass', 'fb' => 'host', 'ui' => 'uipw', 'pt' => 'port', 'tf' => 'totp') as $k => $v)	// Optionen mit Zwangsparameter
    if($key == $k and $var)
     $cfg[$v] = $var;
 }
 if(($bug = $cfg['dbug']) & 1<<8)	// PHP-Fehler Protokollieren
  set_error_handler('phperr');
 else
  error_reporting(0);			// Fehler-Meldungen deaktivieren!
 init(4);				// Den Rest Initialiseren (Konfig-Datei)

# Drag'n'Drop Modus
 if(ifset($cfg['drag']) and $argc == 2 and file_exists($argv[1]) and is_file($argv[1])) {
  if(is_array($cfg['drag'])) {	// Ist es ein Array mit Dateitypen als Schlüssel?
   if(!preg_match('/\.([^.]+)(\.(gz|bz2?))?$/',$argv[1],$m) or !($drag = ifset($cfg['drag'][strtolower($m[1])],"")))
    $drag = isset($cfg['drag']['*']) ? $cfg['drag']['*'] : 'info hash *';
  }
  else					// Fallback zu String
   $drag = $cfg['drag'];
  $bug and dbug("Nutze Drag-Parameter: ".str_replace('*'," {$argv[1]} ",$drag));
  $drag = explode('*',$drag);
  array_splice($argv,$argc,0,explode(' ',trim($drag[1])));
  array_splice($argv,1,0,explode(' ',trim($drag[0])));
  $argc = count($argv);
  init(2,$argv,$argc);			// Parameter nocheinmal Parsen
 }

# Parameter "-fb" verwenden oder alternativ den Ersten Fritz!Box Parameter ermitteln und auswerten
 if($var = getArg('-fb'))													// Fritz!Box-Argument in den Optionen
  init(3,$var);
 elseif($argc > 1 and $n = ($cfg['fbnp'] < 0 ? $argc : 0) + $cfg['fbnp'] and $n < $argc and $n > 0 and init(3,$argv[$n])	// Mögliches Fritz!Box-Argument anwenden
	and (isset($cfg['arg'][$n]) and !$m = 0 or preg_match('/^(\w+):/',$argv[$n],$m) and isset($cfg['args'][$m[1]]))) {	// Gefundenes Fritz!Box-Argument entfernen
  if($m) {						// Benanntes Argument löschen
   unset($cfg['args'][$m[1]]);
   unset($cfg['arg'][$m[1]]);
  }
  else {						// Nummeriertes Argument löschen
   unset($cfg['arg'][$n]);
   if(($var = array_search($n,$cfg['argc'])) !== false)
    unset($cfg['argc'][$var]);
  }
 }
 init(7);				// Init CleanUp

# Consolen Breite automatisch ermitteln
 if(ifset($cfg['wrap'],'auto')) {
  $cfg['wrap'] = 0;			// Bei fehlgeschlag -> Wrap deaktiviert
  if($var = getenv('COLUMNS') or $var = getenv('COLS'))
   $cfg['wrap'] = intval($var);
  elseif(ifset($cfg['cron']));
  elseif(ifset($cfg['os'],'/darwin|linux/i'))	// Linux/Mac
   $cfg['wrap'] = (($var = (int)getenv('COLUMNS'))
	or file_exists('/bin/stty')	and $var = (int)preg_replace('/^\d+\D*/','',@exec('stty size'))
	or file_exists('/bin/tput')	and $var = (int)@exec('tput cols')
  ) ? $var : 0;
  elseif((ifset($cfg['os'],'/^winnt(?!-wine)/i') or file_exists(getenv('windir')."/system32/mode.com")) and (@exec('mode con',$var) or true)	// Windows
	and is_array($var) and preg_match_all('/(?:(zeilen|lines)|(spalten|columns)|(code\s?page)):\s*(\S+)/',strtolower(implode('',$var)),$val))
   foreach($val[4] as $key => $var) {
    if(ifset($val[2][$key]))			// Breite sichern
     $cfg['wrap'] = (int)$var;
    if(ifset($val[3][$key]))			// Codepage merken
     $char = "cp".(($var == 65001 and ifset(($cfg['php'][1]),'/Windows NT[\s\w_-]*(6\.[01])/i')) ? 850 : $var);
   }
 }

# Char ermitteln und festlegen
 if(ifset($cfg['char'],'auto')) {
  if(!ifset($cfg['cron']) and preg_match('/(13)[73]((\1)37)/',date('dnHi'),$var))
   $cfg['char'] = $var[2];
  elseif(ifset($char))
   $cfg['char'] = $char;
  elseif($var = ifset($_SERVER['LANG'],'/(UTF-?8)|((?:iso-)?8859-1)/i') and ($var[1] and !isset($cfg['utf8'])) or ifset($var[2]))	// Linux
   $cfg['char'] = $var[1] ? 'utf-8' : 'iso-8859-1';
  elseif(!ifset($cfg['cron']) and getenv('HOME') and getenv('USER') and getenv('TERM') and getenv('SHELL')	// Unix/Linux/Mac
	and file_exists('/usr/bin/locale') and preg_match('/(utf-?8)|(ansi|iso-?8859-?1|ascii)/i',@exec('locale charmap'),$var))
   $cfg['char'] = (ifset($var[1]) and !isset($cfg['utf8'])) ? 'utf8' : (ifset($var[2]) ? strtolower(str_replace('-','_',$var[2])) : 'utf7');
  elseif(getenv('SystemDrive') and getenv('SystemRoot') and getenv('APPDATA'))		// Windows
   $cfg['char'] = '65000';
  else
   $cfg['char'] = '7bit';	// Fallback zu 7 Bit ASCII
 }
 $cfg['char'] = ($var = '(?:c(?:odepage|p))?'
	and $val = ifset($cfg['char'],"/^(?:(?P<d>$var(437|85[08])|dos|oem)|(?P<a>$var(1252|851|28591)|iso.?8859.?1|ansi)|(?P<m>$var(?:1250|852|28952)|iso.?8859.?2)"
	."|(?P<c>{$var}65000|7bit|asc(ii)?|utf-?7|auto)|(?P<u>{$var}65001|utf-?8)|(?P<h>x?html?)|(?P<l>[1l][E3³]{2}[t\+7])|(?P<r>rot13)|(?P<n>none))$/i"))
	? $val : array(0 => "char ($cfg[char])", 'c' => 1);
 $bug and dbug(array('char' => $cfg['char']),4);

# Auto-Update (Check)
 if($cfg['upda'] and ifset($cfg['uplink'],5)) {		// Ein Updatecheck durchführbar?
  $file = "$cfg[dir]/.touch-$cfg[cu]";	// Alternative Datei zum beschreiben
  if($cfg['upda'] < 0)			// Update-Prüfung verhindern und Touch-Datei aktualisieren
   mytouch(1);
  elseif($fbnet = mytouch(0))		// Prüfung auf Touchdatei
   if(is_array($fbnet) and ifset($fbnet['ver']) and $fbnet['ver'] > $cfg['ver'][10])
    out(errmsg("1:Ein Update ist bereits verfügbar ($fbnet[name] $fbnet[ver]) - Bitte nutzen Sie die Update-Funktion!\n\nBeispiel:\n$self info update\n\n"));
   elseif(!mytouch(is_array($fbnet) ? $fbnet : 1))	// Touch-Datei aktualisieren
    errmsg("32:Keine Schreibberechtigung im Programmverzeichnis!\nBitte ändern Sie das oder deaktivieren Sie die Auto-Update Funktion in der fb_config.json oder nutzen Sie die Option -nu!");
   elseif(is_bool($fbnet) or is_array($fbnet) and ifset($fbnet['chk'])) {
    $bug and dbug("Prüfe auf Updates...");
    foreach($cfg['uplink']['port'] as $var)
     if($fbnet = request('GET-array',$cfg['uplink']['path'].$cfg['uplink']['fbts'].".md5",0,0,$cfg['uplink']['host'],$var)) {
      if($var = ifset($fbnet['Location'],'/^(https?:)(\/\/.+)$/'))
       $fbnet = request("$var[1][array]$var[2]");
      break;
     }
    if($fbnet and ifset($fbnet['Content-MD5'],"/^(".preg_quote(base64_encode($var = hash('md5',$fbnet[1],true)),'/')."|".bin2hex($var).")$/")
	and preg_match("/^#\s*(\w+)\s([\d\s.:]+)\((\w+)\s([\d.]+)\)/",$fbnet[1],$var)) {
     if(floatval($var[4]) > $cfg['ver'][10]) {
      out(errmsg("1:Ein Update ist verfügbar ($var[3] $var[4]) - Bitte nutzen Sie die Update-Funktion!\n\nBeispiel:\n$self info update\n\n"));
      if($var[1] == 'Emergency_Update' or $var[1] == 'Emergency_Exit' and errmsg("254:$var[1]"))
       $cfg['args'] = array('mode' => 'info', 'func' => 'update');
     }
     if($cfg['coki'] and ifset($fbnet['X-Cookie']))
      $bug and dbug($fbnet['X-Cookie']);
    }
    else
     $bug and dbug(errmsg("1:Fehlerhafte Update-Liste erhalten!"));	// Eigentlich ein Fehler
   }
 }

# Bei Fehlern jetzt abbrechen
 if($var = errmsg())
  out($var);
# Parameter auswerten
 elseif($val = getArg('mode','/^
	((?P<bi>BoxInfo|bi)	|(?P<pi>PlugIns?|pi)	|(?P<pe>(Plugin)?Exec|pi?e)	|(?P<gip>G(et)?IP)	|(?P<lio>Log(in(-?test)?|out)|l(o|it?))
	|(?P<rc>ReConnect|rc)	|(?P<sd>SupportDaten|sd)|(?P<ss>(System)?S(tatu)?s)	|(?P<k>K(onfig)?)	|(?P<i>I(nfo)?|UpGrade|ug|otp(auth)?)
	|(?P<e>E(reignis(se)?)?)|(?P<led>led)		|(?P<al>AnrufList(en?)?|al)	|(?P<sh>SmartHome|sh)	|(?P<wh>Dial|d|WahlHilfe|wh)
	|(?P<kf>KF|Komfort)	|(?P<t>T(raffic)?)	|(?P<ut>ut|UpTime)'.($cfg['a1st'] ? $cfg['a1st'][1] : "").'|(?P<pit>[\w-]+))($)/ix')) {
  $bug and dbug(array('mode' => $val) + preg_array('/^(arg.?|opts)$/',$cfg,3),3);
  if(!$val['pi'] and !$val['pit'])			// Plugin Voreinstellungen löschen, wenn KEINE Plugins geladen werden
   unset($cfg['plugin']);
  if($val['i']) {					// Info (Intern)
   if($cfg['help']) {
    $var = ifset($cfg['uplink']) ? array("\nUpDate <opt:Check>|-|FB_Tools über das Internet aktualisieren","\n$self info update") : array ("","");
    out("$self [mode:Info|i] <func|Datei> <Parameter>\n
Funktionen (func):\n{{{tt}
AES|-|Verfügbarkeit der AES-Entschlüsselung ausgeben
Arg <arg> <preg>|-|Geparste Argumente ausgeben
Cat [file]|-|Dateiinhalt mit Terminal-Charset ausgeben
CSV [file]|-|CSV-Datei als Tabelle ausgeben
Dir <dir>|-|Verzeichnis auflisten
Echo <str>|-|Parameter ausgeben
ErrorCode [code]|-|Einen Manuellen Fehler-Code erzeugen
ExTension|-|Verfügbarkeit der PHP-Erweiterungen anzeigen
eXtrakt [file] <dir>|-|Dateien aus Archiv auflisten oder entpacken
Globals <file>|-|PHP-Variabeln ausgeben oder im JSON-Format speichern
Hash <file\|str>|-|Hashes von einer Datei oder einem String erstellen
JSON [file\|str] <opt>|-|JSON-Datei oder String geparst ausgeben
OpenSsl|-|Verfügbarkeit der OpenSSL-Bibliotek ausgeben
OTPauth <secret\|file>|-|TOTP Token-Generator (Google Authenticator)
PanGramm|-|Kodierungstest mit Umlauten und ASCII-Art
PHP <file>|-|PHPInfo() ausgeben oder in eine Datei speichern
PhpIni <find:Suchname>|-|Werte aus der PHP.ini ausgeben
StrfTime <str> <time>|-|Alle Zeit-Angaben von strftime ausgeben
Time <time> <-ft>|-|Datum und Uhrzeit ausgeben$var[0]
WebGet [url] <file\|:>|-|Datei herunterladen und HTTP-Header ausgeben}}".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self info
$self info cat fb_config.php
$self info csv Anrufliste.csv -cs:$qt;$qt
$self info dir
$self info echo {$qt}Hello World!$qt
$self info fb_config.php$var[1]
$self info hash file:$qt$script$qt
$self info json file:./assets/meta.json opt:0
$self info otp secret:{$qt}ABCD EFGH IJKL MNOP QRST UVWX YZ23 4567$qt
$self info wg http://http.mengelke.de : -ua:Wget/1.10
$self info strftime $qt%d.%m.%y %H:%M:%S$qt @1234567890
$self i pg -c:ansi
$self i x -zp:password FRITZBox-assets.zip ./dir/" : ""));
    if(!$cfg['help'] or $cfg['help'] === true)
     $cfg['help'] = -1;
    if(ifset($cfg['uplink']))
     $opts .= "CSV:|-cs:|[Char]|CSV-Separator festlegen (;)".(ifset($dev,'/^https?:/i') ? "
Dev:|-ip:|<File>|Entwickler-Version Lokal installieren" : "")."
Extrakt:|-pa:|[TAR\|ZIP]|Archiv-Type festlegen
|-zp:|[Password]|ZIP-Kennwort festlegen
OTPauth:|-ft:|[strftime]|Eigenes Datumsformat ($cfg[fstr])
|-rp:|[count]|Anzahl der Token, die ausgegeben werden sollen
|-tf:|[Secret]|Secret für TOTP-Token
|-ts:|[time]|Zeit für die TOTP-Token
StrfTime:|-tc:|[1-10]|Gewünschte Tabellenspalten
Update:|-f||Fehler Ignorieren
|-rd:|[dir]|RAW-Daten speichern
";
   }
   elseif($arg = getArg('func','/^(?:	(?P<php>PHP)		|(?P<pi>pi|phpini)	|(?P<g>G(?:LOBALS)?)	|(?P<pg>P(?:anGramm|g))
	|(?P<c>c|Cat)	|(?P<e>e|Echo)	|(?P<wg>wg|W(eb)?Get)	|(?P<st>st|StrfTime)	|(?P<h>h(ash(er)?)?)	|(?P<os>os|OpenSSL)
	|(?P<d>d|Dir)	|(?P<a>a|Arg)	|(?P<ts>ts|Test)	|(?P<et>et|ExTension)	|(?P<ud>U(?:pdate|d))	|(?P<otp>otp(auth)?)
	|(?P<aes>aes)	|(?P<cs>csv)	|(?P<js>json)		|(?P<x>x|eXtra[ck]t)	|(?P<ec>ec|ErrorCode)	|(?P<t>t|Time))($)/ix')
	or ifset($val['i'],'/upgrade|ug|otp(auth)?/i'))
    if($arg['pg'] and $var = "Welch fieser Katzentyp quält da süße Vögel bloß zum Jux?")	// Pangramm mit Kitty
     out(($vas = $cfg['zlib']['inflate'](base64_decode("VMqxCcQwEETR3OAefjYS7MjJZQJXIrxbiLnaD4X34sefd8GWEWE7Is/j23TDXZ3tihpWCcADpufci4sOjQXwxsfQ6Y4cYy4alKzzEA/AQ4FsSy0vW1DWys5v3pklJZUA")))
	? wordwrap("$var\n",min(($cfg['wrap'] ? (int)$cfg['wrap'] : 80),42)).$vas : $var);
    elseif($arg['c'] and $file = getArg('file','file_exists'))	// Cat
     out(preg_replace('/^\xef\xbb\xbf/','',file_contents($file)));
    elseif($arg['js'] and ($file = getArg('file','file_exists') and $data = file_contents($file)
	or $data = getArg('str','/^\s*(\{.*\}|\[.*\]|".*"|\'.*\'|true|false|null)\s*$/si0')))	// JSON
     out(($data = json2array($data,intval(getArg('opt','/^[0-2]$/0',2)))) ? $data : errmsg(0,'json2array'));
    elseif($arg['os'])					// OpenSSL
     out(($var = init(5,'openssl')) ? $var : errmsg("8:Nicht vorhanden - Kein SSL/HTTPS möglich!"));
    elseif($arg['aes'])					// AES
     out(($var = init(5,'aes')) ? ($val = count($var))." Bibliothek".(($val > 1) ? "en" : "")." zur Entschlüsselung vorhanden" : errmsg("8:Nicht vorhanden - Keine Entschlüsselung möglich!"));
    elseif($arg['d'])					// Dir
     out(implode("\n",(array)listDir(getArg('dir'),false,(int)getArg('opt'))));
    elseif($arg['ec'] and $var = getArg('code','is_numeric') & 255)// ErrorCode
     errmsg("$var:Custom-Error Code");
    elseif($arg['ts'])					// Test{}
     out(($str = getArg('str')) ? ifset($str,is_callable($var = getArg('test')) ? "" : $var) : ";-)");
    elseif($arg['t'])					// Time
     out("".$strftime(getArg('-ft',"","%-a, %d %h %Y %X %z"),$time = ($var = getArg('time') and $var = strtotime($var)) ? $var : microtime(true)));
    elseif($arg['a']) {					// Args
     $array = array('system (argv)' => $argv, 'arguments (arg)' => $cfg['arg'], 'available keys (argc)' => $cfg['argc'], 'labeled (args)' => $cfg['args'], 'options (opts)' => $cfg['opts']);
     if($cfg['dbug'])
      $array['consign'] = $cfg['argk'];
     $var = getArg('arg','/^(?:(arg[cksv]?|'.implode('|',array_keys($array)).')|\w+)($)/i');
     out(($var and isset($cfg['arg'][$var[0]])) ? getArg($var[0],is_callable($preg = getArg('preg')) ? "" : $preg) : (($var and isset($cfg[$var[1]])) ? $cfg[$var[1]] : (($var and isset($array[$var[1]])) ? $array[$var[1]] : $array)));
    }
    elseif($arg['php']) {				// PHPInfo() mit Archiv-Test
     init(5);
     ob_start();
     phpinfo();
     $data = ob_get_contents();
     ob_end_clean();
     if(($cfg['php'][2] != 'cli'))
      $data = preg_replace(array('/<style[^>]*>.*?<\/style>|<[^>]+>/s','/&#0?39;/','/&nbsp;/','/&amp;/'),array('',"'",' ','&'),$data);
     if($file = getArg('save'))
      if($var = ifset($file,$cfg['ptar'])) {	// Daten als Archiv schreiben
       $files = array('phpinfo.txt' => array('time' => time(), 'data' => $data));
       if($var[4]) {
        $bug and dbug("Erstelle ZIP-Archiv ...",0,10);
        file_contents($file,data2zip($files));
       }
       elseif($fp = file_stream($file,1)) {
        $bug and dbug("Erstelle TAR-Archiv ...",0,10);
        foreach($files as $file => $data)
         file_stream($fp,data2tar($file,$data['data'],$data['time']));
        file_stream($fp,str_repeat("\0",512));
        file_stream($fp);
       }
       $bug and dbug(" done");
      }
      else
       file_contents($file,$data);
     else
      out($data);
    }
    elseif($arg['pi'] and $array = ini_get_all()) {	// PHP.ini
     $preg = ($var = getArg('find')) ? "/".preg_quote($var,'/')."/i" : false;
     $ini = array();
     foreach($array as $key => $var) {
      $main = preg_match('/^(\w+)\./',$key,$val) ? $val[1] : "PHP";
      $key = preg_replace('/^\w+\./','',$key);
      if(!$preg or ifset($main,$preg) or ifset($key,$preg))
       foreach(array('global_value','local_value','access') as $val) {
        $vas = ($val == 'access') ?(($var[$val]&4) ? 's' : '-').(($var[$val]&2) ? 'p' : '-').(($var[$val]&1) ? 'u' : '-') : $var[$val];
        $ini[$main][$key][] = $vas;
       }
     }
     foreach($ini as $key => $var) {
      foreach($var as $k => $v)
       $var[$k] = trim("$k|$v[2]|".(($v[0] != $v[1]) ? ($v[0] ? "$v[0] \| $v[1]" : $v[1]) : $v[0]));
      $ini[$key] = strtoupper("||\n[$key]\n").implode("\n",$var);
     }
     init(5,'php');
     out($cfg['php'][5]."\n{{{tt}".implode("\n",$ini)."}}");
    }
    elseif($arg['g']) {					// PHP-GLOBALS
     init(5);
     $_ENV = getenv(null);
     $_CLASS = get_declared_classes();
     $_CONSTANT = get_defined_constants();
     $_EXTENSION = get_loaded_extensions();
     $_FUNCTION = get_defined_functions();
     $_PHPINI = ini_get_all();
     $_LASTMOD = getlastmod();
     $_MYGID = getmygid();
     $_MYINODE = getmyinode();
     $_MYPID = getmypid();
     $_MYUID = getmyuid();
     $_CURRENT_USER = get_current_user();
     $_INCLUDED_FILES = get_included_files();
     $_REQUIRED_FILES = get_required_files();
     if(is_callable("getrusage"))
      $_RUSAGE = getrusage();
     if(is_callable("stream_get_wrappers"))
      $_STREAM_WRAPPERS = stream_get_wrappers();
     if(is_callable("stream_get_transports"))
      $_STREAM_TRANSPORTS = stream_get_transports();
     if(is_callable("stream_get_filters"))
      $_STREAM_FILTERS = stream_get_filters();
     if($file = getArg('file'))
      file_contents($file,array2json($GLOBALS));
     else
      out($GLOBALS);
    }
    elseif($arg['et']) {				// PHP-Extension
     init(5);
     ob_start();					// PHPInfo() aufrufen
     phpinfo();
     $data = ob_get_contents();
     ob_end_clean();
     $bug and dbug($data);
     $array = array();
     foreach($cfg['mods'] as $key => $var) {
      $var = is_array($var) ? realpath($var[0]) : (is_string($var) ? realpath($var) : 'Intern oder bereits geladen');
      if($key == 'openssl')
       $array[$key] = OPENSSL_VERSION_TEXT;
      elseif($key == 'mysqli')
       $array[$key] = preg_replace(array('/(?<=\d)(?=(\d\d)+$)/','/\b0+(?=0\b)/'),array('.',''),mysqli_get_client_version());
      elseif(ifset($key,'/(aes\d*|sha(256|512)|hashtool)/i'))
       $array[$key] = preg_match('/\/\/\s*\b[\w-]+ ([\d\.]+)/',file_contents($var),$val) ? $val[1] : '-/-';
      elseif(preg_match("/^$key$\s*(?:.*?)^$/msi",$data,$val) and preg_match("/^(?:$key(?:\s*api)?|compiled|)?\s*version.*?(\d[\w.]+)/mi",$val[0],$m))
       $array[$key] = $m[1];
      elseif(preg_match("/^$key version.*?(\d[\w ,.-]+)/mi",$data,$m))
       $array[$key] = $m[1];
      elseif(preg_match("/^".substr($key,0,-1)." library .*?(\d[\w ,.-]+)/mi",$data,$m))
       $array[$key] = $m[1];
      else
       $array[$key] = "Unbekannt";
      $array[$key] = "$key||".$array[$key]."||$var";
     }
     out($array ? "{{{tt}".implode("\n",$array)."}}" : errmsg("8:Keine Erweiterungen gefunden!"));
    }
    elseif($arg['e']) {					// Echo
     $var = ifset($cfg['args']['str']) ? getArg('str',array()) : getArg(0,array());
     if($cfg['dbug']) {
      ob_start();
      var_dump($var);
      $data = ob_get_contents();
      ob_end_clean();
      $bug and dbug($data);
     }
     elseif($var)
      out(trim(implode(' ',$var)));
    }
    elseif($arg['st']) {				// strftime
     $arg = getArg('str',array());
     $cols = intval(getArg('-tc','is_numeric'));	// Gewünschte Spalten von der Tabelle
     $time = ($var = getArg('time') and $var = strtotime($var)) ? $var : microtime(true);
     if(is_string($time) and $var = explode(' ',$time) and count($var) == 2)
      $time = $var[0] + $var[1];
     if($arg) {
      foreach($arg as $str) {
       out($var = @$strftime(trim($str),$time));
       if($var = strtotime($var))
        $bug and dbug(($var != $time) ? "$arg -> ".(($var === false) ? "false" : "Zeitunterschied: ".($time - $var)." sec") : "Zeitausgabe wurde mit strtotime() erkannt");
      }
     }
     else {
      $array = $tmp = array();
      for($a=65; $a <= 90; $a++)	# StrfTime	// Alle Buchstaben
       for($b=0; $b < 2; $b++)				// Gross und kleinschreibung
        for($c=0; $c < 2; $c++) {			// Positiv und Negativ
         $key = ($c ? '-' : "").chr($a + $b * 32);	// Code-Zeichen berechnen
         $var = @$strftime("%$key",$time);		// Code-Datum erstellen
         $val = str_replace(array("\n","\t"),array('\n','\t'),str_pad("%$key",4," ")."= $var");	// Code-Spalte erstellen
         if($var !== false and !ifset($var,"/^%?".preg_quote($key,'/')."$/") and !ifset($key,"/^-?".preg_quote($var,'/')."$/") and (!$c or preg_replace('/^%-?(\w)\s*/','%$1  ',$val) !== $array[substr($key,1)]))
          $array[$key] = str_replace('|','\|',$val);
         $key = "!$key";		# Date@StrfTime	// Date-Code erstellen
         if(!preg_match('/^(%?'.$key.')?$/',$var = @$strftime("%$key",$time)) and (!isset($tmp[$d = str_replace("-","",$key)]) or "$var" !== preg_replace('/^[^=]+= /','',$tmp[$d])))
          $tmp[$key] = str_replace('|','\|',"%$key".($c ? "" : " ")."= $var");
        }
      $array = array_values(array_merge($array,array('%' => '%%  = %'),$tmp));
      $b = 1;
      $c = count($array);
      $max = $cfg['wrap'];
      do {
       $tmp = array();
       for($a=0; $a < $c; $a++)				// Tabelle erstellen
        if(strlen($tmp[$d = $a%$b] = (isset($tmp[$d]) ? $tmp[$d]."|\| " : "").$array[$a]) > $cfg['wrap']) {
         $a = false;
         break;
        }
       if($a) {
        $tmp = explode("\n",$out = textTable(implode("\n",$tmp),$cfg['wrap']*2));
        for($a=0, $max=0; $a < count($tmp); $a++)	// Tabellenbreite mit Whitespaces ermitteln
         $max = max($max,strlen($tmp[$a]));
       }
       $col = ceil($c/$b++);				// Tatzächliche Tabellenspalte
      }
      while((($max > $cfg['wrap']-2 and count($tmp) < $c) or $cols and $col > $cols) and $b < $c);	// Passt die Tabelle in die Console
      if(!isset($out)) {				// Fallback, wenn keine korrekte Breite ermittelt werden kann
       $cols = max(1,$cols ? $cols : 2);
       $d = ceil($c / $cols);
       $tmp = array();
       for($a = 0; $a < $cols; $a++)
        for($b = 0; $b < $d; $b++)
         $tmp[$b] = (isset($tmp[$b]) ? $tmp[$b]."|\|" : "").(isset($array[$e = $a*$d+$b]) ? $array[$e] : "");
       $out = textTable(implode("\n",$tmp));
      }
      out("$out\n\nWeitere Informationen erhalten sie mit dem Plugin 'StrfTime', php.net/strftime oder auf strftime.org");
     }
    }
    elseif($arg['cs'] and $file = getArg('file') and $data = preg_replace('/^\xef\xbb\xbf/','',file_contents($file))) {	// CSV
     if(preg_match('/^.*?\bsep=(.)/i',$data,$var)) {
      $cs = $var[1];
      $data = preg_replace('/^.*\r?\n/','',$data);
     }
     else
      $cs = ";";
     if($var = getArg("-cs"))
      $cs = strtr($var,array('\t' => "\t"));
     print textTable(out($data,9),0,$cs)."\n";
    }
    elseif($arg['x'] and $file = getArg('file') and ($var = ifset($file,$cfg['ptar'])
	or $var = getArg('-pa','/'.strstr($cfg['ptar'],'(')))) { // Archive Extract
     $ft = getArg('-ft',0,$cfg['fstr']);
     if($files = $var[4] ? zip2array(file_contents($file,0)) : datatar2array(file_contents($file))) {
      if($dir = getArg('dir')) {
       if(!file_exists($dir))
        makedir($dir,1);
       foreach($files as $key => $var) {
        out("$key ... ",2);
        if(!file_exists(dirname($key)))
         makedir(dirname($key),0);
        if(file_contents($key,$var['data']) or !$var['data']) {
         touch("$key",$var['mtime']);
         out("ok");
        }
        else
         out("fail");
       }
      }
      else {
	$typ = explode(',',"Daten,Gepackt,Programm,Document,Bild,Binär,Ascii,Ansi,Leer,UTF-8,UTF-8 BOM");
       $out = "Datei | Bytes|Typ |Datum\n";
       $sum = 0;
       foreach($files as $key => $var) {
        $sum += strlen($var['data']);
        $out .= "$key | ".number_format(strlen($var['data']),0,0,'.')."|"
	.$typ[preg_match('/^(PK\x03\x04|7z\xbc\xaf\'\x1c|\xfd7zXZ|\x1f\x8b\x08|BZh\d|Rar!)|^(MZ[\x00-\xff]\x00|\x7fELF|\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1\x00)'
	.'|^(%PDF|\x7b\\\\rtf1)|^(GIF8|\x89PNG|MM\x00|BM\xb6|\xff\xd8\xff\xe0)|(\x00)|^((?=[ -~\s]+$)...)|^(\xef\xbb\xbf)?((?=[\s -\xff]+$)...)|(^$)|(.)/s',$var['data'],$m)
	? ($m[1] ? 1 : ($m[2] ? 2 : ($m[3] ? 3 : ($m[4] ? 4 : ($m[5] ? 5 : ($m[6] ? 6
	: (($m[8] and utf8($var['data']) != $var['data']) ? ($m[7] ? 10 : 9) : ($m[8] ? 7 : (($var['data'] == "") ? 8 : 0))))))))) : 0]." |".($var['mtime'] ? @$strftime($ft,$var['mtime']) : " - ")."\n";
       }
       print textTable(out($out,9),0,"|","\n","|"," ").out("\n\nDateien gesamt: ".number_format(count($files),0,0,'.')." - Gesamtgröße: ".number_format($sum)." Bytes",1);
      }
     }
     else
      out(errmsg(0,'*'));
    }
    elseif($arg['wg'] and $var = getArg('url','/^(?:(https?):\/\/)?([.\w-]+)(?::(\d+))?(.*)$/i')) { // WGet
     $opt = array(
	'host' => $var[2],
	'sock' => $var[1] ? $var[1] : 'auto',
	'page' => $var[4] ? $var[4] : '/',
	'method' => ($file = getArg('file')) ? (($file == ':') ? 'GET' : 'GET-save:'.$file) : 'GET-save:./');
     $opt['port'] = $var[3] ? $var[3] : ((strlen($opt['sock']) == 5) ? 443 : 80);
     out(($val = request($opt)) ? $val : ($cfg['http'] ? $cfg['http'] : errmsg("8:Aufruf fehlgeschlagen")));
    }
    elseif($arg['h'] and ($file = getArg('file','file_exists') or $str = getArg('str') or $file = $script)) { // Hashes berechnen
     $a = $b = 0;
     $hash = array();
     if(!ifset($str))
      $size = filesize($file);
     if(!function_exists('hash_algos'))	// SHA-256 nachinstallieren
      init(5,'mhash sha256 sha512');
     $algo = array('crc32b','md5','sha1','sha256','sha512');
     if(!isset($str) and function_exists('hash_init') and $fp = fopen($file,'r')) { // Hash direkt beim Laden erstellen
      foreach($algo as $var)		// Init Hashes
       $hash[$var] = hash_init($var);
      while(!feof($fp)) {		// Read Data
       $data = fread($fp,$cfg['sbuf']);
       foreach($hash as $var)		// Calc Hashes
        hash_update($var,$data);
       $a += strlen($data);		// Fortschritts-Anzeige berechnen
       $c = floor($a / max($a,$size) * max($cfg['wrap']-1,10)) - $b;
       $bug and dbug(str_repeat(".",$c),0,10);	// Download-Anzeige
       $b += $c;
      }
      $bug and dbug("\n",0,8);		// Download-Anzeige abschließen
      foreach($hash as $key => $var)	// Finalize Hashes
       $hash[$key] = hash_final($var);
      fclose($fp);
     }
     else
      foreach($algo as $var)		// Daten laden und dann ein Hash davon berechnen
       $hash[$var] = hash($var,ifset($str) ? $str : file_contents($file,0));
     $out = ($str ? "String:|$str" : "File:|$file\nSize:|".number_format($size,0,0,'.')." Bytes")."\n\n";
     foreach($hash as $key => $var)	// Hashes ausgeben
      if($var = preg_replace('/(?<=\w)(?=(\w{8})+$)/i',' ',$var))
       $out .= preg_replace('/\D$/','',strtoupper($key)).":|$var\n";
     out("{{{tt}$out}}");
    }
    elseif(($arg['otp'] or ifset($val['i'],'/otp(auth)?/i')) and (function_exists('hash_hmac') or init(5,'hashtool'))	// OTPAuth
	and ($data = getArg('secret',$preg = '/(?i:\b[A-Z2-7]{4}(\W?[A-Z2-7]{4}){7}\b)|^[A-Z2-7]{16,32}$/i0')	// secret-Parameter überprüfen
	or $file = getArg('file','file_exists') and $var = file_contents($file) and $data = ifset($var,$preg)	// OTP von einer Datei
	or $data = ifset($cfg['totp'],$preg) or $data = ifset($cfg['uipw'],$preg)		// OTP aus der Konfig-Datei
	or $var = getArg(0,array()) and $var = implode('',$var) and $data = ifset($var,$preg))) {// Alle restlichen Parameter als Secret-Parameter
     $ft = getArg('-ft',0,"$cfg[fstr] : ");						// Option für eigenes Datum-Format
     $rp = getArg('-rp','is_numeric',1);						// Option für Multi-Token ausgabe
     $bug and dbug("Nutze OATH-TOTP-Secret: ".preg_replace('/[^A-Z2-7]+/','',strtoupper($data))." (".@$strftime($cfg['fstr'],$cfg['time']).")");
     if($otp = otpauth($data,$rp,$cfg['time'])) {
      if(is_array($otp)) {
       foreach($otp as $key => $var)
        $otp[$key] = @$strftime($ft,$key).$var;
       $otp = implode("\n",$otp);
      }
      out($otp);
     }
     else
      out(errmsg(0,'otpauth'));
    }
    elseif(ifset($cfg['uplink'],5) and ($arg['ud'] or ifset($val['i'],'/upgrade|ug/i'))) {	// FB_Tools Update
     if(!getArg('-f') and $fbnet = mytouch(0) and is_array($fbnet) and ifset($fbnet['ver']) and $fbnet['ver'] <= $cfg['ver'][10]
	and ifset($fbnet['time']) and time()-$fbnet['time'] < $cfg['uptp'])
      out(errmsg("1:Ein Update ist jetzt nicht erforderlich!"));
     else {							// Updateliste laden
      if($cfg['sock'] == 'auto' and !$cfg['ssl'])		// SSL Laden
       $cfg['ssl'] = init(5,'openssl');
      foreach($cfg['uplink']['port'] as $port)
       if($fbnet = request('GET-array',$cfg['uplink']['path'].$cfg['uplink']['fbts'].".md5",0,0,$cfg['uplink']['host'],$port)) {
        if($var = ifset($fbnet['Location'],'/^(https?:)(\/\/.+)$/'))
         $fbnet = request("$var[1][array]$var[2]");
        break;
       }
      if($fbnet and $rd = getArg('-rd','is_dir'))		// RAW-Daten Speichern?
       file_contents(realpath($rd)."/".$cfg['uplink']['fbts'].".md5",$fbnet[1]);
      if($fbnet and ifset($fbnet['Content-MD5'],"/^(".preg_quote(base64_encode($var = hash('md5',$fbnet[1],true)),'/')."|".bin2hex($var).")$/") or getArg('-f')) {// Update-Check
       if($fbnet and preg_match("/((\d\d)\.(\d\d)\.(\d{4}))\s([\d:]+)\s*\((\w+)\s([\d.]+)\)(?:.*?(\w+)\s\*[\w-]+\.$cfg[ext](?=\s))?/s",$fbnet[1],$up)) {// Liste auswerten
        if((intval($up[4].$up[3].$up[2]) >= $cfg['ver'][9] and floatval($up[7]) > $cfg['ver'][10]) or getArg('-f')) {			// Versionscheck
         out("Ein Update ist verfügbar: $up[6] $up[7] vom $up[1]");
         if(!getArg('opt','/^(c|check)$/i')) {
          out("Installiere Update ... ");
          $manuell = "!\nBitte installieren Sie es von http://{$cfg['uplink']['host']}/.dg manuell!";
          if(ifset($up[8]) and $up[9] = @request('GET',$cfg['uplink']['path'].$cfg['uplink']['fbts'].".$cfg[ext].gz"			// Neues fb_Tools herunterladen
		.(ifset($fbnet['X-Usrid']) ? "?".preg_replace('/^0+/','',bin2hex(base64_decode($fbnet['X-Usrid']))) : ""),0,0,$cfg['uplink']['host'],$port)) {
           if($rd)
            file_contents(realpath($rd)."/".$cfg['uplink']['fbts'].".$cfg[ext].gz",$up[9]);
           $rename = preg_replace('/(?=(\.\w+)?$)/',"_{$cfg['ver'][2]}.bak",$script,1);							// Neuer Name für alte Version
           if($var = $cfg['zlib']['decode']($up[9]) and (getArg('-f') or hash('md5',$var) == $up[8]) and @rename($script,$rename)) {	// Update ab PHP5
            file_contents($script,$var);
            @chmod($script,intval(fileperms($rename),8));
            out("abgeschlossen!");
           }
           else
            out(errmsg("16:fehlgeschlagen$manuell"));
          }
          else
           out(errmsg("16:Automatisches Update ist nicht verfügbar$manuell"));
         }
        }
        else {
         out("Kein neues Update verfügbar!");
         if(ifset($up[7],$cfg['ver'][10]) and $up[8] != hash('md5',file_contents($script)))	// MD5-Check
          out(errmsg("1:Hinweis: $Self wurde verändert"));
        }
        mytouch(array('time' => time(), 'uptime' => strtotime("$up[4]-$up[3]-$up[2] $up[5]"), 'name' => $up[6], 'ver' => floatval($up[7])));	// Aktuelles Datum setzen
       }
       else							// fb_tools.md5 nicht verfügbar
        out(errmsg("16:Update-Server sagt NEIN! - Kein gültiges Update verfügbar"));
       if($cfg['coki'] and $fbnet['X-Cookie'])			// Coolen Spruch ausgeben
        out("\n".$fbnet['X-Cookie']);
      }
      else							// Kein Netzwerk/Internet verfügbar
       out(errmsg("16:Computer sagt NEIN! - Entweder ist MEngelke offline oder es ist kein Netzwerk/Internet verfügbar"));
     }
    }
    else
     out(errmsg("2:Unerwartete Parameter übergeben!"));
   elseif($var = getArg('-ip') and is_string($dev) and ifset($dev,'/^https?:/i'))	// Developer-Version Speichern
    if(is_string($var) and $data = request($dev))
     file_contents($var,(preg_match('/\.php$/',$var) ? preg_replace(array('/^[@:].*?(?=<\?php)|(?<=lines=)cr\+(?=lf)|\r/s','/^/'),array('',"#!/usr/bin/php\n"),$data) : $data));
    else
     request(preg_replace('!(?<=:)(?=/)!','[GET-save:./]',$dev));
   else {						// FB_Tools-Version und PHP Kurzinfos ausgeben
    $var = array("PHP {$cfg['php'][0]}/{$cfg['php'][2]} ({$cfg['php'][4]} Bit)".($cfg['cron'] ? " - Sicherheits-Modus" : ""),$cfg['php'][1]);
    if(ifset($dev)) {					// Developer-Version ausgeben
     $data = "\nLocation: ";
     if(is_string($dev)) {
      $data .= ifset($dev,'/^https?:/i') ? $dev : realpath($dev);
      if((is_callable('http_get_last_response_headers') and $array = http_get_last_response_headers()
	or isset($GLOBALS['http_response_header']) and $array = $GLOBALS['http_response_header'])
	and $val = preg_array('/^Last-Modified: (.*)$/i',$array,32)) {
       $data .= " - Stand: ".$strftime(getArg('-ft',0,$cfg['fstr']),strtotime($val[1]));
       if($val = preg_array('/^X-Channel: (\w+)$/i',$array,32))
        $data .= " - Release: ".strtr($val[1],array('beta' => 'Beta', 'dev' => 'Developer'));
       if($cfg['coki'] and $val = preg_array('/^X-Cookie: (.*)$/i',$array,32))
        $data .= "\n\n$val[1]";
      }
     }
     elseif(is_array($dev)) {
      foreach($dev as $k => $v)
       if(!preg_match('/^https?:/i',$v) and file_exists($v))
        $dev[$k] = realpath($v);
      $data .= implode(', ',$dev);
      if(file_exists($val = end($dev)))
       $data .= " - Stand: ".$strftime(getArg('-ft',0,$cfg['fstr']),filemtime($val));
      $data .= " - Release: XDebug".(getenv('XDEBUG_TRIGGER') ? " (Activ)" : "");
     }
    }
    else
     $data = "";
    out($cfg['ver'][0]."\n\n".implode(($cfg['wrap'] and strlen($var[0].$var[1])+3 < $cfg['wrap']) ? " - " : "\n",$var)
	."\nTerminal: Breite: $cfg[wrap], Zeichensatz: {$cfg['char'][0]}, OS: ".strtoupper($cfg['os']).", Benutzer: $cfg[cu]"
	.(($var = getenv('SUDO_USER')) ? " ($var)" : "")
	.(ifset($cfg['loadcfg']) ? "\n\n{{{tt}Konfig-Datei:|".str_replace('|',', ',$cfg['loadcfg'])."|}}" : "").$data);
   }
  }
  elseif($val['al']) {					// Anrufliste
   if(ifset($cfg['help'])) {				// Hilfe Ausgeben
    out("$self [$cfg[fbhp]] [mode:AnrufListe|al] <file:Datei/Ordner> <from:zeit> <to:zeit>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:anrufliste file:calllist-%y%m%d.csv -cs:$qt\\t$qt
$self $cfg[fbhp] al
$self $cfg[fbhp] al from:2018-01-01 {$qt}to:2018-12-31 23:59$qt
$self $cfg[fbhp] anrufliste calls-%F.json
$self $cfg[fbhp] mode:anrufliste file:call_%Y-%m-%d.csv -ch -lf" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "AnrufListe:|-ch||Schreibt in der Datei ein CSV-Header
|-cs:|[Char]|CSV-Separator festlegen (;)
|-ft:|[Strftime]|Eigenes Datumsformat ($cfg[fstr])
|-lf||Schreibt die Daten als Logfile";
   }
   elseif($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {
    if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
     $bug and dbug("Download der Anrufliste anfordern");
     $pfile = getArg('file');
     $from = ($var = getArg('from') and $val = strtotime($var) and $val != -1) ? $val : false;
     $to = ($var = getArg('to') and $val = strtotime($var) and $val != -1) ? $val : false;
     $file = ($pfile and strpos($pfile,'%') !== false) ? @$strftime($pfile) : ((!$pfile or ifset($pfile,'/^[:*]$/')) ? false : $pfile);
     $ftime = getArg('-ft');						// Benutzerdefiniertes Datum-Format
     if($data = getcall('all')) {					// Anrufliste holen
      $bug and dbug($data,4);
      $count = 0;
      $sep = strtr((!$file) ? '|' : getArg('-cs',0,$data['sep']),array('\t' => "\t"));	// Seperator für CSV-Dateien
      $psep = preg_quote($sep,'/');
      $csv = (!$file or getArg('-ch')) ? preg_replace("/".preg_quote($data['sep'],'/')."/",$sep,$data['csv']) : "";	// CSV-Header
      $call = array();							// Zeitbereich auswählen
      foreach($data['call'] as $time => $var)
       if((!$from or $time >= $from) and (!$to or $time <= $to)) {
        if($ftime)
         $var[1] = @$strftime($ftime,$time);
        $var[0] = str_replace($sep,"\\$sep",strtr($var[0],array('fail','in','ring','drop','out')));
        $call[$time] = implode($sep,$var);
       }
      $bug and dbug(count($call).((count($call) != count($data['call'])) ? "/".count($data['call']) : "")." Anruf(e) wurden ausgelesen");
      if(!$file)							// Anrufliste auf den Bildschirm ausgeben
       out("{{{tt}".utf8(preg_replace('/^.*sep=.*\r?\n/','',$csv).implode("\n",$call))."}}");
      elseif(ifset($file,'/\.json(\.(gz|bz(ip)?2?|zip))?$/i')) {	// Anrufliste als JSON-Datei schreiben
       $bug and dbug("Anrufliste als JSON-Datei speichern");
       file_contents($file,array2json($data,1));			// Komplette Liste Speichern
      }
      else {								// CSV-Datei speichern
       $preg = "/((?:[0-4]|fail|in|ring|drop|out)$psep((0[1-9]|[12]\d|3[10])\.(0[1-9]|1[0-2])\.(?:20)?(\d\d)\s+([\d:]+)|[\w .:\/+-]+)($psep(.*?)){4,5})\s*$/";
       if(getArg('-lf')) {						// Logmodus
        $bug and dbug("Anrufliste im Logfile-Modus speichern");
        $last = -1;
        foreach($call as $key => $var) {
         if($file != ($val = (strpos($pfile,'%') !== false) ? @$strftime($pfile,intval($key)) : $pfile))
          $file = $val;
         $date = 0;
         if(file_exists($file)) {
          if($data = file_contents($file,-256) and preg_match($preg,$data,$m))
           $date = strtotime($m[3] ? "20$m[5]-$m[4]-$m[3] $m[6]" : $m[2]);
         }
         elseif($csv)
          file_contents($file,$csv);					// CSV-Header anlegen
         if(intval($key) > $date or intval($key) == $last) {		// or intval($key) == $date and $var != $val[1]
          file_contents($file,"$var\r\n",8);				// Anruf speichern
          $last = intval($key);
          $count++;
         }
        }
       }
       else {								// Anrufliste normal in Datei speichern
        if(file_exists($file)) {
         $date = 0;
         if($data = file_contents($file,-256) and preg_match($preg,$data,$m))
          $date = strtotime($m[3] ? "20$m[5]-$m[4]-$m[3] $m[6]" : $m[2]);
         foreach($call as $key => $var)
          if(intval($key) <= $date)
           unset($call[$key]);
         if($call)
          file_contents($file,implode("\r\n",$call)."\r\n",8);		// Anruf speichern
        }
        else
         file_contents($file,$csv.implode("\r\n",$call)."\r\n");	// Anruf speichern
        $count = count($call);
       }
      }
      if($count)
       out("Es wurde".(($count == 1) ? " 1 neuer Eintrag" : "n $count neue Einträge")." gespeichert");
     }
     else
      out(errmsg("8:Keine Anrufliste erhalten!"));
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
    if(!ifset($cfg['bsid']))						// Abmelden
     logout($sid);
   }
   else
    out(errmsg(0,'login'));						// Login fehlgeschlagen
  }
  elseif($val['bi']) {					// Jason/Juis Boxinfo
   if(ifset($cfg['help'])) {
    out("$self <$cfg[fbhp]> [mode:BoxInfo|bi] <file:jason_boxinfo.xml>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self mode:boxinfo file:/media/stick/jason_boxinfo.xml
$self $cfg[fbhp] bi
$self $cfg[fbhp] boxinfo -rd:debug
$self $cfg[fbhp] boxinfo" : ""));
    if(!$cfg['help'] or $cfg['help'] === true)
     $cfg['help'] = -1;
    $opts .= "Boxinfo:|-rd:|<path>|Schreibt die RAW-Daten";
   }
   elseif($data = boxinfo(($arg = getArg('file','file_exists')) ? file_contents($arg) : false,$path = getArg('-rd'))) {
    if(is_array($data)) {				// RAW-Daten Speichern
     if(!is_bool($path))
      if(!file_exists($path))
       makedir($path);
      elseif(is_dir($path))
       chdir($path);
     foreach($data as $key => $var)
      if(!is_int($key))
       file_contents("$key",$var[1]);
     $data = $data[0];
    }
    out("Boxinfos:\n".$data);
   }
   elseif($data === '')
    out(errmsg("8:Keine BoxInfos erhalten"));
   else
    out(errmsg(0,'request'));
  }
  elseif($val['gip']) {					// Get Extern IP
   if(ifset($cfg['help'])) {
    out("$self <$cfg[fbhp]> [mode:GetIP|gip] <filter> <file:json|csv> <url>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:getip filter:ipv4
$self $cfg[fbhp] gip
$self $cfg[fbhp] getip
$self $cfg[fbhp] gip dns
$self $cfg[fbhp] getip file:ip_%F.json
$self $cfg[fbhp] getip file:{$qt}ip_%Y-%-b.csv$qt -cs:$qt;$qt -ft:$qt%F %X$qt
$self $cfg[fbhp] getip file:ip_%F.json url:{$qt}http://example.org?data=<b64>ip=<ipaddr>&ip6=<ip6addr>&ip6lan=<ip6lanprefix></b64>$qt -f" : ""));
    if(!$cfg['help'] or $cfg['help'] === true)
     $cfg['help'] = -1;
    $opts .= "GetIP:|-cs:|[Char]|CSV-Separator festlegen (;)
|-ft:|[Strftime]|Eigenes Datumsformat ($cfg[fstr])
|-f||Request-Url im jeden Fall aufrufen";
   }
   elseif($array = getexternalip()) {
    if($array and $file = getArg('file')) {
     $sep = getArg('-cs','/^(\\\\t|.)$/0',' ');		// Eigenen Seperator
     $ftime = getArg('-ft');				// Benutzerdefiniertes Datum-Format
     $msg = "1:IP-Adressen haben sich geändert";
     if(ifset($file,'/\.csv(\.gz)?$/i') or trim($sep) or $ftime) {	// File-Modus CSV
      $sep = strtr($sep,array('\t' => "\t"));
      if(!$ftime)
       $ftime = $cfg['flog'];
      $csv =	$sep.(($var = ifset($array['IPv4'],"")) ? $var : '-')
		.$sep.(($var = ifset($array['IPv6'],"")) ? $var : '-')
		.$sep.(($var = ifset($array['IPv6-Prefix'],"")) ? $var : '-')
		.$sep.(ifset($array['DNSv4']) ? implode($sep,array_slice($array['DNSv4'],0,2)) : "-$sep-")
		.$sep.(ifset($array['DNSv6']) ? implode($sep,array_slice($array['DNSv6'],0,2)) : "-$sep-")
		."\n";
      if(file_exists(@$strftime($file)) and $data = file_contents($file,-1024) and $csv == substr($data,-strlen($csv)))
       $csv = false;					// Der letzte Eintrag ist noch aktuell!
      if($csv) {
       file_contents($file,@$strftime($ftime).$csv,8);
       errmsg($msg);
      }
     }
     else {						// File-Modus JSON
      $data = array2json($array);
      if(!file_exists($file) or $json = (md5_file($file) != md5($data))) {
       file_contents($file,$data);
       if($json)
        errmsg($msg);
      }
     }
     if(($lnk = getArg('url',array(),0) or $lnk = getArg(0,array())) and (getArg('-f') or ifset($csv) or ifset($json))) {	// Urls Aufrufen
      $ip = array();
      foreach(preg_array('/^ipv[46](-prefix)?$/i',$array,3) as $key => $var)
       $ip[strtr($key,array('IPv4' => '<ipaddr>', 'IPv6' => '<ip6addr>', 'IPv6-Prefix' => '<ip6lanprefix>'))] = $var;
      foreach($lnk as $url) {
       if(preg_match('!<b64>(.*?)</b64>!',$url = strtr($url,$ip),$m,PREG_OFFSET_CAPTURE))
        $url = substr_replace($url,urlencode(base64_encode($m[1][0])),$m[0][1],strlen($m[0][0]));
       out("$url:\n".request($url)."\n");
      }
      $array = false;
     }
    }
    if($array and is_array($array)) {
     if($var = getArg('filter','/[-\w]+/0'))		// Filter für die Ausgabe
      $array = preg_array("/$var/i",$array,3);
     if(count($array) == 1)				// Ist nur EIN Wert im Array, dann nur diesen einen Wert ohne Key ausgeben
      $array = array(reset($array));
     else
      foreach($array as $key => $var)			// Tabelle mit mehreren Werten erstellen
       $array[$key] = "$key:|".(is_array($var) ? implode(", ",$var) : $var);
     if($array)						// Tabelle ausgeben
      out("{{{tt}".implode("\n",$array)."}}");
     else
      out(errmsg("8:Keine Daten erhalten"));
    }
   }
   elseif($var = errmsg(0,'getexternalip'))
    out($var);
   else
    out(errmsg("8:UPnP Deaktiviert oder keine IP-Adressen erhalten"));
  }
  elseif($val['e']) {					// Ereignisse
   if(ifset($cfg['help'])) {
    out("$self [$cfg[fbhp]] [mode:Ereignisse|e] <file> <filter> <from:zeit> <to:zeit>\n
Folgende Filter sind Möglich: alle, telefon, internet, usb, wlan, system".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:Ereignisse file:event-internet.csv filter:internet -cs:;
$self $cfg[fbhp] Ereignisse event.csv
$self $cfg[fbhp] e -pw:secret
$self $cfg[fbhp] e logs-%y%m%d.log alle -lf
$self $cfg[fbhp] ereignisse logs-%F.json" : ""));
    if(!$cfg['help'] or $cfg['help'] === true)
     $cfg['help'] = -1;
    $opts .= "Ereignisse:|-ch||Schreibt in der Datei ein CSV-Header
|-cs:|[Char]|CSV-Separator festlegen ( )
|-ft:|[Strftime]|Eigenes Datumsformat ($cfg[fstr])
|-lf||Schreibt die Daten als Logfile";
   }
   elseif($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {	// Einloggen
    if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
     $pfile = getArg('file');
     $file = (strpos($pfile,'%') !== false) ? @$strftime($pfile) : (ifset($file,'/^[:*]$/') ? false : $pfile);
     $filter = preg_array('/^'.getArg('filter','/^(?=a(lle)?|t(elefon)?|i(nternet)?|u(sb)?|w(lan)?|s(ystem)?)\w/i0',0,'a').'/i',explode(',','alle,telefon,internet,usb,wlan,system'));
     $from = ($var = getArg('from') and $val = strtotime($var) and $val != -1) ? $val : false;
     $to = ($var = getArg('to') and $val = strtotime($var) and $val != -1) ? $val : false;
     $sep = strtr(getArg('-cs',0,' '),array('\t' => "\t"));		// Seperator für CSV-Dateien
     $psep = preg_quote($sep,'/');
     $count = 0;
     $preg = array("/(0[1-9]|[12]\d|3[10])\.(0[1-9]|1[0-2])\.(?:20)?(\d\d)$psep([\d:]+)$psep(.*?)\s*$/","/(?<=^|\\n)([\w .:+\/-]+)$psep(.*?)\s*$/");
     $ftime = getArg('-ft');						// Benutzerdefiniertes Datum-Format
     $json = ifset($file,'/\.json(\.(gz|bz(ip)?2?|zip))?$/i');		// JSON-Datei abfragen
     if($array = getevent($filter)) {					// Ereignisse holen
      $event = array();							// Zeitbereich auswählen
      foreach($array as $key => $var)
       if($time = intval($key) and (!$from or $time >= $from) and (!$to or $time <= $to))
        $event[$key] = $json ? $var : utf8($var);
      $bug and dbug(count($event).((count($event) != count($array)) ? "/".count($array) : "")." Event(s) wurden ausgelesen");
      if($json) {							// Ereignisse als JSON-Datei schreiben
       $bug and dbug("Alle Ereignisse als JSON-Datei speichern");
       file_contents($file,array2json($event,1));
      }
      elseif($file and getArg('-lf')) {					// Logmodus
       $bug and dbug("Ereignisse im Logfile-Modus speichern");
       $last = -1;
       foreach($event as $key => $var) {
        if($file != ($val = (strpos($pfile,'%') !== false) ? @$strftime($pfile,intval($key)) : (ifset($file,'/^[:*]$/') ? false : $pfile)))
         $file = $val;
        $date = file_exists($file) ? (($data = file_contents($file,-1024) and preg_match($preg[0],$data,$m)) ? strtotime("20$m[3]-$m[2]-$m[1] $m[4]") : 0) : 0;
        if(intval($key) > $date or intval($key) == $last) {
         $last = intval($key);
         file_contents($file,($ftime ? @$strftime($ftime,$last) : "$var[0]$sep$var[1]")."$sep$var[2]\n",8);	// Ereignisse speichern
         $count++;
        }
       }
      }
      elseif($file) {							// Ereignisse normal in Datei speichern
       $bug and dbug("Ereignisse normal speichern");
       $date = 0;
       $log = array();
       if(file_exists($file)) {
        $data = file_contents($file,-1024);
        if(preg_match($preg[0],$data,$m))
         $date = strtotime("20$m[3]-$m[2]-$m[1] $m[4]");
        elseif(preg_match($preg[1],$data,$m))
         $date = strtotime($m[1]);
       }
       elseif(getArg('-ch'))
        $log[] = ($ftime ? "" : "date$sep")."time{$sep}info";		// CSV-Header
       foreach($event as $key => $var)
        if(intval($key) > $date)
         $log[] = ($ftime ? @$strftime($ftime,intval($key)) : "$var[0]$sep$var[1]")."$sep$var[2]";
       if($count = count($log))
        file_contents($file,implode("\n",$log)."\n",8);			// Ereignisse speichern
      }
      elseif($event) {							// Ereignisse auf den Bildschirm ausgeben
       $val = "";
       foreach($event as $key => $var)
        $val .= ($ftime ? @$strftime($ftime,intval($key)) : "$var[0] $var[1]")."|$var[2]\n";
       out("{{{tt}Datum|Ereignis\n$val}}");
      }
      if($count)
       out("Es wurde".(($count == 1) ? " 1 neuer Eintrag" : "n $count neue Einträge")." gespeichert");
     }
     else
      out(errmsg(0,'getevent'));
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
    if(!ifset($cfg['bsid']))						// Ausloggen
     logout($sid);
   }
   else
    out(errmsg(0,'login'));
  }
  elseif($val['k']) {					// Konfig
   if(ifset($cfg['help']) or !getArg(true))
    out("$self <$cfg[fbhp]> [mode:Konfig|k] [func:Funktion] <Datei|Ordner> <Kennwort>\n
Funktionen (func):\n{{{tt}
ExPort|<of:file> <pass>|-|Konfig exportieren(1)
ExPort-DeCrypt|<of:file> <pass>|-|Konfig entschlüsseln und exportieren(1,3)
ExTrakt|<of:dir> <pass>|-|Konfig entpackt anzeigen/exportieren(1)
ExTrakt-DeCrypt|<of:dir> <pass>|-|Konfig entpackt entschl./anz./exp.(1,3)
File|[if:file] <of:dir>|-|Konfig aus Datei entpacken und anzeigen(2)
File|[if:dir] [of:file]|-|Konfig-Ordner in Datei zusammenpacken(2)
File-CalcSum|[if:file/dir] [of:file]|-|Konfig-Datei/Ordner für Import Vorbereiten(2)
File-DeCrypt|[if:file] [pass:list/file]||<of:file> - Konfig-Daten entschlüsseln(2,3,4)
File-JSON|[if:file] [of:file]|-|Konfig-Daten in JSON konvertieren(2)
ImPort|[if:file/dir] <pass>|-|Konfig importieren(1)
ImPort-CalcSum|[if:file/dir] <pass>|-|Veränderte Konfig importieren(1)}}\n
(1) Anmeldung mit Logindaten und 2FA erforderlich / (2) Ohne Fritz!Box nutzbar
(3) Eins von (php_openssl, php_mcrypt, aes.php, aes_4.class.php) erforderlich
(4) Mehrere Angaben möglich (pass:foo pass:bar pass:test oder pass[/]:foo/bar/test)
[ ] Pflicht | < > Optional | ( ) Auswahl\n
Ab OS 6.69 ist beim Login eine Zwei-Faktor-Authentisierung erforderlich, falls aktiviert".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] konfig export
$self $cfg[fbhp] konfig extrakt
$self konfig file fritzbox.export.gz
$self konfig file-decrypt fb.export geheim fbdc.export -d
$self $cfg[fbhp] konfig extract archiv.tar.gz
$self k fcs Export-Ordner fritzbox.export
$self $cfg[fbhp] konfig import {$qt}fb 7170.export$qt
$self $cfg[fbhp] konfig import archiv.tar.gz
$self $cfg[fbhp] k ipcs {$qt}FRITZ.Box Fon WLAN 6360 85.04.86_01.01.00_0100.export$qt
$self k fdc if:fb7390_nopass.export pass:admin123 pass:11:23:58:13:21:34 pass:passwd.txt
$self k fdc if:fb7530_nopass.export of:fb7530_decrypt.export pass:K175.678.30.000.196-98:9B:CB:30:01:96" : ""));
   elseif($mode = getArg('func','/^(					# 1:Alle
	|i(p|mport)(cs|-calcsum)?					# 2:Import 3:CalcSum
	|e(p|xport)(?:(dc|-de(?:crypt|code))?)				# 4:Export 5:DeCrypt
	|(et|(?:extra[ck]t))?(?:(dc|-de(?:crypt|code))?)		# 6:Extrakt 7:DeCrypt
	|(f(?:ile)?)(?:(cs|-calcsum)?|(dc|-de(?:crypt|code))?|(-?json)?)# 8:File 9:CalcSum 10:DeCrypt 11:JSON
		)($)/ix')) {
    $bug and dbug($mode,3);				// Debug Parameter
    $file = getArg('if');
    $pass = ($pw = getArg('pass',array())) ? reset($pw) : ""; // Multipass ;-)
    $save = getArg('of');
    if(($mode[5] or $mode[7] or $mode[10]) and !init(5,'aes')) {
     out(errmsg("64:Die Entschlüsselung wird von ihren System nicht unterstützt!\nBitte Installieren Sie die AES-Scripte aus dem Archiv: fb_Tools.7z\n\n"));
     $mode[5] = $mode[7] = $mode[10] = false;
    }
    if(($mode[2] or $mode[4] or $mode[6])) {		// Login Optionen
     if($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login(0,0,true)) {
      if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
       if(!$pw and is_bool($pw) and $cfg['fiwa'] >= 600)// Sicherstellen, dass ab Fritz!OS 6 immer mit einem Kennwort exportiert wird
        $pass = $cfg['pass'];
       $file = getArg('of',false,$file);		// Arg[of]
       if(!ifset($pass))
        $pass = false;
       if(($mode[5] or $mode[7]) and !$pass)		// Im DeCode-Modus kein leeres Kennwort zulassen
        $pass = ifset($cfg['pass'],'/^[ -~]+$/') ? $cfg['pass'] : 'geheim';
       if($mode[4]) {					// Export
        if(is_dir($file)) {				// Im Ordner schreiben
         makedir($file);				// Verzeichnis erstellen
         $file = false;
        }
        if($mode[5] and $pass and $data = cfgexport('array',$pass) and $data[1]) {	// Exportieren mit Entschlüsselten Benutzerdaten
         $bug and dbug("Entschlüssele Konfig-Daten");
         if($data[1] and $data[1] = cfgdecrypt($data[1],$pass)) {
          out(showaccessdata($data[1]));
          saverpdata($file,$data,'file.export');
         }
         else
          out(errmsg(0,'cfgdecrypt') || errmsg(0,'cfgexdport') || errmsg(0,'request'));
        }
        elseif(!ifset($data))					// Export direkt File
         out(cfgexport($file ? $file : true,$pass) ? "Konfiguation wurde erfolgreich exportiert" : errmsg(0,'request'));
        else
         out(($var = errmsg(0,'request')) ? $var : errmsg("8:Keine Konfig erhalten - Möglichlichweise ist noch die Sicherheits-Bestätigungsfunktion aktiviert?"));
       }
       elseif($mode[6]) {					// Extrakt
        if($data = cfgexport('array',$pass) and $data[1]) {	// Konfigdaten holen
         $mod = $file ? (preg_match($cfg['ptar'],$file,$var) ? ($var[4] ? 5 : (($cfg['bzip'] and $var[3]) ? 4 : ($var[2] ? 3 : 2))) : 1) : 0;
         if($mod == 1)
          makedir($file);					// Verzeichnis erstellen
         $bug and dbug("Entschlüssele Konfig-Daten");
         if($mode[7] and $pass and $data[2] = cfgdecrypt($data[1],$pass,$sid))	// Konfig Entschlüsseln
          out(cfginfo($data[2],$mod,$file,showaccessdata($data[2])));
         else
          out(cfginfo($data[1],$mod,$file));
        }
        else
         out(($var = errmsg(0,'request')) ? $var : errmsg("8:Keine Konfig erhalten - Möglichlichweise ist noch die Sicherheits-Bestätigungsfunktion aktiviert?"));
       }
       elseif($mode[2] and $file and file_exists($file))	// Import-Konfig
        out(cfgimport($file,$pass,$mode[3]) ? "Konfig wurde hochgeladen und wird nun bearbeitet" : errmsg(0,'cfgimport'));
       else
        out(errmsg("8:$file kann nicht geöffnet werden!"));
      }
      else
       out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
      if(!ifset($cfg['bsid']))
       logout($sid);
     }
     else
      out(errmsg(0,'login'));
    }
    elseif($file = getArg('if',false,$file) and $mode[8] and !$mode[10] and !$mode[11] and is_file($file) and $data = file_contents($file) and preg_match('/^\*{4}\s+\w+.*CONFIGURATION EXPORT/',$data)) {	// Converter-Modus File -> Dir
     $mod = ($save = getArg('of',false,$pass)) ? (preg_match($cfg['ptar'],$save,$var) ? (($cfg['bzip'] and ifset($var[3])) ? 4 : (ifset($var[2]) ? 3 : 2)) : 1) : 0;
     if($mod == 1 and $mode[9] and preg_match('/\.\w+$/',$save)) {	// Soll nur eine Checksumme berechnet werden und in einer Datei geschrieben werden
      $var = cfgcalcsum($data);
      $val = errmsg(0,'cfgcheck',1);
      out(file_contents($save,$var[2]) ? (($var[0] == $var[1] and !$val) ? "Konfig-Checksumme ist korrekt!"
	: errmsg("1:".(($var[0] != $var[1]) ? "Konfig-Checksumme wurde von $var[0] auf $var[1] korrigiert".($val ? " und $val!" : "!") : "KonfigDatei hat einen Formatierungsfehler: $val")))
	: errmsg("32:Konfig-Datei konnte nicht gespeichert werden!"));
     }
     else
      out(($data = cfginfo($data,$mod,$save)) ? $data : errmsg("16:Defekte Konfig Export-Datei angegeben"));
    }
    elseif($mode[8] and !$mode[10] and !$mode[11] and (preg_match($cfg['ptar'],$file,$val) and is_file($file) or is_dir($file))) {	// Converter-Modus Dir/Tar -> File
     $array = array();
     if($val)
      $array = ($val[4] and $data = file_contents($file)) ? zip2array($data,array(),array(),true) : tar2array($file);	// Archiv als Array einlesen
     else
      $array = $file;
     out($array ? (($data = cfgmake($array,$mode[9],$save)) ? ($save ? $data : cfginfo($data)) : errmsg("10:Kein Konfig Export-Archiv/Verzeichnis angegeben")) : errmsg(0,'tar2array'));
    }
    elseif($mode[8] and $mode[10] and !$mode[11] and $pass and $data = (preg_match($cfg['ptar'],$file,$var) or is_dir($file))
	? cfgmake($var ? ($var[4] ? zip2array(file_contents($file),array(),array(),1) : tar2array($file)) : $file) : file_contents($file)) {	// Kennwörter Entschlüsseln
     if(preg_match('/^\*{4} .*? CONFIGURATION EXPORT/',$data)) {
      foreach($pw as $pass) {
       if($fp = file_exists($pass) ? $cfg['zlib']['open']($pass,'r') : false) {	// Passwordliste einlesen
        $cfg['errmute'] = true;							// Fehlermeldungen pausieren
        $bug and dbug("Lese Password-Liste: $pass");
       }
       while($pwd = $fp ? $cfg['zlib']['gets']($fp,$cfg['sbuf']) : $pass)	// Password-Argument oder Passwordliste durchgehen
        if($pass = false or $pwd = preg_replace('/[\r\n]+$/','',$pwd)) {	// Password von cr/lf bereinigen
         $bug and dbug(".",0,10);
         if(isset($cfg['error']['cfgdecrypt']))					// Alte Fehlermeldung entfernen
          unset($cfg['error']['cfgdecrypt']);
         if($dcdata = cfgdecrypt($data,$pwd)) {					// Konfig mit Kennwort entschlüsseln
          $bug and dbug("\nKonfig-Kennwort gefunden: $pwd",0,8);
          if($save) {
           if(preg_match('/^(.*?)[\\\\\/]$/',$save,$var)) {			// Verzeichnis erstellen
            makedir($save);
            $mod = 1;
            $save = $var[1];
           }
           elseif(preg_match($cfg['ptar'],$save,$var))
            $mod = (($cfg['bzip'] and ifset($var[3])) ? 4 : (ifset($var[2]) ? 3 : 2));
           else {
            file_contents($save,$dcdata);					// Entschlüsselte Konfig sichern
            $mod = 0;
           }
          }
          else
           $mod = 0;
          out(cfginfo($dcdata,$mod,$save,showaccessdata($dcdata)));		// Daten als Text Präsentieren
          break;
         }
        }
       $bug and dbug("",0,8);
       if($fp)
        $cfg['zlib']['close']($fp);
      }
      $cfg['errmute'] = false;							// Fehlermeldungen pausieren
      if(!$dcdata)
       out(errmsg(0,'cfgdecrypt'));
     }
     else
      out(errmsg("10:Keine Konfig-Datei angegeben!"));
    }
    elseif($mode[8] and $mode[11] and is_file($file) and $pass = getArg('of',false,$pass))	// JSON Konverter (File -> File)
     if($data = file_contents($file) and $array = konfig2array($data))
      file_contents($pass,array2json($array,4));
     else
      out(errmsg("16:Keine Konfig-Datei"));
    else
     out(errmsg("10:Parameter-Ressourcen zu Konfig $mode[0] nicht gefunden oder nicht korrekt angegeben"));
   }
   else
    out(errmsg("2:Unbekannte Funktionsangabe für Konfig"));
  }
  elseif($val['kf']) {					// Komfort-Funktionen Schalten
   if(ifset($cfg['help']) or !getArg(true))
    out("$self [$cfg[fbhp]] [mode:Komfort|kf] <func> <cmd:an|on|aus|off|test> <id>\n
Funktionen: (func)\n{{{tt}
list ||Listet alle Komfortfunktionen auf, die geschaltet werden können
wlan |wifi |Das Haupt-WLAN an/abschalten
gast |guest |Das Gast-WLAN an/abschalten
wlan-wps |wifi-wps |WPS für das Haupt-WLAN auslösen
gast-wps |guest-wps |WPS für das Gast-WLAN auslösen
ruf |rules |Rufumleitungen an/abschalten
ab |tam |Anrufbeantworter an/abschalten
wecker |alarm |Weckruf an/abschalten}}".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self fritz.box kf list
$self $cfg[fbhp] komfort wlan aus
$self $cfg[fbhp] komfort gast-wps an
$self $cfg[fbhp] mode:komfort func:rufumleitung cmd:aus id:rul_4
$self $cfg[fbhp] komfort wecker test 2
$self $cfg[fbhp] komfort test alarm1
$self $cfg[fbhp] kf ab an 2
$self $cfg[fbhp] kf wecker aus 0" : "")."\n");
   elseif(login(false) >= 680 or getArg('-f')) {			// Parameter überprüfen
    $func = getArg('func','/^(?:
	(list)								# 1: list
	|(?:(wlan|wifi)	|(gast-?(?:wlan)?|(?:wifi)?guest))(-?wps)?	# 2: wlan, 3: gast, 4: wps
	|(ru(?:les)?|(?:an)?ruf(?:umleitung(?:en)?)?|calles)		# 5: Rufumleitung
	|(t?a[bm]|answer|anruf(?:beanworter)?|sprachbox|voicemail)	# 6: Anrufbeantworter
	|(weck(?:er|ruf)|alarms?))($)/ix');				# 7: Weckruf
    $do = getArg('cmd','/^(?:(an|ein|on)|(aus|off)|(test))($)/i');	// Befehl
    $id = getArg('id','/^(([a-z]+_?)?\d+|(guest_)?wlan(_wps)?)$/0');	// ID des Gerätes
    $fw = $cfg['fiwa'] < 720;						// Versionsweiche
    $bug and dbug(array('func' => $func, 'do' => $do, 'id' => $id),9);
    if($fw and ($func or $id and $do) or !$fw and $func) {		// Parameter-Check
     if($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {		// Login durchführen
      if($cfg['bsid'] or isset($cfg['auth']['BoxAdmin'])) {
       $page = $fw ? '/myfritz/areas/comfort.lua' : '/myfritz/api/data.lua';
       $cmd = $fw ? "ajax_id=".rand(1000,9999)."&sid=$sid&cmd=" : "sid=$sid&c=comfort&a=";
       $names = $fw
	? array('wlan' => 'WLAN', 'tam' => 'Anrufbeantworter', 'rule' => 'Rufumleitung', 'alarm' => 'Weckruf')
	: array('wifi' => 'WLAN', 'wifiGuest' => 'Gast-WLAN', 'rules' => 'Rufumleitungen', 'answeringMachines' => 'Anrufbeantworter', 'alarms' => 'Weckrufe');
       $out = array();
       if($func and $func[1]) {													// Liste anfordern
        if($fw and $data = request('POST',$page,$cmd."getData") and ifset($data,'/^\{.*\}$/') and $json = json2array($data)) {	// 6.80
         if(ifset($json['wlan']))
          foreach($json['wlan'] as $key => $var)
           $out['wlan'] = (isset($out['wlan']) ? $out['wlan'] : "ID |Name |Status\n")."$var[itemId] |$var[text] |"
		.(($var['state'] == 'on') ? " an" : "aus ")."\n";
         if(ifset($json['fon']))
          foreach($json['fon'] as $key => $var)
           if($var['type'] == 'tam')
            $out['tam'] = (isset($out['tam']) ? $out['tam'] : "ID |Name |Annahme |Status\n")
		."$var[itemId] |$var[text] |$var[details] |".(($var['state'] == 'on') ? " an" : "aus ")."\n";
           elseif($var['type'] == 'rule')
            $out['rule'] = (isset($out['rule']) ? $out['rule'] : "ID |Name |Umleiten |Ziel |Modus |Status\n")
		."$var[itemId] |$var[text] |".implode(" |",preg_replace('/^.*?: /u','',$var['details']))." |"
		.(($var['state'] == 'on') ? " an" : "aus ")."\n";
           elseif($var['type'] == 'alarm')
            $out['alarm'] = (isset($out['alarm']) ? $out['alarm'] : "ID |Name |Wiederholung |Weckzeit |Status\n")."$var[itemId] |$var[text] |$var[details] |"
		.preg_replace('/(\d\d)(\d\d)/','$1:$2',$var['time'])." |".(($var['state'] == 'on') ? " an" : "aus ")."\n";
         foreach($out as $key => $var)
          $out[$key] = $names[$key].":\n".textTable(out($var,9),0,"|","\n","|"," ");
        }
        elseif(!$fw and $data = request('GET',$page,$cmd."getData") and ifset($data,'/^\{.*\}$/') and $json = json2array($data)) { // 7.20
         ksort($json);
          $head = array('wifi' => 'Art |Status |Info', 'rules' => 'ID |Name |Umleiten |Ziel |Modus |Status', 'answeringMachines' => 'ID |Name |Annahme |Status', 'alarms' => 'ID |Name |Wiederholung |Weckzeit |Status');
         $out = array();
         foreach($json as $grp => $lst)
          if($lst)
           if($grp == 'wifi')
            $out[$grp] = "WLAN |".($lst['isEnabled'] ? " an" : "aus ")."|".(isset($lst['wps']) ? "WPS ist ".(ifset($lst['wps']['isDisabled']) ? "aus" : (ifset($lst['wps']['isActive']) ? "aktiv" : "verfügbar")) : "" );
           elseif($grp == 'wifiGuest')
            $out['wifi'] .= "\nGast-WLAN |".($lst['isEnabled'] ? " an" : ($lst['isDisabled'] ? "deaktiviert" : "aus "))."|"
		.($lst['remainingTime'] ? "bleibt noch $lst[remainingTime] Minuten an": "dauerhaft an");
           elseif($grp == 'rules') {
            $list = "";
            foreach($lst as $key => $var)
             if(isset($var['displayDescription']))
              $list .= "$var[id] |$var[displayDescription] |$var[divertionVia] |$var[destination] |$var[divertionInfo] |".($var['isEnabled'] ? " an" : "aus ")."\n";
            if($list)
             $out[$grp] = $list;
           }
           elseif($grp == 'answeringMachines') {
            $list = "";
            foreach($lst as $key => $var)
             $list .= " $var[id]|$var[name] |".($var['fetchCallTimeInSeconds'] ? "$var[fetchCallTimeInSeconds] Sek" : "Sofort")." |".($var['isEnabled'] ? " an" : "aus ")."\n";
            if($list)
             $out[$grp] = $list;
           }
           elseif($grp == 'alarms') {
            $list = "";
            foreach($lst as $key => $var)
             $list .= " $var[id]|$var[displayName] |".(($var['repetition'] == 'NONE') ? "Einmalig"
		: (($var['repetition'] == 'DAILY') ? "Täglich" : implode(', ',preg_array('/'.implode('|',array_keys(preg_array('/1/',$var['alarmDays'],2)))
		.'/',array('mon' => 'Mo', 'tue' => 'Di', 'wed' => 'Mi', 'thu' => 'Do', 'fri' => 'Fr', 'sat' => 'Sa', 'sun' => 'So'),3))))." |"
		.preg_replace('/\b\d\b/','0$0',$var['alarmTime']['hour'].":".$var['alarmTime']['minute'])." |".($var['isEnabled'] ? " an" : "aus ")."\n";
             if($list)
              $out[$grp] = $list;
           }
           else
            $bug and dbug(array($grp => $lst));
         foreach($out as $key => $var)
          $out[$key] = $names[$key].":\n".textTable(out($head[$key]."\n$var",9),0,"|","\n","|"," ");
        }
        else
         out(errmsg("16:Unbekannte Daten erhalten oder Komfort-Funktionen werden nicht unterstützt"));
        $bug and dbug($json,9);
        if($out)
         print implode("\n\n",$out)."\n";
       }
       elseif($do and $do[3])							// Test
        if($data = request('POST',$page,$cmd."getData") and ifset($data,'/^\{.*\}$/') and $json = json2array($data)) {
         $bug and dbug($json,9);
         if($fw) {
          if(!$id and ($func[1] or $func[2] or $func[3]))
           $id = $func[0];
          if($id)
           foreach($json as $grp => $itms) {
            if(is_array($itms))
             foreach($itms as $key => $var)
              if(is_array($var) and $var['itemId'] == $id) {
               $id = true;
               out(($var['state'] == "on") ? errmsg("1:'$var[text]' ist an bzw. aktiv") : "'$var[text]' ist aus");
               break 2;
              }
           }
         }
         elseif($list = ifset($json[$name = ($func[2] or $func[3] or $func[4]) ? "wifi".($func[3] ? "Guest" : "") : ($func[5] ? 'rules' : ($func[6] ? "answeringMachines" : ($func[7] ? "alarms" : false)))],true)) {
          if(substr($name,0,4) == 'wifi') {
           $list = array($list + array('id' => $func[0], 'name' => $name));
           $id = $func[0];
          }
          foreach($list as $key => $var)
           if($var['id'] == $id) {
            $id = true;
            if($val = preg_array('/^(display(Description|Name)|name)$/',$var,1))
             $name = $val;
            if(isset($names[$name]))
             $name = $names[$name];
            out($var['isEnabled'] ? errmsg("1:'$name' ist an bzw. aktiv") : "'$name' ist aus");
            break;
           }
         }
         if($id !== true)
          out(errmsg("8:".($id ? $id : (isset($names[$name]) ? $names[$name] : $name))." nicht gefunden"));
        }
        else
         out(errmsg("16:Unbekannte Daten erhalten oder Komfort-Funktionen werden nicht unterstützt"));
       elseif($do or $func[4]) {					// Schalten
        $cmd .= $fw ? "switchChange&itemId=" : "";
        if($func[2] or $func[3]) {					// WLAN
         $cmd .= $fw ? ($func[3] ? "guest_" : "")."wlan".($func[4] ? "_wps" : "") : ($func[4] ? "startWps" : "switchWifi")."&iface=".($func[2] ? "wifi" : "guest");
         if($fw and $func[4] and !$do)
          $do = array(1,1);
        }
        elseif(($fw or $do) and $id !== false) {			// ID
         $cmd .= $fw ? $id : "switch";
         if(!$fw)
          if($func[5])							// Rufumleitungen
           $cmd .= "Rule&rule=$id";
          elseif($func[6])						// Anrufbeantworter
           $cmd .= "AnsweringMachine&answeringMachine=$id";
          elseif($func[7])						// Wecker
           $cmd .= "Alarm&alarm=$id";
        }
        else {
         $cmd = false;
         out(errmsg("2:Keine ID angegeben"));
        }
        if($cmd) {
         $bug and dbug(array('cmd' => $cmd, 'do' => $do),9);
         $var = " nicht";
         if($fw) {
          if($data = request('POST',$page,$cmd."&cmdValue=".($do[1] ? 1 : 0)) and preg_match('/"status":"switchStateChangedSend"/',$data))
           $var = "";
         }
         elseif($data = request('GET',$page,$cmd.($do ? "&value=".($do[1] ? "true" : "false") : "")) and preg_match('/"successful":\b(true|1)\b/',$data))
          $var = "";
         out("Schaltvorgang wurde$var erfolgreich gesendet");
         $bug and dbug($data,9);
        }
       }
       else
        out(errmsg("2:Keinen Befehl zur Funktion angegeben"));
      }
      else
       out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
      if(!ifset($cfg['bsid']))						// Abmelden
       logout($sid);
     }
     else
      out(errmsg(0,'login'));						// Login fehlgeschlagen
    }
    else								// Parameter fehlen
     out(errmsg("2:Fehler: Parameter nicht korrekt übergeben!"));	// Fehlermeldung
   }
   else
    out(errmsg("64:Die Komfort-Funktionen benötigen mindestens Fritz!OS 6.80"));
  }
  elseif($val['led']) {					// LED
   if(!login(false,555))
    out(errmsg("64:Diese Funktion wird nicht von der Fritz!OS Firmware unterstützt!"));
   elseif(ifset($cfg['help']) or !$var = getArg('func','/(test)|(auto-?)?((off|aus)|(low|dunkel)|([oa]n|normal)|(high|hell)|(?<=auto))/i'))	// Hilfe Ausgeben
    out("$self [$cfg[fbhp]] [mode:LED] [func:auto|test|on|off|high|low|an|aus|hell|dunkel]".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:led func:off
$self $cfg[fbhp] led test
$self $cfg[fbhp] led auto-low
$self $cfg[fbhp] led hell
$self $cfg[fbhp] led auto-an" : "")."\n");
   elseif($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {			// Login durchführen
    if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
     if($var[1]) {									// LED Status Abfragen
      $bug and dbug("Ermittle LED-Status");
      if($val = request('GET','/query.lua',http_build_query(array(
	'sid' => $sid,
	'led' => 'box:settings/led_display'))) and $var = ifset($val,'/"led":\s*"(\d+)"/'))
       out($var[1] ? errmsg("1:LED ist aus") : "LED ist an");				// LED Status ausgeben
      else
       out(errmsg("64:LED-Status nicht ermittelbar!"));
     }
     elseif($var[2] or $var[3]) {
      $bug and dbug("Schalte LED a".($var[1] ? "n" : "us"));
      $led = array(ifset($var[4]) ? 2 : 0, ifset($var[2]) ? 1 : 0, ifset($var[5]) ? 1 : (ifset($var[7]) ? 3 : 2));
      if($cfg['fiwa'] > 715)
       request('POST','/data.lua',http_build_query(array(				// LED schalten: auto,off,low,on,high
	'sid' => $sid,
	'apply' => "",
	'page'=> 'led',
	'ledDisplay' => $led[0],
	'envLight' => $led[1],
	'dimValue' => $led[2])));
      else
       request('POST','/system/led_display.lua',http_build_query(array(			// LED schalten: an / aus
	'sid' => $sid,
	'apply' => "",
	'led_display' => $led[0])));
     }
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
    if(!ifset($cfg['bsid']))								// Abmelden
     logout($sid);
   }
   else
    out(errmsg(0,'login'));								// Login fehlgeschlagen
  }
  elseif($val['lio']) {					// Manuelles Login / Logout
   if(ifset($cfg['help'])) {
    out("$self <http://user:pass@fritz.box:port#passui> [mode:LogIn|LogOut|LogInTest|li|lo|lit] <file:SID> <-s:sid|file>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self https://user:pass@example.org:12345#password mode:login -o:sid
$self password@fritz.box login sid
$self login -o:sid -p:https -fb:example.org -li:1 -pt:12345 -un:user -pw:pass -ui:password
$self logintest -fb:{$qt}user:pass@example.org:12345#GOOGLETWOFACTORAUTHENTICATIONOTP$qt
$self $cfg[fbhp] login -pw:password -o:sid
$self $cfg[fbhp] logintest -s:sid
$self $cfg[fbhp] logout -s:0123456789abcdef
$self logintest -cc:/media/veracrypt1/Fritz!Box/fb_config.json -ps:meinebox
$self meinebox::$qt/media/veracrypt1/Fritz!Box/fb_config.json$qt logintest
$self logintest -fb:$qtmeinebox::/media/veracrypt1/Fritz!Box/fb_config.json$qt
$self https://max:headroom@0123456789abcdef.myfritz.net:12345#ABCDEFGHIJKLMNOPQRSTUVWXYZ234567 logintest -tf -d" : ""));
    if(!$cfg['help'] or $cfg['help'] === true)
     $cfg['help'] = -1;
   }
   elseif(preg_match('/^l(?:og)?(?:(in?)(-?t(?:est)?)?|(o(?:ut)?))($)/i',$val['lio'],$var)) {
    if($var[1] and !ifset($cfg['sid'])) {			// Login (User/Pass)
     if($cfg['dbug'] === true)
      $cfg['dbug'] = 513;
     $sid = login();
     if($var[2])						// Test
      if($sid) {
       logout($cfg['sid']);
       out(errmsg("1:Login war erfolgreich"));
      }
      else
       out(errmsg(0,"login"));
     else {							// SID-Modus
      if($sid and $file = getArg('file')) {
       file_contents($file,array2json(preg_array('/^(fiwa|host|port|sid|sock)$/',$cfg,3)));
       chmod($file,0600);					// SID-Datei ist Exclusiv für fb_Tools
      }
      out($sid ? $sid : errmsg(0,'login'));
     }
    }
    elseif(ifset($cfg['sid'])) {				// SID-Modus
     if($var[2])						// Test
      out(errmsg("1:Die SID ist gültig"));
     elseif($var[3]) {						// Logout
      logout($cfg['sid']);
      if($var = ifset($cfg['opts']['s'],"") and file_exists($var))// SID-Datei löschen
       unlink($var);
     }
     else							// SID ausgeben
      out(login(0,0,0,$cfg['sid']));
    }
   }
  }
  elseif($val['rc']) {					// ReConnect
   if(ifset($cfg['help'])) {
    out("$self <$cfg[fbhp]> [mode:ReConnect|rc]\n
Ab Fritz!OS 8.25 muss für den jeweiligen Host die UPnP-Rechte für das Neuverbinden gesetzt sein!
Ansonsten müssen Sie die Anmeldedaten mitangeben, um die API-Funktion zu nutzen!".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:reconnect -rc:upnp
$self user:pass@$cfg[fbhp] mode:reconnect -rc:api
$self $cfg[fbhp] rc" : ""));
    $opts .= "Reconnect:|-rc:|[UPnP\|API]|Reconnect zwingend über UPnP oder API durchführen";
   }
   elseif(getArg('-rc','/^upnp$/i') or !getArg('-rc','/^(web)?api$/i') and $cfg['host'] == 'fritz.box' and $cfg['pass'] == 'password' and !$cfg['user'])
    out(forcetermination() ? "Reconnect wurde über UPnP ausgeführt" : errmsg(0,'getexternalip'));
   elseif($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {	// Login durchführen
    if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
     out("Reconnect wird über WebAPI durchgeführt");
     if($cfg['fiwa'] >= 840) {
      $bug and dbug("Methode für Fritz!OS 8.40+");
      if($data = request('PUT',"/api/v0/generic/connections/connection/connection0001",array2json(array('cmd_disconnect' => 1)),array("AUTHORIZATION" => "AVM-SID $sid")))
       $bug and dbug(json2array($data));
     }
     elseif($cfg['fiwa'] >= 730) {
      $bug and dbug("Methode für Fritz!OS 7.30+");
      $data = request('POST',"/data.lua",http_build_query(array('sid' => $sid, 'page' => 'netMoni', 'xhrId' => 'reconnect', 'disconnect' => true, 'xhr' => 1)));
      if($var = json2array($data))
       $bug and dbug(json2array($data));
     }
     elseif($cfg['fiwa'] >= 600) {
      $bug and dbug("Methode für Fritz!OS 6+");
      $data = request('GET',"/internet/inetstat_monitor.lua",array(
	'sid' => $sid,
	'useajax' => 1,
	'myXhr' => 1,
	'action' => 'disconnect',
	'xhr' => 1));
      $bug and dbug($data);
     }
     elseif($cfg['fiwa'] >= 480) {
      $bug and dbug("Methode für Fritz!OS 4.80+");
      out(($data = request('POST',"/cgi-bin/webcm",http_build_query(array(
	'sid' => $sid,
	'connection0:settings/cmd_disconnect' => "")))) ? "Reconnect Anfrage gesendet" : errmsg(0,'request'));
     }
     else
      out(errmsg("64:Die Firmware unterstützt die Funktion leider nicht!"));
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für die Administration!"));
    if(!ifset($cfg['bsid']))						// Abmelden
     logout($sid);
   }
   else
    out(errmsg(0,'login'));						// Login fehlgeschlagen
  }
  elseif($val['sh']) {					// SmartHome
   $var = getArg('func','/(?:([ao]n)|(off|aus)|(um|switch|toggle|schalt)|(info|set|test)|(list|csv|json|xml)|(close|down|runter)|(open|up|rauf)|(stop|halt)|(array))($)/i');
   $set = array();	#    1	     2	       3			 4		 5		     6			 7		8	    9
   $ain = getArg('ain','/^[\w -]+$/0');						// Eindeutige Aktor/Template-ID
   $set['hkr'] = getArg('hkr','/^((([8-9]|1\d|2[0-8])(\.[50])?)°?C?|spar|komfort|[ao]n|aus|off)$/i0');	// Temperatur für Heizkörperregler
   $set['kelvin'] = getArg('kelvin','/^((2[789]|[345]\d|6[0-4])\d\d|6500)$/0');	// Farbtemperatur (2700-6500) für Lampe
   $set['dimm'] = getArg('dimm','/^1?\d?\d$/0');				// Helligkeit (0-100) für lampe
   $set['delay'] = getArg('delay','/^\d{1,8}$/0');				// Geschwindigkeit (?) der Änderung
   $set['hsv'] = getArg('hsv','/^([12]?\d?\d|3[0-5]\d)(\D1?\d?\d){0,2}$/0');	// Farbwinkel (0-359), Farbsättigung (0-100), Helligkeit (0-100) für Lampe
   if($val = getArg('color','/^[\w\s]+$/u0') or $val = getArg('color','/^[\w\söäüßÖÄÜ]+$/0'))	// Farbname für Lampe
    $set['color'] = preg_replace('/\s+/','',$val);
   $file = getArg('file');
   if(!login(false,669) and !getArg('-f'))
    out(errmsg("64:Diese Funktion wird nicht von der Fritz!OS Firmware unterstützt!"));
   elseif(ifset($cfg['help']) or !$var) {				// Hilfe Ausgeben
    out("$self [$cfg[fbhp]] [mode:SmartHome|sh] [func] <ain> <hkr|kelvin|dimm|hsv|color|file>\n
Funktionen (func):\n{{{tt}
list||-|Übersicht aller Aktoren ausgeben
close/down/runter|[ain:Aktor]|-|Rollläden schließen
csv|<file:Datei>|-|Übersicht aller Aktoren als CSV-Datei speichern
json|<file:Datei>|-|Vollständige Aktorenliste als JSON-Datei speichern
info|[ain:Aktor]|-|Informationen über Aktor ausgeben
on/an|[ain:Aktor]|-|Aktor einschalten
off/aus|[ain:Aktor]|-|Aktor ausschalten
open/up/rauf|[ain:Aktor]|-|Rollläden öffnen
stop/halt|[ain:Aktor]|-|Rollläden anhalten
um/switch/schalt|[ain:Aktor]|-|Aktor umschalten
test|[ain:Aktor]|-|Schaltzustand des Aktors abfragen
xml|<file:Datei>|-|Rohdaten als XML-Datei speichern
set|[ain:Aktor]||<ain\|color\|dimm\|hkr\|hsv\|kelvin>}}\n
Übergabe-Parameter für die SET Funktion:\n{{{tt}
Farblampe:|[color:|Farbname 1-3]|Farbangabe mit Sättigungsnummber|(3)
|[dimm:|0-100]|Helligkeit setzen|
|[hsv:|0-359,0-100,0-100]|Farbwinkel, Farbsättigung, Helligkeit|(2)
|[kelvin:|2700-6500]|Farbtemperatur in Kelvin|(2)
Heizregler:|[hkr:|8.0-28.0\|an\|aus\|komfort\|spar]|Temperatur setzen|(1)
Template:|[ain:|Template]|Aktor nach Vorgaben setzen}}
\n{{{tt}
(1) Temperatur auf 0.5° genau und änderungen dauern bis zu 15 Minuten
(2) Akzeptiert z.Z. nur Vorgabewerte - Alternativ [color] nutzen
(3) Verfügbare Farbwerte mit [func:info] abfragen}}".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:smarthome func:test ain:11:23:58:13:21:34
$self $cfg[fbhp] smarthome an Lampe
$self $cfg[fbhp] sh set 01234-0001234 23
$self $cfg[fbhp] sh json file.json" : "")."\n");
    if(!$cfg['help'] or $cfg['help'] === true)
     $cfg['help'] = -1;
    $opts .= "SmartHome:|-cs:|<Char>|CSV-Separator festlegen (;)
|-f||Aktor direkt per AIN Schalten (Nur für an/aus/schalt/set)";
   }
   elseif($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {	// Login durchführen
    if($cfg['bsid'] or isset($cfg['auth']['HomeAuto'])) {
     $val = strtolower($var[0]);
     if(ifset($var[5])) {						// list / csv / json / xml
      $set = array();
      if(ifset($val,'/csv|json|xml/')) {				// Dateiname für csv/json ermitteln
       if(!$file and $ain) {
        $file = $ain;
        $ain = false;
       }
       if($cs = getArg('-cs'))						// CSV-Separator festlegen
        $set['csv'] = strtr($cs,array('\t' => "\t"));
       if($data = smarthome($val,0,$set))
        if($file)
         out(file_contents($file,$data) ? "$file wurde erfolgreich gespeichert!" : errmsg("32:$file konnte nicht geschrieben werden!"));
        else
         echo utf8($data,1);
      }
      else
       if($data = smarthome($val,0,$set))
        print textTable(out(preg_replace('/\b((?<=aus|offline$)|(?=an|online$))/m',' ',$data),9))."\n";
       else
        out(errmsg(0,'smarthome'));
     }
     elseif(($var[1] or $var[2] or $var[3]) and $ain)			// on / off / switch
      out(($data = smarthome($var[1] ? 'on' : ($var[2] ? "off" : "trip"),$ain,getArg('-f'))) ? $data : errmsg(0,'smarthome'));
     elseif($var[4] and $ain)						// info / set / test
      out(($data = smarthome($val,$ain,($val == 'set' and getArg('-f')) ? true : $set)) ? "{{{tt}$data}}" : errmsg(0,'smarthome'));
     elseif(($var[6] or $var[7] or $var[8]) and $ain)			// Rollläden
      out($data = smarthome($var[6] ? 'close' : ($var[7] ? "open" : "stop"),$ain) ? $data : errmsg(0,'smarthome'));
     elseif($var[9])
      out(smarthome('array',$ain));
     else
      out(errmsg("2:Unbekannte Argumente angegeben!"));
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für SmartHome-Steuerung"));
    if(!ifset($cfg['bsid']))						// Abmelden
     logout($sid);
   }
   else
    out(errmsg(0,'login'));						// Login fehlgeschlagen
  }
  elseif($val['sd']) {					// Supportdaten
   if(ifset($cfg['help'])) {
    out("$self [$cfg[fbhp]] [mode:SupportDaten|sd] <file:Datei|Ordner|.> <func:ExTrakt|Datei>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:supportdaten file:support.txt func:extrakt
$self $cfg[fbhp] supportdaten . -tm
$self $cfg[fbhp] supportdaten sd-ordner extrakt -d
$self $cfg[fbhp] sd -pw:geheim
$self sd file:support.txt func:support.tar" : ""));
    if(!$cfg['help'] or $cfg['help'] === true)
     $cfg['help'] = -1;
    $opts .= "SupportDaten:|-tm:|<on/off>|Schaltet Telemetriedaten an/aus";
   }
   else {
    $file = getArg('file');
    $et = getArg('func');
    $mode = ($file and preg_match($cfg['ptar'],$file,$var)) ? (($cfg['bzip'] and ifset($var[3])) ? 3 : (ifset($var[2]) ? 2 : 1)) : 0;
    if(!$mode and $et and $file and makedir($file))			// Neues Verzeichniss erstellen
     $file = './';
    if(file_exists($file) and is_file($file) and $et and $data = file_contents($file))	// Converter-Modus ('file' -> 'func')
     out("\n".supportdataextrakt($data,($et and preg_match($cfg['ptar'],$et,$var)) ? (($cfg['bzip'] and ifset($var[3])) ? 3 : (ifset($var[2]) ? 2 : 1)) : 0,$et)."\n");
    elseif($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {
     if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
      $tm = ($var = getArg('-tm','/^(?:[ao](?:(n)|(us|ff)))?$/i') and (ifset($var[1]) or !ifset($var[2])));
      if(ifset($et,'/^(extra[ck]t|et)$/i') and $cfg['fiwa'] >= 630) {	// Extrakt
       $bug and dbug("Hole Support-Daten zum extrahieren");
       if($data = supportdata(0,$tm) and $text = supportdataextrakt($data[1],$mode,$file))
        out("\n$text\n");
       elseif($data[1])
        file_contents((!preg_match($cfg['ptar'],$file) and substr($file,-1) != '/') ? $file : ((preg_match('/filename=(["\']?)(.*?)\1/i',$data['Content-Disposition'],$var))
         ? preg_replace('/[?\\\\\/<*>:"]+/','_',$var[2]) : "Supportdaten.txt"),$data[1]);
      }
      elseif(supportdata($file ? $file : './',$tm))
       out("Supportdaten wurden erfolgreich gespeichert");
      else
       out(errmsg(0,'supportdata'));
     }
     else
      out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
     if(!ifset($cfg['bsid']))
      logout($sid);
    }
    else
     out(errmsg(0,'login'));
   }
  }
  elseif($val['ss']) {					// SystemStatus
   if(ifset($cfg['help'])) {
    out("$self <$cfg[fbhp]> [mode:SystemStatus|Status|ss] <file|code>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:systemstatus
$self $cfg[fbhp] status
$self mode:status file:'./system_status.html'
$self ss code:{$qt}FRITZ!Box Fon WLAN 7390-B-010203-040506-733454-124607-147902-840522-22574-avm-de$qt" : ""));
    if(!$cfg['help'] or $cfg['help'] === true)
     $cfg['help'] = -1;
    $opts .= "System-Status:|-rd:|<path>|Schreibt die RAW-Daten";
   }
   elseif($data = supportcode(($file = getArg('file','file_exists')) ? file_contents($file) : getArg('code'))) {
    out($data);
    if($path = getArg('-rd')) {				// RAW-Daten Speichern
     if(!is_bool($path))
      if(!file_exists($path))
       makedir($path);
      elseif(is_dir($path))
       chdir($path);
     file_contents("system_status.html",$cfg['body']);
    }
   }
   else
    out(errmsg(0,'supportcode'));
  }
  elseif($val['t']) {					// Traffic
   if(ifset($cfg['help']) /* or !getArg(true) */ )
    out("$self [$cfg[fbhp]] [mode:Traffic|t] <file:Datei.json>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiel:
$self $cfg[fbhp] mode:traffic
$self $cfg[fbhp] traffic /var/log/fb/counter-%F.json.gz
$self $cfg[fbhp] -c:none traffic php://stdout | jq" : ""));
   elseif($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {
    if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
     if($traffic = gettraffic()) {
      if($file = getArg('file'))			// Traffic-Daten als JSON-Datei speichern
       file_contents($file,array2json($traffic));
      $out = "| Verbindungen| Online| Ausgehend| Eingehend| Gesamt\n";
      foreach(array(
	'Today' => 'Heute',
	'Yesterday' => 'Gestern',
	'ThisWeek' => 'Diese Woche',
	'ThisMonth' => 'Dieser Monat',
	'LastMonth' => 'Letzter Monat') as $key => $var) {
       $val = $traffic[$key];
       $out .= "$var| ".number_format($val['connect'],0,',','.')
	."| ".number_format($val['time'] / 60,0,',','.').":".str_pad($val['time'] % 60,2,0,STR_PAD_LEFT)
	."| ".number_format($val['out'],0,',','.')
	."| ".number_format($val['in'],0,',','.')
	."| ".number_format($val['sum'],0,',','.')
	."\n";
      }
      if($out)
       out(textTable(out($out,9)));
      if(isset($traffic['Counter'])) {
       $out = "";
       $val = $traffic['Counter'];
       if(ifset($val['sum']) and ifset($val['max']))
        $out .= "Daten-Budget| ".number_format($val['sum'],0,',','.')." bytes von ".number_format($val['max'],0,',','.')." bytes\n";
       if(ifset($val['time']) and ifset($val['maxtime']))
        $out .= "Zeit-Budget| ".number_format($val['time'] / 60,0,',','.').":".str_pad($val['time'] % 60,2,0,STR_PAD_LEFT)
	." von ".number_format($val['maxtime'] / 60,0,',','.').":".str_pad($val['maxtime'] % 60,2,0,STR_PAD_LEFT)."\n";
       if($out)
        out("\n".textTable(out($out,9)));
      }
     }
     else
      out(errmsg(0,'gettraffic'));
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
    if(!ifset($cfg['bsid']))
     logout($sid);
   }
   else
    out(errmsg(0,'login'));
  }
  elseif($val['ut']) {					// UpTime
   if(ifset($cfg['help'])) {
    out("$self [$cfg[fbhp]] [mode:UpTime|ut]".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:uptime
$self $cfg[fbhp] ut
$self $cfg[fbhp] uptime -rd" : ""));
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "UpTime:|-ft:|[Strftime]|Eigenes Datumsformat ($cfg[fstr])
|-rd:|<file>|Gibt die RAW-Daten im JSON-Format aus oder erstellt eine JSON-Datei";
   }
   elseif($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login()) {	// Login durchführen
    if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
     if($time = getuptime($sid)) {
      $ftime = getArg('-ft');				// Benutzerdefiniertes Datum-Format
      if($raw = getArg('-rd') and $data = array2json(array_combine(array('days','hours','minutes','time','start'),$time))) {	// RAW-Daten im JSON-Format speichern
       if(is_bool($raw))
        out($data);
       elseif(!file_contents($raw,$data))
        out(errmsg('32:Datei konnte nicht geschrieben werden'));
      }
      else
       out($strftime(($ftime and !is_bool($ftime)) ? $ftime
	: "Startzeit: $cfg[fstr] oder aktiv seit ".preg_replace('/(\b0 \w+, )+|(\b1 \w+)[en]\b/','$2',"$time[0] Tage, $time[1] Stunden, $time[2] Minuten"),$time[4]));	// Ausgabe
      }
     else
      out(errmsg(0,'getuptime'));
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
    if(!ifset($cfg['bsid']))				// Abmelden
     logout($sid);
   }
   else
    out(errmsg(0,'login'));				// Login fehlgeschlagen
  }
  elseif($val['wh']) {					// Wahlhilfe
   if(ifset($cfg['help']) or !getArg(true))
    out("$self [$cfg[fbhp]] [mode:WahlHilfe|wh|Dial|d] [tel:Rufnummer] <fon:Telefon>\n
Telefon:
FON(1-3) | ISDN/DECT | ISDN(1-8) | DECT(1-6) | (Keine Unterstützung für IP-Telefone)\n
{{{tt}Wahl-Codes: (tel) |Beschreibung: |Wahl-Codes: (tel) |Beschreibung:
\$FON(1-3) |Analog-Telefon |\$Busy-on-Busy_(on/off) |Besetzt bei Besetzt
\$DECT(1-6)|DECT-Telefon |\$CallForward_(on/off) |Anbietervermittlung
\$ISDN(1-8) |ISDN-Telefon |\$CallThrough_(on/off) |Wahlregeln für CallThrough
\$VoIP(1-10) |IP-Telefon |\$FaxSwitch_(on/off) |Faxweiche
\$Broadcast |Rundruf |\$MWI_(on/off) |Message Waiting Indicator
\$WLAN_(on/off) |WLAN |\$NoiseReduction_(on/off) |Rauschunterdrückung
\$CAPI-over-TCP_(on/off) |Faxen über IP |\$ReCall_(on/off) |Rückruf für ISDN
\$CallMonitor_(on/off) |Anrufmonitor |\$Telnetd_(on/off) |Telnetd (Nur Fritz!OS 4/5)
\$Reset |Fritz!Box neustarten |\$FactoryReset |Fritz!Box auf Werkseinstellungen zurücksetzen}}\n
Ab OS 6.69 ist bei Telefonänderung eine Zwei-Faktor-Authentisierung erforderlich, falls aktiviert".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] mode:wahlhilfe tel:0123456789 fon:isdn/dect
$self $cfg[fbhp] dial $qt#96*7*$qt
$self $cfg[fbhp] wahlhilfe $qt\$wlan_aus$qt
$self $cfg[fbhp] wahlhilfe $qt\$CallMonitor_on$qt
$self $cfg[fbhp] wh $qt\$voip2$qt
$self $cfg[fbhp] wh ." : ""));
   elseif($tel = getArg('tel') and ($fon = getArg('fon') or 1))
    if($sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login(0,0,$tfa = $fon && getArg('-tf'))) {
     out(($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['Dial']))
	? (dial($tel,$fon,0,$tfa) ? "Rufnummer wurde gewählt" : errmsg(0,'dial'))
	: errmsg("8:Benutzer hat nicht das Recht für die Wahlhilfe"));
     if(!ifset($cfg['bsid']))
      logout($sid);
    }
    else
     out(errmsg(0,'login'));
   else
    out(errmsg("2:Keine Rufnummer übergeben"));
  }
  elseif((ifset($val['rp']) or ifset($val['tg'])) and ifset($cfg['a1st'])) {	// Test-Funktion
   if($val['rp'])					// Test RP
    out(($pass = getArg('pass','/^\w+$/0')) ? ($val = getupnppath('LANConfigSecurity')) ? (($val = upnprequest($val[1],$val[0],'ResetWebUi',$pass)) ? $val : errmsg("64:Fehlgeschlagen!"))
	: str_rot13($cfg['a1st'][4]) : "$self ".$cfg['a1st'][2].(ifset($cfg['help'],'/[ab]/i') ? "\n\nBeispiele:\n$self $cfg[fbhp] rp sonnig1337" : ""));
   elseif($val['tg'])					// Test TG
    if((float)phpversion() >= 5.12) {
     if($mac = getArg('maca','/^[\da-f]{2}(?:[:-][\da-f]{2}){5}$/i0') and $a = ifset($cfg['a1st'][0],'/T\w+(?=\s)/')) {
      out($a[0],2);
      for($a=0, $b=2, $c=str_rot13('fyrrc'), $time = intval(time() / 30), $data = unbase(strtolower($mac),"0123456789abcdef"); $a < 10; $a++) {
       call_user_func($c,$a);
       $hash = hash_hmac('SHA1',str_pad(pack('N*',$time + $a),8,"\0",STR_PAD_LEFT),$data,true);
       $var = unpack('N',substr($hash,ord(substr($hash,-1)) & 15, 4));
       out(((($b = ($b + 13 < $cfg['wrap']) ? $b + 8 : 10) == 10) ? ($a ? str_pad("\n",$b," ") : ": ") : ", ")
	.str_pad(($var[1] & (1 << 31) - 1) % 1e6,6,0,STR_PAD_LEFT),2);
      }
      out("\n\n".str_rot13($cfg['a1st'][4]));
     }
     else
     out("$self ".$cfg['a1st'][3].(ifset($cfg['help'],'/[ab]/i') ? "\n\nBeispiele:\n$self [$cfg[fbhp]] tg 04:08:15:16:23:42" : ""));
    }
    else
     out(errmsg("64:Es wird mindestens PHP 5.1.2 benötigt"));
  }
  elseif($val['pi'] and !$cfg['help'] and ifset($cfg['uplink'],5) and $mode = getArg('func',$preg = '/^(?:(?P<c>check|c)|(?P<i>i(?:nstall)?)|(?P<l>liste?|l)|(?P<u>update|ud))$/i')) { // Plugin Update(1)
   if($cfg['sock'] == 'auto' and !$cfg['ssl'])			// SSL Laden
    $cfg['ssl'] = init(5,'openssl');
   if($array = getArg('opt',$preg))				// Mode durch zweiten Parameter erweitern
    foreach($array as $key => $var)
     if($var and !ifset($mode[$key]))
      $mode[$key] = $var;
   $plug = ($var = getArg('plug',"/^($cfg[fbtm]|[\w-]+)$/0")) ? "/$var/i" : false;
   foreach($cfg['uplink']['port'] as $port)			// MD5-Liste für Plugins anfordern
    if($fbnet = request('GET-array',$cfg['uplink']['path'].$cfg['uplink']['fbtp'].".md5",0,0,$cfg['uplink']['host'],$port)) {
     if($var = ifset($fbnet['Location'],'/^(https?:)(\/\/.+)$/'))
      $fbnet = request("$var[1][array]$var[2]");
     break;
    }
   if($fbnet and (ifset($fbnet['Content-MD5'],"/^(".preg_quote(base64_encode($var = hash('md5',$fbnet[1],true)),'/')."|".bin2hex($var).")$/") or getArg('-f'))
	and preg_match("/((\d\d)\.(\d\d)\.(\d{4}))\s([\d:]+)\s*\(([\w.-]+)\)/s",$fbnet[1],$up)	// Datum und Archivname
	and preg_match_all('/^(\w+)\s+([\d.]+)\s+\*([\w.-]+)\s*$/m',$fbnet[1],$list)) {	// MD5, Version und Pluginname
    $usrid = ifset($fbnet['X-Usrid']) ? preg_replace('/^0+/','',bin2hex(base64_decode($fbnet['X-Usrid']))) : false;
    if(ifset($mode['l']))					// Mode: List
     out($fbnet[1]);
    else {
     if((array)$pi = listDir($cfg['fbtg'],$cfg['fbta'],4))
      $pi = array_keys($pi);
     $out = $files = $install = $filter = $update = array();
     foreach($list[3] as $key => $val)				// Plugins-Liste mit Lokalen Verzeichnis abgleichen
      if($file = preg_array('/'.preg_quote($val,'/').'$/',$pi,2))
       $files = array_merge($files,$file);
      else
       $install[] = array('name' => $val, 'version' => $list[2][$key], 'hash' => $list[1][$key]);
     foreach($files as $key => $file)				// Von vorhandenen Plugins alle Daten zusammensuchen
      if($data = file_contents($file) and preg_match('/\$plugin\s*=\s*([\'"])(.*?)\1;[^$]*(?:\$info\s*=\s*([\'"])(.*?)\3;)?/',$data,$match)) {
       $name = preg_replace("/.*?$cfg[fbtm]$/",'$1',$file);
       $data = (preg_match('/^.*?('.preg_quote($name,'/').')\s([\d.]+)\s+(.*)$/i',$match[2],$var))
	? array('name' => $var[1], 'version' => (float)$var[2], 'copyright' => $var[3]) : false;
       $update = (($var = preg_array('/'.preg_quote($name,'/').'/',$list[3],4)) !== false) ? array('version' => (float)$list[2][$var], 'hash' => $list[1][$var]) : false;
       $files[$key] = array('name' => $name, 'file' => basename($file), 'filename' => $file, 'plugin' => $match[2], 'info' => $match[4], 'data' => $data,
	'hash' => md5_file($file), 'update' => $update);
      }
     foreach($files as $key => $data) {				// Lokale Plugins mit Update-Liste vergleichen und Updates anzeigen
      if(ifset($data['data']['version']) and ifset($data['update']['version']) and $data['data']['version'] < $data['update']['version'])
       $update[$key] = 1;
      elseif(ifset($data['hash']) and ifset($data['update']['hash']) and $data['hash'] != $data['update']['hash'])
       $update[$key] = getArg('-f') ? 0 : 2;			// Mit -f die Warnung für veränderung ignorieren!
      if(ifset($update[$key])) {				// Veränderungen ausgeben
       if($update[$key])
        $filter[$key] = $data['file'];				// Preg-Filter mit dem Dateinamen
       $out[$data['name']] = ($update[$key] == 1) 		// Update auflisten
	? "Update: ".number_format($data['data']['version'],2)." -> ".number_format($data['update']['version'],2)	// Normale Änderung
	: "Plugin wurde verändert";
      }
     }
     foreach($install as $file) {				// Neue (nicht installierte) Plugins anzeigen
      $out[preg_replace("/^$cfg[fbtm]$/",'$1',$file['name'])] = "NEU: ".number_format($file['version'],2);
      if(ifset($mode['i']))
       $filter[] = $file['name'];				// Preg-Filter mit dem Dateinamen
     }
     if($out) {							// Updates ausgeben
      $max = max(array_map('strlen',array_keys($out))) + 1;
      out(errmsg("1:Es sind Updates/Plugins verfügbar:"));
      foreach($out as $key => $var)
       out(str_pad($key,$max,' ').$var);
      if(!ifset($mode['c']) and $filter and (!$plug or preg_array($plug,$filter))) {	// Update/Install durchführen
       out("\nInstalliere/Aktualisiere Plugins...");
       foreach($cfg['uplink']['port'] as $port)
        if($tgz = request('GET-array',$cfg['uplink']['path']."$up[6]?$usrid",0,0,$cfg['uplink']['host'],$port))	// Tar-Archiv holen
         break;
       foreach($filter as $key => $var)
        $filter[$key] = preg_quote($var,'/');
       if($tgz and ifset($tgz['Content-MD5'],"/^(".preg_quote(base64_encode($var = hash('md5',$tgz[1],true)),'/')."|".bin2hex($var).")$/")
	and $tgz = datatar2array($cfg['zlib']['decode']($tgz[1]),'/('.implode('|',$filter).')$/')) {	// Tar-Archiv in Array entpacken
        if(ifset($mode['u'])) {					// Mode: Update
         foreach($update as $key => $file) {
          if($file and file_exists($files[$key]['filename']) and ifset($tgz[$files[$key]['file']]) and (!$plug or preg_match($plug,$file))) {
           if(hash('md5',$tgz[$files[$key]['file']]['data']) == $files[$key]['update']['hash'] or getArg('-f')) {
            if(!getArg('-ow')) {				// -ow für Überschreiben abfragen
             $bug and dbug("Sichere: ".$files[$key]['file']);
             if(file_exists($rename = preg_replace('/(\.\w+)$/','_'.number_format($files[$key]['data']['version'],2).'$1.bak',$files[$key]['filename'])))
              $rename = preg_replace('/(\.\w+)$/','_'.time().'$1',$rename);
             @rename($files[$key]['filename'],$rename);
            }
            else
             $bug and dbug("Überschreibe: ".$files[$key]['file']);
            out("Update: ".$files[$key]['file']." ... ",2);
            out(file_contents($files[$key]['filename'],$tgz[$files[$key]['file']]['data']) ? "erfolgreich" : errmsg("32:fehlgeschlagen"));
           }
           else
            out(errmsg("16:Fehler: ".$files[$key]['file']." ist defekt oder verändert worden!"));
          }
         }
        }
        if(ifset($mode['i']) and $install) {			// Neue Plugins installieren
         foreach(array_reverse($cfg['fbta']) as $var)		// Plugin-Ordner suchen
          if(file_exists($var) and is_dir($var)) {
           $path = $var;
           break;
          }
         $bug and dbug("Benutze Plugin-Ordner: $path");
         foreach($install as $file)				// Plugins aus Tar-Archiv installieren
          if(!$plug or preg_match($plug,$file['name']))
           if((hash('md5',$tgz[$file['name']]['data']) == $file['hash'] or getArg('-f'))) {
            out("Installiere: $file[name] ... ",2);
            out(file_contents("$path/$file[name]",$tgz[$file['name']]['data']) ? "erfolgreich" : errmsg("32:fehlgeschlagen"));
           }
           else
            out(errmsg("16:Fehler: $file[name] ist defekt oder verändert worden!"));
        }
       }
       else
        out(errmsg("16:Plugin-Archiv ist fehlerhaft!"));
      }
     }
     else
      out("Keine neuen Updates verfügbar!");
    }
    if($cfg['coki'] and ifset($fbnet['X-Cookie']))		// Coolen Spruch ausgeben
     out("\n".$fbnet['X-Cookie']);
   }
   else
    out(errmsg("64:Update-Server sagt NEIN!"));
  }
  elseif(($val['pi'] or $val['pe']) and $file = getArg('plug','is_file') or $data = listDir("/$cfg[fbtm]\s*$/i",$cfg['fbta'],1)	// Plugin Exec(2)
	and ($val['pit'] and $file = preg_array('/'.preg_quote($val['pit'],'/').'/i',$data)
	or $var = getArg('plug') and $file = preg_array('/'.preg_quote($var,'/').'/i',$data))) {
   $plug = preg_replace("!^.*?$cfg[fbtm]$!",'$1',$file);
   $err = "";
   if($var = file_contents($file) and preg_match('/\$meta\s*=\s*\'(\{(?:[^"\n]+|(?<!\\\\)")+\})\';/',$var,$var)
	and $splug = json2array($var[1])) {	// JSON Plugininfo lesen
    if(ifset($splug['php']) and (float)phpversion() < (float)$splug['php'])
     $err = "benötigt mindestens PHP $splug[php]!";
    elseif(ifset($splug['fbt']) and $cfg['ver'][10] < (float)$splug['fbt'])
     $err = "benötigt mindestens fb_Tools $splug[fbt] oder neuer!";
    elseif(ifset($splug['fos']) and ($val = (int)login(false)) !== 100 and $val < ($var = (int)preg_replace('/^0*(\d+)\.?(\d\d)\d*$/','$1$2',"$splug[fos]00")))
     $err = "benötigt mindestens Fritz!OS ".preg_replace('/(?=\d\d$)/','.',$var)." oder neuer!";
    elseif(ifset($splug['ssl']) and (!init(5,'openssl') or $cfg['osn'] < $splug['ssl']))
     $err = "benötigt mindestens OpenSSL $splug[ssl] oder neuer!";
   }
   else
    $splug = array();
   if($err and !getArg('-f'))
    out(errmsg("16:".ucfirst($plug)." $err"));
   else {
    if($err)
     out(errmsg("1:".ucfirst($plug)." $err"));
    if(isset($cfg['plugin'][$var = strtolower($plug)]) and is_array($cfg['plugin'][$var])) {	// Gibt es Voreinstellungen
     $bug and dbug("Lade Pluginvoreinstellungen");
     extract($cfg['plugin'][$var]);		// Konfiguration bereitstellen
    }
    unset($cfg['plugin']);			// Alle anderen Voreinstellungen löschen!
    $var = "<mode:PlugIn|exec> [plug:$plug]";	// Die Help-Variable berechnen
    for($a = 0; $a < 3; $a++) {
     $splug[$a] = "$self ";
     if($a)
      $splug[$a] .= (substr($cfg['fbhp'],0,4) != '-fb:') ? ($a%2 ? "<" : "[").$cfg['fbhp'].($a%2 ? ">" : "]")." " : "$cfg[fbhp] ";
     $splug[$a] .= $var;
    }
    include_once $file;				// Plugin ausführen
   }
   if(ifset($cfg['error']) and !ifset($cfg['error']['main']))	// Nur fehler ausgeben, wenn es noch keine Fehlermeldung gab
    out(errmsg());
  }
  elseif($val['pi'] or $val['pe']) {			// Plugin Liste(3)
   $var = ifset($cfg['uplink']) ? array("|opt:Check|Install|List|UpDate","
$self plugin update list
$self plugin update check
$self plugin update -ow
$self plugin install update
$self plugin install konfigdecrypt") : array(":list","");
   if($val['pe'])
    out("$self <fritz.box> <mode:exec|PluginExec|pe> [plug:Plugin|Script-Datei] <...>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self fritz.box pluginexec fbtp_test.php Foo Bar
$self plugin plug:test
$self exec fbtp_test.php
$self test {$qt}Hello World$qt" : ""));
   else
    out("$self <fritz.box> <mode:PluginExec|pe> [plug:Plugin|Script-Datei] <...>
$self [mode:PlugIn|pi] [func$var[0]] <plug:Plugin>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self fritz.box pluginexec fbtp_test.php Foo Bar
$self test {$qt}Hello World$qt
$self plugin$var[1]
$self exec fbtp_test.php" : ""));
   if(!$cfg['help'] or $cfg['help'] === true) {
    $cfg['help'] = -1;
    $opts .= "PlugIn:|-em||Erweiterte Meta-Daten Auflisten
|-pp:|[Path]|Alternativen Plugin-Path setzen";
    if($array = listDir("/$cfg[fbtm]\s*$/i",array_merge($cfg['fbta'],array(str_replace('\\','/',(file_exists($file) and is_dir($file)) ? preg_replace('![\\\\/]+$!','',$file) : "."))),5)) {
     $plugins = "";
     if(ifset($cfg['os'],'/^(winnt|darwin)/i'))			// Gross/Kleinschreibung bei Windows ignorieren
      $array = array_unique($array);
     natcasesort($array);
     $em = getArg('-em');
     foreach($array as $file => $v)
      if($data = file_contents($file) and preg_match('/\$plugin\s*=\s*([\'"])(.*?(?:('.preg_quote(preg_match("/$cfg[fbtm]\s*$/i",$file,$var) ? $var[1]
	: basename($file),'/').')\s+([\d.]+)\s+).*?(?:((?:0[1-9]|[12]\d|3[01])\.(?:0[1-9]|1[012])\.2[01]\d\d).*?)?)\1;[^$]*(?:\$info\s*=\s*([\'"])(.*?)\6;)?(?:\s*\$meta\s*=\s*\'(\{(?:[^"\n]+|(?<!\\\\)")+\})\';)?/i',$data,$var)
	and $data = preg_replace('/\|/','\|',$var)) {
       $data[8] = ifset($data[8]) ? json2array($data[8]) : array();
       $plugins .= "$data[3]|$data[4]".($em
	? date('|d.m.y',$data[5] ? strtotime($data[5]) : filemtime($file))
	."|".(isset($data[8]['php']) ? number_format($data[8]['php'],1) : "-")
	."|".(isset($data[8]['fbt']) ? number_format($data[8]['fbt'],2) : "-")
	."|".(isset($data[8]['fos']) ? number_format($data[8]['fos'],2) : "-")
	."|".(isset($data[8]['ssl']) ? number_format($data[8]['ssl'],1) : "-") : "")."|$data[7]\n";
      }
     out($plugins ? "\nVorhandene Plugins: (WARNUNG: Es gibt KEINE Prüfung auf Malware!)\n\n{{{tt}Plugin|Version".($em ? "|Datum|PHP|fbT|F!OS|SSL" : "")."|Beschreibung\n$plugins}}\n" : errmsg("8:Keine gültigen Plugins gefunden!"),2);
    }
    else
     out(errmsg("8:Keine Plugins gefunden!"));
   }
   else {
    if(ifset($cfg['uplink']))
     $opts .= "Update:|-f||Force - Fehler Ignorieren\n|-ow||Dateien überschreiben";
    if($cfg['help'] === true)
     $cfg['help'] = -1;
   }
  }
  else	// Möglichweise ist ein unbekannter und unerwarterer, sowie mysteriöser Layer-8 Problem aufgetreten ;-)
   out(errmsg("10:\"$val[0]\": Unbekannter Befehl oder Plugin nicht gefunden\nEine Hilfe erhalten Sie mit $self -h"));
 }
 elseif($cfg['dbug']%2)					// DEBUG: $argv & $cfg ausgeben
  $bug and dbug(compact(explode(',','argv,cfg')));
 else {							// Hilfe ausgeben
  $_help = out(getArg('-version') ? $ver : "$self <http://user:pass@fritz.box:port#otp> [mode] <Parameter> ... <Option>".(ifset($cfg['help']) ? "\n
Modes (mode):\n{{{tt}
AnrufListe|-|Anrufliste abrufen/mit Datei Syncronisieren(2)
BoxInfo|-|Modell, Firmware-Version und MAC-Adresse ausgeben
Ereignisse|-|Systemmeldungen abrufen/mit Datei Syncronisieren(2)
GetIP|-|Aktuelle externe IPv4-Adresse ausgeben(1)
Info|-|FB-Tools/PHP Version, Terminal infos, Update/Prüfen(3)
KomFort|-|Verschiedene Komfortfunktionen für WLAN/Telefonie Schalten(2)
Konfig|-|Einstellungen Ex/Importieren, Daten entschlüsseln(2,3,4,5)
LED|-|LED an/ausschalten oder Status abfragen(2)
LogIn/LogOut|-|Manuelles Einloggen für Scriptdateien(2)
PlugIn|-|Weitere Funktion per Plugin-Script einbinden
ReConnect|-|Neueinwahl ins Internet(1,2)
SmartHome|-|Aktoren schalten und auslesen(2)
SupportDaten|-|AVM-Supportdaten Speichern(2)
SystemStatus|-|Modell, Version, Laufzeiten, Neustarts und Status ausgeben(3)
UpTime|-|Betriebszeit seit dem letzten Neustart ausgeben(2)
Traffic|-|Trafficzähler ausgeben(2)
WahlHilfe/Dial|-|Rufnummer wählen(2,5)".($cfg['a1st'] ? $cfg['a1st'][0] : "")."}}

{{{tt}(1)|Aktiviertes UPnP erforderlich (Nicht über https nutzbar)
(2)|Anmeldung mit Logindaten erforderlich
(3)|Teilweise ohne Fritz!Box nutzbar
(4)|OpenSSL, MCrypt oder Aes.php nötig
(5)|Ab OS 6.69 ist beim Login eine Zwei-Faktor-Authentisierung erforderlich, falls aktiviert}}
[ ] Pflicht / < > Optional".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self mode:getip filter:ipv4
$self secret@fritz.box supportdaten
$self -fb:{$qt}hans:geheim@$cfg[host]$qt konfig export
$self http://secret@169.254.1.1 Ereignisse -w:80 -c:utf8 -o:file.txt
$self myfritz komfort AB an tam0
$self 7500 logintest -d
$self https://max:headroom@0123456789abcdef.myfritz.net:12345#ABCDEFGHIJKLMNOPQRSTUVWXYZ234567 konfig export-decrypt of:fb.export -d
$self -fb:192.168.178.1 AnrufListe /var/log/fb_call_%F.log -lf
$self wahlhilfe $qt**51$qt -fb:fritz.box -un:max -pw:geheim
$self $cfg[fbhp] led off -pw:secret
$self info
$self --help:a": "") : "\n\nWeitere Hilfe bekommen Sie mit --help oder mehr Hilfe mit -h:all"));
 }
 if($cfg['help']) {					// Weitere Hilfe ausgeben
  if((ifset($cfg['help'],'/k/i') or $cfg['help'] == -1) and ifset($opts))
   out("\nKontext-Optionen:\n{{{tt,0,|,\n, ;; ;, }$opts}}");
  elseif(ifset($cfg['help'],'/[ao]/i'))			// Optionen ausgeben
   out("\nAlle Optionen:\n{{{tt,0,|,\n, ;; ;, }
|-d||Debuginfos
|-h:|<a\|b\|o\|k\|s>|Hilfe (Alles, Beispiele, Optionen, Kontext, Standard)
|-cm||Cron-Modus (Sicherheits-Modus bei Admin-Rechten)".($cfg['cron'] ? " ($cfg[cron])" : "")."
|-nc||Keine X-Cookies anzeigen
|-nu||Keine Update-Prüfung".(($cfg['upda'] > 0) ? " (Alle ".floor($cfg['upda']/864e2)." Tage)" : "")."
|-uc|<Konfig-Name>|Name der Benutzer-Konfig".($cfg['usrcfg'] ? " ($cfg[usrcfg])" : "")."
Console:|-c:|[CodePage]|Kodierung der Umlaute ({$cfg['char'][0]})
|-w:|[Breite]|Wortumbruch ($cfg[wrap])
|-o:|[Datei]|RAW-Ausgabe an Datei anhängen
Login:|-p:|[Protokoll]|Protokoll ($cfg[sock])
|-s:|[SID\|Datei]|Manuelle SID Angabe (Für Scriptdateien)
|-u:|[Port]|UPnP-Ports ({$cfg['upnp'][0]},{$cfg['upnp'][1]})
|-cc:|[ConfigFile]|Lädt eine Benutzerkonfig-Datei nach
|-fb:|[Host]|Fritz!Box Angabe ($cfg[host])
|-fw:|[Version]|Manuelle Angabe der Firmware-Version ($cfg[fiwa])
|-li:|[Version]|Manuelle Angabe der Login-Version ($cfg[livs])
|-pt:|[Port]|Port Angabe ($cfg[port])
|-ps:|[Name]|Fritz!Box Angaben aus Preset von -cc:file auswählen
|-pw:|[Pass]|Kennwort Angabe
|-ui:|[Pass]|Anmeldekennwort (Bei Fernwartung)
|-tf:|<TOTP>|Zwei-Faktor-Authentisierung (2FA)
|-ts:|[time]|Uhrzeit für 2FA festlegen (".$strftime($cfg['fstr'],intval($cfg['time'])).")
|-un:|[User]|Benutzername Angabe".($cfg['user'] ? " ($cfg[user])" : "")."
Request:|-b:|[Bytes]|Buffergröße ($cfg[sbuf])
|-px:|[Proxy:Port]|HTTP-Proxy (".($cfg['proxy'] ? $cfg['proxy'] : "-").")
|-t:|[Sekunden]|TCP/IP Timeout ($cfg[tout])
|-ua:|[String]|User-Agent (".preg_replace('/\s.*$/',' ...',$cfg['head']['User-Agent']).")
Dateien:|-bz:|[Level]|ZIP Packstufe für BZip2-Mode festlegen ($cfg[bz])
|-gz:|[Level]|zlib/GZip/ZIP Packstufe festlegen ({$cfg['zlib']['mode']})
|-zb:|[Bits]|ZIP-Verschlüsselungsbits setzen".(ifset($cfg['zb']) ? " ($cfg[zb])" : "")."
|-zp:|[Pass]|ZIP-Verschlüsselungskennwort setzen
Datum:|-ot||StrfTime vom Betriebssystem nutzen (Wenn noch vorhanden)
JSON:|-oj:|<0-2>|Originale JSON_Encode nutzen ($cfg[json])
PHP:|-pe:|[Extension]|Lädt ohne rückfrage eine PHP-Erweiterung nach".((ifset($opts) ? "\n$opts" : ""))."}}");
  elseif($cfg['help'] === true and !ifset($cfg['arg']) or $cfg['help'] === -1)
   out("\nMehr Hilfe bekommen Sie mit -h:a (Alles) -h:b (Beispiele) -h:k (Kontext) -h:o (Optionen)
Jede Funktion (mode) hat eine eigene Hilfe und bei bedarf Kontextabhängige Optionen");
  if(ifset($_help))
   out("\nEine Anleitung finden Sie auf ".preg_replace('/(?<=\/)www\./','',$cfg['ver'][7]).$cfg['ver'][8]);
 }
 if(ifset($cfg['error'])) {				// Wenn Fehler aufgetreten sind
  if($bug)
   dbug("Fehler:\n".print_r($cfg['error'],true));	// Fehler bei -d ausgeben
  $err = 0;						// Nach Error-Codes suchen
  if(isset($cfg['error']['main']))
   foreach($cfg['error']['main'] as $var)
    if(preg_match('/^(\d+):/',$var,$m) and $e = intval($m[1]))
     $err = ($e & 128) ? max($err,$e) : $err | $e;	// Error-Code berechnen
  if(preg_array('/^1:/',$cfg['error'],18))		// Nach Infos oder Hinweisen suchen
   $err |= 1;
  if($err and $bug) {					// Error-Code vorhanden
   $msg = array();
   $bit = 1;
   foreach(json2array('[
	"Info/Hinweis oder Warnung",							# 0: 1
	"Ungültige Parameter",								# 1: 2
	"Login Fehlgeschlagen (Falsches Kennwort)",					# 2: 4
	"Ressource nicht gefunden/erhalten/verfügbar (Ladefehler/Keine Berechtigung)",	# 3: 8
	"Falsche/defekte/ungültige Ressource",						# 4: 16
	"Schreibfehler (Kein Platz/Schreibberechtigung)",				# 5: 32
	"Prozedur auf Ressource nicht möglich"]') as $var)				# 6: 64
    if($err & ($bit *= 2) / 2)
     $msg[] = $var;
   dbug("{{{tt}Error-Code: | $err".($msg ? "|".implode(", ",$msg) : "")." }}");	// Error-Code ausgeben
  }
  if($err)
   exit($err);						// PHP mit Error-Code beenden
 }
}
?>
