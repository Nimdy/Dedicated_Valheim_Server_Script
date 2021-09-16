#!/usr/bin/php
<?php

function GetWorldName() {
    $world_name = htmlspecialchars($_GET['world_name']);
    if ($world_name == '') {
      echo 'ERROR: World name: "' . $world_name . '"';
      exit;
    }
    return $world_name;
}

function checkLogs() {
	$cmd = escapeshellcmd('grep "Got connection SteamID\|Closing socket\|has wrong password\|Got character ZDOID from\|World saved\|- Completed reload, in\|Valheim Server.\|has incompatible version,\|is blacklisted or not in whitelist" /var/log/syslog');
	exec(escapeshellcmd($cmd));
}

// Verify user then check $_GET values for issued server commands
if (isset($_SESSION['login']) && $_SESSION['login'] == $hash) {
  if (isset($_GET['start'])) {
    $value = htmlspecialchars($_GET['value']);
    $command = 'sudo systemctl start valheimserver_' . $value . '.service';
    $info = exec(escapeshellcmd($command));
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['stop'])) {
    $value = htmlspecialchars($_GET['value']);
    $command = 'sudo /usr/bin/systemctl stop valheimserver_' . $value . '.service';
    $info = exec(escapeshellcmd($command));
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['restart'])) {
    $value = htmlspecialchars($_GET['value']);
    $command = 'sudo systemctl restart valheimserver_' . $value . '.service';
    $info = exec(escapeshellcmd($command));
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['download_db'])) {
    $value = htmlspecialchars($_GET['value']);
    if (file_exists("/home/steam/.config/unity3d/IronGate/Valheim/".$value."/worlds/".$value.".db")) {
     # $command = shell_exec('sudo cp -R /home/steam/.config/unity3d/IronGate/Valheim/' . $value . '/worlds/'. $value . '.db ' . dirname(__DIR__) . '/njordgui/html/download/');
      $command = 'sudo /usr/bin/cp -R /home/steam/.config/unity3d/IronGate/Valheim/' . $value . '/worlds/'. $value . '.db ' . dirname(__DIR__) . '/njordgui/html/download/';
      $info = exec(escapeshellcmd($command));
      $dir = dirname(__DIR__) . '/njordgui/html/download/';
      $files = scandir($dir);
      foreach ($files as $key => $value) {
        $ext  = (new SplFileInfo($value))->getExtension();
        if ($ext == 'db' ) {
          header('location: /download/'. $value);
          exit;
        }
      }
    } else {
      header("Location: $_SERVER[PHP_SELF]");
      exit;
    }
  }

  if (isset($_GET['download_fwl'])) {
    $value = htmlspecialchars($_GET['value']);
    if (file_exists("/home/steam/.config/unity3d/IronGate/Valheim/".$value."/worlds/".$value.".fwl")) {
      $command = 'sudo cp -R /home/steam/.config/unity3d/IronGate/Valheim/' . $value . '/worlds/'. $value . '.fwl ' . dirname(__DIR__) . '/njordgui/html/download/';
      $info = exec(escapeshellcmd($command));
      $dir = dirname(__DIR__) . '/njordgui/html/download/';
      $files = scandir($dir);
      foreach ($files as $key => $value) {
        $ext  = (new SplFileInfo($value))->getExtension();
        if ($ext == 'fwl' ) {
          header('location: /download/'. $value);
          exit;
        }
      }
    } else {
      header("Location: $_SERVER[PHP_SELF]");
#trigger_error('Error: No .fwl file found, check permissions and try again.');
      exit;
    }
  }

  if (isset($_GET['add_admin'])) {
    $world_name = GetWorldName();
    $ID = preg_replace("/[^0-9]/", "", $_GET['add_admin'] );
    $full_command = "sudo echo '".$ID."' | sudo tee -a /home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/adminlist.txt";
    $command = exec(escapeshellcmd($full_command));
    $string = file_get_contents(dirname(__DIR__) . "/njordgui/" . $world_name . ".json");
    $json_a = json_decode($string, true);
    // Find entry and edit
    foreach ($json_a as $key => $value) {
      if ($_GET['add_admin'] == $key) {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => '1', 'banned' => $value['banned'], 'allowed' => $value['allowed']);
        $updated = $replace_array;
      } else {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
        $updated = $replace_array;
      }
    }
    $json_a = json_encode($updated);
    file_put_contents(dirname(__DIR__) . '/njordgui/' . $world_name . '.json', $json_a);
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['remove_admin'])) {
    $world_name = GetWorldName();
    $ID = preg_replace("/[^0-9]/", "", $_GET['remove_admin'] );
    $full_command = "sed -i '/^".$ID."/d' /home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/adminlist.txt";
    $command = exec(escapeshellcmd($full_command));
    $string = file_get_contents(dirname(__DIR__) . '/njordgui/' . $world_name . ".json");
    $json_a = json_decode($string, true);
    // Find entry and edit
    foreach ($json_a as $key => $value) {
      if ($_GET['remove_admin'] == $key) {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => '0', 'banned' => $value['banned'], 'allowed' => $value['allowed']);
        $updated = $replace_array;
      } else {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
        $updated = $replace_array;
      }
    }
    $json_a = json_encode($updated);
    file_put_contents(dirname(__DIR__) . '/njordgui/' . $world_name . '.json', $json_a);
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['add_ban'])) {
    $world_name = GetWorldName();
    $ID = preg_replace("/[^0-9]/", "", $_GET['add_ban'] );
    $full_command = "echo '".$ID."' | tee -a /home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/bannedlist.txt";
    $command = exec(escapeshellcmd($full_command));
    $string = file_get_contents(dirname(__DIR__) . '/njordgui/' . $world_name . ".json");
    $json_a = json_decode($string, true);
    // Find entry and edit
    foreach ($json_a as $key => $value) {
      if ($_GET['add_ban'] == $key) {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => '1', 'allowed' => $value['allowed']);
        $updated = $replace_array;
      } else {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
        $updated = $replace_array;
      }
    }
    $json_a = json_encode($updated);
    file_put_contents(dirname(__DIR__) . '/njordgui/' . $world_name . '.json', $json_a);
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['remove_ban'])) {
    $world_name = GetWorldName();
    $ID = preg_replace("/[^0-9]/", "", $_GET['remove_ban'] );
    $full_command = "sed -i '/^".$ID."/d' /home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/bannedlist.txt";
    $command = exec(ecsapeshellcmd($full_command));
    $string = file_get_contents(dirname(__DIR__) . '/njordgui/' . $world_name . ".json");
    $json_a = json_decode($string, true);
    // Find entry and edit
    foreach ($json_a as $key => $value) {
      if ($_GET['remove_ban'] == $key) {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => '0', 'allowed' => $value['allowed']);
        $updated = $replace_array;
      } else {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
        $updated = $replace_array;
      }
    }
    $json_a = json_encode($updated);
    file_put_contents('/var/www/' . $world_name . '.json', $json_a);
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['add_allow'])) {
    $world_name = GetWorldName();
    $ID = preg_replace("/[^0-9]/", "", $_GET['add_allow'] );
    $full_command = "echo '".$ID."' | tee -a /home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/permittedlist.txt";
    $command = exec(escapeshellcmd($full_command));
    $string = file_get_contents(dirname(__DIR__) . '/njordgui/' . $world_name . ".json");
    $json_a = json_decode($string, true);
    // Find entry and edit
    foreach ($json_a as $key => $value) {
      if ($_GET['add_allow'] == $key) {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => '1');
        $updated = $replace_array;
      } else {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
        $updated = $replace_array;
      }
    }
    $json_a = json_encode($updated);
    file_put_contents(dirname(__DIR__) . '/njordgui/' . $world_name . '.json', $json_a);
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['remove_allow'])) {
    $world_name = GetWorldName();
    $ID = preg_replace("/[^0-9]/", "", $_GET['remove_allow'] );
    $full_command = "sed -i '/^".$ID."/d' /home/steam/.config/unity3d/IronGate/Valheim/" . $world_name . "/permittedlist.txt";
    $command = exec(escapeshellcmd($full_command));
    $string = file_get_contents(dirname(__DIR__) . '/njordgui/' . $world_name . ".json");
    $json_a = json_decode($string, true);
    // Find entry and edit
    foreach ($json_a as $key => $value) {
      if ($_GET['remove_allow'] == $key) {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => '0');
        $updated = $replace_array;
      } else {
        $replace_array[$key] = array('username' => $value['username'], 'admin' => $value['admin'], 'banned' => $value['banned'], 'allowed' => $value['allowed']);
        $updated = $replace_array;
      }
    }
    $json_a = json_encode($updated);
    file_put_contents(dirname(__DIR__) . '/njordgui/' . $world_name . '.json', $json_a);
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['remove_ZIP'])) {
    $zip_file = str_replace('"', "", $_GET['remove_ZIP']);
    $zip_file = str_replace("'", "", $zip_file);
    unlink(dirname(__DIR__) . "/njordgui/html/plugins/".$zip_file);
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['remove_MOD'])) {
    $world_name = htmlspecialchars($_GET['world_name']);
    $mod_file = str_replace('"', "", $_GET['remove_MOD']);
    $mod_file = str_replace("'", "", $mod_file);
    $full_command = "rm /home/steam/valheimserver/" . $world_name . "/BepInEx/plugins/" . $mod_file;
    $command = exec(escapeshellcmd($full_command));
    header("Location: $_SERVER[PHP_SELF]");
    exit;
  }

  if (isset($_GET['PUSH'])) {
    $file_to_push = str_replace('"', "", $_GET['PUSH']);
    $file_to_push = str_replace("'", "", $file_to_push);
    $file_to_push = str_replace("%", "/\ ", $file_to_push);
    $world_name = htmlspecialchars($_GET['world_name']);
    $file_path = dirname(__DIR__) . "/njordgui/html/plugins/".$file_to_push;
    if (file_exists($file_path)) {
      // Add ZIP file verification   unzip -t <file>
      $full_command = "-u steam unzip -o " . dirname(__DIR__) . "/njordgui/html/plugins/".$file_to_push." -d /home/steam/valheimserver/" . $world_name . "/BepInEx/plugins/";
      $command = exec(escapeshellcmd($full_command));
    }
    header("Location: $_SERVER[PHP_SELF]");
  }

  if (isset($_POST['upload'])) {
    // Upload ZIPs
    $target_dir = "plugins/";
    $clean_filename = str_replace(' ', '', $_FILES["fileToUpload"]);
    $target_file = $target_dir . basename($clean_filename["name"]);
    $uploadOk = 1;
    $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
    $upload_msg = "";
    if ($_FILES["fileToUpload"]["size"] > 500000) {
      $upload_msg = "Sorry, your file is too large.";
      $uploadOk = 0;
    }
    if($imageFileType != "zip" ) {
      $upload_msg = "Sorry, only ZIP files are allowed.";
      $uploadOk = 0;
    }
    if ($uploadOk == 0) {
      $upload_msg = "Sorry, your file was not uploaded.";
    } else {
      if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        $upload_msg = "The file '". htmlspecialchars( basename( $_FILES["fileToUpload"]["name"])). "' has been uploaded.";
      } else {
        $upload_msg = "Sorry, there was an error uploading your file.";
      }
    }
  }

  if (isset($_GET['ID_to_Verify'] )) {
    $ID_to_Verify = preg_replace("/[^0-9]/", "", $_GET['ID_to_Verify'] );
    $world_name = htmlspecialchars($_GET['world_name']);
    $json_file = dirname(__DIR__) . '/njordgui/' . $world_name . '.json';

    if ($world_name == '') {
      exit;
    }
    $url = "https://steamidfinder.com/lookup/" . $ID_to_Verify;
    $fp = file_get_contents($url);
    $res = preg_match("/name <code>(.*)<\/code>/siU", $fp, $title_matches);
    $title_array = explode(" ", $title_matches[1]);
    if ($title_array[0] == "steam" || $title_array[0] == "404" || $title_array[0] == "" || $title_array[0] == "Steam") {
      // Do Nothing
      echo 'THERE WAS AN ERROR.';
    } else {
      $string = file_get_contents( $json_file );
      $json_a = json_decode($string, true);
      // build user array
      $user_array = array('username' => $title_array[0], 'admin' => '0', 'banned' => '0', 'allowed' => '0');
      // add user array to all_users
      $json_a[$ID_to_Verify] = $user_array;
      $json_a = json_encode($json_a);
      file_put_contents( $json_file, $json_a);
    }
  header("Location: $_SERVER[PHP_SELF]");
  }

  if (isset($_GET['password_update'])) {
    $clean_pass = filter_var($_GET['password_update'], FILTER_SANITIZE_SPECIAL_CHARS);
    $string = file_get_contents(dirname(__DIR__) . "/njordgui/VSW-GUI-CONFIG");
    $updated_string = str_replace("ch4n93m3",$clean_pass,$string);
    file_put_contents(dirname(__DIR__) . '/njordgui/VSW-GUI-CONFIG', $updated_string);
    header("Location: $_SERVER[PHP_SELF]");
  }
}

?>
