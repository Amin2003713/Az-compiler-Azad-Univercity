﻿{
  واحد: SyntaxLine
  توضیحات:
  این واحد شامل ساختار TSyntaxLine است که برای پردازش متنی به منظور تحلیل سینتکس طراحی شده است.
  این ساختار شامل عملیاتی مانند خواندن فایل، پیمایش در متن، بررسی پایان فایل و گزارش خطاهای سینتکس به همراه اطلاعات دقیق می‌باشد.

  توسعه‌دهنده: mohhamad amin ahmadi
  تاریخ: 2025-02-21
}

unit SyntaxLine;

interface

uses
  Dialogs, SysUtils, IOUtils, Character, Types, Generics.Collections;

type
  TSyntaxLine = record
  private const
    END_OF_FILE_CHAR = #1; // نشانگر انتهای فایل
  private
    FSourceText: string; // متن اصلی مورد پردازش
    FCurrentPos: Integer; // موقعیت فعلی در متن
    FNewPosition: Integer; // موقعیت ثانویه (برای استفاده‌های آینده)
    FLineColumn: TPoint; // موقعیت فعلی به صورت (خط، ستون)؛ X: خط، Y: ستون
  public
    /// <summary>
    /// تمام فیلدهای داخلی را به حالت اولیه بازنشانی می‌کند.
    /// </summary>
    procedure Reset;

    /// <summary>
    /// متن ورودی را تنظیم کرده و نشانگر انتهای فایل را به آن اضافه می‌کند.
    /// </summary>
    procedure SetSourceText(const AText: string);

    /// <summary>
    /// متن منبع را از فایل مشخص شده بارگذاری می‌کند و نشانگر انتهای فایل را به آن اضافه می‌کند.
    /// </summary>
    procedure LoadFromFile(const AFileName: string);

    /// <summary>
    /// موقعیت فعلی را به APos تغییر می‌دهد، اطلاعات خط و ستون را به‌روزرسانی کرده و متنی شامل کاراکترهای طی شده برمی‌گرداند.
    /// </summary>
    function MoveToPosition(APos: Integer): string;

    /// <summary>
    /// در صورت رسیدن به پایان متن یا مشاهده نشانگر انتهای فایل، مقدار True برمی‌گرداند.
    /// </summary>
    function IsEndOfFile: Boolean;

    /// <summary>
    /// خط جاری متن را با توجه به وجود کاراکترهای newline استخراج و برمی‌گرداند.
    /// </summary>
    function GetCurrentLine: string;

    /// <summary>
    /// در صورت بروز خطای سینتکس، پیام خطا به همراه اطلاعات خط، کاراکتر و موقعیت فعلی نمایش داده و اجرای برنامه متوقف می‌شود.
    /// </summary>
    procedure ReportSyntaxError(const Msg: string);

    function IsUnread: Boolean;
    function SkipUnread: string;

    function IsId: Boolean;
    function SkipId: string;

    function IsInt: Boolean;
    function SkipInt: Integer;
  end;

implementation

{ TSyntaxLine }

function TSyntaxLine.SkipId: string;
begin
  if IsId then
    Result := MoveToPosition(FNewPosition)
  else
    ReportSyntaxError('شناسه نامعتبر.')
end;



function TSyntaxLine.SkipInt: Integer;
begin
   if IsInt then
    Result := MoveToPosition(FNewPosition).ToInteger
  else
    ReportSyntaxError('شناسه نامعتبر.')
end;

function TSyntaxLine.IsId: Boolean;
var
  p, state: Integer;
  text: Char;
begin
  SkipUnread;
  state := 0; // مقدار اولیه وضعیت
  for p := FCurrentPos to High(FSourceText) do
  begin
    text := FSourceText[p];
    case state of

      0:
        if text.IsLetter then
          state := 1
        else
          Break;

      1:
        if text.IsLetterOrDigit then
          state := 1
        else
          Break;
    end;
  end;

  Result := state in [1];

  if Result then
    FNewPosition := p;
end;

function TSyntaxLine.IsInt: Boolean;
var
  p, state: Integer;
  text: Char;
