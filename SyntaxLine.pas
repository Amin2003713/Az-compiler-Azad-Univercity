(*
  Unit: SyntaxLine
  Description:
  This unit defines the TSyntaxLine record used for text processing and syntax analysis.
  It includes methods for:
  - Reading text from a file
  - Navigating through the text
  - Checking for end-of-file conditions
  - Reporting syntax errors with detailed information

  Developer: mohhamad amin ahmadi
  Date: 2025-02-21
*)

unit SyntaxLine;

interface

uses
  Dialogs, SysUtils, IOUtils, Character, Types, Generics.Collections , Math;

type
  /// <summary>
  /// TSyntaxLine manages a source text for syntax analysis. It supports methods for loading,
  /// scanning, error reporting, and skipping various tokens such as identifiers, integers, and numbers.
  /// </summary>
  TStrList = array of string;

   TStackRec<T> = record
   Stk: TStack<T>; // شی‌ء پشته داخلی

  class operator Initialize(out Dest: TStackRec<T>);
  class operator Finalize(var Dest: TStackRec<T>);
  
  procedure Push(const Value: T); inline;

  function Pop: T; inline;
  function Peek: T; inline;

end;

       TCode = record
    Op, Addr1, Addr2, Target: string;
  end;

  TCodeList = array of TCode;
  
    HCodeList = record helper for TCodeList
    function Add(Op, Addr1, Addr2, Target: string): Integer;
    function ToLines: TStrList;
    end;
  
  TSyntaxLine = record
  private const
    END_OF_FILE_CHAR = #1; // Marker indicating the end of the file
  private
    FSourceText: string; // The main source text to be processed
    FCurrentPos: Integer; // The current position in the source text
    FNewPosition: Integer;
    // A secondary position used to mark the end of recognized tokens
    FLineColumn: TPoint; // Represents the current line (X) and column (Y)
  public
    /// <summary>
    /// Resets all internal fields to their initial states.
    /// </summary>
    procedure Reset;

    /// <summary>
    /// Sets the input text and appends the end-of-file marker.
    /// </summary>
    procedure SetSourceText(const AText: string);

    /// <summary>
    /// Loads the source text from the specified file and appends the end-of-file marker.
    /// </summary>
    procedure LoadFromFile(const AFileName: string);

    /// <summary>
    /// Moves the current position to APos, updates line and column info,
    /// and returns the substring of all characters traversed.
    /// </summary>
    function MoveToPosition(APos: Integer): string;

    /// <summary>
    /// Returns True if the current position is at or beyond the end of the text
    /// or if the end-of-file marker is encountered.
    /// </summary>
    function IsEndOfFile: Boolean;

    /// <summary>
    /// Extracts and returns the current line of the text based on newline characters.
    /// </summary>
    function GetCurrentLine: string;

    /// <summary>
    /// Displays a syntax error message with details about the line, character,
    /// and current position, then aborts execution.
    /// </summary>
    procedure ReportSyntaxError(const Msg: string);

    /// <summary>
    /// Checks if the remaining text consists only of whitespace or comments.
    /// Returns True if so; otherwise False.
    /// </summary>
    function IsUnread: Boolean;

    /// <summary>
    /// Skips over any unread text (whitespace/comments) and returns it.
    /// </summary>
    function SkipUnread: string;

    /// <summary>
    /// Checks if the next sequence of characters forms a valid identifier.
    /// An identifier must start with a letter and may continue with letters or digits.
    /// </summary>
    function IsId: Boolean;

    /// <summary>
    /// If the next sequence is a valid identifier, skips it and returns the identifier.
    /// Otherwise, reports a syntax error.
    /// </summary>
    function SkipId: string;

    /// <summary>
    /// Checks if the next sequence of characters forms a valid integer.
    /// Integers may have an optional sign ('-' or '+') followed by one or more digits.
    /// </summary>
    function IsInt: Boolean;

    /// <summary>
    /// If the next sequence is a valid integer, skips it and returns its integer value.
    /// Otherwise, reports a syntax error.
    /// </summary>
    function SkipInt: Integer;

    /// <summary>
    /// Checks if the next sequence of characters forms a valid number.
    /// This includes numbers with optional signs, decimal points, and exponents.
    /// </summary>
    function IsNumber: Boolean;

    /// <summary>
    /// If the next sequence is a valid number, skips it and returns the number as a string.
    /// Otherwise, reports a syntax error.
    /// </summary>
    function SkipNumber: Double;

    function IsStr: Boolean;
    function SkipStrQuot: string;
    function SkipStrValues: string;

    function IsSep(sep: string): Boolean;
    function SkipSep(sep: string): string;

    function IsKey(Key: string): Boolean;
    function SkipKey(Key: string): string;

    function IsNext(Any: string): Boolean;
    function Skip(Any: string): string;
    function WhichIs(L: TStrList): Integer;
    function InList(L: TStrList): Boolean;
    function SkipSXY: string;
    function SkipSPNV: string;

    function SkipDepth: Integer;

     function SkipExpVal: Double;



    private type
  TSemanticAction = (
    saId, saNum, saStr,
    saAdd, saSub, saMul, saDiv,
    saOr, saAnd,
    saLess, saEqual, saGreat,
    saLessEq, saNotEq, saGreatEq,
    saNeg, saNot , saCopy , saThen , saElse,saTarget, saLabel , saDoWhile,saEndWhile ,saToFor , saDoFor , saEndFor
  );

  private
    SS: TStackRec<string>;
    Codes: TCodeList;
    TempNo: Integer;

    function NewTemp: string;
    procedure DoAction(Act: TSemanticAction; TokenVal: string = '');
  public
    procedure SkipExp;
    function SkipCodes: TCodeList;

    procedure SkipStatement;
