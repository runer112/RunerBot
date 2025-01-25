/runerbot.check {
  return $regex($2,/^runerbot\b/i)
}
/runerbot {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %target $4-5
  var %errortarget $6-7
  var %command $8
  set -ln %query $strip($9-)
  if %query == reload {
    runerbot.reload
    halt
  }
  if $regex(%query,/^(|git\s+)(fetch|pull|checkout\s+[\w/-]+)$/i) {
    run -n cmd /c cd " $+ $scriptdir.." && git $regml(2) || pause
    halt
  }
}
/runerbot.reload {
  load -a $scriptdir $+ jacobly_a.mrc
  load -rs $scriptdir $+ jacobly_rs.mrc
  load -a $scriptdir $+ omni_a.mrc
  load -rs $scriptdir $+ omni_rs.mrc
  load -a $scriptdir $+ paste_a.mrc
  load -a $scriptdir $+ pastebin_a.mrc
  load -rs $scriptdir $+ pastebin_rs.mrc
  load -a $scriptdir $+ rafb_a.mrc
  load -rs $scriptdir $+ rafb_rs.mrc
  load -a $scriptdir $+ shortenurl_a.mrc
  load -a $scriptdir $+ tinyurl_a.mrc
  load -rs $scriptdir $+ tinyurl_rs.mrc
  load -a $scriptdir $+ wikiti_a.mrc
  load -rs $scriptdir $+ wikiti_rs.mrc
  load -a $scriptdir $+ runerbot_a.mrc
}
