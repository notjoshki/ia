with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Lexer;
with IR;

package Parser is
   use type Lexer.Token_Kind;
   use type Lexer.Token;
   use type IR.Instruction;
   package Token_Vector is new Ada.Containers.Vectors (Positive, Lexer.Token);
   package Instruction_Vector is new Ada.Containers.Vectors (Positive, IR.Instruction);

   type Parser is record
      Filename : Ada.Strings.Unbounded.Unbounded_String;
      Tokens : Token_Vector.Vector;
      Token : Lexer.Token;
      Index : Positive := 1;
      Instructions : Instruction_Vector.Vector;
   end record;

   function Create (Prs : out Parser; Filename : String) return Boolean;
   procedure Parse_Program (Prs : in out Parser);

private
   package TIO renames Ada.Text_IO;
   package SU renames Ada.Strings.Unbounded;

   procedure Push_Instruction (Prs : in out Parser; Inst : IR.Instruction);
   procedure Step (Prs : in out Parser);
   procedure Eat (Prs : in out Parser; Kind : Lexer.Token_Kind);
   function Peek (Prs : in out Parser; Offset : Integer) return Lexer.Token;
   procedure Parse (Prs : in out Parser);
   procedure Parse_ID (Prs : in out Parser);
   procedure Parse_Label (Prs : in out Parser);
   procedure Parse_Keyword (Prs : in out Parser);
   procedure Parse_Exit (Prs : in out Parser);
end Parser;