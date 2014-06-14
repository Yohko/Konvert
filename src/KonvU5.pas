unit KonvU5;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Konvert-Tool for Converting Spectra (Omicron) and Phoibos (Specs) into ORIGIN®
// by Patrick Hoffmann, eMail: Patrick.Hoffmann@T-Online.de, Patrick.Hoffmann@TU-Cottbus.de
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Meine;

type
  TOptionenFenster = class(TForm)
    bt_Cancel: TButton;
    bt_Ok: TButton;
    GroupBox1: TGroupBox;
    rb_hn_ausDatei: TRadioButton;
    rb_hn_Fest: TRadioButton;
    il_PhotonenEnergie: TEdit;
    rb_hn_ask: TRadioButton;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    il_TemplateName: TEdit;
    OpenDialog1: TOpenDialog;
    bt_ChooseTemplateFile: TButton;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    il_MinStellen: TEdit;
    Label1: TLabel;
    GroupBox4: TGroupBox;
    Label2: TLabel;
    il_TemplateMovingSizing: TEdit;
    bt_ChooseTemplateMovingSizing: TButton;
    Label6: TLabel;
    cb_IncludeAnalyserParameter: TCheckBox;
    cb_IncludeColumnLabel: TCheckBox;
    cb_IncludeWksLabel: TCheckBox;
    GroupBox5: TGroupBox;
    cb_ChanneltronEinzeln: TCheckBox;
    cb_Interpolate: TCheckBox;
    bt_Help: TButton;
    cb_IncludeADC: TCheckBox;
    procedure bt_ChooseTemplateFileClick(Sender: TObject);
    procedure bt_ChooseTemplateMovingSizingClick(Sender: TObject);
    procedure bt_HelpClick(Sender: TObject);
    procedure KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  OptionenFenster: TOptionenFenster;

implementation

{$R *.DFM}

 procedure TOptionenFenster.bt_ChooseTemplateFileClick(Sender: TObject);

  VAR
   D, N, E :STRING;

  begin
   FSplit(Application.ExeName,D,N,E);
   OpenDialog1.InitialDir := D;
   OpenDialog1.FileName := '*.OTW';
   OpenDialog1.Options := [ofFileMustExist];
   IF OpenDialog1.Execute THEN il_TemplateName.Text := OpenDialog1.FileName;
  end;


 procedure TOptionenFenster.bt_ChooseTemplateMovingSizingClick(Sender: TObject);

  VAR
   D, N, E :STRING;

  begin
   FSplit(Application.ExeName,D,N,E);
   OpenDialog1.InitialDir := D;
   OpenDialog1.FileName := '*.OTW';
   OpenDialog1.Options := [ofFileMustExist];
   IF OpenDialog1.Execute THEN il_TemplateMovingSizing.Text := OpenDialog1.FileName;
  end;


 PROCEDURE TOptionenFenster.KeyUp(Sender:TObject; VAR Key:Word; Shift:TShiftState);
  BEGIN
   IF Key <> VK_F1 THEN EXIT; {Nur weiter, wenn auch die F1-Taste gedrückt wurde}
   bt_HelpClick(Sender);
  END;


 PROCEDURE TOptionenFenster.bt_HelpClick(Sender: TObject);
  VAR TmpI :LongInt;
  BEGIN
   TmpI := ActiveControl.HelpContext;
   IF TmpI = 0 THEN TmpI := 2; {Falls kein Hilfs-Kontext hgesetzt, dann Optionen-Seite in der HLP-Datei aufrufen}
   Application.HelpCommand(HELP_CONTEXT, TmpI);
  END;


end.
