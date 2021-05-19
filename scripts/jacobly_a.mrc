/jacobly.paste {
  ;;;; REQUIRED PARAMETERS ;;;;
  ;     Developer API Key
  ;     File to upload (in quotation marks)
  ;     Operation to call with result
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;echo -s jacobly.paste $1-

  tokenize 32 $1-
  if $2 == $null {
    echo 2 * /jacobly.paste: insufficient parameters
    halt
  }

  if $regex($1,/[^0-9A-Fa-f]/) {
    echo 2 * /jacobly.paste: invalid dev key $1
    halt
  }
  var %devkey $1
  msg jacobot %devkey
  tokenize 32 $2-

  if !$regex(jacobly.paste,$1-,/^("[^"]+")/) {
    echo 2 * /jacobly.paste: malformed file path
    halt
  }
  if !$exists($regml(jacobly.paste,1)) {
    echo 2 * /jacobly.paste: no such file $regml(jacobly.paste,1)
    halt
  }
  if $gettok($gettok($1-,2-,$asc(")),1-,32) == $null {
    echo 2 * /jacobly.paste: insufficient parameters
    halt
  }

  var %sockname
  while (%sockname == $null) || ($sock(%sockname) != $null) {
    var %sockname $+(jacobly.paste.,$rand(1,999999999999))
  }
  sockopen %sockname jacobly.com 10001
  sockmark %sockname $1-
}

/jacobly.paste.return {
  ;echo -s jacobly.paste.return $1-
  .timer $+ $1 off
  $sock($1).mark $2-
  sockclose $1
}
