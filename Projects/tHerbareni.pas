unit tHerbareni;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  VCLTee.TeCanvas, Vcl.ComCtrls, Vcl.Menus, System.UITypes ;

type
  TSecondaryForm = class(TForm)
    btnZelena: TButton;
    chkZelena: TCheckBox;
    lblZelena: TLabel;

    btnModra: TButton;
    chkModra: TCheckBox;
    lblModra: TLabel;

    btnCervena: TButton;
    chkCervena: TCheckBox;
    lblCervena: TLabel;

    btnFialova: TButton;
    chkFialova: TCheckBox;
    lblFialova: TLabel;

    btnTemna: TButton;
    chkTemna: TCheckBox;
    lblTemna: TLabel;

    Timer1: TTimer;
    Label1: TLabel;
    StatusBar1: TStatusBar;

    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    miRestore1: TMenuItem;
    miExit1: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure btnZelenaClick(Sender: TObject);
    procedure btnModraClick(Sender: TObject);
    procedure btnCervenaClick(Sender: TObject);
    procedure btnFialovaClick(Sender: TObject);
    procedure btnTemnaClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure miRestoreClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);

    private
    SekundZelena: Integer;
    SekundModra: Integer;
    SekundCervena: Integer;
    SekundFialova: Integer;
    SekundTemna: Integer;

    function FormatujCas(Sekund: Integer): string;
  public
    { Public declarations }
  end;

var
  SecondaryForm: TSecondaryForm;

implementation

{$R *.dfm}

function TSecondaryForm.FormatujCas(Sekund: Integer): string;
var
  Hodin, Minuty, Sekundy: Integer;
begin
  if Sekund <= 0 then
    Result := '00:00'
  else
  begin
    Hodin := Sekund div 3600;
    Minuty := (Sekund mod 3600) div 60;
    Sekundy := Sekund mod 60;

    if Hodin > 0 then
      Result := Format('%d:%.2d:%.2d', [Hodin, Minuty, Sekundy])
    else
      Result := Format('%.2d:%.2d', [Minuty, Sekundy]);
  end;
end;


procedure TSecondaryForm.FormCreate(Sender: TObject);
begin
  btnZelena.Caption := 'Zelena';
  btnModra.Caption := 'Modra';
  btnCervena.Caption := 'Cervena';
  btnFialova.Caption := 'Fialova';
  btnTemna.Caption := 'Temna';

  chkZelena.Caption := 'Speciální èas';
  chkModra.Caption := 'Speciální èas';
  chkCervena.Caption := 'Speciální èas';
  chkFialova.Caption := 'Speciální èas';
  chkTemna.Caption := 'Speciální èas';

  SekundZelena := 0;
  SekundModra := 0;
  SekundCervena := 0;
  SekundFialova := 0;
  SekundTemna := 0;

  lblZelena.Caption := 'Neaktivní';
  lblModra.Caption := 'Neaktivní';
  lblCervena.Caption := 'Neaktivní';
  lblFialova.Caption := 'Neaktivní';
  lblTemna.Caption := 'Neaktivní';

  Timer1.Interval := 1000;
  Timer1.Enabled := True;
end;


procedure TSecondaryForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Res: Integer;
begin
Res := MessageDlg('Chcete program zavøít? Pro bìh na pozadí zvolte No',
                    mtConfirmation, [mbYes, mbNo, mbCancel], 0);

  if Res = mrYes then
  begin
    CanClose := True; // Program se zcela zavøe
  end
  else if Res = mrNo then
  begin
    CanClose := False; // Program se nezavøe, bìží na pozadí
    Hide;              // Skryje hlavní okno
  end
  else
  begin
    CanClose := False; // Storno, akce se zruší
end;

end;


procedure TSecondaryForm.TrayIcon1DblClick(Sender: TObject);
begin
  Show;                   // Zobrazí formuláø
  WindowState := wsNormal;// Vrátí normální velikost okna
  Application.BringToFront;
end;


procedure TSecondaryForm.miExitClick(Sender: TObject);
begin
Application.Terminate; //zavøe program
end;

