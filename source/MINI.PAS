program MINI;
  { Copyright (c)02.12.1990 by Thomas Much }

  uses crt,dos,printer;

  const dsmax   = 99;
        psmax   = 99;
        version = 1.3;

  var ot                    : array [1..psmax] of byte;
      at                    : array [1..psmax] of integer;
      ds                    : array [1..dsmax] of real;
      tx                    : array [1..psmax] of string[66];
      cstat,pstat,ubreak    : boolean;
      cerr,lcom,bzr,schritt : integer;
      workfile              : string;
      workf                 : text;
      ac                    : real;
      tstat                 : byte;
      pdata                 : searchrec;


function exist(path : string) : boolean;

  begin
    findfirst(path,0,pdata);
    if doserror=0 then exist:=true
      else exist:=false;
  end;


function left(teil : string; anz : byte) : string;

  begin
    left:=copy(teil,1,anz);
  end;


function right(teil : string; anz : byte) : string;

  begin
    if anz>length(teil) then anz:=length(teil);
    right:=copy(teil,succ(length(teil)-anz),anz)
  end;


function space(anz : byte) : string;
  var sdummy : string;
      sc     : byte;

  begin
    sdummy:='';
    if anz>0 then for sc:=1 to anz do sdummy:=sdummy+' ';
    space:=sdummy;
  end;


procedure bildschirm(wo : integer);
  var q : integer;

  begin
    for q:=1 to 22 do
      begin
        gotoxy(3,succ(q));
        write((q+wo):3);
        gotoxy(12,succ(q));
        write(tx[q+wo],space(67-length(tx[q+wo])));
      end;
  end;


