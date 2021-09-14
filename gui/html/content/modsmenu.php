<?php
// Verify user logged in, redirect to index if not
if (!isset($_SESSION)) {
  session_start();
}
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
<div class='world-item'>
<h2>Upload a Mod</h2>

<?php
if (!empty($upload_msg)) {
  echo '<div class="alert alert-success">
          <span class="glyphicon glyphicon-info-sign"></span> ' . $upload_msg . '
        </div>';
}
?>

<form action="index.php" method="post" enctype="multipart/form-data">
  <div class="input-group">
    <input type="file" name="fileToUpload" id="fileToUpload" class="form-control">
    <input type="submit" value="Upload ZIP" name="upload" class="btn btn-success form-control">
  </div>
</form>
</div>
<div class='world-item'>
<h2>Uploaded Mods</h2>
<?php
  if ($handle = opendir(dirname(__DIR__) . '/plugins')) {
      while (false !== ($entry = readdir($handle))) {
          if ($entry != "." && $entry != "..") {
              echo "<div class='row no-gutters'>
                      <div class='col-8 filename'>".$entry."</div>
                      <div class='col-2 right'>
                        <div class='btn-group'>
                          <button type='button' class='btn btn-success dropdown-toggle' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
                            Push to 
                          </button>
                          <ul class='dropdown-menu mod-world-item'>";
                            foreach ($world_array as $key => $value) {
                              echo '<li onclick="location.href=\'index.php?PUSH='.$entry.'&world_name=' . $value . '\';" >' . $value . '</li>';
                            }
                            
                          echo "</ul>
                        </div>
                      </div>
                      <div class='col-2 right'>
                        <button class='btn btn-danger trash' onclick=\"location.href='index.php?remove_ZIP=".$entry."'\" >
                          <span class='glyphicon glyphicon-trash'></span>
                        </button>
                      </div>
                    </div>";
          }
      }
      closedir($handle);
  } else {
    echo 'No mods uploaded';
  }
?>

</div>

<?php 

  foreach ($world_array as $key => $value) {
    echo "<div class='world-item'><h2>BepInEx Plugin Directory for <span class='glyphicon glyphicon-globe' aria-hidden='true'></span> " . $value . "</h2>";

      if ($handle = opendir('/home/steam/valheimserver/' . $value . '/BepInEx/plugins')) {
        while (false !== ($entry = readdir($handle))) {
            if ($entry != "." && $entry != "..") {
              $file = '/home/steam/valheimserver/' . $value . '/BepInEx/plugins/'.$entry;
              if (is_file($file)) {
                echo "<div class='row no-gutters'>
                        <div class='col-10 filename'>$entry</div><div class='col-2 right'><button class='btn btn-danger trash' onclick=\"location.href='index.php?remove_MOD=".$entry."&world_name=".$value."'\" ><span class='glyphicon glyphicon-trash'></span></button>
                      </div></div>";
              } else {
                echo "<div class='row no-gutters'>
                        <div class='col-12 folder'><span class='glyphicon glyphicon-folder-open'></span>$entry</div>
                      </div>";
                }
              }
        }
        closedir($handle);
        echo '</div>';
    } else {
      
      if (!is_dir('/home/steam/valheimserver/' . $value . '/BepInEx/plugins')) {
        echo 'BepInEx not found. Run the Njord Menu, verify you are on "Server Name: ' . $value . ' (world session can be changed with option 99) and run 19 or 20 (both options will install BepInEx, 19 additionally installs Valheim+). In the next menu run option 1 ( 19: Install valheim Mods, 20: Install BepInEx Mods).';
      } else {  
        echo 'No files found, </div>';
      }
    }

  }

?>
