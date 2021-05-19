/omni.dir {
  return $qt($gettok(%omni.dir $+ \ $+ $replace($1-,$chr(32),\),1-,$asc(\)) $+ \)
}
/omni.enabled {
  return %omni.enabled
}
/omni.pastebin.devkey {
  return %omni.pastebin.devkey
}
/omni.nocolor {
  return
}
/omni.noformat {
  return #cemetech #omnimaga2 echo
}
/omni.nodesc {
  return
}
/omni.nolimit {
  return #omnimaga-spam
}

/omni.file {
  return $qt($noqt($omni.dir($2-)) $+ $1)
}
/omni.z80.includes {
  if $1 == 8384 {
    return ti83plus.inc dcs7.inc axe.inc
  }
  if $1 == 84pcse {
    return ti84pcse.inc
  }
  if $1 == 8384pce {
    return ti84pce.inc
  }
}
/omni.msg {
  if $istok($omni.nocolor,$gettok($1-,1,32),32) {
    msg $strip($remove($1-,),c)
  }
  elseif $istok($omni.noformat,$gettok($1-,1,32),32) {
    msg $strip($1-)
  }
  else {
    msg $1-
  }
}
/omni.nick {
  if ($me == $anick) {
    nick $mnick
    .timeromni.nick 0 60 omni.nick
  }
  else if ($me == $mnick) {
    .timeromni.nick off
  }
}
/omni.class {
  return 14[7 $+ $1 $+ 14]
}
/omni.divider {
  return 14|01
}
/omni.asmdivider {
  return 14\01
}
/omni.user.version {
  return 2
}
/omni.user.formatfile {
  return $omni.file($omni.user.version $+ .txt,user,format)
}
/omni.user.default {
  return $gettok($read($omni.user.formatfile,ntw,$1- $+ *),2,9)
}
/omni.user.line {
  noop $read($omni.user.formatfile,ntw,$1- $+ *)
  return $readn
}
/omni.user.get {
  return $read($1,nt,$omni.user.line($2))
}
/omni.user.set {
  write -l $+ $omni.user.line($2) $1 $3-
}
/omni.user.tofile {
  return $omni.file($replace($1-,*,^,:,.) $+ .txt,user)
}
/omni.user.filecheck {
  if !$exists($1-) {
    var %formatfile $omni.user.formatfile
    var %i 1
    while %i <= $lines(%formatfile) {
      write $1- $gettok($read(%formatfile,nt,%i),2,9) $+ $crlf
      inc %i
    }
    return
  }
  var %v $omni.user.get($1-,Version)
  if %v <= 1 {
    omni.user.set $1- Version 2
    var %x $omni.user.default(Default)
    write -il $+ $readn $1- %x
  }
}
/omni.request {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %msg $4
  var %auto $5
  if %auto {
    return ok
  }
  var %user $iif(%omnomirc,%nick,$address(%nick,2))
  var %file $omni.user.tofile(%user)
  omni.user.filecheck %file
  if (%nick != $me) && ($read(%file,nt,$omni.user.line(Unrestricted)) != 1) && !$istok($omni.nolimit,%chan,32) && (# isin %chan) {
    var %rfile $omni.file(restrictions.txt)
    var %line $omni.user.line(History)
    var %i 0
    var %duration 0
    var %maxduration $gettok($read(%rfile,nt,$lines(%rfile)),2,9)
    while (%line <= $lines(%file)) && (%duration < %maxduration) {
      var %r $read(%file,nt,%line)
      if # isin $gettok(%r,2,9) {
        inc %i
        var %duration $calc($ctime - $gettok(%r,1,9))
        var %rline 1
        while %rline <= $lines(%rfile) {
          var %rr $read(%rfile,nt,%rline)
          var %wait $calc($gettok(%rr,2,9) - %duration)
          if (%i >= $gettok(%rr,1,9)) && (%wait > 0) {
            return %wait
          }
          inc %rline
        }
      }
      inc %line
    }
    write -il $+ $omni.user.line(History) %file $+($omni.tabpad($ctime,2),$omni.tabpad(%chan,2),%msg)
  }
  return ok
}
/omni.tabpad {
  var %tabs $calc($2 - $floor($calc($len($1) / 8)))
  return $1 $+ $str($chr(9),$iif(%tabs > 0,%tabs,1))
}
/omni.check {
  if !%omni.enabled {
    halt
  }
  var %nick $1
  var %chan $2
  if # !isin %chan {
    var %chan %nick
    tokenize 32 $1 %nick $2-
  }
  var %omnomirc $3
  var %msg $strip($4-)
  var %user $iif(%omnomirc,%nick,$address(%nick,2))
  var %file $omni.user.tofile(%user)
  var %auto 0
  while 1 {
    if $istok(. ! @,$left(%msg,1),32) {
      if %omnomirc == 1 {
        var %target omni.msg %chan
        var %errortarget omni.msg %chan
        var %requesttarget noop
      }
      else {
        var %requesttarget notice %nick
        if (%nick == %chan) || $istok(! @,$left(%msg,1),32) {
          var %target omni.msg %chan
          var %errortarget omni.msg %chan
        }
        elseif %nick == $me {
          var %target echo -a
          var %errortarget echo -a
          var %requesttarget echo -a
        }
        else {
          var %target notice %nick
          var %errortarget notice %nick
        }
      }
      if %auto {
        var %errortarget noop 0
      }
      var %msg1 $right(%msg,-1)
      var %do
      .fopen cmds $omni.file(cmds.txt)
      while !$ferr {
        tokenize 9 $fread(cmds)
        if $1 == $null {
          break
        }
        var %regex $1
        var %class
        var %title
        var %response
        var %classopt
        if ($1 != $null) && ($2 == $null) {
          var %do %errortarget ERROR: GRAPE
          break
        }
        if $5 != $null {
          var %do %errortarget ERROR: GRAPEFRUIT
          break
        }
        if $4 != $null {
          var %response $4
          var %title $3
          var %class $2
        }
        elseif $3 != $null {
          var %response $3
          var %title $2
        }
        else {
          var %response $2
        }
        if $right(%class,1) == ? {
          var %class $left(%class,-1)
          var %classopt 1
        }
        if $regex(%msg1,$+(/^,$iif(%classopt,$+($chr(40),%class,$chr(32),$chr(41),?)),%regex,$,/i)) {
          var %do %target $iif(%class != $null,$omni.class(%class)) $iif(%title != $null,$+(,%title,:)) %response
          break
        }
      }
      .fclose cmds
      if %do == $null {
        tokenize 32 %nick %chan %omnomirc %target %errortarget %msg1
        if $omni.basic.check(%chan,%msg1) {
          var %do omni.basic $1-
        }
        elseif $omni.z80.check(%chan,%msg1) {
          var %do omni.z80 $1-
        }
        elseif $omni.axe.check(%chan,%msg1) {
          var %do omni.axe $1-
        }
        elseif $omni.sprite.check(%chan,%msg1) {
          var %do omni.sprite $1-
        }
        elseif $omni.color.check(%chan,%msg1) {
          var %do omni.color $1-
        }
        elseif $regex(%msg1,/^port /i) {
          var %do omni.z80 %nick %chan %omnomirc %target %errortarget $left(%msg,1) $+ ? %msg1
        }
        elseif $regex(%msg1,/^(?:set)?default ?(.*)/i) {
          var %do omni.user.set %file Default $regml(1)
        }
      }
    }
    if %do != $null {
      var %request $omni.request(%nick,%chan,%omnomirc,%msg,%auto)
      if %request != ok {
        %requesttarget To prevent spam, you are only allowed to use commands in the channel so often. You may either wait $duration(%request) or /query me at any time.
        halt
      }
      %do
      halt
    }
    if %auto || (%chan != %nick && $len($strip(%msg)) <= 2) {
      halt
    }
    var %msg $omni.user.get(%file,Default) %msg
    var %auto 1
  }
}
/omni.basic.check {
  return $regex($2,/^(ti|ti-)?basic\b/i)
}
/omni.basic.syntax {

}
/omni.basic.help {

}
/omni.basic {

}
/omni.z80.check {
  return $omni.z80.getmodel($gettok($2,1,32))
}
/omni.z80.syntax {

}
/omni.z80.help {

}
/omni.z80 {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %target $4-5
  var %errortarget $6-7
  var %command $8
  var %model $omni.z80.getmodel(%command)
  var %class $iif(%model == 8384pce,eZ80,Z80)
  set -ln %query $strip($9-)
  if %query == $null {
    %errortarget $omni.class(%class) ERROR $omni.divider No query entered.
    halt
  }
  if $gettok(%query,1,32) == port {
    if $regex(%query,/^port +\$?([0-9A-F]{1,6})h? *$/i) {
      var %ez80 $iif(%class == ez80 || (!%model && $len($regml(1)) > 2),1,0)
      var %port $left($iif(%ez80,0000,00),- $+ $len($regml(1))) $+ $upper($regml(1))
      var %searchport %port
      if %ez80 {
        var %decport $base(%port,16,10)
        var %offset
        if %decport >= $base(E00000,16,10) && %decport < $base(E40000,16,10) {
          var %offset DF0000
        }
        else if %decport >= $base(F00000,16,10) && %decport < $base(FB0000,16,10) {
          var %offset EB0000
        }
        if %offset {
          var %decport $calc(%decport - $base(%offset,16,10))
          var %searchport $base(%decport,10,16,5)
          var %searchport $left(%searchport,1) $+ $right(%searchport,3)
        }
        if %searchport > 2000 {
          var %searchport $left(%searchport,-3) $+ 000
        }
      }
      wikiti -gt /<b>Function:<\/b> $+ $chr(160) $+ (.+)/ $iif(%ez80,84PCE,83Plus) $+ :Ports: $+ %searchport omni.z80.port $1-8 %port
      halt
    }
    else {
      %errortarget $omni.class(%class) ERROR $omni.divider Invalid port number.
      halt
    }
  }
  if $regex(%query,/^\s*dec\s+(b|c|d|e|h|l|\(hl\)|a|bc|de|hl|sp|i[xy]h|i[xy]l|i[xy]|\(i[xy].*\))( |$)/i) {
    goto assembly
  }
  if $regex(%query,/^(what is|what's|calc|calculate|calculator|b|bin|binary|o|oct|octal|d|dec|decimal|h|hex|hexadecimal|chr|char)( |$)(.*)/i) {  
    var %forcecalc 1
    goto calc
  }
  if $regex(%query,/^(\.assume +adl *= *[01] +(\\ +)?|adl +|z80 +)?[ 0-9a-f]*[0-9abcdef]$/i) {
    goto disassembly
  }
  if \ isin %query {
    goto assembly
  }
  :calc
  if $regex(%query,/^(what is|what's|calc|calculate|calculator)( |$)(.*(?<!\?))/i) {
    set -ln %query $regml(3)
    var %forcecalc 1
  }
  if $regex(%query,/^(b|bin|binary)( |$)(.*)/i) {
    set -ln %query $regml(3)
    var %base 2
    var %forcecalc 1
  }
  elseif $regex(%query,/^(o|oct|octal)( |$)(.*)/i) {
    set -ln %query $regml(3)
    var %base 8
    var %forcecalc 1
  }
  elseif $regex(%query,/^(d|dec|decimal)( |$)(.*)/i) {
    set -ln %query $regml(3)
    var %base 10
    var %forcecalc 1
  }
  elseif $regex(%query,/^(h|hex|hexadecimal)( |$)(.*)/i) {
    set -ln %query $regml(3)
    var %base 16
    var %forcecalc 1
  }
  elseif $regex(%query,/^(chr|char)( |$)(.*)/i) {
    set -ln %query $regml(3)
    var %base char
    var %forcecalc 1
  }
  else {
    var %base auto
  }
  if %query == $null {
    %errortarget $omni.class(%class) ERROR $omni.divider No expression entered.
    halt
  }
  var %wordsize $iif(%class == z80,16,24)
  var %calc $omni.z80.a.calc(%query,%model,%base,%wordsize,big format)
  if %calc != $null {
    if ($gettok(%calc,2,32) != $null) {
      var %base $gettok(%calc,2,32)
      if ($gettok(%calc,3,32) == 1) && $regex(%query,/^-?[0-9a-z$%@]/i) {
        var %base $iif(%base == 16,10,16)
        var %calc $omni.z80.a.calc($gettok(%calc,1,32),%model,%base,%wordsize,big format)
      }
      var %calc $gettok(%calc,1,32)
    }
    %target $omni.class(%class) Calculator $omni.divider %query == $omni.z80.color.imm $+ $iif($left(%calc,3) == $ $+ 00,$ $+ $right(%calc,-3),$iif($left(%calc,9) == % $+ 00000000,% $+ $right(%calc,-9),%calc))
    halt
  }
  if %forcecalc {
    %errortarget $omni.class(%class) ERROR $omni.divider Could not compute: %query
    halt
  }
  :assembly
  var %assembly $omni.z80.a(%query,%model,%class)
  if error* iswm %assembly {
    if $istok(lego legos,%query,32) {
      %errortarget $omni.class(%class) Assembly $omni.divider http://tinyurl.com/4zq9pjb
      halt
    }
    %errortarget $omni.class(%class) ERROR $omni.divider Could not assemble: $gettok(%assembly,2-,32)
    halt
  }
  var %file $omni.file(assemblyhex.txt,%class)
  if ($lines(%file) == 1) && (.d !isin %query) {
    var %query %assembly
    goto disassembly
  }
  paste %file omni.z80.a.pastebin $1-8
  halt
  :disassembly
  if $findtok(%query,add,32) || $findtok(%query,ccf,32) || $findtok(%query,daa,32) {
    goto assembly
  }
  var %adl $iif(%class == eZ80,1,0)
  var %dishex %query
  if $regex(%dishex,/^(?:\.assume +adl *= *([01]) +(?:\\ +)?)(.+)/i) {
    var %adl $regml(1)
    var %dishex $regml(2)
  }
  elseif $gettok(%dishex,1,32) == adl {
    var %adl 1
    var %dishex $gettok(%dishex,2-,32)
  }
  elseif $gettok(%dishex,1,32) == z80 {
    var %adl 0
    var %dishex $gettok(%dishex,2-,32)
  }
  var %dishex $remove($upper(%dishex),$chr(32))
  var %disassembly $omni.z80.d(%dishex,%model,%class,%adl,1)
  if error parity == %disassembly {
    if $regex(%dishex,/^[0-9]+$/) {
      goto calc
    }
    %errortarget $omni.class(%class) ERROR $omni.divider Odd number of hexadecimal characters entered.
    halt
  }
  if error invalid != %disassembly {
    ; echo -s . %disassembly
    var %file $omni.file(disassembly.txt,%class)
    if (error length != %disassembly) && ($lines(%file) == 1) && !$regex($read(%file,nt,1),/^\s*\./) {
      var %action
      if $left(%dishex,2) == EF {
        var %action wikiti -t $+($iif(%model == 8384pce,84PCE:Syscalls,$iif(%model == 8384,83Plus,84PCSE) $+ :BCALLs),:,$mid(%dishex,5,2),$mid(%dishex,3,2)))
      }
      %action omni.z80.instr $1-8 %adl %dishex $replace(%disassembly,$chr(32),$chr(160))
      halt
    }
    var %disassembly $omni.z80.d(%dishex,%model,%class,%adl)
    paste %file omni.z80.d.pastebin $1-8 %adl %dishex $replace(%disassembly,$chr(32),$chr(160))
    halt
  }
}
/omni.z80.getmodel {
  if $regex($1,/^(z80|8[34][+p](se)?)$/i) {
    return 8384
  }
  if $regex($1,/^(84[+p]cse|cse)$/i) {
    return 84pcse
  }
  if $regex($1,/^(ez80|8[34][+p]ce|ce)$/i) {
    return 8384pce
  }
}
/omni.z80.textparse {
  unset %omni.z80.d.*
  set %omni.z80.d.model $2
  set %omni.z80.d.class $3
  set %omni.z80.d.ez80 $iif($3 == eZ80,1,0)
  set %omni.z80.d.adl %omni.z80.d.ez80
  set %omni.z80.d.general 1
  var %dishex $4
  if $findtok(40 49 52 5B,$left(%dishex,2),32) {
    set %omni.z80.d.suffix $left(%dishex,2)
    var %dishex $right(%dishex,-2)
  }
  if $left(%dishex,2) == DD {
    set %omni.z80.d.index ix
  }
  elseif $left(%dishex,2) == FD {
    set %omni.z80.d.index iy
  }
  var %a $omni.z80.mparse($1)
  unset %omni.z80.d.*
  return %a
}
/omni.z80.port {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %target $4-5
  var %errortarget $6-7
  var %command $8
  var %port $9
  var %model $omni.z80.getmodel(%command)
  var %class $iif(%model == 8384pce || (!%model && $len(%port) > 2),eZ80,Z80)
  var %function $iif($numtok($1-,32) != 10,$gettok($1-,10- $+ $calc($numtok($1-,32) - 1),32))
  var %page $iif($numtok($1-,32) >= 10,$gettok($1-,$numtok($1-,32),32))
  if %page == $null {
    %errortarget $omni.class(%class) ERROR $omni.divider Port %port could not be found on WikiTI.
    halt
  }
  %target $omni.class(%class) Port $omni.z80.color.bold(%port) $+ $iif(%function != $null,: %function) $omni.divider Info: %page
}
/omni.z80.instr {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %target $4-5
  var %errortarget $6-7
  var %command $8
  var %model $omni.z80.getmodel(%command)
  var %class $iif(%model == 8384pce,eZ80,Z80)
  var %ez80 $iif(%class == eZ80,1,0)
  var %adl $9
  var %dishex $10
  var %disassembly $replace($11,$chr(160),$chr(32))
  var %disstripped $strip(%disassembly)
  var %wikiti $12
  ; echo -s . $1-
  var %disassembly2 $omni.z80.d(%dishex,%model,%class,%adl)
  ; var %r $read($omni.file(ops.txt,%class),ntw,* $+ $chr(9) $+ %disstripped $+ $chr(9) $+ *)
  var %suffix
  var %suffixnum $findtok(40 49 52 5B,$left(%dishex,2),32)
  var %suffixbits 11
  var %r $omni.z80.instr.lookup(%dishex,%class)
  ; echo -s . %r
  if %ez80 && ((%r == $null) || (%suffixnum && ($gettok(%r,1,9) == 01......))) {
    if %suffixnum {
      var %suffix $left(%dishex,2)
      dec %suffixnum
      var %suffixbits $base(%suffixnum,10,2,2)
      var %r $omni.z80.instr.lookup($right(%dishex,-2),%class)
    }
  }
  if %r == $null {
    %errortarget $omni.class(%class) ERROR $omni.divider This error should not have happened. Make sure the human who maintains me knows about this! ERROR CODE: BANANA
    halt
  }
  if 0 {
    var %bytes $gettok(%r,3,9)
    var %cycles $gettok(%r,4,9)
    if %ez80 {
      var %ccycles $gettok(%r,5,9)
      var %documented *
      var %s $iif(%suffix == 40 || %suffix == 52,1,0)
      var %is $iif(%suffix == 40 || %suffix == 49,1,0)
      var %xcycles 0
      if %suffix != $null {
        inc %bytes
        inc %xcycles
      }
      if %s {
        if $regex(%disstripped,/^p(ush|op|ea) /i) {
          dec %xcycles
        }
        elseif ex (sp)* iswm %disstripped {
          dec %xcycles 2
        }
        elseif $regex(%disstripped,/^ld (reg24|ix|iy) $+ $chr(44) $+ \ $+ $chr(40) $+ (hl|ix\+ofs8|iy\+ofs8)/i) {
          dec %xcycles 1
        }
        elseif $regex(%disstripped,/^ld \ $+ $chr(40) $+ (hl|ix\+ofs8|iy\+ofs8).*\ $+ $chr(41) $+ $chr(44) $+ (reg24|ix|iy)/i) {
          dec %xcycles 1
        }
      }
      if %is {
        if *(imm24)* iswm %disstripped {
          dec %bytes
          dec %xcycles 2
        }
        elseif *imm24* iswm %disstripped {
          dec %bytes
          dec %xcycles
        }
      }
      if $regex(%cycles,/(.+)\/(.+)/) {
        var %cycles $calc($regml(1) + %xcycles) $+ / $+ $calc($regml(2) + %xcycles)
      }
      else {
        var %cycles $calc(%cycles + %xcycles)
      }
    }
    else {
      var %documented $gettok(%r,5,9)
      var %ccycles *
    }
    if $chr(47) isin %cycles && reg8 isin %disstripped {
      if $numtok(%cycles,47) == 2 {
        var %cycles $gettok(%cycles,$iif($chr(40) $+ hl $+ $chr(41) isin %disassembly2,2,1),47)
      }
      if $numtok(%ccycles,47) == 2 {
        var %ccycles $gettok(%ccycles,$iif($chr(40) $+ hl $+ $chr(41) isin %disassembly2,2,1),47)
      }
    }
    var %flags $gettok(%r,6,9)
    var %description $gettok(%r,7,9)
    %target $omni.class(%class) Instruction $iif(%disassembly != %disassembly2,$omni.divider Class: $omni.z80.color.bold(%disassembly)) $iif($left($strip(%disassembly2),1) != .,$omni.divider Instance: $omni.z80.color.bold(%disassembly2) $+([,$omni.z80.color.def,%dishex,$omni.z80.color.punct,])) $iif(%bytes != *,$omni.divider Bytes: $omni.z80.color.bold(%bytes)) $iif((%cycles != *) || (%ccycles != *),$omni.divider Cycles: $omni.z80.color.bold(%cycles $+ $iif(%ez80 && (%ccycles != 0),$chr(32) $+ MEM $+ $chr(44) %ccycles CPU))) $iif(%flags != *,$omni.divider Flags: $omni.z80.color.bold(%flags)) $iif(%documented == 0,$omni.divider Undocumented) $iif(!$istok($omni.nodesc,$gettok(%target,2,32),32),$iif(%description != *,$omni.divider Description: $omni.z80.textparse(%description,%model,%class,%dishex))) $iif(%wikiti != $null,$omni.divider More info: %wikiti)
  }
  else {
    var %c 3
    var %bytes $gettok(%r,%c,9)
    inc %c
    var %cycles $gettok(%r,%c,9)
    while $regex(%cycles,/(.*)\((\d+)\+\.(i?)([sl])\)(.*)/) {
      var %cycles $regml(1) $+ $calc($regml(2) + $xor($mid(%suffixbits,$iif($regml(3) == i,1,2),1),$iif($regml(4) == s,1,0))) $+ $regml(5)
    }
    if %suffix {
      ; echo . %suffixbits . %disstripped
      ; echo . $not($iif(!$left(%suffixbits,1) && (*imm24* iswm %disstripped),1,0)) . $iif(*imm24* iswm %disstripped,1,0)
      if $left(%suffixbits,1) || (*imm24* !iswm %disstripped) {
        inc %bytes
      }
      noop $regex(%cycles,/(.*)(\d+)(F\b.*)/)
      var %cycles $regml(1) $+ $calc($regml(2) + 1) $+ $regml(3)
    }
    inc %c
    if %ez80 {
      var %documented *
    }
    else {
      var %documented $gettok(%r,%c,9)
      inc %c
    }
    var %flags $gettok(%r,%c,9)
    inc %c
    var %description $gettok(%r,%c,9)
    inc %c
    %target $omni.class(%class) Instruction $iif(%disassembly != %disassembly2,$omni.divider Class: $omni.z80.color.bold(%disassembly)) $iif($left($strip(%disassembly2),1) != .,$omni.divider Instance: $omni.z80.color.bold(%disassembly2) $+([,$omni.z80.color.def,%dishex,$omni.z80.color.punct,])) $iif(%bytes != *,$omni.divider Bytes: $omni.z80.color.bold(%bytes)) $iif(%cycles != *,$omni.divider Cycles: $omni.z80.color.bold(%cycles)) $iif(%flags != *,$omni.divider Flags: $omni.z80.color.bold(%flags)) $iif(%documented == 0,$omni.divider Undocumented) $iif(!$istok($omni.nodesc,$gettok(%target,2,32),32),$iif(%description != *,$omni.divider Description: $omni.z80.textparse(%description,%model,%class,%dishex))) $iif(%wikiti != $null,$omni.divider More info: %wikiti)
  }
}
/omni.z80.instr.lookup {
  var %dishex $1
  var %class $2
  var %disbin $base(%dishex,16,2,$calc($len(%dishex) * 4))
  .fopen omni.z80.ops $omni.file(ops.txt,%class)
  while !$feof {
    var %r $fread(omni.z80.ops)
    if ($gettok(%r,1,9) != $null) && $regex(%disbin $+ 00000000000000000000000000000000,/^ $+ $gettok(%r,1,9) $+ .*/) {
      break
    }
    var %r
  }
  .fclose omni.z80.ops
  return %r
}
/omni.z80.pastelink {
  var %link $1
  return $iif(error* !iswm %link,%link,$omni.z80.color.error $+ Paste error)
}
/omni.z80.d.pastebin {
  shortenurl $12 omni.z80.d.shortenurl $1-11
}
/omni.z80.d.shortenurl {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %target $4-5
  var %errortarget $6-7
  var %command $8
  var %model $omni.z80.getmodel(%command)
  var %class $iif(%model == 8384pce,eZ80,Z80)
  var %adl $9
  var %dishex $10
  var %disassembly $11
  var %pastebin $12
  %target $omni.class(%class) Disassembly $omni.divider $omni.z80.pastelink(%pastebin) $omni.divider $omni.z80.color.bold($calc($len(%dishex) / 2) bytes) $iif($lines($omni.file(disassembly.txt,%class)) <= 10,$omni.divider $replace(%disassembly,$chr(160),$chr(32)))
}
/omni.z80.a.pastebin {
  shortenurl $9 omni.z80.a.shortenurl $1-8
}
/omni.z80.a.shortenurl {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %target $4-5
  var %errortarget $6-7
  var %command $8
  var %model $omni.z80.getmodel(%command)
  var %class $iif(%model == 8384pce,eZ80,Z80)
  var %pastebin $9
  var %file $omni.file(assemblyhex.txt,%class)
  var %assembly
  var %bold 1
  var %i 1
  while %i <= $lines(%file) {
    if %bold {
      var %assembly %assembly $+  $+ $read(%file,nt,%i) $+ 
      var %bold 0
    }
    else {
      var %assembly %assembly $+ $read(%file,nt,%i)
      var %bold 1
    }
    inc %i
  }
  %target $omni.class(%class) Assembly $omni.divider $omni.z80.pastelink(%pastebin) $omni.divider $omni.z80.color.bold($calc($len($strip(%assembly)) / 2) bytes) $iif($len(%assembly) <= 50,$omni.divider $omni.z80.color.def $+ %assembly)
}
/omni.z80.d {
  tokenize 32 $remove($1,$chr(32)) $2-
  var %error $omni.hexvalidate($1)
  if %error != $null {
    return %error
  }
  unset %omni.z80.d.*
  var %model $2
  set %omni.z80.d.model $2
  var %class $3
  var %ez80 $iif(%class == ez80,1,0)
  set %omni.z80.d.class %class
  set %omni.z80.d.ez80 %ez80
  set %omni.z80.d.adl $iif($4 != null,$4,0)
  if $5 {
    set %omni.z80.d.general 1
    set %omni.z80.d.generalsuffix 1
  }
  .fclose omni.z80.d.*
  .fopen -o omni.z80.d.file $omni.file(disassembly.txt,%class)
  .fopen -o omni.z80.d.hexfile $omni.file(disassemblyhex.txt,%class)
  set %omni.z80.d.true 1
  set %omni.z80.d.ops 0
  set %omni.z80.d.input $upper($1)
  set %omni.z80.d.pos 1
  while (%omni.z80.d.pos <= $len(%omni.z80.d.input)) && (%error == $null) {
    if %omni.z80.d.general && (%omni.z80.d.ops > 0) {
      unset %omni.z80.d.* %x %y %z %p %q
      .fclose omni.z80.d.*
      return error length
    }
    omni.z80.d.bytefeed
    var %m
    set %x $base($left(%omni.z80.d.bin,2),2,10)
    set %y $base($mid(%omni.z80.d.bin,3,3),2,10)
    set %z $base($right(%omni.z80.d.bin,3),2,10)
    set %p $base($mid(%omni.z80.d.bin,3,2),2,10)
    set %q $base($mid(%omni.z80.d.bin,5,1),2,10)
    if %omni.z80.d.prefix == $null {
      if %x == 0 {
        if %z == 0 {
          if %y == 0 {
            var %m nop
          }
          elseif %y == 1 {
            var %m ex .reg16af[3;1],.reg16af[3;1]'
          }
          elseif %y == 2 {
            var %m djnz .ofs8pc[]
          }
          elseif %y == 3 {
            var %m jr .ofs8pc[]
          }
          else {
            var %m jr .cc[$calc(%y - 4)],.ofs8pc[]
          }
        }
        elseif %z == 1 {
          if %q == 0 {
            var %m ld .reg16[%p],.imm16[]
          }
          else {
            var %m add .reg16[2;1],.reg16[%p]
          }
        }
        elseif %z == 2 {
          if %q == 0 {
            if (%p == 0) || (%p == 1) {
              var %m ld .punct[](.reg16[%p;1]),.reg8[7;1]
            }
            elseif %p == 2 {
              var %m ld .punct[](.imm16[]),.reg16[2;1]
            }
            else {
              var %m ld .punct[](.imm16[]),.reg8[7;1]
            }
          }
          else {
            if (%p == 0) || (%p == 1) {
              var %m ld .reg8[7;1],(.reg16[%p;1])
            }
            elseif %p == 2 {
              var %m ld .reg16[2;1],(.imm16[])
            }
            else {
              var %m ld .reg8[7;1],(.imm16[])
            }
          }
        }
        elseif %z == 3 {
          if %q == 0 {
            var %m inc .reg16[%p]
          }
          else {
            var %m dec .reg16[%p]
          }
        }
        elseif %z == 4 {
          var %m inc .reg8[%y]
        }
        elseif %z == 5 {
          var %m dec .reg8[%y]
        }
        elseif %z == 6 {
          var %m ld .reg8[%y],.imm8[]
        }
        else {
          if %y == 0 {
            var %m rlca
          }
          elseif %y == 1 {
            var %m rrca
          }
          elseif %y == 2 {
            var %m rla
          }
          elseif %y == 3 {
            var %m rra
          }
          elseif %y == 4 {
            var %m daa
          }
          elseif %y == 5 {
            var %m cpl
          }
          elseif %y == 6 {
            var %m scf
          }
          else {
            var %m ccf
          }
        }
      }
      elseif %x == 1 {
        var %m ld .reg8[%y],.reg8[%z]
        if %z == %y {
          if %z == 6 {
            var %m halt
          }
          elseif %ez80 && %z < 4 {
            set %omni.z80.d.suffix %omni.z80.d.byte
            var %m
          }
        }
      }
      elseif %x == 2 {
        var %m .alu[%y].reg8[%z]
      }
      else {
        if %z == 0 {
          var %m ret .cc[%y]
        }
        elseif %z == 1 {
          if %q == 0 {
            var %m pop .reg16af[%p]
          }
          else {
            if %p == 0 {
              var %m ret
            }
            elseif %p == 1 {
              var %m exx
            }
            elseif %p == 2 {
              var %m jp .punct[](.reg16[2;1])
            }
            else {
              var %m ld .reg16[3;1],.reg16[2;1]
            }
          }
        }
        elseif %z == 2 {
          var %m jp .cc[%y],.imm16[]
        }
        elseif %z == 3 {
          if %y == 0 {
            var %m jp .imm16[]
          }
          elseif %y == 1 {
            set %omni.z80.d.prefix %omni.z80.d.prefix $+ %omni.z80.d.byte
          }
          elseif %y == 2 {
            var %m out .punct[](.imm8[]),.reg8[7;1]
          }
          elseif %y == 3 {
            var %m in .reg8[7;1],(.imm8[])
          }
          elseif %y == 4 {
            var %m ex .punct[](.reg16[3;1]),.reg16[2;1]
          }
          elseif %y == 5 {
            var %m ex .reg16[1;1],.reg16[2;1]
          }
          elseif %y == 6 {
            var %m di
          }
          else {
            var %m ei
          }
        }
        elseif %z == 4 {
          var %m call .cc[%y],.imm16[]
        }
        elseif %z == 5 {
          if %q == 0 {
            var %m push .reg16af[%p]
          }
          else {
            if %p == 0 {
              var %m call .imm16[]
            }
            else {
              set %omni.z80.d.prefix %omni.z80.d.prefix $+ %omni.z80.d.byte
              set %omni.z80.d.index $iif(%omni.z80.d.byte == DD,ix,iy)
            }
          }
        }
        elseif %z == 6 {
          if (%y < 4) || (%y == 7) {
            var %m .alu[%y].imm8[]
          }
          else {
            var %m .alu[%y].imm8[b]
          }
        }
        else {
          if !%ez80 && %y == 5 {
            var %m B_CALL.punct[](.bcall[])
          }
          else {
            var %m rst .dec2h[$calc(%y * 8)]
          }
        }
      }
    }
    elseif %omni.z80.d.prefix == CB {
      if %x == 0 {
        if %ez80 && %y == 6 {
          var %m trap
        }
        else {
          var %m .rot[%y].reg8[%z]
        }
      }
      elseif %x == 1 {
        var %m bit .imm3[%y],.reg8[%z]
      }
      elseif %x == 2 {
        var %m res .imm3[%y],.reg8[%z]
      }
      else {
        var %m set .imm3[%y],.reg8[%z]
      }
    }
    elseif %omni.z80.d.prefix == ED {
      if %ez80 && %x == 0 {
        if %z == 0 {
          if %y != 6 {
            var %m in0 .reg8[%y],(.imm8[])
          }
          else {
            var %m in0 .punct[](.imm8[])
          }
        }
        elseif %z == 1 {
          if %y != 6 {
            var %m out0 .punct[](.imm8[]),.reg8[%y]
          }
          else {
            var %m ld .regi[1],(.reg16[2;1])
          }
        }
        elseif %z == 2 || %z == 3 {
          if %q == 0 {
            var %regi $iif(%z == 3,1,0)
            var %m lea $iif(%p != 3,.reg16[%p],.regi[ $+ %regi $+ ]) $+ ,.regiofs8[ $+ %regi $+ ]
          }
        }
        elseif %z == 4 {
          var %m tst a,.reg8[%y]
        }
        elseif %z == 6 {
          if %y == 7 {
            var %m ld .punct[](.reg16[2;1]),.regi[1]
          }
        }
        elseif %z == 7 {
          var %reg16 $iif(%p != 3,.reg16[%p],.regi[0])
          if %q == 0 {
            var %m ld %reg16 $+ ,(.reg16[2;1])
          }
          else {
            var %m ld .punct[](.reg16[2;1]), $+ %reg16
          }
        }
      }
      elseif %x == 1 {
        var %regport $iif(%ez80,.reg16[0;1],.reg8[1;1])
        if %z == 0 {
          if %y == 6 {
            var %m in .punct[]( $+ %regport $+ )
          }
          else {
            var %m in .reg8[%y],( $+ %regport $+ )
          }
        }
        elseif %z == 1 {
          if %y == 6 {
            if !%ez80 {
              var %m out .punct[]( $+ %regport $+ ),.zero[]
            }
          }
          else {
            var %m out .punct[]( $+ %regport $+ ),.reg8[%y]
          }
        }
        elseif %z == 2 {
          if %q == 0 {
            var %m sbc .reg16[2;1],.reg16[%p]
          }
          else {
            var %m adc .reg16[2;1],.reg16[%p]
          }
        }
        elseif %z == 3 {
          if %q == 0 {
            var %m ld .punct[](.imm16[]),.reg16[%p]
          }
          else {
            var %m ld .reg16[%p],(.imm16[])
          }
        }
        elseif %z == 4 {
          if %ez80 {
            if %q == 0 {
              if %p == 0 {
                var %m neg
              }
              elseif %p == 1 {
                var %m lea .regi[0],.regiofs8[1]
              }
              elseif %p == 2 {
                var %m tst .reg8[7;1],.imm8[]
              }
              else {
                var %m tstio .imm8[]
              }
            }
            else {
              var %m mlt .reg16[%p]
            }
          }
          else {
            var %m neg
          }
        }
        elseif %z == 5 {
          if %ez80 {
            if %y == 0 {
              var %m retn
            }
            elseif %y == 1 {
              var %m reti
            }
            elseif %y == 2 {
              var %m lea .regi[1],.regiofs8[0]
            }
            elseif %y == 4 {
              var %m pea .regiofs8[0]
            }
            elseif %y == 5 {
              var %m ld .regmb[],.reg8[7;1]
            }
            elseif %y == 7 {
              var %m stmix
            }
          }
          else {
            if %y == 1 {
              var %m reti
            }
            else {
              var %m retn
            }
          }
        }
        elseif %z == 6 {
          if %ez80 {
            if %y < 4 {
              if %y != 1 {
                var %m im .im[%y]
              }
            }
            elseif %y == 4 {
              var %m pea .regiofs8[1]
            }
            elseif %y == 5 {
              var %m ld .reg8[7;1],.regmb[]
            }
            elseif %y == 6 {
              var %m slp
            }
            elseif %y == 7 {
              var %m rsmix
            }
          }
          else {
            var %m im .im[%y]
          }
        }
        else {
          if %p == 0 {
            var %m ld .reg8ir[%q;1],.reg8[7;1]
          }
          elseif %p == 1 {
            var %m ld .reg8[7;1],.reg8ir[%q;1]
          }
          elseif %y == 4 {
            var %m rrd
          }
          elseif %y == 5 {
            var %m rld
          }
        }
      }
      else {
        if %ez80 && %omni.z80.d.byte == C7 {
          var %m ld .reg8ir[0;1],.reg16[2;1]
        }
        elseif %ez80 && %omni.z80.d.byte == D7 {
          var %m ld .reg16[2;1],.reg8ir[0;1]
        }
        else {
          var %p2 $calc((%x % 2) * 4 + %p)
          var %z2 %z
          var %beforer
          var %afterr
          if %ez80 {
            if %z2 == 2 || %z2 == 3 {
              if %p2 < 2 {
                inc %p2 2
                var %beforer m
              }
              elseif %p2 == 4 {
                var %p2 3
                var %afterr x
              }
            }
            elseif %z2 == 4 && %p2 < 4 {
              var %z2 $calc(%p2 / 2 + 2)
              var %p2 $calc(%p2 % 2 + 2)
              var %beforer 2
            }
          }
          if (%p2 == 2 || %p2 == 3) && %z2 < 4 {
            var %m $+($gettok(ld cp in $iif(%p2 == 2,out,ot),$calc(%z2 + 1),32),$iif(%q,d,i),%beforer,$iif(%p2 == 3,r),%afterr)
          }
        }
      }
      if %m == $null {
        if %ez80 {
          var %m trap
        }
        else {
          set %omni.z80.d.hex $left(%omni.z80.d.hex,2)
          omni.z80.d.write noni
          set %omni.z80.d.hex %omni.z80.d.byte
          var %m nop
        }
      }
    }
    elseif (%omni.z80.d.prefix == DD) || (%omni.z80.d.prefix == FD) {
      if %x == 0 {
        if %z == 1 {
          if %q == 0 {
            if %p == 2 {
              var %m ld .regi[],.imm16[]
            }
            elseif %ez80 && %p == 3 {
              var %m ld .regiopp[],(.regiofs8[])
            }
          }
          else {
            var %m add .regi[],.reg16i[%p]
          }
        }
        elseif %z == 2 {
          if %q == 0 {
            if %p == 2 {
              var %m ld (.imm16[]),.regi[]
            }
          }
          else {
            if %p == 2 {
              var %m ld .regi[],(.imm16[])
            }
          }
        }
        elseif %z == 3 {
          if %q == 0 {
            if %p == 2 {
              var %m inc .regi[]
            }
          }
          else {
            if %p == 2 {
              var %m dec .regi[]
            }
          }
        }
        elseif %z == 4 {
          if (%y == 4) || (%y == 5) {
            var %m inc .regi8[%y]
          }
          elseif %y == 6 {
            var %m inc (.regiofs8[])
          }
        }
        elseif %z == 5 {
          if (%y == 4) || (%y == 5) {
            var %m dec .regi8[%y]
          }
          elseif %y == 6 {
            var %m dec (.regiofs8[])
          }
        }
        elseif %z == 6 {
          if (%y == 4) || (%y == 5) {
            var %m ld .regi8[%y],.imm8[]
          }
          elseif %y == 6 {
            var %m ld (.regiofs8[]),.imm8[]
          }
          elseif %ez80 && %y == 7 {
            var %m ld (.regiofs8[]),.regiopp[]
          }
        }
        elseif %ez80 && %z == 7 {
          var %reg16 $iif(%p != 3,.reg16[%p],.regi[])
          if %q == 0 {
            var %m ld %reg16 $+ ,(.regiofs8[])
          }
          else {
            var %m ld (.regiofs8[]), $+ %reg16
          }
        }
      }
      elseif %x == 1 {
        if (%z == 6) && (%y == 6) {
          ;intentionally left blank
        }
        elseif %z == 6 {
          var %m ld .reg8[%y],(.regiofs8[])
        }
        elseif %y == 6 {
          var %m ld (.regiofs8[]),.reg8[%z]
        }
        elseif (%z == 4) || (%z == 5) {
          var %m ld .reg8i[%y],.regi8[%z]
        }
        elseif (%y == 4) || (%y == 5) {
          var %m ld .regi8[%y],.reg8i[%z]
        }
      }
      elseif %x == 2 {
        if (%z == 4) || (%z == 5) {
          var %m .alu[%y].regi8[%z]
        }
        elseif %z == 6 {
          var %m .alu[%y](.regiofs8[])
        }
      }
      else {
        if %z == 1 {
          if %q == 0 {
            if %p == 2 {
              var %m pop .regi[]
            }
          }
          else {
            if %p == 2 {
              var %m jp (.reg16i[2;1])
            }
            elseif %p == 3 {
              var %m ld .reg16i[3;1],.reg16i[2;1]
            }
          }
        }
        elseif %z == 3 {
          if %y == 1 {
            set %omni.z80.d.prefix %omni.z80.d.prefix $+ %omni.z80.d.byte
          }
          elseif %y == 4 {
            var %m ex (.reg16i[3;1]),.reg16i[2;1]
          }
        }
        elseif %z == 5 {
          if %q == 0 {
            if %p == 2 {
              var %m push .regi[]
            }
          }
        }
      }
      if (%m == $null) && (%omni.z80.d.byte != CB) {
        if %ez80 {
          var %m trap
        }
        else {
          dec %omni.z80.d.pos 2
          set %omni.z80.d.hex $left(%omni.z80.d.hex,2)
          omni.z80.d.write .db .byte[%omni.z80.d.hex]
        }
      }
    }
    elseif $len(%omni.z80.d.hex) == 8 {
      if %x == 0 {
        if %z == 6 {
          var %m .rot[%y](.regiofs8[])
        }
        elseif !%ez80 {
          var %m .rot[%y](.regiofs8[]),.reg8[%z]
        }
      }
      elseif %x == 1 {
        if %z == 6 || !%ez80 {
          var %m bit .imm3[%y],(.regiofs8[])
        }
      }
      elseif %x == 2 {
        if %z == 6 {
          var %m res .imm3[%y],(.regiofs8[])
        }
        elseif !%ez80 {
          var %m res .imm3[%y],(.regiofs8[]),.reg8[%z]
        }
      }
      else {
        if %z == 6 {
          var %m set .imm3[%y],(.regiofs8[])
        }
        elseif !%ez80 {
          var %m set .imm3[%y],(.regiofs8[]),.reg8[%z]
        }
      }
      if %m == $null {
        var %m trap
      }
      else {
        var %m %m $+ .dummy[]
        dec %omni.z80.d.pos 4
        set %omni.z80.d.hex $left(%omni.z80.d.hex,-4)
      }
    }
    if %m != $null {
      var %error $omni.z80.d.write(%m)
    }
  }
  unset %omni.z80.d.suffix
  set %omni.z80.d.byte 00
  var %hex %omni.z80.d.hex
  while %hex != $null {
    set %omni.z80.d.hex $left(%hex,2)
    omni.z80.d.write .db .imm8[h;%omni.z80.d.hex]
    var %hex $right(%hex,-2)
  }
  var %str %omni.z80.d.str
  unset %omni.z80.d.* %x %y %z %p %q
  .fclose omni.z80.d.*
  return $left(%str,- $+ $len($omni.asmdivider))
}
/omni.z80.d.bytefeed {
  set %omni.z80.d.byte $mid(%omni.z80.d.input,%omni.z80.d.pos,2)
  set %omni.z80.d.hex %omni.z80.d.hex $+ %omni.z80.d.byte
  set %omni.z80.d.bin $base(%omni.z80.d.byte,16,2,8)
  inc %omni.z80.d.pos 2
  return %omni.z80.d.byte
}
/omni.z80.d.write {
  var %m $omni.z80.mparse($1-)
  if %m == error {
    return %m
  }
  set %omni.z80.d.str %omni.z80.d.str %m $omni.asmdivider
  inc %omni.z80.d.ops
  .fwrite -n omni.z80.d.file $chr(9) $+ $strip(%m)
  .fwrite -n omni.z80.d.hexfile %omni.z80.d.hex
  unset %omni.z80.d.hex
  unset %omni.z80.d.index
  unset %omni.z80.d.prefix
  unset %omni.z80.d.suffix
}
/omni.z80.mparse {
  var %m $1
  if ($left(%m,1) == .) && ([ !isin $gettok(%m,1,32)) {
    var %m $omni.z80.color.def $+ ~ $+ $right(%m,-1)
  }
  elseif %omni.z80.d.true {
    var %m $omni.z80.color.op $+ %m $+ $omni.z80.color.punct
  }
  var %immword 0
  while . isin %m {
    unset %omni.z80.d.color
    var %p1 $pos(%m,.,1)
    if $mid(%m,$calc(%p1 + 1),1) isalnum {
      var %p2 $pos($left(%m,%p1),$chr(93),0)
      var %p2 $pos(%m,$chr(93),$calc(%p2 + 1))
      var %sym $mid(%m,%p1,$calc(%p2 - %p1 + 1))
      if .imm16* iswm %sym {
        var %immword 1
      }
      var %replace $(,$replace($+($,omni.z80.sym,%sym),[,$chr(40),],$chr(41),;,$chr(44))) $+ $omni.z80.color.punct
      if !%omni.z80.d.general && (%omni.z80.d.byte == $null) {
        return error
      }
    }
    else {
      var %p2 %p1
      var %replace ~
    }
    var %m $left(%m,$calc(%p1 - 1)) $+ %omni.z80.d.color $+ $replace(%replace,$chr(160),$chr(32)) $+ $right(%m,- $+ %p2)
  }
  var %m $replace(%m,~,.,$chr(160),$chr(32),$omni.z80.color.punct $+ ,)
  var %suffix $iif(!%omni.z80.d.general,$gettok($iif(%omni.z80.d.adl,.sis .is $iif(%immword,.sil,.s) .lil,.sis $iif(%immword,.lis,.l) .il .lil),$findtok(40 49 52 5B,%omni.z80.d.suffix,32),32))
  var %m $gettok(%m,1,32) $+ %suffix $gettok(%m,2-,32)
  return %m
}
/omni.z80.sym.bcall {
  set %omni.z80.d.color $omni.z80.color.imm
  var %byte $omni.z80.d.bytefeed
  var %addr $omni.z80.d.bytefeed $+ %byte $+ h
  if %omni.z80.d.general && !$2 {
    return imm16
  }
  var %inc $omni.file($gettok($omni.z80.includes(%omni.z80.d.model),1,32),z80)
  var %r $read(%inc,ntw,*equ %addr $+ *)
  if %r == $null {
    var %r $read(%inc,ntw,$+(*equ,$chr(9),%addr,*))
  }
  if $left(%r,1) != _ {
    return %addr
  }
  set %omni.z80.d.color $omni.z80.color.bcall
  return $gettok(%r,1,9)
}
/omni.z80.sym.imm3 {
  set %omni.z80.d.color $omni.z80.color.imm
  if %omni.z80.d.general && !$2 {
    return imm3
  }
  return $1
}
/omni.z80.sym.zero {
  set %omni.z80.d.color $omni.z80.color.imm
  return 0
}
/omni.z80.sym.byte {
  set %omni.z80.d.color $omni.z80.color.imm
  if %omni.z80.d.general && !$2 {
    return imm8
  }
  return $iif($3 == b,% $+ $base($1,16,2,8),$iif($3 == d,$base($1,16,10),$ $+ $1))
}
/omni.z80.sym.dummy {
  omni.z80.d.bytefeed
  return
}
/omni.z80.sym.punct {
  set %omni.z80.d.color $omni.z80.color.punct
  return $1
}
/omni.z80.sym.ofs8 {
  set %omni.z80.d.color $omni.z80.color.imm
  var %dec $base($omni.z80.d.bytefeed,16,10)
  if %omni.z80.d.general && !$2 {
    return ofs8
  }
  return $iif(%dec <= 127,+ $+ %dec,$calc(%dec - 256))
}
/omni.z80.sym.ofs8pc {
  set %omni.z80.d.color $omni.z80.color.imm
  var %dec $calc(($base($omni.z80.d.bytefeed,16,10) + 2) % 256)
  if %omni.z80.d.general && !$2 {
    return ofs8
  }
  return $ $+ $iif(%dec <= 129,+ $+ %dec,$calc(%dec - 256))
}
/omni.z80.sym.imm8 {
  set %omni.z80.d.color $omni.z80.color.imm
  if $2 == $null {
    var %a $omni.z80.d.bytefeed
  }
  else {
    var %a $2
  }
  if %omni.z80.d.general && !$3 {
    return imm8
  }
  return $iif($1 == b,% $+ $base(%a,16,2,8),$iif($1 == d,$base(%a,16,10),$ $+ %a))
}
/omni.z80.sym.imm16 {
  set %omni.z80.d.color $omni.z80.color.imm
  var %suffix %omni.z80.d.suffix
  var %bits $iif(%suffix == 52 || %suffix == 5B || (%omni.z80.d.adl && %suffix != 40 && %suffix != 49),24,16)
  if $2 == $null {
    var %a $omni.z80.d.bytefeed
    var %a $omni.z80.d.bytefeed $+ %a
    if %bits == 24 {
      var %a $omni.z80.d.bytefeed $+ %a
    }
  }
  else {
    var %a $2
  }
  if %omni.z80.d.general && !$3 {
    return imm $+ $iif(%omni.z80.d.generalsuffix,$iif(%omni.z80.d.ez80,24,16),%bits)
  }
  if $1 == b {
    return % $+ $base(%a,16,%bits)
  }
  if $1 == d {
    return $base(%a,16,10)
  }
  return $ $+ %a
}
/omni.z80.sym.imm24 {
  return $omni.z80.sym.imm16($1,$2,$3)
}
/omni.z80.sym.dec2h {
  set %omni.z80.d.color $omni.z80.color.imm
  if %omni.z80.d.general && !$2 {
    return imm8
  }
  return $base($1,10,16,2) $+ h
}
/omni.z80.sym.iff1 {
  set %omni.z80.d.color $omni.z80.color.reg
  return IFF1
}
/omni.z80.sym.iff2 {
  set %omni.z80.d.color $omni.z80.color.reg
  return IFF2
}
/omni.z80.sym.reg8 {
  set %omni.z80.d.color $omni.z80.color.reg
  if %omni.z80.d.general && !$2 {
    return reg8
  }
  return $gettok(b_c_d_e_h_l_(hl)_a,$calc($1 + 1),95)
}
/omni.z80.sym.reg8i {
  set %omni.z80.d.color $omni.z80.color.reg
  if %omni.z80.d.general && !$2 {
    return reg8
  }
  return $gettok($+(b_c_d_e_,%omni.z80.d.index,h_,%omni.z80.d.index,l_!_a),$calc($1 + 1),95)
}
/omni.z80.sym.regi8 {
  set %omni.z80.d.color $omni.z80.color.reg
  if %omni.z80.d.general && !$2 {
    return reg8index
  }
  return $gettok($+(!_!_!_!_,%omni.z80.d.index,h_,%omni.z80.d.index,l_!_!),$calc($1 + 1),95)
}
/omni.z80.sym.regiofs8 {
  return $+(.regi[,$1,],$iif(%omni.z80.d.general,.punct[+]),.ofs8[])
}
/omni.z80.sym.reg8ir {
  set %omni.z80.d.color $omni.z80.color.reg
  if %omni.z80.d.general && !$2 {
    return $chr(123) i $chr(124) r $chr(125)
  }
  return $gettok(i_r,$calc($1 + 1),95)
}
/omni.z80.sym.regmb {
  set %omni.z80.d.color $omni.z80.color.reg
  return mb
}
/omni.z80.sym.reglsb {
  set %omni.z80.d.color $omni.z80.color.reg
  return regLSB
}
/omni.z80.sym.regmsb {
  set %omni.z80.d.color $omni.z80.color.reg
  return regMSB
}
/omni.z80.sym.reg16 {
  set %omni.z80.d.color $omni.z80.color.reg
  if %omni.z80.d.general && !$2 {
    var %suffix %omni.z80.d.suffix
    return reg $+ $iif($iif(%omni.z80.d.generalsuffix,%omni.z80.d.ez80,$iif(%suffix == 49 || %suffix == 5B || (%omni.z80.d.adl && %suffix != 40 && %suffix != 52),1,0)),24,16)
  }
  return $gettok(bc_de_hl_sp,$calc($1 + 1),95)
}
/omni.z80.sym.reg24 {
  return $omni.z80.sym.reg16($1,$2)
}
/omni.z80.sym.reg16af {
  set %omni.z80.d.color $omni.z80.color.reg
  if %omni.z80.d.general && !$2 {
    return $omni.z80.sym.reg16($1,$2)
  }
  return $gettok(bc_de_hl_af,$calc($1 + 1),95)
}
/omni.z80.sym.reg24af {
  return $omni.z80.sym.reg16af($1,$2)
}
/omni.z80.sym.reg16sh {
  set %omni.z80.d.color $omni.z80.color.reg
  if %omni.z80.d.general && !$2 {
    return $omni.z80.sym.reg16($1,$2)
  }
  return $gettok(bc'_de'_hl'_af',$calc($1 + 1),95)
}
/omni.z80.sym.reg24sh {
  return $omni.z80.sym.reg16sh($1,$2)
}
/omni.z80.sym.reg16i {
  set %omni.z80.d.color $omni.z80.color.reg
  if %omni.z80.d.general && !$2 {
    return $omni.z80.sym.reg16($1,$2)
  }
  return $gettok(bc_de_ $+ %omni.z80.d.index $+ _sp,$calc($1 + 1),95)
}
/omni.z80.sym.reg24i {
  return $omni.z80.sym.reg16i($1,$2)
}
/omni.z80.sym.regi {
  set %omni.z80.d.color $omni.z80.color.reg
  if $1 != $null {
    return $iif($1,iy,ix)
  }
  return %omni.z80.d.index
}
/omni.z80.sym.regiopp {
  set %omni.z80.d.color $omni.z80.color.reg
  return $iif(%omni.z80.d.index == ix,iy,ix)
}
/omni.z80.sym.regpc {
  set %omni.z80.d.color $omni.z80.color.reg
  return pc
}
/omni.z80.sym.cc {
  set %omni.z80.d.color $omni.z80.color.flag
  if %omni.z80.d.general && !$2 {
    return cc
  }
  return $gettok(nz_z_nc_c_po_pe_p_m,$calc($1 + 1),95)
}
/omni.z80.sym.alu {
  var %acomma .reg8[7;1] $+ $chr(44)
  var %acommamaybe $chr(160) $+ $iif(%omni.z80.d.ez80,%acomma,)
  return $gettok(add %acomma $+ _adc %acomma $+ _sub $+ %acommamaybe $+ _sbc %acomma $+ _and $+ %acommamaybe $+ _xor $+ %acommamaybe $+ _or $+ %acommamaybe $+ _cp $+ %acommamaybe,$calc($1 + 1),95)
}
/omni.z80.sym.rot {
  return $gettok(rlc $+ $chr(160) $+ _rrc $+ $chr(160) $+ _rl $+ $chr(160) $+ _rr $+ $chr(160) $+ _sla $+ $chr(160) $+ _sra $+ $chr(160) $+ _sll $+ $chr(160) $+ _srl $+ $chr(160),$calc($1 + 1),95)
}
/omni.z80.sym.im {
  set %omni.z80.d.color $omni.z80.color.imm
  return $gettok(0_0/1_1_2_0_0/1_1_2,$calc($1 + 1),95)
}
/omni.z80.a {
  var %input $1
  var %model $2
  var %class $3
  var %ez80 $iif(%class == ez80,1,0)
  var %adl %ez80
  var %hex
  .fclose omni.z80.a.*
  .fopen -o omni.z80.a.file $omni.file(assembly.txt,%class)
  .fopen -o omni.z80.a.hexfile $omni.file(assemblyhex.txt,%class)
  while %input != $null {
    var %bin
    var %prefix
    var %suffix
    var %m $replace($gettok($gettok(%input,1,$asc($strip($omni.asmdivider))),1-,32),$chr(9),$chr(32))
    var %mns %m
    var %input $gettok($gettok(%input,2-,$asc($strip($omni.asmdivider))),1-,32)
    if ,, isin %m {
      goto error
    }
    var %m1 $gettok(%m,1,32)
    if %ez80 {
      var %ms
      var %ms1
      var %ms2
      if $regex(%m,/^([^ .]+)\.([^ .]+)(.*)/) {
        var %m1 $regml(1)
        var %ms $regml(2)
        var %mns $regml(1) $+ $regml(3)
        var %ms1 $iif(%adl,l,s)
        var %ms2 $iif(%adl,il,is)
        if $regex(%ms,/^([sl])$/i) {
          var %ms1 $regml(1)
        }
        elseif $regex(%ms,/^(i[sl])$/i) {
          var %ms2 $regml(1)
        }
        elseif $regex(%ms,/^([sl])(i[sl])$/i) {
          var %ms1 $regml(1)
          var %ms2 $regml(2)
        }
        else {
          goto error
        }
        var %ms %ms1 $+ %ms2
        var %suffix $gettok(01000000 01001001 01010010 01011011,$findtok(sis lis sil lil,%ms,32),32)
      }
    }
    var %wordbits $iif(%ms2 == il || (%adl && %ms2 != is),24,16)
    var %m2.1- $gettok(%m,2-,32)
    if ($left(%m2.1-,1) == ,) || ($right(%m2.1-,1) == ,) {
      goto error
    }
    var %m2.1 $gettok($gettok(%m2.1-,1,44),1-,32)
    var %m2.2- $gettok($gettok(%m2.1-,2-,44),1-,32)
    var %m2.2 $gettok($gettok(%m2.1-,2,44),1-,32)
    var %m2.3 $gettok($gettok(%m2.1-,3-,44),1-,32)
    if .* iswm %m1 {
      if %ms != $null {
        goto error
      }
      var %databits $calc($findtok(.db .dw $iif(%ez80,.dl),%m1,32) * 8)
      if %databits {
        if %m2.1- == $null {
          goto error
        }
        while %m2.1 != $null {
          var %noqt $noqt(%m2.1)
          if $qt(%noqt) == %m2.1 {
            while %noqt != $null {
              var %bin %bin $+ $base($asc($left(%noqt,1)),10,2,8)
              var %noqt $right(%noqt,-1)
            }
          }
          else {
            var %a $left($omni.z80.a.calc(%m2.1,%model,2,%wordbits),%databits)
            if %a == $null {
              goto error
            }
            var %bin %bin $+ %a
          }
          var %m2.1- $gettok(%m2.1-,2-,44)
          var %m2.1 $gettok(%m2.1-,1,44)
        }
        goto end
      }
    }
    if !%ez80 && (($left(%m,6) == B_CALL) || ($left(%m,5) == bcall)) {
      var %pos $iif($left(%m,6) == B_CALL,7,6)
      if ($mid(%m,%pos,1) == $chr(40)) && ($right(%m,1) == $chr(41)) {
        var %bcall $left($right(%m,- $+ %pos),-1)
      }
      elseif $mid(%m,%pos,1) == $chr(32) {
        var %bcall $right(%m,- $+ %pos)
      }
      else {
        goto error
      }
      var %a $omni.z80.a.imm16(%bcall,%model,%wordbits)
      if %a != $null {
        var %bin 11101111 $+ %a
        goto end
      }
    }
    if %mns == nop {
      var %bin 00000000
      goto end
    }
    if %m1 == ex {
      if (%m2.1 == af) && (%m2.2- == af') {
        var %bin 00001000
        goto end
      }
      if (%m2.1 == (sp)) && $omni.z80.a.ishlixiy(%m2.2-) {
        var %prefix $omni.z80.a.reg16prefix(%m2.2-)
        var %bin 11100011
        goto end
      }
      if (%m2.1 == de) && (%m2.2- == hl) {
        var %bin 11101011
        goto end
      }
    }
    if %m1 == djnz {
      var %a $omni.z80.a.ofs8pc(%m2.1-,%model)
      if %a != $null {
        var %bin 00010000 $+ %a
        goto end
      }
    }
    if %m1 == jr {
      var %a $omni.z80.a.ofs8pc(%m2.1-,%model)
      if %a != $null {
        var %bin 00011000 $+ %a
        goto end
      }
      var %a $omni.z80.a.ccjr(%m2.1)
      if %a != $null {
        var %b $omni.z80.a.ofs8pc(%m2.2-,%model)
        if %b != $null {
          var %bin 00 $+ %a $+ 000 $+ %b
          goto end
        }
      }
    }
    if %m1 == ld {
      var %a $omni.z80.a.reg16(%m2.1)
      if %a != $null {
        var %p $omni.z80.a.reg16prefix(%m2.1)
        var %ptr $omni.z80.a.ptr(%m2.2-)
        var %b $omni.z80.a.imm16(%ptr,%model,%wordbits)
        if %b != $null {
          var %prefix %p
          if $omni.z80.a.ishlixiy(%m2.1) {
            var %bin 00101010 $+ %b
          }
          else {
            var %bin 1110110101 $+ %a $+ 1011 $+ %b
          }
          goto end
        }
        var %b $omni.z80.a.imm16(%m2.2-,%model,%wordbits)
        if %b != $null {
          var %prefix %p
          var %bin 00 $+ %a $+ 0001 $+ %b
          goto end
        }
        elseif %ez80 {
          if %m2.2- == (hl) {
            var %a $omni.z80.a.reg16e(%m2.1,11011101)
            if %a == 100 {
              var %bin 1110110100110001
              goto end
            }
            var %bin 1110110100 $+ %a $+ 0111
            goto end
          }
          var %x $omni.z80.a.regiofs8(%m2.2-,%model)
          var %p2 $gettok(%x,1,32)
          var %b $gettok(%x,2,32)
          if %b != $null {
            var %a $omni.z80.a.reg16e(%m2.1,%p2)
            var %prefix %p2
            if %a == 100 {
              var %bin 00110001 $+ %b
              goto end
            }
            var %bin 00 $+ %a $+ 0111 $+ %b
            goto end
          }
        }
      }
      if %m2.1 == sp {
        if $omni.z80.a.ishlixiy(%m2.2-) {
          var %prefix $omni.z80.a.reg16prefix(%m2.2-)
          var %bin 11111001
          goto end
        }
      }
      if %m2.1 == (bc) {
        if %m2.2- == a {
          var %bin 00000010
          goto end
        }
      }
      if %m2.1 == (de) {
        if %m2.2- == a {
          var %bin 00010010
          goto end
        }
      }
      var %ptr $omni.z80.a.ptr(%m2.1)
      if %ptr != $null {
        var %a $omni.z80.a.imm16(%ptr,%model,%wordbits)
        if %a != $null {
          var %p $omni.z80.a.reg16prefix(%m2.2-)
          var %b $omni.z80.a.reg16(%m2.2-)
          if %b != $null {
            var %prefix %p
            if $omni.z80.a.ishlixiy(%m2.2-) {
              var %bin 00100010 $+ %a
            }
            else {
              var %bin 1110110101 $+ %b $+ 0011 $+ %a
            }
            goto end
          }
          if %m2.2- == a {
            var %bin 00110010 $+ %a
            goto end
          }
        }
      }
      if %m2.1 == a {
        if %m2.2- == (bc) {
          var %bin 00001010
          goto end
        }
        if %m2.2- == (de) {
          var %bin 00011010
          goto end
        }
        var %ptr $omni.z80.a.ptr(%m2.2-)
        if %ptr != $null {
          var %a $omni.z80.a.imm16(%ptr,%model,%wordbits)
          if %a != $null {
            var %bin 00111010 $+ %a
            goto end
          }
        }
        if %m2.2- == i {
          var %bin 1110110101010111
          goto end
        }
        if %m2.2- == r {
          var %bin 1110110101011111
          goto end
        }
        if %ez80 && (%m2.2- == mb) {
          var %bin 1110110101101110
          goto end
        }
      }
      var %a $omni.z80.a.reg8(%m2.1)
      if %a != $null {
        var %p $omni.z80.a.reg8prefix(%m2.1)
        var %b $omni.z80.a.imm8(%m2.2-,%model)
        if %b != $null {
          var %prefix %p
          var %bin 00 $+ %a $+ 110 $+ %b
          goto end
        }
        var %b $omni.z80.a.reg8(%m2.2-)
        if (%b != $null) && ((%a != %b) || !$istok($iif(%ez80,b c d e) $chr(40) $+ hl $+ $chr(41),%m2.1,32)) {
          var %p2 $omni.z80.a.reg8prefix(%m2.2-)
          if $istok(100 101,%a,32) && $istok(100 101,%b,32) && (%p != %p2) {
            goto error
          }
          if %p != $null {
            if (%p2 != $null) && (%p != %p2) {
              goto error
            }
            if %m2.2- == (hl) {
              goto error
            }
            var %prefix %p
          }
          elseif %p2 != $null {
            if %m2.1 == (hl) {
              goto error
            }
            var %prefix %p2
          }
          var %bin 01 $+ %a $+ %b
          goto end
        }
        if (%m2.1 != (hl)) && (%p == $null) {
          var %x $omni.z80.a.regiofs8(%m2.2-,%model)
          var %p2 $gettok(%x,1,32)
          var %b $gettok(%x,2-,32)
          if %b != $null {
            var %prefix %p2
            var %bin 01 $+ %a $+ 110 $+ %b
            goto end
          }
        }
      }
      var %x $omni.z80.a.regiofs8(%m2.1,%model)
      var %p $gettok(%x,1,32)
      var %a $gettok(%x,2-,32)
      if %a != $null {
        var %b $omni.z80.a.imm8(%m2.2-,%model)
        if %b != $null {
          var %prefix %p
          var %bin 00110110 $+ %a $+ %b
          goto end
        }
        var %b $omni.z80.a.reg8nohl(%m2.2-,0)
        if %b != $null {
          var %prefix %p
          var %bin 01110 $+ %b $+ %a
          goto end
        }
        var %b $omni.z80.a.reg16e(%m2.2-,%p)
        if %b != $null {
          var %prefix %p
          if %b == 100 {
            var %bin 00111110 $+ %a
            goto end
          }
          var %bin 00 $+ %b $+ 1111 $+ %a
          goto end
        }
      }
      if %m2.1 == i {
        if %m2.2- == a {
          var %bin 1110110101000111
          goto end
        }
        if %ez80 && %m2.2- == hl {
          var %bin 1110110111000111
          goto end
        }
      }
      if %m2.1 == r {
        if %m2.2- == a {
          var %bin 1110110101001111
          goto end
        }
      }
      if %ez80 {
        if %m2.1 == (hl) {
          var %b $omni.z80.a.reg16e(%m2.2-)
          if %b != $null {
            if %b == 100 {
              var %bin 1110110100111110
              goto end
            }
            var %bin 1110110100 $+ %b $+ 1111
            goto end
          }
        }
        if %m2.1 == mb {
          if %m2.2- == a {
            var %bin 1110110101101101
            goto end
          }
        }
        if %m2.1 == hl {
          if %m2.2- == i {
            var %bin 1110110111010111
            goto end
          }
        }
      }
    }
    if %m1 == add {
      var %p $omni.z80.a.reg16prefix(%m2.1)
      if $omni.z80.a.ishlixiy(%m2.1) {
        var %b $omni.z80.a.reg16(%m2.2-)
        if %b != $null {
          var %p2 $omni.z80.a.reg16prefix(%m2.2-)
          if (%p2 != $null) && (%p != %p2) {
            goto error
          }
          var %prefix %p
          var %bin 00 $+ %b $+ 1001
          goto end
        }
      }
      var %a $omni.z80.a.imm8(%m2.1-,%model)
      if %a != $null {
        var %bin 11000110 $+ %a
        goto end
      }
    }
    if %m1 == inc {
      var %a $omni.z80.a.reg16(%m2.1-)
      if %a != $null {
        var %prefix $omni.z80.a.reg16prefix(%m2.1-)
        var %bin 00 $+ %a $+ 0011
        goto end
      }
      var %a $omni.z80.a.reg8(%m2.1-)
      if %a != $null {
        var %prefix $omni.z80.a.reg8prefix(%m2.1-)
        var %bin 00 $+ %a $+ 100
        goto end
      }
      var %x $omni.z80.a.regiofs8(%m2.1,%model)
      var %p $gettok(%x,1,32)
      var %a $gettok(%x,2-,32)
      if %a != $null {
        var %prefix %p
        var %bin 00110100 $+ %a
        goto end
      }
    }
    if %m1 == dec {
      var %a $omni.z80.a.reg16(%m2.1-)
      if %a != $null {
        var %prefix $omni.z80.a.reg16prefix(%m2.1-)
        var %bin 00 $+ %a $+ 1011
        goto end
      }
      var %a $omni.z80.a.reg8(%m2.1-)
      if %a != $null {
        var %prefix $omni.z80.a.reg8prefix(%m2.1-)
        var %bin 00 $+ %a $+ 101
        goto end
      }
      var %x $omni.z80.a.regiofs8(%m2.1,%model)
      var %p $gettok(%x,1,32)
      var %a $gettok(%x,2-,32)
      if %a != $null {
        var %prefix %p
        var %bin 00110101 $+ %a
        goto end
      }
    }
    if %mns == rlca {
      var %bin 00000111
      goto end
    }
    if %mns == rrca {
      var %bin 00001111
      goto end
    }
    if %mns == rla {
      var %bin 00010111
      goto end
    }
    if %mns == rra {
      var %bin 00011111
      goto end
    }
    if %mns == daa {
      var %bin 00100111
      goto end
    }
    if %mns == cpl {
      var %bin 00101111
      goto end
    }
    if %mns == scf {
      var %bin 00110111
      goto end
    }
    if %mns == ccf {
      var %bin 00111111
      goto end
    }
    if %mns == halt {
      var %bin 01110110
      goto end
    }
    var %a $omni.z80.a.alu(%m1)
    if %a != $null {
      if (%m1 != add) && (%m1 != adc) && (%m1 != sbc) && (%m2.2- == $null) {
        var %x %m2.1-
      }
      else {
        var %x $omni.z80.a.reg8(%m2.1)
        if (%x == 111) {
          var %x %m2.2-
        }
        else {
          var %x
        }
      }
      if %x != $null {
        var %b $omni.z80.a.reg8(%x)
        if %b != $null {
          var %prefix $omni.z80.a.reg8prefix(%x)
          var %bin 10 $+ %a $+ %b
          goto end
        }
        var %b $omni.z80.a.imm8(%x,%model)
        if %b != $null {
          var %bin 11 $+ %a $+ 110 $+ %b
          goto end
        }
        var %x $omni.z80.a.regiofs8(%x,%model)
        var %p $gettok(%x,1,32)
        var %b $gettok(%x,2-,32)
        if %b != $null {
          var %prefix %p
          var %bin 10 $+ %a $+ 110 $+ %b
          goto end
        }
      }
    }
    if %m1 == ret {
      var %a $omni.z80.a.cc(%m2.1-)
      if %a != $null {
        var %bin 11 $+ %a $+ 000
        goto end
      }
      if %m2.1- == $null {
        var %bin 11001001
        goto end
      }
    }
    if %m1 == pop {
      var %a $omni.z80.a.reg16af(%m2.1-)
      if %a != $null {
        var %prefix $omni.z80.a.reg16prefix(%m2.1-)
        var %bin 11 $+ %a $+ 0001
        goto end
      }
    }
    if %mns == exx {
      var %bin 11011001
      goto end
    }
    if %m1 == jp {
      var %reg16ptr $omni.z80.a.ptr(%m2.1-)
      if %reg16ptr != $null {
        if $omni.z80.a.ishlixiy(%reg16ptr) {
          var %prefix $omni.z80.a.reg16prefix(%reg16ptr)
          var %bin 11101001
          goto end
        }
      }
      var %a $omni.z80.a.cc(%m2.1)
      if %a != $null {
        var %b $omni.z80.a.imm16(%m2.2-,%model,%wordbits)
        if %b != $null {
          var %bin 11 $+ %a $+ 010 $+ %b
          goto end
        }
      }
      var %a $omni.z80.a.imm16(%m2.1-,%model,%wordbits)
      if %a != $null {
        var %bin 11000011 $+ %a
        goto end
      }
    }
    if %m1 == in {
      var %port $omni.z80.a.port(%m2.2-)
      if %port != $null {
        if (%port == c) || (%ez80 && (%port == bc)) {
          if %m2.1 == f {
            var %a 110
          }
          else {
            var %a $omni.z80.a.reg8nohl(%m2.1,0)
          }
          if %a != $null {
            var %bin 1110110101 $+ %a $+ 000
            goto end
          }
        }
        var %b $omni.z80.a.imm8(%port,%model)
        if %b != $null {
          if %m2.1 == a {
            var %bin 11011011 $+ %b
            goto end
          }
        }
      }
      var %port $omni.z80.a.port(%m2.1-)
      if (%port == c) || (%ez80 && (%port == bc)) {
        var %bin 1110110101110000
        goto end
      }
    }
    if %m1 == out {
      var %port $omni.z80.a.port(%m2.1)
      if %port != $null {
        if (%port == c) || (%ez80 && (%port == bc)) {
          if %m2.2- == 0 {
            if !%ez80 {
              var %a 110
            }
          }
          else {
            var %a $omni.z80.a.reg8nohl(%m2.2-,0)
          }
          if %a != $null {
            var %bin 1110110101 $+ %a $+ 001
            goto end
          }
        }
        var %a $omni.z80.a.imm8(%port,%model)
        if %a != $null {
          if %m2.2- == a {
            var %bin 11010011 $+ %a
            goto end
          }
        }
      }
    }
    if %mns == di {
      var %bin 11110011
      goto end
    }
    if %mns == ei {
      var %bin 11111011
      goto end
    }
    if %m1 == call {
      var %a $omni.z80.a.cc(%m2.1)
      if %a != $null {
        var %b $omni.z80.a.imm16(%m2.2-,%model,%wordbits)
        if %b != $null {
          var %bin 11 $+ %a $+ 100 $+ %b
          goto end
        }
      }
      var %a $omni.z80.a.imm16(%m2.1-,%model,%wordbits)
      if %a != $null {
        var %bin 11001101 $+ %a
        goto end
      }
    }
    if %m1 == push {
      var %a $omni.z80.a.reg16af(%m2.1-)
      if %a != $null {
        var %prefix $omni.z80.a.reg16prefix(%m2.1-)
        var %bin 11 $+ %a $+ 0101
        goto end
      }
    }
    if %m1 == rst {
      var %a $omni.z80.a.rst(%m2.1-,%model)
      if %a != $null {
        var %bin 11 $+ %a $+ 111
        goto end
      }
    }
    var %a $omni.z80.a.rot(%m1)
    if %a != $null {
      if %ez80 && (%a == 110) {
        goto error
      }
      var %b $omni.z80.a.reg8(%m2.1-,0)
      if %b != $null {
        var %bin 1100101100 $+ %a $+ %b
        goto end
      }
      var %x $omni.z80.a.regiofs8(%m2.1,%model)
      var %p $gettok(%x,1,32)
      var %b $gettok(%x,2-,32)
      if %b != $null {
        if %m2.2- == $null {
          var %prefix %p
          var %bin 11001011 $+ %b $+ 00 $+ %a $+ 110
          goto end
        }
        if !%ez80 {
          var %c $omni.z80.a.reg8nohl(%m2.2-,0)
          if %c != $null {
            var %prefix %p
            var %bin 11001011 $+ %b $+ 00 $+ %a $+ %c
            goto end
          }
        }
      }
    }
    var %o $omni.z80.a.bit(%m1)
    if %o != $null {
      var %a $omni.z80.a.imm3(%m2.1,%model)
      if %a != $null {
        var %b $omni.z80.a.reg8(%m2.2-,0)
        if %b != $null {
          var %bin 11001011 $+ %o $+ %a $+ %b
          goto end
        }
        var %x $omni.z80.a.regiofs8(%m2.2,%model)
        var %p $gettok(%x,1,32)
        var %b $gettok(%x,2-,32)
        if %b != $null {
          if %m2.3 == $null {
            var %c 110
          }
          elseif !%ez80 {
            var %c $omni.z80.a.reg8nohl(%m2.3,0)
          }
          if %c != $null {
            var %prefix %p
            var %bin 11001011 $+ %b $+ %o $+ %a $+ %c
            goto end
          }
        }
      }
    }
    if %m1 == sbc {
      if %m2.1 == hl {
        var %a $omni.z80.a.reg16(%m2.2-,0)
        if %a != $null {
          var %bin 1110110101 $+ %a $+ 0010
          goto end
        }
      }
    }
    if %m1 == adc {
      if %m2.1 == hl {
        var %a $omni.z80.a.reg16(%m2.2-,0)
        if %a != $null {
          var %bin 1110110101 $+ %a $+ 1010
          goto end
        }
      }
    }
    if %mns == neg {
      var %bin 1110110101000100
      goto end
    }
    if %mns == retn {
      var %bin 1110110101000101
      goto end
    }
    if %mns == reti {
      var %bin 1110110101001101
      goto end
    }
    if %m1 == im {
      var %a $omni.z80.a.im(%m2.1-)
      if (%a != $null) && (!%ez80 || (%a != 01)) {
        var %bin 1110110101 $+ %a $+ 110
        goto end
      }
    }
    if %mns == rrd {
      var %bin 1110110101100111
      goto end
    }
    if %mns == rld {
      var %bin 1110110101101111
      goto end
    }
    if !%ez80 {
      var %a $omni.z80.a.bli(%m)
      if %a != $null {
        var %bin 11101101 $+ %a
        goto end
      }
    }
    else {
      if %m2.1- == $null {
        var %a $omni.z80.a.blie(%m1)
        if %a != $null {
          var %bin 11101101 $+ %a
          goto end
        }
      }
      if %m1 == in0 {
        var %port $omni.z80.a.port(%m2.2-)
        if %port != $null {
          var %b $omni.z80.a.imm8(%port,%model)
          if %b != $null {
            if %m2.1 == f {
              var %a 110
            }
            else {
              var %a $omni.z80.a.reg8nohl(%m2.1,0)
            }
            if %a != $null {
              var %bin 1110110100 $+ %a $+ 000 $+ %b
              goto end
            }
          }
        }
        var %port $omni.z80.a.port(%m2.1-)
        if %port != null {   
          var %b $omni.z80.a.imm8(%port,%model)
          if %b != $null {
            var %bin 1110110100110000 $+ %b
            goto end
          }
        }
      }
      if %m1 == out0 {
        var %port $omni.z80.a.port(%m2.1)
        if %port != $null {
          var %b $omni.z80.a.imm8(%port,%model)
          if %b != $null {
            var %a $omni.z80.a.reg8nohl(%m2.2-,0)
            if %a != $null {
              var %bin 1110110100 $+ %a $+ 001 $+ %b
              goto end
            }
          }
        }
      }
      if %m1 == lea {
        var %x $omni.z80.a.regiofs8(%m2.2-,%model,0)
        var %p $gettok(%x,1,32)
        var %b $gettok(%x,2,32)
        if %b != $null {
          var %a $omni.z80.a.reg16e(%m2.1,%p)
          if %a != $null {
            var %piy $iif(%p == 11111101,1,0)
            if %a == 100 {
              var %bin 111011010101010 $+ $iif(%piy,0,1) $+ %b
              goto end
            }
            var %bin 1110110100 $+ %a $+ 001 $+ %piy $+ %b
            goto end
          }
        }
      }
      if %m1 == tst {
        if %m2.1 == a {
          var %b $omni.z80.a.reg8(%m2.2-,0)
          if %b != $null {
            var %bin 1110110100 $+ %b $+ 100
            goto end
          }
          var %b $omni.z80.a.imm8(%m2.2-,%model)
          if %b != $null {
            var %bin 1110110101100100 $+ %b
            goto end
          }
        }
      }
      if %m1 == tstio {
        var %a $omni.z80.a.imm8(%m2.1-,%model)
        if %a != $null {
          var %bin 1110110101110100 $+ %a
          goto end
        }
      }
      if %m1 == pea {
        var %x $omni.z80.a.regiofs8(%m2.1-,%model,0)
        var %p $gettok(%x,1,32)
        var %a $gettok(%x,2,32)
        if %a != $null {
          var %bin 11101101011001 $+ $iif(%p == 11011101,01,10) $+ %a
          goto end
        }
      }
      if %mns == slp {
        var %bin 1110110101110110
        goto end
      }
      if %m1 == mlt {
        var %a $omni.z80.a.reg16(%m2.1-,0)
        if %a != $null {
          var %bin 1110110101 $+ %a $+ 1100
          goto end
        }
      }
      if %mns == stmix {
        var %bin 1110110101111101
        goto end
      }
      if %mns == rsmix {
        var %bin 1110110101111110
        goto end
      }
      if %mns == trap {
        var %bin 1101110111000111
        goto end
      }
    }
    :end
    if %bin == $null {
      goto error
    }
    var %hex
    var %bin %suffix $+ %prefix $+ %bin
    while %bin != $null {
      var %hex %hex $+ $base($left(%bin,8),2,16,2)
      var %bin $right(%bin,-8)
    }
    var %str %str $+ %hex
    .fwrite -n omni.z80.a.file $chr(9) $+ %m
    .fwrite -n omni.z80.a.hexfile %hex
  }
  .fclose omni.z80.a.*
  return %str
  :error
  .fclose omni.z80.a.*
  return error $iif(%prefix == 11111101,$replace(%m,ix,iy),%m)
}
/omni.z80.a.calc.spaceify {
  return $regsubex($1,/(?<!'(?<!'.'))([()*/\-+\%^&|!~]|<<|>>|==|<=|>=|<|>|=)/g,$chr(32) $+ \1 $+ $chr(32))
}
/omni.z80.a.calc {
  ;echo -s 1: $1 2: $2 3: $3 4: $4 5: $5
  var %r $omni.z80.a.calc.main($1,$2,$3,$4,$5)
  unset %outbits
  unset %signedmax
  unset %overflow
  unset %mainbase
  unset %mainbaserank
  unset %opsperformed
  unset %arg1
  return %r
}
/omni.z80.a.calc.main {
  if $regex($1,/(?<!')[^\s\w()*/\-+\%^&|$@' $+ $chr(44) $+ <>=]/) {
    return
  }
  set -ln %equ $omni.z80.a.calc.spaceify($1)
  if %equ == $null {
    return
  }
  var %model $2
  var %class $iif(%model == 8384pce,eZ80,Z80)
  var %outbase $iif($3 != $null,$3,auto)
  set %outbits $iif($4 != $null,$4,16)
  var %modifiers $5
  var %max $calc(2 ^ %outbits)
  set %signedmax $calc(%max / 2)
  set %overflow 0
  set %mainbase 10
  set %mainbaserank -1
  var %iterations 0
  set -ln %argstack
  set -ln %opstack
  set -n %arg1
  set -ln %op
  set -ln %arg2
  if ($left(%equ,1) == $chr(40)) && ($right(%equ,1) == $chr(41)) {
    ;echo 4 -s Parentheses
  }
  while %equ != $null {
    :start
    inc %iterations
    set -ln %a $gettok(%equ,1,32)
    if %a == ' {
      set -ln %a $left(%equ,3)
      set -ln %equ $right(%equ,-3)
    }
    else {
      set -ln %equ $gettok(%equ,2-,32)
    }
    if %arg1 == $null {
      if $regex(%equ,/^(the )?answer to life( $+ $chr(44) $+ ? the universe $+ $chr(44) $+ ? and everything)?(.*)/i) {
        omni.z80.a.setarg1 42
        set -ln %equ $regml(3)
        inc %iterations
      }
      elseif (%a == +) || (%a == -) {
        omni.z80.a.setarg1 0
        set -ln %op %a
        dec %iterations
      }
      elseif (%a == %) {
        set -ln %equ % $+ %equ
        dec %iterations
      }
      elseif %a == $chr(40) {
        set -ln %argstack null %argstack
        set -ln %opstack null %opstack
      }
      else {
        var %imm $omni.z80.a.immhandler(%a,%model,%class)
        if %imm == $null {
          return
        }
        if $gettok(%imm,1,32) == equ {
          set -ln %equ ( $omni.z80.a.calc.spaceify($gettok(%imm,2-,32)) ) %equ
          goto start
        }
        omni.z80.a.setarg1 %imm
      }
    }
    elseif %op == $null {
      if $istok(* / - + % ^ & $chr(124) << >> == = <= >= < >,%a,32) {
        set -ln %op %a
      }
      elseif %a == $chr(41) {
        set -ln %op $gettok(%opstack,1,32)
        set -ln %opstack $gettok(%opstack,2-,32)
        set -ln %arg $gettok(%argstack,1,32)
        set -ln %argstack $gettok(%argstack,2-,32)
        if %op == $null {
          return
        }
        elseif %op != null {
          set -ln %arg2 %arg1
          omni.z80.a.setarg1 %arg
        }
        else {
          set -ln %op
          set -ln %arg2
        }
      } 
      else {
        return
      }
    }
    else {
      if %a == % {
        set -ln %equ % $+ %equ
      }
      elseif %a == $chr(40) {
        set -ln %argstack %arg1 %argstack
        omni.z80.a.setarg1
        set -ln %opstack %op %opstack
        set -ln %op
      }
      else {
        if $regex(%equ,/^(the )?answer to life $+ $chr(44) $+ ? the universe $+ $chr(44) $+ ? and everything/) {
          set -ln %imm 42
          set -ln %equ $regml(1)
        }
        else {
          set -ln %imm $omni.z80.a.immhandler(%a,%model,%class)
        }
        if %imm == $null {
          return
        }
        if $gettok(%imm,1,32) == equ {
          set -ln %equ ( $omni.z80.a.calc.spaceify($gettok(%imm,2-,32)) ) %equ
          goto start
        }
        set -ln %arg2 %imm
      }
    }
    if %arg2 != $null {
      if $istok(* / - + %,%op,32) {
        if (%op == /) && (%arg2 == 0) {
          return
        }
        omni.z80.a.setarg1 $floor($calc(%arg1 %op %arg2))
      }
      elseif $istok(^ & $chr(124),%op,32) {
        omni.z80.a.setarg1 $(,$+($,$replace(%op,^,xor,&,and,|,or),$chr(40),%arg1,$chr(44),%arg2,$chr(41)))
      }
      elseif $istok(<< >>,%op,32) {
        omni.z80.a.setarg1 $floor($calc(%arg1 * 2 ^ ($iif(%op == >>, -) %arg2)))
      }
      else {
        omni.z80.a.setarg1 $iif(%arg1 %op %arg2,1,0)
      }
      set -ln %op
      set -ln %arg2
    }
  }
  if (%op != $null) || (%arg2 != $null) || (%opstack != $null) || (%argstack != $null) {
    return
  }
  if (%outbase == auto) {
    var %outbase %mainbase
    var %autobase %outbase
    if !%overflow {
      var %modifiers %modifiers signed
    }
  }
  var %arg1 $calc(%arg1 % %max)
  var %arg1 $iif(%arg1 < 0,$calc(%max + %arg1),%arg1)
  if (%outbase == char && (%arg1 < 32 || %arg1 >= 127)) {
    var %outbase 16
  }
  var %exp $findtok(2 4 8 16,%outbase,32)
  if (%outbase == 10) && $istok(%modifiers,signed,32) {
    var %r $iif(%arg1 >= %signedmax,- $+ $calc(%max - %arg1),%arg1)
  }
  else {
    if %exp {
      var %r $base(%arg1,10,%outbase,$ceil($calc(%outbits / %exp)))
    }
    elseif %outbase == char {
      var %r $chr($iif(%arg1 != 32,%arg1,160))
    }
    else {
      var %r $base(%arg1,10,%outbase)
    }
    var %digitsperbyte $calc(8 / %exp)
    if !$istok(%modifiers,big,32) && $istok(8 2,%digitsperbyte,32) {
      var %r2
      var %i 1
      while ($len(%r2) < $len(%r)) {
        var %r2 $mid(%r,%i,%digitsperbyte) $+ %r2
        inc %i %digitsperbyte
      }
      var %r %r2
    }
  }
  return $iif($istok(%modifiers,format,32),$iif(%outbase == 2,% $+ %r,$iif(%outbase == 8,%r $+ o,$iif(%outbase == 16,$ $+ %r,$iif(%outbase == char,' $+ %r $+ ',%r)))),%r) $iif(%autobase,%autobase %iterations)
}
/omni.z80.a.unop {
  var %op $1
  var %arg $2
  if (%op == +) {
    return %arg
  }
  if (%op == -) {
    return $calc(- %arg)
  }
  if (%op == ~) {
    return $calc()
  }
  TODO
}
/omni.z80.a.setarg1 {
  set -n %arg1 $1-
  if (%arg1 >= %signedmax) || (%arg1 <= $calc(-%signedmax)) {
    set %overflow 1
  }
}
/omni.z80.a.bintosigned {
  var %bin $1
  var %bits $iif($2 != $null,$2,$len(%bin))
  var %maxneg $calc(2 ^ ($len(%bin) - 1))
  var %dec $base(%bin,2,10)
  return $iif(%dec >= %maxneg,$calc(%dec - %maxneg * 2),%dec)
}
/omni.z80.a.immhandler {
  tokenize 32 $omni.z80.a.immhandler.main($1,$2,$3)
  if ($1 != equ) {
    if ($abs($1) > %mainbaserank) {
      set %mainbase $2
      set %mainbaserank $abs($1)    
    }
    tokenize 32 $1
  }
  return $1-
}
/omni.z80.a.immhandler.main {
  :start
  if $regex($1,/^([0-9]+)(d)?$/) {
    return $regml(1) 10
  }
  var %bin
  if $left($1,1) == % {
    var %bin $right($1,-1)
  }
  if $right($1,1) === b {
    var %bin $left($1,-1)
  }
  if $regex(%bin,/^[01]{1 $+ $chr(44) $+ 32}$/) {
    return $base(%bin,2,10) 2
  }
  var %hex
  if $left($1,1) == $ {
    var %hex $right($1,-1)
  }
  if $right($1,1) === h && $left($1,1) isnum {
    var %hex $left($1,-1)
  }
  if $regex(%hex,/^[0-9A-Fa-f]{1 $+ $chr(44) $+ 8}$/) {
    return $base(%hex,16,10) 16
  }
  var %oct
  if $left($1,1) == @ {
    var %oct $right($1,-1)
  }
  if $right($1,1) == o {
    var %oct $left($1,-1)
  }
  if $regex(%oct,/^[0-7]+$/) {
    return $base(%oct,8,10) 8
  }
  if $regex($1,/^'.'$/) {
    return $asc($mid($1,2,1)) 16
  }
  if !$regex($1,/^[A-Za-z0-9_]+$/) {
    return
  }
  var %r
  var %i 1
  while (%r == $null) && (%i <= $numtok($omni.z80.includes($2),32)) {
    var %f $omni.file($gettok($omni.z80.includes($2),%i,32),$3)
    var %r $read(%f,ntr,/^[ $+ $chr(9) $+ $chr(32) $+ ]* $+ $1 $+ [ $+ $chr(9) $+ $chr(32) $+ ]+(\.?equ[ $+ $chr(9) $+ $chr(32) $+ ]+|=[ $+ $chr(9) $+ $chr(32) $+ ]*)([^ $+ $chr(9) $+ ;]+)/i))
    inc %i
  }
  if %r != $null {
    return equ $regml(2)
  }
}
/omni.z80.a.ptr {
  if ($left($1,1) != $chr(40)) || ($right($1,1) != $chr(41)) {
    return
  }
  return $left($right($1,-1),-1)
}
/omni.z80.a.port {
  return $omni.z80.a.ptr($1)
}
/omni.z80.a.imm3 {
  var %bin $omni.z80.a.calc($1,$2,2,3)
  return $iif($len(%bin) == 3,%bin)
}
/omni.z80.a.ofs8 {
  var %bin $omni.z80.a.calc($1,$2,2,32,big)
  var %dec $omni.z80.a.bintosigned(%bin)
  if (%dec < -128) || (%dec > 127) {
    return
  }
  return $right(%bin,8)
}
/omni.z80.a.ofs8pc {
  if $1 == $ {
    tokenize 32 $ $+ +0
  }
  if $regex($1,/^\$ *[-+]/) {
    return $omni.z80.a.ofs8(-2 $+ $right($1,-1),$2)
  }
  if $regex($1,/^\+ *\$$/) {
    return $omni.z80.a.ofs8($left($1,-1) $+ -2,$2)
  }
}
/omni.z80.a.imm8 {
  var %bin $omni.z80.a.calc($1,$2,2,8)
  if %bin == $null {
    return
  }
  return $right(%bin,8)
}
/omni.z80.a.imm16 {
  var %bin $omni.z80.a.calc($1,$2,2,$3)
  return %bin
}
/omni.z80.a.rst {
  var %bin $omni.z80.a.calc($1,$2,2,8)
  if !$regex(%bin,/^00(...)000$/) {
    return
  }
  return $regml(1)
}
/omni.z80.a.reg8prefix {
  if $1 == ixh || $1 == ixl {
    return 11011101
  }
  if $1 == iyh || $1 == iyl {
    return 11111101
  }
}
/omni.z80.a.reg8 {
  if $2 != 0 {
    if ($1 == ixh) || ($1 == iyh) {
      return 100
    }
    if ($1 == ixl) || ($1 == iyl) {
      return 101
    }
  }
  var %a $findtok(b_c_d_e_h_l_(hl)_a,$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a - 1),10,2,3)
}
/omni.z80.a.reg8nohl {
  if $1 == (hl) {
    return
  }
  return $omni.z80.a.reg8($1,$2)
}
/omni.z80.a.regiofs8 {
  var %a $1
  var %lp \(
  var %rp \)
  if $3 == 0 {
    var %lp
    var %rp
  }
  if $regsub(%a,/^( $+ %lp $+ (?:ix|iy))( $+ %rp $+ )$/i,\1+0\2,%a) {
    ;intentionally left blank
  }
  if !$regex(%a,/^ $+ %lp $+ (ix|iy) *([+-].+) $+ %rp $+ $ $+ /i) {
    return
  }
  return $iif($regml(1) == ix,11011101,11111101) $omni.z80.a.ofs8($regml(2),$2-)
}
/omni.z80.a.ishlixiy {
  return $iif(($1 == hl) || ($1 == ix) || ($1 == iy),1,0)
}
/omni.z80.a.reg16prefix {
  if $1 == ix {
    return 11011101
  }
  if $1 == iy {
    return 11111101
  }
}
/omni.z80.a.reg16 {
  if $2 != 0 {
    if ($1 == ix) || ($1 == iy) {
      return 10
    }
  }
  var %a $findtok(bc_de_hl_sp,$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a - 1),10,2,2)
}
/omni.z80.a.reg16af {
  if $2 != 0 {
    if ($1 == ix) || ($1 == iy) {
      return 10
    }
  }
  var %a $findtok(bc_de_hl_af,$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a - 1),10,2,2)
}
/omni.z80.a.reg16e {
  var %a $findtok(bc_de_hl_ $+ $iif($2 == 11111101,iy_ix,ix_iy),$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a - 1),10,2,2)
}
/omni.z80.a.cc {
  var %a $findtok(nz_z_nc_c_po_pe_p_m,$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a - 1),10,2,3)
}
/omni.z80.a.ccjr {
  var %a $findtok(nz_z_nc_c,$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a + 4 - 1),10,2,2)
}
/omni.z80.a.alu {
  var %a $findtok(add_adc_sub_sbc_and_xor_or_cp,$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a - 1),10,2,3)
}
/omni.z80.a.rot {
  if $1 == sl1 {
    return 110
  }
  var %a $findtok(rlc_rrc_rl_rr_sla_sra_sll_srl,$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a - 1),10,2,3)
}
/omni.z80.a.bit {
  var %a $findtok(bit_res_set,$1,1,95)
  if %a == $null {
    return
  }
  return $base(%a,10,2,2)
}
/omni.z80.a.im {
  var %a $findtok(0_0/1_1_2,$1,1,95)
  if %a == $null {
    return
  }
  return $base($calc(%a - 1),10,2,3)
}
/omni.z80.a.bli {
  var %a $findtok(ldi_cpi_ini_outi_ldd_cpd_ind_outd_ldir_cpir_inir_otir_lddr_cpdr_indr_otdr,$1,1,95)
  if %a == $null {
    return
  }
  var %a $base($calc(%a - 1),10,2,4)
  return 101 $+ $left(%a,2) $+ 0 $+ $right(%a,2)
}
/omni.z80.a.blie {
  if $1 == . {
    return
  }
  var %a $findtok(._._inim_otim_ini2_._._._._._indm_otdm_ind2_._._._._._inimr_otimr_ini2r_._._._._._indmr_otdmr_ind2r_._._._ldi_cpi_ini_outi_outi2_._._._ldd_cpd_ind_outd_outd2_._._._ldir_cpir_inir_otir_oti2r_._._._lddr_cpdr_indr_otdr_otd2r_._._._._._inirx_otirx_._._._._._._indrx_otdrx,$1,1,95)
  if %a == $null {
    return
  }
  return 1 $+ $base($calc(%a - 1),10,2,7)
}
/omni.z80.color.error {
  return 04
}
/omni.z80.color.op {
  return 02
}
/omni.z80.color.def {
  return 14
}
/omni.z80.color.punct {
  return 01
}
/omni.z80.color.reg {
  return 03
}
/omni.z80.color.imm {
  return 07
}
/omni.z80.color.flag {
  return 05
}
/omni.z80.color.bcall {
  return 07
}
/omni.z80.color.bold {
  return $+(,$replace($1-,$omni.z80.color.punct,$omni.z80.color.punct $+ ),)
}
/omni.axe.check {
  return $regex($2,/^axe(parser)?\b/i)
}
/omni.axe.syntax {

}
/omni.axe.help {

}
/omni.axe {
  var %nick $1
  var %chan $2
  var %target $3-4
  var %errortarget $5-6
  var %command $7
  var %query $8-
  if %query == $null {
    halt
  }
}
/omni.sprite.check {
  return $regex($2,/^sprite\b/i)
}
/omni.sprite.syntax {

}
/omni.sprite.help {

}
/omni.sprite {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %target $4-5
  var %errortarget $6-7
  var %command $8
  set -ln %query $strip($9-)
  if $regex(%query,/\[([0-9A-F]{16})\](\[([0-9A-F]{16})\])?/i) {
    var %sprite $regml(1) $+ $mid($regml(2),2,16)
    var %y 0
    while (%y < 8) {
      var %line
      var %x 0
      while (%x < 8) {
        var %ctop $omni.sprite.getcolor(%sprite,%x,%y)
        var %cbot $omni.sprite.getcolor(%sprite,%x,$calc(%y + 1))
        var %line $+(%line,,%cbot,$chr(44),%ctop,$iif(%ctop == %cbot,█,▄))
        inc %x
      }
      %target $omni.class(SPRITE) $omni.divider %line
      inc %y 2
    }
  }
}
/omni.sprite.getcolor {
  var %sprite $1
  var %x $2
  var %y $3
  var %depth $calc(2 ^ ($len(%sprite) / 16))
  var %r 0
  while (%sprite != $null) {
    var %spritec $left(%sprite,16)
    var %r $calc(%r * 2 + $omni.sprite.getbit(%spritec,%x,%y))
    var %sprite $right(%sprite,-16)
  }
  inc %r
  if (%depth == 2) {
    return $gettok(0 1,%r,32)
  }
  return $gettok(0 15 14 1,%r,32)
}
/omni.sprite.getbit {
  return $iif($mid($base($mid($1,$floor($calc($3 * 2 + $2 / 4 + 1)),1),16,2,4),$calc($2 % 4 + 1),1),1,0)
}
/omni.hexvalidate {
  if $1 == $null {
    return error null
  }
  if $regex($1,/[^0-9A-Fa-f]/) {
    return error invalid
  }
  if $calc($len($1) / 2) != $floor($calc($len($1) / 2)) {
    return error parity
  }
}
/omni.color.check {
  return $regex($2,/^c(olou?r)?\b/i)
}
/omni.color.help {

}
/omni.color {
  var %nick $1
  var %chan $2
  var %omnomirc $3
  var %target $4-5
  var %errortarget $6-7
  var %command $8
  set -ln %query $strip($9-)
  if %query == $null {
    omni.color.help $1-
  }
  tokenize 32 %query
  var %outspacestr $1
  var %outspace $omni.color.space(%outspacestr)
  var %colorquery $2-
  if %outspace == $null {
    %errortarget $omni.class(COLOR) ERROR $omni.divider Unknown colorspace: %outspacestr
    halt
  }
  if $regex($2,/([-=])+>/) {
    var %inspacestr %outspacestr
    var %inspace %outspace
    var %outspacestr $3
    var %outspace $omni.color.space(%outspacestr)
    var %colorquery $4-
    if %outspace == $null {
      %errortarget $omni.class(COLOR) ERROR $omni.divider Unknown colorspace: %outspacestr
      halt
    }
  }
  if ((%inspacestr == RGB24) || (%inspacestr == BGR24) || (%inspacestr == $null)) && $regex(%colorquery,/^(?:#|0x)?([0-9A-F]{6})h?$/i) {
    var %incolor $omni.color.unpack(RGB24,$regml(1))
    if %inspace == $null {
      var %inspacestr RGB24
      var %inspace $omni.color.space(RGB24)
    }
  }
  else if ((%inspacestr == RGB16) || (%inspacestr == BGR16) || (%inspacestr == $null)) && $regex(%colorquery,/^(?:0x)?([0-9A-F]{4})h?$/i) {
    var %incolor $omni.color.unpack(RGB16,$regml(1))
    if %inspacestr == $null {
      var %inspacestr RGB16
      var %inspace $omni.color.space(RGB16)
    }
  }
  else if ((%inspacestr == RGB1555) || (%inspacestr == BGR1555)) && $regex(%colorquery,/^(?:0x)?([0-9A-F]{4})h?$/i) {
    var %incolor $omni.color.unpack(%inspacestr,$regml(1))
    var %inspace $omni.color.space(%inspacestr,1)
  }
  else if ((%inspacestr == xLIBC) || (%inspacestr == $null)) && ($regex(%colorquery,/^([0-9]{1,3})$/i) || $regex(%colorquery,/^(?:0x)?()([0-9A-F]{2})h?$/i)) {
    var %incolor $omni.color.unpack(xLIBC,$iif($regml(1) != $null,$base($regml(1),10,16,2),$regml(2)))
    if %incolor == $omni.color.unpack(xLIBC,57) {
      %errortarget $omni.class(COLOR) ERROR $omni.divider That's transparent, dummy
      halt
    }
    if %inspacestr == $null {
      var %inspacestr xLIBC
    }
    var %inspace $omni.color.space(xLIBC,1)
  }
  else if $regex($remove(%colorquery,$chr(32)),$+(/[,$chr(40),\[{]?([\d]+),$chr(44),([\d]+),$chr(44),([\d]+)[,$chr(41),\]}]?/i)) {
    var %incolor $regml(1) $regml(2) $regml(3)
  }
  else {
    %errortarget $omni.class(COLOR) ERROR $omni.divider Cannot parse color: %colorquery
    halt
  }
  if %inspace == $null {
    %errortarget $omni.class(COLOR) ERROR $omni.divider Cannot determine input colorspace
    halt
  }
  var %i 1
  while %i <= 3 {
    var %c $gettok(%incolor,%i,32)
    var %b $gettok(%inspace,$calc(%i + 3),32)
    if %c > $omni.intmax(%b) {
      %errortarget $omni.class(COLOR) ERROR $omni.divider Value %c outside of %b $+ -bit range
      halt
    }
    inc %i
  }
  var %outcolor $omni.color.convert(%incolor,%inspace,%outspace)
  var %similarity $calc($omni.color.similarity(%incolor,%inspace,%outcolor,$omni.color.space(%outspace,1)) * 100)
  %target $omni.class(COLOR) $omni.color.tostring(%inspacestr,%incolor) ==> $omni.color.tostring(%outspacestr,%outcolor) $+ $iif(%similarity != 100,$chr(44) %similarity $+ % similar)
}
/omni.color.convert {
  var %incolor $1
  var %inspace $2
  var %outspace $3
  ;echo -s incolor %incolor
  ;echo -s inspace %inspace
  ;echo -s outspace %outspace
  if (%outspace == xLIBC) {
    var %bestsim 0
    var %i 0
    while %i < 256 {
      if (%i != 87) {
        var %xcolor $omni.color.unpack(xLIBC,$base(%i,10,16,2))
        var %sim $omni.color.similarity(%incolor,%inspace,%xcolor,R G B 5 6 5)
        if %sim > %bestsim {
          var %bestsim %sim
          var %bestxcolor %xcolor
        }
      }
      inc %i
    }
    return %bestxcolor
  }
  var %rgb1555 $iif(%outspace == RGB1555,1,0)
  var %bgr1555 $iif(%outspace == BGR1555,1,0)
  var %xgx1555 $iif(%rgb1555 || %bgr1555,1,0)
  if %xgx1555 {
    var %outspace $omni.color.space(%outspace,1)
  }
  var %depthinreal $gettok(%inspace,7,32)
  var %depthoutreal $gettok(%outspace,7,32)
  var %outcolor
  var %i 1
  while %i <= 3 {
    var %iin $findtok(%inspace,$gettok(%outspace,%i,32),32)
    var %cin $gettok(%incolor,%iin,32)
    var %depthin $gettok(%inspace,$calc(%iin + 3),32))
    if (%depthinreal > %depthin) {
      var %cin $omni.color.msbtolsb(%cin,%depthin,%depthinreal)
      var %depthin %depthinreal
    }
    var %maxin $omni.intmax(%depthin)
    var %depthout $gettok(%outspace,$calc(%i + 3),32)
    var %depthoutextra $calc(%depthoutreal - %depthout)
    var %maxout $omni.intmax($iif(%depthoutextra <= 0,%depthout,%depthoutreal))
    var %c $calc(%cin * %maxout / %maxin)
    if (%depthoutextra <= 0) {
      var %c $round(%c,0)
    }
    else {
      var %c1 $round($calc(%c / (2 ^ %depthoutextra)),0)
      var %c1x $omni.color.msbtolsb(%c1,%depthout,%depthoutreal)
      var %c2 $calc(%c1 + $iif(%c1x <= %c,1,-1))
      var %c2x $omni.color.msbtolsb(%c2,%depthout,%depthoutreal)
      var %c $iif($abs($calc(%c - %c1x)) < $abs($calc(%c - %c2x)),%c1,%c2)
    }
    var %outcolor %outcolor %c
    inc %i
  }
  return %outcolor
}
/omni.color.msbtolsb {
  if ($2 >= $3) {
    return $1
  }
  var %n $calc($3 - $2)
  var %x $calc($1 * (2 ^ %n))
  var %n $2
  while ($3 > %n) {
    var %x $calc(%x + $floor($calc(%x / (2 ^ %n))))
    var %n $calc(%n * 2)
  }
  return %x
}
/omni.color.similarity {
  var %space R G B 16 16 16
  var %c1 $omni.color.convert($1,$2,%space)
  var %c2 $omni.color.convert($3,$4,%space)
  ; http://www.compuphase.com/cmetric.htm
  ; A low-cost approximation
  var %r1 $gettok(%c1,1,32)
  var %r2 $gettok(%c2,1,32)
  var %rx $calc((%r1 + %r2) / 2 / 65535)
  var %dr $calc(%r1 - %r2)
  var %dg $calc($gettok(%c1,2,32) - $gettok(%c2,2,32))
  var %db $calc($gettok(%c1,3,32) - $gettok(%c2,3,32))
  var %dc $calc((((2 + %rx) * %dr * %dr) + (4 * %dg * %dg) + ((3 - %rx) * %db * %db)) ^ 0.5)
  return $calc((196605 - %dc) / 196605)
}
/omni.color.tostring {
  var %space $1
  var %colors $2
  var %list $chr(123)
  var %i 1
  while %i <= 3 {
    var %list %list $+ $iif(%i != 1,$chr(44) $+ $chr(32)) $+ $gettok(%colors,%i,32)
    inc %i
  }
  var %list %list $+ $chr(125)
  var %packed $omni.color.pack(%space,%colors)
  return %space $+ : $iif((%space == xLIBC) || (%space == RGB1555) || (%space == BGR1555),0x $+ %packed,%list $iif(%packed != $null,$chr(40) $+ 0x $+ %packed $+ $chr(41)))
}
/omni.color.pack {
  tokenize 32 $1-
  if ($1 == RGB24) || ($1 == BGR24) || ($1 == RGB888) || ($1 == BGR888) {
    return $base($2,10,16,2) $+ $base($3,10,16,2) $+ $base($4,10,16,2)
  }
  if ($1 == RGB16) || ($1 == BGR16) || ($1 == RGB565) || ($1 == BGR565) {
    return $base($calc(($2 * 64 + $3) * 32 + $4),10,16,4)
  }
  if ($1 == RGB1555) || ($1 == BGR1555) {
    return $base($calc(((($3 % 2) * 32 + $2) * 32 + $floor($calc($3 / 2))) * 32 + $4),10,16,4)
  }
  if ($1 == xLIBC) {
    return $base($calc(($3 * 32 + $4) % 256),10,16,2)
  }
}
/omni.color.unpack {
  if ($1 == xLIBC) {
    tokenize 32 RGB16 $2 $+ $2
  }
  var %c $base($2,16,10)
  if ($1 == RGB24) || ($1 == BGR24) {
    return $floor($calc(%c / 65536)) $floor($calc((%c % 65536) / 256)) $calc(%c % 256)
  }
  if ($1 == RGB16) || ($1 == BGR16) {
    return $floor($calc(%c / 2048)) $floor($calc((%c % 2048) / 32)) $calc(%c % 32)
  }
  if ($1 == RGB1555) || ($1 == BGR1555) {
    var %i $floor($calc(%c / 32768))
    return $floor($calc((%c % 32768) / 1024)) $calc($floor($calc((%c % 1024) / 32)) * 2 + %i) $calc(%c % 32)
  }
}
/omni.color.space {
  if $1 == xLIBC {
    return $iif($2,R G B 5 6 5,xLIBC)
  }
  if ($1 == RGB1555) || $regex($1,/^1[-:]5[-:]5[-:]5$/) {
    return $iif($2,R G B 5 6 5 6,RGB1555)
  }
  if ($1 == BGR1555) {
    return $iif($2,B G R 5 6 5 6,BGR1555)
  }
  if $regex($1,/^(?:(R)(G)(B)|(B)(G)(R))(15|16|24)$/i) {
    var %b $floor($calc($regml(4) / 3))
    return $upper($regml(1) $regml(2) $regml(3)) %b $iif($regml(4) == 16,6,%b) %b
  }
  if $regex($1,/^(\d+)[-:](\d+)[-:](\d+)$/) {
    return R G B $regml(1) $regml(2) $regml(3)
  }
  if (R isin $1) && (G isin $1) && (B isin $1) {
    if $regex($1,/^(.)\s*(.)\s*(.)\s*(\d)\s*(\d)\s*(\d)$/i) {
      return $upper($regml(1) $regml(2) $regml(3)) $regml(4) $regml(5) $regml(6)
    }
    if $regex($1,/^(.)\s*(\d+)\s*(.)\s*(\d+)\s*(.)\s*(\d+)$/i) {
      return $upper($regml(1) $regml(3) $regml(5)) $regml(2) $regml(4) $regml(6)
    }
  }
}
/omni.color.tospace {
  ; currently unused alias
  tokenize 32 $1-
  var %colors $remove($1-3,$chr(32))
  var %nums $remove($4-6,$chr(32))
  if (%colors == RGB) || (%colors == BGR) {
    if %nums == 565 {
      return %colors $+ 16
    }
    else if %nums == 888 {
      return %colors $+ 24
    }
  }
  var %out
  var %i 1
  while %i <= 3 {
    var %out %out $+ $mid(%colors,%i,1) $+ $mid(%nums,%i,1)
    inc %i
  }
  return %out
}
/omni.intmax {
  return $calc(2 ^ ($1-) - 1)
}
/tmp {
  var %i 1
  var %f $omni.file(colors.txt,ez80)
  var %f2 $omni.file(colors_rgb332.txt,ez80)
  var %l $lines(%f)
  while %i <= $lines(%f) {
    var %r $read(%f,%i)
    if $left(%r,1) == @ {
      omni.color . . . write %f2 echo . %r
    }
    else {
      write %f2 %r
    }
    inc %i
  }
}
