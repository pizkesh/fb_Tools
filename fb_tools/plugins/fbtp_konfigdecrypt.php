<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

$plugin = "KonfigDecrypt 0.46 (c) 23.03.2025 by Michael Engelke";
$info = 'Entschlüsselt die Fritz!Box Konfigdateien mit hilfe der Fritz!Box (End of Service)';
$meta = '{fbt:0.46,fos:5.00,eos:true}'; /*

Plugingeschichte:
0.13 25.06.2016
 - NEU: Alle Zugangsdaten können OHNE Telnet aus der Fritz!Konfig ausgelesen und angezeigt werden
0.15 07.07.2016
 - Zugangsdaten können auch bei einer Internationalen Fritz!Box (z.B. 4020) ausgelesen/entschlüsselt werden
0.16 20.07.2016
 - Konfig-DeCrypt verbessert (Entschlüsselt auch Konfigurationen mit mehreren Kennwörtern - Danke an Herby007)
0.17 06.08.2016
 - Konfig-DeCrypt verbessert (Entschlüsselt auch Kennwörter im Binaer-Bereich der Konfig - Danke für den Hinweis)
0.19 29.01.2017
 - Ereignisse und Konfig-DeCrypt an OS 6.8 angepasst
 - Workaround für Konfig-DeCrypt an Fritz!Box 7312 implemmentiert
 - Workaround für HTTP-Fehler 503 implementiert
0.20 20.03.2017
 - Konfig DeCrypt: Internationale Sprachen an OS 6.8 angepasst
0.22 11.04.2017 (Intern)
 - Letzte Version als bestandteil von fb_Tools
0.23 18.03.2019
 - Bug: Konfig-Decrypt entschlüsselte nur ein Teil bei einer Fritz!Box 7412
 - Ausgelagert als Plugin
0.25 19.06.2019
 - Fix: Anpassungen an fb_Tools 0.25+
0.28 13.09.2020
 - Fix: Anpassungen an fb_Tools 0.28+
0.30 23.03.2021
 - Fix: Anpassungen an fb_Tools 0.30+
0.32 01.12.2022
 - Fix: Anpassungen an fb_Tools 0.32+
0.40 05.05.2024
 - Hilfe verbessert
0.42 04.11.2024
 - Hilfe verbessert
0.46 23.03.2025
 - Hilfe an fb_Tools 0.46+ angepasst
*/
function konfigdecrypt($data,$pass,$sid=0) {		// Konfig-Datei mit Fritz!Box entschlüsseln
 global $cfg,$bug;
 $fn = __FUNCTION__;
 if(!$sid)						// Sid sicherstellen
  $sid = $cfg['sid'];
 $bug and dbug($data,4,'12,KonfigDeCrypt-Crypted');
 $plain = $buffer = array();
 if($sid and preg_match_all('/^\s*([\w-]+)\s*=\s*("?)(\${4}\w+)\2;?\s*$/m',$data,$array) and preg_match('/(?:\s*Password\d*=\${4}\w+)+/',$data,$var)) {
  if(preg_match('/^boxusers\s\{\s*^\s{8}users(\s\{.*?^\s{8}\}$)/smx',$k = str_replace("\t","        ",$cfg['zlib']['inflate'](base64_decode("
	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"))),$v))
   $bug and dbug($export = array(str_replace("#0",$var[0],$k),$v[1]),9);	// Stark gekürze und leere Fritz!Box 7490 Konfig
  if(preg_match_all('/\${4}\w+/',$var[0],$val))		// Salt-Kennwörter entfernen
   foreach($val[0] as $var)
    if(($key = array_search($var,$array[3])) !== false) {
     $plain[$var] = $pass;
     unset($array[3][$key]);
    }
  if(preg_match_all('/^\*\*\*\*\sBINFILE:(.*)\s*([\dA-F\s]*?(?:24\s*){4}(?:[46][1-9A-F]|[57][0-9A]|3\d|\s*)+[\dA-F\s]*)/mi',$data,$binfile)) {
   $binfile = array_combine($binfile[1],$binfile[2]);	// Binfiles mit verschlüsselten Werten einbeziehen
   foreach($binfile as $key => $var) {
    $binfile[$key] = pack('H*',preg_replace('/[^\da-f]+/i',"",$var));
    if(preg_match_all('/\${4}\w+/',$binfile[$key],$val))
     $array[3] = array_merge($array[3],$val[0]);
   }
  }
  else
   $binfile = false;
  $bug and dbug($array,4,'KonfigDeCrypt');
  $list = array_unique($array[3]);			// Doppelte Einträge entfernen
  shuffle($list);					// Alle Einträge durchwürfeln (Für Problemfälle)
  if(preg_match_all('/\${4}\w+/',$var[0],$array))	// Salt-Kennwörter eintragen
   foreach($array[0] as $var)
    $plain[$var] = $pass;
  $dupe = array(array(1,4,'/^(.*?)$/'), array(15,5,'/(?<=^|,\s)(.*?)(?=,\s|$)/'));
  $pregimport = array(
   'de' => array('Internetzugangsdaten' => array(1,0,'/^Benutzer:\s(.*?)(?:,\sAnbieter:\s.*?)?$/'), 'Dyn(amic )?DNS' => array(2,1,'/(?<=Domainname:\s|Benutzername:\s)(.*?)(?=,\s|$)/'),
    'PushService' => array(1,3,'/^E-Mail-Empfänger:\s(.*?)$/'), 'MyFRITZ!' => $dupe[0], 'FRITZ!Box-Benutzer' => $dupe[1]),
   'en' => array('Internet Account Information' => array(1,0,'/^User:\s(.*?)(?:,\sProvider:\s.*?)?$/'), 'Dyn(amic )?DNS' => array(2,1,'/(?<=Domain\sname:\s|user\sname:\s)(.*?)(?=,\s|$)/'),
    'Push service' => array(1,3,'/^e-mail\srecipient:\s(.*?)$/'), 'MyFRITZ!' => $dupe[0], 'FRITZ!Box Users' => $dupe[1]),
   'es' => array('Datos de acceso a Internet' => array(1,0,'/^Usuario:\s(.*?)(?:,\sProvider:\s.*?)?$/'),
    '(Dyn)?DNS( dinámico)?' => array(2,1,'/(?<=Nombre\sdel\sdominio:\s|nombre\sdel\susuario:\s)(.*?)(?=,\s|$)/'),
    'Push Service|Notificaciones' => array(1,3,'/^Destinatario\sde\scorreo:\s(.*?)$/'), 'MyFRITZ!' => $dupe[0], 'Usuarios de FRITZ!Box' => $dupe[1]),
   'fr' => array('Données d\'accès à Internet' => array(1,0,'/^Utilisateur[\xa0\s]?:[\xa0\s](.*?)(?:,\sProvider:\s.*?)?$/'),
    '(Dyn)?DNS( dynamique)?' => array(2,1,'/(?<=Nom\sde\sdomaine[\xa0\s]:[\xa0\s]|nom\sd\'utilisateur[\xa0\s]:[\xa0\s])(.*?)(?=,\s|$)/'),
    'Service push' => array(1,3,'/^Destinataire\sdu\scourrier\sélectronique[\xa0\s]?:[\xa0\s](.*?)$/'), 'MyFRITZ!' => $dupe[0], 'Utilisateur de FRITZ!Box' => $dupe[1]),
   'it' => array('Dati di accesso a Internet' => array(1,0,'/^Utente:\s(.*?)(?:,\sProvider:\s.*?)?$/'), 'Dyn(amic )?DNS' => array(2,1,'/(?<=Nome\sdi\sdominio:\s|nome\sutente:\s)(.*?)(?=,\s|$)/'),
    'Servizio Push' => array(1,3,'/^Destinatario\se-mail:\s(.*?)$/'), 'MyFRITZ!' => $dupe[0], 'Utenti FRITZ!Box' => $dupe[1]),
   'pl' => array('Dane dost\?powe do internetu' => array(1,0,'/^U\?ytkownik:\s(.*?)(?:,\sProvider:\s.*?)?$/'),
    'Dyn(amic )?DNS' => array(2,1,'/(?<=Nazwa\sdomeny:\s|nazwa\su\?ytkownika:\s)(.*?)(?=,\s|$)/'), 'Push Service' => array(1,3,'/^Odbiorca\se-maila:\s(.*?)$/'),
    'MyFRITZ!' => $dupe[0], 'U\?ytkownicy FRITZ!Box' => $dupe[1]),
  );
  $lang = (ifset($cfg['boxinfo']['Lang']) and ifset($pregimport[$cfg['boxinfo']['Lang']])) ? $cfg['boxinfo']['Lang'] : 'de';
  $bug and dbug((count($list) + count($plain))." verschiedene verschlüsselte Einträge gefunden! (Sprachmuster: $lang)");
  $bug and dbug($list,4,'KonfigDeCrypt-List');
  $b = 1;
  while($list) {					// Alle Verschlüsselte Einträge durchlaufen
   $import = $export[0];
   $buffer = array_values($buffer);
   while($list and count($buffer) < ((ifset($cfg['boxinfo']['Name'],'/FRITZ!Box 7[34]12/i')) ? 4 : 20))	// Die ersten 20 Einträge sichern
    $buffer[] = array_shift($list);
   $a = 0;						// Import-Buffer füllen
   $v = array();
   foreach($buffer as $var)
    if($a++ < 5)
     $import = str_replace("#$a",$var,$import);
    else
     $v[] = str_replace('#7',$var,str_replace('#6',4+$a,$export[1]));
   $import = preg_replace('/(^boxusers\s\{\s*^\s{8}users)\s\{.*?^\s{8}\}$/smx',"$1".str_replace('$','\$',implode('',$v)),$import);
   if($var = cfgcalcsum($import))			// Checksum berechnen
    $import = $var[2];
   $bug and dbug($import,4,"KonfigDeCrypt-Import-$b");
   $bug and dbug($buffer,4,"KonfigDeCrypt-Buffer-".($b++));
   if($var = request('POST','/cgi-bin/firmwarecfg',array('sid' => $sid, 'ImportExportPassword' => $pass,
	'ConfigTakeOverImportFile' => array('filename' => 'fritzbox.export', 'Content-Type' => 'application/octet-stream', '' => $import), 'apply' => false)) and !preg_match('/cfg_nok/',$var)) {
    if($getdata = utf8(($cfg['fiwa'] < 650) ? request('GET',"/system/cfgtakeover_edit.lua?sid=$sid&cfg_ok=1") : request('POST',"/data.lua","xhr=1&sid=$sid&lang=de&no_sidrenew=&page=cfgtakeover_edit"))) {
     if(preg_match_all('/^\s*\["add\d+_text"\]\s*=\s*"([^"]+)",\s*$.*?^\s*\["gui_text"\]\s*=\s*"([^"]+)",\s*$/sm',$getdata,$match))
      $match[2] = array_flip($match[2]);
     elseif(preg_match_all('/<label for="uiCheckcfgtakeover\d+">(.*?)\s*<\/label>\s*<span class="addtext">(.*?)\s*<br>\s*<\/span>/',$getdata,$match))
      $match = array(1 => $match[2], 2 => array_flip($match[1]));
     if($match) {					// Decodierte Kennwörter gefunden
      $bug and dbug($match,4,'KonfigDeCrypt-Match');
      foreach($pregimport[$lang] as $key => $var)
       if($k = preg_array("/^$key$/",$match[2],5) and preg_match_all($var[2],$match[1][$match[2][$k]],$array))
        foreach($array[1] as $k => $v)
         if(isset($buffer[$var[1] + $k]) and $buffer[$var[1] + $k] != $v) {	// Kennwort sichern
          $plain[$buffer[$var[1] + $k]] = str_replace('"','\\\\"',html_entity_decode($v,ENT_QUOTES,'ISO-8859-1'));
          unset($buffer[$var[1] + $k]);
         }
     }
     else
      return errmsg('8:Keine Entschlüsselte Daten gefunden',$fn);
    }
    else
     return errmsg('8:Keine Daten erhalten',$fn);
   }
   else
    return errmsg('64:Entschlüsselungsversuch wurde nicht akzeptiert'
	.(($val = ifset($var,'/<p class="ErrorMsg">(.*?)<\/p>/')) ? (($val[1] == '?1043?')
	? "\nBitte \"Ausführung bestimmter Einstellungen und Funktionen zusätzlich bestätigen\" deaktivieren!" : " - $val[1]") : ''),$fn);
   $bug and dbug((count($list)) ? floor(count($plain)/(count($list)+count($plain))*100)."% entschlüsselt..." : "100% ".($buffer ? "Es konnte".((count($buffer) == 1)
	? " ein Eintrag" : "n ".count($buffer)." Einträge")." nicht Entschlüsselt werden! " : "")."- Ersetze ".count($plain)." entschlüsselte Einträge...");
  }
  $bug and dbug($buffer,4,'KonfigDeCrypt-Resistant');
  $bug and dbug($plain,4,'KonfigDeCrypt-Plain');			// Plaintext sichern
  if($binfile)						// BinFiles wieder zusammenpacken
   foreach($binfile as $key => $var)
    $data = preg_replace("/(?<=\*{4} BINFILE:$key\s)[\dA-F\s]*(?=\s\*{4} END OF FILE \*{4})/",
	wordwrap(strtoupper(implode('',unpack('H*',str_replace(array_keys($plain),array_values($plain),$var)))),80,"\n",1),$data,1);
  $data = str_replace(array_keys($plain),array_values($plain),$data);
  $bug and dbug($data,4,'12,KonfigDeCrypt-Decrypted');
  return $data;
 }
 return errmsg('16:Keine Konfig-Datei',$fn);
}
if(isset($cfg['utf8']) and !$cfg['utf8'])
 out(errmsg("1:Hinweis: UTF-8 wird auf Ihrem System von PHP nicht unterstützt, daher ist die Entschlüsselung Problematisch!"));
if(ifset($cfg['help']) or !getArg(true)) {		// Hilfe Ausgeben
 out("$plugin\n$info\n\n$splug[2] [func:Funktion] <Datei|Ordner> <pass:Kennwort>\n
Funktionen (func):\n{{{tt}ExPort|<of:Datei>|<pass:Kennwort>|-|Konfig entschlüsseln und exportieren
ExTrakt|<of:Ordner>|<pass:Kennwort>|-|Konfig entschlüsseln, anzeigen/exportieren (tar)
File|[if:Datei]|[pass:Kennwort]||<of:Datei> - Konfig-Daten entschlüsseln}}

Anmeldung mit Logindaten & Fritz!Box mit OS 5 oder neuer erforderlich
Ab OS 6.69 muss die Sicherheits-Bestätigungsfunktion deaktiviert werden"
  .(ifset($cfg['help'],'/[ab]/i') ? "\n\nBeispiele:
$self $cfg[fbhp] plugin $plug file-decrypt fb.export geheim fbdc.export -d
$self $cfg[fbhp] pi $plug exdc fb.export geheim -d\n" : ""));
}
elseif($mode = getArg('func','/^(?:e(p|xport)?|(et|(?:extra[ck]t))?|(f(?:ile)?))$/ix')) {	// Parameter überprüfen
 $mode = array_pad($mode,4,null);
 $file = getArg('of');
 if(!$pass = getArg('pass'))
  $pass = (ifset($cfg['pass'],'/^[ -~]+$/')) ? $cfg['pass'] : 'geheim';
 if(login(false,500)) {
  if($sid = (ifset($cfg['bsid'])) ? $cfg['bsid'] : login(0,0,true)) {// Login durchführen
   if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
    if($mode[1]) {					// Export
     if(is_dir($file)) {				// Im Ordner schreiben
      makedir($file);					// Verzeichnis erstellen
      $file = false;
     }
     $bug and dbug("Hole Konfiguration");		// Debug-Meldung für cfgexport
     if($data = cfgexport('array',$pass)) {		// Exportieren mit Entschlüsselten Benutzerdaten
      if($data[1] = konfigdecrypt($data[1],$pass,$sid)) {
       out(showaccessdata($data[1]));
       saverpdata($file,$data,'file.export');
      }
      else
       out(errmsg(0,'konfigdecrypt') || errmsg(0,'cfgexdport') || errmsg(0,'request'));
     }
     elseif(!ifset($data))				// Export direkt File
      out(cfgexport($file ? $file : true,$pass) ? "Konfiguation wurde erfolgreich exportiert" : errmsg(0,'request'));
     else
      out(($var = errmsg(0,'request')) ? $var : errmsg("8:Keine Konfig erhalten - Möglichlichweise ist noch die Sicherheits-Bestätigungsfunktion aktiviert?"));
    }
    elseif($mode[2]) {					// Extrakt
     if($data = cfgexport('array',$pass) and $data[1]) {// Konfigdaten holen
      $mode = $file ? ((preg_match($cfg['ptar'],$file,$var)) ? ((ifset($var[1])) ? 3 : 2) : 1) : 0;
      if($mode == 1)
       makedir($file);					// Verzeichnis erstellen
      if($data[2] = konfigdecrypt($data[1],$pass,$sid))	// Konfig Entschlüsseln
       out(cfginfo($data[2],$mode,$file,showaccessdata($data[2])));
     }
     else
      out(($var = errmsg(0,'request')) ? $var : errmsg("8:Keine Konfig erhalten - Möglichlichweise ist noch die Sicherheits-Bestätigungsfunktion aktiviert?"));
    }
    elseif($mode[3]) {					// Kennwörter aus Datei entschlüsseln
     if($save = getArg('if'))				// Argumente vertauschen?
      if($save == getArg('if',0,false) and $file == getArg('of',0,false)) {
       $file = getArg('if');
       $save = getArg('of');
      }
     if(is_file($file) and $data = (preg_match($cfg['ptar'],$file)) ? cfgmake(tar2array($file)) : file_contents($file)) {	// Datei laden
      if($data = konfigdecrypt($data,$pass,$sid)) {
       if($save) {					// Datei speichern
        if(preg_match('/^(.*?)[\\\\\/]$/',$save,$var)) {	// Verzeichnis erstellen
         makedir($save);
         $mode = 1;
        }
        elseif(preg_match($cfg['ptar'],$save,$var))
         $mode = (ifset($var[1])) ? 3 : 2;
        else {
         file_contents($save,$data);			// Entschlüsselte Konfig sichern
         $mode = 0;
        }
       }
       else
        $mode = 0;
       out(cfginfo($data,$mode,$save,showaccessdata($data)));	// Daten als Text Präsentieren
      }
      else {
       out(errmsg(0,'konfigdecrypt'));
       if(!ifset($pass,'/^[ -~]+$/'))
        out(errmsg("1:Hinweis: Das Konfig-Kennwort enthält Sonderzeichen, die bei unterschiedlicher Zeichenkodierung Probleme bereiten können"));
      }
     }
    }
   }
   else
    out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
   if(!ifset($cfg['bsid']))				// Abmelden
    logout($sid);
  }
  else
   out(errmsg(0,'login'));				// Login fehlgeschlagen
 }
 else
  out(errmsg("64:Entschlüsselung wird von Fritz!OS nicht unterstützt"));
}
else
 out(errmsg("2:Parameter müssen korrekt angegeben werden"));

?>
