unit tDochazka;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, System.hash,
  Vcl.ExtCtrls, System.JSON, System.Net.HttpClient, System.Net.URLClient, System.UITypes,
  System.Net.HttpClientComponent, Vcl.Clipbrd, System.DateUtils, System.Generics.Collections;

type
  TForm1 = class(TForm)
    PanelTop: TPanel;
    PanelBottom: TPanel;
    GridDochazka: TStringGrid;
    lblTyden: TLabel;
    cbTydny: TComboBox;
    btnNovyTyden: TButton;
    btnSync: TButton;
    chkAutoSync: TCheckBox;
    btnOdemknout: TButton;
    lblRezim: TLabel;
    btnDiscord: TButton;
    edtNovyClen: TEdit;
    btnPridatClena: TButton;
    btnSmazatClena: TButton;
    lblStav: TLabel;
    TimerSync: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure GridDochazkaDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GridDochazkaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnPridatClenaClick(Sender: TObject);
    procedure btnSmazatClenaClick(Sender: TObject);
    procedure btnNovyTydenClick(Sender: TObject);
    procedure cbTydnyChange(Sender: TObject);
    procedure btnSyncClick(Sender: TObject);
    procedure TimerSyncTimer(Sender: TObject);
    procedure chkAutoSyncClick(Sender: TObject);
    procedure btnOdemknoutClick(Sender: TObject);
    procedure btnDiscordClick(Sender: TObject);
  private
    FUpdating: Boolean;
    FOdemknuto: Boolean;
    procedure AktualizujStavOdemknuti;
    function OverHesloVedení: Boolean;
    procedure NastavHlavickuGridu(const DatumPondeli: TDate);
    procedure PrepocitatRadek(ARow: Integer);
    procedure PridatRadekDoGridu(const Jmeno: string; const Dny: array of Boolean; Zaplaceno: Boolean);
    function AktualniKlicTydne: string;
    procedure NactiSeznamTydnuZCloudu;
    procedure NactiTydenZCloudu(const KlicTydne: string);
    procedure UlozTydenDoCloudu;
  public
  end;

var
  Form1: TForm1;

const
  // SEM VLOŽ SVOU ADRESU Z FIREBASE (bez lomítka na konci)
  FIREBASE_URL = 'https://triton-dungeon-default-rtdb.europe-west1.firebasedatabase.app';
  ZAKLADNI_POPLATEK = 3.00;
  SLEVA_ZA_DEN = 0.40;

  // SHA-256 otisk hesla vedení (výchozí heslo: TRITON2026)
  // Pro zmìnu hesla si vygeneruj nový SHA-256 otisk malými písmeny (hex)
  HESLO_VEDENI_SHA256 = 'cd44141c6cb89a1af36e937aab5edb97c2386ed4e615af6b12051a44a9248861';


implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  GridDochazka.ColWidths[0] := 150; // Jméno
  for var i := 1 to 7 do
    GridDochazka.ColWidths[i] := 85; // Dny
  GridDochazka.ColWidths[8] := 85;  // Sleva
  GridDochazka.ColWidths[9] := 85;  // Poplatek
  GridDochazka.ColWidths[10] := 80; // Zaplaceno

  GridDochazka.Cells[0, 0] := 'Èlen cechu';
  GridDochazka.Cells[8, 0] := 'Sleva';
  GridDochazka.Cells[9, 0] := 'Poplatek';
  GridDochazka.Cells[10, 0] := 'Zaplaceno';

  FOdemknuto := False;
  AktualizujStavOdemknuti;

  NastavHlavickuGridu(StartOfTheWeek(Date));
  NactiSeznamTydnuZCloudu;
end;

