<?php

// Verify user logged in, redirect to index if not
if (!isset($_SESSION)) {
  session_start();
}
require '/var/www/VSW-GUI-CONFIG';
if (!isset($_SESSION['login']) || $_SESSION['login'] != $hash) {
  header("Location: /index.php");
  exit();
}
$_SESSION['PAGE'] = 'worldmapandseed';

?>
<script type="text/javascript">
  $(function() {
    $(".hide-to-fade").fadeIn(300);

    $(".map_button").click(function(){
      var SRC = $(this).attr('id');
      $("#map_frame").removeClass("hidden");
      $("#map_frame").attr("src", "https://valheim-map.world/?seed=" + SRC + "&offset=506%2C778&zoom=0.077&view=0&ver=0.148.6");
    });
  });
</script>
<div class="hide-to-fade">
<?php
  foreach ($world_array as $key => $value) {
    $world_name = $value;
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
    echo '<button class="btn btn-success map_button" id="' . $seed . '">Map for ' . $world_name . '</button> ';
  }
?>
  <iframe src="" id="map_frame" class="hidden"></iframe>
</div>
