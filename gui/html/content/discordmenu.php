<?php
session_start();

// Verify user logged in, redirect to index if not
session_start();
require '/var/www/VSW-GUI-CONFIG';
if (!isset($_SESSION['login']) || $_SESSION['login'] != $hash) {
	header("Location: /index.php");
	exit();
}

$_SESSION['PAGE'] = 'discordmenu';
?>
<script type="text/javascript">
	$(function() {
		$(".hide-to-fade").fadeIn(300);
	});
</script>
<div class="hide-to-fade">
<h1>DISCORD MENU</h1>
</div>