procedure TForm1.AktualizujStavOdemknuti;
begin
  btnNovyTyden.Enabled := FOdemknuto;
  edtNovyClen.Enabled := FOdemknuto;
  btnPridatClena.Enabled := FOdemknuto;
  btnSmazatClena.Enabled := FOdemknuto;

  if FOdemknuto then
  begin
    btnOdemknout.Caption := 'Zamknout úpravy';
    lblRezim.Caption := 'Režim: Vedení (úpravy povoleny)';
    lblRezim.Font.Color := clGreen;
  end
  else
  begin
    btnOdemknout.Caption := 'Odemknout úpravy';
    lblRezim.Caption := 'Režim: Jen ke ètení';
    lblRezim.Font.Color := clMaroon;
  end;
end;

function TForm1.OverHesloVedení: Boolean;
var
  ZadaneHeslo, HashZadane: string;
begin
  Result := False;
  ZadaneHeslo := '';
  if not InputQuery('Pøihlášení vedení cechu', 'Zadej heslo pro úpravy a zápis:', ZadaneHeslo) then
    Exit;

  HashZadane := LowerCase(THashSHA2.GetHashString(ZadaneHeslo, SHA256));
  if SameText(HashZadane, HESLO_VEDENI_SHA256) then
    Result := True
  else
    MessageDlg('Nesprávné heslo. Zùstáváš v režimu jen ke ètení.', mtWarning, [mbOK], 0);
end;

procedure TForm1.btnOdemknoutClick(Sender: TObject);
begin
  if FOdemknuto then
  begin
    FOdemknuto := False;
    AktualizujStavOdemknuti;
  end
  else if OverHesloVedení then
  begin
    FOdemknuto := True;
    AktualizujStavOdemknuti;
  end;
end;

procedure TForm1.NastavHlavickuGridu(const DatumPondeli: TDate);
begin
  for var i := 0 to 6 do
    GridDochazka.Cells[i + 1, 0] := FormatDateTime('d.m.yyyy', DatumPondeli + i);
end;

function TForm1.AktualniKlicTydne: string;
begin
  if cbTydny.ItemIndex >= 0 then
    Result := cbTydny.Items[cbTydny.ItemIndex]
  else
    Result := FormatDateTime('yyyy-mm-dd', StartOfTheWeek(Date));
end;

procedure TForm1.PrepocitatRadek(ARow: Integer);
var
  Col, Ucasti: Integer;
  Sleva, Poplatek: Double;
begin
  Ucasti := 0;
  for Col := 1 to 7 do
    if GridDochazka.Cells[Col, ARow] = '1' then
      Inc(Ucasti);

  Sleva := Ucasti * SLEVA_ZA_DEN;
  Poplatek := ZAKLADNI_POPLATEK - Sleva;
  if Poplatek < 0 then
    Poplatek := 0.00;

  GridDochazka.Cells[8, ARow] := FormatFloat('0.00', Sleva) + 'B';
  GridDochazka.Cells[9, ARow] := FormatFloat('0.00', Poplatek) + 'B';
end;

procedure TForm1.PridatRadekDoGridu(const Jmeno: string; const Dny: array of Boolean; Zaplaceno: Boolean);
var
  R: Integer;
begin
  if (GridDochazka.RowCount = 2) and (GridDochazka.Cells[0, 1] = '') then
    R := 1
  else
  begin
    R := GridDochazka.RowCount;
    GridDochazka.RowCount := R + 1;
  end;

  GridDochazka.Cells[0, R] := Jmeno;
  for var i := 0 to 6 do
    if (i <= High(Dny)) and Dny[i] then
      GridDochazka.Cells[i + 1, R] := '1'
    else
      GridDochazka.Cells[i + 1, R] := '0';

  if Zaplaceno then
    GridDochazka.Cells[10, R] := '1'
  else
    GridDochazka.Cells[10, R] := '0';

  PrepocitatRadek(R);
end;

procedure TForm1.GridDochazkaDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  CheckRect: TRect;
  CheckState: UINT;
  TextStr: string;
