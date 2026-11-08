package body IR is
   function Operand_Exit (Exit_Code : Long_Long_Integer) return Instruction is
   begin
      return (Ext, (Value_Int_Signed_64 => Exit_Code, others => <>));
   end Operand_Exit;

   function Operand_Label (Name : Ada.Strings.Unbounded.Unbounded_String) return Instruction is
   begin
      return (Label, (Value_String => Name, others => <>));
   end Operand_Label;
end Ir;