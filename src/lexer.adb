with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Directories;
with Ada.Characters.Handling;
with Logger;
with Utilities;

package body Lexer is
   function Create (Lex : out Lexer; Filename : String) return Boolean is
      File : TIO.File_Type;
   begin
      if not Ada.Directories.Exists (Filename) then
         Logger.Log (Logger.Critical, "File '" & Filename & "' does not exist");
         return False;
      end if;

      TIO.Open (File, TIO.In_File, Filename);

      while not TIO.End_Of_File (File) loop
         SU.Append (Lex.Source, TIO.Get_Line (File));
      end loop;
      
      TIO.Close (File);
      Lex.Current_Char := SU.Element (Lex.Source, 1);
      return True;
   end Create;

   function Get_Next_Token (Lex : in out Lexer) return Token is
   begin
      while CH.Is_Space (Lex.Current_Char) loop
         Step (Lex);
      end loop;

      if Lex.Current_Char = End_Char then
         return (EOF, Lex.Ln, Lex.Col, Value => <>);
      elsif CH.Is_Letter (Lex.Current_Char) then
         return Lex_ID (Lex);
      elsif CH.Is_Digit (Lex.Current_Char) then
         return Lex_Digit (Lex);
      end if;

      case Lex.Current_Char is
         when '"' => return Lex_String (Lex);
         when ':' => return Step_And_Create_Token (Lex, Colon);
         when '{' => return Step_And_Create_Token (Lex, LBrace);
         when '}' => return Step_And_Create_Token (Lex, RBrace);
         when ';' => return Step_And_Create_Token (Lex, Semicolon);
         when '.' => return Step_And_Create_Token (Lex, Dot);
         when '(' => return Step_And_Create_Token (Lex, LParen);
         when ')' => return Step_And_Create_Token (Lex, RParen);
         when others =>
            Logger.Log (Logger.Critical, "Unknown token " & Lex.Current_Char'Img & "");
            Step (Lex);
            return Get_Next_Token (Lex);
      end case;
   end Get_Next_Token;

   procedure Step (Lex : in out Lexer) is
   begin
      if Lex.Index + 1 > SU.Length (Lex.Source) then
         Lex.Current_Char := End_Char;
         return;
      end if;

      if Lex.Current_Char = Character'Val (10) then
         Lex.Ln := Lex.Ln + 1;
         Lex.Col := 1;
      else
         Lex.Col := Lex.Col + 1;
      end if;

      Lex.Index := Lex.Index + 1;
      Lex.Current_Char := SU.Element (Lex.Source, Lex.Index);
   end Step;

   function Peek (Lex : Lexer; Offset : Integer) return Character is
   begin
      if Integer (Lex.Index) + Offset > SU.Length (Lex.Source) then
         return SU.Element (Lex.Source, SU.Length (Lex.Source));
      elsif Integer (Lex.Index) + Offset <= 1 then 
         return SU.Element (Lex.Source, 1);
      else
         return SU.Element (Lex.Source, Integer (Lex.Index) + Offset);
      end if;
   end Peek;

   function Step_And_Create_Token (Lex : in out Lexer; Kind : Token_Kind; Step_Count : Positive := 1) return Token is
      Ln : constant Natural := Lex.Ln;
      Col : constant Natural := Lex.Col;
   begin
      for I in 1 .. Step_Count loop
         Step (Lex);
      end loop;

      return (Kind, Ln, Col, Value => <>);
   end Step_And_Create_Token;

   function Lex_ID (Lex : in out Lexer) return Token is
      Col : constant Positive := Lex.Col;
      Value : SU.Unbounded_String;

      function Is_Keyword return Boolean is
         function Cmp (LHS : SU.Unbounded_String; RHS : String) return Boolean
            renames Utilities.Compare_Unbounded_String_To_String;
      begin
         if Cmp (Value, "SECTIONS") then
            return True;
         elsif Cmp (Value, "ENTRY") then
            return True;
         elsif Cmp (Value, "EXIT") then
            return True;
         end if;

         return False;
      end Is_Keyword;
   begin
      while CH.Is_Alphanumeric (Lex.Current_Char) loop
         SU.Append (Value, Lex.Current_Char);
         Step (Lex);
      end loop;

      return ((if Is_Keyword then Keyword else ID), Lex.Ln, Col, Value);
   end Lex_ID;

   function Lex_Digit (Lex : in out Lexer) return Token is
      Col : constant Natural := Lex.Col;
      Value : SU.Unbounded_String;
   begin
      while CH.Is_Digit (Lex.Current_Char) loop
         SU.Append (Value, Lex.Current_Char);
         Step (Lex);
      end loop;

      return (Int, Lex.Ln, Col, Value);
   end Lex_Digit;

   function Lex_String (Lex : in out Lexer) return Token is
      Col : constant Positive := Lex.Col;
      Value : SU.Unbounded_String;
   begin
      Step (Lex);

      while Lex.Current_Char /= End_Char and Lex.Current_Char /= '"' loop
         SU.Append (Value, Lex.Current_Char);
         Step (Lex);

         if Lex.Current_Char = '"' and Peek (Lex, -1) = '\' then
            SU.Append (Value, Character'Val (32));
            Step (Lex);
         end if;
      end loop;

      Step (Lex);
      return (Str, Lex.Ln, Col, Value);
   end Lex_String;
end Lexer;