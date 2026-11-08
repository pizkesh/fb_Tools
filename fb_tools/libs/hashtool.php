<?php	// Hash-Tool 1.1 for PHP 4/5

if(!function_exists('hash_hmac')) {	// http://php.net/hash_hmac
 function hash_hmac($algo, $data, $key, $raw=false) {
  $algo = strtolower($algo);
  $pack = 'H'.strlen(hash($algo,0));
  $opad = $ipad = "";
  $key = str_pad((strlen($key) > 64) ? pack($pack,hash($algo,$key)) : $key,64,"\0");
  for($i=0; $i < 64;) {
   $opad .= chr(92) ^ $key[$i];
   $ipad .= chr(54) ^ $key[$i++];
  }
  $hash = hash($algo,$opad.pack($pack,hash($algo,$ipad.$data)));
  return $raw ? pack($pack,$hash) : $hash;
 }
}

# PBKDF2 for PHP (c) 2016 Taylor Hornby (https://defuse.ca/php-pbkdf2.htm / https://github.com/defuse/password-hashing)
if(!function_exists('hash_pbkdf2')) {	// http://php.net/hash_pbkdf2
 function hash_pbkdf2($algo, $pass, $salt, $count, $length, $raw=false) {
  $algo = strtolower($algo);
  if(!$raw)
   $length /= 2;
  $block = ceil($length / strlen(hash($algo,"",true)));
  $hash = "";
  for($i=1; $i <= $block; $i++) {
   $last = $xorsum = hash_hmac($algo,$salt.pack("N",$i),$pass,true);
   for($j=1; $j < $count; $j++)
    $xorsum ^= ($last = hash_hmac($algo,$last,$pass,true));
   $hash .= $xorsum;
  }
  $hash = substr($hash,0,$length);
  return $raw ? $hash : bin2hex($hash);
 }
}

?>
