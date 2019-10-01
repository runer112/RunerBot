on *:input:*: {
  set %omni.input omni.check $mnick $chan 0 $1-
  .timer 1 0 %omni.input | unset %omni.input
  if $regex($strip($1),/^\/\/?(quit|disconnect|exit)$/) {
    set -eu1 %dontreconnect 1
  }
}
on *:text:*:*: {
  if $regex($strip($1-),/<([^>]+)> (.+)/) {
    var %nick $replace($regml(1),$chr(32),$chr(160))
    var %msg $regml(2)
    omni.check %nick $chan 1 %msg
  }
  else if $regex($strip($1-),/\[([^\]]+)\] (.+)/) {
    var %nick $replace($regml(1),$chr(32),$chr(160))
    var %msg $regml(2)
    omni.check %nick $chan 1 %msg
  }
  else {
    omni.check $nick $chan 0 $1-
  }
}
on *:sockopen:omni.test: {
  echo -s sockopen $sockname $+ 
  sockwrite -nt $sockname $+(GET /index.php?wap;action=unread HTTP/1.1,$crlf,Host: omnimaga.org,$crlf,$crlf)
}
on *:sockread:omni.test: {
  var %x
  sockread %x
  echo -s sockread $sockname $+  %x
}
on *:connect: {
  if ($me == $anick) {
    nick $mnick
    timeromni.nick 0 60 omni.nick
  }
  join #omnimaga
  join #omnimaga-spam
  join #omnimaga-ops
  join #fishtankcity
  join #cemetech
  join #tiplanet
  join #cemu-dev
  join #ez80-dev
  join #ti
  join #tiboy-testing
  join #tipython-dev
}
on *:disconnect: {
  if !%dontreconnect {
    server irc.efnet.org
  }
}
on *:quit: {
  if ($nick == $mnick) && ($me == $anick) {
    nick $mnick
  }
  if $regex($1-,/^[^.]+\.[^.]+\.[^.]+ [^.]+\.[^.]+\.[^.]+$/) || $regex($1-,/^Ping timeout:/) {
    if %efnet.netsplit.threshold == $null {
      var %nicklist
      var %chan 1
      while %chan <= $chan(0) {
        var %c $chan(%chan)
        var %nick 1
        while %nick <= $nick(%c,0) {
          var %n $nick(%c,%nick)
          if !$istok(%nicklist,%n,32) {
            set %nicklist %nicklist %n
          }
          inc %nick
        }
        inc %chan
      }
      set -eu60 %efnet.netsplit.threshold $calc($numtok(%nicklist,32) / 2)
    }
    set -eu60 %efnet.netsplit.counter $calc(%efnet.netsplit.counter + 1)
    if %efnet.netsplit.counter >= %efnet.netsplit.threshold {
      unset %efnet.netsplit*
      server irc.efnet.org
    }
  }
}
