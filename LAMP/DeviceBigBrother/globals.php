<?php
   // this is for the SHA-256 hash
   $secret = "MySecret";

   // this is for sending email alerts
   $mailinglist = "mymailinglist@mydomain.com";
   $subjectPrefix = "[DeviceBigBrother] ";

   // this is home base location for checking how far device is from home
   $home_lat = 7.357805;
   $home_lon = 22.014439;
   $home_boundary = 5; // number of miles the boundary of geofence   

   // this is number of hours device has not checed in test 
   $num_hours = 1;
?>
