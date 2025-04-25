unit Neslib.SysUtils;
{< Sytem utilities }

{$INCLUDE 'Neslib.inc'}

interface

uses
  System.SysUtils;

{ Checks two string references for equality.

  Parameters:
    AString1: first string
    AString2: second string

  Returns:
    True if AString1 and AString2 are references to the same string.

  This function is useful with string interning to quickly check two interned
  strings for equality. Instead of comparing the contents of the two strings,
  it just checks their references, which is just a single pointer comparison.

  See Neslib.Collections.TStringInternPool for a class you can use for string
  interning. }
function SameStringRef(const AString1, AString2: String): Boolean; overload; inline;
function SameStringRef(const AString1, AString2: UTF8String): Boolean; overload; inline;

{ Tries to parse a string and extract the fields given in the AFormat parameter.
  It is sort of the inverse of Delphi's Format routine. If is also similar to
  the scanf function in C/C++.

  Parameters
  ----------
    AInput: the string you want to parse.
    AFormat: the format string. The syntax of this string is roughly similar to
      the one used in Delphi's Format function. But there are exceptions, which
      are noted below.
    AOutput: array of pointers that point to the variables that need to be
      extracted. Unfortunately, we cannot use an "array of const" parameter
      here, because these can only be used for input parameters. This means
      that you must be careful to make sure that each pointer points to a
      variable of the correct type as specified in the format string. Thus,
      if the format string contains a "%d" specifier, then the respective
      parameter MUST point to an integer variable. Otherwise, strange results
      or access violations can occur because we have no way of checking what
      each pointer points to.
      NOTE: you may specify a "nil" value in the array. This will ignore that
      specific field.
    AFormatSettings (optional): specifies the characters used for decimal and
      thousand separators. If not specified, the locale defaults will be used.
    AOptions (optional): currently only one optional option is supported:
      TUnformatOption.CaseSensitive: whether literal characters in the format
      string must be matched case sensitively or not (default not case
      sensitive).

  The function returns True if *all* fields in the format string are extracted.

  There is also an overloaded version that returns the number of extracted
  fields in an out parameter. That version also only returns True if *all*
  fields are extracted. Otherwise, you can use the returned count to check only
  the extracted fields.

  NOTE: For performance reasons the function does not do extensive error
  checking and will not raise exceptions on errors in the format string. It will
  just return False in those cases.

  Example
  -------
  var
    I: Integer;
    S: String;
  begin
    if Unformat('One 2 Three', 'one %d %s', [@I, @S]) then
    begin
      WriteLn('I = ', I);
      WriteLn('S = ', S);
    end;
  end;

  The example above will output:
    I = 2
    S = Three

  If the function would be called with the TUnformatOption.CaseSensitive option,
  then it would fail and return False because 'one' does not match 'One'.

  Format string specification
  ---------------------------
  Format strings contain three types of objects: plain characters, whitespace
  and format specifiers.

  Plain characters have to be matched verbatim with the input string (case
  sensitively or not, depending on the TUnformatOption.CaseSensitive option).

  Whitespace in the format string can match whitespace in the input string, but
  the input string does not need to have whitespace at that location. Whitespace
  can be of any size, so if the format string contains a single space character,
  this will match any amount or no whitespace in input string. All characters
  #32 and below are considered whitespace.

  Format specifiers fetch pointers from the AOutput array and extract the
  corresponding value from the input string to them.

  Format specifiers have the following form:

    "%" [index ":"] ["-"] [width] ["." prec] ["#" typeinfo] type

  A format specifier begins with a % character. After the % come the
  following, in this order:

  *  an optional argument index specifier, [index ":"]
  *  an optional left-justification indicator, ["-"]. This indicator is ignored,
     but allowed for Delphi's Format string compatibility.
  *  an optional width specifier, [width]. This is the *maximum* width of input
     that will be extracted. This *only* applies to String and Pattern format
     specifiers (see below).
  *  an optional precision specifier, ["." prec]. This specifier is ignored,
     but allowed for Delphi's Format string compatibility.
  *  optional type information, ["#" typeinfo]. This allows for further
     specifying what type of output variable is pointed to (for example, whether
     it is a  8, 16, 32 or 64 bit integer).
  *  the conversion type character: type

  The following conversion characters (with optional type information) are
  supported (all case insensitive):

  d  Decimal. The argument must point to a Int32 value. The optional type
     information may have values '8', '16', '32' or '64' to specify the size
     of the integer argument (defaults to '32'). For example, '%#16d' will
     extract an Int16 value.
     NOTE: the code does NOT check if the value fits the given integer size.
     If it does not fit, the returned value is unreliable.

  u  Unsigned decimal. Similar to 'd', but treated as an unsigned value.

  x  Hexadecimal. Similar to 'd', but the input string is treated as a
     hexadecimal value.

  i  Integer. Similar to 'd', 'u' and 'x'. Tries to automatically match a
     decimal or hexadecimal value. If the input string starts with '$', '0X'
     or '0x', then a hexadecimal value will be extracted. Otherwise a decimal
     value.

  e
  f
  g  Scientific, Fixed or General. These are treated the same in Unformat (the
     will lead to different results in Delphi's Format function).
     A floating-point value in scientific, fixed or general format is
     extracted.
     The argument must point to a Double value. The optional type information
     may have values 's', 'd', or 'e' to specify the type of floating point
     value (Single, Double or Extended). Defaults to 'd'. For example, '%#ef'
     will extract an Extended value.
     NOTE: String values 'NAN' and 'INF' are also recognized (these can be
     produced by Delphi's Format function).

  n  Number. Similar to 'e', 'f' or 'g', but the input string may contain
     thousand separators.

  p  Pointer. The argument must point to a pointer value.

  s  String. The argument must point to a (Unicode) string, unless one of the
     following optional type information values is specified: 'a' for
     AnsiString, 'u' for UnicodeString.
     For example, '%#as' will extract an AnsiString.
     If a Width specifier is present, then only strings up to the specified
     width are extracted.
     The input string will be scanned until a whitespace character is found,
     *or* until the next character in the format string is found. This may sound
     a bit confusing, but makes matching more natural. For example, this allows
     you to extract the Scheme and Domain from a URL like this:
       Unformat('http://www.bilsen.com', '%s://%s', [@Scheme, @Domain]).
     The first string will be matched until whitespace or the ':' character (the
     next character in the format string) is encountered.
     If you need more specific string matching rules, you can use the [] pattern
     specifier, discussed next.

  [] String pattern. Similar to 's', but a specific pattern must be matched
     (like a simplified regular expression). You can specify character ranges
     or negative character ranges:
       [a-fA-F]: will match characters 'a'..f' or 'A'..'F'
       [^0-9]: will match anything except '0'..'9'
       [auz ]: will match 'a', 'u', 'z' or a space
       []]: will match ']'
     The input string will be scanned as long as it matches the pattern.
     NOTE: pattern search is *always* case sensitive, even if the
     case-insensitive version of Unformat is used.
     NOTE: like 's', the scan will also stop when whitespace is found (unless
     the whitespace is included in the pattern of course).
     NOTE: only Ansi Characters in the pattern are supported. (You can still
     specify 'a' or 'u' for the result parameter though).

  NOTE: Unlike Delphi's Format function, indirect index, width and precision
  specifiers (as in "%*.*f") are *not* supported.

  An index specifier sets the current argument list index to the specified
  value. The index of the first argument in the argument list is 0. Using
  index specifiers, it is possible to unformat the same argument multiple
  times. For example "Unformat('1 2 3 4', '%d %d %0:d %d', [@A, @B])" will
  return 3 and 4 in A and B (the first 2 values are overwritten). }

type
  TUnformatOption = (CaseSensitive);
  TUnformatOptions = set of TUnformatOption;

function Unformat(const AInput, AFormat: String;
  const AOutput: array of Pointer;
  const AOptions: TUnformatOptions = []): Boolean; overload;

function Unformat(const AInput, AFormat: String;
  const AOutput: array of Pointer; const AFormatSettings: TFormatSettings;
  const AOptions: TUnformatOptions = []): Boolean; overload;

function Unformat(const AInput, AFormat: String;
  const AOutput: array of Pointer; out AOutputCount: Integer;
  const AOptions: TUnformatOptions = []): Boolean; overload;

function Unformat(const AInput, AFormat: String;
  const AOutput: array of Pointer; out AOutputCount: Integer;
  const AFormatSettings: TFormatSettings;
  const AOptions: TUnformatOptions = []): Boolean; overload;

var
  { A TFormatSettings record configured for US number settings.
    It uses a period (.) as a decimal separator and comma (,) as thousands
    separator.
    Can be used to convert strings to floating-point values in cases where the
    strings are always formatted to use periods as decimal separators
    (regardless of locale). }
  USFormatSettings: TFormatSettings;

implementation

uses
  System.Math,
  System.Character;

function SameStringRef(const AString1, AString2: String): Boolean;
begin
  Result := (Pointer(AString1) = Pointer(AString2));
end;

function SameStringRef(const AString1, AString2: UTF8String): Boolean;
begin
  Result := (Pointer(AString1) = Pointer(AString2));
end;

type
  TCharSet = record
  private const
    RANGE_PER_CLUSTER = 32;
    MINPOS_IN_CLUSTER = 0;
    MAXPOS_IN_CLUSTER = 31;
  private
    FFlagCluster: array[0..7] of Cardinal;
  private
    function PosInCluster(const AVal: SmallInt): Cardinal; inline;
    function ClusterIndexOf(const AVal: Char): Integer; overload; inline;
    function ClusterIndexOf(const AVal: SmallInt): Integer; overload; inline;
    function MaskInCluster(const AVal: Char): Cardinal; overload; inline;
    function MaskInCluster(const AVal: SmallInt): Cardinal; overload; inline;
    procedure FillCluster(const AClusterIdx: Integer); overload; inline;
    procedure FillCluster(const AClusterIdx: Integer; const AStartPos: Cardinal;
      const AEndPos: Cardinal = MAXPOS_IN_CLUSTER); overload; inline;
    function MakeRangeMask(const AStartPos: Cardinal = MINPOS_IN_CLUSTER;
      const AEndPos: Cardinal = MAXPOS_IN_CLUSTER): Cardinal; inline;
  public
    procedure Clear; inline;
    procedure Include(const AChar: Char); inline;
    procedure IncludeRagne(const AFromChar, AToChar: Char); inline;
    procedure Exclude(const AChar: Char); inline;
    procedure Invert; inline;
    function Contains(const AChar: Char): Boolean; overload; inline;
    function Contains(const AChars: array of Char): Boolean; overload;
  end;

{ TCharSet }

procedure TCharSet.Clear;
begin
  FillChar(FFlagCluster[0], Length(FFlagCluster) * SizeOf(FFlagCluster[0]), 0);
end;

function TCharSet.ClusterIndexOf(const AVal: Char): Integer;
begin
  Result := ClusterIndexOf(Ord(AVal));
end;

function TCharSet.ClusterIndexOf(const AVal: SmallInt): Integer;
begin
  Result := AVal div (SizeOf(FFlagCluster[0]) * 8);
end;

function TCharSet.Contains(const AChars: array of Char): Boolean;
var
  I: Integer;
begin
  for I := 0 to Length(AChars) - 1 do
  begin
    if (Contains(AChars[I])) then
      Exit(True);
  end;

  Result := False;
end;

function TCharSet.Contains(const AChar: Char): Boolean;
begin
  Result := (FFlagCluster[ClusterIndexOf(AChar)] and (MaskInCluster(AChar))) <> 0;
end;

procedure TCharSet.Exclude(const AChar: Char);
begin
  FFlagCluster[ClusterIndexOf(AChar)] :=
    FFlagCluster[ClusterIndexOf(AChar)] and (not MaskInCluster(AChar));
end;

procedure TCharSet.FillCluster(const AClusterIdx: Integer);
begin
  FFlagCluster[AClusterIdx] := $FFFFFFFF;
end;

procedure TCharSet.FillCluster(const AClusterIdx: Integer; const AStartPos,
  AEndPos: Cardinal);
begin
  FFlagCluster[AClusterIdx] :=
    FFlagCluster[AClusterIdx] or MakeRangeMask(AStartPos, AEndPos);
end;

procedure TCharSet.Include(const AChar: Char);
begin
  Assert(Ord(AChar) <= $FF);
  FFlagCluster[ClusterIndexOf(AChar)] :=
    FFlagCluster[ClusterIndexOf(AChar)] or MaskInCluster(AChar);
end;

procedure TCharSet.IncludeRagne(const AFromChar, AToChar: Char);
var
  I, FromClusterIdx, ToClusterIdx: Integer;
  F, T: SmallInt;
begin
  F := Ord(AFromChar);
  T := Ord(AToChar);
  if (F > T) then
    Exit;

  FromClusterIdx := ClusterIndexOf(F);
  ToClusterIdx := ClusterIndexOf(T);

  if FromClusterIdx = ToClusterIdx then
    FillCluster(FromClusterIdx, PosInCluster(F), PosInCluster(T))
  else
  begin
    FillCluster(FromClusterIdx, PosInCluster(F));
    for I := FromClusterIdx + 1 to ToClusterIdx - 1 do
      FillCluster(I);
    FillCluster(ToClusterIdx, 0, PosInCluster(T));
  end;
end;

procedure TCharSet.Invert;
var
  I: Integer;
begin
  for I := 0 to Length(FFlagCluster)-1 do
    FFlagCluster[I] := not FFlagCluster[I];
end;

function TCharSet.MakeRangeMask(const AStartPos, AEndPos: Cardinal): Cardinal;
var
  Range: Cardinal;
begin
  Result := $FFFFFFFF;
  Range := AEndPos - AStartPos + 1;
  Result := Result shl (RANGE_PER_CLUSTER - Range);
  Result := Result shr (MAXPOS_IN_CLUSTER - AEndPos);
end;

function TCharSet.MaskInCluster(const AVal: SmallInt): Cardinal;
begin
  Result := 1 shl PosInCluster(AVal);
end;

function TCharSet.PosInCluster(const AVal: SmallInt): Cardinal;
begin
  Result := AVal mod RANGE_PER_CLUSTER;
end;

function TCharSet.MaskInCluster(const AVal: Char): Cardinal;
begin
  Result := MaskInCluster(Ord(AVal));
end;

{ Unformat }

function Unformat(const AInput, AFormat: String; const AInputLength: Integer;
  const AOutput: array of Pointer; out AOutputCount: Integer;
  const AFormatSettings: TFormatSettings;
  const AOptions: TUnformatOptions): Boolean; overload;
const
  FLOAT_STRLEN_MAX = 32;
var
  InpIdx, FmtIdx, InpStart, I, Value, Index, Width: Integer;
  Value64: UInt64;
  Value32: UInt32;
  ValueExt: Extended;
  TypeInfo, TypeSpec, Terminator: WideChar;
  Param: Pointer;
  Pattern: TCharSet;
  Negative, Thousands, Skip, CaseSensitive: Boolean;
  FloatState: (fsIntegral, fsFractional, fsExponent);
  Buf: array [0..FLOAT_STRLEN_MAX - 1] of Char;
  Temp: String;
begin
  AOutputCount := 0;
  Result := False;

  if (Length(AOutput) = 0) then
    Exit(True);

  if (AInput.Length = 0) or (AFormat.Length = 0) then
    Exit;

  Index := 0;
  InpIdx := 0;
  FmtIdx := 0;
  CaseSensitive := (TUnformatOption.CaseSensitive in AOptions);

  try
    { Scan AFormat string }
    while (AFormat.Chars[FmtIdx] <> #0) and (AInput.Chars[InpIdx] <> #0) do
    begin
      { Scan for '%' token }
      while (AFormat.Chars[FmtIdx] <> #0) do
      begin
        case AFormat.Chars[FmtIdx] of
          '%':
            begin
              { If the AFormat is '%%', then the AInput must match a single '%' }
              Inc(FmtIdx);
              if (AFormat.Chars[FmtIdx] = '%') then
              begin
                if (AInput.Chars[InpIdx] = '%') then
                begin
                  Inc(FmtIdx);
                  Inc(InpIdx);
                end
                else
                  Exit; { Mismatch, terminate }
              end
              else
                Break; { Found AFormat specifier }
            end;

          #1..#32:
            begin
              { Skip whitespace in AInput an AFormat }
              while (AFormat.Chars[FmtIdx] <> #0) and(AFormat.Chars[FmtIdx] <= ' ') do
                Inc(FmtIdx);

              while (AInput.Chars[InpIdx] <> #0) and(AInput.Chars[InpIdx] <= ' ') do
                Inc(InpIdx);
            end;
        else
          begin
            { Characters other than '%' or whitespace must match exactly }
            if (CaseSensitive) then
            begin
              if (AInput.Chars[InpIdx] <> AFormat.Chars[FmtIdx]) then
                Exit;
            end
            else
            begin
              if (AInput.Chars[InpIdx].ToUpper <> AFormat.Chars[FmtIdx].ToUpper) then
                Exit;
            end;
            Inc(InpIdx);
            Inc(FmtIdx);
          end;
        end;
      end;

      if (AFormat.Chars[FmtIdx] = #0) or (AInput.Chars[InpIdx] = #0) then
        Exit;

      { We found a '%'. Now parse the AFormat specifier:
        "%" [index ":"] ["-"] [width] ["." prec] ["#" typeinfo] type }
      Width := 0;
      TypeInfo := #0;
      TypeSpec := #0;
      Negative := False;
      while (AFormat.Chars[FmtIdx] <> #0) do
      begin
        if (AFormat.Chars[FmtIdx] = '-') then
          Inc(FmtIdx); { Ignore Left Justification specifier }

        Value := 0;
        while (AFormat.Chars[FmtIdx] >= '0') and (AFormat.Chars[FmtIdx] <= '9') do
        begin
          Value := Value * 10 + (Ord(AFormat.Chars[FmtIdx]) - Ord('0'));
          Inc(FmtIdx);
        end;

        case AFormat.Chars[FmtIdx] of
          #0:
            Exit;

          ':':
            begin
              Index := Value;
              Inc(FmtIdx);
            end;

          '.':
            begin
              Width := Value;

              { Ignore precision }
              Inc(FmtIdx);
              while (AFormat.Chars[FmtIdx] >= '0') and (AFormat.Chars[FmtIdx] <= '9') do
                Inc(FmtIdx);
            end;

          '#':
            begin
              if (Width = 0) then
                Width := Value;

              { Extract type info }
              Inc(FmtIdx);
              TypeInfo := AFormat.Chars[FmtIdx].ToUpper;

              if (TypeInfo = '1') or (TypeInfo = '3') or (TypeInfo = '6') then
                { Ignore 2nd character in '16', '32' or '64' }
                Inc(FmtIdx);

              Inc(FmtIdx);
            end;

        else
          begin
            if (Width = 0) then
              Width := Value;

            { Extract type specifier }
            TypeSpec := AFormat.Chars[FmtIdx].ToUpper;
            Inc(FmtIdx);
            Break;
          end;
        end;
      end;

      { We have successfully parse the AFormat specifier. Now get the
        corresponding AOutput parameter. }
      if (Index >= Length(AOutput)) then
        Exit;

      Param := AOutput[Index];

      if (TypeSpec = '[') then
      begin
        { Parse [..] pattern }
        Pattern.Clear;
        Negative := (AFormat.Chars[FmtIdx] = '^');
        if (Negative) then
          Inc(FmtIdx);

        { Special cases ']' and '-' right after opening bracket }
        if (AFormat.Chars[FmtIdx] = ']') or (AFormat.Chars[FmtIdx] = '-') then
        begin
          Pattern.Include(AFormat.Chars[FmtIdx]);
          Inc(FmtIdx);
        end;

        { Parse pattern }
        while (AFormat.Chars[FmtIdx] <> #0) do
        begin
          if (AFormat.Chars[FmtIdx] = ']') then
          begin
            { End of pattern }
            Inc(FmtIdx);
            Break;
          end
          else if (AFormat.Chars[FmtIdx+1] = '-') and (AFormat.Chars[FmtIdx+2] <> ']') then
          begin
            { Range }
            Pattern.IncludeRagne(AFormat.Chars[FmtIdx], AFormat.Chars[FmtIdx+2]);
            Inc(FmtIdx, 3);
          end
          else
          begin
            { Single character }
            Pattern.Include(AFormat.Chars[FmtIdx]);
            Inc(FmtIdx);
          end;
        end;

        if (Negative) then
          { Negate pattern }
          Pattern.Invert;
      end
      else
      begin
        { Ignore whitespace for non-pattern data types }
        while (AInput.Chars[InpIdx] <> #0) and (AInput.Chars[InpIdx] <= ' ') do
          Inc(InpIdx);
        if (AInput.Chars[InpIdx] = #0) then
          Exit;

        { For the %i specifier, auto detect Decimal vs Hexadecimal }
        if (TypeSpec = 'I') then
        begin
          { Check sign. }
          Negative := AInput.Chars[InpIdx] = '-';
          if (Negative) or (AInput.Chars[InpIdx] = '+') then
          begin
            Inc(InpIdx);
            if (AInput.Chars[InpIdx] = #0) then
              Exit;
          end;
          if (AInput.Chars[InpIdx] = '$') then
          begin
            TypeSpec := 'X';
            Inc(InpIdx);
            if (AInput.Chars[InpIdx] = #0) then
              Exit;
          end
          else if (AInput.Chars[InpIdx] = '0') and (AInput.Chars[InpIdx+1].ToUpper = 'X') then
          begin
            TypeSpec := 'X';
            Inc(InpIdx, 2);
            if (AInput.Chars[InpIdx] = #0) then
              Exit;
          end
          else
            TypeSpec := 'D';
        end;
      end;

      { We can now parse the AInput }
      if (Width = 0) then
        Width := MaxInt;
      Width := Min(Width, AInputLength - InpIdx);

      case TypeSpec of
        'D',
        'U':
          begin
            { Check sign. }
            if not Negative then
            begin
              Negative := (AInput.Chars[InpIdx] = '-');
              if (Negative) or (AInput.Chars[InpIdx] = '+') then
              begin
                Inc(InpIdx);
                if (AInput.Chars[InpIdx] = #0) then
                  Exit;
              end;
            end;

            { Scan decimal number }
            if (TypeInfo = '6') then
            begin
              { Special case for 64-bit integers. Parsing an Int64 is slower. }
              Value64 := 0;
              while (AInput.Chars[InpIdx] >= '0') and (AInput.Chars[InpIdx] <= '9') do
              begin
                Value64 := (Value64 * 10) + Cardinal(Ord(AInput.Chars[InpIdx]) - Ord('0'));
                Inc(InpIdx);
              end;

              if Assigned(Param) then
              begin
                if (Negative) then
                  Int64(Param^) := -(Int64(Value64))
                else
                  UInt64(Param^) := Value64;
              end;
            end
            else
            begin
              { Use an Int32 for parsing 8-32 bit integers. This is faster than
                using a 64-bit integer. }
              Value32 := 0;
              while (AInput.Chars[InpIdx] >= '0') and (AInput.Chars[InpIdx] <= '9') do
              begin
                Value32 := (Value32 * 10) + Cardinal(Ord(AInput.Chars[InpIdx]) - Ord('0'));
                Inc(InpIdx);
              end;

              if Assigned(Param) then
              begin
                if (Negative) then
                  Int32(Value32) := -(Int32(Value32));

                case TypeInfo of
                  '1': UInt16(Param^) := UInt16(Value32);
                  '8': UInt8(Param^) := UInt8(Value32);
                else
                  UInt32(Param^) := Value32;
                end;
              end;
            end;
          end;

        'X',
        'P':
          begin
            { Check sign. }
            if not Negative then
            begin
              Negative := (AInput.Chars[InpIdx] = '-');
              if (Negative) or (AInput.Chars[InpIdx] = '+') then
              begin
                Inc(InpIdx);
                if (AInput.Chars[InpIdx] = #0) then
                  Exit;
              end;
            end;

            { Scan hexadecimal number }
            if (TypeInfo = '6') then
            begin
              { Special case for 64-bit integers. Parsing an Int64 is slower. }
              Value64 := 0;
              while (True) do
              begin
                case AInput.Chars[InpIdx] of
                  '0'..'9':
                    Value64 := (Value64 shl 4) + Cardinal(Ord(AInput.Chars[InpIdx]) - Ord('0'));
                  'A'..'F':
                    Value64 := (Value64 shl 4) + Cardinal(Ord(AInput.Chars[InpIdx]) - Ord('A') + 10);
                  'a'..'f':
                    Value64 := (Value64 shl 4) + Cardinal(Ord(AInput.Chars[InpIdx]) - Ord('a') + 10);
                else
                  Break;
                end;
                Inc(InpIdx);
              end;

              if Assigned(Param) then
              begin
                if (Negative) then
                  Int64(Param^) := -(Int64(Value64))
                else
                  UInt64(Param^) := Value64;
              end;
            end
            else
            begin
              { Use an Int32 for parsing 8-32 bit integers. This is faster than
                using a 64-bit integer. }
              Value32 := 0;
              while (True) do
              begin
                case AInput.Chars[InpIdx] of
                  '0'..'9':
                    begin
                      Value32 := (Value32 shl 4) + Cardinal(Ord(AInput.Chars[InpIdx]) - Ord('0'));
                      Inc(InpIdx);
                    end;
                  'A'..'F':
                    begin
                      Value32 := (Value32 shl 4) + Cardinal(Ord(AInput.Chars[InpIdx]) - Ord('A') + 10);
                      Inc(InpIdx);
                    end;
                  'a'..'f':
                    begin
                      Value32 := (Value32 shl 4) + Cardinal(Ord(AInput.Chars[InpIdx]) - Ord('a') + 10);
                      Inc(InpIdx);
                    end;
                else
                  Break;
                end;
              end;

              if Assigned(Param) then
              begin
                if (Negative) then
                  Int32(Value32) := -(Int32(Value32));
                case TypeInfo of
                  '1': UInt16(Param^) := UInt16(Value32);
                  '8': UInt8(Param^) := UInt8(Value32);
                else
                  UInt32(Param^) := Value32;
                end;
              end;
            end;
          end;

        'E',
        'F',
        'G',
        'N':
          begin
            ValueExt := 0.0;

            { Check sign }
            Negative := (AInput.Chars[InpIdx] = '-');
            if (Negative) or (AInput.Chars[InpIdx] = '+') then
            begin
              Inc(InpIdx);
              Dec(Width);
              if (AInput.Chars[InpIdx] = #0) then
                Exit;
            end;

            { Check for NAN and INF }
            Skip := False;
            if (Width >= 3) then
            begin
              Temp := AInput.SubString(InpIdx, 3);
              if Temp.Equals('NAN') then
              begin
                { 'NAN' }
                if (Negative) then
                  ValueExt := -NaN
                else
                  ValueExt := NaN;
                Inc(InpIdx, 3);
                Skip := True;
              end
              else if (Temp.Equals('INF')) then
              begin
                { 'INF' }
                if (Negative) then
                  ValueExt := NegInfinity
                else
                  ValueExt := Infinity;
                Inc(InpIdx, 3);
                Skip := True;
              end;
            end;

            if (not Skip) then
            begin
              { Extract string to temporary buffer }
              Thousands := (TypeSpec = 'N');
              FloatState := fsIntegral;
              if (Negative) then
              begin
                Buf[0] := '-';
                I := 1;
              end
              else
                I := 0;

              while (I < (Length(Buf) - 1)) do
              begin
                if (AInput.Chars[InpIdx] >= '0') and (AInput.Chars[InpIdx] <= '9') then
                begin
                  Buf[I] := AInput.Chars[InpIdx];
                  Inc(I);
                  Inc(InpIdx);
                end
                else if (Thousands) and (FloatState = fsIntegral)
                  and (AInput.Chars[InpIdx] = AFormatSettings.ThousandSeparator) then
                begin
                  { Skip }
                  Inc(InpIdx);
                end
                else if (FloatState = fsIntegral)
                  and (AInput.Chars[InpIdx] = AFormatSettings.DecimalSeparator) then
                begin
                  Buf[I] := AInput.Chars[InpIdx];
                  Inc(I);
                  Inc(InpIdx);
                  FloatState := fsFractional;
                end
                else if (FloatState <> fsExponent) and ((AInput.Chars[InpIdx] = 'e') or (AInput.Chars[InpIdx] = 'E')) then
                begin
                  Buf[I] := AInput.Chars[InpIdx];
                  Inc(I);
                  Inc(InpIdx);
                  FloatState := fsExponent;
                  if (AInput.Chars[InpIdx] = '-') or (AInput.Chars[InpIdx] = '+') then
                  begin
                    Buf[I] := AInput.Chars[InpIdx];
                    Inc(I);
                    Inc(InpIdx);
                  end;
                end
                else
                  Break;
              end;

              { Convert temporary buffer }
              Temp := TEncoding.Unicode.GetString(BytesOf(@Buf[0], I * SizeOf(Char)));
              try
                ValueExt := Extended.Parse(Temp, AFormatSettings);
              except
                on EConvertError do
                  Exit;
              end;
            end;

            { Assign value to AOutput parameter }
            if Assigned(Param) then
            begin
              case TypeInfo of
                'S': Single(Param^)   := ValueExt;
                'E': Extended(Param^) := ValueExt;
              else
                Double(Param^) := ValueExt;
              end;
            end;
          end;

        'S',
        '[':
          begin
            InpStart := InpIdx;
            if (TypeSpec = 'S') then
            begin
              { For Strings, scan until whitespace or terminator }
              Terminator := AFormat.Chars[FmtIdx];
              while (Width > 0) and (AInput.Chars[InpIdx] > ' ') and (AInput.Chars[InpIdx] <> Terminator) do
              begin
                Inc(InpIdx);
                Dec(Width);
              end;
            end
            else
            begin
              { For patterns, scan while characters match pattern }
              while (Width > 0) and (Pattern.Contains(AInput.Chars[InpIdx])) do
              begin
                Inc(InpIdx);
                Dec(Width);
              end;
            end;

            if (InpIdx = InpStart) then
              Exit;

            { Assign value to AOutput parameter }
            if Assigned(Param) then
            begin
              Value := InpIdx - InpStart;
              if (TypeInfo = 'A') then
              begin
                Temp := AInput.Substring(InpStart, Value);
                TBytes(Param^) := BytesOf(Temp);
              end
              else
              begin
                String(Param^) := AInput.Substring(InpStart, Value);
              end;
            end;
          end;
      else
        Exit;
      end;

      { We have parsed one parameter. On to the next one. }
      Inc(Index);
      AOutputCount := Max(AOutputCount, Index);
    end;
  finally
    AOutputCount := Max(AOutputCount, Index);
    Result := (AOutputCount = Length(AOutput));
  end;
end;

function Unformat(const AInput, AFormat: String;
  const AOutput: array of Pointer;
  const AOptions: TUnformatOptions): Boolean; overload;
var
  AOutputCount: Integer;
begin
  Result := Unformat(AInput, AFormat, AInput.Length, AOutput, AOutputCount,
    FormatSettings, AOptions);
end;

function Unformat(const AInput, AFormat: String;
  const AOutput: array of Pointer; const AFormatSettings: TFormatSettings;
  const AOptions: TUnformatOptions): Boolean; overload;
var
  AOutputCount: Integer;
begin
  Result := Unformat(AInput, AFormat, AInput.Length, AOutput, AOutputCount,
    AFormatSettings, AOptions);
end;

function Unformat(const AInput, AFormat: String;
  const AOutput: array of Pointer; out AOutputCount: Integer;
  const AOptions: TUnformatOptions): Boolean; overload;
begin
  Result := Unformat(AInput, AFormat, AInput.Length, AOutput, AOutputCount,
    FormatSettings, AOptions);
end;

function Unformat(const AInput, AFormat: String;
  const AOutput: array of Pointer; out AOutputCount: Integer;
  const AFormatSettings: TFormatSettings;
  const AOptions: TUnformatOptions): Boolean; overload;
begin
  Result := Unformat(AInput, AFormat, AInput.Length, AOutput, AOutputCount,
    AFormatSettings, AOptions);
end;

initialization
  USFormatSettings := TFormatSettings.Create('en-US');
  USFormatSettings.DecimalSeparator := '.';
  USFormatSettings.ThousandSeparator := ',';

end.
