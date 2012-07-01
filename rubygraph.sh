#!/bin/sh
echo "digraph {"
echo "  node [ shape = box ]"
grep require *.rb | sed 's/\:/ /g;s/"//g;s/\.rb//g;s/require/->/g'
echo "}"
