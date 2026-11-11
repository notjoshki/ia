with Lexer;
with Logger;
with Utilities;
with Symbol;

package body Parser is
   function Create (Prs : out Parser; Filename : String) return Boolean is
      Lex : Lexer.Lexer;
      Tok : Lexer.Token;
   begin
      if not Lexer.Create (Lex, Filename) then
         return False;
      end if;

      while Lex.Current_Char /= Lexer.End_Char loop
         Tok := Lexer.Get_Next_Token (Lex);
         Token_Vector.Append (Prs.Tokens, Tok);
      end loop;

      Prs.Filename := SU.To_Unbounded_String (Filename);
      Token_Vector.Append (Prs.Tokens, (Lexer.EOF, others => <>));
      Prs.Token := Prs.Tokens (1);
      return True;
   end Create;

   procedure Parse_Program (Prs : in out Parser) is
      use type Symbol.Symbol_Kind;
   begin
      while Prs.Token.Kind /= Lexer.EOF loop
         Parse (Prs);
      end loop;

      if SU.Length (Prs.Entry_Section) = 0 then
         Logger.Log (Logger.Critical, "Missing ENTRY clause");
      elsif Symbol.Find (Symbol.Section, Prs.Entry_Section).Kind = Symbol.None then
         Logger.Log (Logger.Critical, "No such section '" & SU.To_String (Prs.Entry_Section) & "' found in ENTRY clause");
      else
         SU.Append (Prs.Code, End_Code_Template);
      end if;
   end Parse_Program;

   procedure Step (Prs : in out Parser) is
   begin
      if Prs.Token.Kind /= Lexer.EOF then
         Prs.Index := Prs.Index + 1;
         Prs.Token := Prs.Tokens (Prs.Index);
      end if;
   end Step;

   procedure Eat (Prs : in out Parser; Kind : Lexer.Token_Kind) is
   begin
      if Kind /= Prs.Token.Kind then
         Logger.Log (Logger.Critical, "Expected token type '" & Kind'Img & "' but found '" & Prs.Token.Kind'Img & "'");
      end if;

      Step (Prs);
   end Eat;

   function Peek (Prs : Parser; Offset : Integer) return Lexer.Token is
   begin
      if Integer (Prs.Index) + Offset > Natural (Token_Vector.Length (Prs.Tokens)) then
         return Token_Vector.Element (Prs.Tokens, Natural (Token_Vector.Length (Prs.Tokens)));
      elsif Integer (Prs.Index) + Offset <= 1 then 
         return Token_Vector.Element (Prs.Tokens, 1);
      else
         return Token_Vector.Element (Prs.Tokens, Integer (Prs.Index) + Offset);
      end if;
   end Peek;

   procedure Parse (Prs : in out Parser) is
   begin
      if Prs.Token.Kind = Lexer.Semicolon then
         Step (Prs);
         return;
      end if;

      case Prs.Token.Kind is
         when Lexer.ID => Parse_ID (Prs);
         when Lexer.Keyword => Parse_Keyword (Prs);
         when Lexer.Dot =>
            if Peek (Prs, 1).Kind = Lexer.Str then
               Parse_Print (Prs);
            else
               Parse_Section (Prs);
            end if;
         when others =>
            Logger.Log (Logger.Critical, "Invalid statement '" & Prs.Token.Kind'Img & "'");
            Step (Prs);
      end case;
   end Parse;

   procedure Parse_Block (Prs : in out Parser) is
   begin
      Eat (Prs, Lexer.LBrace);

      while Prs.Token.Kind /= Lexer.EOF and Prs.Token.Kind /= Lexer.RBrace loop
         Parse (Prs);
      end loop;

      Eat (Prs, Lexer.RBrace);
   end Parse_Block;

   procedure Parse_ID (Prs : in out Parser) is
      Next : constant Lexer.Token := Peek (Prs, 1);
   begin
      Logger.Log (Logger.Critical, "Undefined ID '" & SU.To_String (Prs.Token.Value) & "'");
      Eat (Prs, Lexer.ID);
   end Parse_ID;

   procedure Parse_Keyword (Prs : in out Parser) is
      function Cmp (LHS : SU.Unbounded_String; RHS : String) return Boolean
         renames Utilities.Compare_Unbounded_String_To_String;
   begin
      if Cmp (Prs.Token.Value, "EXIT") then
         Parse_Exit (Prs);
      elsif Cmp (Prs.Token.Value, "SECTIONS") then
         Parse_Sections (Prs);
      elsif Cmp (Prs.Token.Value, "ENTRY") then
         Parse_Entry (Prs);
      else
         Logger.Log (Logger.Critical, "Undefined keyword '" & SU.To_String (Prs.Token.Value) & "'");
         Eat (Prs, Lexer.Keyword);
      end if;
   end Parse_Keyword;

   procedure Parse_Sections (Prs : in out Parser) is
   begin
      Prs.Parsing_Sections := True;
      Eat (Prs, Lexer.Keyword);
      Parse_Block (Prs);
      Prs.Parsing_Sections := False;
   end Parse_Sections;

   procedure Parse_Section (Prs : in out Parser) is
   begin
      Eat (Prs, Lexer.Dot);

      if not Utilities.Compare_Unbounded_String_To_String (Prs.Token.Value, "text") then
         Logger.Log (Logger.Critical, "Unknown section '" & SU.To_String (Prs.Token.Value) & "'");
      else
         Symbol.Push ((Symbol.Section, Prs.Token.Value));
      end if;

      if not Prs.Parsing_Sections then
         Logger.Log (Logger.Critical, "Section '" & SU.To_String (Prs.Token.Value) & "' defined outside SECTIONS clause");
      end if;

      Eat (Prs, Lexer.ID);
      Eat (Prs, Lexer.Colon);
      Parse_Block (Prs);
   end Parse_Section;

   procedure Parse_Entry (Prs : in out Parser) is
   begin
      Eat (Prs, Lexer.Keyword);
      Eat (Prs, Lexer.LParen);
      Eat (Prs, Lexer.Dot);

      Prs.Entry_Section := Prs.Token.Value;
      Eat (Prs, Lexer.ID);

      Eat (Prs, Lexer.RParen);
   end Parse_Entry;

   procedure Parse_Exit (Prs : in out Parser) is
   begin
      Eat (Prs, Lexer.Keyword);
      Eat (Prs, Lexer.LParen);

      SU.Append (Prs.Code, "return " & SU.To_String (Prs.Token.Value) & ";" & Utilities.CRLF);
      Eat (Prs, Lexer.Int);

      Eat (Prs, Lexer.RParen);
   end Parse_Exit;

   procedure Parse_Print (Prs : in out Parser) is
   begin
      Eat (Prs, Lexer.Dot);
      SU.Append (Prs.Code, "printf(" & Character'Val (34) & SU.To_String (Prs.Token.Value) & Character'Val (34) & ");" & Utilities.CRLF);
      Eat (Prs, Lexer.Str);
   end Parse_Print;
end Parser;