LIBRARY Konv_DLL;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Konvert-Tool for Converting Spectra (Omicron) and Phoibos (Specs) into ORIGIN®
// by Patrick Hoffmann, eMail: Patrick.Hoffmann@T-Online.de, Patrick.Hoffmann@TU-Cottbus.de
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

{%ToDo 'Konv_DLL.todo'}

uses
  SysUtils,
  Forms,
  Windows,
  KonvU1 in 'KonvU1.pas' {HauptFenster},
  KonvU2 in 'KonvU2.pas' {InfoFenster},
  KonvU4 in 'KonvU4.pas' {StatusFenster},
  KonvU5 in 'KonvU5.pas' {OptionenFenster},
  HKKeep in 'HKKEEP.PAS',
  Meine in 'Meine.pas';

{$R *.RES}

 FUNCTION DOKONVERT(Wnd:hWnd; InputWert:PChar):INTEGER; stdcall;{Name der Funktion MUSS groß geschrieben werden, sonst kann sie ORIGIN nicht importieren !!!}

  VAR
   D, N, E  :STRING;

  BEGIN
   ORIGIN_Wnd := Wnd;
   ORIGINCall := TRUE;
   FSplit(Application.ExeName,D,N,E);
   Application.Initialize;
   Application.Handle := Origin_Wnd; {Macht das KONVERT-Fenster zu einem Fenster von Origin}
   Application.CreateForm(THauptFenster, HauptFenster);
  Application.CreateForm(TInfoFenster, InfoFenster);
  Application.CreateForm(TStatusFenster, StatusFenster);
  Application.CreateForm(TOptionenFenster, OptionenFenster);
  LadeIniFile;
    {Formular auf den Aufrruf aus ORIGIN heraus vorbereiten}
    HauptFenster.CB_Origin.Checked := TRUE;
    HauptFenster.CB_Origin.Enabled := FALSE;
    HauptFenster.IL_ExportName.Text := Application.ExeName;{hier muss ein gültiger Pfad angegeben werden, weil ja hierher die Log-Datei gespeichert wird !}
    HauptFenster.IL_ExportName.Enabled := FALSE;
    HauptFenster.BT_ExportName.Enabled := FALSE;
    HauptFenster.BT_Exit.Caption := 'Return to Origin ...';
   Application.HelpFile := 'Konvert.HLP';
   Application.Run;
   DoKonvert := 0;
  end;


 FUNCTION IMPORTASCII(Wnd:hWnd; InputWert:PChar):INTEGER; stdcall;{Name der Funktion MUSS groß geschrieben werden, sonst kann sie ORIGIN nicht importieren !!!}
  {Da Origin6.1 nicht in der Lage ist, auf einem deutschen System ASCII-Dateien zu importieren,
   die als Dezimalzeichen einen Punkt haben (Origin nimmt immer an, es muss ein Komma sein !),
   habe ich diese Funktion implementiert. Sie öffnet eine Datei, deren Namen in InputWert
   übergeben wurde, ändert alle "."-Zeichen in ","-Zeichen um, speichert die Datei unter
   gleichem Namen, allerdings mit vorangestelltem '_' (damit falls aus dem Origin-Verzeichnis importiert werden
   soll, ich nicht die Originaldatei überschreibe) aber im Origin-Vereichnis und kehrt wieder zurück mit dem
   Rückgabewert 0, falls alles Ok war}

  VAR
   InFile,
   OutFile     :TextFile;
   OutFileName,
   D,N,E,
   D2,N2,E2,
   TmpS,
   Zeile       :STRING;
   ReturnValue,
   I           :INTEGER;

  CONST
   KommentarZeichen:CHAR = '%';

  LABEL
   Ende;

  PROCEDURE ReadLnUNIX(VAR F:TextFile; VAR S:STRING);
   VAR Ch:CHAR;
   BEGIN
    S := '';
    IF EOF(F) THEN EXIT;
    Read(F,Ch);
    WHILE (NOT EOF(F)) AND (Ch <> #10) AND (Ch <> #13) DO
     BEGIN
      IF Ch=#9 THEN Ch := #32; {Manchmal hat der Tabulatot Probleme gemacht, weswegen ich den in ein Leerzeichn umwandle}
      S := S + Ch; {IF (Ch<>#13 THEN S := S + Ch;}
      Read(F,Ch);
     END;{WHILE}
   END;

  BEGIN
   ReturnValue := 0;
   {Zunächst Werte setzen, die in der UNIT KonvU1 gebracuht werden}
   ORIGIN_Wnd := Wnd;
   ORIGINCall := TRUE;
   {Öffnen der Eingabe-Datei}
   AssignFile(InFile,STRING(InputWert));
   {$I-}
   ReSet(InFile);
   {$I-}
   IF IOResult <> 0 THEN
    BEGIN
     MessageBox(Wnd,'Could not open Import-File !','ERROR ...',mb_IconError);
     ReturnValue := 1;
     GOTO Ende;
    END;
   {Feststellen des Pfades, des Dateinamens und der Erweiterung der Eingabedatei}
   FSplit(TFileName(InputWert),D,N,E);
   FSplit(Application.ExeName,D2,N2,E2);
   IF E<>'' THEN E := '.' + E; {Damit nur bei vorhandener Erweiterung der Punkt mit angefügt wird}
   OutFileName := D2 + '\_' + N + E; {Das vorangestellte '_' wird ORIGIN ignorieren, aber es verhindert, dass beim Importieren aus dem Origin-Verzeichnis die Originaldatei überschrieben wird}
                                                    {Die Copy-Funktion am Anfang ist wichtig, um den Laufwerksbuchstaben der Festplatte zu bekommen. Bei Win-XP ist das nämlich nicht zwangsläufig c: !!!}
   {Öffnen der Ausgabe-Datei}
   AssignFile(OutFile,OutFileName);
   {$I-}
   ReWrite(OutFile);
   {$I-}
   IF IOResult <> 0 THEN
    BEGIN
     OutFileName := 'Could not create temporary Importfile: ' + OutFileName + #0;
     MessageBox(Wnd,@OutFileName[1],'ERROR ...',mb_IconError);
     ReturnValue := 2;
     GOTO Ende;
    END;
   {Jede Zeile einlesen, Punkte durch Kommas ersetzen und Zeile in Ausgabedatei schreiben}
   WHILE NOT EOF(InFile) DO
    BEGIN
     {$I-}
     ReadLnUNIX(InFile,Zeile);
     {$I-}
     IF IOResult <> 0 THEN
      BEGIN
       MessageBox(Wnd,'Could not read from importfile !','ERROR ...',mb_IconError);
       ReturnValue := 3;
       GOTO Ende;
      END;
     {Alle Punkte durch Kommas ersetzen}
     FOR I := 1 TO LENGTH(Zeile) DO IF Zeile[I] = '.' THEN Zeile[I] := ',';
     Zeile := Zeile + KommentarZeichen; {Damit ist sichergestellt, dass falls kein Kommentarzeichen in der Zeile stand, POS nicht 0 liefert und die gesamte ursprüngliche Zeile kopiert wird}
     Zeile := COPY(Zeile,1,POS(KommentarZeichen,Zeile)-1);
     {$I-}
     IF Zeile <> '' THEN WriteLn(OutFile,Zeile); {Sollte das Kommentarzeichen das erste Zeichen in der Zeile gewesen sein, dann gar keine Leerzeile schreiben}
     {$I-}
     IF IOResult <> 0 THEN
      BEGIN
       MessageBox(Wnd,'Could not write to temporary Importfile in C:\ !','ERROR ...',mb_IconError);
       ReturnValue := 4;
       GOTO Ende;
      END;
    END;{WHILE}
   CloseFile(OutFile);
   CloseFile(InFile);
   {Import durchführen}
   IF SendToOrigin('open -w ' + OutFileName + ';') <> 0 THEN
    BEGIN
     MessageBox(Wnd,'Could not import temporary Importfile from C:\ !','ERROR ...',mb_IconError);
     ReturnValue := 5;
     GOTO Ende;
    END;
   {temporäre Ausgabedatei löschen}
   OutFileName := OutFileName + #0;
   IF NOT DeleteFile(@OutFileName[1]) THEN
    BEGIN
     MessageBox(Wnd,'Could not delete temporary Importfile in C:\ !','ERROR ...',mb_IconError);
     ReturnValue := 6;
     GOTO Ende;
    END
   ELSE ReturnValue := 0;
   ENDE:
   IMPORTASCII := ReturnValue;
  END;


 FUNCTION IMPORTEMP(Wnd:hWnd; InputWert:PChar):INTEGER; stdcall;{Name der Funktion MUSS groß geschrieben werden, sonst kann sie ORIGIN nicht importieren !!!}
  {Zum Importieren von EMP-Text-Dateien mit X-Achse !}

  VAR
   InFile,
   OutFile     :TextFile;
   OutFileName,
   D,N,E,
   D2,N2,E2,
   TmpS,
   Zeile       :STRING;
   ReturnValue,
   I,
   TmpI,
   StartText,
   AnzahlYSpalten :INTEGER;
   SpaltenName  :ARRAY [1..16] OF STRING; {mehr als 16 Spalten kann EMP eh nicht messen}

  CONST
   KommentarZeichen:CHAR = '%';
   EMPMarkerDevices:STRING = 'DEVICES';   {Groß-Schreibung ist wichtig, da alles Eingelesene in Großbuchstaben gewandelt wird}
   EMPMarkerData:STRING = 'BEGIN';
   EMPMarkerDataEnd:STRING = 'END';

  LABEL
   Ende;

  PROCEDURE ReadLnUNIX(VAR F:TextFile; VAR S:STRING);
   {Diese Funktion hat einen Mangel: Sie liefert oft zu viele Leerzeilen !  Wird nämlich eine Zeile mit #10#13 abgeschlossen, so liest ReadLnUNIX nur bis zum #10. Das nächste Lesen liefert eine Leerzeile, weil der Zeiger ja auf #13 stand. Es geht leider nicht anders, weil ich nach dem Erreichen von #10 oder #13 nicht einfach weiterlesen darf, denn wenn ein anderes Zeichen kommt, dann habe ich den Dateizeiger eins weiter geschoben und kann ihn (weil es eine Textdatei ist) nicht wieder eins zurückschieben !}
   VAR Ch:CHAR;
   BEGIN
    S := '';
    IF EOF(F) THEN EXIT;
    Read(F,Ch);
    WHILE (NOT EOF(F)) AND (Ch <> #10) AND (Ch <> #13) DO
     BEGIN
      IF Ch=#9 THEN Ch := #32; {Manchmal hat der Tabulator Probleme gemacht, weswegen ich den in ein Leerzeichn umwandle}
      S := S + Ch; {IF (Ch<>#13 THEN S := S + Ch;}
      Read(F,Ch);
     END;{WHILE}
   END;

  BEGIN
   ReturnValue := 0;
   {Zunächst Werte setzen, die in der UNIT KonvU1 gebracuht werden}
   ORIGIN_Wnd := Wnd;
   ORIGINCall := TRUE;
   {Öffnen der Eingabe-Datei}
   AssignFile(InFile,STRING(InputWert));
   {$I-}
   ReSet(InFile);
   {$I-}
   IF IOResult <> 0 THEN
    BEGIN
     MessageBox(Wnd,'Could not open Import-File !','ERROR ...',mb_IconError);
     ReturnValue := 1;
     GOTO Ende;
    END;
   {Feststellen des Pfades, des Dateinamens und der Erweiterung der Eingabedatei}
   FSplit(TFileName(InputWert),D,N,E);
   FSplit(Application.ExeName,D2,N2,E2);
   IF E<>'' THEN E := '.' + E; {Damit nur bei vorhandener Erweiterung der Punkt mit angefügt wird}
   OutFileName := D + '\_' + N + E; {Das vorangestellte '_' wird ORIGIN ignorieren, aber es verhindert, dass die Originaldatei überschrieben wird}
                                    {NEU: Ich importiere nicht aus dem Origin-Verzeichnis, sondern aus dem Verzeichnis, wo die Datei liegt.}
                                                    {Die Copy-Funktion am Anfang ist wichtig, um den Laufwerksbuchstaben der Festplatte zu bekommen. Bei Win-XP ist das nämlich nicht zwangsläufig c: !!!}
   {Öffnen der Ausgabe-Datei}
   IF DateiExist(OutFileName) THEN
    BEGIN
     MessageBox(Wnd,'Temporary Output file already exists. Try renaming your file and import again ...','ERROR ...',mb_IconError);
     ReturnValue := 7;
     GOTO Ende;
    END;
   AssignFile(OutFile,OutFileName);
   {$I-}
   ReWrite(OutFile);
   {$I-}
   IF IOResult <> 0 THEN
    BEGIN
     OutFileName := 'Could not create temporary Importfile: ' + OutFileName + #0;
     MessageBox(Wnd,@OutFileName[1],'ERROR ...',mb_IconError);
     ReturnValue := 2;
     GOTO Ende;
    END;
   {Jede Zeile einlesen, Punkte durch Kommas ersetzen und Zeile in Ausgabedatei schreiben}
   WHILE NOT EOF(InFile) DO
    BEGIN
     {$I-}
     ReadLnUNIX(InFile,Zeile);
     {$I-}
     IF IOResult <> 0 THEN
      BEGIN
       MessageBox(Wnd,'Could not read from importfile !','ERROR ...',mb_IconError);
       ReturnValue := 3;
       GOTO Ende;
      END;
     {Nun auf die Schlüsselworte in der EMP-Datei lauschen}
     {Spaltennamen auslesen ################################################################################################################################################}
     IF UpcaseString(COPY(Zeile,1,LENGTH(EMPMarkerDevices))) = EMPMarkerDevices THEN
      BEGIN
       StartText := 1;
       AnzahlYSpalten := 0;
       REPEAT
        INC(AnzahlYSpalten);
        StartText := 1;
        WHILE (Zeile[StartText] <> '=') AND (StartText <= LENGTH(Zeile)) DO INC(StartText); {Das '=' suchen, danach sollte der Name der Spalte beginnen}
        INC(StartText);  {1 Zeichen hinter dem = beginnt der eigentliche Text}
        TmpS := '';
        TmpI := StartText;
        WHILE (Zeile[TmpI] <> ',') AND (TmpI <= LENGTH(Zeile)) DO {Bis zum nächsten Komma steht der Name des Gerätes}
         BEGIN
          IF Zeile[TmpI] <> ',' THEN TmpS := TmpS + Zeile[TmpI];
          INC(TmpI);
         END;{WHILE}
        {Nun sollte der Spaltenname der (AnzahlYSpalten). Spalte in TmpS stehen}
        SpaltenName[AnzahlYSpalten] := TmpS;
        REPEAT {Wird eine Zeile mit #10#13 abgeschlossen, so liest ReadLnUNIX nur bis zum #10. Das nächste Lesen liefert eine Leerzeile, weil der Zeiger ja auf #13 stand. Deswegen muss ich Leerzeichen hier ignorieren. Es geht leider nicht anders, weil ich nach dem Erreichen von #10 oder #13 nicht einfach weiterlesen darf, denn wenn ein anderes Zeichen kommt, dann habe ich den Dateizeiger eins weiter geschoben und kann ihn (weil es eine Textdatei ist) nicht wieder eins zurückschieben !}
         {$I-}
         ReadLnUNIX(InFile,Zeile);
         {$I-}
         IF IOResult <> 0 THEN
          BEGIN
           MessageBox(Wnd,'Could not read from importfile !','ERROR ...',mb_IconError);
           ReturnValue := 3;
           GOTO Ende;
          END;
        UNTIL (Zeile <> '') OR (EOF(InFile)); {Ich muss lesen, bis keine Leerzeile mehr kommt / siehe Kommentar bei REPEAT}
       UNTIL COPY(Zeile,1,LENGTH(EMPMarkerDevices)) <> StringOfChar(' ',LENGTH(EMPMarkerDevices));
      END;{Spaltennamen auslesen}
     {Daten lesen ################################################################################################################################################}
     IF UpcaseString(COPY(Zeile,1,LENGTH(EMPMarkerData))) = EMPMarkerData THEN
      BEGIN
       REPEAT
        {$I-}
        ReadLnUNIX(InFile,Zeile); {nächste Zeile nach BEGIN auslesen, das müsste die erste Datenzeile sein !}
        {$I-}
        IF IOResult <> 0 THEN
         BEGIN
          MessageBox(Wnd,'Could not read from importfile !','ERROR ...',mb_IconError);
          ReturnValue := 3;
          GOTO Ende;
         END;
        {Alle Punkte durch Kommas ersetzen}
        FOR I := 1 TO LENGTH(Zeile) DO IF Zeile[I] = '.' THEN Zeile[I] := ',';
        Zeile := Zeile + KommentarZeichen; {Damit ist sichergestellt, dass falls kein Kommentarzeichen in der Zeile stand, POS nicht 0 liefert und die gesamte ursprüngliche Zeile kopiert wird}
        Zeile := COPY(Zeile,1,POS(KommentarZeichen,Zeile)-1);
        {$I-}
        IF (Zeile <> '') AND (UpcaseString(COPY(Zeile,1,LENGTH(EMPMarkerDataEnd))) <> EMPMarkerDataEnd) THEN WriteLn(OutFile,Zeile); {Sollte das Kommentarzeichen das erste Zeichen in der Zeile gewesen sein, dann gar keine Leerzeile schreiben}
                                                                                                                                     { ... und auch nx schreiben, wenn das Ende erreicht wurde, also der Zeilenanfang dem EMPMarkerDataEnd entspricht}
        {$I-}
        IF IOResult <> 0 THEN
         BEGIN
          MessageBox(Wnd,'Could not write to temporary Importfile in C:\ !','ERROR ...',mb_IconError);
          ReturnValue := 4;
          GOTO Ende;
         END;
       UNTIL UpcaseString(COPY(Zeile,1,LENGTH(EMPMarkerDataEnd))) = EMPMarkerDataEnd;
      END;{Daten auslesen}
    END;{WHILE}
   CloseFile(OutFile);
   CloseFile(InFile);
   {Import durchführen}
   IF SendToOrigin('open -w ' + OutFileName + ';') <> 0 THEN
    BEGIN
     MessageBox(Wnd,'Could not import temporary Importfile from C:\ !','ERROR ...',mb_IconError);
     ReturnValue := 5;
     GOTO Ende;
    END;
   {Spaltennamen und Label setzen / in N sollte ja noch der Name der Import-Datei stehen}
   SendToOrigin('worksheet -n 1 Energy;'); {erste Spalte Energy nennen}
   SendToOrigin(GetORIGINFormat(N) + '!wks.col1.label$="Energy";'); {Damit setze ich das Label der 1. Spalte auf "Energy"}
   SendToOrigin(GetORIGINFormat(N) + '!wks.labels();'); {Damit schalte ich die Anzeige des Labels ein. Mit "wks.labels(0);" kann ich sie übrigens wieder ausschalten}
   FOR TmpI := 2 TO (AnzahlYSpalten + 1) DO
    BEGIN
     STR(TmpI:1,TmpS);
     SendToOrigin('worksheet -n ' + TmpS + ' ' + GetORIGINFormat(SpaltenName[TmpI-1]) + ';'); {Spaltennamen setzen}
     SendToOrigin(GetORIGINFormat(N) + '!wks.col' + TmpS + '.label$="' + N + ' : ' + SpaltenName[TmpI-1] + '";'); {Damit setze ich das Label der (TmpI-1). Spalte}
    END;{FOR}
   {temporäre Ausgabedatei löschen}
   OutFileName := OutFileName + #0;
   IF NOT DeleteFile(@OutFileName[1]) THEN
    BEGIN
     MessageBox(Wnd,'Could not delete temporary Importfile in C:\ !','ERROR ...',mb_IconError);
     ReturnValue := 6;
     GOTO Ende;
    END
   ELSE ReturnValue := 0;
   ENDE:
   IMPORTEMP := ReturnValue;
  END;


 EXPORTS
  DOKONVERT Index 1,
  IMPORTASCII Index 2,
  IMPORTEMP Index 3;

begin
end.
