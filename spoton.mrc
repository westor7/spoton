;Welcome to SpotOn mIRC Addon. Since this is only in beta.
;You could not do so much. I'm not a good MSL coder, so this is the result in beta.
;
; Spoton v1.0.7 is supported since this beta release.



menu menubar {
  SpotOn $+([,$replace($dll($spfind,status,0),0,Not Running,1,Paused,2,Advertisement,3,Playing),])
  .Menu
  ..Open Menu:spssh | dialog -m sps sps
  ..Says:spotwin
  .-
  .Control
  ..Play:/dll spoton.dll play
  ..Pause:/dll spoton.dll pause
  ..Next:/dll spoton.dll next
  ..Previous:/dll spoton.dll prev
}

menu channel {
  SpotOn $+([,$replace($dll($spfind,status,0),0,Not Running,1,Paused,2,Advertisement,3,Playing),])
  .Menu
  ..Open Menu:spssh | dialog -m sps sps
  ..Says:spotwin
  .-
  .Control
  ..Play:/dll spoton.dll play
  ..Pause:/dll spoton.dll pause
  ..Next:/dll spoton.dll next
  ..Previous:/dll spoton.dll prev
  .-
  .Say:snp
}


dialog sps {
  title ""
  size -1 -1 187 64
  option dbu
  box "", 1, 1 0 185 53
  edit "", 2, 3 39 180 11, autohs return
  icon 3, 4 53 180 12,  spssh.bmp, 0, noborder
  text "", 4, 5 7 111 30
  button "Save", 5, 152 7 29 10, flat disable
  button "List", 6, 152 21 29 10, flat disable
}


on *:dialog:sps:*:*:{
  if ($devent == init) {
    dialog -t $dname SpotOn
    did -a $dname 4 $spfrmx
    if ($lines(says.txt) > 0) { did -e $dname 6 }
    if (%saythis) {
      spssh %saythis 
      did -ra $dname 2 %saythis | did -e $dname 5
    }
  }
  if ($devent == sclick) {
    if ($did == 5) {
      if (!$read(says.txt, w, * $+ $did(2))) {
        set %saythis $did(2)
        var %line = $iif($lines(says.txt) == 0,1,$calc($v1 +1))
        write says.txt %line $+ $chr(144) $+ $did(2)
      }
      else { noop $input(The Say is already in the list!,ow,SpotOn,2) | set %saythis $did(2) }
      did -e $dname 6
    }
    if ($did == 6) { $iif($window(@saylist) != $null,window -c @saylist,spotwin) }
    if ($did == 3) { did -r $dname 2 | spssh }
  }
  if ($devent == edit) {
    if ($did == 2) {
      if ($len($did(2)) > 0) { spssh $did(2) }
      if ($len($did(2)) >= 5) { did -e $dname 5 }
      elseif ($len($did(2)) < 5) { did -b $dname 5 }
      elseif ($len($did(2)) == 0) { spssh }
      did -f $dname 2
    }
  }
  if ($devent == close) { window -c @spss | window -c @saylist }
}


;Generate Image into the tool
alias -l spssh {
  if ($1- != $null) {
    clear @spss
    var %ttext = $1-
    var %tfont = tahoma, %tsize = 11
    window -dBk0pw0h +dL @spss -1 -1 360 15
    drawfill -r @spss $rgb(face) $rgb(face) 0 0
    drawrect -rf @spss $rgb(face) 1 $calc($width(%ttext,%tfont,%tsize,0,1) + 3) 0 360 15
    drawtext -pb @spss $color(text) $color(background) %tfont %tsize 2 1 %ttext
    drawrect -r @spss $color(text) 1 0 0 $calc($width(%ttext,%tfont,%tsize,0,1) + 3) 15
  }
  else {
    clear @spss
    window -dBk0pw0h +dL @spss -1 -1 360 15
    drawrect -rf @spss $rgb(face) 1 0 0 360 15
  }
  drawsave @spss spssh.bmp
  $iif($dialog(sps) != $null,did -g sps 3 spssh.bmp)
  window -c @spss
}

;Add new features from SpotOn
alias -l spfrmx { 
  var %spuyt = [Song] $str($chr(9),2) Shows the Artist - Title $+ $crlf
  ;var %spuyt = %spuyt $+ [Artist] $str($chr(9),2) Shows the Artist $+ $crlf
  ;var %spuyt = %spuyt $+ [Title] $str($chr(9),2) Shows the Title $+ $crlf
  return %spuyt
}

;Generate says into the window
alias -l spotwin {
  if ($lines(says.txt) > 0) {
    clear @saylist
    var %x = $iif($dialog(sps) != $null,$calc($dialog(sps).x + $dialog(sps).w),-1)
    var %y = $iif($dialog(sps) != $null,$dialog(sps).y,-1)
    window -ak0ld $+ $iif($dialog(sps) == $null,C) +L @saylist %x %y 200 200
    var %o = 1
    while (%o <= $lines(says.txt)) {
      aline @saylist $+($chr(2),%o,.,$chr(2),$chr(160),$gettok($read(says.txt,%o),2,144))
      inc %o
    }
  }
  else { set %saythis spotify > [song] }
}

;Select and Remove says.
menu @saylist {
  dclick:{
    if ($sline(@saylist,1) != $null) {
      if ($dialog(sps) != $null) {
        did -ra sps 2 $gettok($sline(@saylist,1),2,160)
        spssh $gettok($sline(@saylist,1),2,160)
        did -e sps 5
      }
      set %saythis $gettok($sline(@saylist,1),2,160)
    }
  }
  Remove:write -dl $+ $sline(@saylists,1).ln says.txt | spotwin
}

;## 0therz ##


;Replace x with SpotOn features.
alias -l spfrm {
  var %f1 = $replace($1-,[song],$dll($spfind,song,0))
  ;var %f2 = $replace(%f1,[artist],$dll($spfind,artist,0))
  ;var %f3 = $replace(%f2,[title],$dll($spfind,title,0))
  return $spc(%f1)
}

;Check if channel have +c (Colors enabled)
alias -l spc {
  if ($left($active,1) == $chr(35)) {
    if (c !isincs $chan(#).mode) { return $1- }
    else { return $strip($1-) }
  }
  else { return $1- }
}

;Checks if spoton.dll exists and return the path
alias -l spfind {
  if ($exists($+($nofile($script),spoton.dll)) == $true) {
    return $+($nofile($script),spoton.dll)
  }
  else { !echo -ag * Can't find the DLL-file. | halt }
}

;If SpotOn is playing a song (Status Code: 3), write out to the channel/pm.
alias snp {
  if ($dll($spfind,status,0) == 3) {
    say $spfrm(%saythis)
  }
  else { !echo -ag * Spotify is $replace($dll($spfind,status,0),0,Not running,1,Paused,2,Playing Advertisement) | halt }
}

;Setup everything that is needed when loaded.
on *:load:{
  set %saythis Spotify » [song]
  spssh
  !echo -ag Spoton is loaded!
}

on *:unload:{
  unset %saythis
  remove spssh.bmp
  !echo -ag SpotOn is now unloaded!
}