procedure SkipAssign;
procedure SkipIf;
procedure SkipFor;
procedure SkipWhile;

  end;


implementation

{ TSyntaxLine }


procedure TSyntaxLine.SkipWhile;
begin
  SkipKey('while');
  DoAction(saLabel);
  SkipExp;
  SkipKey('do');
  DoAction(saDoWhile);
  SkipStatement;
  DoAction(saEndWhile);
end;


procedure TSyntaxLine.SkipFor;
begin
  SkipKey('for');
  DoAction(saId, SkipId);
  SkipSep(':=');
  SkipExp;
  SkipKey('to');
  DoAction(saToFor);
  SkipExp;
  SkipSep('do');
  DoAction(saDoFor);
  SkipStatement;
  DoAction(saEndFor);
end;


procedure TSyntaxLine.SkipStatement;
begin
  case WhichIs(['$if', '$while', '$for', '#id']) of
    0: SkipIf;
    1: SkipWhile;
    2: SkipFor;
    3: SkipAssign;
  else
    ReportSyntaxError('Statement expected: if , while, for, id');
  end;
end;



 procedure TSyntaxLine.SkipAssign;
begin
  DoAction(saId, SkipId);         // شناسه چپ را به عنوان یک id ذخیره می‌کنیم
  SkipSep(':=');                  // بررسی و عبور از :=
  SkipExp;                        // تحلیل سمت راست انتساب (یک عبارت کامل)
  DoAction(saCopy, ':=');         // تولید دستور معنایی برای انتساب
end;



function TSyntaxLine.NewTemp: string;
begin
  Inc(TempNo);
  Result := 't' + IntToStr(TempNo);
end;

 procedure TSyntaxLine.DoAction(Act: TSemanticAction; TokenVal: string);
var
  L, R, Temp: string;
  P1, P2 , L1 :Integer;
begin
  case Act of
    saId, saNum, saStr:
      SS.Push(TokenVal);

    saAdd..saGreatEq:
      begin
        R := SS.Pop;
        L := SS.Pop;
        Temp := NewTemp;
        Codes.Add(TokenVal, L, R, Temp);
        SS.Push(Temp);
      end;

    saNeg, saNot:
      begin
        Temp := NewTemp;
        Codes.Add(TokenVal, SS.Pop, '', Temp);
        SS.Push(Temp);
      end;
        saCopy:
      begin
        R := SS.Pop;
        L := SS.Pop;
        Codes.Add(':=', R, '', L);
      end;

    saThen:
      begin
        P1 := Codes.Add('jf', SS.Pop, '', '');  // jump if false
        SS.Push(P1.ToString);                  // ذخیره موقعیت پرش در پشته
      end;

    saTarget:
      begin

        Codes[SS.Pop.ToInteger].Target := Length(Codes).ToString;  // تنظیم مقصد پرش به کد فعلی
      end;

    saElse:
      begin
        P1 := SS.Pop.ToInteger;
        P2 := Codes.Add('j', '', '', '');
        SS.Push(P2.ToString);                         // پرش از بخش true به بعد از else
        Codes[P1].Target := Length(Codes).ToString;
      end;

     saLabel:
  SS.Push(Length(Codes).ToString);

saDoWhile:
begin
  P1 := Codes.Add('JF', SS.Pop, '', '');
  SS.Push(P1.ToString);
end;

