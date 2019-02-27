unit uAllocStreamMgr;

interface
uses
   Classes;
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

  TAllocStreamMgr = Class(TMemoryStream)
  private
    FSize: Integer;
    FHandle: THandle;
    FDataPointer: Pointer;
    FShareMemStreamRec: TShareMemStreamRec;
  public
    procedure SetShareMemContent(aRec: TShareMemStreamRec; aStream: TStream);
    function GetShareMemContent(aStream: TStream): TShareMemStreamRec;
    destructor Destroy; override;
    constructor Create;
  End;
implementation

{ TAllocStreamMgr }
uses
  Windows, SysUtils, Clipbrd;
var
  CF_PMFormat: Word;
constructor TAllocStreamMgr.Create;
begin
  CF_PMFormat := RegisterClipboardFormat(PChar('PMSL'));
end;

destructor TAllocStreamMgr.Destroy;
begin
  GlobalFree(FHandle);
  inherited;
end;

function TAllocStreamMgr.GetShareMemContent(
  aStream: TStream): TShareMemStreamRec;
var
  aHandle: THandle;
begin
  if not Clipboard.HasFormat(CF_PMFormat) then
    Exit;
  aHandle := Clipboard.GetAsHandle(CF_PMFormat);
  if aHandle <> 0 then
  begin
    FDataPointer := GlobalLock(aHandle);
    try
       //���ֶ�ȡ��ʽ ͨ��stream �����Լ���(������)
       //1.ͨ��stream
       SetPointer(FDataPointer, SizeOf(TShareMemStreamRec));
       Position := 0;
       Read(Result, SizeOf(TShareMemStreamRec));
       SetPointer(FDataPointer, Result.StreamSize + SizeOf(TShareMemStreamRec));

       //2.ͨ��CopyMemory
       //CopyMemory(@Result, FDataPointer, SizeOf(TShareMemStreamRec));
       //SetPointer(FDataPointer, Result.StreamSize + SizeOf(TShareMemStreamRec));
       //Position := SizeOf(TShareMemStreamRec);

       aStream.CopyFrom(Self, Result.StreamSize);
    finally
      GlobalUnlock(aHandle);
    end;
  end;
end;

procedure TAllocStreamMgr.SetShareMemContent(aRec: TShareMemStreamRec; aStream:
    TStream);
var
  StreamSize: Int64;
  NewRec: TShareMemStreamRec;
begin
  StreamSize := aStream.Size;
  //�����ø��� ûָ��(�±�ĵط��ͷŵ�)
  FShareMemStreamRec := aRec;
  FShareMemStreamRec.StreamSize :=  StreamSize;
  FSize := SizeOf(TShareMemStreamRec) +  StreamSize;

  if FHandle <> 0  then
    GlobalFree(FHandle);

  FHandle := GlobalAlloc(GMEM_DDESHARE, FSize);
  if FHandle <> 0 then
  begin
    FDataPointer := GlobalLock(FHandle);
    try
      SetPointer(FDataPointer, FSize);
      Write(FShareMemStreamRec, SizeOf(TShareMemStreamRec));
      CopyFrom(aStream, StreamSize);
    finally
      GlobalUnlock(FHandle);
    end;
    Clipboard.Open;
    try
      Clipboard.SetAsHandle(CF_PMFormat, FHandle);
    finally
      Clipboard.Close;
    end;
  end;
end;

end.
