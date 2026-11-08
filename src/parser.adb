with Lexer;
with Logger;
with Utilities;

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
   begin
      while Prs.Token.Kind /= Lexer.EOF loop
         Parse (Prs);
      end loop;
   end Parse_Program;

   procedure Step (Prs : in out Parser) is
   begin
      if Prs.Token.Kind /= Lexer.EOF then
         Prs.Index := Prs.Index + 1;
         Prs.Token := Prs.Tokens (Prs.Index);
      end if;
   end Step;

   procedure Push_Instruction (Prs : in out Parser; Inst : IR.Instruction) is
   begin
      Instruction_Vector.Append (Prs.Instructions, Inst);
   end Push_Instruction;

   procedure Eat (Prs : in out Parser; Kind : Lexer.Token_Kind) is
   begin
      if Kind /= Prs.Token.Kind then
         Logger.Log (Logger.Critical, "Expected token type '" & Kind'Img & "' but found '" & Prs.Token.Kind'Img & "'");
      end if;

      Step (Prs);
   end Eat;

   function Peek (Prs : in out Parser; Offset : Integer) return Lexer.Token is
   begin
      if Integer (Prs.Index) + Offset > Natural (Token_Vector.Length (Prs.Tokens)) then
         return Token_Vector.Element (Prs.Tokens, Natural (Token_Vector.Length (Prs.Tokens)));
      elsif Integer (Prs.Index) + Offset <= 1 then 
         return Token_Vector.Element (Prs.Tokens, 1);
      else
         return Token_Vector.Element (Prs.Tokens, Prs.Index + Positive (Offset));
      end if;
   end Peek;

   procedure Parse (Prs : in out Parser) is
   begin
      case Prs.Token.Kind is
         when Lexer.ID => Parse_ID (Prs);
         when Lexer.Keyword => Parse_Keyword (Prs);
         when others =>
            Logger.Log (Logger.Critical, "Invalid statement '" & Prs.Token.Kind'Img & "'");
            Step (Prs);
      end case;
   end Parse;

   procedure Parse_ID (Prs : in out Parser) is
      Next : constant Lexer.Token := Peek (Prs, 1);
   begin
      if Next.Kind = Lexer.Colon then
         Parse_Label (Prs);
      end if;
   end Parse_ID;

   procedure Parse_Label (Prs : in out Parser) is
   begin
      Push_Instruction (Prs, IR.Operand_Label (Prs.Token.Value));
      Eat (Prs, Lexer.ID);
      Eat (Prs, Lexer.Colon);
   end Parse_Label;

   procedure Parse_Keyword (Prs : in out Parser) is
      function Cmp (LHS : SU.Unbounded_String; RHS : String) return Boolean
         renames Utilities.Compare_Unbounded_String_To_String;
   begin
      if Cmp (Prs.Token.Value, "exit") then
         Parse_Exit (Prs);
      end if;
   end Parse_Keyword;

   procedure Parse_Exit (Prs : in out Parser) is
   begin
      Eat (Prs, Lexer.Keyword);
      Push_Instruction (Prs, IR.Operand_Exit (0));
   end Parse_Exit;
end Parser;