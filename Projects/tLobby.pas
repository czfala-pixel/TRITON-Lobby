unit tLobby;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.UITypes,
  tDochazka, tHerbareni, tEventy, Vcl.ExtCtrls;

type
  TLobbyForm = class(TForm)
    btnDochazka: TButton;
    btnHerbareni: TButton;
    btnEventy: TButton;
    Panel1: TPanel;
    procedure btnDochazkaClick(Sender: TObject);
    procedure btnHerbareniClick(Sender: TObject);
    procedure btnEventyClick(Sender: TObject);
  private
  public
  end;

var
  LobbyForm: TLobbyForm;

implementation

{$R *.dfm}

procedure TLobbyForm.btnDochazkaClick(Sender: TObject);
begin
  Form1.Show;
  Form1.BringToFront;
end;

procedure TLobbyForm.btnHerbareniClick(Sender: TObject);
begin
  SecondaryForm.Show;
  SecondaryForm.BringToFront;
end;

procedure TLobbyForm.btnEventyClick(Sender: TObject);
begin
  FormEventy.Show;
  FormEventy.BringToFront;
end;

end.
