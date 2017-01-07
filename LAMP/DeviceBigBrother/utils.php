<?php
// These are all utility functions

// This to generate the SHA256 hash
function hmac($message, $secret) {
   error_log("hmac was called with " . $message);
   $s = hash_hmac("sha256", $message, $secret, true);
   return base64_encode($s);
}

require 'PHPMailer/PHPMailerAutoload.php';

function sendmail($to, $subj, $msg) {
   error_log("sendmail was called with " . $to . " " . $subj . " " . $msg);
   $mail = new PHPMailer;
   $mail->SMTPDebug = 3;                               // Enable verbose debug output

   $mail->isSMTP();                                      // Set mailer to use SMTP
   $mail->Host = 'smtp.mail.yahoo.com';  // Specify main and backup SMTP servers
   $mail->SMTPAuth = true;                               // Enable SMTP authentication
   $mail->Username = 'myaccount@yahoo.com';                 // SMTP username
   $mail->Password = 'mypassword';                           // SMTP password
   $mail->SMTPSecure = 'tls';                            // Enable TLS encryption, `ssl` also accepted
   $mail->Port = 587;                                    // TCP port to connect to

   $mail->From = 'myaccount@yahoo.com';
   $mail->FromName = 'Device Big Brother';
   $mail->addAddress($to, 'Device Big Brother Minders');     // Add a recipient
   $mail->addReplyTo('myaccount@yahoo.com', 'Device Big Brother');

   $mail->isHTML(true);                                  // Set email format to HTML

   $mail->Subject = $subj;
   $mail->Body    = $msg;
   $mail->AltBody = 'You need a HTML capable Mail client to read this';

   if(!$mail->send()) {
       error_log("sendmail: Message could not be sent");
       error_log("Mailer Error: " . $mail->ErrorInfo);
   } else {
   }

}
?>
