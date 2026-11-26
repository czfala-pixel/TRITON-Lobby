unit tLobby;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.UITypes,
  tDochazka, tHerbareni, tEventy, Vcl.ExtCtrls, System.JSON, System.Net.HttpClient,
  System.IOUtils, System.Net.URLClient, System.Hash, tVylepsovani,
  System.Net.HttpClientComponent, Vcl.ComCtrls;

type
  TLobbyForm = class(TForm)
    btnDochazka: TButton;
    btnHerbareni: TButton;
    btnEventy: TButton;
    Panel1: TPanel;
    btnAktualizovat: TButton;
    lblUpdateStatus: TLabel;
    pbUpdate: TProgressBar;
    btnHelper: TButton;
    btnOsvicenstvi: TButton;
    btnVylepsovani: TButton;
    procedure btnDochazkaClick(Sender: TObject);
    procedure btnHerbareniClick(Sender: TObject);
    procedure btnEventyClick(Sender: TObject);
    procedure btnAktualizovatClick(Sender: TObject);
    procedure btnHelperClick(Sender: TObject);
    procedure btnOsvicenstviClick(Sender: TObject);
    procedure btnVylepsovaniClick(Sender: TObject);
  private
    procedure OpenUrl(const AUrl: string);
  public
  end;

var
  LobbyForm: TLobbyForm;

implementation

{$R *.dfm}

function IsValidPEExecutable(const AFileName: string; MinSizeBytes: Int64 = 1024): Boolean;
var
  FS: TFileStream;
  Header: array[0..1] of Byte;
begin
  Result := False;
  if not FileExists(AFileName) then
    Exit;

  FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    if FS.Size < MinSizeBytes then
      Exit;

    if FS.Read(Header[0], SizeOf(Header)) <> SizeOf(Header) then
      Exit;

    // Platný spustitelný soubor MS-DOS / PE zaèíná znaky 'MZ' ($4D, $5A)
    Result := (Header[0] = $4D) and (Header[1] = $5A);
  finally
    FS.Free;
  end;
end;

procedure ReplaceAndRestartLobby(const DownloadedExe: string; ShowWindow: Boolean = True);
var
  TargetExe, BatFile, BatContent: string;
  ShowCmd: Integer;
begin
  TargetExe := ParamStr(0);
  BatFile := TPath.Combine(TPath.GetTempPath, 'LobbyRestart.bat');

  BatContent :=
    '@echo off' + sLineBreak +
    'title Aktualizace TRITON Lobby' + sLineBreak +
    'echo Cekam na ukonceni Lobby...' + sLineBreak +
    'timeout /t 2 /nobreak >nul' + sLineBreak +
    'set /a tries=0' + sLineBreak +
    ':retry' + sLineBreak +
    'set /a tries+=1' + sLineBreak +
    'echo Prepisuji soubor (pokus %tries%/20)...' + sLineBreak +
    'copy /y "' + DownloadedExe + '" "' + TargetExe + '" >nul 2>&1' + sLineBreak +
    'if errorlevel 1 (' + sLineBreak +
    '  if %tries% lss 20 (' + sLineBreak +
    '    timeout /t 1 /nobreak >nul' + sLineBreak +
    '    goto retry' + sLineBreak +
    '  ) else (' + sLineBreak +
    '    echo.' + sLineBreak +
    '    echo CHYBA: Nepodarilo se prepsat soubor "' + TargetExe + '".' + sLineBreak +
    '    pause' + sLineBreak +
    '    goto cleanup' + sLineBreak +
    '  )' + sLineBreak +
    ')' + sLineBreak +
    'echo Spoustim novou verzi...' + sLineBreak +
    'start "" "' + TargetExe + '"' + sLineBreak +
    ':cleanup' + sLineBreak +
    'del /f /q "' + DownloadedExe + '" >nul 2>&1' + sLineBreak +
    '(goto) 2>nul & del /f /q "%~f0"' + sLineBreak;

  TFile.WriteAllText(BatFile, BatContent, TEncoding.Default);

  if ShowWindow then
    ShowCmd := SW_SHOWNORMAL
  else
    ShowCmd := SW_HIDE;

  if ShellExecute(0, 'open', PChar(BatFile), nil, PChar(TPath.GetTempPath), ShowCmd) <= 32 then
    raise Exception.Create('Nepodaøilo se spustit skript pro dokonèení aktualizace.');

  Halt(0);
end;

procedure TLobbyForm.btnAktualizovatClick(Sender: TObject);
const
  CURRENT_APP_VERSION = '2.2.2.1';
  UPDATE_JSON_URL = 'https://github.com/czfala-pixel/TRITON-Lobby/releases/download/Lobby2/update.json';
var
  Http: TNetHTTPClient;
  Resp: IHTTPResponse;
  JsonVal: TJSONValue;
  Obj: TJSONObject;
  RemoteVer, DownloadUrl, TempFile, UrlWithCacheBust: string;
  FileStream: TFileStream;
  ReadyToRestart: Boolean;