begin
  SkipUnread;
  state := 0; // مقدار اولیه وضعیت
  for p := FCurrentPos to High(FSourceText) do
  begin
    text := FSourceText[p];
    case state of

      0:
        if text.IsDigit then
          state := 2
        else if text in ['-', '+'] then
          state := 1
        else
          Break;

      1:
        if text.IsDigit then
          state := 2
        else
          Break;

      2:
        if text.IsDigit then
          state := 2
        else
          Break;

    end;
  end;
  Result := state in [2];

  if Result then
    FNewPosition := p;
end;

function TSyntaxLine.SkipUnread: string;
begin
  Result := '';
  while IsUnread do
    Result := Result + MoveToPosition(FNewPosition);
end;

{
  تابع IsUnread بررسی می‌کند که آیا متن باقی‌مانده در `FSourceText` شامل فضای خالی یا کامنت است یا خیر.

  نویسنده: محمد امین احمدی
  تاریخ: ۲۰۲۵

  توضیحات:
  - این تابع یک پردازش خودکار روی `FSourceText` از موقعیت فعلی `FCurrentPos` انجام می‌دهد.
  - در صورتی که فقط فضاهای خالی یا کامنت‌ها در متن باقی مانده باشند، مقدار `True` برمی‌گرداند.
  - کامنت‌ها می‌توانند به دو صورت باشند:
  1. `//` تا انتهای خط
  2. `/* ... */` که چندخطی است.
  - اگر متن شامل کاراکتر دیگری باشد، پردازش متوقف شده و مقدار `False` برگردانده می‌شود.

  ورودی:
  - هیچ ورودی مستقیمی ندارد اما از `FSourceText` استفاده می‌کند.

  خروجی:
  - مقدار `Boolean` که نشان می‌دهد آیا متن خوانده‌نشده فقط شامل فضاهای خالی یا کامنت‌ها است یا خیر.
}
function TSyntaxLine.IsUnread: Boolean;
var
  p, state: Integer;
  text: Char;
