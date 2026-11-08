<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "Neustart 0.07 (c) 23.03.2025 by Michael Engelke";
 $info = 'Startet die Fritz!Box neu! (Web-Variante)';
 $meta = '{fbt:0.46}';  /*

Plugingeschichte:
0.01 23.05.2018
 - Erste Version
0.02 21.08.2019
 - Unterstützung für Fritz!OS 5.x - 7.1
0.03 05.10.2020
 - Unterstützung für Fritz!OS 4.x
0.04 01.12.2022
 - Anpassung an fb_Tools 0.32+
0.05 05.05.2024
 - Hilfe verbessert
0.06 04.11.2024
 - Hilfe verbessert
0.07 23.03.2025
 - Anpassung an fb_Tools 0.46+
*/
 if(ifset($cfg['help']))						// Hilfe Ausgeben
  out("$plugin\n$info\n\n$splug[2]".(ifset($cfg['help'],'/[ab]/i') ? "\n\nBeispiel:\n$self $cfg[fbhp] plugin $plug\n\n" : ""));
 elseif($sid = (ifset($cfg['bsid'])) ? $cfg['bsid'] : login()) {	// Login durchführen
  if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
   out("Starte $cfg[fbhp] neu");					// Kurze Mitteilung
   $s = "&sid=$sid";
   if($cfg['fiwa'] >= 708) {
    $bug and dbug("Neustart-Variante für Fritz!OS 7.1+");
    request('POST','/data.lua',"xhr=1&no_sidrenew=&reboot=&oldpage=%2Fsystem%2Freboot.lua$s");		// Reset ankündigen
    request('POST','/reboot.lua',"ajax=1&no_sidrenew=1&xhr=1&useajax=1$s");				// und bestätigen
   }
   elseif($cfg['fiwa'] >= 650) {
    $bug and dbug("Neustart-Variante für Fritz!OS 6.5 - 7.0");
    request('POST','/data.lua',"xhr=1&lang=de&no_sidrenew=&reboot=&oldpage=%2Fsystem%2Freboot.lua$s");	// Reset ankündigen
    request('GET','/reboot.lua',"ajax=1&no_sidrenew=1&xhr=1$s");					// und bestätigen
   }
   else {
    $bug and dbug("Neustart-Variante für Fritz!OS 4.x - 6.3");
    request('POST','/system/reboot.lua',"reboot=$s");			// Reset ankündigen
    request('GET','/reboot.lua',"ajax=1&xhr=1$s");			// und bestätigen
    request('POST','/cgi-bin/webcm',strtr("getpage=../html/reboot.html&logic:command/reboot=../gateway/commands/saveconfig.html$s",array('/' => '%2F', ':' => '%3A')));	// Für OS 4.x
   }
  }
  else
   out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
  if(!ifset($cfg['bsid']))						// Abmelden
   logout($sid);
 }
 else
  out(errmsg(0,'login'));						// Login fehlgeschlagen

?>
