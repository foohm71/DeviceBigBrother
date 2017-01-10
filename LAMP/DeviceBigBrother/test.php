<?php

$ts = time();
$hmac = hash_hmac("sha256", $ts, "MySecret", true);
$hash = base64_encode($hmac);
$host = "myhost";
$URI = "DeviceBigBrother/track.php";
$deviceID = "snvd-04-casino";
$model = "iPhone6";
$lat = "1.2345";
$lon = "5.678";
$authHeader = "Authorization:" . $hash;

$URL = "http://" . $host . "/" . $URI . "?" .
       "deviceID=" . $deviceID . "&" .
       "model=" . $model . "&" . 
       "lat=" . $lat . "&" . 
       "lon=" . $lon . "&" .
       "ts=" . $ts;

echo $URL;

$result = `curl --header "$authHeader" "$URL"`;
?>

