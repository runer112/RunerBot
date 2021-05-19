on *:sockopen:jacobly.paste.*: {
  ;echo -s sockopen $sockname

  var %file $gettok($sock($sockname).mark,1,$asc("))
  sockmark $sockname $gettok($sock($sockname).mark,2-,$asc("))

  var %i 1
  while %i <= $lines(%file) {
    var %r $read(%file,nt,%i)
    ;echo -s sockwrite -n $sockname %r
    sockwrite -n $sockname %r
    inc %i
  }

  .timer $+ $sockname 1 1 jacobly.paste.return $sockname error
}

on *:sockread:jacobly.paste.*: {
  var %r
  sockread %r
  ;echo -s sockread $sockname %r
  if (http* iswm %r) {
    jacobly.paste.return $sockname %r
  }
  jacobly.paste.return $sockname error
}
