with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Logger;
with Parser;

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

      if Logger.Logged_Errors > 0 then
         return False;
      end if;

      Ada.Text_IO.Put_Line (Ada.Strings.Unbounded.To_String (Prs.Code));
      return True;
   end Compile;
end Process;