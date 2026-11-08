<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "KonfigHacker 0.10 (c) 16.09.2026 by Michael Engelke";
 $info = 'Konfig-Key per Bruteforce knacken';
 $meta = '{fbt:0.46,ssl:1.0,php:5.4}'; /*

Plugingeschichte:
0.00 16.09.2019
 - Erste Test-Version (POC)
 - Danke an SM vom CERN (Unmöglich ist es erst, wenn es bewiesen wurde)
0.01 22.09.2019
 - Erste vollständige Version
0.02 05.11.2020
 - Unterstützung für BZip Dateien
 - Unterstützung von Arrays in Optionen
 - Benötigt zwingend fb_Tools 0.28+
0.03 23.03.2021
 - AVM MAC-Adressen erweitert
 - Anpassung an fb_Tools 0.30+
0.04 01.12.2022
 - AVM MAC-Adressen erweitert
 - Minimale Optimierungen vorgenommen
 - Das auffinden von alten MAC-Adressen etwas beschleunigt
0.05 27.12.2023
 - BUG: Im MAC-Modus funktionierte die Fortschrittsanzeige nicht
0.06 05.05.2024
 - Hilfe verbessert
0.07 19.09.2024
 - Benötigt jetzt zwingend fb_Tools 0.41+
 - Folgende neue Parameter eingebaut:
   try: für BruteForce chars,min-max,marker
   set: das Startpassword setzen
   dot: Nach wievielen versuchen ein Dot ausgegeben wird
   interim: Nach wievielen versuchen eine Statistik  ausgegeben wird
0.08 23.03.2025
 - AVM MAC-Adressen erweitert
 - Anpassung an fb_Tools 0.46+
0.09 18.08.2025
 - Division by Zero im Zwischenbericht entfernt
0.10 16.09.2026
 - NEU: Parameter crypt erlaubt jetzt auch Dateiname auf die Konfig-Datei
 - NEU: Option -sp erlaubt das vertauschen der Kennwörter von Parameter pass (mit Optionalen Separator)
 - Änderung: Die PHP/OpenSSL-Anforderungen erhöht
 - Der Try-Parameter erlaubt nun auch mindestlänge = 0 und kann auch als Array übergeben werden
 - Hauptschleife etwas optimiert
 - AVM Mac-Adressen erweitert
*/
 function bfnxt($pw="") {					// Kennwort mit BruceForce erweitern
  global $cfg,$bf,$strftime,$bug;		// Interne Variablen verfügbara machen
  if(!$bf or $pw === false)
   return false;
  elseif(!$bf['pass']) {			// Erster Aufruf
   if($bf['min'] or $bf['last'] !== false) {
    $bf['pass'] = array_fill(0,max(1,$bf['min']),0);// Kennwort initialisieren
    $bug and dbug($strftime("$cfg[fstr]: Beginne mit Kennwort: $pw"),9);
   }
   $bf['last'] = '';				// Letztes Kennwort löschen
  }
  else {
   $x = $y = count($bf['pass']);
   while($x--)					// Kennwort "hochzählen"
    if($bf['pass'][$x] = ++$bf['pass'][$x] % $bf['chrs'])
     break;
   if($x == $y -1 and $bf['last']) {		// Kein überhang?
    $bf['last'][-1] = $bf['chr'][$bf['pass'][$x]];// Kennwort schnell generieren
    $pass = $bf['last'];
   }
   elseif($x == -1)				// Letzte Stelle erreicht und nix gefunden?
    if(count($bf['pass']) == $bf['max']) {	// Maximum erreicht?
     $bf['pass'] = array();			// Kennwort löschen
     $bf['last'] = false;			// Letztes Kennwort löschen
     if($bug and $bf['min'] < $bf['max'])
      dbug($strftime("%n$cfg[fstr]: Kennwort hat maximallänge erreicht: $bf[max]"),9);
     return false;				// Fehlschlag melden
    }
    else {
     $bf['pass'] = array_fill(0,count($bf['pass'])+1,0); // Kennstelle um eins erhöhen
     $bug and dbug($strftime("$cfg[fstr]: Kennwort auf ".count($bf['pass'])." Stellen erhöht"),9);
    }
  }
  if(!isset($pass)) {				// Liegt schon ein fertiges Kennwort vor?
   $pass = "";					// Kennwort erstellen
   foreach($bf['pass'] as $v)
    $pass .= $bf['chr'][$v];
   $bf['last'] = $pass;				// Kennwort sichern
  }
  return $bf['dot'] ? str_replace($bf['dot'],$pass,$pw) : ($bf['way'] ? $pass.$pw : $pw.$pass);	// Mit Realen Kennwort erweitern
 }
 function spnxt($pw="") {					// Kennwortteile vertauschen
  global $sp;				// Interne Variablen verfügbara machen
  for($a=$b=0; $a < $sp['len']; $a++)
   if(!$b and $sp['pass'][$a] = ($sp['pass'][$a] + 1) % $sp['deep'])	// Überschlag
    $b++;				// Normales zählen
  if(!$b)				// Alle Zähler wieder auf null?
   if($sp['len']++ >= $sp['deep'])	// Ende?
    return false;			// Ende!
   else
    $sp['pass'][] = 0;			// Zähler erweitern
  for($a=0; $a < $sp['len']; $a++)	// Password erzeugen
   $pw .= ($a ? $sp['sep'] : "").$sp['char'][$sp['pass'][$a]];
  return $pw;
 }
 if(ifset($cfg['help']) or !getArg(true)) {			// Hilfe Ausgeben bei -h oder ohne Parameter
  out("$plugin\n$info\n\n$splug[0] [crypt] <pass> <mac> <serial> <try> <set> <dot> <interim>"
	.((ifset($cfg['help'],'/[ab]/i') and $base = str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ123456')) ? "\n
Beispiele:
$self $plug $base
$self $plug {$qt}crypt:$$$\$$base$qt mac:11:23:58
$self $plug crypt:$base mac[/]:11:23:58/13:21:34
$self $plug crypt:$base serial:A123.456.78.901.234
$self $plug {$qt}crypt:$$$\$$base$qt pass:passwd.txt
$self $plug crypt:$base pass[,]:admin,123456,password,qwertz,12345
$self $plug crypt:$base {$qt}pass[!]:passwd.txt!kennwort.txt$qt
$self $plug crypt:$qt$$$\$$base$qt pass[,]:foo,bar,test -sp -d
$self $plug crypt:$qt$$$\$$base$qt pass[-]:4-8-15-16-23-42 -sp:$qt $qt -d
$self $plug crypt:FRITZ.Box_7590.export pass:kennwort.txt try:0-9,4 -d
$self $plug crypt:$qt$$$\$$base$qt pass[,]:admin,password,1qaz2wsx,qwerty try[,]:0-9,0-3 -sp -d
$self $plug crypt:$qt$$$\$$base$qt pass:$qt$qt try:$qt\\x20-\\x7e,5-32$qt set:'574r7_h3r3' dot:1e7 interim:1e9 -d" : "")."\n");
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "KonfigHacker:|-sa||Auch bei einem erfolgreichen Fund weiter suchen
|-sp:|<sep>|Kennwortteile vertauschen";
 }
 elseif($data = getArg('crypt',$var = '/^(\${4})?([A-Z1-6]{32,})$/2')	// 'crypt'-Parameter überprüfen
	or $file = getArg('crypt','file_exists')
		and preg_match("/^Password=".substr($var,2,-1)."m",file_contents($file),$pass)
		and $data = $pass[2]) {	// Crypt aus Konfig-Datei
  $pass = getArg('pass',array());
  $serial = ($var = getArg('serial','/([A-Z](?:0[1-9]|[1-4]\d|5[0-3])[1-7]\.?\d{3}\.?\d{2}(?:\.?\d{3}){2})/1'))
	? str_replace('.','',$var) : str_repeat('0',16);
  if($var = getArg('-sp') and count($pass) > 1) {// Kennwörter vertauschen
   $sp = array('char' => $pass, 'pass' => array(), 'deep' => count($pass), 'len' => 0, 'sep' => is_string($var) ? $var : "");
   $pass = "";
  }
  else
   $sp = false;
  if(($var = ($key = getArg('try',array()) and count($key) >= 2
	and preg_match('/^((?:(?:[\\\\0]x[a-f0-9]{2}|.)-(?:[\\\\0]x[a-f0-9]{2}|.))+|(.+?))($)/',$key[0],$m)	// Chars
	and preg_match('/^([12]?\d|3[012])(?:-([12]?\d|3[012]))?($)/',$key[1],$n)) ? array(count($key),$m[1],$m[2],$n[1],$n[2],isset($key[2]) ? $key[2] : false) : false)	// passlen
  or $var = getArg('try','/((?:(?:[\\\\0]x[a-f0-9]{2}|.)-(?:[\\\\0]x[a-f0-9]{2}|.))+|(.+?))(?<!\\\\)(?:,([12]?\d|3[012])(?:[,-]([12]?\d|3[012]))?)(?:,(.))?($)/i')) {	// try:BruteForce
   $bf = array('chr' => '', 'chrs' => 0, 'tot' => 0, 'min' => 0, 'max' => 0, 'way' => 0, 'dot' => '', 'last' => false, 'pass' => array());
   if($var[2])			// Direkte Charcode Tabelle
    $bf['chr'] = $var[2];
   elseif(preg_match_all('/(?:[\\\\0]x([a-f0-9]{2})|(.))-(?:[\\\\0]x([a-f0-9]{2})|(.))/i',$var[1],$m))	// Charcode Bereiche
    foreach($m[1] as $k => $v) {			// Bereiche durchgehen
     $x = $v ? hexdec($v) : ord($m[2][$k]);		// Min-Wert
     $y = $m[3][$k] ? hexdec($m[3][$k]) : ord($m[4][$k]);// Max-Wert
     $z = max($x,$y);
     for($x = min($x,$y); $x <= $z; $x++)	// Bereich erstellen
      $bf['chr'] .= chr($x);
    }
   if(($var[3] or $var[4]) and $bf['chrs'] = strlen($bf['chr'] = implode('',array_unique(preg_split('/(?=.)/',$bf['chr']))))) {	// Mache Charcode-Tabelle Unique
    $bf['min'] = $bf['max'] = intval($var[3]);	// Mindeslänge
    if($var[4])					// Maximalelänge
     $bf['max'] = max(intval($var[4]),$bf['max']);
    if($var[5] == "^" or $var[5] == "<")	// Links vom Kennwort
     $bf['way'] = 1;
    elseif($var[5] == "$" or $var[5] == ">")	// Rechts vom Kennwort
     $bf['way'] = 0;
    else
     $bf['dot'] = $var[5];			// Da, wo der Platzhalter ist
    for($bf['tot'] = 0, $a = $bf['min']; $a <= $bf['max']; $a++)
     $bf['tot'] += pow($bf['chrs'],$a);
    if($set = getArg('set',"/^[".preg_quote($bf['chr'])."]{".$bf['min'].",".$bf['max']."}$/0"))
     for($a=0; $a < strlen($set); $bf['pass'][] = strpos($bf['chr'],$set[$a++]));
    out("BruteForce: $bf[chrs] Zeichen, Kennwortlänge $bf[min]".(($bf['min'] < $bf['max']) ? "-$bf[max]": "")." - Maximale Versuche: ".number_format($bf['tot'],0,0,'.'));
   }
   else
    $bf = false;
  }
  else
   $bf = false;
  $dot = (int)getArg('dot','/^(\d+|1?\de1?\d)$/i0',1e7);	// Ein Punkt nach x versuchen
  $int = floor((int)getArg('interim','/^(\d+|1?\de1?\d)$/i0',1e9)/$dot);	// Zwischenergebnis
  $iv = substr($d = unBase($data),0,16);			// AES iv
  $data = substr($d,16).str_repeat("\0",16 - strlen($d) % 16);	// AES data.pad
  $pad = str_repeat("\0",16);					// Pad für Key
  $a = $b = $c = $all = 0;
  $secret = $key = false;
  $bug and dbug("AES-IV:     ".bin2hex($iv)."\nAES-Cipher: ".bin2hex(substr($d,16)));
  if(preg_match('/^c(1cb3b22d5e4f18fa4c45df95625f36c|cdafc77fc4038dde77ff93ec5e1c1a6)$/',md5($d)))
   $secret = $key = bindec(str_repeat(10,(pi().'exists')[0]));	// 7.5e9 Jahre
  elseif($pass !== false) {					// Kennwörter durchprobieren
   $eol = array("\r","\n");					// Zur Beschleunigung vordefinieren
   $d = microtime(true);					// Startzeit Stoppen
   out($strftime("Startzeit:  $cfg[fstr]"));
   while(($file = $sp ? spnxt($pass) : array_shift($pass)) !== false and $file !== null) {
    if($fp = (!$sp and $file and file_exists($file)) ? file_stream($file) : false)	// Passwordliste öffnen (<r4<k5747!0n.n37)
     $bug and dbug("Lese Password-Liste: $file");
    else
     $bug and dbug("Probiere weiter mit: $file",9);
    while(($pwd = ($bf and ($var = bfnxt($file)) !== false) ? $var					// Bruteforce-Modus
		: (($fp and ($var = file_stream($fp)) !== false) ? ($file = str_replace($eol,'',$var))	// Nächstes Kennwort holen
			: (($file !== false and $var = $file and !$file = false) ? $var			// Dateiname selbst probieren
				: false))) !== false							// Fehlschlag
	and !($key = openssl_decrypt($data, "AES-256-CBC", hash('md5',$pwd,true).$pad, OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING, $iv)
	and substr($key,4,2) == "\0\0"
	and hexdec(bin2hex(substr($key,4,4))) < strlen($key)	// pack("A4",substr($key,4,4))
	and substr(hash('md5',substr($key,4,strlen($key) - 20),true),0,4) == substr($key,0,4))) {
#     echo "$pwd\n";	// Password-Monitor
     if($a++ == $dot) {
      $b += $a;
      $a = 0;
      if($c++ == $int) {
       out($strftime("%n$cfg[fstr]").": '".trim($pwd)."' - ".number_format($b / ($time = microtime(true) - $d),0,0,'.')
	." Versuche in der Sekunde von bis jetzt ".($bf and $bf['tot'] ? round($b/$bf['tot'],3)."% " : "")."insgesamt ".number_format($b,0,0,'.')." Versuchen in ".gmdate('H:i:s',floor($time)));
       $c = 0;
      }
      else
       out(".",10);
     }
    }
    if($pwd) {
     $aes = preg_replace('/[\r\n]+/','',$pwd);
     $secret = "Kennwort gefunden: $aes";
     $aes = hash('md5',$aes,true).$pad;
     if(!getArg('-sa')) {
      $speed = ($all = $a + $b) / ($time = microtime(true) - $d);// Endzeit Stoppen
      break;
     }
     else {
      $bug and dbug("AES-Key:    ".bin2hex($aes));
      out($secret);
      $secret = $aes = "";
     }
    }
   }
   out($strftime("%nEndzeit:    $cfg[fstr]"));
  }
  elseif($data) {						// Mac-Adressen durchprobieren
   $macs = ($var = getArg('mac',array())) ? $var : (preg_match_all('/[\dA-F]{6}/',
	strtoupper(bin2hex(base64_decode("AAQOABUMABpPABxKAB8/ACT+vAVDwCUGJGURnMemCJbXNIHENDHEXEl5yA4UOBDV4ChtzM4eRE5t6N9wfP9N8LAUmJvL3DlvLDr9LJGrPKYvdEJ/
	0BLL3BXIPDcSHO1vsPIIUOY2SF01DHJ0BLT+1CTd4AhVYLWNtPx9mKllCLZXNOGpgCOVDMV0AHqkJJkAHCOiSH+A"))),$avm)
	? preg_replace('/../','$0:',$avm[0]) : 0);
   for($a=$all=$time=0, $hex=array(); $a < 256; $hex[] = strtoupper(str_pad(dechex($a++),2,0,STR_PAD_LEFT)));
   foreach($macs as $mac)					// Alle MAC-Hersteller durchgehen
    if(preg_match('/^([\da-f]{2}([:-]|$)){3}/i',$mac,$var)) {
     $mac = strtoupper(preg_replace('/\W+|(?<=\w)$/',':',$var[0]));
     $a = $b = $c = $d = $e = 0;				// MAC-Nummern Initialisieren
     out($f = "Versuche $mac",10);
     $f = strlen($f);
     $g = microtime(true);					// Startzeit Stoppen
     while(!($key = openssl_decrypt($data, "AES-256-CBC",
	hash('md5',"$serial\n$mac".$hex[$c].":".$hex[$b].":".$hex[$a]."\n",true).$pad, OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING, $iv)
	and substr($key,4,2) == "\0\0"
	and hexdec(bin2hex(substr($key,4,4))) < strlen($key)	// pack("A4",substr($key,4,4))
	and substr(hash('md5',substr($key,4,strlen($key) - 20),true),0,4) == substr($key,0,4)))
      if(!($a = ++$a & 255))
       if(!($b = ++$b & 255)) {
        $e = floor(($c / 256) * max($cfg['wrap']-$f,10)) - $d;	// Fortschrittsanzeige
        out(str_repeat(".",$e),10);
        $d += $e;
        if(!($c = ++$c & 255))
         break;
       }
     out("\n",8);
     $time += microtime(true) - $g;				// Endzeit Stoppen
     if($a + $b + $c > 0) {
      $aes = $mac.$hex[$c].":".$hex[$b].":".$hex[$a];
      $secret = "MAC-Adresse gefunden: $aes";
      $aes = hash('md5',"$serial\n$aes\n",true).$pad;
      if(!getArg('-sa')) {
       $all += $a + $b * 256 + $c * 65536;
       $speed = $all / $time;
       break;
      }
      else {
       $bug and dbug("AES-Key:    ".bin2hex($aes));
       out($secret);
       $secret = $aes = "";
      }
     }
     else
      $all += 1<<24;
    }
  }
  if($key and $secret == $key)					// Sonderfall: secret = key
   $secret = $cfg['dbug'] ? "Antwort:    $key" : "$key";
  elseif($secret and $key) {					// Erfolgreicher Fund!
   $var = substr($key,8,hexdec(bin2hex(substr($key,4,4))));
   $bug and dbug("AES-Key:    ".bin2hex($aes)."\nAES-Decrypt:".bin2hex(substr($key,0,4))." ".bin2hex(substr($key,4,4))." ".bin2hex($var));
   if(substr($var,0,strlen($var)/2) == substr($var,strlen($var)/2))
    $bug and dbug("Konfig-Key: ".bin2hex(substr($var,strlen($var)/2).$pad));
   elseif(preg_match('/^([[:print:]]+)\0?$/',$var,$val))
    $bug and dbug("Decrypted:  $val[1]");
  }
  else {							// Nichts gefunden
   $secret = "Nichts gefunden, keine Entschlüsselung möglich!";
   if(!isset($all) or !$all)
    $all = $a + $b;
   if(!isset($time))
    $time = microtime(true) - $d;
   if(!isset($speed))
    $speed = $all / $time;
  }
  if($all)
   out(number_format($speed,0,0,'.')." Versuche in der Sekunde von insgesamt ".number_format($all,0,0,'.')." Versuchen in ".gmdate('H:i:s',floor($time)));
  out($secret);
 }
 else								// 'crypt'-Parameter fehlt
  out(errmsg("2:Fehler: Parameter crypt nicht übergeben oder ist ungültig!"));	// Fehlermeldung

?>
