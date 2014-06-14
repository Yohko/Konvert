UNIT Meine;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Unit with usefull functions
// by Patrick Hoffmann, eMail: Patrick.Hoffmann@T-Online.de, Patrick.Hoffmann@TU-Cottbus.de
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

INTERFACE

 USES SysUtils;

 FUNCTION DateiExist(Datei:TFileName):BOOLEAN;

 FUNCTION DateiExistNotEmpty(Datei:TFileName):BOOLEAN;

 FUNCTION DateiNameGueltig(Datei:TFileName):BOOLEAN;

 FUNCTION AllesGross(InStr:STRING):STRING;

 FUNCTION HexToWord(H:STRING):WORD;

 FUNCTION WordToHex(W:WORD):STRING;

 FUNCTION UpCaseString(Org:STRING):STRING;

 PROCEDURE FSplit(Datei:TFileName; VAR D,N,E:STRING);

 FUNCTION EntferneAlleLeerzeichen(Quelle:STRING):STRING;

IMPLEMENTATION

 FUNCTION DateiExist(Datei:TFileName):BOOLEAN;

 VAR F:FILE;

 BEGIN
  IF Length(Datei) < 1 THEN Datei :=  ' ';
  AssignFile(F,Datei);
  {$I-}
  Reset(F);
  {$I+}
  IF IOResult = 0 THEN
   BEGIN
    DateiExist := TRUE;
    CloseFile(F);
   END
  ELSE DateiExist := FALSE;
 END;

 FUNCTION DateiExistNotEmpty(Datei:TFileName):BOOLEAN;
 VAR F:FILE;
 BEGIN
  DateiExistNotEmpty:=false;
  IF Length(Datei) < 1 THEN Datei :=  ' ';
  AssignFile(F,Datei);
  {$I-}
  Reset(F);
  {$I+}
  IF IOResult = 0 THEN
   BEGIN
    if filesize(F)>0 then DateiExistNotEmpty := TRUE;
    CloseFile(F);
   END;
 END;

 FUNCTION DateiNameGueltig(Datei:TFileName):BOOLEAN;
 VAR F:FILE;
 BEGIN
  IF NOT DateiExist(Datei) THEN
   BEGIN
    AssignFile(F,Datei);
    {$I-}
    REWRITE(F);
    {$I+}
    IF IOResult <> 0 THEN
     BEGIN
      DateiNameGueltig := FALSE;
      EXIT;
     END
    ELSE
     BEGIN
      CloseFile(F);
      Erase(F);
     END;{IF}
   END;{IF}
  DateiNameGueltig := TRUE;
 END;

 FUNCTION AllesGross(InStr:STRING):STRING;
 VAR A:BYTE;
 BEGIN
  FOR A := 1 TO LENGTH(InStr) DO InStr[A] := UpCase(InStr[A]);
  AllesGross := InStr;
 END;

 FUNCTION HexToWord(H:STRING):WORD;

 VAR
  A,B   :BYTE;
  P,Z   :WORD;

 BEGIN
  H := AllesGross(H);
  Z := 0;
  P := 1;
  FOR A := LENGTH(H) DOWNTO 1 DO
   BEGIN
    B := ORD(H[A])-48;
    IF B>9 THEN B := B - 7;
    IF B>15 THEN B := 0;
    Z := Z + B * P;
    P := P * 16;
   END;{FOR}
  HexToWord := Z;
 END;

 FUNCTION WordToHex(W:WORD):STRING;

 CONST
  HexZiffern :ARRAY [0..15] OF CHAR = (#48,#49,#50,#51,#52,#53,#54,#55,#56,#57,#65,#66,#67,#68,#69,#70);

 VAR
  Zw:STRING;

 BEGIN
  Zw := '';
  WHILE W > 0 DO
   BEGIN
    Zw := HexZiffern[W MOD 16] + Zw;
    W :=  W DIV 16;
   END;{WHILE}
  IF Zw = '' THEN WordToHex := '0'
             ELSE WordToHex := Zw;
 END;

 FUNCTION UpCaseString(Org:STRING):STRING;

  VAR
   I :BYTE;

  BEGIN
   FOR I := 1 TO LENGTH(Org) DO
    CASE Org[I] OF
     'Ñ':Org[I] := 'é';
     'î':Org[I] := 'ô';
     'Å':Org[I] := 'ö';
     ELSE Org[I] := UpCase(Org[I]);
    END;{CASE}
   UpCaseString := Org;
  END;

 PROCEDURE FSplit(Datei:TFileName; VAR D,N,E:STRING);

  VAR
   Zw,
   Zw2 :BYTE;

  BEGIN
   D := '';
   E := '';
   N := '';
   IF Datei = '' THEN EXIT;
   Zw2 := LENGTH(Datei);
   {WHILE (Datei[Zw2] <> '.') AND (Zw2 > 0) DO DEC(Zw2); alter Code zum Finden des Punktes von hinten um die Erweiterung herauszufiltern / macht aber Probleme, wenn es keine Erweiterung gibt und der Pfad einen Punkt enth‰lt !}
   WHILE (Datei[Zw2] <> '.') AND (Datei[Zw2] <> '\') AND (Zw2 > 0) DO DEC(Zw2);
   IF Datei[Zw2] = '\' THEN Zw2 := 0; {Falls kein Punkt vor dem letzten \ gefunden wird, steht zw2 auf diesem Zeichen. Dann muss ich Zw2 auf 0 setzten, um ein Nicht-Finden der Erweiterung anzuzeigen} 
   IF Zw2 <> 0 THEN E := COPY(Datei,Zw2+1,LENGTH(Datei)-Zw2);
   IF Zw2 = 0 THEN Zw := LENGTH(Datei)
              ELSE Zw := Zw2;
   WHILE (Datei[Zw] <> '\') AND (Zw > 0) DO DEC(Zw);
   IF Zw2= 0 THEN N := COPY(Datei,Zw+1,LENGTH(Datei)-Zw) {es gibt keine Erweiterung !}
             ELSE N := COPY(Datei,Zw+1,Zw2-Zw-1);
   D := COPY(Datei,1,Zw-1);
  END;

 FUNCTION EntferneAlleLeerzeichen(Quelle:STRING):STRING;
  VAR I:INTEGER;
  BEGIN
   I := 1;
   WHILE (I > 0) AND (I <= LENGTH(Quelle)) DO
    IF Quelle[I] = #32 THEN DELETE(Quelle,I,1)
                       ELSE INC(I);
   EntferneAlleLeerzeichen := Quelle;
  END;
  
END.
