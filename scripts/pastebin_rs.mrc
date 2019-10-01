on *:sockopen:pastebin*: {
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
  sockwrite -n $sockname POST /api/api_post.php HTTP/1.1
  sockwrite -n $sockname Host: pastebin.com
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
  .timer $+ $sockname 1 3 pastebin.return $sockname error
}
on *:sockread:pastebin*: {
  var %r
  sockread %r
  ;echo -s sockread $sockname %r
  if ((HTTP/* iswm %r) && ($gettok(%r,2,32) != 200)) || (ERROR* iswm %r) || (0 == %r) {
    pastebin.return $sockname error
  }
  if http://* iswm %r {
    pastebin.return $sockname %r
  }
}