begin
  if (ARow > 0) and ((ACol in [1..7]) or (ACol = 10)) and (GridDochazka.Cells[0, ARow] <> '') then
  begin
    GridDochazka.Canvas.Brush.Color := clWindow;
    if ACol = 10 then
    begin
      if GridDochazka.Cells[10, ARow] = '1' then
        GridDochazka.Canvas.Brush.Color := $00E6FFE6
      else
        GridDochazka.Canvas.Brush.Color := $00E6E6FF;
    end;

    GridDochazka.Canvas.FillRect(Rect);
    CheckRect := Rect;
    InflateRect(CheckRect, -((Rect.Width - 16) div 2), -((Rect.Height - 16) div 2));

    CheckState := DFCS_BUTTONCHECK;
    if GridDochazka.Cells[ACol, ARow] = '1' then
      CheckState := CheckState or DFCS_CHECKED;

    DrawFrameControl(GridDochazka.Canvas.Handle, CheckRect, DFC_BUTTON, CheckState);
  end
  else if (ARow > 0) and (ACol = 9) then
  begin
    GridDochazka.Canvas.Brush.Color := clWindow;
    GridDochazka.Canvas.FillRect(Rect);
    GridDochazka.Canvas.Font.Style := [fsBold];
    TextStr := GridDochazka.Cells[ACol, ARow];
    GridDochazka.Canvas.TextOut(Rect.Left + 8, Rect.Top + 5, TextStr);
  end;
end;

procedure TForm1.GridDochazkaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Integer;
begin
  if Button <> mbLeft then Exit;
  if not FOdemknuto then Exit; // V režimu jen ke ètení nelze pøepínat docházku ani platby

  GridDochazka.MouseToCell(X, Y, Col, Row);

  if (Row > 0) and (GridDochazka.Cells[0, Row] <> '') and ((Col in [1..7]) or (Col = 10)) then
  begin
    if GridDochazka.Cells[Col, Row] = '1' then
      GridDochazka.Cells[Col, Row] := '0'
    else
      GridDochazka.Cells[Col, Row] := '1';

    PrepocitatRadek(Row);
    GridDochazka.Invalidate;
    UlozTydenDoCloudu;
  end;
end;

procedure TForm1.btnPridatClenaClick(Sender: TObject);
var
  Jmeno: string;
  PrazdneDny: array[0..6] of Boolean;
begin
  if not FOdemknuto then Exit;

  Jmeno := Trim(edtNovyClen.Text);
  if Jmeno = '' then Exit;

  for var i := 0 to 6 do PrazdneDny[i] := False;
  PridatRadekDoGridu(Jmeno, PrazdneDny, False);
  edtNovyClen.Clear;
  GridDochazka.Invalidate;
  UlozTydenDoCloudu;
end;

procedure TForm1.btnSmazatClenaClick(Sender: TObject);
var
  SelRow: Integer;
