<?php if(!defined('fb_tools')) die("Plugin-File for fb_tools");	// (charset=iso-8859-1 / tabs=8 / lines=lf / lang=de)

 $plugin = "SQLDB 0.11 (c) 20.06.2026 by Michael Engelke";
 $info = 'Schreibt die Anrufliste, Ereignisse oder Traffic-Zähler in eine SQL-Datenbank';
 $meta = '{php:5.3,fbt:0.46,fos:4.0}'; /*

Plugingeschichte:
0.01 13.11.2020
 - Erste Version
0.02 16.11.2020
 - Querys können mehrere Spalten mit den selben Namen haben
0.03 23.03.2021
 - BUG: Mash-Name wurde beim abgleich mit der Fritz!Box nicht übernommen
 - BUG: Beim Export der Anrufliste wurde alle Einträge verdoppelt
 - FIX: Sehr größe Tabellen konnten nicht exportiert werden
 - Tabellen-Prüfung bei Abfragen gelockert
 - Anpassung an fb_Tools 0.30+
0.04 01.12.2022
 - FIX: Es wurden keine Tabellen-Prefixe, die Zahlen enthielten erkannt
 - Anpassung an fb_Tools 0.32+ und PHP 8.x
0.05 26.01.2023
 - BUG: Bei der Erstellung von SQLite-Tabellen konnte der Indexname nicht mit -pm beeinflusst werden
 - FIX: strftime verwendete falsche Platzhälter
 - FIX: Die [vars]-Tablelle wird jetzt auf Exists geprüft
 - Beispiele verbessert
0.06 05.05.2024
 - Hilfe verbessert
0.07 23.06.2024
 - FIX: MySQL-Fehler führten zu Script-Abbruch
 - strftime defaultstring geändert
0.08 04.11.2024
 - Hilfe verbessert
0.09 23.03.2025
 - Hilfe an fb_Tools 0.46+ angepasst
0.10 23.07.2025
 - BUG: Zur Initalisierung der PHP-Plugins wurde noch die alte Funktion aufgerufen
0.11 10.06.2026
 - BUG: Es wurde immer ein SQLite Query ausgeführt, der bei MySQL/MariaDB fehlgelagen ist

Voreinstellungen in fb_config.json:
#{ plugin: {

 sqldb: {// SQLDB Plugin begin
  preset: {
   mydb: {		// Name frei wählbar
    type: "mysqli",
    host: "localhost",
    port: 3306,
    user: "root",
    pass: "",
    base: "fb_tools"
   },
   lite: {		// Name frei wählbar
    type: "sqlite3",
    file: "/usr/local/share/fb_tools/sqlite.db"
   }
  }
 },	// SQLDB Plugin end

#}}
*/
function dbclose() {			// Datenbank schließen
 global $db;
 return ($db['type'] == DB_MYSQLI) ? mysqli_close($db['conn']) : (($db['type'] == DB_SQLITE3) ? $db['conn']->close() : false);
}
function dberror($mode=2) {		// Letzten Fehler zurückgeben
 global $db;
 $err = ($db['type'] == DB_MYSQLI) ? array(mysqli_errno($db['conn']),mysqli_error($db['conn']))
	: (($db['type'] == DB_SQLITE3) ? array($db['conn']->lastErrorCode(),$db['conn']->lastErrorMsg()) : false);
 return $db['error'] = $err ? ((isset($err[$mode])) ? $err[$mode] : (($mode == -1) ? $err : "($err[0]) $err[1]")) : false;
}
function dbescape($str) {		// String für den Query entwerten
 global $db;
 return ($db['type'] == DB_MYSQLI) ? mysqli_real_escape_string($db['conn'],$str) : (($db['type'] == DB_SQLITE3) ? $db['conn']->escapeString($str) : false);
}
function dbfetch($res,$opt=3) {		// Nächste Zeile vom Ergebnis zurückgeben
 global $db;
 return ($db['type'] == DB_MYSQLI) ? mysqli_fetch_array($res,$opt % 4) : (($db['type'] == DB_SQLITE3) ? $res->fetchArray($opt % 4) : false);
}
function dbfields($res,$num=false) {	// Feldnamen vom Ergebnis ermitteln
 global $db;
 if($num === false)
  for($a=0, $num=($db['type'] == DB_MYSQLI) ? mysqli_num_fields($res) : (($db['type'] == DB_SQLITE3) ? $res->numColumns() : false), $out=array(); $a < $num; $a++)
   $out[] = call_user_func(__FUNCTION__,$res,$a);
 else
  $out = ($db['type'] == DB_MYSQLI and $var = mysqli_fetch_field_direct($res,$num)) ? $var->name : (($db['type'] == DB_SQLITE3) ? $res->columnName($num) : false);
 return $out;
}
function dbid() {			// Letzte ID nach einen Insert zurückgeben
 global $db;
 return ($db['type'] == DB_MYSQLI) ? mysqli_insert_id($db['conn']) : (($db['type'] == DB_SQLITE3) ? $db['conn']->lastInsertRowID() : false);
}
function dbopen($base,$type,$opt=false){// Datenbank öffnen Host (all,user,pass,host,port,base) - host,user,pass,base,port
 $db = array('type' => $type, 'host' => $base, 'query' => array(), 'error' => false);
 if($opt and is_array($opt))
  $db = array_merge($db,$opt);
 if($type == DB_MYSQLI and is_array($base) and count($base) >= 5) {
  if(!$base['port'])
   $db['host']['port'] = $base['port'] = 3306;
  if(!$db['conn'] = mysqli_connect($base['host'],$base['user'],$base['pass'],$base['base'],$base['port']))
   $db['error'] = "(".mysqli_connect_errno().") ".mysqli_connect_error();
  elseif(!$var = mysqli_get_server_version($db['conn']) or $var < 401e2) {
   mysqli_close($db['conn']);
   $db['conn'] = false;
   $db['error'] = "MySQL wird ab Version 4.1 unterstützt.";
  }
 }
 elseif($type == DB_SQLITE3 and is_string($base['file']))
  if(!$db['conn'] = new SQLite3($base['file']))
   $db['error'] = "(".$db['conn']->lastErrorCode().") ".$db['conn']->lastErrorMsg();
  elseif(!($var = $db['conn']->version()) or !isset($var['versionNumber']) or $var['versionNumber'] < 3008e3) {
   $db['conn']->close();
   $db['conn'] = false;
   $db['error'] = "SQLite wird ab Version 3.8 unterstützt.";
  }
 return $db;
}
function dbquery($query,$opt=0) {	// Ein SQL-Befehl ausführen
 global $db;
 if($db['type'] == DB_MYSQLI)			// Querys an der verwendeten Datenbank anpassen
  if(!($opt & (DB_MYSQLI | DB_SQLITE3))) {	// Query direkt durchreichen?
   $out = array(
	'/(?<!)\[(?=[a-z_])(\w{2,16})\]/'	=> '`$1`',		// Alle [Tablename] in `Tablename` umwandeln
	'/\bBEGIN(?=;|\s*$)/i'		=> 'START TRANSACTION',
	'/(?<=\bAUTO)(?=INCREMENT\b)/i'	=> '_',
	'/\);\s*CREATE\s+(UNIQUE\s+)?INDEX\s+\[?([\w-]+)\]?\s+ON\s+\[?[\w-]+\]?\s+\(\[?([\w-]+)\]?(?=\);)/i' => ',$1 KEY `$2` (`$3`)',
   );
   $query = preg_replace(array_keys($out),array_values($out),$query);
  }
  else
   $opt &= ~(DB_MYSQLI | DB_SQLITE3);		// Option für Rekusion löschen
 $query = str_replace('','',$query);		// ESC-Zeichen löschen
 if($opt & DB_SQL)				// Nur Korrekten Query Zurückgeben
  return $query;
 elseif($db['query'] or ifset($db['sql']))	// Query-Debug
  $db['query'][] = $query;
 $out = false;
 if($opt & (DB_LINE | DB_COL)) {		// Single Query
  if($db['type'] == DB_MYSQLI) {		// MySQL
   if($res = dbquery($query,$opt & ~(DB_LINE | DB_COL)) and $out = dbfetch($res,($opt & DB_LINE) ? ($opt %4 ?: 1) : DB_NUM)) {
    if($opt & DB_COL)				// Single Column
     $out = $out[0];
    mysqli_free_result($res);			// Ergebnis freigeben (Für SQLite: $res->finalize())
   }
  }
  elseif($db['type'] == DB_SQLITE3)		// SQLite
   $out = $db['conn']->querySingle($query,(bool)($opt & DB_LINE));
 }
 else						// Exec oder Query
  if($db['type'] == DB_MYSQLI)
   $out = ($opt & DB_EXEC) ? mysqli_multi_query($db['conn'],$query) : mysqli_query($db['conn'],$query);
  elseif($db['type'] == DB_SQLITE3)
   $out = ($opt & DB_EXEC) ? $db['conn']->exec($query) : $db['conn']->query($query);
 return $out;
}
function sqlite_tool($s,$d,$c=null) {	// Toolkit für SQLite
 return is_null($c) ? ((is_int($d) and $d < 9) ? number_format($s,$d) : @strftime($s,strtotime($d))) : implode($d,array_slice(explode($d,$s),min(0,$c),abs($c)));
}