saEndWhile:
begin
  P1 := SS.Pop.ToInteger;
  L1 := SS.Pop.ToInteger;
  Codes.Add('J', '', '', L1.ToString);
  Codes[P1].Target := Length(Codes).ToString;
end;

saToFor:
begin
  R := SS.Pop;
  L := SS.Peek;
  Codes.Add(':=', R, '', L);
end;

saDoFor:
begin
  R := SS.Pop;
  L := SS.Peek;
  Temp := NewTemp;
  L1 := Codes.Add('<=', L, R, Temp);
  P1 := Codes.Add('JF', Temp, '', '');
  SS.Push(L1.ToString);
  SS.Push(P1.ToString);
end;

saEndFor:
begin
  P1 := SS.Pop.ToInteger;
  L1 := SS.Pop.ToInteger;
  R := SS.Pop;
  Codes.Add('Inc', R, '', '');
  Codes.Add('J', '', '', L1.ToString);
  Codes[P1].Target := Length(Codes).ToString;
end;


  end;
end;


   procedure TSyntaxLine.SkipExp;

procedure SkipC; forward;
procedure SkipC1; forward;
procedure SkipA; forward;
procedure SkipA1; forward;
procedure SkipM; forward;
procedure SkipM1; forward;
procedure SkipP; forward;


     procedure SkipA1;
begin
  case WhichIs(['+', '-', 'or']) of
    0:
      begin
        SkipSep('+');
        SkipM;
        DoAction(saAdd, '+');
        SkipA1;
      end;
    1:
      begin
        SkipSep('-');
        SkipM;
        DoAction(saSub, '-');
        SkipA1;
      end;
    2:
      begin
        SkipKey('or');
        SkipM;
        DoAction(saOr, 'or');
        SkipA1;
      end;
  else
    ; { null }
  end;
end;


procedure SkipM1;
begin
  case WhichIs(['*', '/', 'and']) of
    0:
      begin
        SkipSep('*');
        SkipP;
        DoAction(saMul, '*');
        SkipM1;
      end;
    1:
      begin
        SkipSep('/');
        SkipP;
        DoAction(saDiv, '/');
        SkipM1;
      end;
    2:
      begin
        SkipKey('and');
        SkipP;
        DoAction(saAnd, 'and');
        SkipM1;
      end;
  else
    ; { null }
  end;
end;


   procedure SkipC;
begin
  SkipA;
  SkipC1;
end;

   procedure SkipA;
begin
  SkipM;
  SkipA1;
end;

   procedure SkipM;
begin
  SkipP;
  SkipM1;
end;

procedure SkipP;
begin
  case WhichIs(['-', 'not', '(', '#id', '#num', '#str']) of
    0: begin
         SkipSep('-');
         SkipP;
         DoAction(saNeg, 'neg');
       end;
    1: begin
         SkipKey('not');
         SkipP;
         DoAction(saNot, 'not');
       end;
    2: begin
         SkipSep('(');
         SkipC;
         SkipSep(')');
       end;
    3:
       DoAction(saId, SkipId);
    4:
       DoAction(saNum, SkipNumber.ToString);
    5:
       DoAction(saStr, SkipStrQuot);
  else
    ReportSyntaxError('"-", not, (, id, num, str expected"');
  end;
end;


  procedure SkipC1;
begin
  case WhichIs(['<=', '<>', '>=', '<', '=', '>']) of
    0:
      begin
        SkipSep('<=');  // مقایسه کمتر مساوی
        SkipA;
        DoAction(saLessEq, '<=');
      end;
    1:
      begin
        SkipSep('<>');
        SkipA;
        DoAction(saNotEq, '<>');
      end;
    2:
      begin
        SkipSep('>=');
        SkipA;
        DoAction(saGreatEq, '>=');
      end;
    3:
      begin
        SkipSep('<');
        SkipA;
        DoAction(saLess, '<');
      end;
    4:
      begin
        SkipSep('=');
        SkipA;
        DoAction(saEqual, '=');
      end;
    5:
      begin
        SkipSep('>');
        SkipA;
        DoAction(saGreat, '>');
      end;
  else
    ; // null – در صورتی که هیچ‌کدام از این مقایسه‌ها نباشد
  end;
end;



begin;
SkipC;
 end;

