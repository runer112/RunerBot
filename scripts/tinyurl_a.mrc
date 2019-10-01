/tinyurl {
  var %sockname
  while (%sockname == $null) || ($sock(%sockname) != $null) {
    var %sockname $+(tinyurl.,$rand(1,999999999999))
  }
  sockopen %sockname is.gd 80
  sockmark %sockname $1-
  .timer $+ %sockname 1 3 tinyurl.return %sockname error $1
}
/tinyurl.return {
  .timer $+ $1 off
  var %action $gettok($sock($1).mark,2-,32)
  sockclose $1
  ;echo -s action: %action
  %action $2-
}
