<?php
if (!isset($_SESSION)) {
  session_start();
}

// Verify user logged in, redirect to index if not
require(dirname(__DIR__).'../../VSW-GUI-CONFIG');
if (!isset($_SESSION['login']) || $_SESSION['login'] != $hash) {
  header("Location: /index.php");
  exit();
}
$_SESSION['PAGE'] = 'servercommands';


// Verify www-data has been added to the sudoer file
$exec = 'sudo /usr/bin/grep "www-data" /etc/sudoers';
$verify = shell_exec(escapeshellcmd($exec));
if ($verify == '' || $verify == null) {
  $warning = 'www-data permissions not found, server commands may not function.';
}

?>
<script type="text/javascript">
	$(function() {
		$(".hide-to-fade").fadeIn(300);

    $(".server-function").click(function() {
      $("#loading-background").removeClass("hidden");
    });

	});
</script>

<!-- ALERT NOTICE -->
  <div class="alert alert-danger alert-dismissible <?php if(!isset($warning)){ echo 'hidden'; } ?>" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <div id="alert_content">
      <!-- ALERT CONTENT -->
      <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span> <?php if(isset($warning)){ echo $warning; } ?>
    </div>
  </div>
<!-- END ALERT -->

<!-- LOADING SCREEN -->
  <div id="loading-background" class="hidden">
    <div id="loading-body" class="panel panel-default">
      <div class="spinner-grow text-primary" role="status">
        <span class="sr-only">Loading...</span>
      </div>
        Server Executing Command, Please wait.
    </div>
  </div>
<!-- END LOADING SCREEN -->

<div class="hide-to-fade">
<h1>SERVER COMMANDS</h1>
<?php

foreach ($world_array as $key => $value) {

  $world_name = htmlspecialchars($value);
  $exec = 'systemctl status --no-pager -l valheimserver_' . $world_name . '.service';
  $info = shell_exec(escapeshellcmd($exec));

  $startup_line = strstr($info, '-name');
  $startup_array = explode(' ', $startup_line);
  $port = 'ERROR';
  $public_status = 'ERROR';
  foreach ($startup_array as $key => $value) {
    $next_key = $key + 1;
    switch ($value) {
      case '-name':
        $name = $startup_array[$next_key];
        break;
      case '-port':
        $port = $startup_array[$next_key];
        break;
      case '-public':
        $public_status = $startup_array[$next_key];
        break;
      default:
        # Do nothing
        break;
    }
  }

  // Look for the FWL and pull the Seed value
  $seed = 'Error: Seed value unset';
  if (file_exists("/home/steam/.config/unity3d/IronGate/Valheim/".$world_name."/worlds/".$world_name.".fwl")) {
    $seed_output_array = array();
    $raw_fwl = shell_exec("hexdump -C /home/steam/.config/unity3d/IronGate/Valheim/".$world_name."/worlds/".$world_name.".fwl");
    $tempy = preg_match_all("/\|(.*)\|/siU", $raw_fwl, $hexdata_matches);
    $seed = $hexdata_matches[0][0] . $hexdata_matches[0][1];
    $seed = str_replace('.', ' ', $seed);
    $seed = str_replace('|', '', $seed);
    $seed_array = array();
    $seed_array = explode(' ', $seed);
    foreach ($seed_array as $key => $value) {
      if (!empty($value)) {
        $seed_output_array[] = $value;
      }
    }
    $seed = $seed_output_array[2];
  } else {
    $seed = 'Error: world FWL not found';
  }

  $needle = "(running)";
  $pos = strpos($info, $needle);
  
  if ($pos > 0 ) {
    $alert_class = "success";
    $public_attr = "";
    $no_download = "disabled data-toggle=\"tooltip\" data-placement=\"top\" title=\"Must Stop Server to Download\"";
    $no_download_class = "danger";
    $url_copy = '';
    $start_attr = 'disabled';
  } else {
    $alert_class = "danger";
    $port = "<span class='glyphicon glyphicon-remove red'></span> " . $port;
    $name = "Valheim Service Not Running";
    $public_class = "danger";
    $public_attr = "disabled";
    $no_download = '';
    $no_download_class = 'success';
    $url_copy = 'hidden';
    $start_attr = '';
  }

  // Pull the systemctl message
  $active = strstr($info, 'Active:');
  $active = str_replace("Active: ", "", substr($active, 0, strpos($active, ";")));
  if ($active == '') {
    $active = 'Error: Could not retrieve service info';
  }

  // Print the World command bar
  echo '
  <div class="world-item">
  <h2 style="margin-top:24px;"><span class="glyphicon glyphicon-globe" aria-hidden="true"></span> ' . $world_name . '</h2>
        <div class="alert alert-' . $alert_class . ' role="alert">
          <div class="col-7"><span class="glyphicon glyphicon-hdd" aria-hidden="true"></span> ' . $active . '</div>
        </div>
        <div class="row no-gutters">
          <div class="col-md-3">
            <label class="label label-info">Port</label> ' . $port . '
          </div>
          <div class="col-md-3">
            <label class="label label-info">World</label> ' . $world_name . '
          </div>
          <div class="col-md-3">
            <label class="label label-info">Public</label> ' . $public_status . '
          </div>
          <div class="col-md-3">
            <label class="label label-info">Seed</label> ' . $seed . '
          </div>
        </div>
        <div class="row no-gutters">
          <button class="btn btn-danger server-function" onclick="location.href=\'index.php?stop=true&value=' . $world_name . '\';" ' . $public_attr . '>Stop</button> 
          <button class="btn btn-success server-function" onclick="location.href=\'index.php?start=true&value=' . $world_name . '\';" ' . $start_attr . '>Start</button> 
          <button class="btn btn-warning server-function" onclick="location.href=\'index.php?restart=true&value=' . $world_name . '\';" ' . $public_attr . '>Restart</button> 
          <button class="btn btn-' . $no_download_class . '" ' . $no_download . ' onclick="location.href=\'index.php?download_db=true&value=' . $world_name . '\';">Download DB</button> 
          <button class="btn btn-' . $no_download_class . '" ' . $no_download . ' onclick="location.href=\'index.php?download_fwl=true&value=' . $world_name . '\';">Download FWL</button>
        </div>
      </div>';
}
?>


</div>
