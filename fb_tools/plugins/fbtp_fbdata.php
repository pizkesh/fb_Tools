<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "FBData 0.05 (c) 23.03.2025 by Michael Engelke";
 $info = 'Speichert alle Relevanten Daten von einer Fritz!Box';
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.01 01.12.2022
 - Erste Version
0.02 26.01.2023
 - Parameter pass dazugekommen, um ein separates Konfig-Kennwort zu setzen
0.03 05.05.2024
 - Hilfe verbessert
0.04 04.11.2024
 - Hilfe verbessert
0.05 23.03.2025
 - Unterstützung für Wireguard-Daten
 - Anpassung an fb_Tools 0.46+
*/
 if(ifset($cfg['help']) or !getArg(true))				// Hilfe Ausgeben bei -h oder ohne Parameter
  out("$plugin\n$info\n\n$splug[1] [level:1-3] <save> <pass>\n
Level 1: Fritz!Box Angabe ohne Login
Level 2: Fritz!Box Angabe mit Login
Level 3: Fritz!Box Angabe mit Login & 2FA".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self $plug level:1
$self $cfg[fbhp] $plug level:2 save:./fbdata/
$self $cfg[fbhp] $plug 3 ./fbdata.zip" : "")."\n");
 elseif($level = intval(getArg('level','/^[123]$/0'))) {		// Parameter überprüfen
  $save = getArg('save');
  $pass = getArg('pass');
  $data = array();
  if($temp = boxinfo("",true))
   $data += $temp;							// jason/juis_boxinfo.xml
  if(supportcode())
   $data += array('system_status.html' => $cfg['http'] + array(1 => $cfg['body'])); // Supportcode
  if($level > 1 and $sid = ifset($cfg['bsid']) ? $cfg['bsid'] : login(0,0,$level == 3)) {
   if($level == 3) {							// Nur bei Level: 3 (2FA)
    if($temp = request('POST-array','/data.lua',"sid=$sid&own_config=&page=shareWireguard")	// Wireguard
	and $array = json2array($temp[1]) and isset($array['data']) and isset($array['data']['wg_device_config'])) {
     $temp[1] = $array['data']['wg_device_config'];
     $data += array('wg_config.conf' => $temp);
    }
    if($temp = cfgexport('array',$pass ? $pass : $cfg['pass']))
     $data += array('FRITZ.Box.export' => $temp);			// Konfig-Export
   }
   if($temp = request('POST-array','/cgi-bin/firmwarecfg',array('sid' => $sid, 'AssetsImportExportPassword' => false, 'AssetsExport' => false)) and substr($temp[1],0,2) == 'PK')
    $data += array('FRITZ.Box.assets.zip' => $temp);			// meta.json & Telefonie-Dateien
   if($temp = request('POST-array','/cgi-bin/firmwarecfg',array('sid' => $sid, 'MeshSupportData' => false)) and substr($temp[1],0,5) == '=====')
    $data += array('meshsupport.txt' => $temp);				// Meshdaten
   if($temp = request('POST-array','/cgi-bin/firmwarecfg',array('sid' => $sid, 'BoxCertExport' => false)) and isset($temp['Content-Disposition']))
    $data += array('boxcert.cer' => $temp);				// HTTPS-Zertifikat
   if($temp = supportdata())
    $data += array('Supportdata.txt' => $temp);				// Supportdaten
   if(!ifset($cfg['bsid']))						// Abmelden
    logout($sid);
  }
  else
   out(errmsg(0,'login'));						// Login fehlgeschlagen
  $files = array();							// Archiv vorbereiten
  foreach($data as $key => $array) {
   if($key)
    $files[(isset($array['Content-Disposition']) and preg_match('/filename="(.*?)"/i',$array['Content-Disposition'],$var)) ? $var[1] : $key] = array('time' => isset($array['Last-Modified']) ? strtotime($array['Last-Modified']) : (isset($array['Date']) ? strtotime($array['Date']) : time()), 'data' => $array[1]);
   unset($data[$key]);
  }
  if($var = ifset($save,$cfg['ptar'])) {				// Daten als Archiv schreiben
   $bug and dbug("Erstelle Archiv");
   if($var[4])
    file_contents($save,data2zip($files));
   elseif($fp = file_stream($save,1)) {
    foreach($files as $file => $data)
     file_stream($fp,data2tar($file,$data['data'],$data['time']));
    file_stream($fp,str_repeat("\0",512));
    file_stream($fp);
   }
  }
  else {								// Daten in Dateien schreiben
   $bug and dbug("Schreibe Dateien");
   if($save)
    if(file_exists($save) and is_dir($save))
     chdir($save);
    else
     makedir($save);
   foreach($files as $file => $data) {
    file_contents($file,$data['data']);
    touch($file,$data['time']);
   }
  }
 }
 else								// Parameter fehlt
  out(errmsg("2:Fehler: Parameter level nicht übergeben!"));	// Fehlermeldung

?>
