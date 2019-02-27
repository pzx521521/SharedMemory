{ ************************************************************* }
{ ��Ʒ���ƣ������ڴ�->������                                    }
{ ��Ԫ������������򶼿��Զ����ڴ�                              }
{ ��Ԫ���ߣ�pzx                                                 }
{ ����ʱ�䣺2019/02/26                                          }
{ ��    ע��1. CloseHandle һ��Ҫע�� ��ֹ�ڴ�й©
              1.1 Get��ʱ��  Ӧ��Ҫ CloseHandle(UnMappingAndFree)
              1.2 Set��ʱ�� һ��Ҫ  Close��һ�ε�Handle
              1.3 Destroy��ʱ��  һ��Ҫ  CloseHandle
 ************************************************************* }
unit uShareMemStreamMgr;

interface
uses
  uShareMemStream, Classes;
type
  //��¼��Ϣ-> Ĭ�Ͽ�ͷΪ��С
  //��βΪ��
  TShareMemStreamRec = record
    //����һ��Ҫ�� PChar
    aToken, aLabel, aBrief: PChar;
    Stream: TStream;
    StreamSize: Int64;
  end;
  PShareMemStreamRec = ^TShareMemStreamRec;

  TShareMemStreamMgr = class
  private
     FSize: Int64;
     FShareMemStream: TShareMemStream;
     FShareMemStreamRec: TShareMemStreamRec;
  public
    procedure SetShareMemContent(PRec: PShareMemStreamRec; aStream: TStream);
    function GetShareMemContent(aStream: TStream): TShareMemStreamRec;
    destructor Destroy; override;
    constructor Create;
  end;
implementation
uses
  Windows;
Const CST_PM_SL_Clipboard_SS = 'PM_SL_Clipboard_SS';
{ TShareMemStreamMgr }

constructor TShareMemStreamMgr.Create;
begin

end;

destructor TShareMemStreamMgr.Destroy;
begin
  if FShareMemStream <> nil then
  begin
    // ��ȫ�ͷ�-> �ᵼ�����������Ҳ���ճ��������
    FShareMemStream.UnMappingAndFree;
    FShareMemStream.Free;
  end;
  inherited;
end;

function TShareMemStreamMgr.GetShareMemContent(aStream: TStream):
    TShareMemStreamRec;
var
  aShareMemStream: TShareMemStream;
begin
  //�����θ� ��һ���ȸ�����Ĵ�С
  aShareMemStream := TShareMemStream.Create(CST_PM_SL_Clipboard_SS, FILE_MAP_ALL_ACCESS, SizeOf(Result), True);
  try
    if (aShareMemStream.Memory <> nil)(*and(ms.AlreadyExists)*) then
    //�������ʧ��Memoryָ���ǿ�ָ��
    //AlreadyExists��ʾ�Ѿ�������,Ҳ����֮ǰ������(Ҳ���Ǳ�Ľ���)��������.
    begin
      //��ȡ��,��������̷߳��ʰ�ȫ����
      if aShareMemStream.GetLock(INFINITE) then
      begin
        aShareMemStream.Read(Result, SizeOf(Result));
        //�ͷ���
        aShareMemStream.ReleaseLock();
      end;
    end;
  finally
    aShareMemStream.UnMappingAndFree;
    aShareMemStream.free;
  end;
  //�ڶ����ȸ����
  aShareMemStream := TShareMemStream.Create(CST_PM_SL_Clipboard_SS, FILE_MAP_ALL_ACCESS, SizeOf(Result)+Result.StreamSize);
  try
    if (aShareMemStream.Memory <> nil)(*and(ms.AlreadyExists)*) then
    //�������ʧ��Memoryָ���ǿ�ָ��
    //AlreadyExists��ʾ�Ѿ�������,Ҳ����֮ǰ������(Ҳ���Ǳ�Ľ���)��������.
    begin
      //��ȡ��,��������̷߳��ʰ�ȫ����
      if aShareMemStream.GetLock(INFINITE) then
      begin
        aShareMemStream.Read(Result, SizeOf(Result));
        aStream.CopyFrom(aShareMemStream, Result.StreamSize);
        //�ͷ���
        aShareMemStream.ReleaseLock();
      end;
    end;
  finally
    aShareMemStream.UnMappingAndFree;
    aShareMemStream.free;
  end;
end;

procedure TShareMemStreamMgr.SetShareMemContent(PRec: PShareMemStreamRec;
    aStream: TStream);
var
  StreamSize: Int64;
begin
  StreamSize := aStream.Size;
  //�����ø��� ûָ��(�±�ĵط��ͷŵ�)
  FShareMemStreamRec := PRec^;
  FShareMemStreamRec.StreamSize :=  StreamSize;
  FSize := SizeOf(TShareMemStreamRec) +  StreamSize;

  //ע�ⲻ���ͷ�-> ����Ҫ����  -> Set֮ǰҪ���ͷ���һ�εĶ���
  if FShareMemStream <> nil then
  begin
    FShareMemStream.UnMappingAndFree;
    FShareMemStream.Free;
  end;

  FShareMemStream := TShareMemStream.Create(CST_PM_SL_Clipboard_SS, FILE_MAP_ALL_ACCESS, FSize);
  try
    //������Ӧ�Զ��̵߳���
    if FShareMemStream.GetLock(INFINITE) then
    begin
      //���������������ڹ����ڴ���
      FShareMemStream.write(FShareMemStreamRec, SizeOf(FShareMemStreamRec));
      FShareMemStream.CopyFrom(aStream, aStream.Size);
      //�ͷ���
      FShareMemStream.ReleaseLock();
    end;
  finally

  end;
end;

end.
