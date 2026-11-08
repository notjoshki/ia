with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Characters.Latin_1;
with IR;
with Parser;

package Backend is
   type Backend is record
      Instructions : Parser.Instruction_Vector.Vector;
      Code : Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String ("");
   end record;

   function Emit_Assembly (Instructions : Parser.Instruction_Vector.Vector) return Ada.Strings.Unbounded.Unbounded_String;

private
   package SU renames Ada.Strings.Unbounded;
   package L1 renames Ada.Characters.Latin_1;
   function US (S : String) return SU.Unbounded_String renames SU.To_Unbounded_String;

   function Emit_Instruction (Back : in out Backend; Instruction : IR.Instruction) return SU.Unbounded_String;
   function Emit_Exit (Back : in out Backend; Instruction : IR.Instruction) return SU.Unbounded_String;
   function Emit_Label (Back : in out Backend; Instruction : IR.Instruction) return SU.Unbounded_String;
end Backend;