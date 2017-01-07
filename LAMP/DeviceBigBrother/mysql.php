<?php
// Create connection
$con=mysqli_connect("localhost","root","mypassword","DeviceBigBrother");

// Check connection
if (mysqli_connect_errno($con)) {
  error_log("Unable to connect to database");
} else {
  error_log("Connected to database");
}
?>

<?php
// All the mysql related functions
function insertNewEntry($con, $deviceID, $model, $lat, $lon) {
   $sql = "INSERT INTO DeviceTracker " . 
          "(deviceID, model, lat, lon, timestamp) " . 
          "VALUES (" . 
          "'" . $deviceID . "'," .
          "'" . $model . "'," . 
          $lat . "," .
          $lon . "," . 
          "Now()" . 
          ");";
   $result = mysqli_query($con, $sql);
   if ($result == FALSE) {
      error_log(mysqli_error($con));
      return FALSE;
   } else {
      return TRUE;
   }
}

function updateEntry($con, $deviceID, $model, $lat, $lon) {
   $sql = "UPDATE DeviceTracker " . 
          "set " . 
          "lat = " . $lat . "," . 
          "lon = " . $lon . "," . 
          "timestamp = Now() " . 
          "where deviceID = '" . $deviceID . "'" .
          ";";
   $result = mysqli_query($con, $sql);
   if ($result == FALSE) {
      error_log(mysqli_error($con));
      return FALSE;
   } else {
      return TRUE;
   }
}

function entryExists($con, $deviceID, $model) {
   $sql = "SELECT * from DeviceTracker " . 
          "where deviceID = '" . $deviceID . "'" .
          ";";
   $result = mysqli_query($con, $sql);
   if ($result == FALSE) {
      error_log(mysqli_error($con));
      return NULL;
   } else {
      $count = mysqli_num_rows($result); 

      if ($count == 0) return FALSE; else return TRUE;
   }
}

function duplicateEntryExists($con, $deviceID, $model) {
   $sql = "SELECT * from DeviceTracker " . 
          "where deviceID = '" . $deviceID . "'" .
          "and not model = '" . $model . "'" .
          ";";
   $result = mysqli_query($con, $sql);
   if ($result == FALSE) {
      error_log(mysqli_error($con));
      return NULL;
   } else {
      $count = mysqli_num_rows($result); 

      if ($count == 0) return FALSE; else return TRUE;
   }
}

function findLateDevices($con, $interval) {
   $sql = "SELECT * from DeviceTracker " . 
          "where timestamp < DATE_SUB(NOW(), INTERVAL " . $interval . " HOUR);";
   $result = mysqli_query($con, $sql);
   $res_list = array();
   if ($result == FALSE) {
      error_log(mysqli_error($con));
      return NULL;
   } else {
      while ($row = mysqli_fetch_array($result)) {
         $res_list[] = $row['deviceID'];
      }
      return $res_list;
   }
}

function findFarDevices($con, $home_lat, $home_lon, $boundary) {
   $sql = "SELECT * from DeviceTracker "; 
   $result = mysqli_query($con, $sql);
   $res_list = array();
   if ($result == FALSE) {
      error_log(mysqli_error($con));
      return NULL;
   } else {
      while ($row = mysqli_fetch_array($result)) {
         $lat = $row['lat'];
         $lon = $row['lon'];
         if (($lat == 0) && ($lon == 0)) {
            // skip cos some devices do not have GPS
         } elseif (distance($home_lat, $home_lon, $lat, $lon, "M") > $boundary) {
            $res_list[] = $row['deviceID'];
         }
      }
      return $res_list;
   }
}

?>