begin
  ReadyToRestart := False;
  TempFile := '';
  btnAktualizovat.Enabled := False;

  if Assigned(lblUpdateStatus) then
    lblUpdateStatus.Caption := 'Kontroluji aktualizaci...';
  if Assigned(pbUpdate) then
  begin
    pbUpdate.Position := 0;
    pbUpdate.Visible := True;
  end;
  Application.ProcessMessages;

  try
    try
      Http := TNetHTTPClient.Create(nil);
      try
        Http.HandleRedirects := True;
        Http.UserAgent := 'TRITON-Lobby-Updater/1.0';
        Http.ConnectionTimeout := 10000;
        Http.ResponseTimeout := 30000;

        if Pos('?', UPDATE_JSON_URL) > 0 then
          UrlWithCacheBust := UPDATE_JSON_URL + '&t=' + IntToStr(GetTickCount)
        else
          UrlWithCacheBust := UPDATE_JSON_URL + '?t=' + IntToStr(GetTickCount);

        Resp := Http.Get(UrlWithCacheBust);
        if (Resp = nil) or (Resp.StatusCode <> 200) then
          raise Exception.CreateFmt('Nepodaøilo se stáhnout update.json (HTTP %d).', [Resp.StatusCode]);

        JsonVal := TJSONObject.ParseJSONValue(Resp.ContentAsString(TEncoding.UTF8));
        try
          if not (JsonVal is TJSONObject) then
            raise Exception.Create('Neplatný formát update.json.');

          Obj := TJSONObject(JsonVal);
          RemoteVer := Trim(Obj.GetValue<string>('version', ''));
          DownloadUrl := Trim(Obj.GetValue<string>('url', ''));

          if RemoteVer = '' then
            raise Exception.Create('V update.json chybí "version".');

          if RemoteVer = CURRENT_APP_VERSION then
          begin
            if Assigned(lblUpdateStatus) then
              lblUpdateStatus.Caption := 'Aplikace je aktuální (' + CURRENT_APP_VERSION + ').';
            ShowMessage('Aplikace je aktuální.');
            Exit;
          end;

          if DownloadUrl = '' then
            raise Exception.Create('V update.json chybí "url".');

          if Assigned(lblUpdateStatus) then
            lblUpdateStatus.Caption := 'Stahuji verzi ' + RemoteVer + '...';
          Application.ProcessMessages;

          // Zde se urèuje doèasný název staženého souboru v %TEMP%
          TempFile := TPath.Combine(TPath.GetTempPath, 'LobbyUpdate_' + RemoteVer + '.exe');
          if FileExists(TempFile) then
            DeleteFile(PChar(TempFile));

          FileStream := TFileStream.Create(TempFile, fmCreate);
          try
            Resp := Http.Get(DownloadUrl, FileStream);
          finally
            FileStream.Free;
          end;

          if (Resp = nil) or (Resp.StatusCode <> 200) or not FileExists(TempFile) then
          begin
            if FileExists(TempFile) then
              DeleteFile(PChar(TempFile));
            if Resp <> nil then
              raise Exception.CreateFmt('Stahování aktualizace selhalo (HTTP %d).', [Resp.StatusCode])
            else
              raise Exception.Create('Stahování aktualizace selhalo.');
          end;

          if not IsValidPEExecutable(TempFile, 4096) then
          begin
            DeleteFile(PChar(TempFile));
            raise Exception.Create(
              'Stažený soubor není platný .exe (zkontroluj URL v update.json nebo antivir).'
            );
          end;

          ReadyToRestart := True;
        finally
          JsonVal.Free;
        end;
      finally
        Http.Free;
      end;

      // Všechny zdroje jsou uvolnìny, nyní pøepíšeme pùvodní Lobby.exe a restartujeme
      if ReadyToRestart then
      begin
        if Assigned(lblUpdateStatus) then
          lblUpdateStatus.Caption := 'Instaluji aktualizaci...';
        if Assigned(pbUpdate) then
          pbUpdate.Position := 100;
        Application.ProcessMessages;

        ReplaceAndRestartLobby(TempFile, True); // True = zobrazí okno s prùbìhem aktualizace
      end;
    except
      on E: Exception do
      begin
        if Assigned(lblUpdateStatus) then
          lblUpdateStatus.Caption := 'Chyba aktualizace.';
        ShowMessage('Aktualizace selhala: ' + E.Message);
      end;
    end;
  finally
    btnAktualizovat.Enabled := True;
  end;
end;

procedure TLobbyForm.btnDochazkaClick(Sender: TObject);
begin
  Form1.Show;
  Form1.BringToFront;
end;

procedure TLobbyForm.btnEventyClick(Sender: TObject);
begin
  FormEventy.Show;
  FormEventy.BringToFront;
end;

procedure TLobbyForm.btnHerbareniClick(Sender: TObject);
begin
  SecondaryForm.Show;
  SecondaryForm.BringToFront;
end;

procedure TLobbyForm.OpenUrl(const AUrl: string);
var
  CleanUrl: string;
begin
  CleanUrl := Trim(AUrl);
  if CleanUrl = '' then
    Exit;

  if (not CleanUrl.StartsWith('http://', True)) and
     (not CleanUrl.StartsWith('https://', True)) then
    CleanUrl := 'https://' + CleanUrl;

  if ShellExecute(Handle, 'open', PChar(CleanUrl), nil, nil, SW_SHOWNORMAL) <= 32 then
    ShowMessage('Nepodaøilo se otevøít adresu: ' + CleanUrl);
end;

procedure TLobbyForm.btnHelperClick(Sender: TObject);
begin
  OpenUrl('https://docs.google.com/spreadsheets/d/1mdnjowAJxLNGDx-habAXJ2iylFDcnLQa1HkoCkDiNwg/edit?gid=0#gid=0');
end;

procedure TLobbyForm.btnOsvicenstviClick(Sender: TObject);
begin
  OpenUrl('https://docs.google.com/document/d/1afPbFuS__nOqGtFhC083u6rACrxQP9raEN7OBCRNXk4/edit?tab=t.0');
end;

procedure TLobbyForm.btnVylepsovaniClick(Sender: TObject);
begin
  frmVylepsovani.Show;
  frmVylepsovani.BringToFront;
end;

end.
