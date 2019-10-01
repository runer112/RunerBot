/wikiti {
  var %tinyurl 0
  var %get
  if -* iswm $1 {
    var %flags $right($1,-1)
    tokenize 32 $2-
    var %f in
    while %f != $null {
      if %f == t {
        var %tinyurl 1
      }
      elseif %f == g {
        var %get $1
        tokenize 32 $2-
      }
      elseif %f != in {
        ;handle error
      }
      var %f $left(%flags,1)
      var %flags $right(%flags,-1)
    }
  }
  var %sockname
  while (%sockname == $null) || ($sock(%sockname) != $null) {
    var %sockname $+(wikiti.,$rand(1,999999999999))
  }
  sockopen %sockname wikiti.brandonw.net 80
  sockmark %sockname /index.php?title= $+ $1 $iif(%get != $null,1 %get,0 0) $iif(%tinyurl,wikiti.tinyurl.1) $2- 
}
/wikiti.tinyurl.1 {
  var %last $gettok($1-,$numtok($1-,32),32)
  if *wikiti.brandonw.net* !iswm %last {
    $1-
  }
  else {
    tinyurl %last wikiti.tinyurl.2 $1-
  }
}
/wikiti.tinyurl.2 {
  var %errindex $numtok($1-,32)
  if $gettok($1-,%errindex,32) == error {
    tokenize 32 $deltok($1-,%erindex,32)
  } 
  else {
    tokenize 32 $deltok($1-,$calc(%errindex - 1),32)
  }
  $1-
}
