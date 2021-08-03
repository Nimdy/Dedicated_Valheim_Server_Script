<?php
// Verify user logged in, redirect to index if not
if (!isset($_SESSION)) {
  session_start();
}
require(dirname(__DIR__, 2).'/VSW-GUI-CONFIG');
if (!isset($_SESSION['login']) || $_SESSION['login'] != $hash) {
	header("Location: $_SERVER[PHP_SELF]");
	exit();
}

$_SESSION['PAGE'] = 'playeroptions';

function get_username($steamID) {
		// Get username from steamfinder
    	$url = "https://steamidfinder.com/lookup/" . $steamID;
    	$fp = file_get_contents($url);
        $res = preg_match("/<title>(.*)<\/title>/siU", $fp, $title_matches);
        $title_array = explode(" ", $title_matches[1]);
        $user_name = $title_array[0];
        return $user_name;
	}

function print_button($steamID, $username, $admin, $banned, $allowed, $style, $world_name) {
	echo '<div class="btn-group" role="group">
			<button type="button" class="btn ' . $style . ' dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">' . $username . '</button>
		    <ul class="dropdown-menu">
		    	<header>' . $steamID . '</header>';
		    	echo '<a href="https://steamidfinder.com/lookup/' . $steamID . '" target="_blank"><li>View on Steamfinder</li></a>';
		    	if ($admin == '0') {
		    		echo '<a href="?add_admin=' . $steamID . '&world_name=' . $world_name . '"><li>Make Admin</li></a>';
		    	} else {
		    		echo '<a href="?remove_admin=' . $steamID . '&world_name=' . $world_name . '"><li>Remove Admin</li></a>';
		    	}
		    	if ($banned == '0') {
		    		echo '<a href="?add_ban=' . $steamID . '&world_name=' . $world_name . '"><li>Ban User</li></a>';
		    	} else {
		    		echo '<a href="?remove_ban=' . $steamID . '&world_name=' . $world_name . '"><li>Remove Ban</li></a>';
		    	}
		    	if ($allowed == '0') {
		    		echo '<a href="?add_allow=' . $steamID . '&world_name=' . $world_name . '"><li>Add to Allow</li></a>';
		    	} else {
		    		echo '<a href="?remove_allow=' . $steamID . '&world_name=' . $world_name . '"><li>Remove Allow</li></a>';
		    	}
	echo '	</ul>
		  </div>';
	//}
}

$all_users = array();
?>
<script type="text/javascript">
	$(function() {
		$(".hide-to-fade").fadeIn(300);
	});
</script>
<div class="hide-to-fade">
<h1>Player Options</h1>

<?php

