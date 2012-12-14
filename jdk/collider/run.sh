#!/bin/sh

N=14

JAVA=java

$JAVA -version
echo

echo "insert 2^$N non-colliding elements"
$JAVA -jar collider.jar $N 

echo

echo "insert 2^$N colliding elements"
$JAVA -Djdk.map.althashing.threshold=1 -jar collider.jar $N 
