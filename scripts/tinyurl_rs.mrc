on *:sockopen:tinyurl*: {
  ;echo -s sockopen $sockname $sock($sockname).mark
  sockwrite -n $sockname GET /create.php?format=simple&url= $+ $gettok($sock($sockname).mark,1,32) HTTP/1.1
  sockwrite -n $sockname Host: is.gd
  sockwrite $sockname $crlf
}
on *:sockread:tinyurl*: {
  var %r
  sockread %r
  ;echo -s sockread $sockname %r
  if 0 {
    if ((HTTP/* iswm %r) && ($gettok(%r,2,32) != 200)) || (ERROR* iswm %r) {
      tinyurl.return $sockname $gettok($sock($sockname).mark,1,32)
      halt
    }
    if http://* iswm %r {
      tinyurl.return $sockname %r
      halt
    }
  }
  if HTTP/1.1 200 OK == %r {
    while $sockbr {
      if http://* iswm %r {
        tinyurl.return $sockname %r
        halt
      }
      sockread %r
      ;echo -s sockread $sockname %r
    }
  }
  tinyurl.return $sockname $gettok($sock($sockname).mark,1,32)
  halt
}