procedure editor;
  var q,cadr,oben : integer;
      taste       : char;
      cpos        : byte;

  begin
    clrscr;
    gotoxy(1,1);
    write('Adr.(PS)   Befehl                                            <Esc> - Men');
    for q:=1 to 22 do
      begin
        gotoxy(3,succ(q));
        write(q:3);
        gotoxy(12,succ(q));
        write(tx[q]);
      end;
    cadr:=1;
    oben:=0;
    gotoxy(12,2);
    write(tx[1]);
    gotoxy(12,2);
    cpos:=0;
    repeat
      taste:=readkey;
      if keypressed then
        begin
          taste:=#0;
          case readkey of
            #82: begin
                   for q:=psmax downto succ(oben+cadr) do tx[q]:=tx[pred(q)];
                   tx[oben+cadr]:='';
                   bildschirm(oben);
                   cpos:=0;
                 end;
            #73: if oben>0 then
                   begin
                     dec(oben,20);
                     if oben<0 then oben:=0;
                     bildschirm(oben);
                     if cpos>length(tx[oben+cadr]) then cpos:=length(tx[oben+cadr]);
                   end
                 else
                   begin
                     cadr:=1;
                     if cpos>length(tx[oben+cadr]) then cpos:=length(tx[oben+cadr]);
                   end;
            #81: if oben<psmax-22 then
                   begin
                     inc(oben,20);
                     if oben>psmax-22 then oben:=psmax-22;
                     bildschirm(oben);
                     if cpos>length(tx[oben+cadr]) then cpos:=length(tx[oben+cadr]);
                   end
                 else
                   begin
                     cadr:=22;
                     if cpos>length(tx[oben+cadr]) then cpos:=length(tx[oben+cadr]);
                   end;
            #75: if cpos>0 then dec(cpos);
            #77: if cpos<length(tx[oben+cadr]) then inc(cpos);
            #71: cpos:=0;
            #79: cpos:=length(tx[oben+cadr]);
            #72: if (oben+cadr)>1 then
                   begin
                     dec(cadr);
                     if cadr<1 then
                       begin
                         dec(oben);
                         cadr:=1;
                         bildschirm(oben);
                       end;
                     if cpos>length(tx[oben+cadr]) then cpos:=length(tx[oben+cadr]);
                   end;
            #80: if (oben+cadr)<psmax then
                   begin
                     inc(cadr);
                     if cadr>22 then
                       begin
                         inc(oben);
                         cadr:=22;
                         bildschirm(oben);
                       end;
                     if cpos>length(tx[oben+cadr]) then cpos:=length(tx[oben+cadr]);
                   end;
            #83: if cpos<length(tx[oben+cadr]) then
                   begin
                     tx[oben+cadr]:=left(tx[oben+cadr],cpos)+right(tx[oben+cadr],pred(length(tx[oben+cadr])-cpos));
                     gotoxy(12,succ(cadr));
                     write(tx[oben+cadr],' ');
                     cstat:=false;
                   end;
          end;
          gotoxy(12+cpos,succ(cadr));
        end
      else
        begin
          case taste of
             #8: begin
                   if cpos>0 then
                     begin
                       dec(cpos);
                       tx[oben+cadr]:=left(tx[oben+cadr],cpos)+right(tx[oben+cadr],length(tx[oben+cadr])-succ(cpos));
                       gotoxy(12,succ(cadr));
                       write(tx[oben+cadr],' ');
                       gotoxy(12+cpos,succ(cadr));
                       cstat:=false;
                     end;
                   taste:=#0;
                 end;
            #13: begin
                   if (oben+cadr)<psmax then
                     begin
                       inc(cadr);
                       if cadr>22 then
                         begin
                           inc(oben);
                           cadr:=22;
                           bildschirm(oben);
                         end;
                       if cpos>length(tx[oben+cadr]) then cpos:=length(tx[oben+cadr]);
                       gotoxy(12+cpos,succ(cadr));
                     end;
                   taste:=#0;
                 end;
            #25: begin
                   for q:=(oben+cadr) to pred(psmax) do tx[q]:=tx[succ(q)];
                   tx[psmax]:='';
                   bildschirm(oben);
                   if cpos>length(tx[oben+cadr]) then cpos:=length(tx[oben+cadr]);
                   gotoxy(12+cpos,succ(cadr));
                   taste:=#0;
                 end;
          end;
          if (taste<>#0) and (taste<>#27) then
            if cpos<66 then
              begin
                tx[oben+cadr]:=left(left(tx[oben+cadr],cpos)+taste+right(tx[oben+cadr],length(tx[oben+cadr])-cpos),66);
                gotoxy(12,succ(cadr));
                write(tx[oben+cadr]);
                inc(cpos);
                gotoxy(12+cpos,succ(cadr));
                cstat:=false;
              end;
        end;
    until taste=#27;
  end;


procedure status_prnt;

  begin
    clrscr;
    write('Programmablauf von ',workfile,'        Protokoll: ');
    if pstat then write('on') else write('off');
    write('    Trace: ');
    case tstat of
      0: writeln('off');
      1: writeln('on');
      2: writeln('B.Sim');
    end;
    writeln;
  end;


procedure bzr_ot_scr;

  begin
    case ot[bzr] of
       1: write('READ ');
       2: write('WRIT ');
       3: write('ADD+ ');
       4: write('SUB- ');
       5: write('MUL* ');
       6: write('DIV/ ');
       7: write('LADE ');
       8: write('STOR ');
       9: write('GOTO ');
      10: write('GO.0 ');
      11: write('GO.P ');
      12: write('END. ');
    end;
  end;


procedure trace_check;
  var dummy : char;
      q     : byte;

  begin
    if pstat then
      begin
        write(lst,'      ');
        if schritt<10 then write(lst,' ');
        write(lst,schritt,'  ');
        if bzr<10 then write(lst,' ');
        write(lst,bzr,'  ');
        case ot[bzr] of
           1: write(lst,'READ ');
           2: write(lst,'WRIT ');
           3: write(lst,'ADD+ ');
           4: write(lst,'SUB- ');
           5: write(lst,'MUL* ');
           6: write(lst,'DIV/ ');
           7: write(lst,'LADE ');
           8: write(lst,'STOR ');
           9: write(lst,'GOTO ');
          10: write(lst,'GO.0 ');
          11: write(lst,'GO.P ');
          12: write(lst,'END. ');
        end;
        if at[bzr]<10 then write(lst,'0');
        write(lst,at[bzr],ac:7:1,'  ');
        for q:=1 to 7 do write(lst,ds[q]:5:1,' ');
        if ot[bzr] in [1,2] then write(lst,' ',ds[at[bzr]]:5:1);
        writeln(lst);
      end;
    if tstat>0 then
      begin
        if ot[bzr]>2 then writeln;
        write('#');
        if schritt<10 then write('0');
        write(schritt,' PS[');
        if bzr<10 then write('0');
        write(bzr,']  ');
        bzr_ot_scr;
        if at[bzr]<10 then write('0');
        write(at[bzr],ac:7:1,'<AC> ');
        for q:=1 to 7 do write(ds[q]:5:1,' ');
        if tstat<>2 then if readkey=#27 then ubreak:=true;
        writeln;
      end;
    if tstat=2 then
      begin
        writeln;
        writeln('  Befehl holen:');
        writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
        write('         1.Schritt:  PAR    <- ');
        if bzr<10 then write('0');
        writeln(bzr);
        write('         2.Schritt:  BR     <- ');
        bzr_ot_scr;
        if at[bzr]<10 then write('0');
        writeln(at[bzr]);
        write('         3.Schritt:  BZR    <- ');
        if bzr<9 then write('0');
        writeln(succ(bzr));
        writeln;
        writeln('  Befehl ausfhren:');
        writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
        write('         4.Schritt:  DEC    <- ');
        bzr_ot_scr;
        writeln;
        case ot[bzr] of
           1: begin
                write('         5.Schritt:  DAR    <- ');
                if at[bzr]<10 then write('0');
                writeln(at[bzr]);
                write('         6.Schritt:  DS[');
                if at[bzr]<10 then write('0');
                writeln(at[bzr],'] <- ',ds[at[bzr]]:0:1,' (E/A)');
              end;
           2: begin
                write('         5.Schritt:  DAR    <- ');
                if at[bzr]<10 then write('0');
                writeln(at[bzr]);
                writeln('         6.Schritt:  E/A    <- ',ds[at[bzr]]:0:1);
              end;
           3..6: begin
                   write('         5.Schritt:  DAR    <- ');
                   if at[bzr]<10 then write('0');
                   writeln(at[bzr]);
                   writeln('         6.Schritt:  HR     <- ',ds[at[bzr]]:0:1);
                   writeln('         7.Schritt:  AC     <- ',ac:0:1);
                 end;
           7: begin
                write('         5.Schritt:  DAR    <- ');
                if at[bzr]<10 then write('0');
                writeln(at[bzr]);
                writeln('         6.Schritt:  AC     <- ',ac:0:1);
              end;
           8: begin
                write('         5.Schritt:  DAR    <- ');
                if at[bzr]<10 then write('0');
                writeln(at[bzr]);
                write('         6.Schritt:  DS[');
                if at[bzr]<10 then write('0');
                writeln(at[bzr],'] <- ',ac:0:1);
              end;
           9: begin
                write('         5.Schritt:  DAT    <- ');
                if at[bzr]<10 then write('0');
                writeln(at[bzr]);
                write('         6.Schritt:  BZR    <- ');
                if at[bzr]<10 then write('0');
                writeln(at[bzr]);
              end;
          10: begin
                if ac=0 then
                  begin
                    write('         5.Schritt:  DAT    <- ');
                    if at[bzr]<10 then write('0');
                    writeln(at[bzr]);
                    write('         6.Schritt:  BZR    <- ');
                    if at[bzr]<10 then write('0');
                    writeln(at[bzr]);
                  end;
              end;
          11: begin
                if ac>0 then
                  begin
                    write('         5.Schritt:  DAT    <- ');
                    if at[bzr]<10 then write('0');
                    writeln(at[bzr]);
                    write('         6.Schritt:  BZR    <- ');
                    if at[bzr]<10 then write('0');
                    writeln(at[bzr]);
                  end;
              end;
        end;
        writeln;
        if ot[bzr]<>12 then
          begin
            if readkey=#27 then ubreak:=true else status_prnt;
          end;
      end;
    inc(schritt);
  end;


procedure prozessor;
  label errjmp;

  var q : integer;

  begin
    status_prnt;
    if pstat then
      begin
        write(lst,'      '#27'-1'#27'4Programm-Ablaufprotokoll '#27'E',workfile,#27'F'#27'-0');
        writeln(lst,#27'5     <Turbo-MINI/R v',version:0:1,'>');
        writeln(lst,#27'S1      Nr  PS  OT   AT    AC   DS:01    02    03    04    05    06    07    I/O'#27'T');
      end;
    for q:=1 to dsmax do ds[q]:=0;
    bzr:=1;
    ac:=0;
    schritt:=1;
    ubreak:=false;
    repeat
      case ot[bzr] of
        0: inc(bzr); { NOP !!! }
        1: begin
             write('DS[',at[bzr],']= ');
             readln(ds[at[bzr]]);
             trace_check;
             if tstat=1 then writeln;
             inc(bzr);
           end;
        2: begin
             writeln('DS[',at[bzr],']=',ds[at[bzr]],'  (',ds[at[bzr]]:0:2,')');
             trace_check;
             if tstat=1 then writeln;
             inc(bzr);
           end;
        3: begin
             ac:=ac+ds[at[bzr]];
             trace_check;
             inc(bzr);
           end;
        4: begin
             ac:=ac-ds[at[bzr]];
             trace_check;
             inc(bzr);
           end;
        5: begin
             ac:=ac*ds[at[bzr]];
             trace_check;
             inc(bzr);
           end;
        6: if at[bzr]=0 then
             begin
               writeln;
               writeln('Division durch Null in PS[',bzr,'].');
               goto errjmp;
             end
           else
             begin
               ac:=ac/ds[at[bzr]];
               trace_check;
               inc(bzr);
             end;
        7: begin
             ac:=ds[at[bzr]];
             trace_check;
             inc(bzr);
           end;
        8: begin
             ds[at[bzr]]:=ac;
             trace_check;
             inc(bzr);
           end;
        9: begin
             trace_check;
             bzr:=at[bzr];
           end;
       10: begin
             trace_check;
             if ac=0 then bzr:=at[bzr] else inc(bzr);
           end;
       11: begin
             trace_check;
             if ac>0 then bzr:=at[bzr] else inc(bzr);
           end;
      end;
      if keypressed then if readkey=#27 then ubreak:=true;
    until (ot[bzr]=12) or (ubreak);
    if not(ubreak) then trace_check;
    errjmp:
    writeln;
    writeln;
    if ubreak then write('   User Break in PS[',bzr,'].') else write('   OK.');
    readln;
  end;


procedure assemble;
  label kommjmp;

  var cadr,bis,c  : integer;
      dummy,cmd   : string;
      spos,q,kpos : byte;
      atval       : longint;
      gefunden    : boolean;

  begin
    bis:=1;
    for c:=1 to psmax do if length(tx[c])>0 then bis:=c;
    cadr:=1;
    cerr:=1;
    cstat:=false;
    repeat
      gotoxy(5,20);
      writeln('Assembling line ',cadr,' ...');
      dummy:=tx[cadr];
      while left(dummy,1)=' ' do dummy:=right(dummy,pred(length(dummy)));
      while right(dummy,1)=' ' do dummy:=left(dummy,pred(length(dummy)));
      if (left(dummy,1)=';') or (length(dummy)=0) then
        begin
          ot[cadr]:=0;
          at[cadr]:=0;
          goto kommjmp;
        end;
      spos:=pos(' ',dummy);
      if spos=0 then cerr:=-1
      else
        begin
          cmd:=left(dummy,pred(spos));
          for q:=1 to length(cmd) do cmd[q]:=upcase(cmd[q]);
          dummy:=right(dummy,length(dummy)-spos);
          while left(dummy,1)=' ' do dummy:=right(dummy,pred(length(dummy)));
          kpos:=pos(';',dummy);
          if kpos>0 then
            begin
              dummy:=left(dummy,pred(kpos));
              while right(dummy,1)=' ' do dummy:=left(dummy,pred(length(dummy)));
            end
          else
            if pos(' ',dummy)>0 then
              begin
                cerr:=-9;
                goto kommjmp;
              end;
          if length(dummy)=0 then
            begin
              cerr:=-1;
              goto kommjmp;
            end;
          atval:=0;
          for q:=1 to length(dummy) do
            if not(dummy[q] in ['0'..'9']) then cerr:=-2
              else atval:=atval*10+ord(dummy[q])-48;
          if cerr=1 then
            begin
              if (((atval<1) or (atval>dsmax)) and (cmd<>'END.')) then cerr:=-3
              else
                begin
                  gefunden:=false;
                  if cmd='READ' then
                    begin
                      ot[cadr]:=1;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='WRIT' then
                    begin
                      ot[cadr]:=2;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='ADD+' then
                    begin
                      ot[cadr]:=3;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='SUB-' then
                    begin
                      ot[cadr]:=4;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='MUL*' then
                    begin
                      ot[cadr]:=5;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='DIV/' then
                    begin
                      ot[cadr]:=6;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='LADE' then
                    begin
                      ot[cadr]:=7;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='STOR' then
                    begin
                      ot[cadr]:=8;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='GOTO' then
                    begin
                      ot[cadr]:=9;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='GO.0' then
                    begin
                      ot[cadr]:=10;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='GO.P' then
                    begin
                      ot[cadr]:=11;
                      at[cadr]:=atval;
                      gefunden:=true;
                    end;
                  if cmd='END.' then
                    begin
                      gefunden:=true;
                      if atval<>0 then cerr:=-5
                      else
                        begin
                          ot[cadr]:=12;
                          at[cadr]:=0;
                          cerr:=0;
                        end;
                    end;
                  if not(gefunden) then cerr:=-4;
                end;
            end;
        end;
      kommjmp:
      inc(cadr);
    until (cadr>bis) or (cerr<1);
    lcom:=pred(cadr);
    if cerr<>0 then
      begin
        gotoxy(5,22);
        write('Fehler ',cerr,' in Zeile ',pred(cadr),': ');
      end;
    case cerr of
       1: write('END. fehlt');
       0: cstat:=true;
      -1: write('Zu wenig Parameter');
      -2: write('AT keine positive ganze Zahl.');
      -3: write('Ungltige Adresse (1..',dsmax,')');
      -4: write('Unbekannter Befehl');
      -5: write('Ungltiger Wert in AT');
      -9: write('";" vor Kommentar fehlt');
    end;
    if cerr<>0 then
      begin
        gotoxy(5,24);
        write('Drcken Sie eine Taste.');
        repeat until keypressed;
      end;
  end;


procedure get_workfile;
  var q     : integer;

  begin
    for q:=1 to psmax do
      begin
        at[q]:=0;
        ot[q]:=0;
        tx[q]:='';
      end;
    gotoxy(5,20);
    write('Workfile name: ');
    readln(workfile);
    if length(workfile)>0 then
      begin
        for q:=1 to length(workfile) do workfile[q]:=upcase(workfile[q]);
        if pos('.',workfile)=0 then workfile:=workfile+'.MAS'
          else if pos('.',workfile)=length(workfile) then workfile:=workfile+'MAS';
        assign(workf,workfile);
        if exist(workfile) then
          begin
            gotoxy(5,22);
            write('Laden: ',workfile,' ...');
            reset(workf);
            q:=1;
            while not eof(workf) do
              begin
                readln(workf,tx[q]);
                inc(q);
              end;
            close(workf);
          end
        else
          begin
            gotoxy(10,22);
            write('New file.');
            delay(1000);
          end;
      end;
    cstat:=false;
  end;


procedure speichern;
  var q,bis : integer;

  begin
    gotoxy(5,20);
    write('Speichern: ',workfile,' ...');
    bis:=1;
    for q:=1 to psmax do if length(tx[q])>0 then bis:=q;
    rewrite(workf);
    for q:=1 to bis do writeln(workf,tx[q]);
    close(workf);
  end;


procedure ausdruck;
  var q,bis : integer;

  begin
    gotoxy(5,20);
    write('Ausdruck ...');
    bis:=1;
    for q:=1 to psmax do if length(tx[q])>0 then bis:=q;
    writeln(lst,'        '#27'-1'#27'4Ausdruck von '#27'E',workfile,#27'F'#27'5'#27'-0');
    writeln(lst,#27'S1        PS   OT    AT'#27'T');
    for q:=1 to bis do writeln(lst,'        ',q:2,':  ',tx[q]);
  end;


procedure directory;
  var fianz : integer;
      dmask : string;

  begin
    clrscr;
    write('Dir mask: ');
    readln(dmask);
    if length(dmask)=0 then dmask:='*.*';
    fianz:=-1;
    findfirst(dmask,0,pdata);
    while (doserror=0) and (fianz<60) do
      begin
        inc(fianz);
        gotoxy(succ((fianz div 20)*25),(fianz mod 20)+3);
        write(pdata.name);
        gotoxy((fianz div 20)*25+15,(fianz mod 20)+3);
        write(pdata.size:6);
        findnext(pdata);
      end;
    if fianz=-1 then
      begin
        writeln;
        writeln('Keine Dateien vorhanden ...');
      end;
    gotoxy(1,24);
    write('Drcken Sie eine Taste.');
    repeat
    until keypressed;
  end;


procedure menu;
  var taste : char;

  begin
    repeat
      clrscr;
      writeln;
      writeln('**************************************************');
      writeln('*   Einadreárechner Turbo-MINI/R Version ',version:0:1,'     *');
      writeln('* mit Real-Arithmetik und integriertem Assembler *');
      writeln('*     Copyright (c)02.12.90 by Thomas Much       *');
      writeln('**************************************************');
      writeln;
      writeln;
      writeln('  (E)dit  (A)ssemble  (R)un    (L)list      (D)irectory');
      writeln;
      write('  (S)ave  (W)orkfile  (Q)uit   (P)rotokoll: ');
      if pstat then write('on') else write('off');
      gotoxy(51,11);
      write('(T)race: ');
      case tstat of
        0: writeln('off');
        1: writeln('on');
        2: writeln('B.Sim');
      end;
      writeln;
      writeln;
      writeln('    Workfile: ',workfile);
      if cstat then
        begin
          gotoxy(36,16);
          write('Lines assembled: ',lcom);
          gotoxy(36,18);
          write('Code in memory is ready to run.');
        end;
      gotoxy(80,25);
      repeat
        taste:=upcase(readkey);
      until taste in ['E','A','R','Q','S','W','L','P','T','D'];
      case taste of
        'E': begin
               if length(workfile)=0 then get_workfile;
               if length(workfile)>0 then editor;
             end;
        'A': if length(workfile)>0 then assemble
             else
               begin
                 get_workfile;
                 if length(workfile)>0 then
                   if exist(workfile) then assemble;
               end;
        'R': if length(workfile)>0 then
               begin
                 if not(cstat) then assemble;
                 if cerr=0 then prozessor;
               end
             else
               begin
                 get_workfile;
                 if length(workfile)>0 then
                   if exist(workfile) then
                     begin
                       assemble;
                       if cerr=0 then prozessor;
                     end;
               end;
        'S': if length(workfile)>0 then speichern;
        'W': get_workfile;
        'P': pstat:=not(pstat);
        'L': if length(workfile)>0 then ausdruck;
        'T': begin
               inc(tstat);
               if tstat>2 then tstat:=0;
             end;
        'D': directory;
      end;
    until taste='Q';
    clrscr;
  end;


begin
  workfile:='';
  cstat:=false;
  pstat:=false;
  tstat:=0;
  menu;
end.
