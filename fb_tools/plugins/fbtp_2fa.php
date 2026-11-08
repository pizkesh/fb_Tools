<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "2FA 0.05 (c) 23.03.2025 by Michael Engelke";
 $info = '(De-)aktiviert die Zwei-Faktor-Authentisierung';
 $meta = '{fbt:0.46,fos:6.69}'; /*

Plugingeschichte:
0.01 28.12.2023
 - Erste Version
0.02 06.01.2024
 - Prüfung ob 2FA unterstützt wird
0.03 05.05.2024
 - Hilfe verbessert
 - Unterstütung für Fritz!OS 6.70-7.19
0.04 04.11.2024
 - Hilfe verbessert
0.05 23.03.2025
 - Anpassung fb_Tools 0.46+
*/
 if(ifset($cfg['help']) or !getArg(true))			// Hilfe Ausgeben bei -h oder ohne Parameter
  out("$plugin\n$info\n\n$splug[2] [func:an|aus|off|on|test]".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self $cfg[fbhp] $plug aus\n$self $plug test" : "")."\n");
 elseif($arg = getArg('func') and $arg = ifset($arg,'/^(?:(an|on)|(aus|off)|(test))($)/')) { // 'func'-Parameter überprüfen
  login(false);
  if(ifset($cfg['boxinfo']['Name'],'/^FRITZ!Box\b/i')) {
   $url = ($cfg['fiwa'] > 719) ? array("support&twofactor=1","&twofactor_auth_enabled=on","",1) : array("userSet&apply=&twofactor_auth_enabled=",1,0,0);
   $tst = is_array($flag = $cfg['boxinfo']['Flag']) ? preg_array('/^2nd_factor_disabled$/i',$flag) : false;
   if($url[3] and (ifset($arg[3]) or $arg[1] and !$tst or $arg[2] and $tst))
    out($tst ? errmsg("1:2FA ist deaktiviert") : "2FA ist aktiv");	// 2FA-Status ausgeben
   elseif(ifset($arg[3]) and !$url[3])
    out(errmsg("8:2FA-Test wird ab Fritz!OS 7.20 unterstützt"));
   else {
    out((ifset($arg[1]) ? "A" : "Dea")."ktiviere die Zwei-Faktor-Authentisierung");
    if($sid = (ifset($arg[1]) ? login() : login(0,0,true))) {
     $bug and dbug("Sende den 2FA-Befehl");
     request('post',"/data.lua","xhr=1&page=$url[0]".(ifset($arg[1]) ? $url[1] : $url[2])."&sid=$sid");
     if(!ifset($cfg['bsid']))
      logout($sid);
    }
    else
     out(errmsg(0,'login'));
   }
  }
  else
   out(errmsg("8:2FA wird nicht unterstützt"));
 }
 else								// 'func'-Parameter fehlt
  out(errmsg("2:Fehler: Parameter func nicht übergeben!"));	// Fehlermeldung

?>
