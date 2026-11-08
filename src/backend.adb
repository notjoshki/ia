with Logger;
with Utilities;

package body Backend is
   function Emit_Assembly (Instructions : Parser.Instruction_Vector.Vector) 
      return Ada.Strings.Unbounded.Unbounded_String is

      Back : Backend := (Instructions => Instructions,
         Code => SU.To_Unbounded_String ("section .text" & Utilities.CRLF & "global _start" & Utilities.CRLF),
         others => <>);
   begin
      for I in 1 .. Instructions.Length loop
         SU.Append (Back.Code, Emit_Instruction (Back, Parser.Instruction_Vector.Element (Instructions, Positive (I))));
      end loop;

      return Back.Code;
   end Emit_Assembly;

   function Emit_Instruction (Back : in out Backend; Instruction : IR.Instruction) return SU.Unbounded_String is
   begin
      case Instruction.Kind is
         when IR.Ext => return Emit_Exit (Back, Instruction);
         when IR.Label => return Emit_Label (Back, Instruction);
         when IR.NOP => return US ("");
         when others =>
            Logger.Log (Logger.Critical, "Uncaught instruction '" & Instruction.Kind'Img & "'");
            return US ("");
      end case;
   end Emit_Instruction;

   function Emit_Exit (Back : in out Backend; Instruction : IR.Instruction) return SU.Unbounded_String is
   begin
      return US ("mov rax, 60" & Utilities.CRLF & "xor rdi, rdi" & Utilities.CRLF & "syscall" & Utilities.CRLF);
   end Emit_Exit;

   function Emit_Label (Back : in out Backend; Instruction : IR.Instruction) return SU.Unbounded_String is
      Code : SU.Unbounded_String := SU.To_Unbounded_String ("_");
   begin
      SU.Append (Code, Instruction.Value.Value_String);
      SU.Append(Code, US (":" & Utilities.CRLF));
      return Code;
   end Emit_Label;
end Backend;