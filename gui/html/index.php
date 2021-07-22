<?php

// Set a nonce value for CSP script verification
$nonce = bin2hex(random_bytes('4'));

// Set headers
// header("Content-Security-Policy: default-src 'self' stackpath.bootstrapcdn.com maxcdn.bootstrapcdn.com code.jquery.com; frame-ancestors 'self'; base-uri 'self'; form-action 'self'; require-trusted-types-for 'script'; object-src 'none'; script-src 'nonce-$nonce';");
// header("X-Frame-Options: SAMEORIGIN");
// header("X-Content-Type-Options nosniff");
// header("X-XSS-Protection: 1; mode=block");
// header("Strict-Transport-Security: max-age=600; includeSubDomains");
// header('Set-Cookie: PHPSESSID=value2; SameSite=None; Secure', false);

// Set session cookie security
// ini_set('session.cookie_httponly', 1);
// ini_set('session.use_only_cookies', 1);
// ini_set('session.cookie_secure', 1);
// ini_set('session.cookie_samesite', 'strict');

// Get the config file
require '/var/www/VSW-GUI-CONFIG';

session_start();
if (!isset($_SESSION['PAGE'])) {
  $_SESSION['PAGE'] = 'valheimnjordgui';
}

// ********** USER LOGOUT  ********** //
if(isset($_GET['logout'])) {
  unset($_SESSION['login']);
  header("Location: $_SERVER[PHP_SELF]");
  exit;
}

require '/var/www/commands.php';

?>
<html>
  <head>
    <!-- JQuery and Bootstrap libraries -->
    <script nonce="<?php echo $nonce; ?>" src="/libs/jquery.js" crossorigin="anonymous"></script>
    <link nonce="<?php echo $nonce; ?>" rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
    <link nonce="<?php echo $nonce; ?>" rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">
    <link nonce="<?php echo $nonce; ?>" rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <script nonce="<?php echo $nonce; ?>" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>

    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Poppins">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Ubuntu+Mono">
    <link nonce="<?php echo $nonce; ?>" rel="stylesheet" href="fancy.css" crossorigin="anonymous">
      <script type="text/javascript">
      $(function() {
        $("#collapse").click(function() {
          $("#navbar").toggleClass("collapsed");
          $("#main").toggleClass("collapsed");
          $(".menu-text-item").toggleClass("collapsed");
          $("#collapse-menu-item").toggleClass("collapsed");
          $("#collapse_on").toggleClass("hidden");
          $("#collapse_off").toggleClass("hidden");
        });
        $("#logout").click(function() {
          window.location.replace("index.php?logout=true");
        });
        $(".menu-item").click(function(){
          var pageID = "";
          // $("#content").load('/content/loading.php');
          var pageID = this.id;
          $("#content").load('/content/'+this.id+'.php');
        });
      });
      </script>
</head>

