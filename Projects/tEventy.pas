unit tEventy;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.DateUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.WinXPickers, Vcl.ExtCtrls;

type
  TFormEventy = class(TForm)
    dny: TComboBox;
    ListBox1: TListBox;
    Label1: TLabel;
    Timer1: TTimer;
    procedure dnyChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    function ParseHM(const S: string; out ATime: TTime): Boolean;
    function IsEventActiveNow(DayIndex: Integer; const Line: string): Boolean;
  public
  end;

var
  FormEventy: TFormEventy;

implementation

{$R *.dfm}

function TFormEventy.ParseHM(const S: string; out ATime: TTime): Boolean;
var
  ColonPos, H, M: Integer;
  HStr, MStr: string;
begin
  Result := False;
  ColonPos := Pos(':', S);
  if ColonPos = 0 then
    Exit;

  HStr := Trim(Copy(S, 1, ColonPos - 1));
  MStr := Trim(Copy(S, ColonPos + 1, Length(S)));

  if TryStrToInt(HStr, H) and TryStrToInt(MStr, M) then
  begin
    if (H >= 0) and (H <= 23) and (M >= 0) and (M <= 59) then
    begin
      ATime := EncodeTime(H, M, 0, 0);
      Result := True;
    end;
  end;
end;

function TFormEventy.IsEventActiveNow(DayIndex: Integer; const Line: string): Boolean;
var
  StartStr, EndStr: string;
  StartTime, EndTime, NowTime: TTime;
begin
  Result := False;

  // Zvýrazòujeme jen když je vybraný aktuální den v týdnu
  if DayIndex <> (DayOfTheWeek(Now) - 1) then
    Exit;

  // Oèekávaný formát zaèátku øádku: "HH:MM - HH:MM    Název..."
  if Length(Line) < 13 then
    Exit;

  StartStr := Trim(Copy(Line, 1, 5));
  EndStr := Trim(Copy(Line, 9, 5));

  if ParseHM(StartStr, StartTime) and ParseHM(EndStr, EndTime) then
  begin
    NowTime := Time;
    Result := (NowTime >= StartTime) and (NowTime <= EndTime);
  end;
end;

procedure TFormEventy.FormCreate(Sender: TObject);
begin
  if dny.Items.Count = 0 then
  begin
    dny.Items.Add('Pondìlí');
    dny.Items.Add('Úterý');
    dny.Items.Add('Støeda');
    dny.Items.Add('Ètvrtek');
    dny.Items.Add('Pátek');
    dny.Items.Add('Sobota');
    dny.Items.Add('Nedìle');
  end;

  dny.ItemIndex := DayOfTheWeek(Now) - 1;
  if dny.ItemIndex <> -1 then
    dnyChange(Sender);
end;

