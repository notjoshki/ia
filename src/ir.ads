with Ada.Strings.Unbounded;

package IR is
   type Opcode is (NOP, Ext, Label);
   type Operand_Kind is (NONE);

   type Long_Long_Natural is range 0 .. Long_Long_Integer'Last;

   type Operand is record
      Kind : Operand_Kind;
      Value_Int_Signed_64 : Long_Long_Integer := 0;
      Value_Int_Unsigned_64 : Long_Long_Natural := 0;
      Value_Flt_64 : Long_Long_Float := 0.0;
      Value_String : Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String ("");
   end record;

   type Instruction is record
      Kind : Opcode;
      Value : Operand;
   end record;

   function Operand_Exit (Exit_Code : Long_Long_Integer) return Instruction;
   function Operand_Label (Name : Ada.Strings.Unbounded.Unbounded_String) return Instruction;

private
   package SU renames Ada.Strings.Unbounded;
end IR;