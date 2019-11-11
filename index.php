<?php  
    $binary = "/usr/bin/prince";

    stream_wrapper_unregister("phar");
    stream_wrapper_unregister("data");
    stream_wrapper_unregister("glob");
    stream_wrapper_unregister("compress.zlib");
    stream_wrapper_unregister("php");

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {

        /* create resume using prince */
        $content = $_POST['content'];
        $filename = md5($_SERVER['REMOTE_ADDR']);
        $file = "/tmp/" . $filename  . ".html";
        $sf = fopen($file, 'w');
        fwrite($sf, $content);
        fclose($sf);

        exec($binary . " --no-local-files " . $file . " -o resumes/" . $filename . ".pdf");

        /* debug */
        $dom = new DOMDocument();
        $dom->loadXML($content, LIBXML_NOENT | LIBXML_DTDLOAD);
        $info = simplexml_import_dom($dom);

        /*$page = '
        <html>
        <head>
            <title>Resumes</title>
            <style>
                textarea {
                width: 500px;
                height: 300px;
            }
            </style>
        </head>
            <body>
                <span>name: ' . $info->name . '</span><br><br>
            </body>
        </html>
            ';

        echo $page;*/

        header('Location: /resumes/' .  $filename . '.pdf');
    } 
    else {
        echo '
            <html>
            <head>
                <title>Resume</title>
                <style>
                    textarea {
                    width: 500px;
                    height: 300px;
                }
                </style>
            </head>
                <body>
                    <h1>Apply today!</h1>
                    <span>Good enough to work with HARPA? send us you resume: </span><br>
                    <textarea name="content" form="princeForm">Enter text here...</textarea>
                    <form method="POST" action="/index.php" id="princeForm">
                        <input type="submit" value="Convert to PDF"></input>
                    </form>
                </body>
            </html>
                ';
    }
