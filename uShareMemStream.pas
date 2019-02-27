{ ************************************************************* }
{ ��Ʒ���ƣ������ڴ�(�̳�TMemoryStream)���̰߳�ȫ               }
{ ��Ԫ������������򶼿��Զ����ڴ�                              }
{ ��Ԫ���ߣ�pzx                                                 }
{ ����ʱ�䣺2019/02/26                                          }
{ ��    ע��1.�����ö�д Read/write ������Record
            2.�������Ļ�ע����CopyForm(ע��1.2����)
            3.���������ͷ�(�ᵼ�����������Ҳ���)
            4.�����ͷŵ�ԭ����ֻʣ1��exe
            5.���̰߳�ȫ
            6.ע���ͷ����� Get����һ��Ҫ UnMappingAndFree
                           Set����һ��Ҫ ���ǰһ����Handle

 ************************************************************* }
unit uShareMemStream;

interface

uses
  SysUtils, Classes, Syncobjs, Windows;

type
  TShareMemStream = class(TMemoryStream)
  private
    FFile: THandle;
    FSize: Int64;
    FEvent: TEvent;
    FAlreadyExists: Boolean;
  protected
    property Event: TEvent read FEvent;
  public
    constructor Create(const ShareName: string; ACCESS: DWORD =
        FILE_MAP_ALL_ACCESS; ASize: Int64 = 16 * 1024 * 1024; OpenFile: Boolean =
        false);
    /// <summary>
    /// �����ͷŸö���-> �����ͷŶ�Ӧ���ڴ�
    /// </summary>
    destructor Destroy; override;
    function UnMappingAndFree: Boolean;

    /// <summary>
    /// �����ͷ�-> ����ʣ��1����Exeʱ�Ž����ͷ�
    /// </summary>
    function UnMappingAndCanFree: Boolean;
    function GetLock(ATimeOut: DWORD = INFINITE): Boolean;
    procedure ReleaseLock();
    function GetFileHandle:THandle;
    property AlreadyExists: Boolean read FAlreadyExists;
  end;

implementation
uses
  TlHelp32, Dialogs;
procedure InitSecAttr(var sa: TSecurityAttributes; var sd: TSecurityDescriptor);
begin
  sa.nLength := sizeOf(sa);
  sa.lpSecurityDescriptor := @sd;
  sa.bInheritHandle := false;
  InitializeSecurityDescriptor(@sd, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@sd, true, nil, false);
end;

{ TShareMem }
function TShareMemStream.UnMappingAndFree: Boolean;
begin
  Result := False;
  if Memory <> nil then
  begin
    UnmapViewOfFile(Memory);
    SetPointer(nil, 0);
    Position := 0;
  end;
  if FFile <> 0 then
  begin
    CloseHandle(FFile);
    Result := True;
    FFile := 0;
  end;
end;

function TShareMemStream.UnMappingAndCanFree: Boolean;
var
  ProcessName : string; //������
  FSnapshotHandle:THandle; //���̿��վ��
  FProcessEntry32:TProcessEntry32; //������ڵĽṹ����Ϣ
  ContinueLoop:Boolean;
  MyHwnd:THandle;
  ExeCount: Integer;
begin
  Result := False;
  if Memory <> nil then
  begin
    UnmapViewOfFile(Memory);
    SetPointer(nil, 0);
    Position := 0;
  end;
  //���û��������������-> ���������һ���򿪵ĳ���
  ExeCount := 0;
  FSnapshotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0); //����һ�����̿���
  FProcessEntry32.dwSize:=Sizeof(FProcessEntry32);
  ContinueLoop:=Process32First(FSnapshotHandle,FProcessEntry32); //�õ�ϵͳ�е�һ������
  //ѭ������
  while ContinueLoop do
  begin
    ProcessName := FProcessEntry32.szExeFile;
    if(SameText(ProcessName, ExtractFileName(ParamStr(0)))) then
      Inc(ExeCount);
    ContinueLoop:=Process32Next(FSnapshotHandle,FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle); // �ͷſ��վ��
  if ExeCount = 1 then
    if FFile <> 0 then
    begin
      CloseHandle(FFile);
      Result := True;
      FFile := 0;
    end;
end;

constructor TShareMemStream.Create(const ShareName: string; ACCESS: DWORD =
    FILE_MAP_ALL_ACCESS; ASize: Int64 = 16 * 1024 * 1024; OpenFile: Boolean =
    false);
var
  sa: TSecurityAttributes;
  sd: TSecurityDescriptor;
  lprotect: DWORD;
  e: Integer;
begin
  FEvent := TEvent.Create(nil, false, true, ShareName +
    '_TShareMemStream_Event');
  FSize := ASize;
  InitSecAttr(sa, sd);
  ACCESS := ACCESS and (not SECTION_MAP_EXECUTE);
  if (ACCESS and FILE_MAP_WRITE) = FILE_MAP_WRITE then
    lprotect := PAGE_READWRITE
  else if (ACCESS and FILE_MAP_READ) = FILE_MAP_READ then
    lprotect := PAGE_READONLY;
  if OpenFile then
  begin
    FFile := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar('Global\'+ShareName));
    if FFile = 0 then
    begin
      MessageDlg('No Data Found!', mtWarning, [mbOK], 0);
      Exit;
    end;
  end
  else
  begin
    FFile := CreateFileMapping(INVALID_HANDLE_VALUE, @sa, lprotect,
      Int64Rec(FSize).Hi, Int64Rec(FSize).Lo, PChar('Global\'+ShareName));
    e := GetLastError;
    if FFile = 0 then
    begin
      raise Exception.Create('CreateFileMapping Error!');
      Exit;
    end;
    FAlreadyExists := e = ERROR_ALREADY_EXISTS;
  end;
  SetPointer(MapViewOfFile(FFile, ACCESS, 0, 0, Int64Rec(FSize).Lo),
    Int64Rec(FSize).Lo);
end;

destructor TShareMemStream.Destroy;
begin
  if FEvent <> nil then
    FEvent.Free;
  inherited Destroy;
end;

function TShareMemStream.GetFileHandle: THandle;
begin
  Result := FFile;
end;

function TShareMemStream.GetLock(ATimeOut: DWORD): Boolean;
var
  wr : TWaitResult;
begin
  wr := FEvent.WaitFor(ATimeOut);
  Result := wr = wrSignaled;
end;

procedure TShareMemStream.ReleaseLock;
begin
  FEvent.SetEvent;
end;

end.
