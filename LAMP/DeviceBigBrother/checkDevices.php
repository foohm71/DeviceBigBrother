<?php include "globals.php" ?>
<?php include "distance.php" ?>
<?php include "mysql.php" ?>
<?php include "utils.php" ?>

<?php

$late_devices_string = "These are the devices not checked in the last " . $num_hours . " hour(s):<p>";

$late_devices = findLateDevices($con, $num_hours);

foreach ($late_devices as $deviceID) {
   $late_devices_string .= $deviceID . "<p>";
}

echo $late_devices_string;
echo "\n\n";
$num_late_devices = sizeOf($late_devices);

$far_devices_string = "These are the devices that are " . $home_boundary . " mile(s) away:<p>";

$far_devices = findFarDevices($con, $home_lat, $home_lon, $home_boundary);

foreach ($far_devices as $deviceID) {
   $far_devices_string .= $deviceID . "<p>";
}

echo $far_devices_string;
$num_far_devices = sizeOf($far_devices);

if (($num_far_devices > 0) || ($num_late_devices > 0)) {
   sendmail($mailinglist, $subjectPrefix . " Alert # late dev: " . $num_late_devices . " # far dev: " . $num_far_devices, "THIS IS AN AUTOGENERATED MESSAGE<p><p>" . $late_devices_string . "<p><p>" . $far_devices_string);
}
?>