begin
  state := 0; // مقدار اولیه وضعیت
  for p := FCurrentPos to High(FSourceText) do
  begin
    text := FSourceText[p];

    case state of
      // وضعیت ۰: بررسی اولین کاراکتر از متن باقی‌مانده
      0:
        if text = '/' then
          state := 1 // احتمال شروع یک کامنت
        else if text.IsWhiteSpace then
          state := 5 // فضای خالی شناسایی شد
        else
          Break; // متن معتبری وجود دارد، پردازش متوقف شود.

      // وضعیت ۱: بررسی اینکه آیا `/` دوم آمده یا `*`
      1:
        if text = '/' then
          state := 6 // کامنت تک‌خطی شناسایی شد
        else if text = '*' then
          state := 2 // کامنت چندخطی شناسایی شد
        else
          Break; // متن معمولی است، پردازش متوقف شود.

      // وضعیت ۲: درون یک کامنت چندخطی قرار داریم
      2:
        if text = '*' then
          state := 3; // احتمال پایان کامنت چندخطی
      // در غیر این صورت، همچنان درون کامنت هستیم.

      // وضعیت ۳: ممکن است انتهای کامنت چندخطی باشد
      3:
        if text = '*' then
          state := 3 // همچنان در حالت پایان کامنت
        else if text = '/' then
          state := 4 // کامنت بسته شد
        else
          state := 2; // بازگشت به داخل کامنت

      // وضعیت ۵: در حال خواندن فضای خالی هستیم
      5:
        if text.IsWhiteSpace then
          state := 5 // همچنان فضای خالی است
        else
          Break; // متن معمولی پیدا شد، پردازش متوقف شود.

      // وضعیت ۶: درون کامنت تک‌خطی هستیم
      6:
        if text in [#10, #13] then
          state := 7 // کامنت تک‌خطی تمام شد
        else
          state := 6; // همچنان در کامنت تک‌خطی هستیم

      // وضعیت‌های ۴ و ۷: کامنت به پایان رسیده است
      4, 7:
        Break;
    end;
  end;

  // بررسی اینکه آیا کل متن شامل فضای خالی یا کامنت بوده است
  Result := state in [4, 5, 7];

  // به‌روزرسانی موقعیت جدید اگر متن فقط شامل فضای خالی یا کامنت بود
  if Result then
    FNewPosition := p;
end;

procedure TSyntaxLine.Reset;
begin
  // بازنشانی تمامی فیلدهای داخلی به حالت اولیه
  FSourceText := '';
  FCurrentPos := 0;
  FNewPosition := 0;
  FLineColumn := Point(0, 0);
end;

procedure TSyntaxLine.SetSourceText(const AText: string);
begin
  // بازنشانی و تنظیم متن همراه با افزودن نشانگر انتهای فایل
  Reset;
  FSourceText := AText + END_OF_FILE_CHAR;
  FCurrentPos := 1;
  FNewPosition := 1;
end;

procedure TSyntaxLine.LoadFromFile(const AFileName: string);
var
  Directory, FileToSearch, FileFound: string;
  Files: TStringDynArray;
  I: Integer;
begin
  // Reset any internal state
  Reset;

  // Extract the directory and file name
  Directory := ExtractFilePath(AFileName);
  FileToSearch := ExtractFileName(AFileName);
  if Directory = '' then
    Directory := GetCurrentDir;

  // Enumerate all files in the directory
  Files := TDirectory.GetFiles(Directory);
  FileFound := '';
  for I := 0 to High(Files) do
  begin
    // Compare file names ignoring case
    if SameText(ExtractFileName(Files[I]), FileToSearch) then
    begin
      FileFound := Files[I];
      Break;
    end;
  end;

  // If a matching file was found, load it; otherwise raise an exception
  if FileFound <> '' then
    FSourceText := TFile.ReadAllText(FileFound) + END_OF_FILE_CHAR
  else
    raise Exception.Create('فایل یافت نشد: ' + AFileName);

  FCurrentPos := 1;
  FNewPosition := 1;
end;

function TSyntaxLine.MoveToPosition(APos: Integer): string;
var
  TextBuilder: TStringBuilder;
begin
  TextBuilder := TStringBuilder.Create;
  try
    // پیمایش از موقعیت فعلی تا APos و به‌روزرسانی اطلاعات خط و ستون
    while FCurrentPos < APos do
    begin
      TextBuilder.Append(FSourceText[FCurrentPos]);
      if FSourceText[FCurrentPos] = #10 then
      begin
        Inc(FLineColumn.X); // افزایش شماره خط
        FLineColumn.Y := 1; // بازنشانی شماره ستون به 1
      end
      else
        Inc(FLineColumn.Y); // افزایش شماره ستون
      Inc(FCurrentPos);
    end;
    Result := TextBuilder.ToString;
  finally
    TextBuilder.Free;
  end;
end;

function TSyntaxLine.IsEndOfFile: Boolean;
begin
  // بررسی پایان متن یا رسیدن به نشانگر انتهای فایل
  Result := (FCurrentPos > Length(FSourceText)) or
    (FSourceText[FCurrentPos] = END_OF_FILE_CHAR);
end;

function TSyntaxLine.GetCurrentLine: string;
var
  StartIndex, EndIndex: Integer;
begin
  // تعیین شروع خط جاری با جستجو به عقب تا یافتن کاراکتر newline
  StartIndex := FCurrentPos;
  while (StartIndex > 1) and not(FSourceText[StartIndex - 1] in [#10, #12]) do
    Dec(StartIndex);

  // تعیین پایان خط جاری با جستجو به جلو تا یافتن کاراکتر newline
  EndIndex := FCurrentPos;
  while (EndIndex <= Length(FSourceText)) and
    not(FSourceText[EndIndex] in [#10, #12]) do
    Inc(EndIndex);

  // استخراج و برگرداندن خط جاری از متن
  Result := Copy(FSourceText, StartIndex, EndIndex - StartIndex);
end;

procedure TSyntaxLine.ReportSyntaxError(const Msg: string);
var
  LineInfo, CharInfo, LocInfo: string;
begin
  // ایجاد اطلاعات خطا شامل خط جاری، کاراکتر فعلی و موقعیت (خط، ستون)
  LineInfo := 'خط = ' + GetCurrentLine;
  CharInfo := 'کاراکتر = ' + FSourceText[FCurrentPos];
  LocInfo := 'موقعیت = (' + FLineColumn.X.ToString + ' , ' +
    FLineColumn.Y.ToString + ')';

  // نمایش پیام خطا به کاربر
  MessageDlg(Msg + sLineBreak + sLineBreak + LineInfo + sLineBreak + CharInfo +
    sLineBreak + LocInfo, mtError, [mbOK], 0);
  Abort;
end;

end.