<body>
<?php
// ********** Form has been submitted ********** //
      if (isset($_POST['submit'])) {
        if ($_POST['username'] == $username && $_POST['password'] == $password){
          // If username and password correct, log in
          $_SESSION["login"] = $hash;
          define('FOOTER_CONTENT', 'Hello I\'m an awesome footer!');
          header("Location: $_SERVER[PHP_SELF]");    
        } else {      
          // Display error on bad login
          display_login_form();
          echo '<div class="alert alert-danger">Incorrect login information.</div>';
          exit;
        }
      }

      if (isset($_SESSION['login']) && $_SESSION['login'] == $hash) {
    // *************************************** //
    // ********** Logged In Content ********** //
    // *************************************** //
  
    // Version Control
        $url = "https://raw.githubusercontent.com/Peabo83/Valheim-Server-Web-GUI/main/.gitignore/version";
        $latest_version = file_get_contents($url);
        $latest_version = strtok($latest_version, "\n");
        if ($version == $latest_version) {
          // DO NOTHING
        } else {
          echo "<div class='row alert alert-danger' role='alert'><div class='col-12'><span class='glyphicon glyphicon-warning-sign'></span> Your version of this GUI is out out of date. (current version: ".$version." - latest version:<a href='https://github.com/Peabo83/Valheim-Server-Web-GUI'>".$latest_version."</a>)</div></div>";
        }
    // End Version Control
?>
  <div id="gui-container">
      <div id="navbar" class="transition">
        <div id="menu_image">
          <img src="njord_menu.png">
        </div>
        <div id="collapse-menu-item" class="row">
          <div class="col-6">
            <div id="collapse"><span class="collapse-label transition">Collapse</span> <span id="collapse_on" class="material-icons transition hidden">toggle_on</span> <span id="collapse_off" class="material-icons transition">toggle_off</span></div>
          </div>
          <div class="col-6">
            <div id="logout"><span class="collapse-label transition">Logout</span> <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M16 13L16 11 7 11 7 8 2 12 7 16 7 13z"></path><path d="M20,3h-9C9.897,3,9,3.897,9,5v4h2V5h9v14h-9v-4H9v4c0,1.103,0.897,2,2,2h9c1.103,0,2-0.897,2-2V5C22,3.897,21.103,3,20,3z"></path></svg></div>
          </div>
        </div>

          <div class="menu-item" id="valheimnjordgui">
            <div class="circle"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 16 16" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><rect width="4" height="5" x="1" y="10" rx="1"></rect><rect width="4" height="9" x="6" y="6" rx="1"></rect><rect width="4" height="14" x="11" y="1" rx="1"></rect></svg>
            </div><div class="menu-text-item transition">Valheim Njord GUI</div>
          </div>


          <div class="menu-item" id="servercommands">
            <div class="circle"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 16 16" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M0 3a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H2a2 2 0 01-2-2V3zm9.5 5.5h-3a.5.5 0 000 1h3a.5.5 0 000-1zm-6.354-.354L4.793 6.5 3.146 4.854a.5.5 0 11.708-.708l2 2a.5.5 0 010 .708l-2 2a.5.5 0 01-.708-.708z" clip-rule="evenodd"></path></svg></div>
            <div class="menu-text-item transition">Server Commands</div>
          </div>

          <div class="menu-item" id="discordmenu">
            <div class="circle"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 448 512" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M297.216 243.2c0 15.616-11.52 28.416-26.112 28.416-14.336 0-26.112-12.8-26.112-28.416s11.52-28.416 26.112-28.416c14.592 0 26.112 12.8 26.112 28.416zm-119.552-28.416c-14.592 0-26.112 12.8-26.112 28.416s11.776 28.416 26.112 28.416c14.592 0 26.112-12.8 26.112-28.416.256-15.616-11.52-28.416-26.112-28.416zM448 52.736V512c-64.494-56.994-43.868-38.128-118.784-107.776l13.568 47.36H52.48C23.552 451.584 0 428.032 0 398.848V52.736C0 23.552 23.552 0 52.48 0h343.04C424.448 0 448 23.552 448 52.736zm-72.96 242.688c0-82.432-36.864-149.248-36.864-149.248-36.864-27.648-71.936-26.88-71.936-26.88l-3.584 4.096c43.52 13.312 63.744 32.512 63.744 32.512-60.811-33.329-132.244-33.335-191.232-7.424-9.472 4.352-15.104 7.424-15.104 7.424s21.248-20.224 67.328-33.536l-2.56-3.072s-35.072-.768-71.936 26.88c0 0-36.864 66.816-36.864 149.248 0 0 21.504 37.12 78.08 38.912 0 0 9.472-11.52 17.152-21.248-32.512-9.728-44.8-30.208-44.8-30.208 3.766 2.636 9.976 6.053 10.496 6.4 43.21 24.198 104.588 32.126 159.744 8.96 8.96-3.328 18.944-8.192 29.44-15.104 0 0-12.8 20.992-46.336 30.464 7.68 9.728 16.896 20.736 16.896 20.736 56.576-1.792 78.336-38.912 78.336-38.912z"></path></svg></div>
            <div class="menu-text-item transition">Discord Menu</div>
          </div>

          <div class="menu-item" id="worldmapandseed">
            <div class="circle"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 496 512" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M248 8C111 8 0 119 0 256s111 248 248 248 248-111 248-248S385 8 248 8zm200 248c0 22.5-3.9 44.2-10.8 64.4h-20.3c-4.3 0-8.4-1.7-11.4-4.8l-32-32.6c-4.5-4.6-4.5-12.1.1-16.7l12.5-12.5v-8.7c0-3-1.2-5.9-3.3-8l-9.4-9.4c-2.1-2.1-5-3.3-8-3.3h-16c-6.2 0-11.3-5.1-11.3-11.3 0-3 1.2-5.9 3.3-8l9.4-9.4c2.1-2.1 5-3.3 8-3.3h32c6.2 0 11.3-5.1 11.3-11.3v-9.4c0-6.2-5.1-11.3-11.3-11.3h-36.7c-8.8 0-16 7.2-16 16v4.5c0 6.9-4.4 13-10.9 15.2l-31.6 10.5c-3.3 1.1-5.5 4.1-5.5 7.6v2.2c0 4.4-3.6 8-8 8h-16c-4.4 0-8-3.6-8-8s-3.6-8-8-8H247c-3 0-5.8 1.7-7.2 4.4l-9.4 18.7c-2.7 5.4-8.2 8.8-14.3 8.8H194c-8.8 0-16-7.2-16-16V199c0-4.2 1.7-8.3 4.7-11.3l20.1-20.1c4.6-4.6 7.2-10.9 7.2-17.5 0-3.4 2.2-6.5 5.5-7.6l40-13.3c1.7-.6 3.2-1.5 4.4-2.7l26.8-26.8c2.1-2.1 3.3-5 3.3-8 0-6.2-5.1-11.3-11.3-11.3H258l-16 16v8c0 4.4-3.6 8-8 8h-16c-4.4 0-8-3.6-8-8v-20c0-2.5 1.2-4.9 3.2-6.4l28.9-21.7c1.9-.1 3.8-.3 5.7-.3C358.3 56 448 145.7 448 256zM130.1 149.1c0-3 1.2-5.9 3.3-8l25.4-25.4c2.1-2.1 5-3.3 8-3.3 6.2 0 11.3 5.1 11.3 11.3v16c0 3-1.2 5.9-3.3 8l-9.4 9.4c-2.1 2.1-5 3.3-8 3.3h-16c-6.2 0-11.3-5.1-11.3-11.3zm128 306.4v-7.1c0-8.8-7.2-16-16-16h-20.2c-10.8 0-26.7-5.3-35.4-11.8l-22.2-16.7c-11.5-8.6-18.2-22.1-18.2-36.4v-23.9c0-16 8.4-30.8 22.1-39l42.9-25.7c7.1-4.2 15.2-6.5 23.4-6.5h31.2c10.9 0 21.4 3.9 29.6 10.9l43.2 37.1h18.3c8.5 0 16.6 3.4 22.6 9.4l17.3 17.3c3.4 3.4 8.1 5.3 12.9 5.3H423c-32.4 58.9-93.8 99.5-164.9 103.1z"></path></svg></div>
            <div class="menu-text-item transition">World Map and Seed</div>
          </div>

          <div class="menu-item" id="notifications">
            <div class="circle"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 512 512" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M440.08 341.31c-1.66-2-3.29-4-4.89-5.93-22-26.61-35.31-42.67-35.31-118 0-39-9.33-71-27.72-95-13.56-17.73-31.89-31.18-56.05-41.12a3 3 0 01-.82-.67C306.6 51.49 282.82 32 256 32s-50.59 19.49-59.28 48.56a3.13 3.13 0 01-.81.65c-56.38 23.21-83.78 67.74-83.78 136.14 0 75.36-13.29 91.42-35.31 118-1.6 1.93-3.23 3.89-4.89 5.93a35.16 35.16 0 00-4.65 37.62c6.17 13 19.32 21.07 34.33 21.07H410.5c14.94 0 28-8.06 34.19-21a35.17 35.17 0 00-4.61-37.66zM256 480a80.06 80.06 0 0070.44-42.13 4 4 0 00-3.54-5.87H189.12a4 4 0 00-3.55 5.87A80.06 80.06 0 00256 480z"></path></svg></div>
            <div class="menu-text-item transition">Notifications</div>
          </div>

          <div class="menu-item" id="playeroptions">
            <div class="circle"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 16 16" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M7 14s-1 0-1-1 1-4 5-4 5 3 5 4-1 1-1 1H7zm4-6a3 3 0 100-6 3 3 0 000 6zm-5.784 6A2.238 2.238 0 015 13c0-1.355.68-2.75 1.936-3.72A6.325 6.325 0 005 9c-4 0-5 3-5 4s1 1 1 1h4.216zM4.5 8a2.5 2.5 0 100-5 2.5 2.5 0 000 5z" clip-rule="evenodd"></path></svg></div>
            <div class="menu-text-item transition">Player Options</div>
          </div>

          <div class="menu-item" id="modsmenu">
            <div class="circle"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><g><path fill="none" d="M0 0h24v24H0z"></path><path d="M12.414 5H21a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h7.414l2 2zm-3.823 8.809l-.991.572 1 1.731.991-.572c.393.371.872.653 1.405.811v1.145h1.999V16.35a3.495 3.495 0 0 0 1.404-.811l.991.572 1-1.73-.991-.573a3.508 3.508 0 0 0 0-1.622l.99-.573-.999-1.73-.992.572a3.495 3.495 0 0 0-1.404-.812V8.5h-1.999v1.144a3.495 3.495 0 0 0-1.404.812L8.6 9.883 7.6 11.615l.991.572a3.508 3.508 0 0 0 0 1.622zm3.404.688a1.5 1.5 0 1 1 0-2.998 1.5 1.5 0 0 1 0 2.998z"></path></g></svg>
            </div><div class="menu-text-item transition">Mods Menu</div>
          </div>

          <div class="menu-item" id="valheimserverlogs">
            <div class="circle"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 16 16" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M4 1h5v1H4a1 1 0 00-1 1v10a1 1 0 001 1h8a1 1 0 001-1V6h1v7a2 2 0 01-2 2H4a2 2 0 01-2-2V3a2 2 0 012-2z"></path><path d="M9 4.5V1l5 5h-3.5A1.5 1.5 0 019 4.5z"></path><path fill-rule="evenodd" d="M5 11.5a.5.5 0 01.5-.5h2a.5.5 0 010 1h-2a.5.5 0 01-.5-.5zm0-2a.5.5 0 01.5-.5h5a.5.5 0 010 1h-5a.5.5 0 01-.5-.5zm0-2a.5.5 0 01.5-.5h5a.5.5 0 010 1h-5a.5.5 0 01-.5-.5z" clip-rule="evenodd"></path></svg>
            </div><div class="menu-text-item transition">Valheim Server Logs</div>
          </div>

      </div>
      <div id="main" class="transition">
        <div id="content">
          <?php 
          include('./content/'.$_SESSION['PAGE'].'.php'); ?>
        </div>
      </div>

  </div>
<?php }
// ********** End IF  ********** //
// ********** Login Form  ********** //
  else {
    display_login_form();
  }
  function display_login_form() { ?>
    <form action="index.php" method='post'>
      <div id="navbar" class="transition login">
        <div class="row">
          <div class="col-4">
            <img src="njord_menu.png">
          </div>
          <div class="col-8">
            <input type="text" name="username" id="username" class="form-control" placeholder="Username">
            <input type="password" name="password" id="password" class="form-control" placeholder="Password">
            <input class="btn btn-success right" type="submit" name="submit" value="submit">
            </form>
          </div>
        </div>
        </div>
      </div>
    </div>
  <?php } ?>

</body>
</html>
