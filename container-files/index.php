<?php
header("Content-Type:text/plain");

echo "your_hello_world\n\n";
echo "=== \$_SERVER ====\n\n";
var_dump($_SERVER);
echo "=== \$_GET ====\n\n";
var_dump($_GET);
echo "=== \$_POST ====\n\n";
var_dump($_POST);

$other = array(
    "Host"=>function_exists("gethostname")?@gethostname():@php_uname("n"),
    "System"=>php_uname(),
    "PHP Version"=>phpversion(),
    "HHVM Version"=>ini_get("hphp.compiler_version"),
    "HHVM compiler id"=>ini_get("hphp.compiler_id"),
    "SAPI"=>php_sapi_name()." ".ini_get("hhvm.server.type"),
  );

echo "=== Other details ====\n\n";
var_dump($other);

echo "=== Loaded Extensions ====\n\n";
var_dump(get_loaded_extensions());

// mongo test
require_once("../MongoTest.php");
