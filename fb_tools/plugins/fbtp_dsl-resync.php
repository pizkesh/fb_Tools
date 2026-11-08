<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "DSL-Resync 0.04 (c) 23.03.2025 by Andreas Müller-Christ";
 $info = 'DSL-Verbindung neu synchronisieren';
 $meta = '{fbt:0.46,fos:6.50}'; /*

Plugingeschichte:
0.00 14.03.2023
 - Modifikation DSL-Resync
0.01 20.03.2023
 - Anpassungen
0.02 05.05.2024
 - Hilfe verbessert
0.03 04.11.2024
 - Hilfe verbessert
0.04 23.03.2025
 - Hilfe an fb_Tools 0.46+ angepasst
*/
 if(ifset($cfg['help']))						// Hilfe Ausgeben
  out("$plugin\n$info\n\n$splug[2]".(ifset($cfg['help'],'/[ab]/i') ? "\n\nBeispiel:\n$self $cfg[fbhp] plugin $plug\n\n" : ""));
 elseif($sid = (ifset($cfg['bsid'])) ? $cfg['bsid'] : login()) {	// Login durchführen
  if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
   out("Synchronisiere DSL $cfg[host] neu");				// Kurze Mitteilung
   request('POST','/data.lua',"xhr=1&no_sidrenew=&lang=de&dsl_resync=&oldpage=%2Fsupport.lua&sid=$sid");	// DSL-Resync ankündigen
   request('POST','/support.lua',"ajax=1&no_sidrenew=1&xhr=1&useajax=1&sid=$sid");				// DSL-Resync durchführen
  }
  else
   out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
  if(!ifset($cfg['bsid']))						// Abmelden
   logout($sid);
 }
 else
  out(errmsg(0,'login'));						// Login fehlgeschlagen

?>
