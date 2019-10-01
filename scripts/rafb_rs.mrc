on *:sockopen:rafb*: {
  ;echo -s sockopen $sockname
  var %params $gettok($sock($sockname).mark,1,32)
  var %file $gettok($sock($sockname).mark,2,$asc("))
  sockmark $sockname $gettok($sock($sockname).mark,3-,$asc("))
  var %len $len(%params)
  var %i 1
  while %i <= $lines(%file) {
    var %r $read(%file,nt,%i)
    inc %len $len($encodeurl(%r))
    inc %len 3
    inc %i
  }
  sockwrite -n $sockname POST /paste.php HTTP/1.1
  sockwrite -n $sockname Host: rafb.me
  sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
  sockwrite -n $sockname Content-length: %len
  sockwrite $sockname $crlf
  sockwrite $sockname %params
  var %i 1
  while %i <= $lines(%file) {
    var %r $read(%file,nt,%i)
    sockwrite $sockname $+($encodeurl(%r),%,0A)
    inc %i
  }
  .timer $+ $sockname 1 1 rafb.return $sockname error
}
on *:sockread:rafb*: {
  var %r
  sockread %r
  ;echo -s sockread $sockname %r
  if (HTTP/1.1 302* iswm %r) {
    sockread %r
    ;echo -s sockread $sockname %r
    sockread %r
    ;echo -s sockread $sockname %r
    sockread %r
    ;echo -s sockread $sockname %r
    if $regex(%r,/^Location: (.+)$/i) {
      rafb.return $sockname $regml(1)
    }
  }
  rafb.return $sockname error
}