procedure TFormEventy.dnyChange(Sender: TObject);
begin
  ListBox1.Items.BeginUpdate;
  try
    ListBox1.Items.Clear;

    case dny.ItemIndex of
      0: // Pondìlí
        begin
          ListBox1.Items.Add('09:30 - 10:00    Dvojnásobný drop z bossù');
          ListBox1.Items.Add('10:00 - 10:30    Dvojnásobný drop z meteorù');
          ListBox1.Items.Add('10:30 - 11:00    Zlepšené toèení horních bonusù');
          ListBox1.Items.Add('17:30 - 17:45    Dvojnásobný lov ryb');
          ListBox1.Items.Add('17:45 - 18:00    Dvojnásobný drop z tìžìní rudy');
          ListBox1.Items.Add('18:00 - 18:30    Týmová gladiator aréna (120-169)');
          ListBox1.Items.Add('18:30 - 19:30    Dvojnásobný drop z dungeonù');
          ListBox1.Items.Add('19:30 - 20:00    Cechovní aréna (120-169)');
          ListBox1.Items.Add('20:00 - 20:30    Týmová gladiator aréna (56-89)');
          ListBox1.Items.Add('21:00 - 21:30    Shuffle gladiator aréna (15+)');
          ListBox1.Items.Add('22:00 - 22:30    Gladiator aréna (170+)');
          ListBox1.Items.Add('23:00 - 23:15    Zlepšené toèení run');
          ListBox1.Items.Add('23:30 - 23:59    Dvojnásobný drop z bossù');
        end;

      1: // Úterý
        begin
          ListBox1.Items.Add('09:30 - 10:00    Dvojnásobný drop z meteorù');
          ListBox1.Items.Add('10:00 - 10:30    Dvojnásobný drop z bossù');
          ListBox1.Items.Add('10:30 - 10:45    Dvojnásobný lov ryb');
          ListBox1.Items.Add('10:45 - 11:00    Dvojnásobný drop z tìžìní rudy');
          ListBox1.Items.Add('17:30 - 17:45    Dvojnásobný poèet bodù do titulù');
          ListBox1.Items.Add('17:45 - 18:00    Zlepšené toèení run');
          ListBox1.Items.Add('18:00 - 18:30    Dvojnásobný drop z tìžìní rudy');
          ListBox1.Items.Add('18:30 - 19:00    Dvojnásobný drop z bossù');
          ListBox1.Items.Add('19:00 - 19:30    Dvojnásobný drop z meteorù');
          ListBox1.Items.Add('19:30 - 20:00    Gladiator aréna (56-89)');
          ListBox1.Items.Add('20:00 - 20:30    Mirror cechovní aréna (15+)');
          ListBox1.Items.Add('20:30 - 21:00    Cechovní aréna (15-55)');
          ListBox1.Items.Add('22:00 - 22:30    Gladiator aréna (15-55)');
          ListBox1.Items.Add('23:30 - 23:59    Dvojnásobný drop z meteorù');
        end;

      2: // Støeda
        begin
          ListBox1.Items.Add('09:30 - 10:30    Dvojnásobný zisk zkušeností');
          ListBox1.Items.Add('10:30 - 10:45    Dvojnásobný poèet bodù do titulù');
          ListBox1.Items.Add('10:45 - 11:00    Zlepšené toèení run');
          ListBox1.Items.Add('17:30 - 18:00    Drop zlatých pokladnic');
          ListBox1.Items.Add('18:00 - 18:30    Týmová gladiator aréna (90-119)');
          ListBox1.Items.Add('18:30 - 19:30    Dvojnásobný zisk bodù z knih misí');
          ListBox1.Items.Add('19:30 - 20:00    Cechovní aréna (90-119)');
          ListBox1.Items.Add('20:00 - 20:30    Týmová gladiator aréna (15-55)');
          ListBox1.Items.Add('21:00 - 21:30    Shuffle gladiator aréna (15+)');
          ListBox1.Items.Add('22:00 - 22:30    Gladiator aréna (120-169)');
          ListBox1.Items.Add('23:30 - 23:59    Dvojnásobný zisk zkušeností');
        end;

      3: // Ètvrtek
        begin
          ListBox1.Items.Add('09:30 - 10:30    Dvojnásobný drop z dungeonù');
          ListBox1.Items.Add('10:30 - 11:00    Drop zlatých pokladnic');
          ListBox1.Items.Add('17:30 - 17:45    Dvojnásobný lov ryb');
          ListBox1.Items.Add('17:45 - 18:30    Dvojnásobný drop z tìžìní rudy');
          ListBox1.Items.Add('18:30 - 19:00    Dvojnásobný drop z meteorù');
          ListBox1.Items.Add('19:00 - 19:30    Dvojnásobný drop z bossù');
          ListBox1.Items.Add('19:30 - 20:00    Gladiator aréna (170+)');
          ListBox1.Items.Add('20:00 - 20:30    Mirror gladiator aréna (15+)');
          ListBox1.Items.Add('22:00 - 22:30    Gladiator aréna (90-119)');
          ListBox1.Items.Add('23:00 - 23:15    Zlepšené toèení run');
          ListBox1.Items.Add('23:30 - 23:59    Dvojnásobný drop z dungeonù');
        end;

      4: // Pátek
        begin
          ListBox1.Items.Add('09:30 - 10:00    Dvojnásobný drop z meteorù');
          ListBox1.Items.Add('10:00 - 10:30    Dvojnásobný drop z bossù');
          ListBox1.Items.Add('10:30 - 10:45    Dvojnásobný lov ryb');
          ListBox1.Items.Add('10:45 - 11:00    Dvojnásobný drop z tìžìní rudy');
          ListBox1.Items.Add('17:30 - 17:45    Dvojnásobný poèet bodù do titulù');
          ListBox1.Items.Add('17:45 - 18:00    Zlepšené toèení run');
          ListBox1.Items.Add('18:00 - 18:30    Týmová gladiator aréna (170+)');
          ListBox1.Items.Add('18:30 - 19:30    Dvojnásobný drop z dungeonù');
          ListBox1.Items.Add('19:30 - 20:00    Cechovní aréna (170+)');
          ListBox1.Items.Add('20:00 - 20:30    Mirror gladiator aréna (15+)');
          ListBox1.Items.Add('22:00 - 22:30    Gladiator aréna (15-55)');
          ListBox1.Items.Add('23:30 - 23:59    Dvojnásobný drop z meteorù');
        end;

      5: // Sobota
        begin
          ListBox1.Items.Add('09:30 - 10:30    Dvojnásobný zisk bodù z knih misí');
          ListBox1.Items.Add('10:30 - 10:45    Dvojnásobný poèet bodù do titulù');
          ListBox1.Items.Add('10:45 - 11:00    Zlepšené toèení run');
          ListBox1.Items.Add('17:30 - 17:45    Dvojnásobný lov ryb');
          ListBox1.Items.Add('17:45 - 18:00    Dvojnásobný drop z tìžìní rudy');
          ListBox1.Items.Add('18:00 - 18:30    Mirror gladiator aréna (15+)');
          ListBox1.Items.Add('18:30 - 19:00    Dvojnásobný drop z bossù');
          ListBox1.Items.Add('19:00 - 19:30    Dvojnásobný drop z meteorù');
          ListBox1.Items.Add('19:30 - 20:00    Gladiator aréna (90-119)');
          ListBox1.Items.Add('20:00 - 20:30    Týmová gladiator aréna (15-55)');
          ListBox1.Items.Add('20:30 - 21:00    Cechovní aréna (15-55)');
          ListBox1.Items.Add('22:00 - 22:30    Gladiator aréna (120-169)');
          ListBox1.Items.Add('23:30 - 23:59    Dvojnásobný drop z bossù');
        end;

      6: // Nedìle
        begin
          ListBox1.Items.Add('09:30 - 10:30    Dvojnásobný drop z dungeonù');
          ListBox1.Items.Add('10:30 - 10:45    Dvojnásobný lov ryb');
          ListBox1.Items.Add('10:45 - 11:00    Dvojnásobný drop z tìžìní rudy');
          ListBox1.Items.Add('17:30 - 18:00    Zlepšené toèení horních bonusù');
          ListBox1.Items.Add('18:00 - 18:30    Týmová gladiator aréna (15-55)');
          ListBox1.Items.Add('18:30 - 19:30    Dvojnásobný zisk zkušeností');
          ListBox1.Items.Add('19:30 - 20:00    Cechovní aréna (56-89)');
          ListBox1.Items.Add('20:00 - 20:30    Mirror cechovní aréna (15+)');
          ListBox1.Items.Add('21:00 - 21:30    Shuffle gladiator aréna (15+)');
          ListBox1.Items.Add('22:00 - 22:30    Gladiator aréna (56-89)');
          ListBox1.Items.Add('23:30 - 23:59    Dvojnásobný drop z dungeonù');
        end;
    end;
  finally
    ListBox1.Items.EndUpdate;
  end;

  ListBox1.Invalidate;