foreach ($world_array as $key => $value) {
		
		// Sterilize variables
		$all_users = array();
		$user_array = array();
		$world_name = '';
		$unassigned_users = array();
		$unassigned_user_array = array();
		$admin_users = array();
		$admin_user_array = array();
		$banned_users = array();
		$banned_user_array = array();
		$permitted_users = array();
		$allowed_user_array = array();

		$world_name = $value;

		echo '<div class="row world-item"><div class="col-md-12"><h2><span class="glyphicon glyphicon-globe" aria-hidden="true"></span> ' . $world_name . '</h2>';

		// Verify world .JSON file exists, if not, create it and set string value
		if (file_exists(dirname(__DIR__, 2) . '/' . $world_name . ".json")) {
			$string = file_get_contents(dirname(__DIR__, 2) . '/' . $world_name . ".json");
		} else {
			$json_data = '';
			file_put_contents(dirname(__DIR__, 2) . '/' . $world_name . '.json', $json_data);
			$string = '';
		}

		// Build a JSON file - This only runs if /var/www/$world_name.json is empty
		$json_a = json_decode($string, true);
		if ($json_a === null) {
			// echo "No Users in users.json found. Attempting to construct file, this may take a moment.<br>";

			// Location of banlist.txt
			$file = fopen("/home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/bannedlist.txt", "r");
			//Output lines until EOF reached
			while(! feof($file)) {
			  $line = fgets($file);
			  if (strpos($line, 'List banned players ID  ONE per line') == false) {
			    $clean_line = strtok($line, "\n");
			    if (!empty($line) && $clean_line != "" ) {
			    	// Get username from steamfinder
			    	$user_name = get_username($clean_line);
                    // build user array
			    	$user_array[$clean_line] = array('username' => $user_name, 'admin' => '0', 'banned' => '1', 'allowed' => '0');
			    	// add user array to all_users
			    	$all_users = $user_array;
			    }
			  }
			}
			fclose($file);

			// Location of adminlist.txt
			$file = fopen("/home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/adminlist.txt", "r");
			//Output lines until EOF reached
			while(! feof($file)) {
			  $line = fgets($file);
			  if (strpos($line, 'List admin players ID  ONE per line') == false) {
			    $clean_line = strtok($line, "\n");
			    if (!empty($line) && $clean_line != "" ) {
			    	// Get username from steamfinder
			    	$user_name = get_username($clean_line);
                    // build user array
			      	$user_array[$clean_line] = array('username' => $user_name, 'admin' => '1', 'banned' => '0', 'allowed' => '0');
			      	// add user array to all_users
			    	$all_users = $user_array;
			    }
			  }
			}
			fclose($file);

			// Location of permittedlist.txt
			$file = fopen("/home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/permittedlist.txt", "r");
			//Output lines until EOF reached
			while(! feof($file)) {
				$line = fgets($file);
				if (strpos($line, 'List permitted players ID ONE per line') == false) {
			    	$clean_line = strtok($line, "\n");
			    	$in_array = false;
			    	if (!empty($line) && $clean_line != "") {

				    	foreach ($all_users as $key => $value) {
				    		if ($key == $clean_line) {
				    			unset($all_users[$key]);
				    			$user_array[$clean_line] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => '0', 'allowed' => '1');
				    			$all_users = $user_array;
				    			$in_array = true;
				    		}
				    	}
				    	if ($in_array == false) {
				    		// Get username from steamfinder
					    	$user_name = get_username($clean_line);
			                // build user array
					      	$user_array[$clean_line] = array('username' => $user_name, 'admin' => '0', 'banned' => '0', 'allowed' => '1');
					      	// add user array to all_users
					    	$all_users = $user_array;
				    	}

				    }
			  	}
			}
			fclose($file);

			$recent_players = shell_exec('sudo grep -E "'. $world_name .'.*handshake" /var/log/syslog');
	        $recent_players = nl2br($recent_players);
	        $recent_players_array = explode('<br />', $recent_players);
	        // Recent players from syslog
	        foreach ($recent_players_array as $key => $value) {
	        	// Pull steamID from syslog, clean data, check not already in all_users, then add to all_users
				$steam_long_id = substr($value, strpos($value, "Got connection SteamID"));
				$steam_long_id = substr($steam_long_id, strpos($steam_long_id, "client"));
				$steam_long_id = str_replace('client ', '', $steam_long_id);
				$in_array = false;

				// Check if steamID is already in all_users
	    		foreach ($all_users as $all_key => $all_value) {
	    			if ($all_key == $steam_long_id) {
	    				$in_array = true;
	    			}
	    		}

	    		if ($in_array == false) {
	    			// Get username from steamfinder
	    			$user_name = '';
	    			$user_array = array();
			    	$user_name = get_username($steam_long_id);
	                // build user array
	                if ($user_name == '' || empty($user_name) || $user_name == "Steam" ) {
	                	// Do nothing
	                } else {
	                	$user_array[$steam_long_id] = array('username' => $user_name, 'admin' => '0', 'banned' => '0', 'allowed' => '0');
				      	// add user array to all_users
				    	$all_users = $user_array;
				    }
	    		}
			}

			// If we found no users, show SteamID input
			if (empty($all_users)) {
				echo 'No users available yet. Enter a user\'s steamID64(Dec) to add them. More info on getting that ID found <a href="https://steamidfinder.com/" target="_blank">here.</a>';
            // Else write the json file
			} else {
				$json_data = '';
				$json_data = json_encode($all_users);
				file_put_contents(dirname(__DIR__, 2) . '/' . $world_name . '.json', $json_data);
			}

		}
		// END IF

		// Reload the JSON data so the page loads cleanly
		$string = file_get_contents(dirname(__DIR__, 2) . '/' . $world_name . ".json");
		$json_a = json_decode($string, true);		

		foreach ($json_a as $key => $value) {
			//echo $key . ' - ' . $value['admin'] . ' - ' . $value['banned'] . ' - ' . $value['allowed'] . ' - ' . $value['username'] . '<br>';
			$all_users[] = $key;

			if ($value['admin'] == '1') {
				$admin_user_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
				$admin_users = $admin_user_array;
			}
			if ($value['banned'] == '1') {
				$banned_user_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
				$banned_users = $banned_user_array;
			}
			if ($value['allowed'] == '1') {
				$allowed_user_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
				$permitted_users = $allowed_user_array;
			}
			if ($value['allowed'] == '0' && $value['admin'] == '0' && $value['banned'] == '0') {
				$unassigned_user_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
				$unassigned_users = $unassigned_user_array;
			}
		}


			// $recent_players = shell_exec('sudo grep -E "'. $world_name .'.*handshake" /var/log/syslog');
	  //       $recent_players = nl2br($recent_players);
	  //       $recent_players_array = explode('<br />', $recent_players);
	  //       $new_recent = array();
	  //       // Recent players from syslog
	  //       foreach ($recent_players_array as $key => $value) {
	  //       	// Pull steamID from syslog, clean data, check not already in all_users, then add to all_users
			// 	$steam_long_id = substr($value, strpos($value, "Got connection SteamID"));
			// 	$steam_long_id = substr($steam_long_id, strpos($steam_long_id, "client"));
			// 	$steam_long_id = str_replace('client ', '', $steam_long_id);
			// 	$in_array = false;

			// 	// Check if steamID is already in all_users
	  //   		foreach ($all_users as $all_key => $all_value) {
	  //   			if ($all_key == $steam_long_id) {
	  //   				$in_array = true;
	  //   			}
	  //   		}
	  //   		if ($in_array == false) {
	  //   			// Get username from steamfinder
			//     	$user_name = get_username($steam_long_id);
	  //               // build user array
	  //               if ($user_name == '' || empty($user_name) || $user_name == "Steam" ) {
	  //               	// Do nothing
	  //               } else {
	  //               	$user_array[$steam_long_id] = array('username' => $user_name, 'admin' => '0', 'banned' => '0', 'allowed' => '0');
			// 	      	// add user array to all_users
			// 	    	$unassigned_users = $user_array;
			// 	    }
	  //   		}
			// }



		if (!empty($unassigned_users)) {
			echo '<h1>Recent</h1>';
			foreach ($unassigned_users as $key => $value) {
				print_button($key, $value['username'], $value['admin'], $value['banned'], $value['allowed'], 'btn-info', $world_name );
			}
		}

		if (!empty($admin_users)) {
			echo '<h1>Admins</h1>';
			foreach ($admin_users as $key => $value) {
				print_button($key, $value['username'], $value['admin'], $value['banned'], $value['allowed'], 'btn-success', $world_name );
			}
		}

		if (!empty($banned_users)) {
			echo '<h1>Banned</h1>';
			foreach ($banned_users as $key => $value) {
				print_button($key, $value['username'], $value['admin'], $value['banned'], $value['allowed'], 'btn-danger', $world_name );
			}
		}

		if (!empty($permitted_users)) {
			echo '<h1>Allowed</h1>';
			foreach ($permitted_users as $key => $value) {
				print_button($key, $value['username'], $value['admin'], $value['banned'], $value['allowed'], 'btn-warning', $world_name );
			}
		}

		echo '	<form method="get" action="index.php">
					<div class="input-group">
					<input type="text" name="ID_to_Verify" class="form-control" placeholder="Validate a player\'s steamID64(Dec)">
					<input type="hidden" name="world_name" value="' . $world_name . '">
					<input type="submit" class="btn btn-success" class="form-control">
					</div>
				</form></div></div>';

	}

?>

</div>