with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Parser;
with Backend;

package body Process is
   function Compile (Filename : String) return Boolean is
      package TIO renames Ada.Text_IO;
      package SU renames Ada.Strings.Unbounded;

      Prs : Parser.Parser;
      Code : SU.Unbounded_String;
   begin
      if not Parser.Create (Prs, Filename) then
         return False;
      end if;

      Parser.Parse_Program (Prs);
      Code := Backend.Emit_Assembly (Prs.Instructions);
      Ada.Text_IO.Put_Line (SU.To_String (Code));
      return True;
   end Compile;
end Process;