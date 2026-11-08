with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Characters.Handling;

package Lexer is
   type Token_Kind is (EOF, ID, Keyword, Int, Colon);

   type Token is record
      Kind : Token_Kind;
      Ln, Col : Natural := 0;
      Value : Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String ("");
   end record;

   type Lexer is record
      Filename, Source : Ada.Strings.Unbounded.Unbounded_String;
      Current_Char : Character;
      Index, Ln, Col : Positive := 1;
   end record;

   End_Char : constant Character := Character'Val (0);

   function Create (Lex : out Lexer; Filename : String) return Boolean;
   function Get_Next_Token (Lex : in out Lexer) return Token;

private
   package TIO renames Ada.Text_IO;
   package SU renames Ada.Strings.Unbounded;
   package CH renames Ada.Characters.Handling;

   procedure Step (Lex : in out Lexer);
   function Step_And_Create_Token (Lex : in out Lexer; Kind : Token_Kind; Step_Count : Positive := 1) return Token;
   function Lex_ID (Lex : in out Lexer) return Token;
   function Lex_Digit (Lex : in out Lexer) return Token;
end Lexer;