function TSyntaxLine.SkipSPNV: string;
procedure SkipS; forward;
procedure SkipP; forward;
procedure SkipN; forward;
procedure SkipV; forward;
  procedure SkipS;
  begin
    case WhichIs(['d', 'e', 'b', 'c']) of
      0, 1:
        begin
          SkipP;
          Result := Result + Skip('a');
          SkipN;
        end;
      2:
        begin
          SkipV;
          SkipP;
        end;
      3:
        Result := Result + Skip('c');
    else
      ReportSyntaxError('d, e, b, c Expected');
    end;
  end;
  procedure SkipP;
  begin
    case WhichIs(['d', 'e']) of
      0:
        begin
          Result := Result + Skip('d');
          SkipN;
          SkipP;
        end;
      1:
        Result := Result + Skip('e');
    else
      ReportSyntaxError('d, e Expected');
    end;
  end;
  procedure SkipN;
  begin
    case WhichIs(['b', 'd', 'e', END_OF_FILE_CHAR]) of
      0:
        begin
          SkipV;
          Result := Result + Skip('a');
        end;
      1 .. 3:
        begin
          { null };
        end;
    else
      ReportSyntaxError('b, d, e, Eof Expected');
    end;
  end;
  procedure SkipV;
  begin
    Result := Result + Skip('b');
  end;

begin
  Result := '';
  SkipS;
end;

function TSyntaxLine.SkipSXY: string;
procedure SkipS; forward;
procedure SkipX; forward;
procedure SkipY; forward;
  procedure SkipS;
  begin
    SkipX;
    Result := Result + Skip('d');
    SkipY;
  end;

  procedure SkipX;
  begin
    if IsNext('a') then
    begin
      Result := Result + Skip('a');
      SkipX;
    end
    else
    begin
      { null };
    end;
  end;

  procedure SkipY;
  begin
    if IsNext('b') then
    begin
      Result := Result + Skip('b');
      SkipY;
      SkipS;
    end
    else
    begin
      { null };
    end;
  end;

begin
  Result := '';
  SkipS;
end;

function TSyntaxLine.InList(L: TStrList): Boolean;
begin
  Result := WhichIs(L) <> -1;
end;

function TSyntaxLine.WhichIs(L: TStrList): Integer;
var
  i: Integer;
begin
  SkipUnread;

  Result := -1;
  for i := 0 to High(L) do
    if IsNext(L[i]) then
      Exit(i);
end;

function TSyntaxLine.IsNext(Any: string): Boolean;
var
  T: string;
begin
  SkipUnread;

  T := Any.ToUpper;
  if T = '#ID' then
    Result := IsId
  else if T = '#INT' then
    Result := IsInt
  else if T = '#NUM' then
    Result := IsNumber
  else if T = '#STR' then
    Result := IsStr
  else if (Any.Length >= 2) and (Any[1] = '$') then
    Result := IsKey(Copy(Any, 2))
  else
    Result := IsSep(Any);
end;

function TSyntaxLine.Skip(Any: string): string;
var
  T: string;
begin
  T := Any.ToUpper;
  if T = '#ID' then
    Result := SkipId
  else if T = '#INT' then
    Result := SkipInt.ToString
  else if T = '#NUM' then
    Result := SkipNumber.ToString
  else if T = '#STRQUOT' then
    Result := SkipStrQuot
  else if T = '#STRVAL' then
    Result := SkipStrValues
  else if (Any.Length >= 2) and (Any[1] = '$') then
    Result := SkipKey(Copy(Any, 2))
  else
    Result := SkipSep(Any);
end;



function TSyntaxLine.SkipCodes: TCodeList;
begin
  Codes := nil;
  TempNo := 0;
  //SkipExp;
  SkipStatement();
  Result := Codes;
end;

procedure TSyntaxLine.SkipIf;

  procedure SkipIf1;
  begin
    if IsKey('else') then
    begin
      SkipKey('else');
      DoAction(saElse);
      SkipStatement;
      DoAction(saTarget);
    end
    else  {null}
      DoAction(saTarget);  // در صورت نبودن else، یک نقطه پرش (target) هم‌چنان ثبت می‌شود
  end;

begin
  SkipKey('if');
  SkipExp;
  SkipKey('then');
  DoAction(saThen);         // ثبت نقطه پرش مشروط
  SkipStatement;
  SkipIf1;
end;


function TSyntaxLine.SkipDepth: Integer;
procedure SkipS; forward;
procedure SkipL; forward;
procedure SkipL1; forward;

type
  TSemanticStack = TStackRec<Integer>;
  TSemanticAction = (saZero, saInc, saMax);

var
  SS: TSemanticStack;

