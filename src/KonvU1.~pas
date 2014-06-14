UNIT KonvU1;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Konvert-Tool for Converting Spectra (Omicron) and Phoibos (Specs) into ORIGIN®
// by Patrick Hoffmann, eMail: Patrick.Hoffmann@T-Online.de, Patrick.Hoffmann@TU-Cottbus.de
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

INTERFACE


 USES
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles, Meine, KonvU4, HKKeep, Math;


 CONST
  MaxDetektoren = 100;
  MaxWksLabelLength = 60; {Gibt die maximale Stringlänge des zu setztenden Worksheet-Labels an, da bei zu langen Labels Origin immer abstürzt. Ob dieser Wert wirklich die Grenze ist, weiß ich nicht !!!}
  MaxColNameLength = 10; {Eigentlich sind ja 11 Zeichen als Namen für eine Spalte erlaubt, aber bei dem Kommando "worksheet -n 2 AsIntroduxm" nennt er die Spalte nur "asintrodux" ! Aber auch nur, wenn das Kommando von der DLL ausgeführt wird ! Hinterpfurziges Origin !!!}


 TYPE
  PWert = ^TWert;
  TWert = RECORD
           Counts :REAL;
           Next   :PWert;
          END;{RECORD}

  TChannelArray = ARRAY [1..MaxDetektoren] OF REAL;
  PChannel = ^TChannel; {Hier werden die einzelnen Channeltrons gespeichert, wenn einzel-Channeltron-Auswertung gefordert ist}
  TChannel = RECORD
           CH   :TChannelArray;
           Next :PChannel;
          END;{RECORD}

  PDWordListe  = ^TDWordListe;
{  TDWordListe  = ARRAY[0..0] OF DWORD;   }
  TDWordListe  = ARRAY OF DWORD;   {neu###}

  PADCChannel = ^TADCChannel;
  TADCChannel = RECORD
                 ChannelName  :STRING; {Der Name, der in SpecsLab eingegeben wurde}
                 Start,
                 Delta        :DOUBLE;
                 Length       :LongInt;
                 AktOutWert,          {dient als Zwischenspeicher, z.B. TRegionORIGINCall.Exportieren benutzt ihn, sollte sonst immer auf NIL stehen}
                 Werte        :PWert; {Wurzelzeiger auf die Liste mit den eingelesenen ADC-Werten für diesen Kanal}
                 NextChannel  :PADCChannel; {Falls noch weitere ADC-Kanäle eingelesen wurden}
                END;{RECORD}

  TRegion = CLASS
   RegionName        :STRING;
   Start,
   Ende,
   Schrittweite,
   Scans,
   Torzeit,
   Messpunkte,
   EPass,
   ExEnergie         :REAL;
   Werte             :PWert;
   ChanneltronEinzeln:BOOLEAN; {Ist TRUE wenn die Challentrons einzeln ausgegeben werden sollen. Macht zwar erst ab dem XML-Import Sinn, aber hier implementiere ich die Exportroutine und muss es dehalb schon hier vorsehen.}
   ADCChannel        :PADCChannel; {Beim XML-Import werden hier die ADC-Werte gespeichert, wenn vorhanden. Muss schon in diesem Objekt sein, weil hier die Export-Routine implementiert ist}
   Channels          :PChannel; {Hier werden die einzelnen Channeltrons gespeichert, wenn einzel-Channeltron-Auswertung gefordert ist. Macht erst ab XML-Import Sinn !}
   NrDetektoren      :WORD;   {Gibt die Anzahl der verwendeten Channeltrons an / eigentlich wird es erst beim Phoibos-XML-Import gebraucht, aber da ich es schon in der Export-Routine bei TRegioanORIGINCall brauche, habe ich es in hierher verschoben}
   NextRegion        :TRegion;
   ScanMode          :INTEGER;{Hier wird gespeichert, in welchem ScanMode (also Fixed Energy oder Fixed Analyser Transmission, usw.) gemessen wurde | Wir eigentlich erst im XML-Import gebraucht, muss ich aber wg. dem Abfragen in der Export-Routine schon hier definieren| Standardwert ist FixedAnalyserTransmission}
   CONSTRUCTOR Create;
   FUNCTION Importieren(VAR F:TEXT):INTEGER; VIRTUAL;
   PROCEDURE Exportieren(VAR F:TEXT); VIRTUAL;
   FUNCTION GetInfoString:STRING; {gibt eine Info-String mit Regiondaten aus}
   DESTRUCTOR Free;
  END;

  TRegionORIGIN = CLASS(TRegion)
   CONSTRUCTOR Create;
   PROCEDURE Exportieren(VAR F:TEXT); OVERRIDE;
  END;

  TRegionORIGINCall = CLASS(TRegion)
   DetectorVoltage   :REAL;{Enthält die Detektor-Spannung. Brauche ich zur Berechnung der X-Achse beim Detector-Voltage-Scan. Muss ich schon in dieser Klasse deklarieren !}
   DateiName,              {Der Name der Datei, aus der Importiert wird. Wird dem Constructor übergeben}
   RegionNameOnly,         {Da ich ja die Variable RegionName schon missbrauche für die ganzen Region-Informationen, muss ich eine neue nur für den Namen einführen}
   GruppenName    :STRING; {Der Name der Gruppe, eigentlich nur wichtig, bei Specs-Import}
   CONSTRUCTOR Create(DName,GroupName:STRING);
   PROCEDURE Exportieren(VAR F:TEXT); OVERRIDE; {Die Variable F ist hier nur noch drinne, weil ich sie ja nicht aus einer virtuellen Methgode herausstreichen kann !!!}
  END;

  TRegionORIGINCallPHOIBOS = CLASS(TRegionORIGINCall)
   CONSTRUCTOR Create(DName,GroupName:STRING);
   FUNCTION Importieren(VAR F:TEXT):INTEGER; OVERRIDE;
  END;

  TRegionORIGINCallPHOIBOS_XML = CLASS(TRegionORIGINCallPHOIBOS)
   AnzahlCounts      :DWORD;   { ### Matthias edit wird -->dword, Gibt die Anzahl der tatsächlich gemessenen Counts an. Ist etwas größer als Messpunkte*NrDetektoren, weil ja am Anfang und Ende etwas Überschnitt gemessen werden muss !}
   DetektorShift     :ARRAY [1..MaxDetektoren] OF DOUBLE;
   CountListe        :PDWordListe; {Hier werden die Counts in der Reihenfolge, wie sie in der XML-Datei gespeichert sind, reingeschrieben und bei mehreren Scans aufsummiert}
   CONSTRUCTOR Create(DName, GroupName:STRING; CHEinzeln:BOOLEAN);
   FUNCTION Importieren(VAR F:TEXT):INTEGER; OVERRIDE;
  END;


  TExperiment = CLASS
   AnzahlRegionen  :WORD;
   ExperimentName  :STRING;
   Regionen        :TRegion;
   CONSTRUCTOR Create;
   FUNCTION Importieren(DateiName:STRING):INTEGER; VIRTUAL;
   FUNCTION Exportieren(ImportDatei,ExportDatei:STRING; VAR ErzeugteDateien:TStrings):INTEGER; VIRTUAL;
   DESTRUCTOR Free;
  END;

  TExperimentORIGIN = CLASS(TExperiment)
   FUNCTION Importieren(DateiName:STRING):INTEGER; OVERRIDE;
   FUNCTION Exportieren(ImportDatei,ExportDatei:STRING; VAR ErzeugteDateien:TStrings):INTEGER; OVERRIDE;
  END;

  TExperimentORIGINCall = CLASS(TExperiment)
   FUNCTION Importieren(DateiName:STRING):INTEGER; OVERRIDE;
   FUNCTION Exportieren(ImportDatei,ExportDatei:STRING; VAR ErzeugteDateien:TStrings):INTEGER; OVERRIDE;
  END;

  TExperimentORIGINCallPHOIBOS = CLASS(TExperimentORIGINCall)
   FUNCTION Importieren(DateiName:STRING):INTEGER; OVERRIDE;
  END;

  TExperimentORIGINCallPHOIBOS_XML = CLASS(TExperimentORIGINCallPHOIBOS)
   FUNCTION Importieren(DateiName:STRING):INTEGER; OVERRIDE;
  END;

  THauptFenster = class(TForm)
    OpenDialog1: TOpenDialog;
    IL_ImportName: TEdit;
    Label1: TLabel;
    BT_ImportName: TButton;
    IL_ExportName: TEdit;
    BT_ExportName: TButton;
    Label2: TLabel;
    BT_Konvertieren: TButton;
    BT_SaveIni: TButton;
    BT_Exit: TButton;
    CB_DivScans: TCheckBox;
    BT_Alles: TButton;
    CB_Origin: TCheckBox;
    CB_DivLifeTime: TCheckBox;
    SaveDialog1: TOpenDialog;
    CB_ExtraSpalte: TCheckBox;
    BT_Options: TButton;
    CB_NormiereExtraSpalte: TCheckBox;
    Memo1: TMemo;
    CB_EnableMovingSizing: TCheckBox;
    GBDataSource: TGroupBox;
    RBDataSource_Spectra: TRadioButton;
    RBDataSource_Phoibos: TRadioButton;
    RBDataSource_PhoibosXML: TRadioButton;
    procedure BT_ImportNameClick(Sender: TObject);
    procedure BT_ExportNameClick(Sender: TObject);
    procedure BT_SaveIniClick(Sender: TObject);
    procedure BT_KonvertierenClick(Sender: TObject);
    procedure BT_ExitClick(Sender: TObject);
    procedure BT_AllesClick(Sender: TObject);
    procedure cb_ExtraSpalte_KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cb_Origin_KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CB_ExtraSpalte_Click(Sender: TObject);
    procedure BT_OptionsClick(Sender: TObject);
    procedure CB_EnableMovingSizingClick(Sender: TObject);
    procedure RBDataSource_SpectraClick(Sender: TObject);
    procedure RBDataSource_PhoibosClick(Sender: TObject);
    procedure RBDataSource_PhoibosXMLClick(Sender: TObject);
  private
    { Private-Declaration }
  public
    { Public-Deklarationen }
  end;

var
  ORIGIN_Wnd             :hWnd; {Handle auf das ORIGIN-Fenster. Nur gültig, wenn auch ORIGINCall=True ist !!!}
  ORIGINCall             :BOOLEAN = FALSE; {Wird auf TRUE gesetzt, falls das Programm als DLL aus ORIGIN heraus aufgerufen wird}
  HauptFenster           :THauptFenster;
  GlobalImportErrorStr,
  IniImportVerzeichnis,
  IniExportVerzeichnis,
  AktDATFileName         :STRING; {gibt den Namen des zu exportierenden DAT-Files an; wird wärend TRegionORIGIN.Export zum generieren des Worksheet-Namens benutzt}
  IgnoriereAlleLeerenYCurves, {Wird von TRegionORIGINCallPHOIBOS_XML.Importieren gesetzt, wenn Y-Curve gefunden wurde, die wohl keine ADC-Daten enthält (passiert z.B. wenn die Operation Peak Location in SpecsLab ausgeführt und in der XML-Datei gespeichert wurde}
  IgnoriereAlleLeerenRegionen, {Wird von TRegionORIGINCallPHOIBOS.Importieren und TRegionORIGINCallPHOIBOS_XML.Importieren gesetzt, wenn eine leere Region vorgefunden wird und er in Zukunft alle ignorieren soll}
  MultipleFilesSelected  :BOOLEAN;
  ProgrammOptionen       :RECORD
                           MinStellen           :INTEGER; {Bei 2 wird dann aus Spektrum.1 Spektrum01, bei 3 aus Spektrum.1 Spektrum001 usw}
                           PhotonenEnergie      :REAL; {Gibt die Photonenenergie an, wenn eine feste genommen werden soll}
                           TemplateName,               {enthält nur den Dateinamen (keine Erweiterung und kein Pfad !) des zu verwendenden Templates}
                           TemplateMovingSizing :STRING; {enthält nur den Dateinamen (keine Erweiterung und kein Pfad !) des zu verwendenden Templates für Moving/Sizing}
                           IncludeAnalyserParameter,      {Gibt an, ob ich die Region-Tags (Reginname, Analysatorparameter, ...) als Textfeld in das WorkSheet schreiben soll}
                           ColumnLabel,                   {Gibt an, ob die Information über Quelldatei, Gruppennamen und Regionnamen als Spaltenlabel gesetzt werden soll}
                           WksLabel,                      {Gibt an, ob die Information über Quelldatei, Gruppennamen und Regionnamen als Worksheet-Label gesetzt werden soll}
                           ChanneltronEinzeln,            {Ist TRUE wenn zusätzlich die Counts der einzelnen Channeltrons mit in Worksheet sollen}
                           Interpolieren,                 {FALSE => Counts werden einfach dem an der tatsächlichen Channeltonenergie liegenden Messpunkt voll zugerechnet (Specs-Methode) | TRUE => die Zählrate am Messpunkt wird aus den rechts und links des Messpunkt liegenden Channeltron-Zählraten ermittelt}
                           IncludeADC,                    {Gibt an, ob die ADC-Kanäle, die evtl in der XML-Datei gefunden werden, als Extra-Spalte(n) im WorkSheet mit aufgenommen werden sollen, default=TRUE}
                           EnableMovingSizing   :BOOLEAN; {Wenn TRUR dann wird als Template das genommen, dessen Name in TemplateMovingSizing ist}
                           Woher_hn             :BYTE; {=1 wenn aus der XPS-Datei zu nehmen | =2 wenn festen Wert (PhotonenEnergie) nehmen | =3 wenn bei jedem Spektrum fragen}
                          END;{RECORD}


CONST
 OriginMakroName = 'Org_Imp.TXT';
 ScanMode_FixedTransm = 1;
 ScanMode_FixedEnerg = 2;
 ScanMode_CFS = 3;
 ScanMode_CIS = 4;
 ScanMode_Detector = 5;
 RegionImport_RegionNichtGemessen = 2;
 RegionImport_foundGroup = 91;
 RegionImport_foundRegion = 92;
 RegionImport_foundComment = 93;


FUNCTION GetORIGINFormat(Original:STRING):STRING;
 {Diese Funktion ersetzt alle nicht-ORIGIN-konfomen Zeichen in dem String Original, so wie es auch ORIGIN selbts machen würde, und gibt das Ergebnis zurück}

PROCEDURE LadeIniFile;

PROCEDURE SaveIniFile;

FUNCTION SendToOrigin(ExecString:STRING):INTEGER;

implementation

uses KonvU2, KonvU5;

{$R *.DFM}

 FUNCTION GetORIGINFormat(Original:STRING):STRING;

  VAR
   I    :INTEGER;
   TmpS :STRING;

  CONST
   ORIGINKonform :SET OF CHAR = ['0'..'9', 'A'..'Z','a'..'z'];

  BEGIN
   TmpS := '';
   IF LENGTH(Original) > 0 THEN
    BEGIN
     FOR I := 1 TO LENGTH(Original) DO
      IF Original[I] IN ORIGINKonform THEN TmpS := TmpS + Original[I];
                                      {ELSE TmpS := TmpS + '.'; geht in ORIGIN6 nicht mehr !!!}
     IF ORD(TmpS[1]) < 65 THEN TmpS := 'A' + TmpS; {In ORIGIN müssen Namen immer mit einem Buchstaben (ASCII >= 65) beginnen !}
    END;
   GetORIGINFormat := TmpS;
  END;

 PROCEDURE LadeIniFile;

  VAR
   Code      :INTEGER;
   TmpS      :STRING;
   IniFile   :TIniFile;

  BEGIN
   IniFile := TIniFile.Create('Konvert.Ini'); {muß sich in C:\Windows befinden !!!}
   HauptFenster.RBDataSource_Spectra.Checked := IniFile.ReadBool('ProgrammOptionen','DataSourceSpectra',TRUE);
   HauptFenster.RBDataSource_Phoibos.Checked := IniFile.ReadBool('ProgrammOptionen','DataSourcePhoibos',FALSE);
   HauptFenster.RBDataSource_PhoibosXML.Checked := IniFile.ReadBool('ProgrammOptionen','DataSourcePhoibosXML',FALSE);
   {Wenigstens einer von den Knöpfen sollte aber ausgewählt sein :}
   IF NOT (HauptFenster.RBDataSource_Spectra.Checked OR HauptFenster.RBDataSource_Phoibos.Checked OR HauptFenster.RBDataSource_PhoibosXML.Checked) THEN HauptFenster.RBDataSource_Spectra.Checked := TRUE;
   IniImportVerzeichnis := IniFile.ReadString('ProgrammOptionen','ImportVerzeichnis','C:\Anwender\');
   IniExportVerzeichnis := IniFile.ReadString('ProgrammOptionen','ExportVerzeichnis','C:\Anwender\');
   ProgrammOptionen.MinStellen := IniFile.ReadInteger('ProgrammOptionen','StellenDerErweiterung',2);
   TmpS := IniFile.ReadString('ProgrammOptionen','AnregungsEnergie','0');
   VAL(TmpS,ProgrammOptionen.PhotonenEnergie,Code);
   IF Code <> 0 THEN ProgrammOptionen.PhotonenEnergie := 0;
   ProgrammOptionen.TemplateName := IniFile.ReadString('ProgrammOptionen','TemplateName','Spektrum');
   ProgrammOptionen.TemplateMovingSizing := IniFile.ReadString('ProgrammOptionen','TemplateMovingSizing','MoveSize');
   ProgrammOptionen.IncludeAnalyserParameter := IniFile.ReadBool('ProgrammOptionen','IncludeAnalyserParameter',TRUE);
   ProgrammOptionen.ColumnLabel := IniFile.ReadBool('ProgrammOptionen','IncludeColumnLabel',TRUE);
   ProgrammOptionen.WksLabel := IniFile.ReadBool('ProgrammOptionen','IncludeWksLabel',TRUE);
   ProgrammOptionen.Interpolieren := IniFile.ReadBool('ProgrammOptionen','Interpolieren',FALSE);
   ProgrammOptionen.IncludeADC := IniFile.ReadBool('ProgrammOptionen','IncludeADCChannels',TRUE);
   ProgrammOptionen.ChanneltronEinzeln := IniFile.ReadBool('ProgrammOptionen','ChanneltronEinzeln',FALSE);
   ProgrammOptionen.EnableMovingSizing := IniFile.ReadBool('ProgrammOptionen','EnableMovingSizing',FALSE);
   ProgrammOptionen.Woher_hn := IniFile.ReadInteger('ProgrammOptionen','Woher_hn',1);
   HauptFenster.CB_ExtraSpalte.Checked := IniFile.ReadBool('CheckBoxen','ExtraSpalte',FALSE);
   HauptFenster.CB_NormiereExtraSpalte.Checked := IniFile.ReadBool('CheckBoxen','NormiereExtraSpalte',FALSE);
   HauptFenster.CB_EnableMovingSizing.Checked := IniFile.ReadBool('CheckBoxen','EnableMovingSizing',FALSE);
   HauptFenster.CB_DivScans.Checked := IniFile.ReadBool('CheckBoxen','TeileDurchScans',TRUE);
   HauptFenster.CB_DivLifeTime.Checked := IniFile.ReadBool('CheckBoxen','TeileDurchTorzeit',TRUE);
   IniFile.Free;
  END;


 PROCEDURE SaveIniFile;

  VAR
   TmpS      :STRING;
   IniFile   :TIniFile;

  BEGIN
   IniFile := TIniFile.Create('Konvert.Ini'); {befindet sich dann in C:\Windows !!!}
   IniFile.WriteBool('ProgrammOptionen','DataSourceSpectra',HauptFenster.RBDataSource_Spectra.Checked);
   IniFile.WriteBool('ProgrammOptionen','DataSourcePhoibos',HauptFenster.RBDataSource_Phoibos.Checked);
   IniFile.WriteBool('ProgrammOptionen','DataSourcePhoibosXML',HauptFenster.RBDataSource_PhoibosXML.Checked);
   IniFile.WriteString('ProgrammOptionen','ImportVerzeichnis',IniImportVerzeichnis);
   IniFile.WriteString('ProgrammOptionen','ExportVerzeichnis',IniExportVerzeichnis);
   IniFile.WriteInteger('ProgrammOptionen','StellenDerErweiterung',ProgrammOptionen.MinStellen);
   STR(ProgrammOptionen.PhotonenEnergie:8:3,TmpS);
   IniFile.WriteString('ProgrammOptionen','AnregungsEnergie',TmpS);
   IniFile.WriteString('ProgrammOptionen','TemplateName',ProgrammOptionen.TemplateName);
   IniFile.WriteString('ProgrammOptionen','TemplateMovingSizing',ProgrammOptionen.TemplateMovingSizing);
   IniFile.WriteBool('ProgrammOptionen','IncludeAnalyserParameter',ProgrammOptionen.IncludeAnalyserParameter);
   IniFile.WriteBool('ProgrammOptionen','IncludeColumnLabel',ProgrammOptionen.ColumnLabel);
   IniFile.WriteBool('ProgrammOptionen','IncludeWksLabel',ProgrammOptionen.WksLabel);
   IniFile.WriteBool('ProgrammOptionen','Interpolieren',ProgrammOptionen.Interpolieren);
   IniFile.WriteBool('ProgrammOptionen','IncludeADCChannels',ProgrammOptionen.IncludeADC);
   IniFile.WriteBool('ProgrammOptionen','ChanneltronEinzeln',ProgrammOptionen.ChanneltronEinzeln);
   IniFile.WriteBool('ProgrammOptionen','EnableMovingSizing',ProgrammOptionen.EnableMovingSizing);
   IniFile.WriteInteger('ProgrammOptionen','Woher_hn',ProgrammOptionen.Woher_hn);
   IniFile.WriteBool('CheckBoxen','ExtraSpalte',HauptFenster.CB_ExtraSpalte.Checked);
   IniFile.WriteBool('CheckBoxen','NormiereExtraSpalte',HauptFenster.CB_NormiereExtraSpalte.Checked);
   IniFile.WriteBool('CheckBoxen','EnableMovingSizing',HauptFenster.CB_EnableMovingSizing.Checked);
   IniFile.WriteBool('CheckBoxen','TeileDurchScans',HauptFenster.CB_DivScans.Checked);
   IniFile.WriteBool('CheckBoxen','TeileDurchTorzeit',HauptFenster.CB_DivLifeTime.Checked);
   IniFile.Free;
  END;

 FUNCTION SendToOrigin(ExecString:STRING):INTEGER;
  VAR Komando   :STRING;{Vor der Version 3.0 hatte ich hier einen String vom Typ STRING[255]}
                        {deklariert. Da aber manchmal der RegionName mit den ganzen Kommentaren
                        {zu den Analysator-Einstellungen mehr als 256 Zeichen hat, habe ich hier}
                        {nur STRING deklariert, was zu einem langen Stringtypen führt}
  BEGIN
   IF NOT ORIGINCall THEN EXIT; {Funktion soll nur ausgefürt werden, wenn auch das Programm aus ORIGIN heraus aufgerufen wird !!!}
   Komando := ExecString + #0; {Sicher ist sicher ;-) }
   SendMessage(ORIGIN_Wnd,wm_User,0,LONGINT(@Komando[1]));
   SendToOrigin := 0;{Ich weiß nicht, wie ich eine Fehlermeldung von ORIGIN erfahre !}
  END;


 CONSTRUCTOR TRegion.Create;
  BEGIN
   RegionName := '';
   Start := 0;
   Ende := 0;
   Schrittweite := 0;
   Scans := 0;
   Torzeit := 0;
   Messpunkte := 0;
   EPass := 0;
   ExEnergie := 0;
   Werte := NIL;
   ChanneltronEinzeln := FALSE; {Erst beim XML-Import wird diese Variable gebraucht und deshalb im Constructor TRegionORIGINCallPhoibos_XML.Create erst auf den eigentlichen Wert gesetzt}
   ADCChannel := NIL; {Erst beim XML-Import wird diese Variable gebraucht}
   Channels := NIL;
   NrDetektoren := 0;
   NextRegion := NIL;
   ScanMode :=  ScanMode_FixedTransm;
  END;


 FUNCTION TRegion.Importieren(VAR F:TEXT):INTEGER;

  VAR
   I               :WORD;
   S1,
   AnregungsEnergie:STRING;
   Code            :INTEGER;
   P1              :PWert;

  BEGIN
   {$I-}
   Read(F,Start,Ende,Schrittweite,Scans,Torzeit,Messpunkte,EPass);
   {$I+}
   IF IOResult <> 0 THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     Importieren := 1;
     EXIT;
    END;
   {Anregungsenergie bestimmen}
   CASE ProgrammOptionen.Woher_hn OF
    1:BEGIN
       IF EOLN(F) THEN
        BEGIN
         STR(ProgrammOptionen.PhotonenEnergie:8:3,AnregungsEnergie);
         REPEAT
          AnregungsEnergie := InputBox('Photon Energy ...','Please Enter Photon Energy :',AnregungsEnergie);
          VAL(AnregungsEnergie,ExEnergie,Code);
          IF Code <> 0 THEN MessageBox(0,'Only numerical values allowed !','Inpot Error ...',mb_Ok + mb_IconStop);
         UNTIL Code = 0;
         ReadLn(F,S1);
        END
       ELSE ReadLn(F,ExEnergie);
      END;
    2:BEGIN
       ReadLn(F,S1); {Damit der Dateizeiger auf die nächste Zeile zeigt !}
       ExEnergie := ProgrammOptionen.PhotonenEnergie;
      END;
    3:BEGIN
       ReadLn(F,S1); {Damit der Dateizeiger auf die nächste Zeile zeigt !}
       STR(ProgrammOptionen.PhotonenEnergie:8:3,AnregungsEnergie);
       REPEAT
        AnregungsEnergie := InputBox('Photon Energy ...','Please Enter Photon Energy :',AnregungsEnergie);
        VAL(AnregungsEnergie,ExEnergie,Code);
        IF Code <> 0 THEN MessageBox(0,'Only numerical values allowed !','Inpot Error ...',mb_Ok + mb_IconStop);
       UNTIL Code = 0;
      END;
    END;{CASE}
   ReadLn(F,RegionName);
   Werte := NEW(PWert);
   P1 := Werte;
   ReadLn(F,P1^.Counts);
   IF Hauptfenster.CB_DivScans.Checked THEN P1^.Counts := P1^.Counts / Scans;
   IF Hauptfenster.CB_DivLifeTime.Checked THEN P1^.Counts := P1^.Counts / Torzeit;
   P1^.Next := NIL;
   FOR I := 2 TO ROUND(Messpunkte) DO
    BEGIN
     P1^.Next := NEW(PWert);
     P1 := P1^.Next;
     ReadLn(F,P1^.Counts);
     IF Hauptfenster.CB_DivScans.Checked THEN P1^.Counts := P1^.Counts / Scans;
     IF Hauptfenster.CB_DivLifeTime.Checked THEN P1^.Counts := P1^.Counts / Torzeit;
     P1^.Next := NIL;
    END;{FOR}
   Importieren := 0;
  END;

 PROCEDURE TRegion.Exportieren(VAR F:TEXT);

  VAR
   I       :WORD;
   EKin    :REAL;
   P1      :PWert;

  BEGIN
   P1 := Werte;
   FOR I := 1 TO ROUND(Messpunkte) DO
    BEGIN
     EKin := Start + (I-1)*(Ende - Start)/(Messpunkte-1);
     WriteLn(F,(EKin-ExEnergie):10:3,'   ',P1^.Counts:10:3,'   ',EKin:10:3);
     P1 := P1^.Next;
    END;{FOR}
  END;

 FUNCTION TRegion.GetInfoString:STRING;

  VAR
   S1,S2   :STRING;

  BEGIN
   S1 := '{from ';
   STR(Start:7:2,S2);
   S1 := S1 + S2 + ' to ';
   STR(Ende:7:2,S2);
   S1 := S1 + S2 + ' eV, Step ';
   STR(SchrittWeite:4:2,S2);
   S1 := S1 + S2 + ' eV, Epass ';
   STR(EPass:4:1,S2);
   S1 := S1 + S2 + 'eV}';
   GetInfoString := S1;
  END;

  
 DESTRUCTOR TRegion.Free;

  VAR
   P1,
   P2           :PWert;
   AktADCChannel:PADCChannel;

  BEGIN
   IF NextRegion <> NIL THEN NextRegion.Free;
   P1 := Werte;
   WHILE P1 <> NIL DO
    BEGIN
     P2 := P1^.Next;
     Dispose(P1);
     P1 := P2;
    END;{WHILE}
   {ADC-Channel-Liste löschen, falls vorhanden}
   AktADCChannel := ADCChannel;
   WHILE AktADCChannel <> NIL DO
    BEGIN
     {Zuerst die Werte-Liste des ADC-Channels löschen}
     P1 := AktADCChannel^.Werte;
     WHILE P1 <> NIL DO
      BEGIN
       P2 := P1^.Next;
       Dispose(P1);
       P1 := P2;
      END;{WHILE}
     {Nun auch die TADCChannel-Struktur selbst}
     ADCChannel := AktADCChannel^.NextChannel;
     DISPOSE(AktADCChannel);
     AktADCChannel := ADCChannel;
    END;{WHILE}
  END;


 CONSTRUCTOR TRegionORIGIN.Create;
  BEGIN
   INHERITED Create;
  END;

  
 PROCEDURE TRegionORIGIN.Exportieren(VAR F:TEXT);

  VAR
   I       :WORD;
   EKin    :REAL;
   P1      :PWert;

  BEGIN
   P1 := Werte;
   FOR I := 1 TO ROUND(Messpunkte) DO
    BEGIN
     EKin := Start + (I-1)*(Ende - Start)/(Messpunkte-1);
     WriteLn(F,GetORIGINFormat(AktDATFileName),'_EBind[',I:5,']=',(EKin-ExEnergie):10:3,';');
     WriteLn(F,GetORIGINFormat(AktDATFileName),'_',GetORIGINFormat(COPY(AktDATFileName,1,MaxColNameLength)),'[',I:5,']=',P1^.Counts:10:3,';');{Nur 11 Zeichen sind für den Spaltennamen in ORIGIN erlaubt !!!}
     WriteLn(F,GetORIGINFormat(AktDATFileName),'_EKin[',I:5,']=',EKin:10:3,';');
     P1 := P1^.Next;
    END;{FOR}
  END;


 CONSTRUCTOR TRegionORIGINCall.Create(DName, GroupName:STRING);
  BEGIN
   INHERITED Create;
   DetectorVoltage := 0;
   DateiName := DName;
   GruppenName := GroupName;
  END;


 PROCEDURE TRegionORIGINCall.Exportieren(VAR F:TEXT);

  VAR
   LblLength,
   I,
   I2                   :WORD;
   MaxDateiNamenLaenge  :INTEGER;
   TmpR,
   EKin                 :REAL;
   P1                   :PWert;
   AktADCChannel        :PADCChannel;
   P1Channel            :PChannel;
   TestCode,
   Lbl,
   StrI,
   Str1                 :STRING;

  PROCEDURE BereiteRegionNameAuf(VAR Aufzubereiten:STRING);

   TYPE
    TErsetzen = ARRAY [1..3] OF RECORD
                                 Alt,
                                 Neu :STRING;
                                END;{RECORD}

   VAR
    TmpI    :LongInt;
    TmpErs  :STRING;

   CONST
    AnzahlErsetzen = 3;
    Ersetzen:TErsetzen = ((Alt:'&gt;'; Neu:'>'), (Alt:'&lt;'; Neu:'<'), (Alt:'&amp;'; Neu:'&'));

   BEGIN
    FOR TmpI := 1 TO AnzahlErsetzen DO
     WHILE POS(Ersetzen[TmpI].Alt,Aufzubereiten) <> 0 DO
      BEGIN
       TmpErs := COPY(Aufzubereiten,1,POS(Ersetzen[TmpI].Alt,Aufzubereiten)-1); {Alles bis zum ersten Vorkommen von dem zu ersetzenden String}
       TmpErs := TmpErs + Ersetzen[TmpI].Neu; {den Ersatzstring einfügen}
       TmpErs := TmpErs + COPY(Aufzubereiten,POS(Ersetzen[TmpI].Alt,Aufzubereiten)+LENGTH(Ersetzen[TmpI].Alt),LENGTH(Aufzubereiten));
       Aufzubereiten := TmpErs;
      END;{WHILE}
    {Nun muss ich alle Gleichheitszeichen durch Doppelpunkte ersetzen, da diese ORIGIN durcheinanderbringen}
    TmpI := POS('=',RegionName);
    WHILE TmpI <> 0 DO
     BEGIN
      RegionName[TmpI] := ':';
      TmpI := POS('=',RegionName);
     END;{WHILE}
    {Und falls noch Semikola drin sind, muss ich die durch Kommas ersetzten, weil sonst Origin das als Ende des Befehls interpretiert !}
    TmpI := POS(';',RegionName);
    WHILE TmpI <> 0 DO
     BEGIN
      RegionName[TmpI] := ':';
      TmpI := POS('=',RegionName);
     END;{WHILE}
   END;

  BEGIN
   {Zunächst einmal den als Zwischenspeicher fungierenden AktOutWert in ADCChannel auf den Anfang der ADC-Liste setzen}
   AktADCChannel := ADCChannel;
   WHILE AktADCChannel <> NIL DO
    BEGIN
     AktADCChannel^.AktOutWert := AktADCChannel^.Werte;
     AktADCChannel := AktADCChannel^.NextChannel;
    END;{WHILE}
   P1 := Werte;
   P1Channel := Channels;
   FOR I := 1 TO ROUND(Messpunkte) DO
    BEGIN
     Str(I:5,StrI);
     CASE ScanMode OF {Ich muss für jeden ScanMode die verschiedenen X-Achsen und kin. Energien berechnen}
      ScanMode_FixedTransm:
       BEGIN
        EKin := Start + (I-1)*(Ende - Start)/(Messpunkte-1); {kin. Energie wird durchgefahren}
        TmpR := EKin-ExEnergie; {Normale Bindungsenergie-Berechnung}
       END;
      ScanMode_FixedEnerg:
       BEGIN
        EKin := Start; {kin. Energie ist fest}
        TmpR := (I-1)*Torzeit; {X-Achse = Zeit}
       END;
      ScanMode_CFS:
       BEGIN
        EKin := Start; {kin. Energie ist fest}
        TmpR := ExEnergie + (I-1)*(Ende - Start)/(Messpunkte-1); {X-Achse = Anregungsenergie}
       END;
      ScanMode_CIS:
       BEGIN
        EKin := Start + (I-1)*(Ende - Start)/(Messpunkte-1); {kin. Energie wird durchgefahren}
        TmpR := ExEnergie + (I-1)*(Ende - Start)/(Messpunkte-1); {X-Achse = Anregungsenergie}
       END;
      ScanMode_Detector:
       BEGIN
        EKin := Start; {kin. Energie ist fest}
        TmpR := DetectorVoltage + (I-1)*SchrittWeite; {Die Detektorspannung errechnet sich aus der im Header gespeicherten DetectorVoltage und Schritte*ScanDelta}
       END;
      END;{CASE}
     Str(TmpR:10:3,Str1);
     SendToOrigin(GetORIGINFormat(AktDATFileName) + '_EBind[' + StrI + ']=' + Str1 + ';');
     Str(P1^.Counts:10:3,Str1);
     SendToOrigin(GetORIGINFormat(AktDATFileName) + '_' + GetORIGINFormat(COPY(AktDATFileName,1,MaxColNameLength)) + '[' + StrI + ']=' + Str1 + ';');{Nur 11 Zeichen sind für den Spaltennamen in ORIGIN erlaubt !!!}
     Str(EKin:10:3,Str1);
     SendToOrigin(GetORIGINFormat(AktDATFileName) + '_EKin[' + StrI + ']=' + Str1 + ';');
     {Hier jetzt die Channeltrons einzeln ausgeben, falls erforderlich}
     IF ChanneltronEinzeln THEN
      BEGIN
       FOR I2 := 1 TO NrDetektoren DO
        BEGIN
         Str(P1Channel^.CH[I2]:10:3,Str1);
         SendToOrigin(GetORIGINFormat(AktDATFileName) + '_Ch' + IntToStr(I2) + '[' + StrI + ']=' + Str1 + ';');
        END;{FOR I2}
       P1Channel := P1Channel^.Next;
      END;{IF}
     {Hier jetzt ADC-Kanäle ausgeben, wenn vorhanden. Die werden ja erst ab dem Specs-XML-Import eingelesen !}
     IF ADCChannel <> NIL THEN
      BEGIN {Es gibt tatsächlich ADC-Werte}
       AktADCChannel := ADCChannel;
       I2 := 0;
       WHILE AktADCChannel <> NIL DO
        BEGIN
         IF AktADCChannel^.AktOutWert = NIL THEN
          BEGIN
           Application.MessageBox('Internal Error: End of ADC data list reached before end of count data ! Application will be terminated !','Fatal Error',mb_Ok);
           Application.Terminate;
          END;
         Str(AktADCChannel^.AktOutWert^.Counts:15:6,Str1); {Normalerweise ist die Liste der ADC-Werte um den Channeltron-Offset an Anfang und Ende des Spektrums länger. Aber den habe ich schon beim Einlesen weg geschnitten. So kann ich mit dem Ausgeben gleich beim ersten Wert der Liste beginnen}
         SendToOrigin(GetORIGINFormat(AktDATFileName) + '_ADC' + IntToStr(I2) + '[' + StrI + ']=' + Str1 + ';');
         INC(I2);
         AktADCChannel^.AktOutWert := AktADCChannel^.AktOutWert^.Next;
         AktADCChannel := AktADCChannel^.NextChannel;
        END;{WHILE}
      END;
     P1 := P1^.Next;
    END;{FOR}
   IF ProgrammOptionen.IncludeAnalyserParameter THEN
    BEGIN
     {Und nun noch den Region-Namen in einem Textfeld namens "RegionName" im Worksheet ablegen}
     {Allerdings muss ich vorher noch einige Zeichen bzw. HTML-Codes von SpecsLab ersetzen, da diese ggf. ORIGIN durcheinanderbringen}
     BereiteRegionNameAuf(RegionName);
     SendToOrigin('label -sa -n RegionName ' + RegionName + ';');
    END;{IF}
   {Jetzt Label zusammenbauen}
   Lbl := '';
   LblLength := 0;
   {Zunächst mal Länge abschätzen. Denn ich kann nur eine bestimmte Länge an Origin übergeben, und es wäre doof, wenn der RegionNamen abschneidet, so wie ich das mal früher gemacht hatte}
   IF DateiName <> '' THEN LblLength := Length(DateiName);
   IF GruppenName <> '' THEN LblLength := LblLength  + Length(' | ') + Length(GruppenName);
   IF RegionNameOnly <> '' THEN LblLength := LblLength + Length(' | ') + Length(RegionNameOnly)
                           ELSE LblLength := LblLength + Length(' | ') + Length(RegionName);
  {Nun entscheiden, wie viel ich in das Label hineinschreiben kann}
   IF LblLength <= MaxWksLabelLength THEN
    BEGIN {Label wird nicht zu lang}
     IF DateiName <> '' THEN Lbl := Lbl + DateiName;
     IF GruppenName <> '' THEN Lbl := Lbl  + ' | ' + GruppenName;
     IF RegionNameOnly <> '' THEN Lbl := Lbl + ' | ' + RegionNameOnly
                             ELSE Lbl := Lbl + ' | ' + RegionName;
    END;{IF}
   IF LblLength > MaxWksLabelLength THEN
    BEGIN {Label wird zu lang => Dateinamen in der Mitte einkürzen !}
     MaxDateiNamenLaenge := Length(DateiName) - (LblLength - (MaxWksLabelLength+21)) - 3; {Soviel müsste ich vom Dateinamen herausschneiden}
     IF MaxDateiNamenLaenge < 0 THEN
      BEGIN {Label ist so lang, dass selbst das Kürzen des Dateinamens auf "..." nicht reicht !}
       Application.MessageBox('Label to long to be viewed in Origin. Shortening Label !','Attention ...',mb_Ok);
       IF DateiName <> '' THEN Lbl := Lbl + DateiName;
       IF GruppenName <> '' THEN Lbl := Lbl  + ' | ' + GruppenName;
       IF RegionNameOnly <> '' THEN Lbl := Lbl + ' | ' + RegionNameOnly
                               ELSE Lbl := Lbl + ' | ' + RegionName;
      END
     ELSE
      BEGIN {Dateinamen kürzen geht. Kürze also Dateinamen in der Mitte ein und füge dort "..." ein.}
       IF DateiName <> '' THEN Lbl := Lbl + COPY(DateiName,1,MaxDateiNamenLaenge DIV 2) + '...' + COPY(DateiName,Length(DateiName)-(MaxDateiNamenLaenge DIV 2),MaxDateiNamenLaenge DIV 2);
       IF GruppenName <> '' THEN Lbl := Lbl  + ' | ' + GruppenName;
       IF RegionNameOnly <> '' THEN Lbl := Lbl + ' | ' + RegionNameOnly
                               ELSE Lbl := Lbl + ' | ' + RegionName;
      END;{IF}
    END;{IF}
   {Label aufbereiten bendet}
   IF ProgrammOptionen.ColumnLabel THEN
    BEGIN {Label der Datenspalte (= 2. Spalte) setzen}
     SendToOrigin(GetORIGINFormat(AktDATFileName) + '!wks.col2.label$="' + Lbl + '";'); {Damit setze ich das Label der 2. Spalte}
     SendToOrigin(GetORIGINFormat(AktDATFileName) + '!wks.labels();'); {Damit schalte ich die Anzeige des Labels ein. Mit "wks.labels(0);" kann ich sie übrigens wieder ausschalten}
    END;{IF}
   IF ProgrammOptionen.WksLabel THEN
    BEGIN {Labels des Woksheets setzen}
     SendToOrigin(GetORIGINFormat(AktDATFileName) + '!page.label$ = "' + COPY(Lbl,1,MaxWksLabelLength) + '";'); {Setzen des Labels}
     SendToOrigin(GetORIGINFormat(AktDATFileName) + '!page.title = 3;'); {Damit stelle ich ein, dass Name und Label angezeigt wird}
    END;{IF}
  END;


 CONSTRUCTOR TRegionORIGINCallPHOIBOS.Create(DName, GroupName:STRING);
  BEGIN
   INHERITED Create(DName,GroupName);
  END;


 FUNCTION TRegionORIGINCallPHOIBOS.Importieren(VAR F:TEXT):INTEGER;

  VAR
   I               :WORD;
   S1,
   AnregungsEnergie,
   TmpS            :STRING;
   Code            :INTEGER;
   X1,
   X2,
   effWorkfunction :REAL;
   P1              :PWert;

  LABEL
   RepeatAfterEmptyRegion;

  BEGIN
   {Als erstes kommt eigentlich der Region-Name. Aber in den PHOIBOS-Export-Dateien können}
   {auch mehre Experimente gespeichert sein. Dann würde hier wieder Group kommen !}
   {$I-}
   ReadLn(F,RegionName);
   {$I+}
   IF IOResult <> 0 THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Could not read from file at region start';
     Importieren := 1;
     EXIT;
    END;
   RepeatAfterEmptyRegion: {Hier mache ich alles nochmal, wenn eine leere Region detektiert wurde}
   IF COPY(RegionName,1,9) = '# Group: ' THEN
    BEGIN
     {$I-}
     ReadLn(F,TmpS); {Die Nächste Zeile wäre dann eine Leerzeile}
     ReadLn(F,RegionName); {In dieser Zeile müsste der Regionname stehen}
     {$I+}
    END;
   IF (IOResult <> 0) OR (COPY(RegionName,1,21) <> '# Region:            ') THEN
    BEGIN
     GlobalImportErrorStr := '"Region" expected !';
     Importieren := 1;
     EXIT;
    END;
   RegionNameOnly := COPY(RegionName,22,255);
   RegionName := 'Region: ' + RegionNameOnly;
   {In den folgenden Zeilen stehen dann einige Parameter, die aber tw. nicht alle drinn stehen müssen}
   REPEAT
    {$I-}
    ReadLn(F,TmpS);
    {$I+}
    IF IOResult <> 0 THEN
     BEGIN {Kann nicht lesen !}
      GlobalImportErrorStr := 'Unable to read XY-File !';
      Importieren := 1;
      EXIT;
     END;
    {In den folgenden IF-THEN-Vergleichen teste ich, ob in den folgenden Zeilen ein bekannter Parameter vorkommt, und lege ihn dann in entsprechenden Variablen ab}
    {Um tolerant gegenüber unbekannten Parametern zu sein, gebe ich keinen Fehler aus, wenn ein unbekannter Parameter folgt}
    IF COPY(TmpS,1,21)= '# Anylsis Method:    ' THEN RegionName := RegionName + ' \nMethode:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Analyzer:          ' THEN RegionName := RegionName + ' \nAnalyser:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Analyzer Lens:     ' THEN RegionName := RegionName + ' \nLens:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Analyzer Slit:     ' THEN RegionName := RegionName + ' \nSlit:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Scan Mode:         ' THEN RegionName := RegionName + ' \nMode:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Number of Scans:   ' THEN
     BEGIN
      VAL(COPY(TmpS,22,255),Scans,Code);
      IF Code <> 0 THEN
       BEGIN {Scheint keine gültige Importdatei zu sein !}
        GlobalImportErrorStr := 'Error in numeric format of the number of scans !';
        Importieren := 1;
        EXIT;
       END;
     END;
    IF COPY(TmpS,1,21)= '# Curves/Scan:       ' THEN
     IF COPY(TmpS,22,255) <> '1' THEN
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       GlobalImportErrorStr := 'Import only possible if Curves/Scan is 1 !';
       Importieren := 1;
       EXIT;
      END;
    IF COPY(TmpS,1,21)= '# Values/Curve:      ' THEN
     BEGIN
      VAL(COPY(TmpS,22,255),Messpunkte,Code);
      IF Code <> 0 THEN
       BEGIN {Scheint keine gültige Importdatei zu sein !}
        GlobalImportErrorStr := 'Error in numeric format of the number of points !';
        Importieren := 1;
        EXIT;
       END;
     END;
    IF COPY(TmpS,1,21)= '# Dwell Time:        ' THEN
     BEGIN
      VAL(COPY(TmpS,22,255),Torzeit,Code);
      IF Code <> 0 THEN
       BEGIN {Scheint keine gültige Importdatei zu sein !}
        GlobalImportErrorStr := 'Error in the numeric format of the dwell time !';
        Importieren := 1;
        EXIT;
       END;
     END;
    IF COPY(TmpS,1,21)= '# Excitation Energy: ' THEN
     BEGIN
      VAL(COPY(TmpS,22,255),ExEnergie,Code);
      IF Code <> 0 THEN
       BEGIN {Scheint keine gültige Importdatei zu sein !}
        GlobalImportErrorStr := 'Error in numeric format of the excitation energy !';
        Importieren := 1;
        EXIT;
       END;
     END;
    IF COPY(TmpS,1,21)= '# Kinetic Energy:    ' THEN
     BEGIN
      VAL(COPY(TmpS,22,255),Start,Code);
      IF Code <> 0 THEN
       BEGIN {Scheint keine gültige Importdatei zu sein !}
        GlobalImportErrorStr := 'Error in numeric format of the kinetic energy !';
        Importieren := 1;
        EXIT;
       END;
     END;
    IF COPY(TmpS,1,21)= '# Pass Energy:       ' THEN
     BEGIN
      RegionName := RegionName + ' \nEPass:' + COPY(TmpS,22,255);
      VAL(COPY(TmpS,22,255),EPass,Code);
      IF Code <> 0 THEN
       BEGIN {Scheint keine gültige Importdatei zu sein !}
        GlobalImportErrorStr := 'Error in numeric format of the pass energy !';
        Importieren := 1;
        EXIT;
       END;
     END;
    IF COPY(TmpS,1,21)= '# Bias Voltage:      ' THEN RegionName := RegionName + ' \nBias:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Detector Voltage:  ' THEN RegionName := RegionName + ' \nHV:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Eff. Workfunction: ' THEN RegionName := RegionName + ' \nWF:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Source:            ' THEN RegionName := RegionName + ' \nSource:' + COPY(TmpS,22,255);
    IF COPY(TmpS,1,21)= '# Comment:           ' THEN RegionName := RegionName + ' \nComment:' + COPY(TmpS,22,255);
   UNTIL TmpS = '#';{Wenn eine Leerzeile kommt, dann ist Schluss mit den Parametern und die Daten beginnen !}

   {1.Zeile nach der Leerzeile : Cycle: 0, Curve: 0}
   {$I-}
   ReadLn(F,TmpS);
   {$I+}
   IF (IOResult <> 0) OR (TmpS <> '# Cycle: 0, Curve: 0') THEN
    BEGIN {Entweder die Region ist leer und es beginnt eine neue oder es ist keine gültige Importdatei zu sein !}
     IF (COPY(TmpS,1,9) = '# Group: ') OR (COPY(TmpS,1,10) = '# Region: ') THEN
      BEGIN {Die gerade Importierte Region ist tatsächlich leer und es beginnt eine neue Region oder gar eine Gruppe !}
       IF NOT IgnoriereAlleLeerenRegionen THEN
        IF Application.MessageBox('One Region seems to have no Data (perhaps not measured). Ignore all emty Regions ?','Question ...',mb_YesNo) = idYes THEN IgnoriereAlleLeerenRegionen := TRUE;
       RegionName := TmpS; {Da ich gleich an den Anfang zurückspringe und ich dort in die Variable RegionName eingelesen habe, muss ich die jetzt mit der gerade gelesenen Zeile belegen.}
       GOTO RepeatAfterEmptyRegion; {Rücksprung an die Stelle, nachdem ich die erste Zeile ausgelesen habe aber bevor ich die Auswertung, on Region oder neue Gruppe startet, gemacht habe}
      END
     ELSE
      BEGIN {keine neue Region/Gruppe startet, sondern fehler !}
       GlobalImportErrorStr := '"# Cycle: 0, Curve: 0" expected ! Instead "' + TmpS + '" found.';
       Importieren := 1;
       EXIT;
      END;{IF}
    END;{IF}
   {2.Zeile nach der Leerzeile : wieder eine Leerzeile}
   {$I-}
   ReadLn(F,TmpS);
   {$I+}
   IF (IOResult <> 0) OR (TmpS <> '#') THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := '"#" expected !';
     Importieren := 1;
     EXIT;
    END;

   {Jetzt noch die Anregungsenergie setzen, falls ich sie nicht aus der Datei lesen sollte !}
   CASE ProgrammOptionen.Woher_hn OF
    1:BEGIN
       {Nix tuen, da ich die Anregungsenergie ja schon oben gelesen habe}
      END;
    2:BEGIN
       ExEnergie := ProgrammOptionen.PhotonenEnergie;
      END;
    3:BEGIN
       STR(ProgrammOptionen.PhotonenEnergie:8:3,AnregungsEnergie);
       REPEAT
        AnregungsEnergie := InputBox('Photon Energy ...','Please Enter Photon Energy :',AnregungsEnergie);
        VAL(AnregungsEnergie,ExEnergie,Code);
        IF Code <> 0 THEN MessageBox(0,'Only numerical values allowed !','Inpot Error ...',mb_Ok + mb_IconStop);
       UNTIL Code = 0;
      END;
    END;{CASE}


   {...}
   {Nun sollten die Daten beginnen. Aus den ersten beiden X-Werten muss ich allerdings noch die}
   {Schrittweite und damit auch die Endenergie ermitteln, da ich aus Kompatibilitätsgründen}
   {zum Omicron-Spectra-Import nur die Y-Werte einlese !}
   Werte := NEW(PWert);
   P1 := Werte;
   {1. Wertepaar einlesen}
   ReadLn(F,X1,P1^.Counts);
   IF Hauptfenster.CB_DivScans.Checked THEN P1^.Counts := P1^.Counts / Scans;
   IF Hauptfenster.CB_DivLifeTime.Checked THEN P1^.Counts := P1^.Counts / Torzeit;
   P1^.Next := NEW(PWert);
   P1 := P1^.Next;
   {2. Wertepaar einlesen}
   ReadLn(F,X2,P1^.Counts);
   IF Hauptfenster.CB_DivScans.Checked THEN P1^.Counts := P1^.Counts / Scans;
   IF Hauptfenster.CB_DivLifeTime.Checked THEN P1^.Counts := P1^.Counts / Torzeit;
   P1^.Next := NIL;
   {Berechnen der Schrittweite und der Endenergie}
   Schrittweite := X2 - X1;
   Ende := Start + (ROUND(Messpunkte) - 1) * Schrittweite;
   FOR I := 3 TO ROUND(Messpunkte) DO
    BEGIN
     P1^.Next := NEW(PWert);
     P1 := P1^.Next;
     ReadLn(F,X1,P1^.Counts);
     IF Hauptfenster.CB_DivScans.Checked THEN P1^.Counts := P1^.Counts / Scans;
     IF Hauptfenster.CB_DivLifeTime.Checked THEN P1^.Counts := P1^.Counts / Torzeit;
     P1^.Next := NIL;
    END;{FOR}
   Importieren := 0;
  END;


 CONSTRUCTOR TRegionORIGINCallPHOIBOS_XML.Create(DName, GroupName:STRING; CHEinzeln:BOOLEAN);
  VAR TmpI:INTEGER;
  BEGIN
   INHERITED Create(DName,GroupName);
   AnzahlCounts := 0;
   FOR TmpI := 1 TO MaxDetektoren DO DetektorShift[TmpI] := 0;
   CountListe := NIL;
   ChanneltronEinzeln := CHEinzeln; {Hier wird dann die Variable, die im Constructor TRegion.Create immer auf FALSE gesetzt wird, auf einen variablen Wert gesetzt}
  END;


 FUNCTION TRegionORIGINCallPHOIBOS_XML.Importieren(VAR F:TEXT):INTEGER;

  VAR
  bufferhandle : THandle; {neu###}
  CountListe2 : array of DWORD;
   AnregungsEnergie,
   TmpS              :STRING;
   InterpolationsDetektor,
   ChanneltronOffsetAnzahl,
   AnzahlADCChannels,
   ADCChannelIndex,
   Code,
   TmpI,
   TmpI3,
   TmpI2             :INTEGER;
   ADCWertIndex      :LongInt;
   AktScan,
   AktCount,
   StartOfsett,
   Index,
   TmpDW             :DWORD;
   HauptAnteil,
   TmpR              :REAL;
   TmpD              :DOUBLE;
   AktADCWert,
   TmpADCWert,
   P1                :PWert;
   TmpADCChannel,
   AktADCChannel     :PADCChannel;
   P1Channels        :PChannel;
   TmpCH             :TChannelArray;

  CONST
   MarkerRegionInfoBlock = '<struct name="region" type_id="IDL:specs.de/SurfaceAnalysis/RegionDef:1.0" type_name="RegionDef">';
   MarkerDataBlock = '<sequence name="scans" length="'; {Das markiert meines Erachtens den Anfang eines Datenblocks nach den ganzen Region-Informationen}
   MarkerAnalysisMethod = '<string name="analysis_method">';
   MarkerAnalyzerInfo = '<struct name="analyzer_info" type_id="IDL:specs.de/SurfaceAnalysis/AnalyzerInfo:1.0" type_name="AnalyzerInfo">';
   MarkerAnalyzerLens =  '<string name="analyzer_lens">';
   MarkerAnalyzerSlit = '<string name="analyzer_slit">';
   MarkerScanMode = '<struct name="scan_mode" type_id="IDL:specs.de/SurfaceAnalysis/ScanMode:1.0" type_name="ScanMode">';
   MarkerNrOfScans = '<ulong name="num_scans">';
   MarkerCurversPerScan = '<ulong name="curves_per_scan">';
   MarkerValuesPerCurve = '<ulong name="values_per_curve">';
   MarkerDwellTime = '<double name="dwell_time">';
   MarkerScanDelta = '<double name="scan_delta">';
   MarkerExcitationEnergy = '<double name="excitation_energy">';
   MarkerKineticEnergy = '<double name="kinetic_energy">';
   MarkerPassEnergy = '<double name="pass_energy">';
   MarkerBiasVoltage = '<double name="bias_voltage">';
   MarkerDetectorVoltage = '<double name="detector_voltage">';
   MarkerEffWorkfunction = '<double name="effective_workfunction">';
   MarkerSourceInfo = '<struct name="source_info" type_id="IDL:specs.de/SurfaceAnalysis/SourceInfo:1.0" type_name="SourceInfo">';
   MarkerDetectors = '<sequence name="detectors" length="';
   MarkerDetectorShift = '<double name="shift">';
   MarkerCounts = '<sequence name="counts" length="';
   MarkerScanModeFixedTransm = 'FixedAnalyzerTransmission';
   MarkerScanModeFixedEnerg = 'FixedEnergies';
   MarkerScanModeCFS = 'ConstantFinalState';
   MarkerScanModeCIS = 'ConstantInitialState';
   MarkerScanModeDetector = 'DetectorVoltageScan';
   MarkerY_Curves = '<sequence name="y_curves" length="'; {Das darf ich nicht mit der kompletten Zeile vergleichen, weil lenght natürlich 0 oder 1 oder .. sein kann}
   MarkerY_CurveChannel = '<struct type_id="IDL:specs.de/Serializer/YCurve:1.0" type_name="YCurve">'; {Markiert den Anfang eines Kanals in der Sequenz "y_curves"}
   MarkerY_CurveName = '<string name="name">'; {Name des Kanals; nach dem '>' kommt der Name !}
   MarkerY_CurveStart = '<double name="start">'; {Startenergie des Kanals; nach dem '>' kommt der Wert !}
   MarkerY_CurveDelta = '<double name="delta">'; {Schrittweite des Kanals; nach dem '>' kommt der Wert !}
   MarkerY_CurveKurven = '<ulong name="curves">'; {Anzahl Kurven im Kanal; nach dem '>' kommt der Wert ! Sollte wohl immer 1 sein !}
   MarkerY_CurveLength = '<sequence name="data" length="'; {Anzahl gemessene Werte im Kanal; nach 'length="' kommt der Wert !}
   MarkerY_CurveData = '<double>'; {Markiert den Anfang der Daten des Kanals}


   MarkerGroupIdentifier = '<struct type_id="IDL:specs.de/Serializer/RegionGroup:1.0" type_name="RegionGroup">';
   MarkerRegionIdentifier = '<struct type_id="IDL:specs.de/Serializer/RegionData:1.0" type_name="RegionData">';
   MarkerKommentarIdentifier = '<string name="name">Comment</string>';

  FUNCTION GetMaxPositiveDetektorShift:DOUBLE;
   VAR
    TmpD_   :DOUBLE;
    TmpI_   :INTEGER;
   BEGIN
    TmpD_ := -1E100; {Ich hoffe, dass das ausreichend negativ ist, um kleiner als jeder DetektorShift zu sein !}
    FOR TmpI_ := 1 TO NrDetektoren DO IF DetektorShift[TmpI_]>TmpD_ THEN TmpD_ :=DetektorShift[TmpI_];
    GetMaxPositiveDetektorShift := TmpD_;
   END;

  BEGIN
   {Ich erwarte hier, dass TExperiment... schon bis zum Erkennungsstring für neue
   Regionen ("<struct type_id="IDL:specs.de/Serializer/RegionData:1.0" type_name="RegionData">")
   gelesen hat. Der Dateizeiger sollte auf die nächste Zeile nach diesem Erkennungs-
   string zeigen. Dort steht dann der Name der Region}
   {$I-}
   ReadLn(F,TmpS);
   {$I+}
   TmpI := LENGTH('<string name="name">');
   IF (IOResult <> 0) OR (COPY(TmpS,1,TmpI) <> '<string name="name">') THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Could not read reagion-name from file at region start';
     Importieren := 1;
     EXIT;
    END;
   RegionNameOnly := COPY(TmpS,TmpI+1,LENGTH(TmpS)-TmpI-9); {Am Ende steht ja immer noch "</string>", das sollte ich natürlich nicht mitkopieren !}
   RegionName := 'Group: ' + GruppenName + ' \nRegion: ' + RegionNameOnly; {In diese Variable, die dann ins Worksheet geschrieben wird, sollen auch die Gruppen- und Regionen-Namen rein !}
   {Nun bis zum Region-Info-Block lesen. Sollte gleich die nächste Zeile sein, aber ich lese trotzdem in einer WHILE-Schleife}
   WHILE (NOT EOF(F)) AND (TmpS <> MarkerRegionInfoBlock) DO ReadLn(F,TmpS);
   IF EOF(F) THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Unexpected end of XML-file after region start';
     Importieren := 1;
     EXIT;
    END;
   {Dateizeiger steht jetzt eine Zeile hinter dem Marker Region-Info-Block. Ich lese jetzt die Region-Infos aus, bis ich zur Sequenz "Detector" komme !}
   WHILE (NOT EOF(F)) AND (COPY(TmpS,1,LENGTH(MarkerDataBlock)) <> MarkerDataBlock) DO
    BEGIN
     ReadLn(F,TmpS);


         {bei neuren Specslab versionn gibt es überhaupt keinen MArkerDataBlock mehr wenn nichts eingelesen wurde  ####### neu}


     IF (TmpS = MarkerGroupIdentifier) OR (TmpS = MarkerRegionIdentifier) OR (TmpS = MarkerKommentarIdentifier) THEN
      BEGIN
             GlobalImportErrorStr := 'New Marker in RegionGroup!!';

        IF TmpS = MarkerGroupIdentifier THEN Importieren := RegionImport_foundGroup;
        IF TmpS = MarkerRegionIdentifier THEN Importieren := RegionImport_foundRegion;
        IF TmpS = MarkerKommentarIdentifier THEN Importieren := RegionImport_foundComment;
       {Importieren := RegionImport_RegionNichtGemessen;}

        IF NOT IgnoriereAlleLeerenRegionen THEN
         IF Application.MessageBox('One Region seems to have no Data (perhaps not measured). Ignore all emty Regions ?','Question ...',mb_YesNo) = idYes THEN IgnoriereAlleLeerenRegionen := TRUE;

       EXIT;
     END;





     IF COPY(TmpS,1,LENGTH(MarkerAnalysisMethod)) = MarkerAnalysisMethod THEN
       RegionName := RegionName + ' \nMethode: ' + COPY(TmpS,LENGTH(MarkerAnalysisMethod)+1,LENGTH(TmpS)-LENGTH(MarkerAnalysisMethod)-9); {Da am Ende nochmal '</string>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
     IF TmpS = MarkerAnalyzerInfo THEN
      BEGIN
       ReadLn(F,TmpS);
       RegionName := RegionName + ' \nAnalyzer: ' + COPY(TmpS,21,LENGTH(TmpS)-20-9); {Die 20 ist die Länge von '<string name="name">' am Anfang der Zeile und die 9 ist die Länge von '</string>' am Ende der Zeile}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerAnalyzerLens)) = MarkerAnalyzerLens THEN
       RegionName := RegionName + ' \nAnalyzer Lens: ' + COPY(TmpS,LENGTH(MarkerAnalyzerLens)+1,LENGTH(TmpS)-LENGTH(MarkerAnalyzerLens)-9); {Da am Ende nochmal '</string>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
     IF COPY(TmpS,1,LENGTH(MarkerAnalyzerSlit)) = MarkerAnalyzerSlit THEN
       RegionName := RegionName + ' \nAnalyzer Slit: ' + COPY(TmpS,LENGTH(MarkerAnalyzerSlit)+1,LENGTH(TmpS)-LENGTH(MarkerAnalyzerLens)-9); {Da am Ende nochmal '</string>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
     IF TmpS = MarkerScanMode THEN
      BEGIN
       ReadLn(F,TmpS);
       TmpS := COPY(TmpS,21,LENGTH(TmpS)-20-9); {Die 20 ist die Länge von '<string name="name">' am Anfang der Zeile und die 9 ist die Länge von '</string>' am Ende der Zeile}
       ScanMode := 0;
       IF TmpS = MarkerScanModeFixedTransm THEN ScanMode := ScanMode_FixedTransm;
       IF TmpS = MarkerScanModeFixedEnerg THEN ScanMode := ScanMode_FixedEnerg;
       IF TmpS = MarkerScanModeCFS THEN ScanMode := ScanMode_CFS;
       IF TmpS = MarkerScanModeCIS THEN ScanMode := ScanMode_CIS;
       IF TmpS = MarkerScanModeDetector THEN ScanMode :=ScanMode_Detector;
       IF ScanMode = 0 THEN
        BEGIN {Unbekannter ScanMode !}
         GlobalImportErrorStr := 'Unknown scan mode ! Supported scan modes: FixedAnalyserTransmission, FixedEnergy, CFS, CIS, DetectorVoltageScan !';
         Importieren := 1;
         EXIT;
        END;{IF}
       RegionName := RegionName + ' \nScan Mode: ' + TmpS;
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerNrOfScans)) = MarkerNrOfScans THEN
      BEGIN
       VAL(COPY(TmpS,LENGTH(MarkerNrOfScans)+1,LENGTH(TmpS)-LENGTH(MarkerNrOfScans)-8),Scans,Code); {Da am Ende nochmal '</ulong>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 8 ab}
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in numeric format of the number of scans !';
         Importieren := 1;
         EXIT;
        END;{IF}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerCurversPerScan)) = MarkerCurversPerScan THEN
      IF COPY(TmpS,LENGTH(MarkerCurversPerScan)+1,LENGTH(TmpS)-LENGTH(MarkerCurversPerScan)-8) <> '1' THEN {Da am Ende nochmal '</ulong>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 8 ab}
       BEGIN {Scheint keine gültige Importdatei zu sein !}
        GlobalImportErrorStr := 'Import only possible if Curves per Scan is 1 !';
        Importieren := 1;
        EXIT;
       END;
     IF COPY(TmpS,1,LENGTH(MarkerValuesPerCurve)) = MarkerValuesPerCurve THEN
      BEGIN
       VAL(COPY(TmpS,LENGTH(MarkerValuesPerCurve)+1,LENGTH(TmpS)-LENGTH(MarkerValuesPerCurve)-8),Messpunkte,Code); {Da am Ende nochmal '</ulong>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 8 ab}
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in numeric format of the values per curve !';
         Importieren := 1;
         EXIT;
        END;{IF}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerDwellTime)) = MarkerDwellTime THEN
      BEGIN
       VAL(COPY(TmpS,LENGTH(MarkerDwellTime)+1,LENGTH(TmpS)-LENGTH(MarkerDwellTime)-9),TorZeit,Code); {Da am Ende nochmal '</double>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in the numeric format of the dwell time !';
         Importieren := 1;
         EXIT;
        END;{IF}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerScanDelta)) = MarkerScanDelta THEN
      BEGIN
       VAL(COPY(TmpS,LENGTH(MarkerScanDelta)+1,LENGTH(TmpS)-LENGTH(MarkerScanDelta)-9),SchrittWeite,Code); {Da am Ende nochmal '</double>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in the numeric format of the step width !';
         Importieren := 1;
         EXIT;
        END;{IF}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerExcitationEnergy)) = MarkerExcitationEnergy THEN
      BEGIN
       VAL(COPY(TmpS,LENGTH(MarkerExcitationEnergy)+1,LENGTH(TmpS)-LENGTH(MarkerExcitationEnergy)-9),ExEnergie,Code); {Da am Ende nochmal '</double>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in numeric format of the excitation energy !';
         Importieren := 1;
         EXIT;
        END;{IF}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerKineticEnergy)) = MarkerKineticEnergy THEN
      BEGIN
       VAL(COPY(TmpS,LENGTH(MarkerKineticEnergy)+1,LENGTH(TmpS)-LENGTH(MarkerKineticEnergy)-9),Start,Code); {Da am Ende nochmal '</double>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in numeric format of the kinetic energy !';
         Importieren := 1;
         EXIT;
        END;{IF}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerPassEnergy)) = MarkerPassEnergy THEN
      BEGIN
       VAL(COPY(TmpS,LENGTH(MarkerPassEnergy)+1,LENGTH(TmpS)-LENGTH(MarkerPassEnergy)-9),EPass,Code); {Da am Ende nochmal '</double>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
       RegionName := RegionName + ' \nEPass: ' + COPY(TmpS,LENGTH(MarkerPassEnergy)+1,LENGTH(TmpS)-LENGTH(MarkerPassEnergy)-9);
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in numeric format of the pass energy !';
         Importieren := 1;
         EXIT;
        END;{IF}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerBiasVoltage)) = MarkerBiasVoltage THEN
       RegionName := RegionName + ' \nBias Voltage: ' + COPY(TmpS,LENGTH(MarkerBiasVoltage)+1,LENGTH(TmpS)-LENGTH(MarkerBiasVoltage)-9); {Da am Ende nochmal '</double>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
     IF COPY(TmpS,1,LENGTH(MarkerDetectorVoltage)) = MarkerDetectorVoltage THEN
      BEGIN
       RegionName := RegionName + ' \nDetector Voltage: ' + COPY(TmpS,LENGTH(MarkerDetectorVoltage)+1,LENGTH(TmpS)-LENGTH(MarkerDetectorVoltage)-9); {Da am Ende nochmal '</double>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
       {Bei einem Detector-Voltage-Scan brauche ich auch diesen Wert als Startwert. Deshalb wandle ich ihn hier in eine Zahl um}
       VAL(COPY(TmpS,LENGTH(MarkerDetectorVoltage)+1,LENGTH(TmpS)-LENGTH(MarkerDetectorVoltage)-9),DetectorVoltage,Code);
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in numeric format of the detector voltage !';
         Importieren := 1;
         EXIT;
        END;{IF}
      END;
     IF COPY(TmpS,1,LENGTH(MarkerEffWorkfunction)) = MarkerEffWorkfunction THEN
       RegionName := RegionName + ' \neff. Workfunction: ' + COPY(TmpS,LENGTH(MarkerEffWorkfunction)+1,LENGTH(TmpS)-LENGTH(MarkerEffWorkfunction)-9); {Da am Ende nochmal '</double>' steht, darf ich das nicht mitkopieren. Deshaln ziehe ich 9 ab}
     IF TmpS = MarkerSourceInfo THEN
      BEGIN
       ReadLn(F,TmpS);
       RegionName := RegionName + ' \nSource: ' + COPY(TmpS,21,LENGTH(TmpS)-20-9); {Die 20 ist die Länge von '<string name="name">' am Anfang der Zeile und die 9 ist die Länge von '</string>' am Ende der Zeile}
      END;{IF}
     IF COPY(TmpS,1,LENGTH(MarkerDetectors)) = MarkerDetectors THEN
      BEGIN {Nun die Energie-Shifts der einzelnen Channeltrons auslesen}
       TmpS := COPY(TmpS,LENGTH(MarkerDetectors)+1,255);
       VAL(COPY(TmpS,1,POS('"',TmpS)-1),NrDetektoren,Code);
       IF Code <> 0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in numeric format of the number of detectors !';
         Importieren := 1;
         EXIT;
        END;{IF}
       IF NrDetektoren > MaxDetektoren THEN
        BEGIN {So viele Detektoren habe ich nicht eingeplant !!!}
         GlobalImportErrorStr := 'Two much Detectors !';
         Importieren := 1;
         EXIT;
        END;{IF}
       FOR TmpI := 1 To NrDetektoren DO
        BEGIN
         REPEAT
          ReadLn(F,TmpS);
         UNTIL EOF(F) OR (COPY(TmpS,1,LENGTH(MarkerDetectorShift)) = MarkerDetectorShift);
         IF EOF(F) THEN
          BEGIN {Scheint keine gültige Importdatei zu sein !}
           GlobalImportErrorStr := 'Unexpected end of XML file while reading the detector shifts !';
           Importieren := 1;
           EXIT;
          END;{IF}
         VAL(COPY(TmpS,LENGTH(MarkerDetectorShift)+1,LENGTH(TmpS)-LENGTH(MarkerDetectorShift)-9),DetektorShift[TmpI],Code);
         IF Code <> 0 THEN
          BEGIN {Scheint keine gültige Importdatei zu sein !}
           GlobalImportErrorStr := 'Error in numeric format of the detector shift !';
           Importieren := 1;
           EXIT;
          END;{IF}
        END;{FOR TmpI}
      END;{IF}
    END;{WHILE}
   IF EOF(F) THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Unexpected end of XML-file while reading region-info-block';  {### Bug empty region am ende der datei --> überspringen}
     Importieren := 1;


        {### neu wegen lehrer region am ender der Datei???}
        IF Application.MessageBox('Unexpected end of XML-file while reading region-info-block. Maybe empty Region at the end ? Ignore and continue ?','Question ...',mb_YesNo) = idYes THEN
         BEGIN
          IgnoriereAlleLeerenRegionen := TRUE;
          Importieren := RegionImport_RegionNichtGemessen;
         END;





     EXIT;
    END;
   {Jetzt noch die Anregungsenergie setzen, falls ich sie nicht aus der Datei lesen sollte !}
   CASE ProgrammOptionen.Woher_hn OF
    1:BEGIN
       {Nix tuen, da ich die Anregungsenergie ja schon oben gelesen habe}
      END;
    2:BEGIN
       ExEnergie := ProgrammOptionen.PhotonenEnergie;
      END;
    3:BEGIN
       STR(ProgrammOptionen.PhotonenEnergie:8:3,AnregungsEnergie);
       REPEAT
        AnregungsEnergie := InputBox('Photon Energy ...','Please Enter Photon Energy :',AnregungsEnergie);
        VAL(AnregungsEnergie,ExEnergie,Code);
        IF Code <> 0 THEN MessageBox(0,'Only numerical values allowed !','Inpot Error ...',mb_Ok + mb_IconStop);
       UNTIL Code = 0;
      END;
    END;{CASE}
   Ende := Start + (ROUND(Messpunkte) - 1) * Schrittweite; {Die Endenergie muss ich auch noch berechnen}
   {Jetzt sollte ich gerade die Zeile mit dem Anfang der Scan-Sequenz ('<sequence name="scans" length="') gelesen haben. Der Dateizeiger steht schon auf der nächsten Zeile
    Nun sollten nur noch die Counts-Sequenzen begonnen werden (in den nächsten paar Zeilen) und dann sollten auch schon die Counts kommen !}
   {Jetzt noch überprüfen, ob die Nummer der Scans aus dem oben ausgelesenen Region-Infos mit der hier angegebenen Scan-Zahl übereinstimmt}
   TmpS := COPY(TmpS,LENGTH(MarkerDataBlock)+1,255);
   VAL(COPY(TmpS,1,POS('"',TmpS)-1),TmpI,Code);
   IF (Code<>0) OR (TmpI<>Scans) THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Difference between Number of Scans in Region-Info-Block and Data Block !';
     Importieren := 1;
     IF (Code=0) AND (TmpI=0) THEN
      BEGIN
       Importieren := RegionImport_RegionNichtGemessen;
       IF NOT IgnoriereAlleLeerenRegionen THEN
        IF Application.MessageBox('One Region seems to have no Data (perhaps not measured). Ignore all emty Regions ?','Question ...',mb_YesNo) = idYes THEN IgnoriereAlleLeerenRegionen := TRUE;
      END;
     EXIT;
    END;
   ReadLn(F,TmpS); {Hier sollte '<struct type_id="IDL:specs.de/Serializer/ScanData:1.0" type_name="ScanData">' stehen, überprüfe ich aber nicht !}
   ReadLn(F,TmpS);
   IF COPY(TmpS,1,LENGTH(MarkerCounts)) <> MarkerCounts THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Sequence "Counts" expected after Scan-Sequence';
     Importieren := 1;
     EXIT;
    END;
   TmpS := COPY(TmpS,LENGTH(MarkerCounts)+1,255);
         { Application.MessageBox(@TmpS[1],'Debug Info',mb_Ok);}   {#####}

   VAL(COPY(TmpS,1,POS('"',TmpS)-1),AnzahlCounts,Code);

           {TmpS := IntToStr(AnzahlCounts)+ '   ' + COPY(TmpS,1,POS('"',TmpS)-1); }    {#####}

         { Application.MessageBox(@TmpS[1],'Debug Info',mb_Ok); }  {#####}

   IF Code<>0 THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Error in numeric format of the Number of Counts !';
     Importieren := 1;
     EXIT;
    END;
   ReadLn(F,TmpS); {Noch eine Zeile lesen und jetzt sollte der Dateizeiger auf den Counts stehen}
   {### neu}

   {   CountListe := Pointer(GlobalAlloc(GPTR,AnzahlCounts*SizeOf(TmpDW)));] {Speicher für die Count-Liste reservieren}
  { bufferhandle:= GlobalAlloc(GPTR,AnzahlCounts*SizeOf(TmpDW));
    CountListe := Pointer(GlobalLock(bufferhandle));} {Speicher für die Count-Liste reservieren}
  {Getmem(CountListe,AnzahlCounts*SizeOf(TmpDW));       }
{ CountListe:= VirtualAlloc(nil, 2000000*AnzahlCounts*SizeOf(TmpDW), MEM_COMMIT, PAGE_READWRITE);  }
                 SetLength(CountListe2, AnzahlCounts*SizeOf(TmpDW));
                  {CountListe := ^countlistarray;   }
           for TmpI3 := low(CountListe2) to high(CountListe2) do begin
              CountListe2[TmpI3] := 0
           end;


           {TmpS := 'Speicher zuweisen; Counts: '+IntToStr(AnzahlCounts)+ '  ' + IntToStr(AnzahlCounts*SizeOf(TmpDW));
           Application.MessageBox(@TmpS[1],'Debug Info',mb_Ok);}



   FOR AktScan := 1 TO ROUND(Scans) DO
    BEGIN
     FOR AktCount := 0 TO AnzahlCounts-1 DO
      BEGIN
       ReadLn(F,TmpS);
       VAL(TmpS,TmpDW,Code);
       IF Code<>0 THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error while reading Counts !';
         Importieren := 1;
         EXIT;
        END;
       CountListe2[AktCount] := CountListe2[AktCount] + TmpDW; {Counts aufaddieren. Da GlobalAlloc den Speicher mit 0 initialisiert, sollte es keine Probleme geben}
      END;{FOR AktCount}
     IF AktScan < Scans THEN
      BEGIN  {Ein paar Zeilen stehen immer zwischen den Scans. Die lese ich jetzt aus, bis die Counts wieder beginnen}
       TmpS := ''; {Zur Sicherheit weise ich mal einen Leerstring zu}
       WHILE (NOT EOF(F)) AND (COPY(TmpS,1,LENGTH(MarkerCounts))<>MarkerCounts) DO ReadLn(F,TmpS);
       TmpS := COPY(TmpS,LENGTH(MarkerCounts)+1,255);

         {TmpS := TmpS + '  ' + IntToStr(AnzahlCounts); }    {neu###}
         {Application.MessageBox(@TmpS[1],'Error ...',mb_Ok); }   {neu###}
       VAL(COPY(TmpS,1,POS('"',TmpS)-1),TmpI,Code);  {###old}
       {VAL(COPY(TmpS,1,POS('"',TmpS)-1-length(IntToStr(AnzahlCounts))),TmpI,Code); } {###new, specsbug, fixed??, Matthias: Specslab hängt ab und zu ein paar Nullen etc. daran??}
       IF (Code<>0) OR (TmpI<>AnzahlCounts) THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Error in numeric format of the number of counts in 2nd or higher scan or different number of counts in the 2nd or higher scan !';
         Importieren := 1;
         EXIT;
        END;
       ReadLn(F,TmpS); {Noch eine Zeile lesen und jetzt sollte der Dateizeiger auf den Counts des nächsten Scans stehen}
      END; {IF}
    END; {FOR AktScan}
   {Der Dateizeiger sollte jetzt auf die direkt den Counts folgende Zeile des letzten Scans dieser Region stehen. TExperiment... muss dann wieder bis zur nächsten Struktur "RegionData" lesen !}
   IF ProgrammOptionen.IncludeADC THEN
    BEGIN {Jetzt schaue ich nach, ob noch ADC-Werte eingelesen werden können. Dazu muss ich lesen, bis eine Sequenz namens "y_curves" kommt und schauen, ob deren Länge > 0 ist}
     TmpS := '';
     WHILE (NOT EOF(F)) AND (COPY(TmpS,1,LENGTH(MarkerY_Curves))<>MarkerY_Curves) DO ReadLn(F,TmpS);
     IF EOF(F) THEN {Es muss immer so eine Sequenz kommen. Selbst in den früheren SpecsLab-Versionen, in denen die ADC-Daten noch gar nicht mit abgespeichert wurden gab es diese Sequenz mit der Länge = 0. Wenn nun ADC-Werte mitgespeichert wurden, dann gibt es diese Sequenz sogar 2 mal: In der 1. sind alle eingelesenen Kanäle nacheinander, die 2. hat immer die Länge 0.}
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       GlobalImportErrorStr := 'Could not find sequence "y_curves" !';
       CloseFile(F);
       Importieren := 1;
       EXIT;
      END;
     TmpS := COPY(TmpS,LENGTH(MarkerY_Curves)+1,255); {Vorn den Marker abschneiden. Jetzt müsste TmpS mit einer Zahl, nämlich der Länge der Sequenz, beginnen}
     VAL(COPY(TmpS,1,POS('"',TmpS)-1),AnzahlADCChannels,Code);
     IF Code<>0 THEN
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       GlobalImportErrorStr := 'Error in numeric format of the length of sequence "y_curves" !';
       CloseFile(F);
       Importieren := 1;
       EXIT;
      END;
     AktADCChannel := NIL;
     FOR ADCChannelIndex := 1 TO AnzahlADCChannels DO
      BEGIN {Es sind tatsächlich ADC-Werte vorhanden}
       {Liste der ADC-Channel aufbauen}
       TmpADCChannel := NEW(PADCChannel);
       TmpADCChannel^.NextChannel := NIL;
       TmpADCChannel^.AktOutWert := NIL;
       IF AktADCChannel = NIL THEN ADCChannel :=  TmpADCChannel {Wurzelzeiger zuweisen}
                              ELSE AktADCChannel^.NextChannel := TmpADCChannel;
       AktADCChannel := TmpADCChannel;
       AktADCChannel^.ChannelName := '';
       AktADCChannel^.Start := 0;
       AktADCChannel^.Delta := 0;
       AktADCChannel^.Length := 0;
       AktADCChannel^.Werte := NIL;
       {Lese nun bis zum Anfang der nächsten Channelstruktur. Das sollte eigentlich gleich in der nächsten Zeile stehen}
       TmpS := '';
       WHILE (NOT EOF(F)) AND (TmpS<>MarkerY_CurveChannel) DO ReadLn(F,TmpS);
       IF EOF(F) THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Could not find structure "YCurve" within sequence "y_curves" !';
         CloseFile(F);
         Importieren := 1;
         EXIT;
        END;
       {In der nächsten Zeile sollten nun Name, Startpunkt, Schrittweite, Anzahl der Kurven und Punktzahl stehen}
       WHILE (NOT EOF(F)) AND (TmpS<>MarkerY_CurveData) DO
        BEGIN
         IF EOF(F) THEN
          BEGIN {Scheint keine gültige Importdatei zu sein !}
           GlobalImportErrorStr := 'Could not find data in structure "YCurve" within sequence "y_curves" !';
           CloseFile(F);
           Importieren := 1;
           EXIT;
          END;
         ReadLn(F,TmpS);
         IF COPY(TmpS,1,LENGTH(MarkerY_CurveName)) = MarkerY_CurveName THEN
          BEGIN {Name des Kanals in TmpS}
           TmpS := COPY(TmpS,LENGTH(MarkerY_CurveName)+1,255);
           AktADCChannel^.ChannelName := COPY(TmpS,1,POS('<',TmpS)-1);
          END;
         IF COPY(TmpS,1,LENGTH(MarkerY_CurveStart)) = MarkerY_CurveStart THEN
          BEGIN {X-Startwert im Kanal in TmpS}
           TmpS := COPY(TmpS,LENGTH(MarkerY_CurveStart)+1,255);
           VAL(COPY(TmpS,1,POS('<',TmpS)-1),AktADCChannel^.Start,Code);
           IF Code <> 0 THEN
            BEGIN {Scheint keine gültige Importdatei zu sein !}
             GlobalImportErrorStr := 'Error in Start Energy of ADC data !';
             CloseFile(F);
             Importieren := 1;
             EXIT;
            END;
          END;
         IF COPY(TmpS,1,LENGTH(MarkerY_CurveDelta)) = MarkerY_CurveDelta THEN
          BEGIN {Schrittweite im Kanal in TmpS}
           TmpS := COPY(TmpS,LENGTH(MarkerY_CurveDelta)+1,255);
           VAL(COPY(TmpS,1,POS('<',TmpS)-1),AktADCChannel^.Delta,Code);
           IF Code <> 0 THEN
            BEGIN {Scheint keine gültige Importdatei zu sein !}
             GlobalImportErrorStr := 'Error in Delta of ADC data !';
             CloseFile(F);
             Importieren := 1;
             EXIT;
            END;
          END;
         IF COPY(TmpS,1,LENGTH(MarkerY_CurveKurven)) = MarkerY_CurveKurven THEN
          BEGIN {Anzahl Kurven im Kanal in TmpS}
           TmpS := COPY(TmpS,LENGTH(MarkerY_CurveKurven)+1,255);
           VAL(COPY(TmpS,1,POS('<',TmpS)-1),TmpI,Code);
           IF (Code <> 0) OR (TmpI<>1) THEN
            BEGIN {Scheint keine gültige Importdatei zu sein !}
             GlobalImportErrorStr := 'Error in Number of Rows of ADC data or Number of Rows not 1 !';
             CloseFile(F);
             Importieren := 1;
             EXIT;
            END;
          END;
         IF COPY(TmpS,1,LENGTH(MarkerY_CurveLength)) = MarkerY_CurveLength THEN
          BEGIN {Anzahl der Punkte im Kanal in TmpS}
           TmpS := COPY(TmpS,LENGTH(MarkerY_CurveLength)+1,255);
           VAL(COPY(TmpS,1,POS('"',TmpS)-1),AktADCChannel^.Length,Code);
           IF Code <> 0 THEN
            BEGIN {Scheint keine gültige Importdatei zu sein !}
             GlobalImportErrorStr := 'Error in Number of Data Points of ADC data !';
             CloseFile(F);
             Importieren := 1;
             EXIT;
            END;
          END;
        END;{WHILE}
       {in der XML-Datei können auch andere als ADC-Kurven gespeichert sein.
        Z.B. der quadratische Fit vom Peak Location. Da diese Kurven sich in
        keinem Identifier von den ADC-Kurven unterscheiden, aber sie meistens
        kürzer als der Scan sind (also: AktADCChannel^.Length < Messpunkte),
        sortiere ich sie anhand dessen heraus.
        Ich hatte anfangs nach der Anfangsenergie aussortiert (also: AktADCChannel^.Start > Start),
        aber manchmal speichert SpecsLab die Anfangsenergie nicht richtig ab.
        Das ist mir schon mal beim Messen aufgefallen.}
       IF AktADCChannel^.Length < Messpunkte THEN
        BEGIN {Ich muss jetzt den AktADCChannel verwerfen}
         IF NOT IgnoriereAlleLeerenYCurves THEN
          BEGIN {Jetzt frage ich mal nach, ob ich alle zukünftigen verwerfen soll}
           TmpS := 'Additional Y-Curve named "' + AktADCChannel^.ChannelName + '" found in XML-File !' + #13 + #10;
           TmpS := TmpS + 'This curve seems not to be a valid ADC input channel. Reason could be: Additional actions performed with SpecsLab (e.g. Peak Location) and saved in XML file.' + #13 + #10;
           TmpS := TmpS + 'Ignoring all of this Y-Curves ?' + #0;
           IF Application.MessageBox(@TmpS[1],'Question ...',mb_YesNo) = idYes THEN IgnoriereAlleLeerenYCurves := TRUE;
          END;{IF}
         {Hier verwerfe ich AktADCChannel und lösche ihn aus der Liste}
         IF AktADCChannel = ADCChannel THEN
          BEGIN {Der Wurzelzeiger ist zu verwerfen}
           ADCChannel := NIL;
           DISPOSE(AktADCChannel);
           AktADCChannel := NIL;
          END
         ELSE
          BEGIN {Schieriger: Es existiert schon eine Liste mit ADC-Kanälen und der letzte schon in die Liste eingetragene ist zu verwerfen}
           TmpADCChannel := ADCChannel;
           WHILE TmpADCChannel^.NextChannel^.NextChannel <> NIL DO TmpADCChannel := TmpADCChannel^.NextChannel;
           IF TmpADCChannel^.NextChannel = AktADCChannel THEN DISPOSE(AktADCChannel)
            ELSE BEGIN {Eigentlich sollte ja AktADCChannel der letzte in der Liste sein. Wenn nicht, dann ist was scheif gelaufen !}
             GlobalImportErrorStr := 'Internal Error: Unexpected Data found in XML file ! Please remove all data created by additional opperations, like Peak Location, and try again.';
             CloseFile(F);
             Importieren := 1;
             EXIT;
            END;
           AktADCChannel := TmpADCChannel;
           AktADCChannel^.NextChannel := NIL;
          END;{IF}
         {Liste mit ADC_Channels ist nun bereinigt}
         CONTINUE; {Nächsten Durchlauf von FOR ADCChannelIndex auslösen}
        END;{IF}
       {So, nun kommt in der nächsten zu lesenden Zeile der erste der ADC-Werte !}
       {Zunächst mal muss ich berechnen, ab wo ich die Werte einlesen muss, denn zuerst kommen einige überzählige Werte wegen des Channeltron-Offsets}
       {ChanneltronOffsetAnzahl := ROUND(ABS(Start - AktADCChannel^.Start) / AktADCChannel^.Delta); So hatte ich es zunächst berechnet. Aber scheinbar durch Fehler in der Abspeicherung der Start-Werte kommt es dabei zu Fehlern}
       ChanneltronOffsetAnzahl := ROUND(ABS(Messpunkte - AktADCChannel^.Length) / 2); {Das ist zwar nicht exact, weil bei ungeraden Channeltron-Offsets ich nicht weiß, ob ich am Anfang oder am Ende mehr nehmen muss. Aber es funktioniert wenigstens}
       IF ChanneltronOffsetAnzahl > AktADCChannel^.Length THEN
        BEGIN {Interner Berechnungsfehler}
         GlobalImportErrorStr := 'Internal Error: Calculated Channeltron-Offset larger than number of Points !';
         CloseFile(F);
         Importieren := 1;
         EXIT;
        END;
       {Nun kann ich die Werte alle einlesen}
       AktADCWert := NIL;
       FOR ADCWertIndex := 1 TO AktADCChannel^.Length DO
        BEGIN
         ReadLn(F,TmpS);
         VAL(TmpS,TmpD,Code);
         IF Code <> 0 THEN
          BEGIN {Scheint keine gültige Importdatei zu sein !}
           GlobalImportErrorStr := 'Error in numerical value of ADC values !';
           CloseFile(F);
           Importieren := 1;
           EXIT;
          END;
         {Nun habe ich den numerischen Wert am Index ADCWertIndex in TmpD. Nun kann ich ihn speicherm wenn er nicht zum Channeltron-Offset gehört}
         IF (ADCWertIndex > ChanneltronOffsetAnzahl) AND (ADCWertIndex <= (Messpunkte+ChanneltronOffsetAnzahl)) THEN
          BEGIN
           TmpADCWert := NEW(PWert);
           TmpADCWert^.Next := NIL;
           IF AktADCWert = NIL THEN AktADCChannel^.Werte := TmpADCWert {erster Wert in Liste}
                               ELSE AktADCWert^.Next := TmpADCWert; {folgende Werte in Liste}
           AktADCWert := TmpADCWert;
           IF Hauptfenster.CB_DivScans.Checked THEN AktADCWert^.Counts := REAL(TmpD) / Scans
                                               ELSE AktADCWert^.Counts := REAL(TmpD);
          END;{FOR}
        END;{FOR ADCWertIndex}
      END;{FOR ADCChannelIndex}
    END;{IF ProgrammOptionen.IncludeADC}
   {...}
   {Hier beginnt nun die Zusammenfassung der einzelnen Channeltrons zum Summen-Spektrum}
   {StartOfsett := (AnzahlCounts - NrDetektoren*ROUND(Messpunkte)) DIV 2; Alte Routine; hat versagt, wenn durch unsymmetrischen Detektorshift am Anfang und am Ende unterschiedlich viele Punkte zusätzlich gemessen werden müssen}
   StartOfsett := NrDetektoren*ROUND(GetMaxPositiveDetektorShift*EPass/Schrittweite); {Zeigt jetzt innerhalb des Counts-Array auf ein Element unmittelbar VOR der ersten Detektorgruppe}
   IF Werte <> NIL THEN
    BEGIN {Da sollten beim Aufruf dieser Routine eigentlich keine Werte drin stehen !!!}
     GlobalImportErrorStr := 'Internal error: TRegionORIGINCallPHOIBOS_XML.Werte already contains values when calling "Importieren"-procedure !';
     Importieren := 1;
     EXIT;
    END;
   P1 := NIL;
   FOR TmpI := 1 TO MaxDetektoren DO TmpCH[TmpI] := 0; {Einmal alles auf 0 setzten damit alle nicht genutzen Detektoren auf 0 sind}
   FOR TmpI := 1 TO ROUND(Messpunkte) DO
    BEGIN
     TmpR := 0;
     FOR TmpI2 := 1 TO NrDetektoren DO
      BEGIN
       CASE ScanMode OF
        ScanMode_FixedTransm: Index := StartOfsett + NrDetektoren*(TmpI-1) + (TmpI2-1) - NrDetektoren*ROUND(DetektorShift[TmpI2]*EPass/Schrittweite);
        ScanMode_FixedEnerg: Index := NrDetektoren*(TmpI-1) + (TmpI2-1); {Hier einfach die Detektoren aufsummieren, da sie hintereinander in der Counts-Liste stehen und auch so zusammen gehören !}
        ScanMode_CFS: Index := NrDetektoren*(TmpI-1) + (TmpI2-1); {Hier einfach die Detektoren aufsummieren, da sie hintereinander in der Counts-Liste stehen und auch so zusammen gehören !}
        ScanMode_CIS: Index := NrDetektoren*(TmpI-1) + (TmpI2-1); {Hier einfach die Detektoren aufsummieren, da sie hintereinander in der Counts-Liste stehen und auch so zusammen gehören !}
        ScanMode_Detector: Index := NrDetektoren*(TmpI-1) + (TmpI2-1); {Hier einfach die Detektoren aufsummieren, da sie hintereinander in der Counts-Liste stehen und auch so zusammen gehören !}
        END;{CASE}
       IF ProgrammOptionen.Interpolieren THEN
        BEGIN {OMICRON-Methode: Zählrate am aktuellen Messpunkt aus den rechts und links davon liegenden Channeltron-Zählraten interpolieren}
         {Zunächst mal muss ich ermittel, ob er ab- oder aufgerundet hat, beim bestimmen des Index}
         IF ABS(FRAC(DetektorShift[TmpI2]*EPass/Schrittweite)) < 0.5 THEN
          BEGIN {Es wurde abgerundet => ich muss mit einem um eine Schrittweite IM INDEX HÖHER liegenden Datenpunkt interpolieren}
           InterpolationsDetektor := -1;
           HauptAnteil := 1 - ABS(FRAC(DetektorShift[TmpI2]*EPass/Schrittweite));
          END
         ELSE
          BEGIN {Es wurde aufgerundet => ich muss mit einem um eine Schrittweite IM INDEX NIEDRIGER liegenden Datenpunkt interpolieren}
           InterpolationsDetektor := 1;
           HauptAnteil := ABS(FRAC(DetektorShift[TmpI2]*EPass/Schrittweite));
          END;{IF}
         InterpolationsDetektor := InterpolationsDetektor * SIGN(FRAC(DetektorShift[TmpI2])); {Der Detektor-Versatz kann ja positiv oder negativ sein. Bei negativem Versatz muss ich die Richtung umkehren !}
         IF InterpolationsDetektor = 0 THEN TmpR := TmpR + CountListe2[Index]   {Wenn der Messpunkt die tatsächliche Channeltronenergie trifft, dann brauche ich nicht zu interpolieren !}
          ELSE BEGIN
            TmpR := TmpR + HauptAnteil * CountListe2[Index]; {Index zeigt ja immer auf den am nähesten an der Energie liegenden Messpunkt. Von da muss also der Hauptteil (>0,5) kommen}
            IF ((Index + InterpolationsDetektor*NrDetektoren) < 0) OR ((Index + InterpolationsDetektor*NrDetektoren) > (AnzahlCounts-1)) THEN InterpolationsDetektor := 0; {Sollte der Datenpunkt außerhalb der Liste liegen, also nicht mitgemessen worden sein, dass nehme ich einfach den mit Index spezifizierten Punkt zu 100%}
            TmpR := TmpR + (1-HauptAnteil) * CountListe2[Index + InterpolationsDetektor*NrDetektoren]; {Index zeigt ja immer auf den am nähesten an der Energie liegenden Messpunkt. Von da muss also der Hauptteil (>0,5) kommen}
          END;{IF}
        END
       ELSE
        BEGIN {Specs-Methode: nicht interpolieren, sondern die Channeltron-Zählrate, die dem aktuellen Messpunkt am nähesten liegt voll dem Messpunkt zuordnen}
           {TmpS := IntToStr(CountListe2[Index]);}     {neu###}
           {Application.MessageBox(@TmpS[1],'Error ...',mb_Ok);  }
         TmpR := TmpR + CountListe2[Index];   {Zählraten der Einzelchanneltrons addieren}
        END;{IF}
       IF ChanneltronEinzeln THEN TmpCH[TmpI2] := CountListe2[Index]; {Falls Zählraten der Einzelchanneltrons auch gewünscht, dann diese aufheben}
      END; {FOR TmpI2}
     {Nun Werte-Liste aufbauen}
     IF Werte = NIL THEN
      BEGIN {1. Werte-Paar => Wurzelzeiger "Werte" zuweisen}
       Werte := NEW(PWert);
       P1 := Werte;
      END
     ELSE
      BEGIN {2. oder folgendes Werte-Paar}
       P1^.Next := NEW(PWert);
       P1 := P1^.Next;
      END;{IF}
     P1^.Next := NIL;
     P1^.Counts := TmpR;
     IF Hauptfenster.CB_DivScans.Checked THEN P1^.Counts := P1^.Counts / Scans;
     IF Hauptfenster.CB_DivLifeTime.Checked THEN P1^.Counts := P1^.Counts / Torzeit;
     IF ChanneltronEinzeln THEN
      BEGIN {Falls Zählraten der Einzelchanneltrons auch gewünscht, dann diese in die 2d-Liste Channels eintragen}
       IF Channels = NIL THEN
        BEGIN {1. Werte-Paar => Wurzelzeiger "Channels" zuweisen}
         Channels := NEW(PChannel);
         P1Channels := Channels;
        END
       ELSE
        BEGIN {2. oder folgendes Werte-Paar}
         P1Channels^.Next := NEW(PChannel);
         P1Channels := P1Channels^.Next;
        END;{IF}
       P1Channels^.Next := NIL;
       P1Channels^.CH := TmpCH; {Ich weise gleich das ganze Array zu}
      END;{IF}
    END; {FOR TmpI}
   IF CountListe <> NIL THEN
      BEGIN             {neu###}
       {GlobalUnlock(bufferhandle);
       GlobalFree(bufferhandle);  }
       {Freemem(CountListe);  }
      { VirtualFree(CountListe, 0, MEM_FREE);}
      SetLength(CountListe2, 0);
       {GlobalFree(HGLOBAL(CountListe));} {Speicher für die Liste der Counts der einzelnen Channeltrons freigeben}
      END;
   Importieren := 0;
  END;


 CONSTRUCTOR TExperiment.Create;
  BEGIN
   AnzahlRegionen := 0;
   ExperimentName := '';
   Regionen := NIL;
  END;


 FUNCTION TExperiment.Importieren(DateiName:STRING):INTEGER;

  VAR
   F         :TEXT;
   R1,
   AktRegion :TRegion;

  BEGIN
   AnzahlRegionen := 0;
   IF Regionen <> NIL THEN Regionen.Free;
   AssignFile(F,DateiName);
   ReSet(F);
   {$I-}
   ReadLn(F,ExperimentName);
   {$I+}
   IF IOResult <> 0 THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Could not read experiment name';
     CloseFile(F);
     Importieren := 1;
     EXIT;
    END;
   AktRegion := NIL;
   WHILE NOT EOF(F) DO
    BEGIN
     INC(AnzahlRegionen);
     R1 := TRegion.Create;
     IF AktRegion = NIL THEN Regionen := R1 {die 1. Region wird importiert}
                        ELSE AktRegion.NextRegion := R1; {weitere Regionen werden importiert}
     AktRegion := R1;
     IF AktRegion.Importieren(F) <> 0 THEN
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       CloseFile(F);
       Importieren := 1;
       EXIT;
      END;
    END;{WHILE}
   CloseFile(F);
   IF AnzahlRegionen > 0 THEN Importieren := 0;
    {Manchmal kann er nämlich den ExperimentNamen lesen, trotzdem es
     keinen richtige Importdatei ist und es ist dann auch gleich EOF=True.
     Dann würde nicht versuchen, auch nur eine Region einzulesen und das
     Ergebnis wäre so trotzdem, dass der Import geglückt sei. Deshalb diese
     Abfrage der Regionen. Sollten keine Regionen Importiert worden sein,
     dann ist der Import auch nicht gelückt !}
  END;


 FUNCTION TExperiment.Exportieren(ImportDatei,ExportDatei:STRING; VAR ErzeugteDateien:TStrings):INTEGER;

  VAR
   Dateien,
   Code       :INTEGER;
   AktRegion  :TRegion;
   TmpS,
   D,N,E,
   D2,N2,E2,
   ExportName :STRING;
   F          :TEXT;

  LABEL
   NaechsteRegion, Abbrechen;

  BEGIN
   AktRegion := Regionen;
   Dateien := 0;
{   IF ErzeugteDateien = NIL THEN ErzeugteDateien.Create
                            ELSE ErzeugteDateien.Clear;}
   WHILE AktRegion <> NIL DO
    BEGIN
     FSplit(ExportDatei,D,N,E);
     FSplit(ImportDatei,D2,N2,E2);
     WHILE LENGTH(E2) < ProgrammOptionen.MinStellen DO E2 := '0' + E2;
     IF AnzahlRegionen = 1 THEN ExportName := D + '\' + N2 + E2 + '.' + E
                           ELSE ExportName := D + '\' + N2 + E2 + CHR(Dateien + 97) + '.' + E;
     IF DateiExistNotEmpty(ExportName) THEN
      BEGIN
       Tmps := 'The File ' + ExportName + ' already exists ! Overwrite ?' + #0;
       CASE MessageBox(0,@TmpS[1],'IO-Error',mb_YesNoCancel + mb_IconStop) OF
        IDNO:GOTO NaechsteRegion;
        IDCANCEL:BEGIN
                  Exportieren := 1;
                  GOTO Abbrechen;
                 END;
        END;{CASE}
      END;{IF}
     AssignFile(F,ExportName);
     {$I-}
     ReWrite(F);
     {$I+}
     IF IOResult <> 0 THEN
      REPEAT
       IF NOT InputQuery('Error in Filename ...','Filename wrong ! Please enter new Filename :',ExportName)
        THEN
         BEGIN
          Exportieren := 1;
          GOTO Abbrechen;
         END;
       AssignFile(F,ExportName);
       {$I-}
       ReWrite(F);
       {$I+}
      UNTIL IOResult = 0;
     INC(Dateien);
     TmpS := '"' + ExportName + '" ' + AktRegion.GetInfoString;
     ErzeugteDateien.Add(TmpS);
     FSplit(ExportName,D,N,E);
     WriteLn(F,'  EBind ',GetORIGINFormat(N),' EKin'); {ab Origin6 muss der Name für die Spalten in der 1.Zeile sein !}
     WriteLn(F,'% ESCA-Spektrum');
     WriteLn(F,'% Original-Datei: ' + ImportDatei);
     WriteLn(F,'% Region-Tag: ' + AktRegion.RegionName);
     AktRegion.Exportieren(F);
     CloseFile(F);
     NaechsteRegion:
     AktRegion := AktRegion.NextRegion;
    END;{WHILE}
   Exportieren := 0;
  Abbrechen:
  END;

 DESTRUCTOR TExperiment.Free;
  BEGIN
   IF Regionen <> NIL THEN Regionen.Free;
   Regionen := NIL;
  END;


 FUNCTION TExperimentORIGIN.Importieren(DateiName:STRING):INTEGER;
 {Einzigster Unterschied zu TExperiment.Importieren: "R1 := TRegion.Create;" in "R1 := TRegionORIGIN.Create;" umgewandelt !}

  VAR
   F         :TEXT;
   R1,
   AktRegion :TRegion;

  BEGIN
   AnzahlRegionen := 0;
   IF Regionen <> NIL THEN Regionen.Free;
   AssignFile(F,DateiName);
   ReSet(F);
   {$I-}
   ReadLn(F,ExperimentName);
   {$I+}
   IF IOResult <> 0 THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Could not read experiment name !';
     CloseFile(F);
     Importieren := 1;
     EXIT;
    END;
   AktRegion := NIL;
   WHILE NOT EOF(F) DO
    BEGIN
     INC(AnzahlRegionen);
     R1 := TRegionORIGIN.Create;
     IF AktRegion = NIL THEN Regionen := R1 {die 1. Region wird importiert}
                        ELSE AktRegion.NextRegion := R1; {weitere Regionen werden importiert}
     AktRegion := R1;
     IF AktRegion.Importieren(F) <> 0 THEN
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       CloseFile(F);
       Importieren := 1;
       EXIT;
      END;
    END;{WHILE}
   CloseFile(F);
   IF AnzahlRegionen > 0 THEN Importieren := 0;
    {Manchmal kann er nämlich den ExperimentNamen lesen, trotzdem es
     keinen richtige Importdatei ist und es ist dann auch gleich EOF=True.
     Dann würde nicht versuchen, auch nur eine Region einzulesen und das
     Ergebnis wäre so trotzdem, dass der Import geglückt sei. Deshalb diese
     Abfrage der Regionen. Sollten keine Regionen Importiert worden sein,
     dann ist der Import auch nicht gelückt !}
  END;


 FUNCTION TExperimentORIGIN.Exportieren(ImportDatei,ExportDatei:STRING; VAR ErzeugteDateien:TStrings):INTEGER;

  VAR
   Dateien,
   Code       :INTEGER;
   AktRegion  :TRegion;
   TmpS,
   D,N,E,
   D2,N2,E2,
   ExportName,
   ORIGINImportFile:STRING;
   F          :TEXT;

  BEGIN
   AktRegion := Regionen;
   Dateien := 0;
{   IF ErzeugteDateien = NIL THEN ErzeugteDateien.Create
                            ELSE ErzeugteDateien.Clear;}
   {Dieser Block war vor der Adaption für den PHOIBOS innerhalb der WHILE-Schleife. Allerdings sehe ich keinen Grund, ihn da zu lassen !!?}
   FSplit(ImportDatei,D2,N2,E2);
   FSplit(ExportDatei,D,N,E);
   WHILE LENGTH(E2) < ProgrammOptionen.MinStellen DO E2 := '0' + E2;
   WHILE LENGTH(N2) + ProgrammOptionen.MinStellen + 2 > 13 DO
    BEGIN{Der WorkSheet-Name setzt sich aus dem Namen der Import-Datei, der Erweiterung (mit Mindestlänge) und max. 2 Zeichen für die Regin ("a" bis "zz") zusammen und darf nicht länger als 13 sein !}
     STR((13-2-ProgrammOptionen.MinStellen):2,TmpS);
     TmpS := 'Import-Filename too long for ORIGIN WorkSheet name. Please reduce to ' + TmpS + ' characters !';
     IF InputQuery('Name too long ...',TmpS,N2) = FALSE THEN
      BEGIN
       Exportieren := 1;
       EXIT;
      END;{IF}
    END;{WHILE}
   {Ende Block}
   WHILE AktRegion <> NIL DO
    BEGIN
     IF AnzahlRegionen = 1 THEN ExportName := N2 + E2
                           ELSE IF Dateien > 25  THEN ExportName := N2 + E2 + CHR((Dateien DIV 26) + 96) + CHR((Dateien MOD 26) + 97)
                                                       {bei Import von PHOIBOS-Daten könnten mehr als 26 Regionen in einem Inportfile auftreten !}
                                                 ELSE ExportName := N2 + E2 + CHR(Dateien + 97);
     AktDATFileName := ExportName; {wird wärend TRegionORIGIN.Export zum generieren des Worksheet-Namens benutzt}
     ORIGINImportFile := D + '\' + OriginMakroName;
     AssignFile(F,ORIGINImportFile);
     {$I-}
     APPEND(F);
     {$I+}
     IF IOResult <> 0 THEN ReWrite(F)   {Falls noch nicht existent, dann neu erzeugen}
                      ELSE WriteLn(F);  {Falls schon da, dann eine Leerzeile einfügen (wg. der Übersichtlichkeit)}
     INC(Dateien);
     TmpS := '"' + GetORIGINFormat(ExportName) + '" ' + AktRegion.GetInfoString;
     ErzeugteDateien.Add(TmpS);
     IF ProgrammOptionen.EnableMovingSizing THEN
       WriteLn(F,'window -t data ',ProgrammOptionen.TemplateMovingSizing,' ',GetORIGINFormat(ExportName),';') {neues Worksheet auf Grundlage des Templates [ProgrammOptionene.TemplateMovingSizing].OTW (falls vorhanden !) mit Namen ExportName erzeugen}
      ELSE
       WriteLn(F,'window -t data ',ProgrammOptionen.TemplateName,' ',GetORIGINFormat(ExportName),';'); {neues Worksheet auf Grundlage des Templates [ProgrammOptionene.TemplateName].OTW (falls vorhanden !) mit Namen ExportName erzeugen}
     WriteLn(F,'worksheet -n 1 EBind;'); {erste Spalte EBind nennen}
     WriteLn(F,'worksheet -n 2 ',GetORIGINFormat(COPY(ExportName,1,MaxColNameLength)),';'); {Zweite Spalte wie das Worksheet nennen / Nur 11 Zeichen sind erlaubt !!!}
     WriteLn(F,'worksheet -c EKin;'); {neue 3. Spalte mit Namen EKin einfügen}
     AktRegion.Exportieren(F);
     IF HauptFenster.cb_ExtraSpalte.Checked THEN
      BEGIN
       WriteLn(F,'worksheet -c ' + GetORIGINFormat(COPY(ExportName,1,7)) + '.CPY;'); {Falls extra Datenspalte gewünscht, diese in den 1. 7 Zeichen wie die Datenspalte nennen + .cpy}
       IF HauptFenster.cb_NormiereExtraSpalte.Checked THEN
        BEGIN
         WriteLn(F,'sum(' + GetORIGINFormat(ExportName) + '_' + GetORIGINFormat(COPY(ExportName,1,MaxColNameLength)) + ');');
         WriteLn(F,GetORIGINFormat(ExportName) + '_' + GetORIGINFormat(COPY(ExportName,1,7)) + '.CPY=(' + GetORIGINFormat(ExportName)+ '_' + GetORIGINFormat(COPY(ExportName,1,MaxColNameLength)) + '-sum.min)/(sum.max-sum.min);');
                 {'WksName_OrgDaten.CPY=(WksName_OrgDate-sum.min)/(sum.max-sum.min)' an ORIGIN senden}
        END
       ELSE WriteLn(F,GetORIGINFormat(ExportName) + '_' + GetORIGINFormat(COPY(ExportName,1,7)) + '.CPY=' + GetORIGINFormat(ExportName)+ '_' + GetORIGINFormat(COPY(ExportName,1,MaxColNameLength))); {'WksName_OrgDaten.CPY=WksName_OrgDate' an ORIGIN senden}
      END;
     CloseFile(F);
     AktRegion := AktRegion.NextRegion;
    END;{WHILE}
   Exportieren := 0;
  END;


 FUNCTION TExperimentORIGINCall.Importieren(DateiName:STRING):INTEGER;
 {Einzigster Unterschied zu TExperiment.Importieren: "R1 := TRegion.Create;" in "R1 := TRegionORIGINCall.Create;" umgewandelt !}

  VAR
   D,N,E     :STRING;
   F         :TEXT;
   R1,
   AktRegion :TRegion;

  BEGIN
   AnzahlRegionen := 0;
   IF Regionen <> NIL THEN Regionen.Free;
   FSplit(DateiName,D,N,E);
   AssignFile(F,DateiName);
   ReSet(F);
   {$I-}
   ReadLn(F,ExperimentName);
   {$I+}
   IF IOResult <> 0 THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Could not read experiment name !';
     CloseFile(F);
     Importieren := 1;
     EXIT;
    END;
   AktRegion := NIL;
   WHILE NOT EOF(F) DO
    BEGIN
     INC(AnzahlRegionen);
     R1 := TRegionORIGINCall.Create(N+'.'+E,ExperimentName);
     IF AktRegion = NIL THEN Regionen := R1 {die 1. Region wird importiert}
                        ELSE AktRegion.NextRegion := R1; {weitere Regionen werden importiert}
     AktRegion := R1;
     IF AktRegion.Importieren(F) <> 0 THEN
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       CloseFile(F);
       Importieren := 1;
       EXIT;
      END;
    END;{WHILE}
   CloseFile(F);
   IF AnzahlRegionen > 0 THEN Importieren := 0;
    {Manchmal kann er nämlich den ExperimentNamen lesen, trotzdem es
     keinen richtige Importdatei ist und es ist dann auch gleich EOF=True.
     Dann würde nicht versuchen, auch nur eine Region einzulesen und das
     Ergebnis wäre so trotzdem, dass der Import geglückt sei. Deshalb diese
     Abfrage der Regionen. Sollten keine Regionen Importiert worden sein,
     dann ist der Import auch nicht gelückt !}
  END;


 FUNCTION TExperimentORIGINCall.Exportieren(ImportDatei,ExportDatei:STRING; VAR ErzeugteDateien:TStrings):INTEGER;

  VAR
   TmpI,
   TmpI2,
   Dateien,
   Code          :INTEGER;
   AktRegion     :TRegion;
   TmpS,
   D,N,E,
   D2,N2,E2,
   ExportName    :STRING;
   F             :TEXT;
   AktADCChannel :PADCChannel;

  BEGIN
   AktRegion := Regionen;
   Dateien := 0;
{   IF ErzeugteDateien = NIL THEN ErzeugteDateien.Create
                            ELSE ErzeugteDateien.Clear;}
   {Dieser Block war vor der Adaption für den PHOIBOS innerhalb der WHILE-Schleife. Allerdings sehe ich keinen Grund, ihn da zu lassen !!?}
   FSplit(ImportDatei,D2,N2,E2);
   FSplit(ExportDatei,D,N,E);
   IF UpperCase(E2) = 'XML' THEN E2 := '' {die Erweiterung der Eingabedatei lautet XML => dann gebe ich die Erweiterung nicht aus}
                            ELSE {Ansonsten könnte es sich um die *.1, *.2, ... Dateien handeln, wo die Erweiterung die Experiment-Nummer angebit => also Ausgeben mit der vorgegebenen Mindestzahl an Stellen}
                             WHILE LENGTH(E2) < ProgrammOptionen.MinStellen DO E2 := '0' + E2;
   WHILE LENGTH(N2) + LENGTH(E2) + 2 > 13 DO
    BEGIN{Der WorkSheet-Name setzt sich aus dem Namen der Import-Datei, der Erweiterung (mit Mindestlänge) und max. 2 Zeichen für die Regin ("a" bis "zz") zusammen und darf nicht länger als 13 sein !}
     STR((13-2-LENGTH(E2)):2,TmpS);
     TmpS := 'Import-Filename too long for ORIGIN WorkSheet name. Please reduce to ' + TmpS + ' characters !';
     IF InputQuery('Name too long ...',TmpS,N2) = FALSE THEN
      BEGIN
       Exportieren := 1;
       EXIT;
      END;{IF}
    END;{WHILE}
   {Ende Block}
   WHILE AktRegion <> NIL DO
    BEGIN
     {Export-Namen zusammen setzen}
     CASE AnzahlRegionen OF
     1:      ExportName := N2 + E2;  {Nur eine Region => keine Buchstaben nötig}
     2..26:  ExportName := N2 + E2 + '0' + CHR(Dateien + 97);  {es reicht ein Buchstabe => ich schreibe ein 0 vornweg, damit man es besser lesen kann !}
     27..676:BEGIN {nun muss ich 2 Buchstaben benutzen. Ich fange wieder mit 0a, 0b, .. an und mache dann mit aa, ab, ac, ... weiter}
              IF Dateien < 26 THEN ExportName := N2 + E2 + '0' + CHR((Dateien MOD 26) + 97)
                              ELSE ExportName := N2 + E2 + CHR((Dateien DIV 26) + 96) + CHR((Dateien MOD 26) + 97);
             END;

     ELSE    BEGIN
              Application.MessageBox('To many regions in File (>676) !','Error ...',mb_Ok);
              EXIT;
             END;
      END;{CASE}
     AktDATFileName := ExportName; {wird wärend TRegionORIGINCall.Export zum generieren des Worksheet-Namens benutzt}
     INC(Dateien);
     TmpS := '"' + GetORIGINFormat(ExportName) + '" ' + AktRegion.GetInfoString;
     ErzeugteDateien.Add(TmpS);
     IF ProgrammOptionen.EnableMovingSizing THEN
       SendToOrigin('window -t data ' + ProgrammOptionen.TemplateMovingSizing + ' ' + GetORIGINFormat(ExportName) + ';') {neues Worksheet auf Grundlage des Templates [ProgrammOptionen.TemplateMovingSizing].OTW (falls vorhanden !) mit Namen ExportName erzeugen}
      ELSE
       SendToOrigin('window -t data ' + ProgrammOptionen.TemplateName + ' ' + GetORIGINFormat(ExportName) + ';'); {neues Worksheet auf Grundlage des Templates [ProgrammOptionen.TemplateName].OTW (falls vorhanden !) mit Namen ExportName erzeugen}
     SendToOrigin('worksheet -n 1 EBind;'); {erste Spalte EBind nennen}
     SendToOrigin('worksheet -n 2 ' + GetORIGINFormat(COPY(ExportName,1,MaxColNameLength)) + ';'); {Zweite Spalte wie das Worksheet nennen / Nur 11 Zeichen sind erlaubt !!!}
     SendToOrigin('worksheet -c EKin;'); {neue 3. Spalte mit Namen EKin einfügen}
     IF AktRegion.ChanneltronEinzeln THEN
      BEGIN {Falls ich auch noch die einzelnen Channeltrons speichern soll (geht erst ab XML-Import !), muss ich noch eine Spalte für jedes Channeltron hinzufügen}
       FOR TmpI := 1 TO AktRegion.NrDetektoren DO
        BEGIN
         SendToOrigin('worksheet -c Ch' + IntToStr(TmpI) +  ';'); {für jedes Channeltron eine neue Spalte mit dem Namen "Chx" einfügen}
        END;{FOR TmpI}
      END;{IF}
     {Falls es ADC-Werte gibt, auch für diese Spalten generieren}
     AktADCChannel := AktRegion.ADCChannel;
     TmpI := 0;
     {In TmpI2 rechne ich aus, wieviele Spalten ich schon im Woksheet habe}
     IF AktRegion.ChanneltronEinzeln THEN TmpI2 := 4 + AktRegion.NrDetektoren
                                     ELSE TmpI2 := 4;
     WHILE AktADCChannel <> NIL DO
      BEGIN
       SendToOrigin('worksheet -c ADC' + IntToStr(TmpI) +  ';'); {für jeden ADC-Kanal eine neue Spalte mit dem Namen "ADCx" einfügen}
       SendToOrigin('wks.col' + IntToStr(TmpI2+TmpI) + '.label$="' + AktADCChannel^.ChannelName + '";'); {Damit setze ich das Label der 2. Spalte}
       SendToOrigin('wks.labels();'); {Damit schalte ich die Anzeige des Labels ein. Mit "wks.labels(0);" kann ich sie übrigens wieder ausschalten}
       INC(TmpI);
       AktADCChannel := AktADCChannel^.NextChannel;
      END;{WHILE}
     STR(AktRegion.ExEnergie,TmpS);
     SendToOrigin('Status.V1=' + TmpS + ';'); {Setze die Eingabezeile (Eigenschaft "V1") im SetEBind-Dialog (Objektaname "Status") auf die Anregungsenergie, die genommen wurde}
     AktRegion.Exportieren(F); {die TEXT-Variable F wird hier nur als DUMMY übergeben !!!}
     IF HauptFenster.cb_ExtraSpalte.Checked THEN
      BEGIN
       SendToOrigin('worksheet -c ' + GetORIGINFormat(COPY(ExportName,1,7)) + '.CPY;'); {Falls extra Datenspalte gewünscht, diese in den 1. 7 Zeichen wie die Datenspalte nennen + .cpy}
       IF HauptFenster.cb_NormiereExtraSpalte.Checked THEN
        BEGIN
         SendToOrigin('sum(' + GetORIGINFormat(ExportName) + '_' + GetORIGINFormat(COPY(ExportName,1,MaxColNameLength)) + ');');
         SendToOrigin(GetORIGINFormat(ExportName) + '_' + GetORIGINFormat(COPY(ExportName,1,7)) + '.CPY=(' + GetORIGINFormat(ExportName)+ '_' + GetORIGINFormat(COPY(ExportName,1,MaxColNameLength)) + '-sum.min)/(sum.max-sum.min);');
                 {'WksName_OrgDaten.CPY=(WksName_OrgDate-sum.min)/(sum.max-sum.min)' an ORIGIN senden}
        END
       ELSE SendToOrigin(GetORIGINFormat(ExportName) + '_' + GetORIGINFormat(COPY(ExportName,1,7)) + '.CPY=' + GetORIGINFormat(ExportName)+ '_' + GetORIGINFormat(COPY(ExportName,1,MaxColNameLength))); {'WksName_OrgDaten.CPY=WksName_OrgDate' an ORIGIN senden}
      END;
     {Jetzt benennen ich, entsprechend des ScanMode, die Spalten um. DAS DARF ICH ERST JETZT MACHEN, WEIL ICH MICH OBERHALB IMMER AUF DIE FESTEN SPALTENNAMEN BEZIEHE !!!}
     CASE AktRegion.ScanMode OF
      ScanMode_FixedTransm:
       BEGIN
        {Ich muss nix machen, weil das ja der Normalfall ist, für den alles schon gesetzt ist}
       END;
      ScanMode_FixedEnerg:
       BEGIN
        SendToOrigin('worksheet -n 1 Time;'); {erste Spalte EBind nennen}
        SendToOrigin('Status.Enable=0'); {Deaktiviert den SetEBind-Dialog (Objektaname "Status")}
       END;
      ScanMode_CFS:
       BEGIN
        SendToOrigin('worksheet -n 1 hn;'); {erste Spalte hn nennen}
        SendToOrigin('Status.Enable=0'); {Deaktiviert den SetEBind-Dialog (Objektaname "Status")}
       END;
      ScanMode_CIS:
       BEGIN
        SendToOrigin('worksheet -n 1 hn;'); {erste Spalte hn nennen}
        SendToOrigin('Status.Enable=0'); {Deaktiviert den SetEBind-Dialog (Objektaname "Status")}
       END;
      ScanMode_Detector:
       BEGIN
        SendToOrigin('worksheet -n 1 DetectorHV;'); {erste Spalte hn nennen}
        SendToOrigin('Status.Enable=0'); {Deaktiviert den SetEBind-Dialog (Objektaname "Status")}
       END;
      END;{CASE}
     AktRegion := AktRegion.NextRegion;
    END;{WHILE}
   Exportieren := 0;
  END;



 FUNCTION TExperimentORIGINCallPHOIBOS.Importieren(DateiName:STRING):INTEGER;
 {Stammt von TExperimentORIGINCall ab | Importiert nun die Export-Dateien vom Specs-PHOIBOS-Analysator der SoLiAS}

  VAR
   D,N,E,
   TmpS      :STRING;
   F         :TEXT;
   R1,
   AktRegion :TRegion;

  BEGIN
   AnzahlRegionen := 0;
   IF Regionen <> NIL THEN Regionen.Free;
   FSplit(DateiName,D,N,E);
   AssignFile(F,DateiName);
   ReSet(F);
   {$I-}
   ReadLn(F,ExperimentName);
   {$I+}
   IF (IOResult <> 0) OR (Copy(ExperimentName,1,8) <> '# Group:') THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Could not read experiment name !';
     CloseFile(F);
     Importieren := 1;
     EXIT;
    END;
   ExperimentName := Copy(ExperimentName,9,255);
   ReadLn(F,TmpS); {Zwischen dem Experiment-Namen und der 1. Region kommt eine Leerzeile}
   AktRegion := NIL;
   WHILE NOT EOF(F) DO
    BEGIN
     INC(AnzahlRegionen);
     R1 := TRegionORIGINCallPHOIBOS.Create(N+'.'+E,ExperimentName);
     IF AktRegion = NIL THEN Regionen := R1 {die 1. Region wird importiert}
                        ELSE AktRegion.NextRegion := R1; {weitere Regionen werden importiert}
     AktRegion := R1;
     IF AktRegion.Importieren(F) <> 0 THEN
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       CloseFile(F);
       Importieren := 1;
       EXIT;
      END;
     ReadLn(F,TmpS); {Nach jeder Region kommt noch eine Leerzeile, die ich auch auslesen muss, damit EOF(F) auch tatsächlich das Ende der Datei richtig erkennt}
    END;{WHILE}
   CloseFile(F);
   IF AnzahlRegionen > 0 THEN Importieren := 0;
    {Manchmal kann er nämlich den ExperimentNamen lesen, trotzdem es
     keinen richtige Importdatei ist und es ist dann auch gleich EOF=True.
     Dann würde nicht versuchen, auch nur eine Region einzulesen und das
     Ergebnis wäre so trotzdem, dass der Import geglückt sei. Deshalb diese
     Abfrage der Regionen. Sollten keine Regionen Importiert worden sein,
     dann ist der Import auch nicht gelückt !}
  END;


 FUNCTION TExperimentORIGINCallPHOIBOS_XML.Importieren(DateiName:STRING):INTEGER;
 {Stammt von TExperimentORIGINCallPHOIBOS ab | Importiert nun die XML-Dateien vom Specs-PHOIBOS-Analysator der SoLiAS}

  VAR
   TmpI      :INTEGER;
   D,N,E,
   AktGroupName,
   TmpS      :STRING;
   F         :TEXT;
   R1,
   AktRegion :TRegion;
   RegionGeradeErfolgreichImportiert :BOOLEAN; {Das signalisiert der Kommentar-Einleseroutine, dass im aktuellen Durchlauf gerade eine Region importier wurde}

  CONST
   XMLDocumentIdentifier1 = '<!-- CORBA XML document created by XMLSerializer 1.3'; {25.03.2008: Specs hat hinten noch weitere Infos rangeschrieben, so dass ich " -->" hinten weg nehmen musste}
   XMLDocumentIdentifier2 = '<!-- CORBA XML document created by XMLSerializer2 1.3'; {25.08.2009: Marcel Michling benutzt die Version 2.44-r16040 built 2009-06-29 10:08:07 UTC von SpecLab, und da steht nun wieder eine 2 nach Serializer, also habe ich einen 2. Identifier eingeführt !}
                            {<!-- CORBA XML document created by XMLSerializer 1.3 at 2010-11-29 10:07:46 UTC, from SL 2.38-r14523 built 2009-01-13 15:11:34 UTC -->}
                            {<!-- CORBA XML document created by XMLSerializer2 1.3 at 2010-12-02 22:46:50 UTC, from SL 2.53-r17444 built 2010-03-18 08:03:38 UTC -->}

   XMLDocumentIdentifier3 = '<!-- CORBA XML document created by XMLSerializer2 1.6';


   MarkerGroupIdentifier = '<struct type_id="IDL:specs.de/Serializer/RegionGroup:1.0" type_name="RegionGroup">';
   MarkerRegionIdentifier = '<struct type_id="IDL:specs.de/Serializer/RegionData:1.0" type_name="RegionData">';
   MarkerKommentarIdentifier = '<string name="name">Comment</string>';

  BEGIN
   AnzahlRegionen := 0;
   IF Regionen <> NIL THEN Regionen.Free;
   AssignFile(F,DateiName);
   {$I-}
   ReSet(F);
   {$I+}
   IF IOResult <> 0 THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Could not open XML file !';
     Importieren := 1;
     EXIT;
    END;
   {$I-}
   ReadLn(F,TmpS); {erste Zeile teste ich nicht}
   {$I+}
   IF IOResult <> 0 THEN
    BEGIN {Scheint keine gültige Importdatei zu sein !}
     GlobalImportErrorStr := 'Could not read from XML file !';
     CloseFile(F);
     Importieren := 1;
     EXIT;
    END;
   ReadLn(F,TmpS); {zweite Zeile sollte den Identifier enthalten / da es mindestens seit Version 2.44-r16040 vom 29.06.2009 noch einen leicht abweichenden gibt, prüfe ich auch auf den}
   IF COPY(TmpS,1,LENGTH(XMLDocumentIdentifier1)) <> XMLDocumentIdentifier1 THEN
    IF COPY(TmpS,1,LENGTH(XMLDocumentIdentifier2)) <> XMLDocumentIdentifier2 THEN   {Das geht noch nicht, da gibts noch Verschiebungsprobleme !}
     IF COPY(TmpS,1,LENGTH(XMLDocumentIdentifier3)) <> XMLDocumentIdentifier3 THEN
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       GlobalImportErrorStr := 'Seems to be no XML file or created with the wrong XMLSerializer (V1.3 was expected) !';
       CloseFile(F);
       Importieren := 1;
       EXIT;
      END;
   FSplit(DateiName,D,N,E);
   ExperimentName := N + '.' + E; {Der Experiment-Name hier beim XML-Import ist immer der Name der XML-Datei}
   AktRegion := NIL;
   TmpS := '';
   AnzahlRegionen := 0;
   RegionGeradeErfolgreichImportiert := FALSE; {Das signalisiert der Kommentar-Einleseroutine, dass im aktuellen Durchlauf gerade eine Region importier wurde / am Anfang der Schleife muss ich es auf FALSE setzen}
   WHILE NOT EOF(F) DO
    BEGIN
     {Zunächst einmal die nächste Gruppen- oder Region-Info-Struktur suchen}
     WHILE (NOT EOF(F)) AND (TmpS<>MarkerGroupIdentifier) AND (TmpS<>MarkerRegionIdentifier) AND (TmpS<>MarkerKommentarIdentifier) DO ReadLn(F,TmpS);

     IF EOF(F) AND (AnzahlRegionen=0) THEN
      BEGIN {Scheint keine gültige Importdatei zu sein !}
       GlobalImportErrorStr := 'Reached end of XML file without any data !';
       CloseFile(F);
       Importieren := 1;
       EXIT;
      END;
     IF TmpS = MarkerGroupIdentifier THEN
      BEGIN {eine neue Gruppe soll beginnen => Gruppennamen auslesen}
       RegionGeradeErfolgreichImportiert := FALSE; {Das signalisiert der Kommentar-Einleseroutine, dass im aktuellen Durchlauf gerade eine Region importier wurde / Sobald was neues (Gruppe, Region, Kommentar) gufunden wurde, muss ich es auf FALSE setzen}
       ReadLn(F,TmpS);
       IF COPY(TmpS,1,20) <> '<string name="name">' THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         GlobalImportErrorStr := 'Unexpected format while reading group name !';
         CloseFile(F);
         Importieren := 1;
         EXIT;
        END;
       AktGroupName := COPY(TmpS,21,LENGTH(TmpS)-20-9);  {Die 21 ist die Länge von '<string name="name">' am Anfang der Zeile plus 1 und die 9 ist die Länge von '</string>' am Ende der Zeile}
      END; {IF}
     IF TmpS = MarkerRegionIdentifier THEN
      BEGIN {eine neue Region soll beginnen => Region importieren}
       TmpS := '';
       RegionGeradeErfolgreichImportiert := FALSE; {Das signalisiert der Kommentar-Einleseroutine, dass im aktuellen Durchlauf gerade eine Region importier wurde / Sobald was neues (Gruppe, Region, Kommentar) gufunden wurde, muss ich es auf FALSE setzen}
       R1 := TRegionORIGINCallPHOIBOS_XML.Create(ExperimentName,AktGroupName,ProgrammOptionen.ChanneltronEinzeln);
       TmpI := R1.Importieren(F);
       IF (TmpI <> 0) AND (TmpI <> RegionImport_RegionNichtGemessen) AND (TmpI <> RegionImport_foundGroup) AND (TmpI <> RegionImport_foundRegion) AND (TmpI <> RegionImport_foundComment) THEN
        BEGIN {Scheint keine gültige Importdatei zu sein !}
         {CloseFile(F); Das macht schon TRegion.Importieren ! Ein zweites mal Schließen führt zu E/A-Fehler 103 !}
         Importieren := 1;
         R1.Free;
         EXIT;
        END;


        IF TmpI = RegionImport_foundGroup THEN
         BEGIN
          TmpS := MarkerGroupIdentifier;
          R1.Free;
         END;
        IF TmpI = RegionImport_foundRegion THEN
         BEGIN
          TmpS := MarkerRegionIdentifier;
          R1.Free;
         END;
        IF TmpI = RegionImport_foundComment THEN
         BEGIN
          TmpS := MarkerKommentarIdentifier;
          R1.Free;
         END;

       IF TmpI = 0 THEN
        BEGIN {Alles Ok, Region wurde importiert => In Liste einreihen}
         IF AktRegion = NIL THEN Regionen := R1 {die 1. Region wird importiert}
                            ELSE AktRegion.NextRegion := R1; {weitere Regionen werden importiert}
         AktRegion := R1;
         INC(AnzahlRegionen);
         RegionGeradeErfolgreichImportiert := TRUE; {Das signalisiert der unten stehenden Kommentar-Importroutine, dass gerade eine neue Region import wurde, also der Kommentar auch für die gerade importierte Region einglsen werden kann. Manchmal stehen nämlich keine Daten in der Region, ich importiere sie also nicht. Aber trotzdem gibt es einen Kommentar. Dann bekomme ich natürlich eine Schutzverletzung, wenn ich den Kommentar importiere (wenn es gleich die erste Region ist) bzw. packe ich den Kommentar in die falsche Region, nämlich die, die als letzte importiert wurde !}
        END;{IF}
       IF TmpI = RegionImport_RegionNichtGemessen THEN R1.Free;

       {IF (TmpI<>RegionImport_foundGroup) OR (TmpI<>RegionImport_foundRegion) OR (TmpI<>RegionImport_foundComment) THEN TmpS := '';} {Denn sonst hat er in der While-Schleife gleich wieder TmpS = MarkerRegionIdentifier !}
      END; {IF}
     IF TmpS = MarkerKommentarIdentifier THEN
      BEGIN {Ein Kommentar wurde gefunden ! Die stehen leider nicht bei den Region-Eigenschaften, sondern ganz am Ende einer Region, nachden Daten und auch nach den ganzen komischen SkalingFactors. Deswegen werte ich sie auch hier in TExperiment nachträglich zum Regionen-Import aus !}
       IF RegionGeradeErfolgreichImportiert THEN
        BEGIN {Ein Kommentar wurde gefunden und es wurde gerade eine Region importier => ich kann also den gerade gefundenen Kommentar zu der aktuellen Region dazulesen}
         RegionGeradeErfolgreichImportiert := FALSE; {Das signalisiert der Kommentar-Einleseroutine, dass im aktuellen Durchlauf gerade eine Region importier wurde / Sobald was neues (Gruppe, Region, Kommentar) gufunden wurde, muss ich es auf FALSE setzen}
         ReadLn(F,TmpS); {nächste Zeile lesen. Da muss drinstehen '<any name="value">'}
         IF COPY(TmpS,1,18) <> '<any name="value">' THEN
          BEGIN {Scheint keine gültige Importdatei zu sein !}
           GlobalImportErrorStr := 'Unexpected format while reading Region Comment !';
           CloseFile(F);
           Importieren := 1;
           EXIT;
          END;
         ReadLn(F,TmpS); {nächste Zeile lesen. Die beginnt mit <string> und dann beginnt der Kommentar, bis wieder eine </string> kommt. Dazwischen ist alles Kommentar. Das können auch mehrere Zeilen sein}
         IF COPY(TmpS,1,8) <> '<string>' THEN
          BEGIN {Scheint keine gültige Importdatei zu sein !}
           GlobalImportErrorStr := 'Unexpected format while reading Region Comment !';
           CloseFile(F);
           Importieren := 1;
           EXIT;
          END;
         TmpS := COPY(TmpS,9,255); {vorn das <string> abschneiden}
         AktRegion.RegionName := AktRegion.RegionName + '\nComment: \n';
         WHILE (NOT EOF(F)) AND (COPY(TmpS,LENGTH(TmpS)-8,9) <> '</string>') DO
          BEGIN
           AktRegion.RegionName := AktRegion.RegionName + '> ' + TmpS + ' \n'; {Ich habe das Leerzeichen vor der Zeilenendenmarke \n eingefügt, weil Origin manchmal das letzte Zeichen einer Zeile verschluckt hat}
           ReadLn(F,TmpS);
          END;
         AktRegion.RegionName := AktRegion.RegionName + '> ' + COPY(TmpS,1,LENGTH(TmpS)-9);
        END
       ELSE
        BEGIN {Ein Kommentar wurde zwar gefunden, aber keine Region wurde gerade eingelesen (kann z.B. sein, dass die Region leer war aber totzdem ein Kommentar drin stand, oder dass es ein Kommantar zu einer neuen Gruppe war) => nicht einlesen}
         TmpS := ''; {Das muss ich machen, sonst hängt er sich hier in der While-Schleife auf: TmpS enthält ja noch den Kommentar-Marker, es wird also keine neue Zeile gelesen. Aber der Kommentar wird auch nicht ausgelesen, denn es gab ja keine aktuell gelesenen Region vorher !}
        END;{IF}
      END;{IF}
    END;{WHILE}
   CloseFile(F);
   IF AnzahlRegionen > 0 THEN Importieren := 0;
  END;


 procedure THauptFenster.BT_ImportNameClick(Sender: TObject);
  VAR S1,S2:STRING;
  begin
   OpenDialog1.InitialDir := IniImportVerzeichnis;
   IF RBDataSource_Spectra.Checked THEN OpenDialog1.FileName := '*.*';
   IF RBDataSource_Phoibos.Checked THEN OpenDialog1.FileName := '*.xy';
   IF RBDataSource_PhoibosXML.Checked THEN OpenDialog1.FileName := '*.xml';
   OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist];
   IF OpenDialog1.Execute THEN
    IF OpenDialog1.Files.Count > 1 THEN
     BEGIN
      MultipleFilesSelected := TRUE;
      BT_Alles.Enabled := FALSE;
      IL_ImportName.Text := '*** multiple Files selected ***';
      FSplit(OpenDialog1.FileName,IniImportVerzeichnis,S1,S2); {Damit er beim nächsten Aufruf des OpenFile-Dialog wieder in das letzte Verzeichnis geht}
     END
    ELSE
     BEGIN
      MultipleFilesSelected := FALSE;
      IF RBDataSource_Spectra.Checked THEN BT_Alles.Enabled := TRUE; {Nur wenn nicht Omicron-SPECTRA-Import angewählt ist, darf ich den Ganze-Verzeichnisse-Knopf aktivieren}
      IL_ImportName.Text := OpenDialog1.FileName;
      FSplit(OpenDialog1.FileName,IniImportVerzeichnis,S1,S2); {Damit er beim nächsten Aufruf des OpenFile-Dialog wieder in das letzte Verzeichnis geht}
     END;{IF}
  end;

 procedure THauptFenster.BT_ExportNameClick(Sender: TObject);
  VAR S1,S2:STRING;
  begin
   SaveDialog1.Filter := 'DAT-File (*.DAT)|*.dat|all Files (*.*)|*.*';
   SaveDialog1.FilterIndex := 1;
   SaveDialog1.InitialDir := IniExportVerzeichnis;
   SaveDialog1.FileName := 'Egal.DAT';
   IF SaveDialog1.Execute THEN IL_ExportName.Text := SaveDialog1.FileName;
   FSplit(SaveDialog1.FileName,IniExportVerzeichnis,S1,S2);
  end;

 procedure THauptFenster.BT_SaveIniClick(Sender: TObject);
  begin
   SaveIniFile;
  end;

 procedure THauptFenster.BT_KonvertierenClick(Sender: TObject);

  VAR
   WeitereIgnorieren :BOOLEAN;
   Strings           :TStrings;
   I                 :INTEGER;
   D,N,E,
   S,TmpS,
   OriginMakroPfad   :STRING;
   Experiment        :TExperiment;
   F                 :FILE;
   LogFile           :TStringList;

  begin
   Strings := InfoFenster.Memo1.Lines;
   InfoFenster.Memo1.Lines.Clear;

   IF CB_Origin.Checked THEN
    BEGIN
     {Zunächst überprüfen, ob das Template sich im ORIGIN-Verzeichnis befindet}
     FSplit(Application.ExeName,D,N,E);
     IF NOT DateiExistNotEmpty(D + '\' + ProgrammOptionen.TemplateName + '.OTW') THEN
      BEGIN
       TmpS := 'You are trying to use a Template named ' + ProgrammOptionen.TemplateName + '.OTW !' + #13;
       TmpS := TmpS + '(refer to "Konvert-Options" !)' + #13;
       TmpS := TmpS + 'This file is not in the ORIGIN-Directory !' + #13;
       TmpS := TmpS + 'Please copy it to the ORIGIN-Directory or change to an existing Template File.' + #13;
       TmpS := TmpS + 'Otherwise Origin.OTW will be used as the Template File.' + #0;
       Application.MessageBox(@TmpS[1],'Attention ...',mb_Ok);
      END;
     {Auch das Moving/Sizing-Template muss sich im ORIGIN-Verzeichnis befinden}
     FSplit(Application.ExeName,D,N,E);
     IF NOT DateiExistNotEmpty(D + '\' + ProgrammOptionen.TemplateMovingSizing + '.OTW') THEN
      BEGIN
       TmpS := 'You are trying to use a Template named ' + ProgrammOptionen.TemplateMovingSizing + '.OTW !' + #13;
       TmpS := TmpS + '(refer to "Konvert-Options" !)' + #13;
       TmpS := TmpS + 'This file is not in the ORIGIN-Directory !' + #13;
       TmpS := TmpS + 'Please copy it to the ORIGIN-Directory or change to an existing Template File.' + #13;
       TmpS := TmpS + 'Otherwise Origin.OTW will be used as the Template File.' + #0;
       Application.MessageBox(@TmpS[1],'Attention ...',mb_Ok);
      END;

     IF ORIGINCall THEN
      BEGIN {Wird als DLL aus ORIGIN heraus aufgerufen}
       IF HauptFenster.RBDataSource_Spectra.Checked THEN Experiment := TExperimentORIGINCall.Create;
       IF HauptFenster.RBDataSource_Phoibos.Checked THEN Experiment := TExperimentORIGINCallPHOIBOS.Create;
       IF HauptFenster.RBDataSource_PhoibosXML.Checked THEN Experiment := TExperimentORIGINCallPHOIBOS_XML.Create;
      END
     ELSE
      BEGIN {Origin-Makro soll erzeugt werden und das Programm wird NICHT über die DLL aus ORIGIN heraus aufgerufen}
       FSplit(IL_ExportName.Text,D,N,E);
       OriginMakroPfad := D + '\' + OriginMakroName;
       IF DateiExistNotEmpty(OriginMakroPfad) THEN
        BEGIN
         S := 'The File ' + OriginMakroPfad + ' for the Origin-Macro already exists ! Append (Ja) or Overwrite (Nein) ?' + #0;
         CASE MessageBox(0,@S[1],'Question ...',mb_YesNoCancel) OF
          idCancel:EXIT;
          idYes:BEGIN{Nix zu machen, angehängt wird dann automatisch}
                END;
          idNo:BEGIN {Die Datei löschen}
                AssignFile(F,OriginMakroPfad);
                Erase(F);
               END;
          END;{CASE}
        END;{IF}
       IF HauptFenster.RBDataSource_Spectra.Checked THEN Experiment := TExperimentORIGIN.Create;
       IF HauptFenster.RBDataSource_Phoibos.Checked OR HauptFenster.RBDataSource_PhoibosXML.Checked THEN
        BEGIN
         Application.MessageBox('PHOIBOS-Import not possible !','Error ...',mb_Ok);
         EXIT;
        END;
      END;
    END
   ELSE
    BEGIN
     IF HauptFenster.RBDataSource_Spectra.Checked THEN Experiment := TExperiment.Create;
     IF HauptFenster.RBDataSource_Phoibos.Checked OR HauptFenster.RBDataSource_PhoibosXML.Checked THEN
      BEGIN
       Application.MessageBox('PHOIBOS-Import not possible !','Error ...',mb_Ok);
       EXIT;
      END;
    END;

   IF NOT MultipleFilesSelected THEN
    BEGIN
     IF Experiment.Importieren(IL_ImportName.Text) <> 0 THEN
      BEGIN {Funktion Importiren meldet: keine gültige Importdatei !}
       S := 'The File ' + IL_ImportName.Text + ' seems to be no valid Import File !' + #13 + #10;
       S := S + '{' + GlobalImportErrorStr + '}' + #0;
       MessageBox(0,@S[1],'Error ...',mb_Ok + mb_IconStop);
       Experiment.Free;
       EXIT;
      END;
     Experiment.Exportieren(IL_ImportName.Text,IL_ExportName.Text,Strings);
     Experiment.Free;
     STR(InfoFenster.Memo1.Lines.Count:2,S);
     IF CB_Origin.Checked THEN InfoFenster.Label1.Caption := 'Executing the Origin-Macro ' + D + '\' + OriginMakroName + ' the following ' + S + ' Worksheet(s) will be created :'
                          ELSE InfoFenster.Label1.Caption := 'The following ' + S + ' Files were created :';
     InfoFenster.ShowModal;
    END
   ELSE
    BEGIN {mehrere Dateien wurden ausgewählt}
     {alle Dateien in der Liste OpenDialog1.Files umwandeln}
     WeitereIgnorieren := FALSE; {Gibt an, ob Dateien, die nicht importiret werden können ignoriert werden sollen, oder ob nachgefragt werden soll}
     LogFile := TStringList.Create;
     LogFile.Clear;
     StatusFenster.Show; {Zunächst Status-Fenster anzeigen}
     FOR I := 0 TO OpenDialog1.Files.Count-1 DO
      BEGIN
       StatusFenster.Label1.Caption := OpenDialog1.Files.Strings[I];
       StatusFenster.Refresh;

       IF CB_Origin.Checked AND NOT ORIGINCall THEN
        BEGIN {Also: Ich rufe das Programm NICHT aus ORIGIN auf und will aber ein ORIGIN-Import-MAKRO erzeugen}
         IF HauptFenster.RBDataSource_Spectra.Checked THEN Experiment := TExperimentORIGIN.Create;
         IF HauptFenster.RBDataSource_Phoibos.Checked OR HauptFenster.RBDataSource_PhoibosXML.Checked THEN
          BEGIN
           Application.MessageBox('PHOIBOS-Import not possible !','Error ...',mb_Ok);
           EXIT;
          END;
        END;
       IF CB_Origin.Checked AND ORIGINCall THEN
        BEGIN {Also: Ich rufe das Programm aus ORIGIN auf und will gleich die Daten an ORIGIN senden}
         IF HauptFenster.RBDataSource_Spectra.Checked THEN Experiment := TExperimentORIGINCall.Create;
         IF HauptFenster.RBDataSource_Phoibos.Checked THEN Experiment := TExperimentORIGINCallPHOIBOS.Create;
         IF HauptFenster.RBDataSource_PhoibosXML.Checked THEN Experiment := TExperimentORIGINCallPHOIBOS_XML.Create;
        END;
       IF NOT CB_Origin.Checked THEN
        BEGIN {Also: Ich rufe das programm nicht aus Origin auf und es sollen Importdateien erstellt werden}
         IF HauptFenster.RBDataSource_Spectra.Checked THEN Experiment := TExperiment.Create;
         IF HauptFenster.RBDataSource_Phoibos.Checked OR HauptFenster.RBDataSource_PhoibosXML.Checked THEN
          BEGIN
           Application.MessageBox('PHOIBOS-Import not possible !','Error ...',mb_Ok);
           EXIT;
          END;
        END;
       Application.MessageBox('Import start','Attention ...',mb_Ok);

       IF Experiment.Importieren(OpenDialog1.Files.Strings[I]) <> 0 THEN
        BEGIN {Funktion Importieren meldet: Keine gültige Importdatei !}
         TmpS := 'The File ' + OpenDialog1.Files.Strings[I] + ' seems to be no valid Import File !' + #13 + #10;
         TmpS := TmpS + '{' + GlobalImportErrorStr + '}' + #13 + #10;
         TmpS := TmpS + 'Ignoring all following non-importable Files (Ja), asking for every following non-importable File to be ignored (Nein) or Cancel (Abbrechen) ?' + #0;
         Experiment.Free;
         IF NOT WeitereIgnorieren THEN
          CASE MessageBox(0,@TmpS[1],'Error ...',mb_YesNoCancel + mb_IconStop) OF
           idCancel:BEGIN {Abbrechen wurde gewählt}
                     LogFile.Free;
                     StatusFenster.Hide;
                     EXIT;
                    END;
           idYes:WeitereIgnorieren := TRUE;
           idNo:WeitereIgnorieren := FALSE;
          END{CASE}
        END
       ELSE
        BEGIN {Import war Ok, jetzt exportieren ...}
               Application.MessageBox('Import war Ok, jetzt exportieren ...','Attention ...',mb_Ok);

         IF CB_Origin.Checked THEN TmpS := 'From the original File ' + OpenDialog1.Files.Strings[I] + ' will be created the following Worksheets by executing the Origin-Macro ' + OriginMakroPfad + ' :'
                              ELSE TmpS := 'From the original File ' + OpenDialog1.Files.Strings[I] + ' have been created the following Files :';
         LogFile.Add(TmpS);
         Delay(250); {Zeit zum Anzeige Aktualisieren}
         IF Experiment.Exportieren(OpenDialog1.Files.Strings[I],IL_ExportName.Text,TStrings(LogFile)) <> 0 THEN
          BEGIN
           Experiment.Free;
           LogFile.Free;
           StatusFenster.Hide;
           EXIT;
          END;
         Experiment.Free;
        END;{ELSE}
       Delay(250);
      END;{FOR I}

     StatusFenster.Hide;
     FSplit(IL_ExportName.Text,D,N,E);
     TmpS := D + '\LogFile.TXT';
     LogFile.SaveToFile(TmpS);
     LogFile.Free;
     TmpS := 'All Files have been converted. A Log-File named ' + TmpS + ' has been created !' + #0;
     MessageBox(0,@Tmps[1],'Note ...',mb_Ok);
    END;
   HauptFenster.SetFocus;
  end;

procedure THauptFenster.BT_ExitClick(Sender: TObject);
begin
 Application.Terminate;
end;

procedure THauptFenster.cb_Origin_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 IF Key = 112 THEN Application.HelpCommand(HELP_CONTEXT, 6);{112 entspricht F1 !}
end;

procedure THauptFenster.cb_ExtraSpalte_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 IF Key = 112 THEN Application.HelpCommand(HELP_CONTEXT, 5);{112 entspricht F1 !}
end;

procedure THauptFenster.BT_AllesClick(Sender: TObject);

 VAR
  WeitereIgnorieren,
  NumberExtentionONLY :BOOLEAN;
  I,Code,TmpI         :INTEGER;
  SearchRec           :TSearchRec;
  OriginMakroPfad,
  D,N,E,
  DD,NN,EE,
  TmpS                :STRING;
  AlleNamen,
  LogFile             :TStringList;
  Experiment          :TExperiment;
  F                   :FILE;

 BEGIN
  IF HauptFenster.RBDataSource_Phoibos.Checked THEN EXIT; {Es ist kein Import des gesamten Verzeichnisses möglich,
                    wenn PHOIBOS-Daten importiert werden sollen. Eigentlich dürfte er dann gar nicht diesen
                    Programmteil aufrufen, da ich den Knopf deaktiviert habe. Aber sicher ist sicher !}
  WeitereIgnorieren := FALSE; {Gibt an, ob Dateien, die nicht importiret werden können ignoriert werden sollen, oder ob nachgefragt werden soll}
  IF CB_Origin.Checked AND NOT ORIGINCall THEN {Zunächst Checken, ob die Origin-Makro-Datei schon existiert, aber nur, wenn nicht als DLL aus ORIGIN heraus aufgerufen}
   BEGIN
    FSplit(IL_ExportName.Text,D,N,E);
    OriginMakroPfad := D + '\' + OriginMakroName;
    IF DateiExistNotEmpty(OriginMakroPfad) THEN
     BEGIN
      TmpS := 'The File ' + OriginMakroPfad + ' for the Origin-Macro already exists ! Append (Ja) or Overwrite (Nein) ?' + #0;
      CASE MessageBox(0,@TmpS[1],'Question ...',mb_YesNoCancel) OF
       idCancel:EXIT;
       idYes:BEGIN{Nix zu machen, angehängt wird dann automatisch}
             END;
       idNo:BEGIN {Die Datei löschen}
             AssignFile(F,OriginMakroPfad);
             Erase(F);
            END;
       END;{CASE}
     END;{IF}
   END;

  {Abfrage, ob nur alle mit Dateien, deren Endung eine Zahl ist, konvertiert werden sollen}
  TmpS:= 'Whould you like to convert only files which have an extention consisting of only numbers (such as *.1 or *.123) ?' + #0;
  IF MessageBox(0,@Tmps[1],'Question ...',mb_YesNo + mb_IconQuestion)=idYes
   THEN NumberExtentionONLY := TRUE
   ELSE NumberExtentionONLY := FALSE;

  FSplit(IL_ImportName.Text,D,N,E);
  TmpS := D + '\*.*';
  IF FindFirst(TmpS,faReadOnly + faHidden + faArchive,SearchRec) <> 0 THEN
   BEGIN
    MessageBox(0,'No Files could be found in the Directory !','Error ...',mb_Ok + mb_IconStop);
    EXIT;
   END;

 {Zunächst alle Dateien im verzeichnis finden und in Stringliste eintragen}
  AlleNamen := TStringList.Create;
  AlleNamen.Clear;
  REPEAT
   TmpS := D + '\' + SearchRec.Name;
   IF NumberExtentionONLY THEN
    BEGIN
     FSplit(SearchRec.Name,DD,NN,EE);
     VAL(EE,TmpI,Code);
     IF Code = 0 THEN AlleNamen.Add(TmpS);
    END
    ELSE AlleNamen.Add(TmpS);
  UNTIL FindNext(SearchRec) <> 0;
  FindClose(SearchRec);

  {Dann alle Dateien umwandeln}
  LogFile := TStringList.Create;
  LogFile.Clear;
  StatusFenster.Show; {Zunächst Status-Fenster anzeigen}
  FOR I := 0 TO AlleNamen.Count-1 DO
   BEGIN
    StatusFenster.Label1.Caption := AlleNamen.Strings[I];
    StatusFenster.Refresh;

    IF CB_Origin.Checked AND NOT ORIGINCall THEN Experiment := TExperimentORIGIN.Create
     ELSE IF CB_Origin.Checked AND ORIGINCall THEN Experiment := TExperimentORIGINCall.Create
      ELSE Experiment := TExperiment.Create;
    IF Experiment.Importieren(AlleNamen.Strings[I]) <> 0 THEN
     BEGIN {Funktion Importieren meldet: Keine gültige Importdatei !}
      TmpS := 'The File ' + AlleNamen.Strings[I] + ' seems to be no valid Import File !' + #13 + #10;
      TmpS := TmpS + '{' + GlobalImportErrorStr + '}' + #13 + #10;
      TmpS := TmpS + 'Ignoring all following non-importable Files (Ja), asking for every following non-importable File to be ignored (Nein) or Cancel (Abbrechen) ?' + #0;
      Experiment.Free;
      IF NOT WeitereIgnorieren THEN
       CASE MessageBox(0,@TmpS[1],'Error ...',mb_YesNoCancel + mb_IconStop) OF
        idCancel:BEGIN {Abbrechen wurde gewählt}
                  AlleNamen.Free;
                  LogFile.Free;
                  StatusFenster.Hide;
                  EXIT;
                 END;
        idYes:WeitereIgnorieren := TRUE;
        idNo:WeitereIgnorieren := FALSE;
       END{CASE}
     END
    ELSE
     BEGIN {Import war Ok, jetzt exportieren ...}
      IF CB_Origin.Checked THEN TmpS := 'From the original File ' + AlleNamen.Strings[I] + ' will be created the following Worksheets by executing the Origin-Macro ' + OriginMakroPfad + ' :'
                           ELSE TmpS := 'From the original File ' + AlleNamen.Strings[I] + ' have been created the following Files :';
      LogFile.Add(TmpS);
      IF Experiment.Exportieren(AlleNamen.Strings[I],IL_ExportName.Text,TStrings(LogFile)) <> 0 THEN
       BEGIN
        Experiment.Free;
        LogFile.Free;
        AlleNamen.Free;
        StatusFenster.Hide;
        EXIT;
       END;
      Experiment.Free;
     END;{ELSE}
   END;{FOR I}

  StatusFenster.Hide;
  FSplit(IL_ExportName.Text,D,N,E);
  TmpS := D + '\LogFile.TXT';
  LogFile.SaveToFile(TmpS);
  LogFile.Free;
  AlleNamen.Free;
  TmpS := 'All Files have been converted. A Log-File named ' + TmpS + ' has been created !' + #0;
  MessageBox(0,@Tmps[1],'Note ...',mb_Ok);
  HauptFenster.SetFocus;
 END;


 procedure THauptFenster.CB_ExtraSpalte_Click(Sender: TObject);
  begin
   IF CB_ExtraSpalte.Checked THEN
    BEGIN
     CB_NormiereExtraSpalte.Enabled := TRUE;
     CB_EnableMovingSizing.Enabled := TRUE;
    END
   ELSE
    BEGIN
     CB_NormiereExtraSpalte.Enabled := FALSE;
     CB_EnableMovingSizing.Enabled := FALSE;
    END;
  end;


 procedure THauptFenster.BT_OptionsClick(Sender: TObject);

  VAR
   B         :BYTE;
   Code,
   Result    :INTEGER;
   R         :REAL;
   D, N, E,
   D2, N2, E2,
   TmpS      :STRING;
   SearchRec :TSearchRec;

  LABEL
   DialogAusfuehren;

  begin
   {Dialog-Felder setzen}
   STR(ProgrammOptionen.MinStellen,TmpS);
   OptionenFenster.il_MinStellen.Text := TmpS;
   OptionenFenster.il_TemplateName.Text := ProgrammOptionen.TemplateName + '.OTW';
   OptionenFenster.il_TemplateMovingSizing.Text := ProgrammOptionen.TemplateMovingSizing + '.OTW';
   OptionenFenster.cb_IncludeAnalyserParameter.Checked := ProgrammOptionen.IncludeAnalyserParameter;
   OptionenFenster.cb_IncludeColumnLabel.Checked := ProgrammOptionen.ColumnLabel;
   OptionenFenster.cb_IncludeWksLabel.Checked := ProgrammOptionen.WksLabel;
   OptionenFenster.cb_Interpolate.Checked := ProgrammOptionen.Interpolieren;
   OptionenFenster.cb_IncludeADC.Checked := ProgrammOptionen.IncludeADC;
   OptionenFenster.cb_ChanneltronEinzeln.Checked := ProgrammOptionen.ChanneltronEinzeln;
   STR(ProgrammOptionen.PhotonenEnergie:8:3,TmpS);
   OptionenFenster.il_PhotonenEnergie.Text := TmpS;
   OptionenFenster.rb_hn_AusDatei.Checked := TRUE;
   CASE ProgrammOptionen.Woher_hn OF
    1:OptionenFenster.rb_hn_AusDatei.Checked := TRUE;
    2:OptionenFenster.rb_hn_Fest.Checked := TRUE;
    3:OptionenFenster.rb_hn_Ask.Checked := TRUE;
    END;{CASE}

   {Dialog ausführen}
   DialogAusfuehren:
   IF OptionenFenster.ShowModal <> mrOk THEN EXIT;

   {Validation der eingegebenen Werte}
   {Ist il_MinStellen ein Byte ???}
   VAL(OptionenFenster.il_MinStellen.Text,B,Code);
   IF Code <> 0 THEN
    BEGIN
     IF Application.MessageBox('Error in numeric Format of the Number of Digits. Must be a Byte ! Retry ?','Error ...',mb_YesNo) = idYes
       THEN GOTO DialogAusfuehren
       ELSE EXIT;
    END;
   {Ist im Verzeichnis der angegebene Template-Datei eine Datei names ORIGI*.EXE zu finden ???}
   FSplit(OptionenFenster.il_TemplateName.Text,D,N,E);
   IF OptionenFenster.il_TemplateName.Text <> ProgrammOptionen.TemplateName + '.OTW' THEN
    BEGIN {Nur wenn sich was geändert hat überprüfen !}
     Result := FindFirst(D + '\Origin*.exe', faAnyFile, SearchRec);
     FindClose(SearchRec);
     IF Result <> 0 THEN
      BEGIN
       IF Application.MessageBox('Specified Template File is not in ORIGIN-Folder (no ORIGIN*.EXE was found) ! Retry ?','Error ...',mb_YesNo) = idYes
         THEN GOTO DialogAusfuehren
         ELSE EXIT;
      END;
    END;{IF}
   {Ist im Verzeichnis der angegebene Template-Datei für Moving/Sizing eine Datei names ORIGI*.EXE zu finden ???}
   FSplit(OptionenFenster.il_TemplateMovingSizing.Text,D2,N2,E2);
   IF OptionenFenster.il_TemplateMovingSizing.Text <> ProgrammOptionen.TemplateMovingSizing + '.OTW' THEN
    BEGIN {Nur wenn sich was geändert hat überprüfen !}
     Result := FindFirst(D2 + '\Origin*.exe', faAnyFile, SearchRec);
     FindClose(SearchRec);
     IF Result <> 0 THEN
      BEGIN
       IF Application.MessageBox('Specified Template File for Moving/Sizing is not in ORIGIN-Folder (no ORIGIN*.EXE was found) ! Retry ?','Error ...',mb_YesNo) = idYes
         THEN GOTO DialogAusfuehren
         ELSE EXIT;
      END;
    END;{IF}
   {Ist die Anregunsenergie eine gültige Real-Zahl ???}
   VAL(OptionenFenster.il_PhotonenEnergie.Text,R,Code);
   IF Code <> 0 THEN
    BEGIN
     IF Application.MessageBox('Error in numeric Format of the excitation Energy. Must be a Real ! Retry ?','Error ...',mb_YesNo) = idYes
       THEN GOTO DialogAusfuehren
       ELSE EXIT;
    END;

   {Alles Ok. Nun Record ProgrammOptionen setzen}
   ProgrammOptionen.MinStellen := B;
   ProgrammOptionen.PhotonenEnergie := R;
   ProgrammOptionen.TemplateName := N; {Nur der Name der ausgewählten Datei. Kein Pfad und keine Erweiterung !}
   ProgrammOptionen.TemplateMovingSizing := N2; {Nur der Name der ausgewählten Datei. Kein Pfad und keine Erweiterung !}
   ProgrammOptionen.IncludeAnalyserParameter := OptionenFenster.cb_IncludeAnalyserParameter.Checked;
   ProgrammOptionen.ColumnLabel := OptionenFenster.cb_IncludeColumnLabel.Checked;
   ProgrammOptionen.WksLabel := OptionenFenster.cb_IncludeWksLabel.Checked;
   ProgrammOptionen.Interpolieren := OptionenFenster.cb_Interpolate.Checked;
   ProgrammOptionen.IncludeADC := OptionenFenster.cb_IncludeADC.Checked;
   ProgrammOptionen.ChanneltronEinzeln := OptionenFenster.cb_ChanneltronEinzeln.Checked;
   IF OptionenFenster.rb_hn_AusDatei.Checked THEN ProgrammOptionen.Woher_hn := 1;
   IF OptionenFenster.rb_hn_Fest.Checked THEN ProgrammOptionen.Woher_hn := 2;
   IF OptionenFenster.rb_hn_Ask.Checked THEN ProgrammOptionen.Woher_hn := 3;
  end;


 PROCEDURE THauptFenster.CB_EnableMovingSizingClick(Sender: TObject);
  BEGIN
   ProgrammOptionen.EnableMovingSizing := cb_EnableMovingSizing.Checked;
  END;


 PROCEDURE THauptFenster.RBDataSource_SpectraClick(Sender: TObject);
  BEGIN
   HauptFenster.CB_DivScans.Checked := TRUE;
   HauptFenster.CB_DivLifeTime.Checked := TRUE;
   IF NOT MultipleFilesSelected THEN HauptFenster.BT_Alles.Enabled := TRUE; {nur aktivieren, wenn nicht mehrere Dateien ausgewählt sind !}
   HauptFenster.RBDataSource_Phoibos.Checked := FALSE;
   HauptFenster.RBDataSource_PhoibosXML.Checked := FALSE;
   ProgrammOptionen.ColumnLabel := FALSE; {Es macht keine Sinn bei Omicron-Spectra-Import diese als Label zu setzen. Wenn man es dennoch will, kann man es ja im Dialog aktivieren}
   ProgrammOptionen.WksLabel := FALSE; {Es macht keine Sinn bei Omicron-Spectra-Import diese als Label zu setzen. Wenn man es dennoch will, kann man es ja im Dialog aktivieren}
  END;


 PROCEDURE THauptFenster.RBDataSource_PhoibosClick(Sender: TObject);
  BEGIN
   HauptFenster.CB_DivScans.Checked := FALSE;
   HauptFenster.CB_DivLifeTime.Checked := FALSE;
   HauptFenster.BT_Alles.Enabled := FALSE;
   HauptFenster.RBDataSource_Spectra.Checked := FALSE;
   HauptFenster.RBDataSource_PhoibosXML.Checked := FALSE;
   ProgrammOptionen.ColumnLabel := TRUE; {Sinnvoll ! Wenn man es dennoch nicht will, kann man es ja im Dialog deaktivieren}
   ProgrammOptionen.WksLabel := TRUE; {Sinnvoll ! Wenn man es dennoch nicht will, kann man es ja im Dialog deaktivieren}
  END;


 PROCEDURE THauptFenster.RBDataSource_PhoibosXMLClick(Sender: TObject);
  BEGIN
   HauptFenster.CB_DivScans.Checked := TRUE;
   HauptFenster.CB_DivLifeTime.Checked := TRUE;
   HauptFenster.BT_Alles.Enabled := FALSE;
   HauptFenster.RBDataSource_Spectra.Checked := FALSE;
   HauptFenster.RBDataSource_Phoibos.Checked := FALSE;
   ProgrammOptionen.ColumnLabel := TRUE; {Sinnvoll ! Wenn man es dennoch nicht will, kann man es ja im Dialog deaktivieren}
   ProgrammOptionen.WksLabel := TRUE; {Sinnvoll ! Wenn man es dennoch nicht will, kann man es ja im Dialog deaktivieren}
  END;


BEGIN
 IgnoriereAlleLeerenRegionen := FALSE;
 IgnoriereAlleLeerenYCurves := FALSE;
END.
