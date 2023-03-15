{
  Copyright (C) 2005 Fabio Almeida
  fabiorecife@yahoo.com.br

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

}
(*

  @abstract( Contém todas as classes para manipular o formato JSON. )

  As principais classes são :  TJSONObject,  TJSONArray .

  OBS: A unit uJSON foi adaptada de uma implementação para json em Java ver
  http://www.json.org .

  JSON =  JavaScript Object Notation

  @author(Jose Fabio Nascimento de Almeida, <fabiorecife@gmail.com>)
  @created(november 7, 2005)

  Utilizando:@br
    para criar um objeto json a partir da string:
    
    @code(
    s  := '{"Commands":[{"Command":"NomeComando", params:{param1:1}}]}';@br
    json := TJSONObject.Create (s);
    )
    
    para acessar os elementos:@br
    @code(json.getJSONArray ('Commands) // retorna uma TJSONArray dos comandos)

    para retornar a string  "NomeComando":@br
    @code(json.getJSONArray ('Commands).getJSONObject(0).getString('Command'))

*)
unit uJSON;

interface
uses
  Windows,SysUtils, Classes,  TypInfo;

Type
    { @abstract(Classe pai de todas as classes em uJSON , resolve o problema de
      impedância entre a classe java Object e a classe delphi TObject)
    }
    TZAbstractObject = class
      { retorna true se value é igual ao objeto}
      function Equals(const Value: TZAbstractObject): Boolean; virtual;
      { código hash do objeto , usa-se o endereço de memória}
      function hash: LongInt;
      { clona o objeto
       @return ( um TZAbstractObject )}
      function Clone: TZAbstractObject; virtual;
      {retorna a representação com string do objeto
       @return (uma string)}
      function toString: string; virtual;
      {retorna true se o parâmetro Value é uma instância de TZAbstractObject }
      function instanceOf(const Value: TZAbstractObject): Boolean;
    end;

    { @abstract(wrapper para ClassCastException do java) }
    ClassCastException = class (Exception) end;
    { @abstract(wrapper para NoSuchElementException do java) }
    NoSuchElementException = class (Exception) end;
    { @abstract(wrapper para NumberFormatException do java) }
    NumberFormatException = class (Exception) end;
    { @abstract(wrapper para NullPointerException do java) }
    NullPointerException = class (Exception) end;
    { @abstract(as features não implementadas geram esta exception) }
    NotImplmentedFeature = class (Exception) end;
    TJSONArray  = class;
    TJSONNumber = class;
    TJSONString = class;
    TJSONDouble = class;
    TJSONNull   = class;

    { @abstract(exception gerada quando ocorre um erro de parsing) }
    ParseException = class (Exception)
       constructor Create(_message: string; index: real);
    end;

    (**
      @abstract(Responsável por auxiliar na análise Léxica de uma string que representa um JSON.)
    *)
    JSONTokener = class  (TZAbstractObject)
     public
       (**
        Construct a JSONTokener from a string.
        @param(s A source string.)     *)
       constructor Create(s: string);

       (**
        Back up one character. This provides a sort of lookahead capability,
        so that you can test for a digit or letter before attempting to parse
        the next number or identifier.
       *)
       procedure back();
       (**
        Get the hex value of a character (base16).
        @param(c A character between '0' and '9' or between 'A' and 'F' or
        between 'a' and 'f'.)
        @return(An int between 0 and 15, or -1 if c was not a hex digit.)
       *)
       class function dehexchar(c: char): integer;
       function more: boolean;
       function next(): char; overload;
       function next(c: char ): char; overload;
       function next(n: integer): string; overload;
       function nextClean(): char;
       function nextString(quote: char): string;
       function nextTo(d: char): string;  overload;
       function nextTo(delimiters: string): char; overload;
       function nextValue(): TZAbstractObject;
       procedure skipPast(_to: string);
       function skipTo(_to: char): char;
       function syntaxError(_message: string): ParseException;
       function toString: string;  override;
       function unescape(s: string): string;
    private
      myIndex: integer;
      mySource: string;
    end;

  { @abstract(Classe que representa um objeto JSON) }
  TJSONObject = class (TZAbstractObject)
  private
    myHashMap: TStringList;
  public
    (**
      Construct an empty TJSONObject.
    *)
    constructor Create;  overload;

    (**
      Construct a TJSONObject from a subset of another TJSONObject.
      An array of strings is used to identify the keys that should be copied.
      Missing keys are ignored.
      @param(jo A TJSONObject.)
      @param(sa An array of strings).
     *)
    constructor Create (jo: TJSONObject; sa: array of string); overload;
    (**
      Construct a TJSONObject from a JSONTokener.
      @param(x A JSONTokener object containing the source string.)
      @raises(ParseException if there is a syntax error in the source string.)
    *)
    constructor Create(x: JSONTokener); overload;
    (**
      Construct a TJSONObject from a TStringList.
      @param(map A map object that can be used to initialize the contents of
       the TJSONObject.)
     *)
    constructor Create(map: TStringList); overload;
    (**
     Construct a TJSONObject from a string.
     This is the most commonly used TJSONObject constructor.
     @param(s @html(A string beginning
     with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     with <code>}</code>&nbsp;<small>(right brace)</small>.))
     @raises(ParseException The string must be properly formatted.)
    *)
    constructor Create(s: string); overload;

    (**
       remove todos os menbros de um objeto JSON  .
    *)
    procedure clean;
    (**
      sobreescreve o metodo Clone de  TZAbstractObject
    *)
    { methods inserted by HydroByte}
    function LoadFromFile(AFilePath: String) : Integer;
    procedure SaveToFile(AFilePath: String);
    procedure Parse(const aStr: string);
    function  TryParse(const aStr: string): Boolean;
    procedure Mount(x: JSONTokener);
    function Clone: TZAbstractObject; override;

    function accumulate(key: string; value: TZAbstractObject): TJSONObject;
    function get(key: string): TZAbstractObject;
    function getBoolean(key: string): boolean;
    function getDouble(key: string): double;
    function getInt(key: string): integer;
    function getJSONArray(key: string):TJSONArray;
    function getJSONObject(key: string): TJSONObject;
    function getString(key: string): string;
    function getStringUtf8(key: string): string;
    function has(key: string): boolean;
    function isNull(key: string): boolean;
    (**
      retorna um TStringList com todos os nomes dos atributos do TJSONObject
    *)
    function keys: TStringList;
    (**
      Retorna quantos atributos tem o TJSONObject
    *)
    function length: integer;
    (**
     Produce a TJSONArray containing the names of the elements of this
     TJSONObject.
     @return(A TJSONArray containing the key strings, or null if the TJSONObject
     is empty).
    *)
    function names: TJSONArray;
    (**
       transforma uma class wrapper TJSONNumber (Number em java) em AnsiString
    *)
    class function numberToString(n: TJSONNumber): string;
    (**
      Make JSON string of an object value.
      @html(<p>
      Warning: This method assumes that the data structure is acyclical.
      )
      @param(value The value to be serialized.)
      @return( @html(a printable, displayable, transmittable
       representation of the object, beginning
       with <code>{</code>&nbsp;<small>(left brace)</small> and ending
       with <code>}</code>&nbsp;<small>(right brace)</small>.))
     *)
    class function valueToString(value: TZAbstractObject): string; overload;
    (**
      Make a prettyprinted JSON text of an object value.
      @html(
      <p>
      Warning: This method assumes that the data structure is acyclical.
      )
      @param(value The value to be serialized.)
      @param(indentFactor The number of spaces to add to each level of
       indentation.)
      @param(indent The indentation of the top level.)
      @return(@html(a printable, displayable, transmittable
       representation of the object, beginning
       with <code>{</code>&nbsp;<small>(left brace)</small> and ending
       with <code>}</code>&nbsp;<small>(right brace)</small>.))
     *)
    class function valueToString(value: TZAbstractObject; indentFactor, 
	  indent: integer): string; overload;
    (**
      Get an optional value associated with a key.
      @param(key   A key string.)
      @return(An object which is the value, or null if there is no value.)
      @raises(NullPointerException caso key = '')
    *)
    function opt(key: string): TZAbstractObject;
    function optBoolean(key: string): boolean; overload;
    function optBoolean(key: string; defaultValue: boolean): boolean; overload;
    function optDouble(key: string): double; overload;
    function optDouble(key: string; defaultValue: double): double; overload;
    function optInt(key: string): integer; overload;
    function optInt(key: string; defaultValue: integer): integer; overload;
    function optString(key: string): string; overload;
    function optString(key: string; defaultValue: string): string; overload;

    function optJSONArray(key: string): TJSONArray; overload;
    function optJSONObject(key: string): TJSONObject; overload;

    function put(key: string; value: boolean): TJSONObject; overload;
    function put(key: string; value: double): TJSONObject; overload;
    function put(key: string; value: integer): TJSONObject; overload;
    function put(key: string; value: string): TJSONObject; overload;

    (**
      Put a key/value pair in the TJSONObject. If the value is null,
      then the key will be removed from the TJSONObject if it is present.
      @param(key   A key string.)
      @param(value An object which is the value. It should be of one of these
       types: Boolean, Double, Integer, TJSONArray, TJSONObject, String, or the
       TJSONObject.NULL object.)
      @return(this.)
      @raises(NullPointerException The key must be non-null.)
    *)
    function put(key: string; value: TZAbstractObject): TJSONObject; overload;
    (**
      Put a key/value pair in the TJSONObject, but only if the
      value is non-null.
      @param(key   A key string.)
      @param(value An object which is the value. It should be of one of these
       types: Boolean, Double, Integer, TJSONArray, TJSONObject, String, or the
       TJSONObject.NULL object.)
      @return(this.)
      @raises(NullPointerException The key must be non-null.)
    *)
    function putOpt(key: string; value: TZAbstractObject): TJSONObject;
    class function quote(s: string): string;
    function remove(key: string): TZAbstractObject;
    procedure assignTo(json: TJSONObject);

    function toJSONArray(names: TJSONArray): TJSONArray;
    function toString(): string; overload; override;
    function toString(indentFactor: integer): string; reintroduce; overload;
    function toString(indentFactor, indent: integer): string; reintroduce; overload;

    destructor Destroy;override;
    class function ObjNULL: TJSONNull;
  end;

  { @abstract(Trata um array JSON = [...])}
  TJSONArray = class (TZAbstractObject)
  public
    destructor Destroy; override;
    constructor Create; overload;
    constructor Create(collection: TList); overload;
    constructor Create(x: JSONTokener); overload;
    constructor Create(s: string);  overload;
    function get(index: integer): TZAbstractObject;
    function getBoolean(index: integer): boolean;
    function getDouble(index: integer): double;
    function getInt(index: integer): integer;
    {
      Get the TJSONArray associated with an index.
      @param(index The index must be between 0 and length() - 1.)
      @return(A TJSONArray value.)
      @raises(NoSuchElementException if the index is not found or if the
      value is not a TJSONArray)     }
    function getJSONArray(index: integer): TJSONArray;
    function getJSONObject(index: integer): TJSONObject;
    function getString(index: integer): string;
    function getStringUtf8(index: integer): string;
    function isNull(index: integer): boolean;
    function join(separator: string): string;
    function length: integer;
    function opt(index: integer): TZAbstractObject;
    function optBoolean(index: integer): boolean; overload;
    function optBoolean(index: integer; defaultValue: boolean): boolean; overload;
    function optDouble(index: integer): double; overload;
    function optDouble(index: integer; defaultValue:double): double; overload;
    function optInt(index: integer): integer; overload;
    function optInt(index: integer; defaultValue: integer): integer; overload;
    function optJSONArray(index: integer): TJSONArray; overload;
    function optJSONObject(index: integer): TJSONObject; overload;
    function optString(index: integer): string; overload;
    function optString(index: integer; defaultValue: string): string; overload;
    function put(value: boolean): TJSONArray; overload;
    function put(value: double ): TJSONArray; overload;
    function put(value: integer): TJSONArray; overload;
    function put(value: TZAbstractObject): TJSONArray; overload;
    function put(value: string): TJSONArray; overload;
    function put(index: integer; value: boolean): TJSONArray; overload;
    function put(index: integer; value: double): TJSONArray; overload;
    function put(index: integer; value: integer): TJSONArray; overload;
    function put(index: integer; value: TZAbstractObject): TJSONArray; overload;
    function put(index: integer; value: string): TJSONArray; overload;
    function toJSONObject(names:TJSONArray): TJSONObject; overload;
    function toString: string; overload; override;
    function toString(indentFactor: integer): string; reintroduce; overload;
    function toString(indentFactor, indent: integer): string; reintroduce; overload;
    function toList(): TList;
  private
    myArrayList: TList;
  end;

  (** @abstract(wrapper da classe Number do java) *)
  TJSONNumber = class (TZAbstractObject)
     function doubleValue: double; virtual; abstract;
     function intValue: integer; virtual; abstract;
  end;

  (** @abstract(wrapper da classe Boolean do java) *)
  TJSONBool = class (TZAbstractObject)
    class function _TRUE(): TJSONBool;
    class function _FALSE(): TJSONBool;
    class function valueOf(b: boolean): TJSONBool;
    constructor Create(b: boolean);
    function toString(): string; override;
    function Clone:TZAbstractObject;  override;
  private
    FValue: boolean;
  end;

  (** @abstract(wrapper da classe Double do java) *)
  TJSONDouble = class (TJSONNumber)
     constructor Create(s: string); overload;
     constructor Create(s: TJSONString); overload;
     constructor Create(d: double); overload;
     function doubleValue: double; override;
     function intValue: integer;  override;
     function toString(): string; override;
     class function NaN: double;
     function Clone: TZAbstractObject; override;
     class var
       FStrFloatFmt: String;
  private
    FValue: double;
  end;

  (** @abstract(wrapper da classe Integer do java) *)
  TJSONInteger = class (TJSONNumber)
    class function parseInt(s: string; i: integer): integer; overload;
    class function parseInt(s: TJSONString): integer; overload;
    class function toHexString(c: char): string;
    constructor Create(i: integer); overload;
    constructor Create(s: string); overload;
    function doubleValue: double; override;
    function intValue: integer;  override;
    function toString(): string; override;
     function Clone:TZAbstractObject; override;
  private
    FValue: integer;
  end;

  (** @abstract(wrapper da classe String do java) *)
  TJSONString = class (TZAbstractObject)
   constructor Create(s: string);
   function EqualsIgnoreCase(s: string): Boolean;
   function Equals(const Value: TZAbstractObject): Boolean; override; 
   function toString(): string; override;
   function Clone:TZAbstractObject; override;
  private
     FValue: string;
  end;


  (** @abstract(utilizado quando se deseja representar um valor NULL ) *)
  TJSONNull = class (TZAbstractObject)
     function Equals(const Value: TZAbstractObject): Boolean; override;
     function toString(): string; override;
  end;


var
  (** constante para representar um objeto null *)
  CNULL: TJSONNull;

implementation

const
  CROTINA_NAO_IMPLEMENTADA:string = 'Rotina Não Implementada';

procedure newNotImplmentedFeature();
begin
  raise NotImplmentedFeature.Create(CROTINA_NAO_IMPLEMENTADA);
end;

function getFormatSettings: TFormatSettings;
var
  f: TFormatSettings;
begin
 {$IFDEF MSWINDOWS}
  SysUtils.GetLocaleFormatSettings(Windows.GetThreadLocale,f);
 {$ELSE}
    newNotImplmentedFeature();
 {$ENDIF}
  Result := f;
  Result.DecimalSeparator := '.';
  Result.ThousandSeparator := ',';
  Result.CurrencyDecimals := 2;

end;


function HexToInt(S: String): Integer;
var
  I, E, F, G: Integer;

  function DigitValue(C: Char): Integer;
  begin
    case C of
      'A': Result := 10;
      'B': Result := 11;
      'C': Result := 12;
      'D': Result := 13;
      'E': Result := 14;
      'F': Result := 15;
    else
      Result := StrToInt(C);
    end;
  end;

begin
  S := UpperCase(S);
  if S[1] = '$' then Delete(S, 1, 1);
  if S[2] = 'X' then Delete(S, 1, 2);
  E := -1; Result := 0;
  for I := Length(S) downto 1 do begin
    G := 1; for F := 0 to E do G := G*16;
    Result := Result+(DigitValue(S[I])*G);
    Inc(E);
  end;
end;



{ JSONTokener }


constructor JSONTokener.Create(s: string);
begin
  self.myIndex := 1;
  self.mySource := s;
end;



procedure JSONTokener.back;
begin
  if (self.myIndex > 1) then begin
            self.myIndex := self.myIndex - 1;
  end;
end;



class function JSONTokener.dehexchar(c: char): integer;
begin
  if ((c >= '0') and (c <= '9')) then begin
      Result :=  (ord(c) - ord('0'));
      exit;
  end;
  if ((c >= 'A') and (c <= 'F')) then begin
      Result :=  (ord(c) + 10 - ord('A'));
      exit;
  end;
  if ((c >= 'a') and (c <= 'f')) then begin
      Result := ord(c) + 10 - ord('a');
      exit;
  end;
  Result := -1;
end;


(**
     * Determine if the source string still contains characters that next()
     * can consume.
     * @return true if not yet at the end of the source.
*)
function JSONTokener.more: boolean;
begin
  Result := self.myIndex <= System.length(self.mySource)+1;
end;

function JSONTokener.next: char;
begin
   if (more()) then begin
	        Result := self.mySource[self.myIndex];
	        self.myIndex := self.myIndex + 1;
          exit;
    end;
		Result := chr(0);
end;


 (**
     * Consume the next character, and check that it matches a specified
     * character.
     * @param c The character to match.
     * @return The character.
     * @throws ParseException if the character does not match.
     *)
function JSONTokener.next(c: char): char;
begin
  Result := next();
  if (Result <> c) then begin
      raise syntaxError('Expected ' + c + ' and instead saw ' +
              Result + '.');
  end;
end;


(**
     * Get the next n characters.
     *
     * @param n     The number of characters to take.
     * @return      A string of n characters.
     * @raises (ParseException
     *   Substring bounds error if there are not
     *   n characters remaining in the source string.)
     *)
function JSONTokener.next(n: integer): string;
var
 i,j: integer;
begin
   i := self.myIndex;
   j := i + n;
   if (j > System.length(self.mySource)) then begin
      raise syntaxError('Substring bounds error');
   end;
   self.myIndex := self.myIndex + n;
   Result := copy(self.mySource,i,n); //substring(i, j)
end;

 (**
     * Get the next char in the string, skipping whitespace
     * and comments (slashslash, slashstar, and hash).
     * @throws ParseException
     * @return  A character, or 0 if there are no more characters.
     *)
function JSONTokener.nextClean: char;
var
  c: char;

begin
  while (true) do
  begin
    c := next();
    if (c = '/') then begin
        case (next()) of
        '/': begin
            repeat
                c := next();
            until (not ((c <> #10) and (c <> #13) and (c <> #0)));
        end;
        '*': begin
            while (true) do begin
                c := next();
                if (c = #0) then begin
                    raise syntaxError('Unclosed comment.');
                end;
                if (c = '*') then begin
                    if (next() = '/') then begin
                        break;
                    end;
                    back();
                end;
            end;
        end
        else begin
            back();
            Result := '/';
            exit;
        end;
    end;
    end else if (c = '#') then begin
        repeat
            c := next();
        until (not ((c <> #10) and (c <> #13) and (c <> #0)));
    end else if ((c = #0) or (c > ' ')) then begin
        Result := c;
        exit;
    end;
  end; //while
end;


(**
     * Return the characters up to the next close quote character.
     * Backslash processing is done. The formal JSON format does not
     * allow strings in single quotes, but an implementation is allowed to
     * accept them.
     * @param quote The quoting character, either
     *      <code>"</code>&nbsp;<small>(double quote)</small> or
     *      <code>'</code>&nbsp;<small>(single quote)</small>.
     * @return      A String.
     * @raises (ParseException Unterminated string.)
     *)
function JSONTokener.nextString(quote: char): string;
var
  c: char;
  sb: string;
begin
  sb := '';
  while (true) do begin
      c := next();
      case (c) of
      #0, #10, #13: begin
          raise syntaxError('Unterminated string');
      end;
      '\': begin
          c := next();
          case (c) of
          'b': 
              sb := sb + #8;
          't':
              sb := sb + #9;
          'n':
              sb := sb + #10;
          'f':
              sb := sb + #12;
          'r':
              sb := sb + #13;
          'u':
            sb := sb+WideChar(StrToInt('$'+next(4)));
          {case 'u':
              sb.append((char)Integer.parseInt(next(4), 16));
              break;
          case 'x' :  \cx  	The control character corresponding to x
              sb.append((char) Integer.parseInt(next(2), 16));
              break;}
            else   sb := sb + c
          end;
      end
      else  begin
          if (c = quote) then begin
              Result := sb;
              exit;
          end;
          sb := sb + c
      end;
      end;
  end;
end;

(**
     * Get the text up but not including the specified character or the
     * end of line, whichever comes first.
     * @param  d A delimiter character.
     * @return   A string.
     *)
function JSONTokener.nextTo(d: char): string;
var
  sb: string;
  c: char;
begin
  {c := #0;}
  sb := '';
  while (true) do
  begin
    c := next();
    if ((c = d) or (c = #0) or (c = #10) or (c = #13)) then begin
        if (c <> #0) then begin
            back();
        end;
        Result := trim (sb);
        exit;
    end;
    sb := sb + c;
  end;
end;

(**
     * Get the text up but not including one of the specified delimeter
     * characters or the end of line, whichever comes first.
     * @param delimiters A set of delimiter characters.
     * @return A string, trimmed.
*)
function JSONTokener.nextTo(delimiters: string): char;
var
  c: char;
  sb: string;
begin
  {c := #0;}
  sb := '';
  while (true) do begin
      c := next();
      if ((pos(c,delimiters) > 0) or (c = #0) or
              (c = #10) or (c = #13)) then begin
          if (c <> #0) then begin
              back();
          end;
          sb := trim(sb);
          if (System.length(sb) > 0) then Result := sb[1];
          exit;
      end;
      sb := sb + c;
  end;
end;

(**
     * Get the next value. The value can be a Boolean, Double, Integer,
     * TJSONArray, TJSONObject, or String, or the TJSONObject.NULL object.
     * @raises (ParseException The source does not conform to JSON syntax.)
     *
     * @return An object.
*)
function JSONTokener.nextValue: TZAbstractObject;
var
  c, b: char;
  s , sb: string;
begin
  c := nextClean();

  case (c) of
      '"', #39: begin
          Result := TJSONString.Create(nextString(c));
          exit;
      end;
      '{': begin
          back();
          Result := TJSONObject.Create(self);
          exit;
      end;
      '[': begin
          back();
          Result := TJSONArray.Create(self);
          exit;
      end;
  end;

  (*
   * Handle unquoted text. This could be the values true, false, or
   * null, or it can be a number. An implementation (such as this one)
   * is allowed to also accept non-standard forms.
   *
   * Accumulate characters until we reach the end of the text or a
   * formatting character.
   *)

  sb := '';
  b := c;
  while ((ord(c) >= ord(' ')) and (pos(c,',:]}/\\\"[{;=#') = 0)) do begin
      sb := sb + c;
      c := next();
  end;
  back();

  (*
   * If it is true, false, or null, return the proper value.
   *)

  s := trim(sb);
  if (s = '') then begin
      raise syntaxError('Missing value.');
  end;
  if (AnsiLowerCase(s) = 'true') then begin
      Result :=  TJSONBool._TRUE;
      exit;
  end;

  if (AnsiLowerCase(s) = 'false') then begin
      Result := TJSONBool._FALSE;
      exit;
  end;
  if (AnsiLowerCase(s) = 'null') then begin
      Result := TJSONObject.ObjNULL;
      exit;
  end;

  (*
   * If it might be a number, try converting it. We support the 0- and 0x-
   * conventions. If a number cannot be produced, then the value will just
   * be a string. Note that the 0-, 0x-, plus, and implied string
   * conventions are non-standard. A JSON parser is free to accept
   * non-JSON forms as long as it accepts all correct JSON forms.
   *)

  if ( ((b >= '0') and (b <= '9')) or (b = '.')
                    or (b = '-') or (b = '+')) then begin
      if (b = '0') then begin
          if ( (System.length(s) > 2) and
                  ((s[2] = 'x') or (s[2] = 'X') ) ) then begin
              try
                  Result := TJSONInteger.Create(
                  TJSONInteger.parseInt(copy(s,3,System.length(s)), 16) );
                  exit;
              Except
                on e:Exception do begin
                  ///* Ignore the error */
                end;
              end;
          end else begin
              try
                  Result := TJSONInteger.Create(TJSONInteger.parseInt(s, 8));
                  exit;
              Except
                on e:Exception do begin
                  ///* Ignore the error */
                end;
              end;
          end;
      end;
      try
          Result := TJSONInteger.Create(s);
          exit;
      Except
              on e:Exception do begin
                ///* Ignore the error */
              end;
      end;

      try
          Result := TJSONDouble.Create(s);
          exit;
      Except
              on e:Exception do begin
                ///* Ignore the error */
              end;
      end;
  end;
  Result := TJSONString.Create(s);
end;

(**
     * Skip characters until the next character is the requested character.
     * If the requested character is not found, no characters are skipped.
     * @param to A character to skip to.
     * @return The requested character, or zero if the requested character
     * is not found.
     *)
function JSONTokener.skipTo(_to: char): char;
var
  c: char;
  index: integer;
begin
   {c := #0;}
    index := self.myIndex;
    repeat
        c := next();
        if (c = #0) then begin
            self.myIndex := index;
            Result := c;
            exit;
       end;
    until (not (c <> _to));
    back();
    Result := c;
    exit;
end;

(**
     * Skip characters until past the requested string.
     * If it is not found, we are left at the end of the source.
     * @param to A string to skip past.
     *)
procedure JSONTokener.skipPast(_to: string);
begin
   self.myIndex := pos(_to, copy(mySource, self.myIndex, System.length(mySource)));
        if (self.myIndex < 0) then begin
            self.myIndex := System.length(self.mySource)+1;
        end else begin
            self.myIndex := self.myIndex + System.length(_to);
        end;
end;



(**
     * Make a ParseException to signal a syntax error.
     *
     * @param message The error message.
     * @return  A ParseException object, suitable for throwing
     *)
function JSONTokener.syntaxError(_message: string): ParseException;
begin
  Result := ParseException.Create(
    _message + toString() + ' próximo a : ' +
    copy(toString(), self.myIndex,10), self.myIndex);
end;


(**
     * Make a printable string of this JSONTokener.
     *
     * @return " at character [this.myIndex] of [this.mySource]"
     *)
function JSONTokener.toString: string;
begin
  Result := ' at character ' + intToStr(self.myIndex) + ' of ' + self.mySource;
end;


(**
     * Convert <code>%</code><i>hh</i> sequences to single characters, and
     * convert plus to space.
     * @param s A string that may contain
     *      <code>+</code>&nbsp;<small>(plus)</small> and
     *      <code>%</code><i>hh</i> sequences.
     * @return The unescaped string.
     *)
function JSONTokener.unescape(s: string): string;
var
  len, i,d,e: integer;
  b: string;
  c: char;
begin
  len := System.length(s);
  b := '';
  i := 1;
  while ( i <= len ) do begin
      c := s[i];
      if (c = '+') then begin
          c := ' ';
      end else if ((c = '%') and ((i + 2) <= len)) then begin
          d := dehexchar(s[i + 1]);
          e := dehexchar(s[i + 2]);
          if ((d >= 0) and (e >= 0)) then begin
              c := chr(d * 16 + e);
              i := i + 2;
          end;
      end;
      b := b + c;
      i := i + 1;
  end;
  Result := b;
end;

{ TJSONObject }

constructor TJSONObject.Create;
begin
  myHashMap := TStringList.Create;
end;

constructor TJSONObject.Create(jo: TJSONObject; sa: array of string);
var
 i: integer;
begin
  Create();
  for i :=low(sa) to high(sa) do
  begin
    putOpt(sa[i], jo.opt(sa[i]).Clone);
  end;
end;

constructor TJSONObject.Create(x: JSONTokener);
begin
  Mount(x);
end;

constructor TJSONObject.Create(map: TStringList);
var
 i: integer;
begin
  self.myHashMap := TStringlist.Create;
  for i := 0 to map.Count -1 do begin
    self.myHashMap.AddObject(map[i],map.Objects[i]);
  end;
end;

constructor TJSONObject.Create(s: string);
var
  token: JSOnTokener;
begin
  token := JSONTokener.Create(s);
  Create(token);
  token.free;
end;

function TJSONObject.LoadFromFile(AFilePath: String) : Integer;
var
  Token: JSOnTokener;
  StrLst: TStringList;
  SJson: String;
  Size: Integer;
begin
  Size   := -1;
  StrLst := TStringList.Create;
  try
    StrLst.LoadFromFile(AFilePath);
    Size := StrLst.Count;
    if (Size > 0) then
    begin
      SJson := StrLst.Text;
      Token := JSONTokener.Create(SJson);
      Mount(Token);
      Token.free;
    end;
  finally
    StrLst.Free;
  end;
  Result := Size;
end;

procedure TJSONObject.SaveToFile(AFilePath: String);
var
  Token: JSOnTokener;
  StrLst: TStringList;
  SJson: String;
begin
  StrLst := TStringList.Create;
  try
    StrLst.Text := Self.toString();
    StrLst.SaveToFile(AFilePath);
  finally
    StrLst.Free;
  end;
end;

procedure TJSONObject.Parse(const aStr: string);
var
  Token: JSOnTokener;
begin
  try
    Token := JSONTokener.Create(aStr);
    Mount(Token);
  finally
    Token.free;
  end;  
end;

function TJSONObject.TryParse(const aStr: string): Boolean;
begin
  try
    Parse(aStr);
    Result := True;
  except
    Result := False;
  end;
end;

procedure TJSONObject.Mount(x: JSONTokener);
var
 c: char;
 key: string;
begin
  {It was the Create() constructor, so copied its content}
  myHashMap := TStringList.Create;

  {c := #0;}
  key := '';

  if (x.nextClean() <> '{') then begin
      raise x.syntaxError('A TJSONObject must begin with "{"');
  end;
  while (true) do begin
      c := x.nextClean();
      case (c) of
      #0:
          raise x.syntaxError('A TJSONObject must end with "}"');
      '}': begin
          exit;
      end
      else begin
          x.back();
          with x.nextValue() do
          begin
            key := toString();
            Free; //Fix memory leak. By creation_zy
          end;
      end
      end; //fim do case

      (*
       * The key is followed by ':'. We will also tolerate '=' or '=>'.
       *)

      c := x.nextClean();
      if (c = '=') then begin
          if (x.next() <> '>') then begin
              x.back();
          end;
      end else if (c <> ':') then begin
          raise x.syntaxError('Expected a ":" after a key');
      end;
      self.myHashMap.AddObject(key, x.nextValue());

      (*
       * Pairs are separated by ','. We will also tolerate ';'.
       *)

      case (x.nextClean()) of
      ';', ',': begin
          if (x.nextClean() = '}') then begin
              exit;
          end;
          x.back();
      end;
      '}': begin
          exit;
      end
      else begin
          raise x.syntaxError('Expected a "," or "}"');
      end
      end;
  end; //while

end;


(**
     * Accumulate values under a key. It is similar to the put method except
     * that if there is already an object stored under the key then a
     * TJSONArray is stored under the key to hold all of the accumulated values.
     * If there is already a TJSONArray, then the new value is appended to it.
     * In contrast, the put method replaces the previous value.
     * @param key   A key string.
     * @param value An object to be accumulated under the key.
     * @return this.
     * @throws NullPointerException if the key is null
     *)
function TJSONObject.accumulate(key: string; value: TZAbstractObject): TJSONObject;
var
 a: TJSONArray;
 o: TZAbstractObject;
begin
  {a := nil;}
  o := opt(key);
  if (o = nil) then begin
      put(key, value);
  end else if (o is TJSONArray) then begin
      a := TJSONArray(o);
      a.put(value);
  end else  begin
      a := TJSONArray.Create;
      a.put(o.Clone);
      a.put(value);
      put(key, a);
  end;
  Result := self;
end;


(**
     * Get the value object associated with a key.
     *
     * @param key   A key string.
     * @return      The object associated with the key.
     * @raises (NoSuchElementException if the key is not found.)
     *)
function TJSONObject.get(key: string): TZAbstractObject;
var
 o: TZAbstractObject;
begin
  o := opt(key);
  if (o = nil) then begin
      raise NoSuchElementException.Create('TJSONObject[' +
          quote(key) + '] not found.');
  end;
  Result := o;
end;


(**
     * Get the boolean value associated with a key.
     *
     * @param key   A key string.
     * @return      The truth.
     * @raises (NoSuchElementException if the key is not found.)
     * @raises (ClassCastException
     *  if the value is not a Boolean or the String "true" or "false".)
     *)
function TJSONObject.getBoolean(key: string): boolean;
var
 o: TZAbstractObject;
begin
    o := get(key);
    if (o.Equals(TJSONBool._FALSE) or
            ((o is TJSONString) and
            (TJSONString(o)).EqualsIgnoreCase('false'))) then begin
        Result := false;
        exit;
    end else if (o.Equals(TJSONBool._TRUE) or
            ((o is TJSONString) and
            (TJSONString(o)).EqualsIgnoreCase('true'))) then begin
        Result := true;
        exit;
    end;
    raise ClassCastException.Create('TJSONObject[' +
        quote(key) + '] is not a Boolean.');
end;

function TJSONObject.getDouble(key: string): double;
var
  o: TZAbstractObject;
begin
        o := get(key);
        if (o is TJSONNumber) then begin
            Result := TJSONNumber(o).doubleValue();
            exit;
        end;
        if (o is TJSONString) then begin
            Result := StrToFloat(TJSONString(o).toString(), getFormatSettings());
            exit;
        end;
        raise NumberFormatException.Create('TJSONObject[' +
            quote(key) + '] is not a number.');
end;


(**
     * Get the int value associated with a key.
     *
     * @param key   A key string.
     * @return      The integer value.
     * @raises (NoSuchElementException if the key is not found)
     * @raises (NumberFormatException
     *  if the value cannot be converted to a number.)
     *)
function TJSONObject.getInt(key: string): integer;
var
  o: TZAbstractObject;
begin
        o := get(key);
        if (o is TJSONNumber) then begin
           Result :=  TJSONNumber(o).intValue();
        end else begin
           Result :=  Round(getDouble(key));
        end;
       
end;


(**
     * Get the TJSONArray value associated with a key.
     *
     * @param key   A key string.
     * @return      A TJSONArray which is the value.
     * @raises (NoSuchElementException if the key is not found or
     *  if the value is not a TJSONArray.)
     *)
function TJSONObject.getJSONArray(key: string): TJSONArray;
var
 o: TZAbstractObject;
begin
  o := opt(key);
  if (o is TJSONArray) then begin
      Result := TJSONArray(o);
  end else begin
    raise  NoSuchElementException.Create('TJSONObject[' +
        quote(key) + '] is not a TJSONArray.');
  end;
end;


(**
     * Get the TJSONObject value associated with a key.
     *
     * @param key   A key string.
     * @return      A TJSONObject which is the value.
     * @raises (NoSuchElementException if the key is not found or
     *  if the value is not a TJSONObject.)
     *)
function TJSONObject.getJSONObject(key: string): TJSONObject;
var
 o: TZAbstractObject;
begin
  o := get(key);
  if (o is TJSONObject) then begin
      Result := TJSONObject(o);
  end else begin
    raise NoSuchElementException.Create('TJSONObject[' +
        quote(key) + '] is not a TJSONObject.');
  end;
end;


(**
     * Get the string associated with a key.
     *
     * @param key   A key string.
     * @return      A string which is the value.
     * @raises (NoSuchElementException if the key is not found.)
*)
function TJSONObject.getString(key: string): string;
begin
  Result := get(key).toString();
end;

function TJSONObject.getStringUtf8(key: string): string;
begin
  Result := Utf8ToAnsi( get(key).toString() );
end;


(**
     * Determine if the TJSONObject contains a specific key.
     * @param key   A key string.
     * @return      true if the key exists in the TJSONObject.
     *)
function TJSONObject.has(key: string): boolean;
begin
   Result := self.myHashMap.IndexOf(key) >= 0;
end;


(**
     * Determine if the value associated with the key is null or if there is
     *  no value.
     * @param key   A key string.
     * @return      true if there is no value associated with the key or if
     *  the value is the TJSONObject.NULL object.
     *)
function TJSONObject.isNull(key: string): boolean;
begin
   Result := ObjNULL.Equals(opt(key));
end;

function TJSONObject.keys: TStringList;
var
 i: integer;
begin
  Result := TStringList.Create;
  for i := 0 to myHashMap.Count -1 do begin
    Result.add(myHashMap[i]);
  end;
end;

function TJSONObject.length: integer;
begin
   Result := myHashMap.Count;
end;


(**
     * Produce a TJSONArray containing the names of the elements of this
     * TJSONObject.
     * @return A TJSONArray containing the key strings, or null if the TJSONObject
     * is empty.
     *)
function TJSONObject.names: TJSONArray;
var
  ja:TJSONArray;
  i: integer;
  k: TStringList;
begin
    ja := TJSONArray.Create;
    k := keys;
    try
      for i := 0 to k.Count -1 do begin
        ja.put(TJSONString.Create(k[i]));
      end;
      if (ja.length = 0) then begin
         Result := nil;
      end else begin
         Result := ja;
      end;
    finally
      k.free;
    end;
end;

class function TJSONObject.numberToString(n: TJSONNumber): string;
begin
   if (n = nil) then begin
     Result := '';
   end
   else begin
     Result :=  n.toString();
   end;
end;



function TJSONObject.opt(key: string): TZAbstractObject;
begin
   if (key = '') then begin
            raise NullPointerException.Create('Null key');
   end else begin
        if myHashMap.IndexOf(key) < 0 then begin
          Result := nil;
        end else begin
         Result :=  TZAbstractObject(myHashMap.Objects [myHashMap.IndexOf(key)]);
        end;
   end;
end;


(**
     * Get an optional boolean associated with a key.
     * It returns false if there is no such key, or if the value is not
     * Boolean.TRUE or the String "true".
     *
     * @param key   A key string.
     * @return      The truth.
     *)
function TJSONObject.optBoolean(key: string): boolean;
begin
  Result := optBoolean(key, false);
end;


(**
     * Get an optional boolean associated with a key.
     * It returns the defaultValue if there is no such key, or if it is not
     * a Boolean or the String "true" or "false" (case insensitive).
     *
     * @param key              A key string.
     * @param defaultValue     The default.
     * @return      The truth.
     *)
function TJSONObject.optBoolean(key: string; defaultValue: boolean): boolean;
var
  o: TZAbstractObject;
begin
  o := opt(key);
  if (o <> nil) then begin
      if (o.Equals(TJSONBool._FALSE) or
              ((o is TJSONString) and
              (TJSONString(o).EqualsIgnoreCase('false')))) then begin
          Result := false;
          exit;
      end else if (o.Equals(TJSONBool._TRUE) or
              ((o is TJSONString) and
              (TJSONString(o).EqualsIgnoreCase('true')))) then begin
          Result := true;
          exit;
      end;
  end;
  Result := defaultValue;
end;


(**
     * Get an optional double associated with a key,
     * or NaN if there is no such key or if its value is not a number.
     * If the value is a string, an attempt will be made to evaluate it as
     * a number.
     *
     * @param key   A string which is the key.
     * @return      An object which is the value.
     *)
function TJSONObject.optDouble(key: string): double;
begin
  Result := optDouble(key, TJSONDouble.NaN);
end;


(**
     * Get an optional double associated with a key, or the
     * defaultValue if there is no such key or if its value is not a number.
     * If the value is a string, an attempt will be made to evaluate it as
     * a number.
     *
     * @param key   A key string.
     * @param defaultValue     The default.
     * @return      An object which is the value.
     *)
function TJSONObject.optDouble(key: string; defaultValue: double): double;
var
 o: TZAbstractObject;
begin
    o := opt(key);
    if (o <> nil) then begin
        if (o is TJSONNumber) then begin
            Result := (TJSONNumber(o)).doubleValue();
            exit;
        end;
        try
            Result := TJSONDouble.Create(TJSONString(o)).doubleValue();
            exit;
          except on e:Exception  do begin
            Result := defaultValue;
            exit;
          end;
        end;
    end;
    Result := defaultValue;
end;

(**
     * Get an optional int value associated with a key,
     * or zero if there is no such key or if the value is not a number.
     * If the value is a string, an attempt will be made to evaluate it as
     * a number.
     *
     * @param key   A key string.
     * @return      An object which is the value.
     *)
function TJSONObject.optInt(key: string): integer;
begin
  Result := optInt(key, 0);
end;


(**
     * Get an optional int value associated with a key,
     * or the default if there is no such key or if the value is not a number.
     * If the value is a string, an attempt will be made to evaluate it as
     * a number.
     *
     * @param key   A key string.
     * @param defaultValue     The default.
     * @return      An object which is the value.
     *)
function TJSONObject.optInt(key: string; defaultValue: integer): integer;
var
  o: TZAbstractObject;
begin
  o := opt(key);
  if (o <> ObjNULL) then begin
      if (o is TJSONNumber) then begin
          Result := (TJSONNumber(o)).intValue();
          exit;
      end;
      try
          Result := TJSONInteger.parseInt(TJSONString(o));
          exit;
        except on e:Exception  do begin
          Result := defaultValue;
          exit;
        end;
      end;
  end;
  Result := defaultValue;
end;




(**
     * Get an optional TJSONArray associated with a key.
     * It returns null if there is no such key, or if its value is not a
     * TJSONArray.
     *
     * @param key   A key string.
     * @return      A TJSONArray which is the value.
     *)
function TJSONObject.optJSONArray(key: string): TJSONArray;
var
 o: TZAbstractObject;
begin
    o := opt(key);
    if (o is TJSONArray) then begin
      Result := TJSONArray(o);
    end else begin
      Result := nil;
    end;
end;


(**
     * Get an optional TJSONObject associated with a key.
     * It returns null if there is no such key, or if its value is not a
     * TJSONObject.
     *
     * @param key   A key string.
     * @return      A TJSONObject which is the value.
     *)
function TJSONObject.optJSONObject(key: string): TJSONObject;
var
 o: TZAbstractObject;
begin
  o := opt(key);
  if (o is TJSONObject) then begin
      Result := TJSONObject(o);
    end else begin
      Result := nil;
    end;
end;

(**
     * Get an optional string associated with a key.
     * It returns an empty string if there is no such key. If the value is not
     * a string and is not null, then it is coverted to a string.
     *
     * @param key   A key string.
     * @return      A string which is the value.
     *)
function TJSONObject.optString(key: string): string;
begin
  Result := optString(key, '');
end;

(**
     * Get an optional string associated with a key.
     * It returns the defaultValue if there is no such key.
     *
     * @param key   A key string.
     * @param defaultValue     The default.
     * @return      A string which is the value.
     *)
function TJSONObject.optString(key, defaultValue: string): string;
var
 o: TZAbstractObject;
begin
  o := opt(key);
  if (o <> nil) then begin
      Result := o.toString();
    end else begin
      Result := defaultValue;
    end;
end;

(**
     * Put a key/boolean pair in the TJSONObject.
     *
     * @param key   A key string.
     * @param value A boolean which is the value.
     * @return this.
     *)
function TJSONObject.put(key: string; value: boolean): TJSONObject;
begin
   put(key, TJSONBool.valueOf(value));
   Result := self;
end;

(**
     * Put a key/double pair in the TJSONObject.
     *
     * @param key   A key string.
     * @param value A double which is the value.
     * @return this.
     *)
function TJSONObject.put(key: string; value: double): TJSONObject;
begin
   put(key, TJSONDouble.Create(value));
   Result := self;
end;


(**
     * Put a key/int pair in the TJSONObject.
     *
     * @param key   A key string.
     * @param value An int which is the value.
     * @return this.
     *)
function TJSONObject.put(key: string; value: integer): TJSONObject;
begin
   put(key, TJSONInteger.Create(value));
   Result := self;
end;


(**
     * Put a key/value pair in the TJSONObject. If the value is null,
     * then the key will be removed from the TJSONObject if it is present.
     * @param key   A key string.
     * @param value An object which is the value. It should be of one of these
     *  types: Boolean, Double, Integer, TJSONArray, TJSONObject, String, or the
     *  TJSONObject.NULL object.
     * @return this.
     * @raises (NullPointerException The key must be non-null.)
     *)
function TJSONObject.put(key: string; value: TZAbstractObject): TJSONObject;
var
  temp: TObject;
  i: integer;
begin
    if (key = '') then begin
            raise NullPointerException.Create('Null key.');
    end;
    if (value <> nil) then begin
        i := self.myHashMap.IndexOf(key);
        if ( i >= 0) then begin
          temp := self.myHashMap.Objects [i];
          self.myHashMap.Objects[i]  := value;
          temp.free;
        end else begin
        self.myHashMap.AddObject(key, value);
        end;
    end else begin
        temp := remove(key);
        if (temp <> nil) then  begin
          temp.free;
        end;
    end;
    Result := self;
end;

function TJSONObject.put(key, value: string): TJSONObject;
begin
   put(key, TJSONString.Create(value));
   Result := self;
end;
function TJSONObject.putOpt(key: string; value: TZAbstractObject): TJSONObject;
begin
   if (value <> nil) then begin
    put(key, value);
   end;
   Result := self;
end;


(**
     * Produce a string in double quotes with backslash sequences in all the
     * right places.
     * @param string A String
     * @return  A String correctly formatted for insertion in a JSON message.
     *)
class function TJSONObject.quote(s: string): string;
var
   b,c: char;
   i, len: integer;
   sb, t: string;
const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')'];
begin
        if ((s = '') or (System.Length(s) = 0)) then begin
            Result :=  '""';
        end;

        {b := #0;}
        c := #0;
        {i := 0;}
        len := System.length(s);
        //SetLength(s, len+4);
        t := '';

        sb := sb +'"';
        for i := 1 to len do begin
            b := c;
            c := s[i];
            case (c) of
            '\', '"': begin
                sb := sb + '\';
                sb := sb + c;
            end;
            '/': begin
                if (b = '<') then begin
                    sb := sb + '\';
                end;
                sb := sb + c;
            end;
            #8:  begin
                sb := sb + '\b';
            end;
            #9:  begin
                sb := sb + '\t';
            end;
            #10:  begin
                sb := sb + '\n';
            end;
            #12:  begin
                sb := sb + '\f';
            end;
            #13:  begin
                sb := sb + '\r';
            end;
            else begin
                if (not (c in NoConversion)) then begin
                    t := '000' + TJSONInteger.toHexString(c);
                    sb := sb + '\u' + copy(t,System.length(t)-3,4);
                end else begin
                    sb := sb + c;
                end;
            end;
            end;
        end;
        sb := sb + '"';
        Result := sb;
end;

(**
     * Remove a name and its value, if present.
     * @param key The name to be removed.
     * @return The value that was associated with the name,
     * or null if there was no value.
     *)
function TJSONObject.remove(key: string): TZAbstractObject;
begin
  if ( myHashMap.IndexOf(key) < 0) then begin
    Result := nil
  end else begin
   Result := TZAbstractObject(myHashMap.Objects [myHashMap.IndexOf(key)]);
   self.myHashMap.delete(myHashMap.IndexOf(key));
  end;
end;

(**
     * Produce a TJSONArray containing the values of the members of this
     * TJSONObject.
     * @param names A TJSONArray containing a list of key strings. This
     * determines the sequence of the values in the result.
     * @return A TJSONArray of values.
     *)
function TJSONObject.toJSONArray(names: TJSONArray): TJSONArray;
var
 i: integer;
 ja: TJSONArray;
begin
  if ((names = nil) or (names.length() = 0)) then begin
      Result := nil;
      exit;
  end;
   ja := TJSONArray.Create;
  for i := 0 to names.length -1 {; i < names.length(); i += 1)} do begin
      ja.put(self.opt(names.getString(i)));
  end;
  Result := ja;
end;


(**
     * Make an JSON external form string of this TJSONObject. For compactness, no
     * unnecessary whitespace is added.
     * <p>
     * Warning: This method assumes that the data structure is acyclical.
     *
     * @return a printable, displayable, portable, transmittable
     *  representation of the object, beginning
     *  with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     *  with <code>}</code>&nbsp;<small>(right brace)</small>.
     *)
function TJSONObject.toString: string;
var
 _keys: TStringList;
 sb: string;
 o: string;
 i:integer;
begin
      _keys := keys();
      try
          sb := '{';

          for i := 0 to _keys.count -1 do begin
              if (System.length(sb) > 1) then begin
                  sb:= sb + ',';
              end;
              o := _keys[i];
              sb := sb + quote(o);
              sb := sb + ':';
              sb:= sb + valueToString(TZAbstractObject(myHashMap.Objects[myHashMap.IndexOf(o)]));
          end;
          sb := sb + '}';
          Result := sb;
      finally
        _keys.free;
      end;
end;


(**
     * Make a prettyprinted JSON external form string of this TJSONObject.
     * <p>
     * Warning: This method assumes that the data structure is acyclical.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @return a printable, displayable, portable, transmittable
     *  representation of the object, beginning
     *  with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     *  with <code>}</code>&nbsp;<small>(right brace)</small>.
     *)
function TJSONObject.toString(indentFactor: integer): string;
begin
  Result := toString(indentFactor, 0);
end;

(**
     * Make a prettyprinted JSON string of this TJSONObject.
     * <p>
     * Warning: This method assumes that the data structure is acyclical.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @param indent The indentation of the top level.
     * @return a printable, displayable, transmittable
     *  representation of the object, beginning
     *  with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     *  with <code>}</code>&nbsp;<small>(right brace)</small>.
     *)
function TJSONObject.toString(indentFactor, indent: integer): string;
var
 j , i , n , newindent: integer;
 _keys: TStringList;
 o, sb: string;
begin
  {i := 0;}
  n := length();
  if (n = 0) then begin
      Result := '{}';
      exit;
  end;
  _keys := keys();
  try
      sb := sb + '{';
      newindent := indent + indentFactor;
      if (n = 1) then begin
          o := _keys[0];
          sb:= sb + quote(o);
          sb:= sb + ': ';
          sb:= sb + valueToString(TZAbstractObject(myHashMap
          .Objects[myHashMap.IndexOf(o)])
          , indentFactor, indent);
      end else begin
          for j := 0 to _keys.count -1 do begin
              o := _keys[j];
              if (System.length(sb) > 1) then begin
                  sb := sb + ','+ #10;
              end else begin
                  sb:= sb + #10;
              end;
              for i := 0 to newindent -1  do begin
                  sb:= sb + ' ';
              end;
              sb:= sb + quote(o);
              sb:= sb + ': ';
              sb:= sb + valueToString(TZAbstractObject(myHashMap
              .Objects[myHashMap.IndexOf(o)])
              , indentFactor, newindent);
          end;
          if (System.length(sb) > 1) then begin
              sb := sb + #10;
              for i := 0 to indent -1 do begin
                  sb:= sb + ' ';
              end;
          end;
      end;
      sb:= sb + '}';
      Result :=  sb;
  finally
      _keys.Free; 
  end;
end;

class function TJSONObject.ObjNULL: TJSONNull;
begin
  Result := CNULL;
end;


class function TJSONObject.valueToString(value: TZAbstractObject): string;
begin
  if ((value = nil) or (value.Equals(ObjNULL))) then begin
      Result := 'null';
      exit;
  end;
  if (value is TJSONNumber) then begin
      Result := numberToString(TJSONNumber(value));
      exit;
  end;
  if ((value is TJSONBool) or (value is TJSONObject) or
          (value is TJSONArray)) then begin
      Result := value.toString();
      exit;
  end;
  Result := quote(value.toString());
end;


(**
     * Make a prettyprinted JSON string of an object value.
     * <p>
     * Warning: This method assumes that the data structure is acyclical.
     * @param value The value to be serialized.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @param indent The indentation of the top level.
     * @return a printable, displayable, transmittable
     *  representation of the object, beginning
     *  with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     *  with <code>}</code>&nbsp;<small>(right brace)</small>.
     *)
class function TJSONObject.valueToString(value: TZAbstractObject;
  indentFactor, indent: integer): string;
begin
   if ((value = nil) or (value.Equals(nil))) then begin
        Result := 'null';
        exit;
    end;
    if (value is TJSONNumber) then begin
        Result := numberToString(TJSONNumber(value));
        exit;
    end;
    if (value is TJSONBool) then begin
        Result :=  value.toString();
        exit;
    end;
    if (value is TJSONObject) then begin
        Result := ((TJSONObject(value)).toString(indentFactor, indent));
        exit;
    end;
    if (value is TJSONArray) then begin
        Result := ((TJSONArray(value)).toString(indentFactor, indent));
        exit;
    end;
    Result := quote(value.toString());
end;

{ TJSONBool }

function TJSONBool.Clone: TZAbstractObject;
begin
  Result := TJSONBool.Create(Self.FValue);
end;

constructor TJSONBool.Create(b: boolean);
begin
   FValue := b;
end;


var
  CONST_FALSE: TJSONBool;
  CONST_TRUE : TJSONBool;
function TJSONBool.toString: string;
begin
  if FValue then begin
    Result := 'true';
  end else begin
    Result := 'false';
  end;
end;

class function TJSONBool.valueOf(b: boolean): TJSONBool;
begin
 if (b) then begin
    Result := _TRUE;
 end else begin
    Result := _FALSE;
 end;
end;

class function TJSONBool._FALSE: TJSONBool;
begin
  Result := CONST_FALSE;
end;

class function TJSONBool._TRUE: TJSONBool;
begin
  Result := CONST_TRUE;
end;

{ TJSONString }

function TJSONString.Clone: TZAbstractObject;
begin
  Result := TJSONString.Create(self.FValue);
end;

constructor TJSONString.Create(s: string);
begin
  FValue := s;
end;


function TJSONString.Equals(const Value: TZAbstractObject): Boolean;
begin
    Result := (value is TJSONString) and (TJSONString(value).FValue = FValue);
end;

function TJSONString.EqualsIgnoreCase(s: string): boolean;
begin
   Result := AnsiLowerCase(s) = AnsiLowerCase(FValue);
end;

function TJSONString.toString: string;
begin
  Result := FValue;
end;

{ ParseException }

constructor ParseException.Create(_message: string; index: real);
begin
   inherited CreateFmt(_message+#10#13' erro no caracter : %d',[index]);
end;

{ TJSONInteger }

constructor TJSONInteger.Create(i: integer);
begin
  FValue := i;
end;

function TJSONInteger.Clone: TZAbstractObject;
begin
  Result := TJSONInteger.Create(self.FValue);
end;

constructor TJSONInteger.Create(s: string);
begin
  FValue := strToInt(s);
end;

function TJSONInteger.doubleValue: double;
begin
  Result := FValue;
end;

function TJSONInteger.intValue: integer;
begin
  Result := FValue;
end;

class function TJSONInteger.parseInt(s: string; i: integer): integer;
var Ans: Integer;
begin
  Ans := 0;
  case i of
  10: Ans := strToInt(s);
  16: Ans := hexToInt(s);
  8 : 
    begin
      if (s = '0') then begin
        Ans := 0
      end else begin
        newNotImplmentedFeature();
      end; 
    end;
  else
    Ans := 0;
  end;
  Result := Ans;  
end;

class function TJSONInteger.parseInt(s: TJSONString): integer;
begin
  Result := TJSONInteger.parseInt(s.toString, 10);
end;

class function TJSONInteger.toHexString(c: char): string;
begin
  Result := IntToHex(ord(c),2);
end;

function TJSONInteger.toString: string;
begin
  Result := intToStr(FValue);
end;


{ TJSONDouble }

constructor TJSONDouble.Create(s: string);
begin
  FValue := StrToFloat(s, getFormatSettings);
end;

constructor TJSONDouble.Create(s: TJSONString);
begin
  Create(s.toString);
end;

constructor TJSONDouble.Create(d: double);
begin
  FValue := d;
end;

function TJSONDouble.Clone: TZAbstractObject;
begin
  Result := TJSONDouble.Create(Self.FValue);
end;

function TJSONDouble.doubleValue: double;
begin
  Result := FValue;
end;

function TJSONDouble.intValue: integer;
begin
  Result := trunc(FValue);
end;

class function TJSONDouble.NaN: double;
begin
  Result := 3.6e-4951;
end;

function TJSONDouble.toString: string;
begin
  {Result := '"'+StringReplace(formatFloat('######0.00',FValue),',','.',[rfReplaceAll])+'"';}
  Result := StringReplace( FormatFloat(FStrFloatFmt, FValue),
                           ',', '.', [rfReplaceAll] );
end;

{ TJSONArray }

(**
     * Construct a TJSONArray from a JSONTokener.
     * @param x A JSONTokener
     * @raises (ParseException A TJSONArray must start with '[')
     * @raises (ParseException Expected a ',' or ']')
     *)
constructor TJSONArray.Create(x: JSONTokener);
begin
  Create;
  if (x.nextClean() <> '[') then begin
      raise x.syntaxError('A TJSONArray must start with "["');
  end;
  if (x.nextClean() = ']') then begin
      exit;
  end;
  x.back();
  while (true) do begin
      if (x.nextClean() = ',') then begin
          x.back();
          myArrayList.add(nil);
      end else begin
          x.back();
          myArrayList.add(x.nextValue());
      end;
      case (x.nextClean()) of
      ';',',': begin
          if (x.nextClean() = ']') then begin
              exit;
          end;
          x.back();
      end;
      ']': begin
          exit;
      end else begin
         raise x.syntaxError('Expected a "," or "]"');
      end
      end;
  end;
end;

destructor TJSONObject.Destroy;
begin
  clean;
  myHashMap.Free;
  inherited;
end;

(**
     * Construct a TJSONArray from a Collection.
     * @param collection     A Collection.
     *)
constructor TJSONArray.Create(collection: TList);
var
  i: integer;
begin
  myArrayList := TList.Create();
  for i := 0 to collection.count -1 do begin
     myArrayList.add(collection[i]);
  end;
end;

(**
 * Construct an empty TJSONArray.
*)
constructor TJSONArray.Create;
begin
   myArrayList := TList.Create;
end;


(**
     * Construct a TJSONArray from a source string.
     * @param string     A string that begins with
     * <code>[</code>&nbsp;<small>(left bracket)</small>
     *  and ends with <code>]</code>&nbsp;<small>(right bracket)</small>.
     *  @raises (ParseException The string must conform to JSON syntax.)
     *)
constructor TJSONArray.Create(s: string);
begin
  Create(JSONTokener.Create(s));
end;

destructor TJSONArray.Destroy;
var
 {i: integer;}
 obj: TObject;
begin
  while myArrayList.Count > 0 do begin
    obj := myArrayList [0];
    myArrayList [0] := nil;
    if (obj <> CONST_FALSE)
      and (obj <> CONST_TRUE)
      and (obj <> CNULL) then begin
        obj.Free;
    end;
    myArrayList.Delete(0);
  end;
  myArrayList.Free;
  inherited;
end;


(**
     * Get the object value associated with an index.
     * @param index
     *  The index must be between 0 and length() - 1.
     * @return An object value.
     * @raises (NoSuchElementException)
     *)
function TJSONArray.get(index: integer): TZAbstractObject;
var
  o: TZAbstractObject;
begin
  o := opt(index);
  if (o = nil) then begin
      raise NoSuchElementException.Create('TJSONArray[' + intToStr(index)
        + '] not found.');
  end;
  Result := o;
end;


(**
     * Get the boolean value associated with an index.
     * The string values "true" and "false" are converted to boolean.
     *
     * @param index The index must be between 0 and length() - 1.
     * @return      The truth.
     * @raises (NoSuchElementException if the index is not found)
     * @raises (ClassCastException)
     *)
function TJSONArray.getBoolean(index: integer): boolean;
var
  o: TZAbstractObject;
begin
  o := get(index);
  if ((o.Equals(TJSONBool._FALSE) or
          ((o is TJSONString) and
          (TJSONString(o)).EqualsIgnoreCase('false')))) then begin
      Result := false;
      exit;
  end else if ((o.Equals(TJSONBool._TRUE) or
          ((o is TJSONString) and
          (TJSONString(o)).EqualsIgnoreCase('true')))) then begin
      Result := true;
      exit;
  end;
  raise ClassCastException.Create('TJSONArray[' + intToStr(index) +
      '] not a Boolean.');
end;

(**
     * Get the double value associated with an index.
     *
     * @param index The index must be between 0 and length() - 1.
     * @return      The value.
     * @raises (NoSuchElementException if the key is not found)
     * @raises (NumberFormatException
     *  if the value cannot be converted to a number.)
     *)
function TJSONArray.getDouble(index: integer): double;
var
  o: TZAbstractObject;
  d: TJSONDouble;
begin
  o := get(index);
  if (o is TJSONNumber) then begin
      Result := (TJSONNumber(o)).doubleValue();
      exit;
  end;
  if (o is TJSONString) then begin
      d :=  TJSONDouble.Create(TJSONString(o));
      try
       Result := d.doubleValue();
       exit;
      finally
       d.Free;
      end; 
  end;
  raise NumberFormatException.Create('TJSONObject['
     + intToStr(index) + '] is not a number.');
end;


(**
     * Get the int value associated with an index.
     *
     * @param index The index must be between 0 and length() - 1.
     * @return      The value.
     * @raises (NoSuchElementException if the key is not found)
     * @raises (NumberFormatException
     *  if the value cannot be converted to a number.)
     *)
function TJSONArray.getInt(index: integer): integer;
var
  o: TZAbstractObject;
begin
  o := get(index);
  if (o is TJSONNumber) then begin
    Result := TJSONNumber(o).intValue();
  end else begin
    Result := trunc(getDouble(index));
  end;
end;


{
     * Get the TJSONArray associated with an index.
     * @param index The index must be between 0 and length() - 1.
     * @return      A TJSONArray value.
     * @raises (NoSuchElementException if the index is not found or if the
     * value is not a TJSONArray)     }
function TJSONArray.getJSONArray(index: integer): TJSONArray;
var
 o: TZAbstractObject;
begin
  o := get(index);
  if (o is TJSONArray) then begin
      Result := TJSONArray(o);
      exit;
  end;
  raise NoSuchElementException.Create('TJSONArray[' + intToStr(index) +
          '] is not a TJSONArray.');
end;


(**
     * Get the TJSONObject associated with an index.
     * @param index subscript
     * @return      A TJSONObject value.
     * @raises (NoSuchElementException if the index is not found or if the
     * value is not a TJSONObject)
     *)
function TJSONArray.getJSONObject(index: integer): TJSONObject;
var
  o: TZAbstractObject;
  s: string;
begin
  o := get(index);
  if (o is TJSONObject) then begin
      Result := TJSONObject(o);
  end else begin
      if o <> nil then begin
        s := o.ClassName;
      end else begin
        s := 'nil';
      end;
      raise NoSuchElementException.Create('TJSONArray[' + intToStr(index) +
        '] is not a TJSONObject is ' + s);
  end;
end;

(**
     * Get the string associated with an index.
     * @param index The index must be between 0 and length() - 1.
     * @return      A string value.
     * @raises (NoSuchElementException)
     *)
function TJSONArray.getString(index: integer): string;
begin
  Result := get(index).toString();
end;

function TJSONArray.getStringUtf8(index: integer): string;
begin
  Result := Utf8ToAnsi( get(index).toString() );
end;

(**
 * Determine if the value is null.
 * @param index The index must be between 0 and length() - 1.
 * @return true if the value at the index is null, or if there is no value.
 *)

function TJSONArray.isNull(index: integer): boolean;
var
 o: TZAbstractObject;
begin
    o := opt(index);
    Result := (o = nil) or (o.Equals(nil));
end;

(**
 * Make a string from the contents of this TJSONArray. The separator string
 * is inserted between each element.
 * Warning: This method assumes that the data structure is acyclical.
 * @param separator A string that will be inserted between the elements.
 * @return a string.
 *)
function TJSONArray.join(separator: string): string;
var
  len, i: integer;
  sb, s: string;
begin
		len := length();
    sb := '';
    for i := 0 to len -1 do begin
        if (i > 0) then begin
            sb := sb + separator;
        end;
        s := TJSONObject.valueToString(TZAbstractObject( myArrayList[i]));
        sb:= sb + s;
    end;
    Result := sb;
end;

(**
 * Get the length of the TJSONArray.
 *
 * @return The length (or size).
 *)
function TJSONArray.length: integer;
begin
  Result := myArrayList.Count;
end;

 {
      Get the optional object value associated with an index.
      @param index The index must be between 0 and length() - 1.
      @return      An object value, or null if there is no
                   object at that index.
     }
function TJSONArray.opt(index: integer): TZAbstractObject;
begin
    if ((index < 0) or (index >= length()) ) then begin
       Result := nil;
    end else begin
      Result := TZAbstractObject(myArrayList[index]);
    end;
end;

(**
     * Get the optional boolean value associated with an index.
     * It returns false if there is no value at that index,
     * or if the value is not Boolean.TRUE or the String "true".
     *
     * @param index The index must be between 0 and length() - 1.
     * @return      The truth.
     *)
function TJSONArray.optBoolean(index: integer): boolean;
begin
  Result := optBoolean(index, false);
end;

(**
     * Get the optional boolean value associated with an index.
     * It returns the defaultValue if there is no value at that index or if it is not
     * a Boolean or the String "true" or "false" (case insensitive).
     *
     * @param index The index must be between 0 and length() - 1.
     * @param defaultValue     A boolean default.
     * @return      The truth.
     *)
function TJSONArray.optBoolean(index: integer;
  defaultValue: boolean): boolean;
var
 o: TZAbstractObject;
begin
  o := opt(index);
  if (o <> nil) then begin
      if ((o.Equals(TJSONBool._FALSE) or
              ((o is TJSONString) and
              (TJSONString(o)).EqualsIgnoreCase('false')))) then begin
          Result := false;
          exit;
      end else if ((o.Equals(TJSONBool._TRUE) or
              ((o is TJSONString) and
              (TJSONString(o)).EqualsIgnoreCase('true')))) then begin
          Result := true;
          exit;
      end;
  end;
  Result := defaultValue;
end;


(**
 * Get the optional double value associated with an index.
 * NaN is returned if the index is not found,
 * or if the value is not a number and cannot be converted to a number.
 *
 * @param index The index must be between 0 and length() - 1.
 * @return      The value.
 *)
function TJSONArray.optDouble(index: integer): double;
begin
   Result := optDouble(index, TJSONDouble.NaN);
end;

(**
 * Get the optional double value associated with an index.
 * The defaultValue is returned if the index is not found,
 * or if the value is not a number and cannot be converted to a number.
 *
 * @param index subscript
 * @param defaultValue     The default value.
 * @return      The value.
 *)
function TJSONArray.optDouble(index: integer; defaultValue:double): double;
var
 o: TZAbstractObject;
 d: TJSONDouble;
begin
  o := opt(index);
  if (o <> nil) then begin
      if (o is TJSONNumber) then begin
          Result := (TJSONNumber(o)).doubleValue();
          exit;
      end;
      try
          d := TJSONDouble.Create(TJSONString(o));
          Result := d.doubleValue;
          d.Free;
	        exit;
      except
        on e:Exception  do begin
          Result := defaultValue;
        end;
      end;
  end;
  Result := defaultValue;
end;

(**
 * Get the optional int value associated with an index.
 * Zero is returned if the index is not found,
 * or if the value is not a number and cannot be converted to a number.
 *
 * @param index The index must be between 0 and length() - 1.
 * @return      The value.
 *)
function TJSONArray.optInt(index: integer): integer;
begin
  Result := optInt(index, 0);
end;


(**
 * Get the optional int value associated with an index.
 * The defaultValue is returned if the index is not found,
 * or if the value is not a number and cannot be converted to a number.
 * @param index The index must be between 0 and length() - 1.
 * @param defaultValue     The default value.
 * @return      The value.
 *)
function TJSONArray.optInt(index, defaultValue: integer): integer;
var
  o: TZAbstractObject;
begin
  o := opt(index);
  if (o <> nil) then begin
      if (o is TJSONNumber) then begin
          Result :=  (TJSONNumber(o)).intValue();
          exit;
      end;
      try
        Result := TJSONInteger.parseInt(TJSONString(o));
        exit;
      except on e: exception do begin
        Result := defaultValue;
        exit;
      end;
      end;
  end;
  Result := defaultValue;
end;


(**
 * Get the optional TJSONArray associated with an index.
 * @param index subscript
 * @return      A TJSONArray value, or null if the index has no value,
 * or if the value is not a TJSONArray.
 *)
function TJSONArray.optJSONArray(index: integer): TJSONArray;
var
 o: TZAbstractObject;
begin
  o := opt(index);
  if (o is TJSONArray) then begin
    Result := TJSONArray(o);
  end else begin
    Result := nil;
  end;
end;

(**
 * Get the optional TJSONObject associated with an index.
 * Null is returned if the key is not found, or null if the index has
 * no value, or if the value is not a TJSONObject.
 *
 * @param index The index must be between 0 and length() - 1.
 * @return      A TJSONObject value.
 *)
function TJSONArray.optJSONObject(index: integer): TJSONObject;
var
  o: TZAbstractObject;
begin
  o := opt(index);
  if (o is TJSONObject) then begin
      Result := TJSONObject(o);
  end else begin
      Result := nil;
  end;
end;


(**
 * Get the optional string value associated with an index. It returns an
 * empty string if there is no value at that index. If the value
 * is not a string and is not null, then it is coverted to a string.
 *
 * @param index The index must be between 0 and length() - 1.
 * @return      A String value.
 *)
function TJSONArray.optString(index: integer): string;
begin
  Result := optString(index, '');
end;

(**
 * Get the optional string associated with an index.
 * The defaultValue is returned if the key is not found.
 *
 * @param index The index must be between 0 and length() - 1.
 * @param defaultValue     The default value.
 * @return      A String value.
 *)
function TJSONArray.optString(index: integer; defaultValue: string): string;
var
  o: TZAbstractObject;
begin
  o := opt(index);
  if (o <> nil) then begin
     Result := o.toString();
  end else begin
     Result := defaultValue;
  end;
end;



(**
 * Append a boolean value.
 *
 * @param value A boolean value.
 * @return this.
 *)
function TJSONArray.put(value: boolean): TJSONArray;
begin
  put(TJSONBool.valueOf(value));
  Result :=  self;
end;

(**
 * Append a double value.
 *
 * @param value A double value.
 * @return this.
 *)
function TJSONArray.put(value: double): TJSONArray;
begin
    put(TJSONDouble.Create(value));
    Result := self;
end;

(**
 * Append an int value.
 *
 * @param value An int value.
 * @return this.
 *)
function TJSONArray.put(value: integer): TJSONArray;
begin
  put(TJSONInteger.Create(value));
  Result := self;
end;


function TJSONArray.put(value: string): TJSONArray;
begin
    put(TJSONString.Create(value));
    Result := self;
end;


(**
 * Append an object value.
 * @param value An object value.  The value should be a
 *  Boolean, Double, Integer, TJSONArray, JSObject, or String, or the
 *  TJSONObject.NULL object.
 * @return this.
 *)
function TJSONArray.put(value: TZAbstractObject): TJSONArray;
begin
    myArrayList.add(value);
    Result := self;
end;

(**
 * Put or replace a boolean value in the TJSONArray.
 * @param index subscript The subscript. If the index is greater than the length of
 *  the TJSONArray, then null elements will be added as necessary to pad
 *  it out.
 * @param value A boolean value.
 * @return this.
 * @raises (NoSuchElementException The index must not be negative.)
 *)
function TJSONArray.put(index: integer; value: boolean): TJSONArray;
begin
  put(index, TJSONBool.valueOf(value));
  Result := self;
end;

function TJSONArray.put(index, value: integer): TJSONArray;
begin
  put(index, TJSONInteger.Create(value));
  Result := self;
end;


function TJSONArray.put(index: integer; value: double): TJSONArray;
begin
  put(index, TJSONDouble.Create(value));
  Result := self;
end;

function TJSONArray.put(index: integer; value: string): TJSONArray;
begin
  put(index,TJSONString.Create(value));
  Result := self;
end;

(**
     * Put or replace an object value in the TJSONArray.
     * @param index The subscript. If the index is greater than the length of
     *  the TJSONArray, then null elements will be added as necessary to pad
     *  it out.
     * @param value An object value.
     * @return this.
     * @raises (NoSuchElementException The index must not be negative.)
     * @raises (NullPointerException   The index must not be null.)
     *)
function TJSONArray.put(index: integer; value: TZAbstractObject): TJSONArray;
begin
    if (index < 0) then begin
        raise NoSuchElementException.Create('TJSONArray['
          + intToStr(index) + '] not found.');
    end else if (value = nil) then begin
        raise NullPointerException.Create('');
    end else if (index < length()) then begin
        myArrayList[index] := value;
    end else begin
        while (index <> length()) do begin
            put(nil);
        end;
        put(value);
    end;
    Result := self;
end;

(**
 * Produce a TJSONObject by combining a TJSONArray of names with the values
 * of this TJSONArray.
 * @param names A TJSONArray containing a list of key strings. These will be
 * paired with the values.
 * @return A TJSONObject, or null if there are no names or if this TJSONArray
 * has no values.
 *)
function TJSONArray.toJSONObject(names:TJSONArray): TJSONObject;
var
  jo: TJSONObject;
  i: integer;
begin
  if ((names = nil) or (names.length() = 0) or (length() = 0)) then begin
      Result := nil;
  end;
  jo := TJSONObject.Create();
  for i := 0 to names.length() do begin
      jo.put(names.getString(i), self.opt(i));
  end;
  Result := jo;
end;


(**
 * Make an JSON external form string of this TJSONArray. For compactness, no
 * unnecessary whitespace is added.
 * Warning: This method assumes that the data structure is acyclical.
 *
 * @return a printable, displayable, transmittable
 *  representation of the array.
 *)
function TJSONArray.toString: string;
begin
   Result := '[' + join(',') + ']';
end;

(**
     * Make a prettyprinted JSON string of this TJSONArray.
     * Warning: This method assumes that the data structure is non-cyclical.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @return a printable, displayable, transmittable
     *  representation of the object, beginning
     *  with <code>[</code>&nbsp;<small>(left bracket)</small> and ending
     *  with <code>]</code>&nbsp;<small>(right bracket)</small>.
     *)
function TJSONArray.toString(indentFactor: integer): string;
begin
  Result := toString(indentFactor, 0);
end;

(**
  * Make a TList of TJSONArray;
  * @return a TList object
*)
function TJSONArray.toList: TList;
begin
  Result := TList.Create;
  Result.Assign(myArrayList,laCopy);
end;

(**
     * Make a prettyprinted string of this TJSONArray.
     * Warning: This method assumes that the data structure is non-cyclical.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @param indent The indention of the top level.
     * @return a printable, displayable, transmittable
     *  representation of the array.
     *)
function TJSONArray.toString(indentFactor, indent: integer): string;
var
  len, i,j, newindent: integer;
  sb: string;
begin
  len := length();
  if (len = 0) then begin
      Result := '[]';
      exit;
  end;
  {i := 0;}
  sb := '[';
  if (len = 1) then begin
      sb := sb + TJSONObject
      .valueToString(TZAbstractObject( myArrayList[0]),indentFactor, indent);
  end else begin
      newindent := indent + indentFactor;
      sb := sb + #10;
      for i := 0 to len -1 do begin
          if (i > 0) then begin
              sb := sb +',' + #10;
          end;
          for j := 0 to newindent-1 do begin
              sb := sb + ' ';
          end;
          sb := sb + (TJSONObject
            .valueToString(TZAbstractObject(myArrayList[i]),
                  indentFactor, newindent));
      end;
      sb := sb + #10;
      for i := 0 to indent-1 do begin
          sb := sb + ' ';
      end;
  end;
  sb := sb + ']';
  Result := sb;
end;


{ TJSONNull }

function TJSONNull.Equals(const Value: TZAbstractObject): Boolean;
begin
  if (value = nil) then begin
    Result := true;
  end else begin
    Result := (value is TJSONNull);
  end;
end;

function TJSONNull.toString: string;
begin
  Result := 'null';
end;


{ TZAbstractObject }

function TZAbstractObject.Clone: TZAbstractObject;
begin
  newNotImplmentedFeature();
end;

function TZAbstractObject.Equals(const Value: TZAbstractObject): Boolean;
begin
  Result := (value <> nil) and (value = self);
end;

function TZAbstractObject.Hash: LongInt;
begin
  Result := integer(addr(self));
end;

function TZAbstractObject.InstanceOf(
  const Value: TZAbstractObject): Boolean;
begin
  Result := value is TZAbstractObject;
end;

function TZAbstractObject.ToString: string;
begin
 Result := Format('%s <%p>', [ClassName, addr(Self)]);
end;

procedure TJSONObject.clean;
begin
  while myHashMap.Count > 0 do begin
      if (myHashMap.Objects [0] <> CONST_FALSE)
        and (myHashMap.Objects [0] <> CONST_TRUE)
        and (myHashMap.Objects [0] <> CNULL) then begin
        myHashMap.Objects [0].Free;
      end;
      myHashMap.Objects [0] := nil;
      myHashMap.Delete(0);
  end;
end;


(**
* Assign the values to other json Object.
* @param TJSONObject  objeto to assign Values
*)
procedure TJSONObject.assignTo(json: TJSONObject);
var
 _keys: TStringList;
 i: integer;
begin
  _keys := keys;
  try
    for i := 0 to _keys.Count -1 do begin
      json.put(_keys[i],get(_keys[i]).Clone);
    end;
  finally
   _keys.free;
  end;
end;

function TJSONObject.Clone: TZAbstractObject;
var
 json: TJSONObject;
begin
  json := TJSONObject.Create(self.toString());
  Result := json;
end;


{ TJSONNumber }


initialization
  CONST_FALSE := TJSONBool.Create(false);
  CONST_TRUE  := TJSONBool.Create(true);
  CNULL       := TJSONNull.Create;
  //Double default format.
  TJSONDouble.FStrFloatFmt := '######0.00';

finalization
  CONST_FALSE.free;
  CONST_TRUE.Free;
  CNULL.free;
end.