procedure DoAction(Act: TSemanticAction);
begin
  case Act of
    saZero:
      SS.Push(0);                         // یک ۰ به پشته اضافه می‌شود
    saInc:
      SS.Push(SS.Pop + 1);                // مقدار بالای پشته +1 شده و دوباره پوش می‌شود
    saMax:
      SS.Push(Max(SS.Pop, SS.Pop));       // دو مقدار بالای پشته برداشته شده و بیشینه آن‌ها پوش می‌شود
  end;
end;

procedure SkipS;
begin
  case WhichIs(['(', 'a']) of
    0: begin
         Skip('(');
         SkipL;
         Skip(')');
         DoAction(saInc) ;
       end;
    1:begin
    Skip('a');
      DoAction(saZero) ;
    end

  else
    ReportSyntaxError('"(", "a" expected');
  end;
end;

procedure SkipL;
begin
  SkipS;
  SkipL1;
end;

procedure SkipL1;
begin
  if IsNext(',') then
  begin
    Skip(',');
    SkipS;
      DoAction(saMax) ;
    SkipL1;
  end
  else
    ; // null
end;

// بلاک اصلی که به عنوان entry point برای پارس است:
begin
SkipS;
  Result := ss.Pop;
end;


function TSyntaxLine.SkipExpVal: Double;
procedure SkipA; forward;
procedure SkipA1; forward;
procedure SkipM; forward;
procedure SkipM1; forward;
procedure SkipP; forward;

type
  TSemanticStack = TStackRec<Double>;
  TSemanticAction = (saAdd, saSub, saMul, saDiv, saNeg, saNum);

var
  SS: TSemanticStack;

procedure DoAction(Act: TSemanticAction; TokenVal: Double = 0);
var
  L, R: Double;
begin
  case Act of
    saAdd:
      SS.Push(SS.Pop + SS.Pop);

    saSub:
      begin
        R := SS.Pop;
        L := SS.Pop;
        SS.Push(L - R);
      end;

    saMul:
      SS.Push(SS.Pop * SS.Pop);

    saDiv:
      begin
        R := SS.Pop;
        L := SS.Pop;
        SS.Push(L / R);
      end;

    saNeg:
      SS.Push(-SS.Pop);

    saNum:
      SS.Push(TokenVal);
  end;
end;

procedure SkipA;
begin
  SkipM;
  SkipA1;
end;

procedure SkipA1;
begin
  if IsSep('+') then
  begin
    Skip('+');
    SkipM;
    DoAction(saAdd);
    SkipA1;
  end
  else if IsSep('-') then
  begin
    Skip('-');
    SkipM;
    DoAction(saSub);
    SkipA1;
  end
  else
    ; { null }
end;

  procedure SkipM;
begin
  SkipP;
  SkipM1;
end;

procedure SkipM1;
begin
  if IsSep('*') then
  begin
    Skip('*');
    SkipP;
    DoAction(saMul);
    SkipM1;
  end
  else if IsSep('/') then
  begin
    Skip('/');
    SkipP;
    DoAction(saDiv);
    SkipM1;
  end
  else
    ; { null }
end;
     procedure SkipP;
begin
  case WhichIs(['-', '(', '#num']) of
    0:
      begin
        Skip('-');
        SkipP;
        DoAction(saNeg);
      end;
    1:
      begin
        Skip('(');
        SkipA;
        Skip(')');
      end;
    2:
     DoAction(saNum , SkipNumber);
  else
    ReportSyntaxError('"-", "(", num expected');
  end;
end;

begin
  SkipA;
  Result := ss.Pop;
end;


function TSyntaxLine.IsKey(Key: string): Boolean;
begin
  Result := IsId and (Copy(FSourceText, FCurrentPos, FNewPosition - FCurrentPos)
    .ToUpper = Key.ToUpper);
end;

function TSyntaxLine.IsSep(sep: string): Boolean;
begin
  SkipUnread;
  Result := Copy(FSourceText, FCurrentPos, sep.Length).ToUpper = sep.ToUpper;

  if Result then
    FNewPosition := FCurrentPos + sep.Length;
end;

function TSyntaxLine.SkipKey(Key: string): string;
begin
  if IsKey(Key) then
    Result := MoveToPosition(FNewPosition)
  else
    ReportSyntaxError('"' + Key + '" Expected');
end;

function TSyntaxLine.SkipId: string;
begin
  // Skip an identifier token if valid; otherwise, report error.
  if IsId then
    Result := MoveToPosition(FNewPosition)
  else
    ReportSyntaxError('Invalid identifier.');
end;

function TSyntaxLine.SkipInt: Integer;
begin
  // Skip an integer token if valid; otherwise, report error.
  if IsInt then
    Result := MoveToPosition(FNewPosition).ToInteger
  else
    ReportSyntaxError('Invalid integer.');
