with Ada.Text_IO;
with Ada.Command_Line;
with Process;

procedure LDC is
   package TIO renames Ada.Text_IO;
   package CL renames Ada.Command_Line;

   procedure Show_Help is
   begin
      TIO.Put_Line ("Usage: ia [options...] <file>");
      TIO.Put_Line ("Options:");
      TIO.Put_Line ("    --help        Show help information");
   end Show_Help;
begin
   if CL.Argument_Count = 0 or else CL.Argument (CL.Argument_Count) = "--help" then
      Show_Help;
      return;
   end if;

   declare
      Filename : constant String := CL.Argument (CL.Argument_Count);
   begin
      for I in 1 .. CL.Argument_Count loop
         exit when I = CL.Argument_Count;

         if CL.Argument (I) = "--help" then
            Show_Help;
            return;
         end if;
      end loop;

      if not Process.Compile (Filename) then
         CL.Set_Exit_Status (CL.Failure);
      end if;
   end;
end LDC;