procedure TSecondaryForm.miRestoreClick(Sender: TObject);
begin
Show;
  WindowState := wsNormal;
  Application.BringToFront;
end;


// --- TLAÈÍTKA S PØEVODEM HODIN NA SEKUNDY ---

procedure TSecondaryForm.btnZelenaClick(Sender: TObject);
begin
  if chkZelena.Checked then
    SekundZelena := (3 * 3600) + (5 * 60)   // 3h 05m = 11100 s
  else
    SekundZelena := (4 * 3600) + (15 * 60);  // 4h 15m = 15300 s
  lblZelena.Caption := FormatujCas(SekundZelena);
end;

procedure TSecondaryForm.btnModraClick(Sender: TObject);
begin
  if chkModra.Checked then
    SekundModra := (4 * 3600) + (5 * 60)    // 4h 05m = 14700 s
  else
    SekundModra := (5 * 3600) + (35 * 60);   // 5h 35m = 20100 s
  lblModra.Caption := FormatujCas(SekundModra);
end;

procedure TSecondaryForm.btnCervenaClick(Sender: TObject);
begin
  if chkCervena.Checked then
    SekundCervena := (5 * 3600) + (2 * 60)   // 5h 02m = 18120 s
  else
    SekundCervena := (6 * 3600) + (55 * 60);  // 6h 55m = 24900 s
  lblCervena.Caption := FormatujCas(SekundCervena);
end;

procedure TSecondaryForm.btnFialovaClick(Sender: TObject);
begin
  if chkFialova.Checked then
    SekundFialova := (6 * 3600) + (1 * 60)   // 6h 01m = 21660 s
  else
    SekundFialova := (8 * 3600) + (15 * 60);  // 8h 15m = 29700 s
  lblFialova.Caption := FormatujCas(SekundFialova);
end;

procedure TSecondaryForm.btnTemnaClick(Sender: TObject);
begin
  if chkTemna.Checked then
    SekundTemna := (6 * 3600) + (59 * 60)  // 6h 59m = 25140 s
  else
    SekundTemna := (9 * 3600) + (35 * 60); // 9h 35m = 34500 s
  lblTemna.Caption := FormatujCas(SekundTemna);
end;

// --- HLAVNÍ ÈASOVAÈ ---

procedure TSecondaryForm.Timer1Timer(Sender: TObject);
begin
  if SekundZelena > 0 then
  begin
    Dec(SekundZelena);
    lblZelena.Caption := FormatujCas(SekundZelena);
    if SekundZelena = 0 then
    begin
      lblZelena.Caption := 'Vypìstováno!';
      ShowMessage('Èas sklidit zelenou bylinu!');
    end;
  end;

  if SekundModra > 0 then
  begin
    Dec(SekundModra);
    lblModra.Caption := FormatujCas(SekundModra);
    if SekundModra = 0 then
    begin
      lblModra.Caption := 'Vypìstováno!';
      ShowMessage('Èas sklidit modrou bylinu!');
    end;
  end;

  if SekundCervena > 0 then
  begin
    Dec(SekundCervena);
    lblCervena.Caption := FormatujCas(SekundCervena);
    if SekundCervena = 0 then
    begin
      lblCervena.Caption := 'Vypìstováno!';
      ShowMessage('Èas sklidit èervenou bylinu!');
    end;
  end;

  if SekundFialova > 0 then
  begin
    Dec(SekundFialova);
    lblFialova.Caption := FormatujCas(SekundFialova);
    if SekundFialova = 0 then
    begin
      lblFialova.Caption := 'Vypìstováno!';
      ShowMessage('Èas sklidit fialovou bylinu!');
    end;
  end;

  if SekundTemna > 0 then
  begin
    Dec(SekundTemna);
    lblTemna.Caption := FormatujCas(SekundTemna);
    if SekundTemna = 0 then
    begin
      lblTemna.Caption := 'Vypìstováno!';
      ShowMessage('Èas sklidit temnou bylinu!');
    end;
  end;
end;


end.
