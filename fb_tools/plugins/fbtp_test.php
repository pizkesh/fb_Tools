<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "Test 0.00 (c) 23.03.2025 by Michael Engelke";
 $info = 'Test-Plugin';
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.00 23.03.2025
 - Erste Version
*/
 if(ifset($cfg['help']) or !getArg(true))			// Hilfe Ausgeben bei -h oder ohne Parameter
  out("$plugin\n$info\n\n$splug[0] [test:String]".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self $plug test:{$qt}Foo Bar$qt\n$self $plug . -d" : "")."\n");

 elseif($arg = getArg('test')) {				// 'test'-Parameter überprüfen

  out($arg);							// Parameter ausgeben
  $bug and dbug(compact(explode(',','self,plug,splug,file,plugin,info,meta')));	// Im Debug-Modus einige Variablen ausgeben

 }
 else								// 'test'-Parameter fehlt
  out(errmsg("2:Fehler: Parameter test nicht übergeben!"));	// Fehlermeldung

?>
