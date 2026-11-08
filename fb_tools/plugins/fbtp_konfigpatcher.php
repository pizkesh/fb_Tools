<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "KonfigPatcher 0.04 (c) 23.03.2025 by Michael Engelke";
 $info = 'Universalpatcher für die Konfiguration';
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.01 01.12.2022
 - Erste Version
0.02 05.05.2024
 - Hilfe verbessert
0.03 04.11.2024
 - Hilfe verbessert
0.04 23.03.2025
 - Anpassung an fb_Tools 0.46+
*/
 $patches = json2array('{
  Base2Bin: {
	m: convert,
	p: /^(?P<base2bin>\*{4} B64FILE:.*\s*)([\w+\/\s=]*?)(?=\s*\*{4} END OF FILE \*{4})/im,
	i: "Convertiert Base64 Container in Binaer"},
  Bin2Base: {
	m: convert,
	p: /^(?P<bin2base>\*{4} BINFILE:.*\s*)([\dA-F\s]*?)(?=\s*\*{4} END OF FILE \*{4})/im,
	i: "Convertiert Binaer Container in Base64"},
  "GUI-Protect": {
	m: bool,
	p: /((_hidden|gui_readonly) = )(yes|no)(?=;\s*$)/im,
	r: ["$1no","$1yes"],
	i: "(Ent)sperrt Konfigbereiche der Fritz!Box"},
  LED: {
	m: bool,
	p: /^(\s{8}control = led_)(on|off)(?=;\s*$)/m,
	r: ["$1off","$1on"],
	i: "Schaltet die LED-Läuchten an oder aus"},
  TwoFactor: {
	m: bool,
	p: /^(\s{8}two_factor_auth_enabled = )(yes|no)(?=;\s*$)/m,
	r: ["$1no","$1yes"],
	i: "(De)aktiviert die Zwei-Faktor-Authentisierung"},
  "VOIP-Protect": {
	m: bool,
	p: /(((ata|voip_2ndPVC)_hidden|gui_readonly) = )(yes|no)(?=;\s*$)/im,
	r: ["$1no","$1yes"],
	i: "(Ent)sperrt die VoIP-Einstellungen der Fritz!Box"},
  "WANMAC-Override": {
	m: set,
	p: /(enable_mac_override = )(no|yes)/,
	r: "$1yes",
	f: /(?<=macdsl_override = )[\w:]+/,
	s: /^[\da-z]{2}(:[\da-z]{2}){5}$/i,
	a: "[set:mac]",
	i: "Überschreibt die WAN-MAC-Adresse mit einer beliebigen anderen MAC-Adresse"},
 }');
 function patchKonfig($data,$patch=false,$cmd=false) {			// Patch Data
  if(is_array($data)) {							// Callback Patch
   if(isset($data['base2bin']))
    $data = str_replace('64','IN',$data[1]).wordwrap(bin2hex(base64_decode($data[2])),80,"\n",true);
   elseif(isset($data['bin2base']))
    $data = str_replace('IN','64',$data[1]).wordwrap(base64_encode(pack('H*',preg_replace('/[^\da-f]+/i','',$data[2]))),80,"\n",true);
   else
    $data = "";
   return $data;
  }
  else {								// Normaler aufruf
   $count = 0;
   if($patch['m'] == 'bool' and is_int($cmd))
    $new = preg_replace($patch['p'],$patch['r'][$cmd],$data,($c = ifset($patch['c'])) ? $c : -1,$count);
   elseif($patch['m'] == 'set' and $cmd and preg_match($patch['s'],$cmd))
    $new = preg_replace($patch['f'],'${1}'.$cmd,
	preg_replace($patch['p'],$patch['r'],$data),
	($c = ifset($patch['c'])) ? $c : -1,$count);
   elseif($patch['m'] == 'convert')
    $new = preg_replace_callback($patch['p'],__FUNCTION__,$data,($c = ifset($patch['c'])) ? $c : -1,$count);
   return ($count and $new != $data) ? $new : false;
  }
 }
 if(ifset($cfg['help']) or !getArg(true)) {				// Hilfe Ausgeben
  $out = "";
  foreach($patches as $key => $var)
   $out .= strtolower($key)."|".(isset($var['a']) ? $var['a'] : (($var['m'] == 'bool') ? '[cmd:on\|off]' : ""))."|$var[i]\n";
  out("$plugin\n$info\n\n$splug[0] [patch] <cmd:off|on> <set> <file> <save>\n
Patches (patch):\n{{{tt}$out}}"
  .(ifset($cfg['help'],'/[ab]/i') ? "\n\nBeispiel:\n$self $cfg[fbhp] $plug patch:led cmd:off
$self $plug voip off file:konfig.export save:konfig_patch.export
$self $cfg[fbhp] $plug base2bin" : ""));
  if(!$cfg['help'] or $cfg['help'] === true)
   $cfg['help'] = -1;
  $opts .= "KonfigPatcher:|-rd:|<path\|file>|Erstellt ein Backup von der Konfig-Datei";
 }
 elseif($patch = getArg('patch','/^[\w-]+$/0')) {			// Parameter überprüfen
  $cmd = ($cmd = getArg('cmd','/^(?:(off|aus)|(on|an))($)/i')) ? ($cmd[2] ? 1 : 0) : getArg('set','/^[\w:.-]+$/0');
  if($patch = preg_array("/$patch/i",$patches,1) and (!ifset($patch['m'],'/^(bool|set)$/') or $cmd !== false)) {
   if($file = getArg('file','file_exists') and $data = file_contents($file)) {// Konfig offline patchen
    $bug and dbug("Patche Konfigurations-File");			// Debug-Meldung für preg_replace
    if($data = patchKonfig($data,$patch,$cmd))				// Auf Änderung prüfen
     file_contents(($save = getArg('save')) ? $save : $file,cfgcalcsum($data));
    else
     out("Keine Änderungen vorgenommen");
   }
   elseif($sid = (ifset($cfg['bsid'])) ? $cfg['bsid'] : login(0,0,true)) {// Login mit 2FA durchführen
    if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
     $bug and dbug("Hole Konfiguration");					// Debug-Meldung für cfgexport
     $data = cfgexport(false,$cfg['pass']);				// Konfig aus der Fritz!Box holen
     if($file = getArg('-rd'))						// RAW-Daten Speichern
      saverpdata($file,$data,"konfig.export");
     $bug and dbug("Patche Konfiguration");				// Debug-Meldung für preg_replace
     if($data = patchKonfig($data,$patch,$cmd)) {			// Auf Änderung prüfen
      $bug and dbug("Sende Konfiguration");				// Debug-Meldung für cfgimport
      out((cfgimport(false,$cfg['pass'],$data))				// Importieren
       ? "Konfig wurde hochgeladen und wird nun bearbeitet" : errmsg(0,'cfgimport'));	// Rückmeldung
     }
     else
      out("Keine Änderungen vorgenommen");
    }
    else
     out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
    if(!ifset($cfg['bsid']))						// Abmelden (Eigentlich Unnötig)
     logout($sid);
   }
   else
    out(errmsg(0,'login'));						// Login fehlgeschlagen
  }
  else
   out(errmsg("2:Patch nicht gefunden oder Parameter passen nicht zum ausgewählten Patch"));
 }
 else
  out(errmsg("2:Parameter müssen korrekt angegeben werden"));

?>
