(*----------------------------------------------------
PS����д����򡱽��ӳ���ϵ���ر��ڴ�ӳ���ļ��ԡ���ȡ���򡱵�Ӱ�졣
1) д�������ӳ���ϵ����Ӱ���ȡ����Ķ�ȡ�����ر��ڴ�ӳ���ļ�����
   Ӱ���ȡ����Ķ�ȡ����
2) ���ӳ���ϵ��ر��ڴ�ӳ���ļ���˳��Ҫ�󣬼�ʱ�����ӳ���ϵҲ��ֱ
   �ӹر��ڴ�ӳ���ļ�
3) ��������ͨѶʱ��Ҫʹ��sendmessage,ͬ��������������postmessage,
   ��ֹǰ���ѹر��ڴ�ӳ���ļ��������߻�û��ȡ��


CreateFileMapping������ʹ���ĵ�
HANDLE CreateFileMapping(
HANDLE hFile,                       //�����ļ����
LPSECURITY_ATTRIBUTES lpAttributes, //��ȫ����
DWORD flProtect,                    //��������
DWORD dwMaximumSizeHigh,            //��λ�ļ���С
DWORD dwMaximumSizeLow,             //��λ�ļ���С
LPCTSTR lpName                      //�����ڴ�����
);
--------------------------------------------------------*)
unit ufrmShareMem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uShareMemStreamMgr;

type
  //�����ڴ�ṹ��
  PShareMem = ^TShareMem;
  TShareMem = Record
    id:string[10];
    name:string[20];
    age:Integer;
    MemSize: Cardinal;
    astream: TFileStream;
  end;

  TMyClass = class
  public
    name: string;
    haha: string;
    age: Integer;
    function erqerewqr: string;
  end;

  TfrmShareMem = class(TForm)
    Memo1: TMemo;
    BtnCreatFile: TButton;
    BtnOpenFile: TButton;
    BtnBuildMapping: TButton;
    BtnWriteInfoIntoMem: TButton;
    BtnRemoveTheBindding: TButton;
    BtnCloseTheMappingFile: TButton;
    BtnReadTheInfo: TButton;
    BtnClear: TButton;
    btnCopy: TButton;
    BtnPast: TButton;
    CopyNew: TButton;
    PasteNew: TButton;
    FreeWhenClose: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOpenFileClick(Sender: TObject);
    procedure BtnCreatFileClick(Sender: TObject);
    procedure BtnBuildMappingClick(Sender: TObject);
    procedure BtnWriteInfoIntoMemClick(Sender: TObject);
    procedure BtnRemoveTheBinddingClick(Sender: TObject);
    procedure BtnCloseTheMappingFileClick(Sender: TObject);
    procedure BtnReadTheInfoClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure BtnPastClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CopyNewClick(Sender: TObject);
    procedure FreeWhenCloseClick(Sender: TObject);
    procedure PasteNewClick(Sender: TObject);
  private
    //����������
    aShareMemStreamRec: TShareMemStreamRec;
    FShareMemStreamMgr: TShareMemStreamMgr;
    shareMemName:string; //�����ڴ���
    fileHandle : THandle;//�ڴ�ӳ���ļ����
    pUserInfoShareMem : PShareMem;//ָ�����ڴ��ָ��
    aUserInfoShareMem : TShareMem;//ָ�����ڴ��ָ��
    aUserInfoShareMem2 : TShareMem;//ָ�����ڴ��ָ��
    aMyClass: TMyClass;
  public
    /// <summary>
    /// �������ڴ�ӳ���ļ���
    /// </summary>
    procedure CreatShareMem;
    /// <summary>
    /// ����ӳ���ϵ
    ///�����ڴ�ӳ���ļ����롰Ӧ�ó����ַ�ռ䡱����ӳ���ϵ
    /// </summary>
    procedure BiuldTheMapping;
    /// <summary>
    /// д����Ϣ
    /// </summary>
    procedure WriteInfoIntoMem;
    /// <summary>
    /// ���ӳ���ϵ
    ///  ������ڴ�ӳ���ļ����롰Ӧ�ó����ַ�ռ䡱��ӳ���ϵ
    /// </summary>
    procedure RemoveTheBindding;
    /// <summary>
    /// �رա��ڴ�ӳ���ļ���
    /// </summary>
    procedure CloseTheMappingFile;
    /// <summary>
    /// �򿪡��ڴ�ӳ���ļ���
    /// </summary>
    procedure OpenTheMappingMemFile;
    /// <summary>
    /// ��ȡ��Ϣ
    /// </summary>
    procedure ReadTheInfo;

  end;

