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
  var %close
  var %found
  var %match
  if 1 {
    if *<meta name="robots"* iswm %r {
      var %close 1
    }
    if !%get {
      if *<link* iswm %r {
        var %close 1
      }
      else if *<meta name="keywords"* iswm %r {
        var %found 1
      }
    }
    else {
      var %getregex $replace($gettok($sock($sockname).mark,3,32),$chr(160),$chr(32))
      if *</html>* iswm %r {
        var %close 1
      }
      if $regex(%r,%getregex) {
        var %found 1
        var %match $regml(1)
      }
    }
    if %close {
      sockclose $sockname
      %action
    }
    else if %found {
      sockclose $sockname
      %action %match http://wikiti.brandonw.net $+ %address
    }
  }
  else {
    sockclose $sockname
    %action $iif(200 isin %r,http://wikiti.brandonw.net $+ %address)
  }
}
