#!/bin/sh

# jison returns 0 on grammar conflicts, so check if any output (such as grammar
# conflicts); if so, exit 1 and display output to stderr
outfile=$1
grammar=$2
lex=$3
jison=$4
echo "$jison" -t "$grammar" "$lex" -o "$outfile"
res=$("$jison" -t "$grammar" "$lex" -o "$outfile")
code=$?
if [ "$code" -eq 0 ] && [ -z "$res" ]; then exit 0
else
  rm "$outfile"
  echo "$res" 1>&2
  exit 1
fi
