on *:sockopen:wikiti*: {
  ;echo -s sockopen $sockname
  ;echo -s sockmark $sock($sockname).mark
  sockwrite -n $sockname GET $gettok($sock($sockname).mark,1,32) HTTP/1.1
  sockwrite -n $sockname Host: wikiti.brandonw.net
  sockwrite $sockname $crlf
}
on *:sockread:wikiti*: {
  var %r
  sockread %r
  ;echo -s sockread $sockname %r
  var %address $gettok($sock($sockname).mark,1,32)
  var %get $gettok($sock($sockname).mark,2,32)
  var %action $gettok($sock($sockname).mark,4-,32)
  if 0 {
    if *<meta name="robots"* iswm %r {
      :close
      sockclose $sockname
      %action
      halt
    }
    if !%get {
      if *<link* iswm %r {
        goto close
      }
      if *<meta name="keywords"* iswm %r {
        :pagefound
        sockclose $sockname
        %action http://wikiti.brandonw.net $+ %address
      }
    }
    else {
      var %getregex $replace($gettok($sock($sockname).mark,3,32),$chr(160),$chr(32))
      if *</html>* iswm %r {
        goto pagefound
      }
      if $regex(%r,%getregex) {
        sockclose $sockname
        %action $regml(1) http://wikiti.brandonw.net $+ %address
      }
    }
  }
  sockclose $sockname
  %action $iif(200 isin %r,http://wikiti.brandonw.net $+ %address)
}
