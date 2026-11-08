with Ada.Text_IO;

package body Logger is
   procedure Log (Kind : Error_Kind; Message : String) is
   begin
      Ada.Text_IO.Put_Line (Kind'Img & ": " & Message);

      if Kind = Critical then
         Error_Count := Error_Count + 1;
      end if;
   end Log;

   function Logged_Errors return Natural is
   begin
      return Error_Count;
   end Logged_Errors;
end Logger;