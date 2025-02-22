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
  Dialogs, SysUtils, IOUtils, Character, Types, Generics.Collections;

type
  /// <summary>
  /// TSyntaxLine manages a source text for syntax analysis. It supports methods for loading,
  /// scanning, error reporting, and skipping various tokens such as identifiers, integers, and numbers.
  /// </summary>
  TSyntaxLine = record
  private const
    END_OF_FILE_CHAR = #1; // Marker indicating the end of the file
  private
    FSourceText: string;  // The main source text to be processed
    FCurrentPos: Integer; // The current position in the source text
    FNewPosition: Integer; // A secondary position used to mark the end of recognized tokens
    FLineColumn: TPoint;  // Represents the current line (X) and column (Y)
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
    function SkipNumber: string;



    function IsStr: Boolean;
    function SkipStrQuot: string;
    function SkipStr: string;
  end;

implementation

{ TSyntaxLine }

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

function TSyntaxLine.SkipNumber: string;
begin
  // Skip a number token if valid; otherwise, report error.
  if IsNumber then
    Result := MoveToPosition(FNewPosition)
  else
    ReportSyntaxError('Invalid number.');
end;

function TSyntaxLine.SkipStr: string;
begin

end;

function TSyntaxLine.SkipStrQuot: string;
begin

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
        else if text = 'E' then
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
begin

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
          state := 1  // Potential start of a comment
        else if text.IsWhiteSpace then
          state := 5  // Whitespace detected
        else
          Break;     // Found a non-whitespace, non-comment character
      // State 1: After seeing '/', decide if it is a single-line or multi-line comment
      1:
        if text = '/' then
          state := 6  // Single-line comment confirmed
        else if text = '*' then
          state := 2  // Multi-line comment confirmed
        else
          Break;     // Not a valid comment start
      // State 2: Inside a multi-line comment
      2:
        if text = '*' then
          state := 3; // Possible end of multi-line comment
        // Otherwise, remain in multi-line comment state
      // State 3: Check if the multi-line comment is ending
      3:
        if text = '*' then
          state := 3  // Still possible end-of-comment sequence
        else if text = '/' then
          state := 4  // End of multi-line comment found
        else
          state := 2; // Return to inside multi-line comment state
      // State 5: In whitespace; continue until a non-whitespace is found
      5:
        if text.IsWhiteSpace then
          state := 5  // Continue in whitespace
        else
          Break;     // Non-whitespace encountered
      // State 6: Inside a single-line comment
      6:
        if text in [#10, #13] then
          state := 7  // End of single-line comment
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
  I: Integer;
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
  for I := 0 to High(Files) do
  begin
    if SameText(ExtractFileName(Files[I]), FileToSearch) then
    begin
      FileFound := Files[I];
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
        FLineColumn.Y := 1;  // Reset the column count to 1
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
  Result := (FCurrentPos > Length(FSourceText))
    or (FSourceText[FCurrentPos] = END_OF_FILE_CHAR);
end;

function TSyntaxLine.GetCurrentLine: string;
var
  StartIndex, EndIndex: Integer;
begin
  // Determine the start of the current line by scanning backward until a newline is found.
  StartIndex := FCurrentPos;
  while (StartIndex > 1) and not (FSourceText[StartIndex - 1] in [#10, #12]) do
    Dec(StartIndex);

  // Determine the end of the current line by scanning forward until a newline is found.
  EndIndex := FCurrentPos;
  while (EndIndex <= Length(FSourceText)) and not (FSourceText[EndIndex] in [#10, #12]) do
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
  LocInfo := 'Position: (' + FLineColumn.X.ToString + ', ' + FLineColumn.Y.ToString + ')';

  // Display the error message along with the error details.
  MessageDlg(
    Msg + sLineBreak + sLineBreak +
    LineInfo + sLineBreak +
    CharInfo + sLineBreak +
    LocInfo,
    mtError, [mbOK], 0
  );
  // Abort the program execution after reporting the error.
  Abort;
end;

end.

