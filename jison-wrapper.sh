#!/bin/sh

# jison returns 0 on grammar conflicts, so check if any output (such as grammar
# conflicts); if so, exit 1 and display output to stderr
outfile=$1
grammar=$2
lex=$3
jison=$4

tmpf=$(mktemp)
trap "rm -f $tmpf" EXIT

debug=$5
if [ -z "$debug" ]; then
  echo "$jison" "$grammar" "$lex" -o "$outfile"
  "$jison" "$grammar" "$lex" -o "$outfile" > "$tmpf"
  if [ $? -eq 0 ] && [ ! -s "$tmpf" ]; then exit 0; fi
else
  echo "$jison" -t "$grammar" "$lex" -o "$outfile"
  "$jison" -t "$grammar" "$lex" -o "$outfile" > "$tmpf"
  if [ $? -eq 0 ] && ! grep -i conflict "$tmpf"; then
    cat "$tmpf"
    exit 0
  fi
fi

rm -f "$outfile"
cat "$tmpf" 1>&2
exit 1
