<?php
// Verify user logged in, redirect to index if not
session_start();
require(dirname(__DIR__).'../../VSW-GUI-CONFIG');
if (!isset($_SESSION['login']) || $_SESSION['login'] != $hash) {
  header("Location: /index.php");
  exit();
}
$_SESSION['PAGE'] = 'valheimnjordgui';
?>
<script type="application/javascript">

function resizeIFrameToFitContent( iFrame ) {

    iFrame.width  = iFrame.contentWindow.document.body.scrollWidth;
    iFrame.height = iFrame.contentWindow.document.body.scrollHeight;
}

window.addEventListener('DOMContentLoaded', function(e) {

    var iFrame = document.getElementById( 'iFrame1' );
    resizeIFrameToFitContent( iFrame );

    // or, to resize all iframes:
    var iframes = document.querySelectorAll("iframe");
    for( var i = 0; i < iframes.length; i++) {
        resizeIFrameToFitContent( iframes[i] );
    }
} );

</script>
<iframe src="./sys/index.php" width="100%" height="100%" id="iFrame1"  style="border: none; overflow-x: hidden; max-height: 90vh;">no iframe</iframe>