var
  frmShareMem: TfrmShareMem;

implementation
uses
  uShareMem, uShareMemStream;
{$R *.dfm}

procedure TfrmShareMem.FormDestroy(Sender: TObject);
begin
  FShareMemStreamMgr.Free;
end;

procedure TfrmShareMem.FormCreate(Sender: TObject);
begin
  shareMemName := 'PMTestShareMapping';
  FShareMemStreamMgr := TShareMemStreamMgr.Create;
end;

{ TfrmShareMem }

procedure TfrmShareMem.BiuldTheMapping;
begin
  //�����ڴ�ӳ���ļ����롰Ӧ�ó����ַ�ռ䡱����ӳ���ϵ
  aMyClass := MapViewOfFile(fileHandle,FILE_MAP_ALL_ACCESS, 0, 0, TMyClass.InstanceSize);
  if aMyClass <> nil then
  begin
     Self.Memo1.Lines.Add('�ѳɹ�����ӳ���ϵ��');
  end;
end;

procedure TfrmShareMem.CloseTheMappingFile;
begin
  //�ر��ڴ�ӳ���ļ�
  if fileHandle<> 0 then
     CloseHandle(fileHandle);
  Self.Memo1.Lines.Add('�ѳɹ��ر��ڴ�ӳ���ļ���');
end;

procedure TfrmShareMem.CreatShareMem;
begin
  //�������ڴ�ӳ���ļ���
  fileHandle:=CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, TMyClass.InstanceSize, PChar(shareMemName));
  if fileHandle <> 0 then
  begin
    Self.Memo1.Lines.Add('�ѳɹ������ڴ�ӳ���ļ���');
  end;
end;

procedure TfrmShareMem.OpenTheMappingMemFile;
begin
  // �򿪡��ڴ�ӳ���ļ���
  fileHandle:=OpenFileMapping(FILE_MAP_ALL_ACCESS,false,pchar(shareMemName));
  if self.FileHandle <> 0 then
  begin
    Self.Memo1.Lines.Add('�ѳɹ����ڴ�ӳ���ļ���')
  end;
end;

procedure TfrmShareMem.ReadTheInfo;
var
  userInfoStr: string;
begin
  //��ȡ��Ϣ
  if aMyClass <> nil then
  begin
    userInfoStr:='�����ڴ��л�ȡ��MyClass��Ϣ����:'+#13#10;
    userInfoStr:=userInfoStr+'MyClassId�ţ�'+aMyClass.name+#13#10;
    userInfoStr:=userInfoStr+'MyClass������'+aMyClass.haha+#13#10;
    userInfoStr:=userInfoStr+'MyClass���䣺'+IntToStr(aMyClass.age);
    Self.Memo1.Lines.Add(userInfoStr);
  end;
end;

procedure TfrmShareMem.RemoveTheBindding;
begin
  //������ڴ�ӳ���ļ����롰Ӧ�ó����ַ�ռ䡱��ӳ���ϵ
  if aMyClass<> nil then
     UnmapViewOfFile(aMyClass);
  Self.Memo1.Lines.Add('�ѳɹ����ӳ���ϵ��');
end;

procedure TfrmShareMem.WriteInfoIntoMem;
begin
  //д����Ϣ
  aMyClass.name := 'para';
  aMyClass.haha := 'test';
  aMyClass.age := 11;
  Self.Memo1.Lines.Add('д����Ϣ��');
end;

procedure TfrmShareMem.BtnBuildMappingClick(Sender: TObject);
begin
  BiuldTheMapping;