end;

function TSyntaxLine.SkipNumber: Double;
begin
  // Skip a number token if valid; otherwise, report error.
  if IsNumber then
    Result := MoveToPosition(FNewPosition).ToDouble
  else
    ReportSyntaxError('Invalid number.');
end;

function TSyntaxLine.SkipStrValues: string;
begin
  SkipUnread;
  Result := '';
  while IsStr do
    Result := Result + MoveToPosition(FNewPosition);
end;

function TSyntaxLine.SkipSep(sep: string): string;
begin
  if IsSep(sep) then
    Result := MoveToPosition(FNewPosition)
  else
    ReportSyntaxError('"' + sep + '" Expected');
end;

function TSyntaxLine.SkipStrQuot: string;
begin
  if IsStr then
    Result := MoveToPosition(FNewPosition)
  else
    ReportSyntaxError('Invalid string');
end;

function TSyntaxLine.IsId: Boolean;
var
  p, state: Integer;
  text: Char;
begin
  // First, skip any unread parts (whitespace/comments)
  SkipUnread;
  state := 0; // Initial state
  // Loop through characters starting at FCurrentPos
  for p := FCurrentPos to High(FSourceText) do
  begin
    text := FSourceText[p];
    case state of
      0:
        // The first character must be a letter
        if text.IsLetter then
          state := 1
        else
          Break;
      1:
        // Subsequent characters can be letters or digits
        if text.IsLetterOrDigit then
          state := 1
        else
          Break;
    end;
  end;
  // Valid identifier if we ended in state 1
  Result := state in [1];
  if Result then
    FNewPosition := p;
end;

function TSyntaxLine.IsInt: Boolean;
var
  p, state: Integer;
  text: Char;
begin
  // Skip any unread parts first
  SkipUnread;
  state := 0; // Initial state
  // Loop through the characters to match an integer pattern
  for p := FCurrentPos to High(FSourceText) do
  begin
    text := FSourceText[p];
    case state of
      0:
        // A number may start with a digit or a sign
        if text.IsDigit then
          state := 2
        else if text in ['-', '+'] then
          state := 1
        else
          Break;
      1:
        // After a sign, digits are required
        if text.IsDigit then
          state := 2
        else
          Break;
      2:
        // Continue reading digits
        if text.IsDigit then
          state := 2
        else
          Break;
    end;
  end;
  // Valid integer if state ended in 2
  Result := state in [2];
  if Result then
    FNewPosition := p;
end;

function TSyntaxLine.IsNumber: Boolean;
var
  p, state: Integer;
  text: Char;
begin
  // Skip any unread parts first
  SkipUnread;
  state := 0; // Initial state
  // Loop through characters to match number patterns (supports decimal and exponent parts)
  for p := FCurrentPos to High(FSourceText) do
  begin
    text := FSourceText[p];
    case state of
      0:
        // Start with an optional sign or digit
        if text in ['+', '-'] then
          state := 1
        else if text.IsDigit then
          state := 2
        else
          Break;
      1:
        // After a sign, a digit must follow
        if text.IsDigit then
          state := 2
        else
          Break;
      2:
        // Read digits; if a dot or slash (for decimals) or 'E' for exponent is encountered, move to next state
        if text.IsDigit then
          state := 2
        else if text in ['.', '/'] then
          state := 3
        else if text = 'E' then
          state := 5
        else
          Break;
      3:
        // After a decimal point, expect digits
        if text.IsDigit then
          state := 4
        else
          Break;
      4:
        // Continue reading digits after the decimal point; exponent can follow
        if text.IsDigit then
          state := 4
        else if text.ToUpper = 'E' then
          state := 5
        else
          Break;
      5:
        // After 'E', allow an optional sign for the exponent
        if text in ['+', '-'] then
          state := 6
        else if text.IsDigit then
          state := 7
        else
          Break;
      6:
        // After the optional exponent sign, expect digits
        if text.IsDigit then
          state := 7
        else
          Break;
      7:
        // Read the exponent digits
        if text.IsDigit then
          state := 7
        else
          Break;
    end;
  end;
  // The number is valid if we finish in one of these states
  Result := state in [7, 4, 2];
  if Result then
    FNewPosition := p;
end;

function TSyntaxLine.IsStr: Boolean;
var
  p, state: Integer;
  text: Char;
