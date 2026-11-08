<?php if(defined('fb_tools')) {	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "CallMonitor 0.04 (c) 31.03.2025 by Michael Engelke";
 $info = 'Überwacht den Anrufmonitor der Fritz!Box (Am Telefon mit #96*5* einschalten)';
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.01 08.04.2020
 - Erste Version
0.02 29.03.2021
 - FIX: Übernimmt die fb_Tools Fritz!Box-Angabe, wenn der host-Parameter fehlt
 - Start nur mit fb_Tools oder php-cli
0.03 01.12.2022
 - Anpassung an PHP 8.x
0.04 23.03.2025
 - Anpassung an fb_Tools 0.46+
*/
# Start als Plugin für fb_Tools
 $pi = "$plugin\n$info\n\n$splug[1]";	// Hilfe vorbereiten
 $buf = $cfg['sbuf'];		// Lesebuffer
 $hlp = ifset($cfg['help']);	// Hilfe
 $log = getArg('log');		// Logfile
 $host = getArg('host');	// Host & Port
 if($var = ifset($host,'/^([\w.-]+|\[[\da-f:]+\])(?::(\d{1,5}))?$/i')) {
  $host = preg_replace('/[\[\]]/','',$var[1]);
  $port = $var[2] ? $var[2] : 0;
 }
 if(!($time = getArg('timeout'))) // Timeout
  $time = $cfg['tout'];
}
# Start als Standalone
elseif(isset($argc) and $argc) {				// Start nur im CLI-Modus
 function out($a) { echo "$a\n"; }				// Normale Ausgaben auf der Konsole
 function dbug($a) { return false; }				// Keine Debug-Ausgaben
 function file_contents($file,$data='',$mode=8) {		// Daten schreiben
  $out = 0;
  if(strpos($file,'%') !== false)				// strftime auflösen
   $file = @strftime($file);
  if(function_exists('file_put_contents'))
   $out = file_put_contents($file,$data,$mode);			// Ungepackt schreiben
  elseif($fp = fopen($file,'a+')) {
   $out = fwrite($fp,$data);
   fclose($fp);
  }
  return $out;
 }
 $c = 1;			// Parameterzähler
 $pi = basename(__FILE__);	// Hilfe vorbereiten
 $buf = 1024;			// Lesebuffer
 $hlp = $argv[$argc-1] == '-h';	// Hilfe
 $log = isset($argv[$c]) ? $argv[$c++] : false; 	// Logfile
 $cfg = array();
 if(isset($argv[$c]) and preg_match('/^([\w.-]+|\[[\da-f:]+\])(?::(\d{1,5}))?$/i',$argv[$c++],$var)) {	// Host & Port
  $host = preg_replace('/[\[\]]/','',$var[1]);
  $port = $var[2] ? $var[2] : 0;
 }
 $time = (isset($argv[$c])) ? intval($argv[$c++]) : false; // Timeout
}
if(isset($hlp))
 if($hlp)		// Hilfe ausgeben
  out("$pi <log> <host> <timeout>");
 else {			// Allgemeiner Start
  if(!isset($host) or !$host)
   $host = (isset($cfg['host'])) ? $cfg['host'] : "fritz.box";
  if(!isset($port) or !$port)
   $port = 1012;
  dbug("Starte Socktet: $host:$port");
  if($sp = fsockopen($host,$port,$no,$str)) {
   if($time)
    stream_set_timeout($sp,$time);
   while(true) {
    while($line = fgets($sp,$buf)) {
     if($log)
      file_contents($log,$line,8);
     out(trim($line));
    }
    dbug("Timeout...");
   }
   fclose($sp);
  }
  else
   out("$host nicht gefunden! Fehler: $no - $str\nAnrufmonitor aktiv? (Am Telefon mit #96*5* einschalten)");
 }
else
 echo "Ausführung nur mit fb_Tools oder mit PHP-cli\n";

?>
