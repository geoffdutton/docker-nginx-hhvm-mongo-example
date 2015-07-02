<?php
echo "\n\n";
if(class_exists("MongoClient")) {
  echo "HOORAY! The mongo extension installed!!!";
}
else {
  echo "Son of a! The mongo extension is effed :(";
}
echo "\n\n";
