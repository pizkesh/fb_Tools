<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "StrfTime 0.02 (c) 23.03.2025 by Michael Engelke";
 $info = 'Zeigt alle von fb_Tools unterstützten StrfTime Formatierungen';
 $meta = '{fbt:0.46}'; /*

Plugingeschichte:
0.01 05.08.2024
 - Erste Version
0.02 23.03.2025
 - Hilfe an fb_Tools 0.46+ angepasst

*/
 if(ifset($cfg['help'])) {					// Hilfe Ausgeben bei -h
  out("$plugin\n$info\n\n$self <PlugIn> [plug:$plug] <func:StrfTime|Date> <time>".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:\n$self $plug\n$self $plug date\n$self $plug time:".$qt.$strftime("%F %X").$qt."\n$self info strftime" : "")."\n");
  if(ifset($cfg['uplink']))
   $opts .= "StrfTime:|-ot||StrfTime vom Betriebssystem nutzen";
 }
 else {
  $func = getArg('func','/^(?:(strftime|st)|(date|d)|(test|t))($)/i');
  if(!$func or !$func[3]) {
   $time = ($var = getArg('time') and $var = strtotime($var)) ? $var : microtime(true);
   if(is_string($time) and $var = explode(' ',$time) and count($var) == 2)
    $time = $var[0] + $var[1];
  }

  if(!$func or $func[1]) {	// StrfTime Tabelle anzeigen
   $group = array(
	'Wochentag' => 'A,a,+u,+w',
	'Woche'	=> 'U,V,W',
	'Tag'	=> 'd,e,j,o',
	'Monat'	=> 'B,b,h,L,m,N,-w',
	'Jahr'	=> 'C,G,g,-u,Y,y',
	'Stunden' => 'H,I,k,l,P,p',
	'Minuten'=> 'M',
	'Sekunden'=> 'f,S',
	'Zeit'	=> 'E,K',
	'Zeitzone' => 'v,Z,z',
	'Datumstempel' => 'D,F,q,x',
	'Zeitstempel' => 'Q,R,r,T,X',
	'Stempel' => 'c,J,O,s',
	'Zeichen' => 'n,t,%',
	'Ungenutzt' => 'i',
   );
   $info = array(
	'-A' => 'Wochtagsname [en] (Monday-Sunday)',
	'A' => 'Wochtagsname [de] (Montag-Sonntag)',
	'-a' => 'Abgekürzter Wochtagsname [en] (Mon-Sun)',
	'a' => 'Abgekürzter Wochtagsname [de] (Mon-Son)',
	'-B' => 'Monatsname [en] (January-December)',
	'B' => 'Monatsname [de] (Januar-Dezember)',
	'-b' => 'Abgekürzter Monatsname [en] (Jan-Dec)',
	'b' => 'Abgekürzter Monatsname [de] (Jan-Dez)',
	'C' => 'Jahrtausend Zweistellig (19-20)',
	'c' => 'Lokales Datum mit Uhrzeit',
	'-c' => 'Alias für "%a %b %e %T %Y"',
	'D' => 'Alias für "%m/%d/%y"',
	'd' => 'Tag des Monats Zweistellig (01-31)',
	'-d' => 'Tag des Monats (1-31)',
	'E' => 'Sekunden des Tages (0-86399)',
	'e' => 'Tag des Monats mit Leerzeichen ( 1-31)',
	'-e' => 'Alias für "%-d"',
	'F' => 'Alias für "%Y-%m-%d"',
	'f' => 'Millisekunden (000-999)*',			// Non Standard
	'-f' => 'Millisekunden (0-999)*',			// Non Standard
	'G' => 'Jahr Vierstellig nach ISO-8601:1988 (0000-9999)',
	'g' => 'Jahr Zweistellig nach ISO-8601:1988 (00-99)',
	'H' => 'Stunde 24h Zweistellig (00-23)',
	'-H' => 'Stunde 24h (0-23)',
	'h' => 'Alias für "%b"',
	'-h' => 'Maximale Tage im Monat (28-31)*',		// Non Standard
	'I' => 'Stunde 12h Zweistellig (00-11)',
	'-I' => 'Stunde 12h (0-11)',
	'J' => 'Datum nach RFC 2822 / RFC 5322*',		// Non Standard
	'-J' => 'Datum nach ISO-8601:1988*',			// Non Standard
	'j' => 'Tage vom Jahr vergangen (001-366)',
	'-j' => 'Tage vom Jahr vergangen (0-365)*',		// Non Standard
	'K' => 'Biel Mean Time (000-999)*',			// Non Standard
	'-K' => 'Biel Mean Time (0-999)*',			// Non Standard
	'k' => 'Stunde 24h mit Leerzeichen ( 0-24)',
	'-k' => 'Alias für "%-H"',
	'L' => '12 Sternzeichen [de] (Steinbock-Schütze)*',	// Non Standard
	'-L' => '12 Sternzeichen [en] (Capricorn-Sagittarius)*',// Non Standard
	'l' => 'Stunde 12h mit Leerzeichen ( 0-12)',
	'-l' => 'Alias für "%-I"',
	'M' => 'Minute Zweistellig (00-59)',
	'-M' => 'Minute (0-59)',
	'm' => 'Monat Zweistellig (00-12)',
	'-m' => 'Monat (1-12)',
	'N' => '13 Sternzeichen [de] (Schütze-Schlangenträger)*',// Non Standard
	'-N' => '13 Sternzeichen [en] (Sagittarius-Ophiuchus)*',// Non Standard
	'n' => 'Alias für "\n"',
	'O' => 'Lokales Datum mit Uhrzeit*',			// Non Standard
	'o' => 'Ordinal indicator ("st","nd","rd","th")*',	// Non Standard
	'-o' => 'Tage bis zum Ostersonntag (81-115)*',		// Non Standard
	'P' => 'Stunde ("am","pm")',
	'p' => 'Stunde ("AM","PM")',
	'Q' => 'Lokale Uhrzeit*',				// Non Standard
	'q' => 'Lokales Datum-Format*',				// Non Standard
	'R' => 'Alias für "%H:%M"',
	'r' => 'Alias für "%I:%M:%S %p"',
	'S' => 'Sekunden Zweistellig (00-59)',
	'-S' => 'Sekunden (0-59)',
	's' => 'Unix UTC Timestamp (Sekunden seit 1970)',
	'T' => 'Alias für "%H:%M:%S"',
	't' => 'Alias für "\t"',
	'U' => 'Kalenderwoche, ab dem ersten Sonntag in der ersten Woche (00-53)',
	'-U' => 'Kalenderwoche, ab dem ersten Sonntag in der ersten Woche (0-53)',
	'u' => 'Wochentag nach ISO-8601:1988 (1-7) [Mo-So]',
	'-u' => 'Jahr ist ein Schaltjahr (0-1)*',		// Non Standard
	'V' => 'Kalenderwoche, ab dem ersten Donnerstag in der ersten Woche (00-53) Nach ISO-8601:1988',
	'-V' => 'Kalenderwoche, ab dem ersten Donnerstag in der ersten Woche (0-53) Nach ISO-8601:1988',
	'v' => 'Zeitverschiebung zu UTC in Sekunden (+/-43200)*',// Non Standard
	'-v' => 'Zeitverschiebung zu UTC (+/-12:00)*',		// Non Standard
	'W' => 'Kalenderwoche, ab dem ersten Montag der ersten Woche (00-53)',
	'-W' => 'Kalenderwoche, ab dem ersten Montag der ersten Woche (0-53)',
	'w' => 'Wochentag (0-6) [So-Sa]',
	'-w' => 'Sommerzeit (0-1)*' ,				// Non Standard
	'X' => 'Lokalew Uhrzeit-Format',
	'-X' => 'Alias für "%T"',
	'x' => 'Lokales Datum-Format',
	'-x' => 'Alias für "%D"',
	'Y' => 'Jahr Vierstellig (0000-9999)',
	'-Y' => 'Jahr (0-9999)',
	'y' => 'Jahr Zweistellig (00-99)',
	'-y' => 'Jahr Zweistellig (0-99)',
	'Z' => 'Zeitzonenkürzel (z.B. MESZ)',
	'-Z' => 'Zeitzonennamen (z.B. Europe/Berlin)*',		// Non Standard
	'z' => 'Zeitverschiebung zu UTC (+/-1200)',
	'%' => 'Alias für "%"',
   );
   $date = array(
	'-A' => 'l',
	'-a' => 'D',
	'-B' => 'F',
	'-b' => 'M',
	'-c' => 'D M j H:i:s Y',
	'D' => 'm/d/y',
	'd' => 'd',
	'-d' => 'j',
	'-e' => 'j',
	'F' => 'Y-m-d',
	'f' => 'v',
	'G' => 'o',
	'H' => 'H',
	'-H' => 'G',
	'h' => 'M',
	'-h' => 't',
	'I' => 'h',
	'-I' => 'g',
	'J' => 'r',
	'-J' => 'c',
	'-j' => 'z',
	'K' => 'B',
	'-k' => 'G',
	'-l' => 'g',
	'M' => 'i',
	'm' => 'm',
	'-m' => 'n',
	'O' => 'j.n.Y, H:i:s',
	'o' => 'S',
	'P' => 'a',
	'p' => 'A',
	'Q' => 'H:i:s',
	'q' => 'j.n.Y',
	'R' => 'H:i',
	'r' => 'h:i:s A',
	'S' => 's',
	's' => 'U',
	'T' => 'H:i:s',
	'u' => 'N',
	'-u' => 'L',
	'V' => 'W',
	'v' => 'Z',
	'w' => 'w',
	'-w' => 'I',
	'X' => 'H:i:s',
	'x' => 'd.m.Y',
	'-x' => 'm/d/y',
	'Y' => 'Y',
	'y' => 'y',
	'Z' => 'T',
	'-Z' => 'e',
	'z' => 'O',
   );
   $str = "Gruppe|Format und Ausgabe|Date-Alias|Beschreibung\n";
   foreach($group as $gk => $gv) {
    $gv = explode(',',$gv);
    for($a = 0; $a < count($gv); $a++) {
     $gx = substr($gv[$a],-1);
     if($gv[$a][0] != '-' and strval($b = $strftime("%".$gx,$time)) and $b != "%$gx")
      $str .= ($a ? "|" : "$gk |")."%$gx  ".strtr($b,array("\n" => '\n', "\t" => '\t'))." |".(isset($date[$gx]) ? $date[$gx]/*."  ".date($date[$gx],floor($time))*/ : "")." |".$info[$gx]."\n";
     if($gv[$a][0] != '+' and strval($c = $strftime("%-$gx",$time)) and $b !== $c and $c != "%-".$gx)
      $str.= "|%-$gx $c |".(isset($date["-".$gx]) ? $date["-".$gx]/*."  ".date($date["-".$gx],floor($time))*/ : "")."|".(isset($info["-".$gx]) ? $info["-".$gx] : (isset($info[$gx]) ? $info[$gx] : ""))."\n";
    }
   }
   out(textTable($str,0,"|","\n",array("|","|","|"))."\n\n(*) -> Non Standard");
   if(!$func)
   out("\nWeitere Formatierungen für Date() über StrfTime erhalten sie mit:\n$self $plug date\n\nOder eine kurzübersicht mit: $self info strftime");
  }
  elseif($func[2]) {		// Date-Tabelle anzeigen (mit StrfTime aufruf [Non Standard])
   $group = array(
	'Wochentag' => 'DlNw',
	'Woche' => 'W',
	'Tag' => 'djStz',
	'Monat' => 'FmMn',
	'Jahr' => 'LoYy',
	'Stunden' => 'AaGgHh',
	'Minuten' => 'i',
	'Sekunden' => 'suv',
	'Zeit' => 'B',
	'Zeitzone' => 'eIOPpTZ',
	'Zeitstempel' => 'crU',
	'Ungenutzt' => 'bCEfJKkQqRVXx',
   );
   $info = array(
	'A' => 'Stunde ("AM","PM")',
	'a' => 'Stunde ("am","pm")',
	'B' => 'Biel Mean Time (000-999)',
	'c' => 'Datum nach ISO 8601',
	'D' => 'Abgekürzter Wochtagsname English (Mon-Sun)',
	'd' => 'Tag des Monats Zweistellig (01-31)',
	'e' => 'Zeitzonennamen (z.B. Europe/Berlin)',
	'F' => 'Monatsname English (January-December)',
	'G' => 'Stunde 24h (0-23)',
	'g' => 'Stunde 12h (0-11)',
	'H' => 'Stunde 24h Zweistellig (00-23)',
	'h' => 'Stunde 12h Zweistellig (00-11)',
	'I' => 'Sommerzeit (0-1)',
	'i' => 'Minute Zweistellig (00-59)',
	'j' => 'Tag des Monats (1-31)',
	'L' => 'Jahr ist ein Schaltjahr (0-1)',
	'l' => 'Wochtagsname English (Monday-Sunday)',
	'M' => 'Abgekürzter Monatsname English (Jan-Dec)',
	'm' => 'Monat Zweistellig (00-12)',
	'N' => 'Wochentag nach ISO-8601 (1-7) [Mo-So]',
	'n' => 'Monat (0-12)',
	'O' => 'Zeitverschiebung zu UTC (+/-1200)',
	'o' => 'Jahreszahl gemäß ISO 8601-Wochennummer (Entspricht "Y" außer z.B. 1999, 2003)',
	'P' => 'Differenz zur Greenwich-Zeit (GMT) (z.B. +02:00, +00:00)',
	'p' => 'Differenz zur Greenwich-Zeit (GMT) (z.B. +02:00, Z)',
	'r' => 'Datum nach RFC 2822 / RFC 5322',
	'S' => 'Ordinal indicator ("st","nd","rd","th")',
	's' => 'Sekunden Zweistellig (00-59)',
	'T' => 'Zeitzonenkürzel (z.B. MESZ)',
	't' => 'Maximale Tage im Monat (28-31)',
	'U' => 'Unix UTC Timestamp (Sekunden seit 1970)',
	'u' => 'Millisekunden (000000-999999)',
	'v' => 'Millisekunden (000-999)',
	'W' => 'Kalenderwoche, ab dem ersten Donnerstag in der ersten Woche (00-53) Nach ISO-8601:1988',
	'w' => 'Wochentag (0-6) [So-Sa]',
	'X' => 'Jahr Erweitert (-9999-+10000)',
	'x' => 'Jahr Erweitert (-10000-0000-9999-+10000)',
	'Y' => 'Jahr Vierstellig (0000-9999)',
	'y' => 'Jahr Zweistellig (00-99)',
	'Z' => 'Zeitverschiebung zu UTC in Sekunden (+/-43200)',
	'z' => 'Tage vom Jahr vergangen (0-365)',
   );
   $ftime = array(
	'A' => '%p',
	'a' => '%P',
	'B' => '%K *',
	'c' => '%-J *',
	'D' => '%-a',
	'd' => '%d',
	'e' => '%-Z *',
	'F' => '%-B',
	'G' => '%-H',
	'g' => '%-I',
	'H' => '%H',
	'h' => '%I',
	'i' => '%M',
	'I' => '%-w *',
	'j' => '%-d',
	'l' => '%-A',
	'L' => '%-u *',
	'm' => '%m',
	'M' => '%-b',
	'N' => '%u',
	'n' => '%-m',
	'o' => '%G',
	'O' => '%z',
	'r' => '%J *',
	'S' => '%o *',
	's' => '%S',
	'T' => '%Z',
	't' => '%-h',
	'u' => '%6f',
	'U' => '%s',
	'v' => '%f *',
	'W' => '%V',
	'w' => '%w',
	'Y' => '%Y',
	'y' => '%y',
	'Z' => '%v *',
	'z' => '%-j *',
   );
   $str = "Gruppe|Format und Ausgabe|StrfTime|Beschreibung\n";
   foreach($group as $gk => $gv)
    for($a = 0; $a < strlen($gv); $a++)
     if(strval($b = date($gv[$a],floor($time))) and $b != $gv[$a])
      $str .= ($a ? "|" : "$gk |")."%!".$gv[$a]." $b |".(isset($ftime[$gv[$a]]) ? /*str_pad(*/$ftime[$gv[$a]]/*,6,' ').$strftime(str_replace(' *','',$ftime[$gv[$a]]))*/ : "")." |".$info[$gv[$a]]."\n";
   out(textTable($str,0,"|","\n",array("|","|","|"))."\n\n(*) -> Non Standard");
  }
  elseif($func[3] and function_exists('strftime')) {
   if($str = getArg('str')) {
    if(!$from = strtotime(getArg('start')))
     $from = time();
    if(!$to = strtotime(getArg('end')))
     $to = time();
    $step = getArg('step','/^\d+$/0',24 * 60 * 60);
    $ftime = getArg('-ft',0,$cfg['fstr']);
    out($strftime("Start: $cfg[fstr]%n",$from).$strftime("End: $cfg[fstr]%n",$to));
    for($c = $d = 0, $time = $from; $time < $to; $time += $step) {
     $a = str_ftime($str,$time);
     $b = @strftime($str,$time);
     $c++;
     if($a != $b) {
      out($strftime($ftime,$time)." - $a - $b -> fail");
      $d++;
     }
    }
    out(compact(explode(',','c,d,str,from,to,step')));
   }
   else
    out("$self <PlugIn> [plug:$plug] [func:test] [str:strftime] <start:time> <end:time> <step:secs>\n\n");
  }
  else
   out(errmsg("64:Computer sagt NEIN!"));
 }

?>