end;

procedure TFormEventy.Timer1Timer(Sender: TObject);
begin
  // Pokud se zmìnil den (napø. o pùlnoci), pøepneme na aktuální den
  if dny.ItemIndex <> (DayOfTheWeek(Now) - 1) then
  begin
    dny.ItemIndex := DayOfTheWeek(Now) - 1;
    dnyChange(Sender);
  end
  else
    ListBox1.Invalidate;
end;

procedure TFormEventy.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LB: TListBox;
  LineText: string;
  ActiveNow: Boolean;
begin
  LB := Control as TListBox;
  LineText := LB.Items[Index];
  ActiveNow := IsEventActiveNow(dny.ItemIndex, LineText);

  if ActiveNow then
  begin
    LB.Canvas.Brush.Color := $00D5F5E3; // jemnì zelené pozadí
    LB.Canvas.Font.Color := $001E8449;  // tmavì zelený text
    LB.Canvas.Font.Style := [fsBold];
    LineText := LineText + '   [PRÁVÌ PROBÍHÁ]';
  end
  else if odSelected in State then
  begin
    LB.Canvas.Brush.Color := clHighlight;
    LB.Canvas.Font.Color := clHighlightText;
    LB.Canvas.Font.Style := [];
  end
  else
  begin
    LB.Canvas.Brush.Color := LB.Color;
    LB.Canvas.Font.Color := LB.Font.Color;
    LB.Canvas.Font.Style := [];
  end;

  LB.Canvas.FillRect(Rect);
  LB.Canvas.TextRect(Rect, Rect.Left + 6, Rect.Top + 3, LineText);
end;

end.
