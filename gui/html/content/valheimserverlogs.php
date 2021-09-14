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
$_SESSION['PAGE'] = 'valheimserverlogs';
?>
<script type="text/javascript">
	$(function() {
		$(".hide-to-fade").fadeIn(300);
	});
</script>
<div class="hide-to-fade">
<h1>VALHEIM SERVER LOGS</h1>
<div id="log-output">
<?php
  $log = shell_exec('sudo grep "Got connection SteamID\|Closing socket\|has wrong password\|Got character ZDOID from\|World saved\|- Completed reload, in\|Valheim Server.\|has incompatible version,\|is blacklisted or not in whitelist" /var/log/syslog');
  $log_array = explode("\n", $log);
  foreach ($log_array as $key => $value) {
    echo $value . "<br>";
  }
?>
</div>
</div>
