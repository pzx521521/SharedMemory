unit uShareMem;

interface
uses
  Windows, TLHelp32, SysUtils;
type
  TShareMemUtil<T> = class
     class var fileHandle: THandle;
     class function GetOrCreateObject(size: Cardinal): Pointer;
     class function CreatShareMem(size: Cardinal): Pointer;
     class procedure UnMappingAndCanFree(aT: Pointer); static;
  end;
implementation
const
  ShareMemName = 'PMShareMemName';

{ TShareMemUtil<T> }
class function TShareMemUtil<T>.CreatShareMem(size: Cardinal): Pointer;
begin
  fileHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, size, PChar(shareMemName));
  Result := MapViewOfFile(fileHandle,FILE_MAP_ALL_ACCESS, 0, 0, size);
end;

class function TShareMemUtil<T>.GetOrCreateObject(size: Cardinal): Pointer;
begin
  //��OpenFile
  fileHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS,false,pchar(shareMemName));
  if self.FileHandle <> 0 then
    Result := MapViewOfFile(fileHandle,FILE_MAP_ALL_ACCESS, 0, 0, size)
  else
  begin
    Result := CreatShareMem(size);
  end;
end;

class procedure TShareMemUtil<T>.UnMappingAndCanFree(aT: Pointer);
var
  ProcessName : string; //������
  FSnapshotHandle:THandle; //���̿��վ��
  FProcessEntry32:TProcessEntry32; //������ڵĽṹ����Ϣ
  ContinueLoop:Boolean;
  MyHwnd:THandle;
  ExeCount: Integer;
begin
  if Assigned(aT) then
     UnmapViewOfFile(aT);
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
     CloseHandle(fileHandle);
end;

end.