if(ifset($cfg['help']) or !getArg(true)) {		// Hilfe Ausgeben bei -h oder ohne Parameter
 if(!$cfg['help'] or $cfg['help'] === true)
  $cfg['help'] = -1;
 out("$plugin\n$info\n\n$splug[1] [func] [Database] <query|sql> <file>\n
Funktionen (func):\n{{{tt}
Call / AnrufListe||Anrufliste der Fritz!Box mit Datenbank abgleichen|(1)
Call-Export|<file>|Datenbank-Export der Anrufliste als CSV-Datei|(2,5)
Call-Import|[file]|Datenbank-Import der Anrufliste von einer CSV-Datei|(2,5,6)
Event / Ereignisse||Ereignisse der Fritz!Box mit Datenbank abgleichen|(1)
Event-Export|<file>|Datenbank-Export der Ereignisse als CSV-Datei|(2,5)
Event-Import|[file]|Datenbank-Import der Ereignisse von einer CSV-Datei|(2,5,6)
Traffic / Verkehr||Daten-Zähler der Fritz!Box mit Datenbank abgleichen|(1)
Traffic-Export|<file>|Datenbank-Export der Daten-Zähler als CSV-Datei|(2,5)
Traffic-Import|[file]|Datenbank-Import der Daten-Zähler von einer CSV-Datei|(2,5,6)
Init||Tabellen für die Anrufliste/Ereignisse erstellen|(2)
Query/Abfrage [sql]|<file>|Eigene Datenbank-Abfragen durchführen|(2,5)
Query [query]|<file>|Vorgefertigte Datenbank-Abfragen durchführen|(2,5)}}\n
Database:\n{{{tt,0,|,\n,; ; , }
[mysql:|'username:password@host:port/database']|MySQL oder Maria-DB|(3)
[sqlite:|'pfad/file.sdb']|SQLite (Lokale Datei)|(4)
[preset:|keyname]|Einstellung in fb_config.php|(3,4)}}\n
{{{tt}
(1)|Fritz!Box Anmeldung erforderlich |(2)|Ohne Fritz!Box nutzbar
(3)|Nur mit PHP-Erweiterung: mysqli |(4)|Nur mit PHP-Erweiterung: sqlite3
(5)|GZip/BZip2-Unterstützung |(6)|Verzeichnis mit mehreren Dateien}}
[ ] Pflicht | < > Optional | ( ) Auswahl".(ifset($cfg['help'],'/[ab]/i') ? "\n
Beispiele:
$self $cfg[fbhp] $plug mode:event mysql:'root:admin123@localhost/fb_tools'
$self $cfg[fbhp] $plug mode:call sqlite:'./fb_tools.sdb'
$self $cfg[fbhp] $plug mode:traffic preset:mydb
$self $plug sqlite:$qt./fb_tools.sdb$qt mode:traffic-export file:./traffic.csv -cs:$qt\\t$qt
$self $plug preset:mydb mode:call-import file:$qt/mnt/c/Users/John/Desktop/Anrufe/*.csv$qt -cs:$qt;$qt -d
$self $plug preset:lite query:event -lm:1000 -nl -rj
$self $plug preset:lite query:event-wlanmac -mu:Wohnzimmer -ft[,]:$qt%d.%m.%Y %H:%M:%S$qt,$qt%d.%m.%Y$qt,$qt%H:%M:%S$qt
$self $plug preset:mydb query sql:'select * from `traffic` order by time desc limit 100'" : "")."\n");
  $opts .= "SQLDB:|-ch||CSV-Header bei Datei-Export
|-cp:|[ansi\|utf8]|Zeichensatz der Datenbank-Tabelle (utf8)
|-cs:|[Seperator]|CSV-Separator festlegen
|-dt||Init: Führt ein 'Drop Table' vor 'Create Table' aus
|-f||Fehler Ignorieren
|-ft:|[strftime]|Eigenes Datumsformat bei Export
|-it:|[Name]|Init: Nur die eine Tabelle anlegen (call\|event\|traffic)
|-lm:|[limit]|Maximale Einträge bei Konsolen-Export
|-mu:|[String]|Ereignis-Abfragen nach Mesh-Gerät filtern
|-nl||'NULL' in Query-Result ausgeben
|-rj:|<Regex>|Optionaler Regulärer Ausdruck für Rechtsbündige Spalten
|-pf:|[String]|Präfix aller Datenbank-Tabellen
|-pm:|[String]|Präfix der Datenbank-Haupttabelle";
}
elseif($func = getArg('func','/^(((?P<c>al|c|anrufliste|call(list)?)|(?P<e>e|ereignisse|event)|(?P<t>t|traffic|v|verkehr))'
	.'(-((?P<x>e|export)|(?P<m>i|import)))?|(?P<i>i|init)|(?P<q>q|query|a|abfrage))($)/ix') or ifset($cfg['args']['query'])) { // Funktion abfragen
 if(!$func)
  $func = array('q' => 'query', 'i' => '');
 $bug and dbug($func,3);
 extract(array(	// Überschreibbare Variabeln
	'nl'	=> "\n",						// Newline
	'mvc'	=> 256,							// Max length for varchar
	'elm'	=> 1e5,							// Max Export Lines pro Select
	'date'	=> '(19|20)\d\d-[01]\d-[0-3]\d',			// Regex für das Datum
	'time'	=> '[0-2]\d(:[0-5]\d){2}',				// Regex für die Uhrzeit
	'dbvar' => explode(',','file,user,pass,host,port,base'),	// Datenbankangaben zum verbinden
	'tables'=> array('event,text','call,text','traffic','vars'),	// Tabellennamen
	'idx'	=> array_flip(array('event','call')),			// Index Time-Namen
	'idb'	=> '0none4mysqli8sqlite_3',				// Unterstützte Datenbanken (Const)
	'const' => '1assoc2num3both16exec32line64col128sql',		// Fetch & Query Constanten
	'sep'	=> strtr(getArg('-cs','/^.$/0',';'),array('\t' => "\t")),// Seperator für CSV-Dateien
	'ch'	=> getArg('-ch'),					// Dateiexport mit CSV-Header
	'cp'	=> ($var = getArg('-cp','/(iso.?8859.?1|ansi)|(utf.?8)/i0')) ? false : true,	// Charset der Tabellen
	'dt'	=> getArg('-dt'),					// Init: Führt ein 'Drop Table' vor 'Create Table' aus
	'f'	=> getArg('-f'),					// Fehler ignorieren
	'ft'	=> getArg('-ft',array()),				// Zeitformat für Query-Ergebnisse
	'ftime'	=> getArg('-ft',0,$cfg['fstr']),			// Zeitformat für Anzeige/Export
	'it'	=> getArg('-it','/^[\w-]+$/i0'),			// Init: Nur die eine Tabelle anlegen
	'lm'	=> getArg('-lm','/^(\d+,\s*)?(\d+)$/0',1e2),		// Maximale Konsoleausgabe
	'mu'	=> getArg('-mu','/^[\w\s.:-]+$/0') ?: getArg('-mu'),	// Query: Nach Mesh-Unit filtern
	'nu'	=> getArg('-nl'),					// 'NULL' in Query-Result ausgeben
	'rj'	=> getArg('-rj',0,'-?(?!0\d{2,})\d+(,\d{3})*(\.\d+)?%?'),// Regex mit Rechtsbündige spalten
	'pf'	=> getArg('-pf','/^[\w-]+$/i0'),			// Präfix aller Tabellen
	'pm'	=> getArg('-pm','/^[\w-]+$/i0'),			// Präfix nur für die Haupttabelle
	'txt'	=> array('event' => 'messages since'),			// Text für "[x Meldungen seit dd.mm.yy hh:ii:ss]"
 ),EXTR_SKIP);
 foreach($tables as $key => $var) {			// Tabellen-Array initialisieren
  unset($tables[$key]);
  $key = preg_replace('/,.*$/','',$var);		// Haupttabelle als Array-Key
  $tables[$key] = preg_replace('/,/',",{$key}_",$var);	// Präfix für Untertabellen
 }
 if($pm)						// Option -pm: Präfix nur für die Haupttabelle
  $tables = preg_replace("/^(?!$tables[vars])/",$pm,$tables);
 if($pf)						// Option -pf: Präfix aller Tabellen
  $tables = preg_replace('/(?<=^|,)/',$pf,$tables);
 foreach($idx as $key => $var)				// Indexnamen erstellen
  $idx[$key] = $pm.substr($key,0,1)."time";
 foreach(array('idb','const') as $val)			// Constanten festlegen
  if(preg_match_all('/(\d+)([a-z]+(?:_\d)*)/i',$$val,$m))
   foreach($$val = array_combine($m[1],str_replace('_','',$m[2])) as $key => $var)
    define('DB_'.strtoupper($var),$key);
 foreach($dbvar as $var)				// Datenbank-Variablen vordefinieren
  $$var = null;
 if($var = getArg('mysql','/^([\w.-]+):([^@\s]*)@([\w.:-]+?)(?::(\d+))?\/([\w.-]+)$/')) {	// MySQL-Parameter überprüfen
  extract(array_combine($dbvar,$var));
  $type = DB_MYSQLI;
  mysqli_report(MYSQLI_REPORT_STRICT);			// MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT | MYSQLI_REPORT_ALL
 }
 elseif(isset($preset) and $var = getArg( 'preset',null,true) and isset($preset[$var]))	// Vorkonfiguration vorhanden?
  extract($preset[getArg('preset')]);
 elseif($file = getArg('sqlite'))						// SQLite-Parameter überprüfen (Unbenannter-Parameter wurde von preset weggeschnappt)
  $type = DB_SQLITE3;
 if($type = isset($type) ? (is_string($type) ? array_search($type,$idb) : $type) : false) {
  if(init(5,$idb[$type])) {						// Datenbank-Plugin prüfen
   if($db = dbopen(compact($dbvar),$type,array('sql' => $cfg['dbug'] & (1<<9))) and ifset($db['conn'])) {
    if($type == DB_SQLITE3) {							// Zusatzfunktionen für SQLITE3
     $db['conn']->createFunction('substring_index','sqlite_tool',3);		// substring_index (Aus MySQL - Ähnliche Funktion wie array_slice)
     $db['conn']->createFunction('format','sqlite_tool',2);			// format (Aus MySQL - Ähnliche Funktion wie number_format und strftime)
     $db['conn']->createFunction('pregexp','preg_match',2);			// regexp (Aus MySQL regexp - Ersetzt mit Funktion preg_match)
    }
    if($f or $func['i'] or $func['q'] or $var = dbquery("select ".implode(',',
	preg_replace('/[\w-]+/',"(select 0 from [\$0] limit 0) as '\$0'",preg_array('/^['.implode('',array_keys(
	preg_array('/^[cet]$/',preg_grep('/./',$func),3))).']/',$tables,3))),DB_LINE)) {	// DB-Check
     foreach($tables as $key => $var)						// Tabellen in Array umwandeln
      $tables[$key] = explode(',',$var);
     $c = 0;									// Counter Initialisieren
     if(// dbquery("select [tbl_name] from [sqlite_master] where [type]='table' and [tbl_name]='{$tables['vars'][0]}'",DB_LINE) and 
	$res = dbquery("select [key],[value] from [{$tables['vars'][0]}]")) {// Variabeln aus der Datenbank setzen
      $vars = array();
      while($line = dbfetch($res,DB_ASSOC))
       $vars[$line['key']] = $line['value'];
      extract($vars);
     }
     $mu = $mu ? (is_bool($mu) ? array("\n\twhere e.[name] is null"," and e.[name] is null")	// SQL-Bedingung um nach Mesh-Unit zu filtern
	: array("\n\twhere e.[name] like '$mu'"," and e.[name] like '$mu'")) : array("","");
     $strftimes = array("/^$date\s$time$/","/^$date$/","/^$time$/");
     if($func['i']) {			// Init
      extract($tables);
      $vers = (preg_match('/^([\w-]+)\s+([\d.]+)/',$plugin,$var)) ? floatval($var[2]) : 'NULL';
      $time = date('Y-m-d H:i:s');
      $sql = array(
	'call' => "-- Anruf Tabellen erstellen
CREATE TABLE IF NOT EXISTS [$call[0]] (
	[id]		INTEGER		NOT NULL	PRIMARY KEY AUTOINCREMENT,
	[time]		DATETIME	NOT NULL,
	[duration]	TIME		NOT NULL,
	[type]		INTEGER		NOT NULL,
	[name]		INTEGER		DEFAULT NULL,
	[callnumber]	INTEGER		DEFAULT NULL,
	[extension]	INTEGER		DEFAULT NULL,
	[ownnumber]	INTEGER		DEFAULT NULL,
	[dupe]		INTEGER		DEFAULT NULL);
CREATE TABLE IF NOT EXISTS [$call[1]] (
	[id]		INTEGER		NOT NULL	PRIMARY KEY AUTOINCREMENT,
	[text]		VARCHAR($mvc)	NOT NULL	UNIQUE);
CREATE INDEX IF NOT EXISTS [$idx[call]] ON [$call[0]] ([time]);"
.preg_replace('/(\d)(\D+)/',"\nREPLACE INTO [$call[1]] ([id],[text]) VALUES (\$1,'\$2');","1in2ring3drop4out"),
	'event' => "-- Ereignis Tabellen erstellen
CREATE TABLE IF NOT EXISTS [$event[0]] (
	[id]		INTEGER		NOT NULL	PRIMARY KEY AUTOINCREMENT,
	[time]		DATETIME	NOT NULL,
	[text]		INTEGER		NOT NULL,
	[name]		VARCHAR($mvc)	DEFAULT NULL,
	[rp_num]	INTEGER		DEFAULT NULL,
	[rp_time]	DATETIME	DEFAULT NULL);
CREATE TABLE IF NOT EXISTS [$event[1]] (
	[id]		INTEGER		NOT NULL	PRIMARY KEY AUTOINCREMENT,
	[tab]		INTEGER		NULL,
	[code]		INTEGER		NULL,
	[text]		VARCHAR($mvc)	NOT NULL	UNIQUE);
CREATE INDEX IF NOT EXISTS [$idx[event]] ON [$event[0]] ([time]);
CREATE INDEX IF NOT EXISTS [tab] ON [$event[1]] ([tab]);"
.preg_replace('/(\d)(\d)(\D+)/',"\nREPLACE INTO [$event[1]] ([id],[tab],[text]) VALUES (\$1,\$2,'\$3');","10system20internet30telephony40wifi50usb"),
	'traffic' => "-- Traffic Tabellen erstellen
CREATE TABLE IF NOT EXISTS [$traffic[0]] (
	[date]		DATE		NOT NULL	PRIMARY KEY,
	[online]	TIME		NOT NULL,
	[connect]	INTEGER		NOT NULL,
	[download]	BIGINT		NOT NULL,
	[upload]	BIGINT		NOT NULL);",
	'vars' => "-- Variabeln Tabelle erstellen
CREATE TABLE IF NOT EXISTS [$vars[0]] (
	[key]		VARCHAR($mvc)	NOT NULL	PRIMARY KEY,
	[value]		VARCHAR($mvc)	NOT NULL);"
.preg_replace('/([^,;]+),([^;]+)/',"\nREPLACE INTO [$vars[0]] ([key],[value]) VALUES ('\$1','\$2')","sqbdb_version,$vers;sqldb_time,$time;"));
      if($dt)
       $sql = preg_replace('/CREATE TABLE IF NOT EXISTS (\[[\w-]+\])/',"DROP TABLE IF EXISTS \$1;\n\$0",$sql);
      if($it)
       $sql = preg_array("/$it/i",$sql,3);
      foreach($sql as $key => $var) {
       $bug and dbug("Init $key");
       if($querys = preg_split('/(?<=;)\r?\n/',$var))
        foreach($querys as $query)
         if((!$c or $f) and !dbquery($query,DB_EXEC) and ++$c and !$f)
          break 2;
      }
      out($c ? errmsg("64:Fehler: ".dberror()) : "Tabellen wurden erfolgreich angelegt");
     }
     elseif($func['q'] or ifset($cfg['args']['query'])) {	// Query
      extract($tables);
      $query = getArg('query','/^[\w-]+$/0');
      $limit = ($file = getArg('file')) ? "" : "\nlimit $lm";
      if(!$sql = getArg('sql')) {
       $queries = (isset($preset['queries'])) ? $preset['queries'] : array();
       $queries += array(
	'tables' => "-- Listet alle Tabellen auf
".(($type == DB_MYSQLI) ? "show tables" : (($type == DB_SQLITE3) ? "select tbl_name from sqlite_master where type = 'table'" : false)),
	'event' => "-- Listet alle Ereignisse auf,1
select	e.[time],
	e.[name],
	t.[tab],
	t.[code],
	t.[text],
	e.[rp_num],
	e.[rp_time]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]$mu[0]
order by e.[time] desc$limit",

	'event-dsl' => "-- Filtert Ereignisse mit DSL,1
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%dsl%'$mu[1]
order by e.[time] desc$limit",

	'event-internet' => "-- Filtert Ereignisse mit Internet,1,2
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where (t.[text] like 'Internetverbindung%' or t.[text] like 'ipv6%')$mu[1]
order by e.[time] desc$limit",

	'event-usb' => "-- Filtert Ereignisse mit USB,1
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%usb%'$mu[1]
order by e.[time] desc$limit",

	'event-fon' => "-- Filtert Ereignisse mit Telefon,1,2
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where (t.[text] like '%Telefon%' or t.[text] like '%Rufnummer%')$mu[1]
order by e.[time] desc$limit",

	'event-wlan' => "-- Filtert Ereignisse mit WLAN,1,2
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like 'wlan%'$mu[1]
order by e.[time] desc$limit",

	'event-ftp' => "-- Filtert Ereignisse mit FTP-Dienst,1,2
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%ftp%'$mu[1]
order by e.[time] desc$limit",

	'event-smb' => "-- Filtert Ereignisse mit Samba,1,2
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%SMB%'$mu[1]
order by e.[time] desc$limit",

	'event-vpn' => "-- Filtert Ereignisse mit VPN,1
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like 'vpn%'$mu[1]
order by e.[time] desc$limit",

	'event-logfail' => "-- Filtert Ereignisse mit Fehlgeschlagenen Anmeldungen,1,2
select	e.[time],
	e.[name] as [mesh],
	t.[text] as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%Anmeldung % gescheitert%'$mu[1]
order by e.[time] desc$limit",

	'event-login' => "-- Listet Logins auf,1,2
select	substring_index(substring_index(t.[text],'Benutzers ',-1),' ',1) as [user],
	substring_index(substring_index(t.[text],'IP-Adresse ',-1),' ',1) as [ip],
	format(count(*),0) as [count],
	min([time]) as [first],
	nullif(max([time]),min([time])) as [last]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%anmeldung%benutzers%ip-adresse%'$mu[1]
group by [user]
order by [user]$limit",

	'event-loginftp' => "-- Listet FTP-Login auf,1,2
select	substring_index(substring_index(t.[text],'Benutzers ',-1),' ',1) as [user],
	substring_index(substring_index(t.[text],'IP-Adresse ',-1),' ',1) as [ip],
	format(count(*),0) as [count],
	min([time]) as [first],
	nullif(max([time]),min([time])) as [last]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%Anmeldung%Benutzers%ftp-%'$mu[1]
group by [user]
union
select	substring_index(substring_index(t.text,'(',-1),')',1) as user,
	substring_index(substring_index(t.text,'IP-Adresse ',-1),' ',1) as ip,
	format(count(*),0) as [count],
	min([time]) as [first],
	nullif(max([time]),min([time])) as [last]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%Anmeldung%App%ftp-%'$mu[1]
group by [user]
order by [user]
$limit",

	'event-loginsmb' => "-- Listet Samba-Login auf,1,2
select	substring_index(substring_index(t.text,'Benutzers ',-1),' ',1) as [user],
	max(substring_index(substring_index(t.text,'IP-Adresse ',-1),' ',1)) as [ip],
	format(count(*),0) as [count],
	min(time) as [first],
	nullif(max([time]),min([time])) as [last]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%SMB-dienst%'$mu[1]
group by [user]
order by [user]$limit",

	'event-loginvpn' => "-- Listet VPN-Anmeldungen auf,1,2
select	[time],
	substring_index(substring_index(t.text,' zu ',-1),' ',1) as [host],
	substring_index(substring_index(t.text,'[',-1),']',1) as [ip],
	substring_index(substring_index(t.text,' IKE SA: ',-1),' ',1) as [ike],
	substring_index(substring_index(t.text,' IPsec SA: ',-1),' ',1) as [ipsec]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like 'vpn-verbindung%hergestellt.'$mu[1]
order by e.[time] desc$limit",

	'event-loginwlan' => "-- Listet WLAN-Anmeldungen auf,1,2
select	upper(substr(t.[text],-18,17)) as [mac],
	substring_index(substring_index(max(t.[text]),', ',-3),',',1) as [name],
	substr(substring_index(substring_index(max(t.[text]),',',-2),',',1),5) as [ip],
	format(count(*),0) as [count],
	min([time]) as [first],
	nullif(max([time]),min(time)) as [last],
	max(t.[text]) as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where	t.[text] like 'WLAN-Gerät % a_gemeldet%'
	and t.[text] like '%, IP%'
	and t.[text] like '%wlan%'
	and ".(($type == DB_MYSQLI)
	? "t.[text] regexp 'a[bn](ge)?meld(ung|et).*([0-9A-F]{2}:){5}[0-9A-F]{2}\.$'" : (($type == DB_SQLITE3)
	? "pregexp('/a[bn](ge)?meld(ung|et).*([0-9A-F]{2}:){5}[0-9A-F]{2}\.$/',t.[text])" : false))."$mu[1]
group by [mac]
order by [last] desc$limit",

	'event-mesh' => "-- Listet Mesh-Teilnehmer auf
select	ifnull([name],'Mesh!Master') as [name],
	format(count(*),0) as count,
	min([time]) as [first],
	nullif(max([time]),min([time])) as [last]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
group by [name]
order by [name]$limit",

	'event-users' => "-- Listet Fritz!Box Benutzer auf,1,2
select	substring_index(substr(t.[text],"
	.(($type == DB_MYSQLI) ? "locate('Benutzers',t.[text])"
	: (($type == DB_SQLITE3) ? "instr(t.[text],'Benutzers')" : false))."+10),' ',1) as [user],
	format(count(*),0) as [count],
	min(e.[time]) as [first],
	nullif(max(e.[time]),min(e.[time])) as [last],
	t.[text]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%benutzers%'$mu[1]
group by [user]
order by [user]$limit",

	'event-reboot' => "-- Ermittelt Neustarts,1,2,3
select	e.[time],"
	.($type == DB_MYSQLI ? "
	concat(datediff(ifnull(b.[time],now()),e.[time]),' days ',sec_to_time(time_to_sec(timediff(ifnull(b.[time],now()),e.[time]))%(60*60*24)))"
	: (($type == DB_SQLITE3) ? "
	((strftime('%s',ifnull(b.[time],'now'))-strftime('%s',e.[time]))/(60*60*24))||' days '||time((strftime('%s',ifnull(b.[time],'now'))-strftime('%s',e.[time]))%(60*60*24),'unixepoch')" : false))." as [duration]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
left join (	select [time]
		from [$event[0]] as e
		left join [$event[1]] as t on t.[id] = e.[text]
		where t.[text] like 'USB-Fernanschluss%''bulk'' gestartet.'$mu[1]
		order by e.[id]".(($type == DB_MYSQLI)
				? ") as b on b.[time] > e.[time]" : (($type == DB_SQLITE3)
				? " desc) as b on strftime('%s',b.[time]) > strftime('%s',e.[time])" : false))."
where t.[text] like 'USB-Fernanschluss%''bulk'' gestartet.'$mu[1]
group by e.[time]
order by e.[time] desc$limit",

	'event-dslspeed' => "-- Listet DSL-Verbindungen auf,1,2
select	[time],
	format(substring_index(substring_index(substring_index(substring_index(t.[text],'(',-1),' ',4),' ',-1),'/',1),0) as [down],
	format(substring_index(substring_index(substring_index(t.[text],'(',-1),' ',4),'/',-1),0) as [up]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%DSL-Synchronisierung besteht mit%'$mu[1]
order by e.[time] desc$limit",

	'event-ipv4' => "-- Listet externen IPv4-Adressen auf,1,2
select	e.[time],
	substring_index(substring_index(t.[text],'IP-Adresse: ',-1),',',1) as 'IP-Adresse',
	substring_index(substring_index(t.[text],'DNS-Server: ',-1),' und ',1) as 'DNS-Server 1',
	substring_index(substring_index(substring_index(t.[text],'DNS-Server: ',-1),' und ',-1),',',1) as 'DNS-Server 2',
	substring_index(substring_index(t.[text],'Gateway: ',-1),',',1) as 'Gateway'
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like 'Internetverbindung wurde erfolgreich hergestellt.%'$mu[1]
order by e.[time] desc$limit",

	'event-ipv6' => "-- Listet externen IPv6-Adressen auf,1,2
select	e.[time],
	substring_index(t.[text],': ',-1) as 'IPv6-Präfix'
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where (t.[text] like 'Internetverbindung IPv6 wurde erfolgreich hergestellt%' or t.[text] like 'ipv6%')$mu[1]
order by e.[time] desc$limit",

	'event-wlanmac' => "-- Listet WLAN-MAC-Adressen auf,1,2
select	upper(substr(t.[text],-18,17)) as [mac],
	min(e.[time]) as [first],
	nullif(max(e.[time]),min(e.[time])) as [last],
	format(count(*),0) as [count],
	max(t.[text]) as [log]
from [$event[0]] as e
left join [$event[1]] as t on t.[id] = e.[text]
where t.[text] like '%wlan%' and ".(($type == DB_MYSQLI)
	? "t.[text] regexp 'a[bn](ge)?meld(ung|et).*([0-9A-F]{2}:){5}[0-9A-F]{2}\.$'" : (($type == DB_SQLITE3)
	? "pregexp('/a[bn](ge)?meld(ung|et).*([0-9A-F]{2}:){5}[0-9A-F]{2}\.$/',t.[text])" : false))."$mu[1]
group by [mac]
order by [last] desc$limit",

	'event-callnumber' => "-- Listet Fritz!Box VoIP-Rufnummern auf,1,2
select	[number],
	format(sum([count]),0) as [count],
	min([first]) as [first],
	nullif(max([last]),min([first])) as [last]
from (	select	substring_index(substring_index(substring_index(t.[text],' ',4),' ',-1),'@',1) as [number],
		format(count(*),0) as [count],
		min(time) as [first],
		max(time) as [last]
	from [$event[0]] as e
	left join [$event[1]] as t on t.[id] = e.[text]
	where t.[text] like 'a_meldung der Internetrufnummer %'$mu[1]
	group by [number]
	union
	select	substring_index(substring_index(substring_index(t.[text],' ',3),' ',-1),'@',1) as [number],
		count(*) as [count],
		min([time]) as [first],
		max([time]) as [last]
	from [$event[0]] as e
	left join [$event[1]] as t on t.[id] = e.[text]
	where (t.[text] like 'Die Rufnummer %' or t.[text] like 'Internettelefonie mit %')$mu[1]
	group by [number]) as [numbers]
group by [number]
order by [number]$limit",

	'call' => "-- Listet alle Anrufe auf
select	c.[time],
	t.[text] as [type],
	n.[text] as [name],
	cn.[text] as [callnumber],
	e.[text] as [extension],
	no.[text] as [ownnumber],
	c.[duration],
	c.[dupe]
from [$call[0]] as c
left join [$call[1]] as t on t.[id] = c.[type]
left join [$call[1]] as n on n.[id] = c.[name]
left join [$call[1]] as cn on cn.[id] = c.[callnumber]
left join [$call[1]] as e on e.[id] = c.[extension]
left join [$call[1]] as no on no.[id] = c.[ownnumber]
order by c.[time] desc$limit",

	'call-book' => "-- Listet Anrufnummern auf
select	cn.[text] as [number],
	n.[text] as [name],
	format(count(*),0) as [count],
	".(($type == DB_MYSQLI)	? "sec_to_time(sum(c.[duration]))" : (($type == DB_SQLITE3) ? "time(sum(c.[duration]),'unixepoch')" : false))." as [duration],
	min([time]) as [first],
	nullif(max([time]),min([time])) as [last]
from [$call[0]] as c
left join [$call[1]] as n on n.id = c.[name]
left join [$call[1]] as cn on cn.id = c.[callnumber]
group by [callnumber]
order by [callnumber]$limit",

	'traffic-days' => "-- Zeigt den Täglichen Daten-Verkehr an
select	[date],
	".(($type == DB_MYSQLI)	? "concat(format(time_to_sec([online])/(60*60*24)*100,2),'%')" : (($type == DB_SQLITE3)
	? "format(cast((substr(online,0,instr(online,':'))*60+substr(online,-5,2))*60+substr(online,-2) as float)/(60*60*24)*100,2)||'%'" : false))." as [online],
	[online] as [time],
	format([connect],0) as [connect],
	format([download],0) as [download],
	format([upload],0) as [upload],
	format([download]+[upload],0) as [traffic]
from [$traffic[0]]
order by [date] desc$limit",

	'traffic-weeks' => "-- Zeigt den Wöchentlichen Daten-Verkehr an".(($type == DB_MYSQLI) ? "
select	year([date]) as [year],
	week([date]) as [week],
	concat(format(sum(time_to_sec([online])/60/60/24)/(to_days(max([date]))-to_days(min([date]))+1)*100,2),'%') as [online],
	concat(format(floor(sum(time_to_sec([online]))/(60*60*24)),0),' days ',sec_to_time(sum(time_to_sec([online]))%(60*60*24))) as [online_time],
	format(sum([connect]),0) as [connect],
	format(sum([download]),0) as [download],
	format(sum([upload]),0) as [upload],
	format(sum([download]+[upload]),0) as [traffic]
from [$traffic[0]]
group by yearweek([date])
order by [date] desc$limit" : (($type == DB_SQLITE3) ? "
select	[year],
	[week],
	format(cast([online] as float)/(60*60*24*[days])*100,2)||'%' as [online],
	([online]/(60*60*24))||' days '||time([online]%(60*60*24),'unixepoch') as [online_time],
	format([connect],0) as [connect],
	format([download],0) as [download],
	format([upload],0) as [upload],
	format([traffic],0) as [traffic]
from (	select	format('%Y',[date]) as [year],
		format('%V',[date]) as [week],
		(max(strftime('%s',[date]))-min(strftime('%s',[date])))/(60*60*24)+1 as [days],
		sum((substr([online],0,instr([online],':'))*60+substr([online],-5,2))*60+substr([online],-2)) as [online],
		sum([connect]) as [connect],
		sum([download]) as [download],
		sum([upload]) as [upload],
		sum([download]+[upload]) as [traffic]
	from [$traffic[0]]
	group by [year], [week])
order by [year] desc, [week] desc$limit" : false)),

	'traffic-months' => "-- Zeigt den Monatlichen Daten-Verkehr an".(($type == DB_MYSQLI) ? "
select	year([date]) as [year],
	month([date]) as [month],
	concat(format(sum(time_to_sec([online]))/(60*60*24*(to_days(max([date]))-to_days(min([date]))+1))*100,2),'%') as [online],
	concat(format(floor(sum(time_to_sec([online]))/(60*60*24)),0),' days ',sec_to_time(sum(time_to_sec([online]))%(60*60*24))) as [online_time],
	format(sum([connect]),0) as [connect],
	format(sum([download]),0) as [download],
	format(sum([upload]),0) as [upload],
	format(sum([download]+[upload]),0) as [traffic]
from [$traffic[0]]
group by year([date]), month([date])
order by [date] desc$limit" : (($type == DB_SQLITE3) ? "
select	[year],
	[month],
	format(cast([online] as float)/(60*60*24*[days])*100,2)||'%' as [online],
	([online]/(60*60*24))||' days '||time([online]%(60*60*24),'unixepoch') as [online_time],
	format([connect],0) as [connect],
	format([download],0) as [download],
	format([upload],0) as [upload],
	format([traffic],0) as [traffic]
from (	select	format('%Y',[date]) as [year],
		format('%m',[date]) as [month],
		(max(strftime('%s',[date]))-min(strftime('%s',[date])))/(60*60*24)+1 as [days],
		sum((substr([online],0,instr([online],':'))*60+substr([online],-5,2))*60+substr([online],-2)) as [online],
		sum([connect]) as [connect],
		sum([download]) as [download],
		sum([upload]) as [upload],
		sum([download]+[upload]) as [traffic]
	from [$traffic[0]]
	group by [year], [month])
order by [year] desc, [month] desc$limit" : false)),

	'traffic-years' => "-- Zeigt den Jährlichen Daten-Verkehr an".(($type == DB_MYSQLI) ? "
select	year([date]) as [year],
	concat(format(sum(time_to_sec([online]))/(60*60*24*(to_days(max([date]))-to_days(min([date]))+1))*100,2),'%') as [online],
	concat(format(floor(sum(time_to_sec([online]))/(60*60*24)),0),' days ',sec_to_time(sum(time_to_sec([online]))%(60*60*24))) as [online_time],
	format(sum([connect]),0) as [connect],
	format(sum([download]),0) as [download],
	format(sum([upload]),0) as [upload],
	format(sum([download]+[upload]),0) as [traffic]
from [$traffic[0]]
group by year([date])
order by [date] desc$limit" : (($type == DB_SQLITE3) ? "
select	[year],
	format(cast([online] as float)/(60*60*24*[days])*100,2)||'%' as [online],
	([online]/(60*60*24))||' days '||time([online]%(60*60*24),'unixepoch') as [online_time],
	format([connect],0) as [connect],
	format([download],0) as [download],
	format([upload],0) as [upload],
	format([traffic],0) as [traffic]
from (	select	format('%Y',[date]) as [year],
		(max(strftime('%s',[date]))-min(strftime('%s',[date])))/(60*60*24)+1 as [days],
		sum((substr([online],0,instr([online],':'))*60+substr([online],-5,2))*60+substr([online],-2)) as [online],
		sum([connect]) as [connect],
		sum([download]) as [download],
		sum([upload]) as [upload],
		sum([download]+[upload]) as [traffic]
	from [$traffic[0]]
	group by [year])
order by [year] desc$limit" : false)),

	'traffic-total' => "-- Zeigt die Summe des kompletten Daten-Verkehr an".(($type == DB_MYSQLI) ? "
select	distinct
	min([date]) as [first],
	max([date]) as [last],
	format(to_days(max([date]))-to_days(min([date]))+1,0) as [days],
	concat(format(sum(time_to_sec([online]))/(60*60*24)/(to_days(max([date]))-to_days(min([date]))+1)*100,2),'%') as [online],
	concat(format(floor(sum(time_to_sec([online]))/(60*60*24)),0),' days ',sec_to_time(sum(time_to_sec([online]))%(60*60*24))) as [online_time],
	format(sum([connect]),0) as [connect],
	format(sum([download]+[upload])/(to_days(max([date]))-to_days(min([date]))+1),0) as [traffic_pre_day],
	format(sum([download]),0) as [download],
	format(sum([upload]),0) as [upload],
	format(sum([download]+[upload]),0) as [traffic]
from [$traffic[0]]$limit" : (($type == DB_SQLITE3) ? "
select	[first],
	[last],
	format([days],0) as days,
	format(cast([online] as float)/(60*60*24*[days])*100,2)||'%' as [online],
	format([online]/(60*60*24),0)||' days '||time([online]%(60*60*24),'unixepoch') as [online_time],
	format([connect],0) as [connect],
	format(traffic/days,0) as [traffic_per_day],
	format([download],0) as [download],
	format([upload],0) as [upload],
	format([traffic],0) as [traffic]
from (	select	distinct
		min([date]) as [first],
		max([date]) as [last],
		(max(strftime('%s',[date]))-min(strftime('%s',[date])))/(60*60*24)+1 as [days],
		sum((substr([online],0,instr([online],':'))*60+substr([online],-5,2))*60+substr([online],-2)) as [online],
		sum([connect]) as [connect],
		sum([download]) as [download],
		sum([upload]) as [upload],
		sum([download]+[upload]) as [traffic]
	from [$traffic[0]])$limit" : false))
       );
      }
      if($sql or $query and $key = (isset($queries[$query])) ? $query : preg_array("/".preg_quote($query,'/')."/i",$queries,5) and $sql = $queries[$key]) {
       $time = array_sum(explode(' ',microtime()));
       if($res = dbquery(utf8($sql,$cp),$query ? 0 : $type)) {
        $time = "Query in ".number_format(array_sum(explode(' ',microtime())) - $time,'2',',','.')." Sekunden ausgeführt";
        $rep = array();
        if($file and $fp = file_stream($file,1)) {
         if($ch)
          file_stream($fp,"sep=$sep$nl".implode($sep,str_replace($sep,"\\$sep",dbfields($res))).$nl);
        }
        else {
         $sep = '|';
         $data = $sep.implode($sep,str_replace($sep,"\\$sep",dbfields($res))).$nl;
         if($rj and is_string($rj))
          $rep["/^$rj$/"] = ' $0';			// Zahlen rechtsbündig
        }
        $rep['/'.preg_quote($sep,'/').'/'] = "\\$sep";	// Separator entwerten
        $fin = array_keys($rep);
        $rep = array_values($rep);
        while($line = dbfetch($res,DB_NUM)) {
         if($ft or $nu)					// Zeit-Format ändern
          foreach($line as $key => $col)
           if($nu and is_null($col))
            $line[$key] = 'NULL';
           elseif($ft)
            foreach($strftimes as $k => $v)
             if(isset($ft[$k]) and preg_match($v,$col))
              $line[$key] = @strftime($ft[$k],strtotime($col));
         $line = implode($sep,preg_replace($fin,$rep,$line)).$nl;
         if(++$c and $file and $fp)
          file_stream($fp,$line);
         else
          $data .= $sep.$line;
        }
        if($file and $fp) {
         file_stream($fp);
         out($c ? "$time - Es wurde".(($c == 1) ? " 1 Eintrag" : "n ".number_format($c,0,',','.')." Einträge")." gespeichert" : errmsg("8:$time - Keine Daten erhalten - Datei ist leer"));
        }
        else
         out($c ? "\n".textTable($data,0,"|","\n","|"," ")."\n\n$time - Es wurde".(($c == 1) ? " 1 Eintrag" : "n ".number_format($c,0,',','.')." Einträge")." ausgegeben" : errmsg("8:$time - Keine Daten erhalten"));
       }
       else
        out(errmsg("64:Query  fehlgeschlagen - ".dberror()."\n\n".dbquery($sql,DB_SQL)));
      }
      else {
//     ksort($queries);
       $list = "";
       foreach($queries as $key => $var)
        $list .= "$key |".((preg_match('/^--\s*(.+?)((?:,\d)+)?(?=[\r\n])/',$var,$m)) ? str_replace('|','\\|',$m[1]).((ifset($m[2])) ? "|(".substr($m[2],1).")" : "|") : "-")."\n";
       out("Liste vorhandener Queries\n\n{{{tt}Query|Beschreibung\n$list}}\n
{{{tt}(1) Mit Option -mu:[Mesh-Unit] filterbar |(2) Nur für Deutsche Ereignisse geeignet
(3) Nur mit aktivierten USB-Fernanschluss |}}");
      }
     }
     elseif($func['x']) {		// *Export
      if(!$file = getArg('file'))	// Optional Datei-Export
       $sep = '|';			// Bildschirmausgabe
      elseif($lm == 1e2)
       $lm = $elm;
      else
       $lm = intval($lm);		// Export mit Limit als Zahl
      $data = "";			// Bildschirmbuffer
      if($func['c']) {			// Call-Export: Anrufliste als CSV-Datei exportieren
       $head = str_replace(',',$sep,"type,time,name,callnumber,extension,ownnumber,duration$nl");	// CSV-Header
       $table = $tables['call'];
       if($page = dbquery("select count(*) from [$table[0]]",DB_COL)) {
        if($file) {
         $fp = file_stream($file,1);
         if($ch)
          file_stream($fp,"sep=$sep$nl$head");
         $pv = array($page,0); // all,drawed
         $page = ceil($page / $lm);
        }
        else
         $page = 1;
        $rep = array('/\\\\/' => '\\\\', '/'.preg_quote($sep,'/').'/' => "\\$sep");
        $fin = array_keys($rep);
        $rep = array_values($rep);
        while($page--) {
         if($res = dbquery("
select	t.[text] as 'type',
	c.[time],
	n.[text] as 'name',
	a.[text] as 'callnumber',
	e.[text] as 'extension',
	o.[text] as 'ownnumber',
	c.[duration],
	c.[dupe]
from [$table[0]] as c
left join [$table[1]] as t on t.[id] = c.[type]
left join [$table[1]] as n on n.[id] = c.[name]
left join [$table[1]] as a on a.[id] = c.[callnumber]
left join [$table[1]] as e on e.[id] = c.[extension]
left join [$table[1]] as o on o.[id] = c.[ownnumber]
order by c.[time]".($file ? ",c.[id]\nlimit $c,$lm" : " desc,c.[id] desc\nlimit $lm")))
          while($line = dbfetch($res,DB_ASSOC)) {
           if($ft or $nu)					// Zeit-Format ändern
            foreach($line as $key => $col)
             if($nu and is_null($col))
              $line[$key] = 'NULL';
             elseif($ft)
              foreach($strftimes as $k => $v)
               if(isset($ft[$k]) and preg_match($v,$col))
                $line[$key] = @strftime($ft[$k],strtotime($col));
           if(!$ft)
            $line['time'] = @strftime($ftime,strtotime($line['time']));	// Datum anpassen
           $line = str_repeat(implode($sep,preg_replace($fin,$rep,array_slice($line,0,-1))).$nl,($line['dupe'] ?: 0) + 1);
           if($file and $fp)
            file_stream($fp,$line);
           else
            $data .= $line;
           if($c++ % 100) {
            $row = floor($c / max($c,$pv[0]) * max($cfg['wrap']-1,10)) - $pv[1];
            $bug and dbug(str_repeat(".",$row),0,10);			// Export-Anzeige
            $pv[1] += $row;
           }
          }
        }
        $bug and dbug("\n",0,8);					// Export-Anzeige abschließen
        if($file and $fp)
         file_stream($fp);
        if($data)
         out("{{{tt}$head".utf8($data)."}}\n\nEs wurde".((($d = min($c,preg_replace('/^.*?(\d+)$/','$1',$lm))) == 1) ? " der letzte" : "n die letzten ".number_format($d,0,',','.'))
	." von ".number_format(dbquery("select count(*) from [$table[0]]",DB_COL),0,',','.')." Einträgen ausgegeben");
        else
         out($c ? "Es wurde".(($c == 1) ? " 1 Eintrag" : "n ".number_format($c,0,',','.')." Einträge")." exportiert" : errmsg("16:Die Datenbank ist leer"));
       }
       else
        out(errmsg("64:Fehler: ".dberror()));
      }
      elseif($func['e']) {		// Event-Export: Ereignisse als CSV-Datei exportieren
       $head = str_replace(',',$sep,"time,text,tab,code$nl");	// CSV-Header
       $table = $tables['event'];
       if($page = dbquery("select count(*) from [$table[0]]$mu[0]",DB_COL)) {
        if($file and $fp = file_stream($file,1)) {
         if($ch)
          file_stream($fp,"sep=$sep$nl$head");
         $pv = array($page,0); // all,drawed
         $page = ceil($page / $lm);
        }
        else
         $page = 1;
        while($page--) {
         if($res = dbquery("
select	e.[id],
	e.[time],
	t.[text],
	e.[name],
	e.[rp_num],
	e.[rp_time],
	c.[text] as [tab],
	t.[code]
from [$table[0]] as e
left join [$table[1]] as t on t.[id] = e.[text]
left join [$table[1]] as c on c.[id] = t.[tab]$mu[0]
order by [time]".($file ? ",e.[id]\nlimit $c,$lm" : " desc,e.[id] desc\nlimit $lm")))
          while($line = dbfetch($res,DB_ASSOC)) {
           $row = array(@strftime($ftime,strtotime($line['time'])),$line['text']);
           if($line['name'])
            $row[1] = "[$line[name]] $row[1]";
           if($line['rp_num'])
            $row[1] .= " [$line[rp_num] $txt[event] ".date('d.m.y H:i:s',strtotime($line['rp_time']))."]";
           if($line['tab'])
            $row[] = $line['tab'];
           if($line['code'])
            $row[] = $line['code'];
           $row = implode($sep,str_replace(array('\\',$sep),array('\\\\',"\\$sep"),$row)).$nl;
           if(++$c and $file and $fp)
            file_stream($fp,$row);
           else
            $data .= $row;
           if($c % 100) {
            $row = floor($c / max($c,$pv[0]) * max($cfg['wrap']-1,10)) - $pv[1];
            $bug and dbug(str_repeat(".",$row),0,10);			// Export-Anzeige
            $pv[1] += $row;
           }
          }
        }
        $bug and dbug("\n",0,8);						// Export-Anzeige abschließen
        if($file and $fp)
         file_stream($fp);
        if($data)
         out("{{{tt}$head".utf8($data)."}}\n\nEs wurde".((($d = min($c,preg_replace('/^.*?(\d+)$/','$1',$lm))) == 1) ? " der letzte" : "n die letzten ".number_format($d,0,',','.'))
	." von ".number_format(dbquery("select count(*) from [$table[0]]",DB_COL),0,',','.')." Einträgen ausgegeben");
        else
         out($c ? "Es wurde".(($c == 1) ? " 1 Eintrag" : "n ".number_format($c,0,',','.')." Einträge")." exportiert" : errmsg("16:Die Datenbank ist leer"));
       }
       else
        out(errmsg("64:Fehler: ".dberror()));
      }
      elseif($func['t']) {		// Traffic-Export: Datenzähler als CSV-Datei exportieren
       $head = str_replace(',',$sep,"date,online,connect,download,upload$nl");	// CSV-Header
       $table = $tables['traffic'];
       if($page = dbquery("select count(*) from [$table[0]]",DB_COL)) {
        if($file and $fp = file_stream($file,1)) {
         if($ch)
          file_stream($fp,"sep=$sep$nl$head");
         $pv = array($page,0); // all,drawed
         $page = ceil($page / $lm);
        }
        else
         $page = 1;
        while($page--) {
         if($res = dbquery("
select	[date],
	[online],
	[connect],
	[download],
	[upload]
from [$table[0]]
order by [date]".($file ? "\nlimit $c,$lm" : " desc limit $lm")))
          while($line = dbfetch($res,DB_ASSOC)) {
           if($ft)
            $line['date'] = @strftime($ftime,strtotime($line['date']));
           $line = implode($sep,$line).$nl;
           if(++$c and $file and $fp)
            file_stream($fp,$line);
           else
            $data .= $line;
           if($c % 100) {
            $row = floor($c / max($c,$pv[0]) * max($cfg['wrap']-1,10)) - $pv[1];
            $bug and dbug(str_repeat(".",$row),0,10);			// Export-Anzeige
            $pv[1] += $row;
           }
          }
        }
        $bug and dbug("\n",0,8);						// Export-Anzeige abschließen
        if($file and $fp)
         file_stream($fp);
        if($data)
         out("{{{tt}$head".utf8($data)."}}\n\nEs wurde".((($d = min($c,preg_replace('/^.*?(\d+)$/','$1',$lm))) == 1) ? " der letzte" : "n die letzten ".number_format($d,0,',','.'))
	." von ".number_format(dbquery("select count(*) from [$table[0]]",DB_COL),0,',','.')." Einträgen ausgegeben");
        else
         out($c ? "Es wurde".(($c == 1) ? " 1 Eintrag" : "n ".number_format($c,0,',','.')." Einträge")." exportiert" : errmsg("16:Die Datenbank ist leer"));
       }
       else
        out(errmsg("64:Fehler: ".dberror()));
      }
     }
     elseif($func['m']) {		// *Import
      if($file = getArg('file')) {
       if($func['c']) {			// Call-Import: Anrufliste von CSV-Datei importieren
        $table = $tables['call'];
        $atab = explode('|',"|".($tabs = 'in|ring|drop|out'));
        $names = array('name','callnumber','extension','ownnumber');
        $p = preg_quote($sep,'/');
        if($files = listDir($file)) {
         foreach($files as $file) {
          $d = 0;
          $bug and dbug("Importiere: ".basename($file)." ... ",0,2);
          if($fp = file_stream($file)) {
           dbquery("begin",DB_EXEC);
           while($line = file_stream($fp))
            if(preg_match("/^([1-4]|$tabs)(?<!\\\\)$p((\d\d)\.(\d\d)\.(?:20)?(\d\d)\s([\d:]+)|[\/\w\s:.+-]+)(?:(?<!\\\\)$p(.*?))?(?<!\\\\)$p([\#\w*.-]*)(?<!\\\\)$p(.*?)(?<!\\\\)$p(.*?)(?<!\\\\)$p([\d:]+)\s*$/i",$line,$m)) {
             $col = array('type' => array_search($m[1],$atab) ?: $m[1], 'time' => $m[3] ? "'20$m[5]-$m[4]-$m[3] $m[6]'" : "'$m[2]'",
		'duration' => "'".((preg_match('/^(\d*)(\d:\d\d)(:\d\d)?($)/',$m[11],$var)) ? (($var[1] != '') ? $var[1] : '0').$var[2].(($var[3] != '') ? $var[3] : ':00') : '00:00:00')."'");
             if($col['type'] == 3 and !preg_match('/^[0:]$/',$col['duration']))	// Automatisch drop (OS6+) & out (OS-5) unterscheiden
              $col['type']++;	// Drop ist das neue Out ;-)
             $where = array('type' => "[type] = $col[type]", 'time' => "[time] = $col[time]", 'duration' => "[duration] = $col[duration]");
             $a = 6;
             foreach($names as $name) {
              $var = 'NULL';
              if($val = $m[++$a]) {
               $var = preg_replace("/^'(NULL)'$/i",'$1',"'".dbescape(utf8((substr($val,0,1) == '"' and substr($val,-1) == '"') ? str_replace(array('""','\\"'),array('"','"'),substr($val,1,-1)) : $val,$cp))."'");
               $var = ($id = dbquery("select id from [$table[1]] where [text] = $var limit 1",DB_COL)) ? $id : ((dbquery("insert into [$table[1]] ([text]) values ($var)",DB_EXEC)) ? dbid() : 0);
              }
              $col[$name] = $var;
              $where[$name] = "[$name] ".(($var == 'NULL') ? "is" : "=")." $var";
             }
             if($id = dbquery("select [id] from [$table[0]] where ".implode(' and ',$where),DB_COL))
              dbquery("update [$table[0]] set [dupe]=ifnull([dupe],1)+1 where [id] = $id",DB_EXEC);
             else
              dbquery("insert into [$table[0]] (".implode(',',preg_replace('/\w+/','[$0]',array_keys($col))).") values (".implode(',',$col).")",DB_EXEC) and ++$c and ++$d;
            }
            elseif(preg_match('/^sep=(.)/',$line,$m)) {
             $sep = $m[1];
             $p = preg_quote($sep,'/');
            }
            else
             $bug and dbug("Ignoriert: $line",9);
           dbquery("commit",DB_EXEC);
           $bug and dbug($d ? (($d == 1) ? "1 neuer Eintrag" : number_format($d,0,',','.')." neue Einträge")." importiert" : "Keine neuen Einträge gefunden");
          }
          else
           $bug and dbug(basename($file)."' konnte nicht geöffnet werden");
         }
         out($c ? "Es wurde".(($c == 1) ? " 1 neuer Eintrag" : "n ".number_format($c,0,',','.')." neue Einträge")." importiert" : "Keine neuen Einträge gefunden");
        }
        else
         out(errmsg("8:Keine Import-Datei gefunden"));
       }
       elseif($func['e']) {		// Event-Import: Ereignisse von CSV-Datei importieren
        $table = $tables['event'];
//      $max = ($var = dbquery("select max([time]) from [$table[0]]",DB_COL)) ? strtotime($var) : 0;
        $atab = explode('|',"|".($tabs = "system|internet|telefon|wlan|usb"));
        $p = preg_quote($sep,'/');
        if($files = listDir($file)) {
         foreach($files as $file) {
          $d = 0;
          $bug and dbug("Importiere: ".basename($file)." ... ",0,2);
          if($fp = file_stream($file)) {
           dbquery("begin",DB_EXEC);
           while($line = file_stream($fp))
            if(preg_match("/^((\d\d)\.(\d\d)\.(?:20)?(\d\d)\s([\d:]+)|[\/\w\s:.+-]+)(?<!\\\\)$p((?:\s*\"?\[([\w\s.:-]+)\])?.*?)(?:\s*\[(\d+)\D+(\d\d)\.(\d\d)\.(?:20)?(\d\d)\s+([\d:]+)\])?(?:(?<!\\\\)$p([0-5]|$tabs))?(?:(?<!\\\\)$p(\d+))?\s*($)/",$line,$m) /* and $max < strtotime("20$m[4]-$m[3]-$m[2] $m[5]") */) {
             if(strtotime($time = $m[2] ? "20$m[4]-$m[3]-$m[2] $m[5]" : date('Y-m-d H:i:s',strtotime($m[1])))) {
              $name = ($m[7] and $m[6] = preg_replace('/\[.*?\]\s+/','',$m[6],1)) ? "'$m[7]'" : "NULL";
              $text = "'".dbescape(utf8((substr($m[6],0,1) == '"' and substr($m[6],-1) == '"') ? str_replace(array('""','\\"'),array('"','"'),substr($m[6],1,-1)) : $m[6],$cp))."'";
              $rp_num = $m[8] ?: 'NULL';
              $rp_time = $m[9] ? "'20$m[11]-$m[10]-$m[9] $m[12]'" : 'NULL';
              $tab = array_search($m[13],$atab) ?: 'NULL';
              $code = $m[14] ?: 'NULL';
              $text = ($id = dbquery("select id from [$table[1]] where [text] = $text limit 1",DB_COL)) ? $id
		: ((dbquery("insert into [$table[1]] ([tab],[code],[text]) values ($tab,$code,$text)",DB_EXEC)) ? dbid() : 0);
              if(!dbquery("select [id] from [$table[0]] where [time] = '$time' and [text] = $text",DB_COL))
               dbquery("insert into [$table[0]] ([time],[text],[name],[rp_num],[rp_time]) values ('$time',$text,$name,$rp_num,$rp_time)",DB_EXEC) and ++$c and ++$d;
             }
             else
              $bug and dbug("Zeit nicht erkannt: $line",9);
            }
            elseif(preg_match('/^sep=(.)/',$line,$m)) {
             $sep = $m[1];
             $p = preg_quote($sep,'/');
            }
            else
             $bug and dbug("Unbekannte Daten: $line",9);
           dbquery("commit",DB_EXEC);
           $bug and dbug($d ? (($d == 1) ? "1 neuer Eintrag" : number_format($d,0,',','.')." neue Einträge")." importiert" : "Keine neuen Einträge gefunden");
          }
          else
           $bug and dbug(basename($file)."' konnte nicht geöffnet werden");
         }
         out($c ? "Es wurde".(($c == 1) ? " 1 neuer Eintrag" : "n ".number_format($c,0,',','.')." neue Einträge")." importiert" : "Keine neuen Einträge gefunden");
        }
        else
         out(errmsg("8:Keine Import-Datei gefunden"));
       }
       elseif($func['t']) {		// Traffic-Import: Datenzähler von CSV-Datei importieren
        $table = $tables['traffic'];
        $p = preg_quote($sep,'/');
        if($files = listDir($file)) {
         foreach($files as $file) {
          $d = 0;
          $bug and dbug("Importiere: ".basename($file)." ... ",0,2);
          if($fp = file_stream($file)) {
           dbquery("begin",DB_EXEC);
           while($line = file_stream($fp))
            if(preg_match("/^([\d-]+)$p([\d:]+)$p(\d+)$p(\d+)$p(\d+)\s*($)/",$line,$m)) {
             if(!dbquery("select date from [$table[0]] where [date] = '$m[1]' limit 1",DB_COL))
              dbquery("insert into [$table[0]] ([date],[online],[connect],[download],[upload]) values ('$m[1]','$m[2]',$m[3],$m[4],$m[5])",DB_EXEC) and ++$c and ++$d;
            }
            elseif(preg_match('/^sep=(.)/',$line,$m)) {
             $sep = $m[1];
             $p = preg_quote($sep,'/');
            }
            else
             $bug and dbug("Ignoriert: $line",9);
           dbquery("commit",DB_EXEC);
           $bug and dbug($d ? (($d == 1) ? "1 neuer Eintrag" : number_format($d,0,',','.')." neue Einträge")." importiert" : "Keine neuen Einträge gefunden");
          }
          else
           $bug and dbug(basename($file)."' konnte nicht geöffnet werden");
         }
         out($c ? "Es wurde".(($c == 1) ? " 1 neuer Eintrag" : "n ".number_format($c,0,',','.')." neue Einträge")." importiert" : "Keine neuen Einträge gefunden");
        }
        else
         out(errmsg("8:Import-Datei nicht gefunden"));
       }
      }
      else
       out(errmsg("2:Keine Import-Datei(en) angegeben"));
     }
     elseif($func['c'] or $func['e'] or $func['t']) {	// Funktionen, die eine Fritz!Box benötigen
      if($sid = (ifset($cfg['bsid'])) ? $cfg['bsid'] : login()) { // Fritz!Box Login
       if($cfg['bsid'] or $cfg['fiwa'] < 530 or isset($cfg['auth']['BoxAdmin'])) {
        if($func['c']) {			// Call: Anrufliste auf der FritzBox
         $table = $tables['call'];
         if($call = getcall()) {
          if($max = strtotime(dbquery("select max([time]) from [$table[0]]",DB_COL)))	// Letzter Anruf
           foreach($call as $key => $var)// Ältere Anrufe aus der Fritz!Box löschen
            if($max >= intval($key))
             unset($call[$key]);
          $calsql = preg_replace('/\w+/','[$0]',$cals = explode(',','type,time,name,callnumber,extension,ownnumber,duration'));	// CSV-Format
          dbquery("begin",DB_EXEC);
          foreach($call as $key => $line) {
           if(count($line) < 6)
            $line = array_splice($line,2,0,'');
           $line[1] = preg_replace('/(\d\d)\.(\d\d)\.(?:20)?(\d\d) ([\d:]+)/',"'20\$3-\$2-\$1 \$4'",$line[1]);	// time
           $line[6] = "'$line[6]'";	// duration
           $where = array();
           foreach($cals as $kid => $var) {			// IDs für die Textspalten ermitteln/erstellen
            if($var and $kid > 1 and $kid < 6 and $line[$kid])	// NUR für Spalten mit Untertabellen
             $line[$kid] = ($id = dbquery("select [id] from [$table[1]] where [text] = '".($txt = dbescape(utf8($line[$kid],$cp)))."' limit 1",DB_COL)) ? $id
	: ((dbquery("insert into [$table[1]] ([text]) values ('$txt')",DB_EXEC)) ? dbid() : 0);
            elseif(!$line[$kid])
             $line[$kid] = 'NULL';
            $where[] = $calsql[$kid].(($line[$kid] == 'NULL') ? " is NULL" : " = ".$line[$kid]);
           }
           if($id = dbquery("select [id] from [$table[0]] where ".implode(' and ',$where),DB_COL))
            dbquery("update [$table[0]] set [dupe]=ifnull([dupe],1)+1 where [id] = $id",DB_EXEC);
           else
            dbquery("insert into [$table[0]] (".implode(',',$calsql).") values (".implode(',',$line).")",DB_EXEC) and $c++;
          }
          dbquery("commit",DB_EXEC);
          out($c ? "Es wurde".(($c == 1) ? " 1 neuer Eintrag" : "n $c neue Einträge")." gespeichert" : "Keine neuen Anrufe erhalten");
         }
         else
          out(errmsg("16:Keine Anrufliste erhalten"));
        }
        elseif($func['e']) {		// Event: Ereignisse aus der Fritz!Box
         $preg = '/^(?:\[([\w.-]+)\] )?(.+?)(?:\s*\[(\d+)\D+(\d\d)\.(\d\d)\.(?:20)?(\d\d)\s+([\d:]+)\])?\s*$/';	// RegEx für wiederholte Ereignisse
         $table = $tables['event'];
         if($event = getevent()) {			// Ereignisse aus Fritz!Box holen
          if($last = dbquery("
select	e.[id],
	e.[time],
	e.[name],
	e.[rp_num],
	e.[rp_time],
	t.[text]
from [$table[0]] as e
left join [$table[1]] as t on t.id = e.text
where e.[time] = (select max([time]) from [$table[0]])
order by e.[id] desc
limit 1",DB_LINE)) {	// Letztes Ereignis aus der Datenbank
           $max = strtotime($last['time']);
           foreach($event as $key => $var)		// Ältere Ereignisse von der Fritz!Box löschen
            if($max >= intval($key))
             unset($event[$key]);
           if($first = reset($event) and $last['rp_num'] and preg_match($preg,$first[2],$var) and $last['name'] == $var[1] and $last['text'] == $var[2] and $last['rp_time'] == "20$var[6]-$var[5]-$var[4] $var[7]")
            if(dbquery("update [$table[0]] set [time] = '".date('Y-m-d H:i:s',intval($key = key($event)))."', [rp_num] = $var[3] where [id] = $last[id]",DB_EXEC))
             unset($event[$key]);
          }
          if($event) {
           dbquery("begin",DB_EXEC);
           foreach($event as $key => $line)
            if(preg_match($preg,$line[2],$var)) {
             $name = (ifset($var[1])) ? "'".dbescape(utf8($var[1],$cp))."'" : 'NULL';
             $time = preg_replace('/(\d\d)\.(\d\d)\.(?:20)?(\d\d)/',"'20\$3-\$2-\$1",$line[0])." $line[1]'";
             $rp_num = (ifset($var[3])) ? $var[3] : 'NULL';
             $rp_time = (ifset($var[4])) ? "'20$var[6]-$var[5]-$var[4] $var[7]'" : 'NULL';
             $text = "'".dbescape(utf8($var[2],$cp))."'";
             $code = (ifset($line[3])) ? $line[3] : 'NULL';
             $tab = (ifset($line[4])) ? $line[4] : 'NULL';
             $text = ($id = dbquery("select id from [$table[1]] where [text] = $text limit 1",DB_COL)) ? $id
	: ((dbquery("insert into [$table[1]] ([tab],[code],[text]) values ($tab,$code,$text)",DB_EXEC)) ? dbid() : 0);
             dbquery("insert into [$table[0]] ([time],[text],[name],[rp_num],[rp_time]) values ($time,$text,$name,$rp_num,$rp_time)",DB_EXEC);
            }
           dbquery("commit",DB_EXEC);
           out("Es wurde".((($var = count($event)) == 1) ? " 1 neuer Eintrag" : "n $var neue Einträge")." gespeichert");
          }
          else
           out("Keine neuen Ereignisse erhalten");
         }
         else
          out(errmsg("16:Keine Meldungen erhalten"));
        }
        elseif($func['t']) {		// Traffic: Datenzähler aus der Fritz!Box
         $table = $tables['traffic'];
         if($traffic = gettraffic()) {			// Ereignisse aus Fritz!Box holen
          if(!$time = $traffic['Time'])
           $time = time();
          if(isset($traffic['Yesterday'])) {
           $traffic = $traffic['Yesterday'];
           $date = date('Y-m-d',$time - 60*60*24);
           out("Traffic-Daten ",2);
           if(!dbquery("select date  from [$table[0]] where date = '$date'",DB_COL))	// Abfragen ob Daten schon vorhanden sind
            out((dbquery("insert into [$table[0]] ([date],[online],[connect],[download],[upload]) values ('$date','".preg_replace('/\b\d\b/','0$0',floor($traffic['time'] / 60).":".($traffic['time'] % 60))."',$traffic[connect],$traffic[in],$traffic[out])",DB_EXEC))
		? "Traffic-Daten für 'Gestern' gespeichert" : errmsg("32:Traffic-Daten konnten nicht gespeichert werden"));
           else
            out("bereits vorhanden");
          }
          else
           out(errmsg("16:Keine Traffic-Daten erhalten"));
         }
         else
          out(errmsg(0,'gettraffic'));
        }
       }
       else
        out(errmsg("8:Benutzer hat nicht das Recht für die Administration"));
       if(!ifset($cfg['bsid']))	// Ausloggen
        logout($sid);
      }
      else
       out(errmsg(0,'login'));
     }
     else
      out(errmsg("64:Möglichweise ist ein unbekannter und unerwarterer, sowie mysteriöser Layer-8 Problem aufgetreten ;-)"));
    }
    else
     out(errmsg("8:Keine oder nicht alle Tabellen gefunden - ".dberror()));
   }
   else
    out(errmsg("8:Datenbank konnte nicht geöffnet werden - $db[error]"));
  }
  else
   out(errmsg("64:Fehler: Die PHP-Erweiterung {$idb[$type]} konnte nicht geladen werden"));
 }
 else
  out(errmsg("2:Fehler: Keine Datenbank übergeben"));
}
else
 out(errmsg("2:Keine oder Unbekannte Parameter übergeben"));
if($bug and isset($db))
 dbug(compact(explode(',','db,tables')),9);

?>
