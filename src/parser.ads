with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Lexer;
with Utilities;
with Symbol;

package Parser is
   use type Lexer.Token_Kind;
   use type Lexer.Token;
   package Token_Vector is new Ada.Containers.Vectors (Positive, Lexer.Token);

   Start_Code_Template : constant String := "#include <stdio.h>" & Utilities.CRLF & 
                                            "int main(int argc, char **argv) {" & Utilities.CRLF;

   End_Code_Template : constant String := "return 0;" & Utilities.CRLF &
                                          "}" & Utilities.CRLF;

   type Parser is record
      Filename : Ada.Strings.Unbounded.Unbounded_String;
      Tokens : Token_Vector.Vector;
      Token : Lexer.Token;
      Index : Positive := 1;
      Entry_Section : Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String ("");
      Code : Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String (Start_Code_Template);
      Parsing_Sections : Boolean := False;
   end record;

   function Create (Prs : out Parser; Filename : String) return Boolean;
   procedure Parse_Program (Prs : in out Parser);

private
   package TIO renames Ada.Text_IO;
   package SU renames Ada.Strings.Unbounded;

   procedure Step (Prs : in out Parser);
   procedure Eat (Prs : in out Parser; Kind : Lexer.Token_Kind);
   function Peek (Prs : Parser; Offset : Integer) return Lexer.Token;
   procedure Parse (Prs : in out Parser);
   procedure Parse_Block (Prs : in out Parser);
   function Parse_Value (Prs : in out Parser) return SU.Unbounded_String;
   function Parse_Variable(Prs : in out Parser) return SU.Unbounded_String;
   function Parse_Int (Prs : in out Parser) return SU.Unbounded_String;
   procedure Parse_ID (Prs : in out Parser);
   procedure Parse_Assignment (Prs : in out Parser);
   procedure Parse_Keyword (Prs : in out Parser);
   procedure Parse_Sections (Prs : in out Parser);
   procedure Parse_Section (Prs : in out Parser);
   procedure Parse_Entry (Prs : in out Parser);
   procedure Parse_Exit (Prs : in out Parser);
   procedure Parse_Print (Prs : in out Parser);
end Parser;