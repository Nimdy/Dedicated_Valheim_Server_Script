<?php
// Verify user logged in, redirect to index if not
session_start();
require(dirname(__DIR__).'../../VSW-GUI-CONFIG');
if (!isset($_SESSION['login']) || $_SESSION['login'] != $hash) {
  header("Location: /index.php");
  exit();
}



$_SESSION['PAGE'] = 'modsmenu';
?>
<script type="text/javascript">
	$(function() {
		$(".hide-to-fade").fadeIn(300);
	});
</script>
<div class="hide-to-fade">
<h1>MODS MENU</h1>
<?php
// Get the config file
require(dirname(__DIR__).'../../VSW-GUI-CONFIG');
// Upload a Mod
?>
<br>
Mods must be uploaded as .ZIP files. Once uploaded a mod can be unzipped into the Valhiem BepInEx folder (/home/steam/valheimserver/BepInEx/plugins/).
<br>
<br>
<h1>Upload a Mod</h1>

<?php
if (!empty($upload_msg)) {
  echo '<div class="alert alert-info">
          <span class="glyphicon glyphicon-info-sign"></span>' . $upload_msg . '
        </div>';
}
?>

<form action="index.php" method="post" enctype="multipart/form-data">
  <div class="input-group">
    <input type="file" name="fileToUpload" id="fileToUpload" class="form-control">
    <input type="submit" value="Upload ZIP" name="upload" class="btn btn-success form-control">
  </div>
</form>
<br>
<h1>Uploaded Mods</h1>
<?php
  if ($handle = opendir('/var/www/html/plugins')) {
      while (false !== ($entry = readdir($handle))) {
          if ($entry != "." && $entry != "..") {
              echo "<div class='row no-gutters'>
                      <div class='col-10 filename'>".$entry."</div><div class='col-1'><button class='btn btn-success btn-push' onclick=\"location.href='index.php?PUSH=".$entry."'\" >Push</button></div><div class='col-1'><button class='btn btn-danger trash' onclick=\"location.href='index.php?remove_ZIP=".$entry."'\" ><span class='glyphicon glyphicon-trash'></span></button></div></div>";
          }
      }
      closedir($handle);
  } else {
    echo 'No mods uploaded';
  }
?>
<br>
<br>
<h1>BepInEx Plugin Directory</h1>
<?php
  if ($handle = opendir('/home/steam/valheimserver/BepInEx/plugins')) {
      while (false !== ($entry = readdir($handle))) {
          if ($entry != "." && $entry != "..") {
            $file = '/home/steam/valheimserver/BepInEx/plugins/'.$entry;
            if (is_file($file)) {
              echo "<div class='row no-gutters'>
                      <div class='col-12 filename'>$entry</div>
                    </div>";
            } else {
              echo "<div class='row no-gutters'>
                      <div class='col-12 folder'><span class='glyphicon glyphicon-folder-open'></span>$entry</div>
                    </div>";
              }
            }
      }
      closedir($handle);
  } else {
    echo 'No contents';
  }
?>