begin
  // Skip any unread parts first
  SkipUnread;
  state := 0; // Initial state
  // Loop through characters to match number patterns (supports decimal and exponent parts)
  for p := FCurrentPos to High(FSourceText) do
  begin
    text := FSourceText[p];
    case state of
      0:
        if text = '''' then
          state := 1
        else if text = '#' then
          state := 3
        else
          Break;

      1:
        if text = '''' then
          state := 2
        else if text in [#10, #13] then
          Break
        else
          state := 1;
      2:
        if text = '''' then
          state := 1
        else if text = '#' then
          state := 3
        else
          Break;

      3:
        if text.IsDigit then
          state := 4
        else
          Break;

      4:
        if text = '''' then
          state := 1
        else if text = '#' then
          state := 3
        else if text.IsDigit then
          state := 4
        else
          Break;
    end;
  end;

  Result := state in [4, 2];
  if Result then
    FNewPosition := p;
end;

function TSyntaxLine.SkipUnread: string;
begin
  // Continuously skip over unread text (whitespace/comments)
  Result := '';
  while IsUnread do
    Result := Result + MoveToPosition(FNewPosition);
end;

{
  IsUnread checks whether the remaining text in FSourceText
  consists only of whitespace or comments.

  Comments can be of two forms:
  1. Single-line comment: starts with "//" and continues until a newline.
  2. Multi-line comment: starts with "/*" and ends with "*/".

  If any non-comment and non-whitespace character is encountered,
  the function stops and returns False.

  Output:
  - Boolean: True if the unread portion is solely whitespace/comments; otherwise, False.
}
function TSyntaxLine.IsUnread: Boolean;
var
  p, state: Integer;
  text: Char;
begin
  state := 0; // Initial state
  // Process characters starting at the current position
  for p := FCurrentPos to High(FSourceText) do
  begin
    text := FSourceText[p];
    case state of
      // State 0: Look at the first character
      0:
        if text = '/' then
          state := 1 // Potential start of a comment
        else if text.IsWhiteSpace then
          state := 5 // Whitespace detected
        else
          Break; // Found a non-whitespace, non-comment character
      // State 1: After seeing '/', decide if it is a single-line or multi-line comment
      1:
        if text = '/' then
          state := 6 // Single-line comment confirmed
        else if text = '*' then
          state := 2 // Multi-line comment confirmed
        else
          Break; // Not a valid comment start
      // State 2: Inside a multi-line comment
      2:
        if text = '*' then
          state := 3; // Possible end of multi-line comment
      // Otherwise, remain in multi-line comment state
      // State 3: Check if the multi-line comment is ending
      3:
        if text = '*' then
          state := 3 // Still possible end-of-comment sequence
        else if text = '/' then
          state := 4 // End of multi-line comment found
        else
          state := 2; // Return to inside multi-line comment state
      // State 5: In whitespace; continue until a non-whitespace is found
      5:
        if text.IsWhiteSpace then
          state := 5 // Continue in whitespace
        else
          Break; // Non-whitespace encountered
      // State 6: Inside a single-line comment
      6:
        if text in [#10, #13] then
          state := 7 // End of single-line comment
        else
          state := 6; // Continue reading the single-line comment
      // States 4 and 7 indicate that a comment has ended
      4, 7:
        Break;
    end;
  end;
  // If we ended in state 4 (multi-line comment closed), 5 (whitespace), or 7 (single-line comment ended),
  // then the unread part consists only of comments/whitespace.
  Result := state in [4, 5, 7];
  // Update the new position marker if the result is True
  if Result then
    FNewPosition := p;
end;

procedure TSyntaxLine.Reset;
begin
  // Reset all internal fields to their initial values.
  FSourceText := '';
  FCurrentPos := 0;
  FNewPosition := 0;
  FLineColumn := Point(0, 0);
end;

procedure TSyntaxLine.SetSourceText(const AText: string);
begin
  // Reset the state and set the source text with the end-of-file marker appended.
  Reset;
  FSourceText := AText + END_OF_FILE_CHAR;
  FCurrentPos := 1;
  FNewPosition := 1;
end;

procedure TSyntaxLine.LoadFromFile(const AFileName: string);
var
  Directory, FileToSearch, FileFound: string;
  Files: TStringDynArray;
  i: Integer;
begin
  // Reset any internal state
  Reset;

  // Determine the directory and file name from the given path
  Directory := ExtractFilePath(AFileName);
  FileToSearch := ExtractFileName(AFileName);
  if Directory = '' then
    Directory := GetCurrentDir;

  // Retrieve the list of files in the directory
  Files := TDirectory.GetFiles(Directory);
  FileFound := '';
  // Loop through the files to find a matching file name (case-insensitive)
  for i := 0 to High(Files) do
  begin
    if SameText(ExtractFileName(Files[i]), FileToSearch) then
    begin
      FileFound := Files[i];
      Break;
    end;
  end;

  // If a matching file was found, read its contents and append the end-of-file marker;
  // otherwise, raise an exception.
  if FileFound <> '' then
    FSourceText := TFile.ReadAllText(FileFound) + END_OF_FILE_CHAR
  else
    raise Exception.Create('File not found: ' + AFileName);

  FCurrentPos := 1;
  FNewPosition := 1;
end;

function TSyntaxLine.MoveToPosition(APos: Integer): string;
var
  TextBuilder: TStringBuilder;
begin
  // Collect characters from the current position up to APos,
  // updating line and column information along the way.
  TextBuilder := TStringBuilder.Create;
  try
    while FCurrentPos < APos do
    begin
      // Append the current character to the result
      TextBuilder.Append(FSourceText[FCurrentPos]);
      // If a newline is encountered, update the line and reset the column
      if FSourceText[FCurrentPos] = #10 then
      begin
        Inc(FLineColumn.X); // Increase the line count
        FLineColumn.Y := 1; // Reset the column count to 1
      end
      else
        Inc(FLineColumn.Y); // Otherwise, increment the column count

      Inc(FCurrentPos); // Move to the next character
    end;
    // Return the collected substring
    Result := TextBuilder.ToString;
  finally
    TextBuilder.Free;
  end;
end;


function TSyntaxLine.IsEndOfFile: Boolean;
begin
  // Check if the current position exceeds the text length or if the next character is the EOF marker.
  Result := (FCurrentPos > Length(FSourceText)) or
    (FSourceText[FCurrentPos] = END_OF_FILE_CHAR);
end;


function TSyntaxLine.GetCurrentLine: string;
var
  StartIndex, EndIndex: Integer;
begin
  // Determine the start of the current line by scanning backward until a newline is found.
  StartIndex := FCurrentPos;
  while (StartIndex > 1) and not(FSourceText[StartIndex - 1] in [#10, #12]) do
    Dec(StartIndex);

  // Determine the end of the current line by scanning forward until a newline is found.
  EndIndex := FCurrentPos;
  while (EndIndex <= Length(FSourceText)) and
    not(FSourceText[EndIndex] in [#10, #12]) do
    Inc(EndIndex);

  // Return the substring that represents the current line.
  Result := Copy(FSourceText, StartIndex, EndIndex - StartIndex);
end;

procedure TSyntaxLine.ReportSyntaxError(const Msg: string);
var
  LineInfo, CharInfo, LocInfo: string;
begin
  // Build detailed error information using the current line, character, and position.
  LineInfo := 'Line: ' + GetCurrentLine;
  CharInfo := 'Character: ' + FSourceText[FCurrentPos];
  LocInfo := 'Position: (' + FLineColumn.X.ToString + ', ' +
    FLineColumn.Y.ToString + ')';

  // Display the error message along with the error details.
  MessageDlg(Msg + sLineBreak + sLineBreak + LineInfo + sLineBreak + CharInfo +
    sLineBreak + LocInfo, mtError, [mbOK], 0);
  // Abort the program execution after reporting the error.
  Abort;
end;

{ TStackRec<T> }

class operator TStackRec<T>.Initialize(out Dest: TStackRec<T>);
begin
  Dest.Stk := TStack<T>.Create;
end;

class operator TStackRec<T>.Finalize(var Dest: TStackRec<T>);
begin
  Dest.Stk.Free;
end;

procedure TStackRec<T>.Push(const Value: T);
begin
  Stk.Push(Value);
end;

function TStackRec<T>.Pop: T;
begin
  Result := Stk.Pop;
end;

function TStackRec<T>.Peek: T;
begin
  Result := Stk.Peek;
end;

function HCodeList.Add(Op, Addr1, Addr2, Target: string): Integer;
var
  ACode: TCode;
begin
  ACode.Op := Op;
  ACode.Addr1 := Addr1;
  ACode.Addr2 := Addr2;
  ACode.Target := Target;
  Self := Self + [ACode]; // اضافه‌کردن رکورد به لیست
  Result := High(Self);   // اندیس آخرین عنصر جدید
end;

function HCodeList.ToLines: TStrList;
var
  i: Integer;
  S: string;
begin

  for i := 0 to High(Self) do
  begin
    S := string.Join(', ', [Self[i].Op, Self[i].Addr1, Self[i].Addr2, Self[i].Target]);
    Result := Result + [' ['+FormatFloat('000' , i ) + '] '+ '(' + s + ')'];
  end;
end;







end.