end;

procedure TfrmShareMem.BtnClearClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TfrmShareMem.BtnCloseTheMappingFileClick(Sender: TObject);
begin
  CloseTheMappingFile;
end;

procedure TfrmShareMem.BtnCreatFileClick(Sender: TObject);
begin
  CreatShareMem;
end;

procedure TfrmShareMem.BtnOpenFileClick(Sender: TObject);
begin
  OpenTheMappingMemFile;
end;

procedure TfrmShareMem.BtnReadTheInfoClick(Sender: TObject);
begin
  ReadTheInfo
end;

procedure TfrmShareMem.BtnRemoveTheBinddingClick(Sender: TObject);
begin
  RemoveTheBindding;
end;

procedure TfrmShareMem.BtnWriteInfoIntoMemClick(Sender: TObject);
begin
  WriteInfoIntoMem;
end;

procedure TfrmShareMem.btnCopyClick(Sender: TObject);
begin
  CreatShareMem;
  BiuldTheMapping;
  WriteInfoIntoMem;
end;

procedure TfrmShareMem.BtnPastClick(Sender: TObject);
begin
  OpenTheMappingMemFile;
  BiuldTheMapping;
  ReadTheInfo;
end;

procedure TfrmShareMem.Button1Click(Sender: TObject);
var
  ms : TShareMemStream;
  aStream: TMemoryStream;
begin
  aStream :=  TMemoryStream.Create();
  aStream.LoadFromFile( 'F:/1.xml');
  ms := TShareMemStream.Create('Globaltest', FILE_MAP_ALL_ACCESS, 99);
  if (ms.Memory <> nil)(*and(ms.AlreadyExists)*) then
  //�������ʧ��Memoryָ���ǿ�ָ��
  //AlreadyExists��ʾ�Ѿ�������,Ҳ����֮ǰ������(Ҳ���Ǳ�Ľ���)��������.
  begin
    aUserInfoShareMem.name := 'para new Unit Test wer wer tre wt!';
    aUserInfoShareMem.id := 'para new Unit Test!';
    aUserInfoShareMem.age := 99;
    aUserInfoShareMem.MemSize :=  aStream.Size;
    //��ȡ��,��������̷߳��ʰ�ȫ����
    if ms.GetLock(INFINITE) then
    begin
      Self.Memo1.Lines.Add('TShareMem size: ' + IntToStr(sizeof(aUserInfoShareMem)));
      ms.write(aUserInfoShareMem, SizeOf(aUserInfoShareMem));
      Self.Memo1.Lines.Add('aStream size: ' + IntToStr(aStream.Size));
      ms.CopyFrom(aStream, aStream.Size);
      //�ͷ���
      ms.ReleaseLock();
    end;
  end;
  //ms.UnMappingAndFree;
  ms.free;
  aStream.Free;
end;

procedure TfrmShareMem.Button2Click(Sender: TObject);
var
  ms : TShareMemStream;
  aStream: TMemoryStream;
begin
  aStream := TMemoryStream.Create;
  ms := TShareMemStream.Create('Globaltest', FILE_MAP_ALL_ACCESS, 4096);
  if (ms.Memory <> nil)(*and(ms.AlreadyExists)*) then
  //�������ʧ��Memoryָ���ǿ�ָ��
  //AlreadyExists��ʾ�Ѿ�������,Ҳ����֮ǰ������(Ҳ���Ǳ�Ľ���)��������.
  begin
    //��ȡ��,��������̷߳��ʰ�ȫ����
    if ms.GetLock(INFINITE) then
    begin
      Self.Memo1.Lines.Add('TShareMem size: ' + IntToStr(sizeof(aUserInfoShareMem2)));
      ms.Read(aUserInfoShareMem2, SizeOf(aUserInfoShareMem2));
      Self.Memo1.Lines.Add('aStream size: ' + IntToStr(aUserInfoShareMem2.MemSize));
      aStream.CopyFrom(ms, aUserInfoShareMem2.MemSize);
      //�ͷ���
      ms.ReleaseLock();
      aStream.SaveToFile('F:/1111.xml');
    end;
  end;
  ms.UnMappingAndFree;
  ms.free;
  aStream.Free;
