<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");

 $plugin = "Telefonbuch 0.06 (c) 24.03.2025 by Michael Engelke"; // (charset=iso-8859-1 / tabs=8 / lines=lf)
 $info = 'Listet die Einträge des Telefonbuches auf oder Exportiert das Telefonbuch in ein Verzeichnis oder Archiv';
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.01 04.11.2019
 - Erste Version
0.02 23.03.2021
 - Anpassung an fb_Tools 0.30+
0.03 01.12.2022 (Danke an Alexander-Palm.de für den Ansporn)
 - NEU: Plugin-Umbennung in "Telefonbuch"
 - NEU: Parameter list und export hinzugekommen
 - Anpassung an fb_Tools 0.32+
 - Jetzt können automatisch alle Telefonbücher exportiert werden
 - Anzeige für ein Telefonbuch in der Console
0.04 05.05.2024
 - Hilfe verbessert
0.05 04.11.2024
 - Hilfe verbessert
0.06 23.03.2025
 - Hilfe an fb_Tools 0.46+ angepasst
*/
 if(ifset($cfg['help']) or !$func = getArg('func','/^((?P<e>e(xport)?)|(?P<l>l(ist)?))$/i'))
  out("$plugin\n$info\n\n$splug[2] [func] <buch|save>\n
Funktionen (func):\n{{{tt}
List|<buch>|Übersicht aller Telefonbücher ausgeben oder ein Telefonbuch anzeigen
Export|<save>|Exportiert das Telefonbuch in ein Verzeichnis oder Archiv}}".(preg_match('/[ab]/i',$cfg['help']) ? "\n
Beispiele:\n$self $cfg[fbhp] plugin $plug list
$self $cfg[fbhp] $plug list telefonbuch
$self $cfg[fbhp] $plug export Desktop/Telefonbücher.zip" : "")."\n");
 else {
  if($sid = (ifset($cfg['bsid'])) ? $cfg['bsid'] : login()) { // Login durchführen
   if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
    $bug and dbug("Lade Telefonbücher");
    $files = array();
    $list = array(0 => "Telefonbuch");
    if($cfg['fiwa'] > 690 and $data = request('POST',"/data.lua","page=bookLi&sid=$sid")	// Telefonbücher ermitteln ab Fritz!OS 7.00
	and preg_match('!<ul[^>]*>.*?</ul>!s',$data,$var) and preg_match_all('!<li[^>]*><a[^>]*?(\b\d\b)[^>]*?>(.*?)</a></li>!',$var[0],$m))
     foreach($m[1] as $key => $var)
      $list[intval($var)-1] = $m[2][$key];
    elseif($cfg['fiwa'] > 530 and $data = request("GET",$var = "/fon_num/fonbook_select.lua","sid=$sid")	// Telefonbücher ermitteln für Fritz!OS 5.50 - 6.90
	and preg_match('!<form[^>]*?'.$var.'[^>]*?>.*?</form>!s',$data,$var) and preg_match_all('!<label for="uiBookid:(\d+)">(.*?)\s*</label>!s',$var[0],$m)
	or $data = request("GET",$var = "/cgi-bin/webcm",array('sid' => $sid, 'getpage' => '../html/de/menus/menu2.html', 'var:pagename' => 'fonbuch', 'var:menu' => 'fon'))	// Für Fritz!OS älter als 5.2
	and preg_match_all('/\bgPhoneBooks\.books\[\d+\] = \{\s*Id: "(\d+)",\s*Name: "([^"]*)"\s*\};/',$data,$m))
     $list = array_combine($m[1],$m[2]);
    if($list) {								// Telefonbücher vorhanden
     if(ifset($func['l'])) {
      if($buch = getArg('buch') and ($id = preg_array('/^'.preg_quote($buch,'/').'$/i',$list,4)) !== false
	and $xml = request('POST','/cgi-bin/firmwarecfg',array('sid' => $sid, 'PhonebookId' => $id, 'PhonebookExportName' => $list[$id], 'PhonebookExport' => false))
	and preg_match_all('!<(contact)>(.*?)</\1>!',str_replace("\n"," ",$xml),$m)) {
       $list = array();
       foreach($m[2] as $key => $var) {
        $array = xml2array($var);
        $bug and dbug($array,9);
        if($name = ifset($array['person']['realName'],"") and ifset($array['telephony']['number'])) {
         $list[$name] = array('date' => '', 'mail' => '', 'call' => array());
         if(isset($array['telephony']['number']['_attribute']))
          $list[$name]['call'][$array['telephony']['number'][0]] = $array['telephony']['number']['_attribute']['type'];
         else
          foreach($array['telephony']['number'] as $var)
           $list[$name]['call'][$var[0]] = $var['_attribute']['type'];
         if($var = ifset($array['mod_time'],""))
          $list[$name]['date'] = strftime('%d.%m.%Y %X',$var);
         if(isset($array['services']['email'][0]))
          $list[$name]['mail'] = $array['services']['email'][0];
        }
       }
       $bug and dbug($list,9);
       $rep = array('home' => 'Privat', 'work' => 'Arbeit', 'mobile' => 'Mobil', 'fax_work' => 'Fax');
       $out = "Name |Type |Telefonnummer |eMail |Letzte Änderung\n";
       foreach($list as $key => $var) {
        $a = 0;
        foreach($var['call'] as $num => $art)
         $out .= ($a ? "" : $key)." |".strtr($art,$rep)." |$num |".($a ? "" : $var['mail'])." |".($a++ ? "" : $var['date'])."\n";
       }
       out(texttable(html_entity_decode($out),0,"|","\n","|"," "));
      }
      else {
       $bug and dbug(compact(explode(',','buch,id,xml,m')));
       out(texttable("Telefonbücher:|".html_entity_decode(implode(', ',$list))));
      }
     }
     elseif(ifset($func['e'])) {
      $save = getArg('save',"",'.');
      $bug and dbug($list,9);
      foreach($list as $key => $var)					// Telefonbuch herunterladen
       if($m = request('POST-array','/cgi-bin/firmwarecfg',array('sid' => $sid, 'PhonebookId' => $key, 'PhonebookExportName' => $var, 'PhonebookExport' => false)))
        $files[(isset($m['Content-Disposition']) and preg_match('/filename="(.*?)"/i',$m['Content-Disposition'],$val)) ? $val[1] : $var] =
	array('time' => isset($m['Last-Modified']) ? strtotime($m['Last-Modified']) : (isset($m['Date']) ? strtotime($m['Date']) : time()), 'data' => $m[1]);
      if($files)
       if($var = ifset($save,$cfg['ptar'])) {				// Daten als Archiv schreiben
        if($var[4]) {
         $bug and dbug("Erstelle ZIP-Archiv ...",0,10);
         file_contents($save,data2zip($files));
        }
        elseif($fp = file_stream($save,1)) {
         $bug and dbug("Erstelle TAR-Archiv ...",0,10);
         foreach($files as $file => $data)
          file_stream($fp,data2tar($file,$data['data'],$data['time']));
         file_stream($fp,str_repeat("\0",512));
         file_stream($fp);
        }
        $bug and dbug(" done");
       }
       else {								// Daten in Dateien schreiben
        $bug and dbug("Schreibe Dateien");
        if($save)
         if(file_exists($save) and is_dir($save))
          chdir($save);
         else
          makedir($save);
        foreach($files as $file => $data) {
         $bug and dbug("$file ...",0,10);
         file_contents($file,$data['data']);
         touch($file,$data['time']);
         $bug and dbug(" done");
        }
       }
      else
       out(errmsg("8:Keine Telefonbücher erhalten"));
     }
    }
    else
     out(errmsg("8:Keine Telefonbücher gefunden"));
   }
   else
    out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
   if(!ifset($cfg['bsid']))						// Abmelden
    logout($sid);
  }
  else
   out(errmsg(0,'login'));						// Login fehlgeschlagen
 } 

?>
