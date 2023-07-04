<?php
class DB
{
   public $conn;

   function __construct($server, $user_name, $pass, $db)
   {
      $this->conn = mysqli_connect($server, $user_name, $pass);
      mysqli_select_db($db, $this->conn);
      mysqli_set_charset('utf8');
   }

   function __destruct()
   {
      mysql_close($this->conn);
   }
}
?>