end;

procedure TfrmShareMem.Button3Click(Sender: TObject);
var
  ms:TMemoryStream;
begin
  aUserInfoShareMem.name := 'para new Unit Test wer wer tre wt!';
  aUserInfoShareMem.id := 'para new Unit Test!';
  aUserInfoShareMem.age := 99;
  ms:=TMemoryStream.Create;
  ms.Write(aUserInfoShareMem,SizeOf(aUserInfoShareMem));

  ms.Position:=0;
  ms.Read(aUserInfoShareMem2,SizeOf(aUserInfoShareMem2));
  ms.Free;
  ShowMessage(aUserInfoShareMem2.name);
end;

procedure TfrmShareMem.Button4Click(Sender: TObject);
var
  aStream: TMemoryStream;
begin
  aStream :=  TMemoryStream.Create();
  try
    aStream.LoadFromFile( 'F:/1.xml');
    aShareMemStreamRec.aToken := 'para new Unit Test wer wer tre wt!';
    aShareMemStreamRec.aLabel := 'para new Unit Test!';
    aShareMemStreamRec.aBrief := '99';

    FShareMemStreamMgr.SetShareMemContent(@aShareMemStreamRec, aStream);
  finally
    aStream.Free;
  end;
end;

procedure TfrmShareMem.Button5Click(Sender: TObject);
var
  aStream: TMemoryStream;
begin
  aStream :=  TMemoryStream.Create();
  try
    aShareMemStreamRec := FShareMemStreamMgr.GetShareMemContent(aStream);
    MessageDlg(aShareMemStreamRec.aToken + ',' + aShareMemStreamRec.aLabel + ',' +aShareMemStreamRec.aBrief , mtWarning, [mbOK], 0);
    if aStream.Size > 0 then
      aStream.SaveToFile('F:/1111.xml');
  finally
    aStream.Free;
  end;
end;

procedure TfrmShareMem.CopyNewClick(Sender: TObject);
var
  aStream: TStream;
begin
  try
    pUserInfoShareMem := (TShareMemUtil<TShareMem>.GetOrCreateObject(sizeof(TShareMem) + aStream.Size));
    pUserInfoShareMem.name := 'para new Unit Test wer wer tre wt!';
    pUserInfoShareMem.id := 'para new Unit Test!';
    pUserInfoShareMem.age := 99;
    pUserInfoShareMem.MemSize := (aStream.Size);
    Self.Memo1.Lines.Add('TShareMem size: ' + IntToStr(sizeof(TShareMem)));
    Self.Memo1.Lines.Add('aStream size: ' + IntToStr(aStream.Size));
    //������
    CopyMemory((@pUserInfoShareMem.astream), aStream, aStream.Size)
  finally
    aStream.Free;
  end;
end;

procedure TfrmShareMem.FreeWhenCloseClick(Sender: TObject);
begin
  TShareMemUtil<TShareMem>.UnMappingAndCanFree(pUserInfoShareMem);
end;

procedure TfrmShareMem.PasteNewClick(Sender: TObject);
var
  aStream: TStream;
begin
  pUserInfoShareMem := (TShareMemUtil<TShareMem>.GetOrCreateObject(sizeof(TShareMem)+529));
  Self.Memo1.Lines.Add(pUserInfoShareMem.name);
  Self.Memo1.Lines.Add(pUserInfoShareMem.id);
  Self.Memo1.Lines.Add(IntToStr(pUserInfoShareMem.age));
  Self.Memo1.Lines.Add(IntToStr(pUserInfoShareMem.MemSize));
  aStream:= TStream.Create;
  try
    CopyMemory(aStream, @pUserInfoShareMem.astream, pUserInfoShareMem.MemSize);
    MessageDlg(IntToStr(astream.Size), mtWarning, [mbOK], 0);
  finally
    aStream.Free;
  end;
end;

{ TMyClass }

function TMyClass.erqerewqr: string;
begin

end;

end.
