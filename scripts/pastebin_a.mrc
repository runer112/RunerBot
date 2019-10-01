/pastebin {
  ;;;;;;;;; SWITCHES ;;;;;;;;;;
  ; -u  User key
  ; -n  Name
  ; -f  Format
  ; -p  Privacy
  ; -x  Expiration
  ;;;; REQUIRED PARAMETERS ;;;;
  ;     Developer API Key
  ;     File to upload (in quotation marks)
  ;     Operation to call with result
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tokenize 32 $1-
  var %switches
  var %userkey
  var %name
  var %format
  var %privacy
  var %expiration
  if -* iswm $1 {
    var %switches $right($1,-1)
    tokenize 32 $2-
  }
  while %switches != $null {
    if $1 == $null {
      echo 2 * /pastebin: insufficient parameters
      halt
    }
    var %s $left(%switches,1)
    var %switches $right(%switches,-1)
    if %s == u {
      if $regex($1,/[^0-9A-Fa-f]/) {
        echo 2 * /pastebin: invalid user key $1
        halt
      }
      var %userkey $+(api_user_key=,$1,&)
    }
    elseif %s == n {
      var %name $+(api_paste_name=,$encodeurl($1),&)
    }
    elseif %s == f {
      if !$istok(4cs 6502acme 6502kickass 6502tasm abap actionscript actionscript3 ada algol68 apache applescript apt_sources asm asp autoconf autohotkey autoit avisynth awk bascomavr bash basic4gl bibtex blitzbasic bnf boo bf c c_mac cil csharp cpp cpp-qt c_loadrunner caddcl cadlisp cfdg chaiscript clojure klonec klonecpp cmake cobol coffeescript cfm css cuesheet d dcs delphi oxygene diff div dos dot e ecmascript eiffel email epc erlang fsharp falcon fo f1 fortran freebasic freeswitch gambas gml gdb genero genie gettext go groovy gwbasic haskell hicest hq9plus html4strict html5 icon idl ini inno intercal io j java java5 javascript jquery kixtart latex lb lsl2 lisp llvm locobasic logtalk lolcode lotusformulas lotusscript lscript lua m68k magiksf make mapbasic matlab mirc mmix modula2 modula3 68000devpac mpasm mxml mysql newlisp text nsis oberon2 objeck objc ocaml-brief ocaml pf glsl oobas oracle11 oracle8 oz pascal pawn pcre per perl perl6 php php-brief pic16 pike pixelbender plsql postgresql povray powershell powerbuilder proftpd progress prolog properties providex purebasic pycon python q qbasic rsplus rails rebol reg robots rpmspec ruby gnuplot sas scala scheme scilab sdlbasic smalltalk smarty sql systemverilog tsql tcl teraterm thinbasic typoscript unicon uscript vala vbnet verilog vhdl vim visualprolog vb visualfoxpro whitespace whois winbatch xbasic xml xorg_conf xpp yaml z80 zxbasic,$1,32) {
        echo 2 * /pastebin: invalid format $1
        halt
      }
      var %format $+(api_paste_format=,$lower($1),&)
    }
    elseif %s == p {
      if !$istok(0 1 2,$1,32) {
        echo 2 * /pastebin: invalid privacy boolean $1
        halt
      }
      var %privacy $+(api_paste_private=,$1,&)
    }
    elseif %s == x {
      if !$istok(N 10M 1H 1D 1M,$1,32) {
        echo 2 * /pastebin: invalid expiration $1
        halt
      }
      var %expiration $+(api_paste_expire_date=,$upper($1),&)
    }
    else {
      echo 2 * /pastebin: invalid switch - $+ %s
      halt
    }
    tokenize 32 $2-
  }
  if $2 == $null {
    echo 2 * /pastebin: insufficient parameters
    halt
  }
  if $regex($1,/[^0-9A-Fa-f]/) {
    echo 2 * /pastebin: invalid dev key $1
    halt
  }
  var %devkey $+(api_dev_key=,$1,&)
  tokenize 32 $2-
  if !$regex(pastebin,$1-,/^("[^"]+")/) {
    echo 2 * /pastebin: malformed file path
    halt
  }
  if !$exists($regml(pastebin,1)) {
    echo 2 * /pastebin: no such file $regml(pastebin,1)
    halt
  }
  if $gettok($gettok($1-,2-,$asc(")),1-,32) == $null {
    echo 2 * /pastebin: insufficient parameters
    halt
  }
  var %sockname
  while (%sockname == $null) || ($sock(%sockname) != $null) {
    var %sockname $+(pastebin.,$rand(1,999999999999))
  }
  sockopen %sockname pastebin.com 80
  sockmark %sockname $+(%userkey,%name,%format,%privacy,%expiration,%devkey,api_option=paste&api_paste_code=) $1-
}
/pastebin.return {
  .timer $+ $1 off
  $sock($1).mark $2-
  sockclose $1
}
/encodeurl {
  return $regsubex($1-,/([ !"#$%&'()*,/:;<=>?@[\]^`{|}~ $+ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ])/g,% $+ $base($asc(\1),10,16))
}
