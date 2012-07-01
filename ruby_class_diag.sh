#!/bin/sh
echo 'digraph {'
echo '  graph [ ratio = "0.5" ]'
echo '  node [ shape = box ]'
echo '  edge [ arrowhead = empty ]'
grep 'class.* <' *.rb | sed 's/.*class //g;s/</->/g'
echo '}'