begin
  if not FOdemknuto then Exit;

  SelRow := GridDochazka.Row;
  if (SelRow <= 0) or (GridDochazka.Cells[0, SelRow] = '') then Exit;

  if MessageDlg('Opravdu odebrat èlena "' + GridDochazka.Cells[0, SelRow] + '" z tohoto týdne?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if GridDochazka.RowCount = 2 then
    begin
      for var c := 0 to 10 do GridDochazka.Cells[c, 1] := '';
    end
    else
    begin
      for var r := SelRow to GridDochazka.RowCount - 2 do
        for var c := 0 to 10 do
          GridDochazka.Cells[c, r] := GridDochazka.Cells[c, r + 1];
      GridDochazka.RowCount := GridDochazka.RowCount - 1;
    end;
    GridDochazka.Invalidate;
    UlozTydenDoCloudu;
  end;
end;

procedure TForm1.btnNovyTydenClick(Sender: TObject);
var
  NovyKlic: string;
  DatumPondeli: TDate;
begin
  if not FOdemknuto then Exit;

  DatumPondeli := StartOfTheWeek(Date);
  NovyKlic := FormatDateTime('yyyy-mm-dd', DatumPondeli);
  if not InputQuery('Nový týden', 'Zadej datum pondìlí (RRRR-MM-DD):', NovyKlic) then Exit;

  if cbTydny.Items.IndexOf(NovyKlic) = -1 then
    cbTydny.Items.Add(NovyKlic);
  cbTydny.ItemIndex := cbTydny.Items.IndexOf(NovyKlic);

  try
    NastavHlavickuGridu(ISO8601ToDate(NovyKlic));
  except
  end;

  for var r := 1 to GridDochazka.RowCount - 1 do
  begin
    if GridDochazka.Cells[0, r] <> '' then
    begin
      for var c := 1 to 7 do GridDochazka.Cells[c, r] := '0';
      GridDochazka.Cells[10, r] := '0';
      PrepocitatRadek(r);
    end;
  end;
  GridDochazka.Invalidate;
  UlozTydenDoCloudu;
end;

procedure TForm1.UlozTydenDoCloudu;
var
  Http: THTTPClient;
  JsonRoot, JsonClen: TJSONObject;
  JsonArrDny: TJSONArray;
  Stream: TStringStream;
  Klic: string;
begin
  if FUpdating then Exit;
  if not FOdemknuto then
  begin
    lblStav.Caption := 'Uložení zablokováno (režim jen ke ètení)';
    Exit;
  end;

  Klic := AktualniKlicTydne;

  JsonRoot := TJSONObject.Create;
  Http := THTTPClient.Create;
  try
    for var r := 1 to GridDochazka.RowCount - 1 do
    begin
      if GridDochazka.Cells[0, r] <> '' then
      begin
        JsonClen := TJSONObject.Create;
        JsonArrDny := TJSONArray.Create;
        for var c := 1 to 7 do
          JsonArrDny.Add(GridDochazka.Cells[c, r] = '1');

        JsonClen.AddPair('dny', JsonArrDny);
        JsonClen.AddPair('zaplaceno', TJSONBool.Create(GridDochazka.Cells[10, r] = '1'));
        JsonRoot.AddPair(GridDochazka.Cells[0, r], JsonClen);
      end;
    end;

    Stream := TStringStream.Create(JsonRoot.ToJSON, TEncoding.UTF8);
    try
      Http.Put(FIREBASE_URL + '/tydny/' + Klic + '.json', Stream);
      lblStav.Caption := 'Uloženo v cloudu (' + FormatDateTime('hh:nn:ss', Now) + ')';
    finally
      Stream.Free;
    end;
  except
    on E: Exception do
      lblStav.Caption := 'Chyba odesílání: ' + E.Message;
  end;
  Http.Free;
  JsonRoot.Free;
end;

procedure TForm1.NactiSeznamTydnuZCloudu;
var
  Http: THTTPClient;
  JsonVal: TJSONValue;
  JsonObj: TJSONObject;
  Vybrany, JsonText: string;
  StreamResp: TStringStream;
begin
  Vybrany := AktualniKlicTydne;
  Http := THTTPClient.Create;
  try
    StreamResp := TStringStream.Create('', TEncoding.UTF8);
    try
      Http.Get(FIREBASE_URL + '/tydny.json?shallow=true', StreamResp);
      JsonText := StreamResp.DataString;
    finally
      StreamResp.Free;
    end;

    if (JsonText <> '') and (JsonText <> 'null') then
    begin
      JsonVal := TJSONObject.ParseJSONValue(JsonText);
      if JsonVal is TJSONObject then
      begin
        JsonObj := TJSONObject(JsonVal);
        cbTydny.Items.BeginUpdate;
        try
          cbTydny.Items.Clear;
          for var Pair in JsonObj do
            cbTydny.Items.Add(Pair.JsonString.Value);
        finally
          cbTydny.Items.EndUpdate;
        end;
        JsonVal.Free;
      end;
    end;

    if cbTydny.Items.Count = 0 then
      cbTydny.Items.Add(FormatDateTime('yyyy-mm-dd', StartOfTheWeek(Date)));

    if cbTydny.Items.IndexOf(Vybrany) >= 0 then
      cbTydny.ItemIndex := cbTydny.Items.IndexOf(Vybrany)
    else
      cbTydny.ItemIndex := cbTydny.Items.Count - 1;

    NactiTydenZCloudu(AktualniKlicTydne);
  except
    lblStav.Caption := 'Offline režim (nelze se pøipojit k databázi)';
  end;
  Http.Free;
end;

procedure TForm1.NactiTydenZCloudu(const KlicTydne: string);
var
  Http: THTTPClient;
  JsonVal: TJSONValue;
  JsonObj, JsonClen: TJSONObject;
  JsonDny: TJSONArray;
  Dny: array[0..6] of Boolean;
  Zaplaceno: Boolean;
  JsonText: string;
  StreamResp: TStringStream;
begin
  FUpdating := True;
  Http := THTTPClient.Create;
  try
    try
      NastavHlavickuGridu(ISO8601ToDate(KlicTydne));
    except
    end;

    StreamResp := TStringStream.Create('', TEncoding.UTF8);
    try
      Http.Get(FIREBASE_URL + '/tydny/' + KlicTydne + '.json', StreamResp);
      JsonText := StreamResp.DataString;
    finally
      StreamResp.Free;
    end;

    GridDochazka.RowCount := 2;
    for var c := 0 to 10 do GridDochazka.Cells[c, 1] := '';

    if (JsonText <> '') and (JsonText <> 'null') then
    begin
      JsonVal := TJSONObject.ParseJSONValue(JsonText);
      if JsonVal is TJSONObject then
      begin
        JsonObj := TJSONObject(JsonVal);
        for var Pair in JsonObj do
        begin
          JsonClen := Pair.JsonValue as TJSONObject;
          JsonDny := JsonClen.GetValue('dny') as TJSONArray;
          for var i := 0 to 6 do
            Dny[i] := (JsonDny <> nil) and (i < JsonDny.Count) and (JsonDny.Items[i] is TJSONTrue);

          Zaplaceno := JsonClen.GetValue('zaplaceno') is TJSONTrue;
          PridatRadekDoGridu(Pair.JsonString.Value, Dny, Zaplaceno);
        end;
        JsonVal.Free;
      end;
    end;
    GridDochazka.Invalidate;
    lblStav.Caption := 'Synchronizováno (' + FormatDateTime('hh:nn:ss', Now) + ')';
  except
    on E: Exception do
      lblStav.Caption := 'Chyba stahování: ' + E.Message;
  end;
  Http.Free;
  FUpdating := False;
end;

procedure TForm1.cbTydnyChange(Sender: TObject);
begin
  NactiTydenZCloudu(AktualniKlicTydne);
end;

procedure TForm1.btnSyncClick(Sender: TObject);
begin
  NactiSeznamTydnuZCloudu;
end;

procedure TForm1.TimerSyncTimer(Sender: TObject);
begin
  if chkAutoSync.Checked then
    NactiTydenZCloudu(AktualniKlicTydne);
end;

procedure TForm1.chkAutoSyncClick(Sender: TObject);
begin
  TimerSync.Enabled := chkAutoSync.Checked;
end;

procedure TForm1.btnDiscordClick(Sender: TObject);
var
  SL: TStringList;
  StavPlatby: string;
begin
  SL := TStringList.Create;
  try
    SL.Add('**TRITON – Pøehled poplatkù (' + AktualniKlicTydne + ')**');
    SL.Add('```');
    for var r := 1 to GridDochazka.RowCount - 1 do
    begin
      if GridDochazka.Cells[0, r] <> '' then
      begin
        if GridDochazka.Cells[10, r] = '1' then
          StavPlatby := '[ZAPLACENO]'
        else
          StavPlatby := '[DLUŽÍ]    ';

        SL.Add(Format('%-18s | Sleva: %-6s | Poplatek: %-6s | %s',
          [GridDochazka.Cells[0, r],
           GridDochazka.Cells[8, r],
           GridDochazka.Cells[9, r],
           StavPlatby]));
      end;
    end;
    SL.Add('```');
    Clipboard.AsText := SL.Text;
    ShowMessage('Pøehled byl zkopírován do schránky. Staèí vložit na Discord (Ctrl+V).');
  finally
    SL.Free;
  end;
end;

end.
