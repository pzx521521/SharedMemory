program CreateFileMapping;

uses
  Forms,
  Dialogs,
  ufrmShareMem in 'ufrmShareMem.pas' {frmShareMem},
  uShareMemStream in 'uShareMemStream.pas',
  uShareMemStreamMgr in 'uShareMemStreamMgr.pas';

{$R *.res}

begin
  Application.Initialize;
  {$IFDEF DEBUG}
  //  ShowMessage('����ģʽ');
  {$ENDIF}
  {$IFDEF RELEASE}
  //  ShowMessage('����ģʽ');
  {$ENDIF}
  {$DEFINE Mydef}
  {$IFDEF Mydef}
  // ShowMessage('MyDef');
  {$ENDIF}
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmShareMem, frmShareMem);
  Application.Run;
end.
