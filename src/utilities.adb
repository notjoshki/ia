with Ada.Characters.Latin_1;

package body Utilities is
   function Compare_Unbounded_String_To_String (LHS : Ada.Strings.Unbounded.Unbounded_String; RHS : String) return Boolean is
   begin
      if SU.Length (LHS) /= RHS'Length then
         return False;
      end if;

      for I in 1 .. RHS'Length loop
         if SU.Element (LHS, I) /= RHS (I) then
            return False;
         end if;
      end loop;

      return True;
   end Compare_Unbounded_String_To_String;

   function CRLF return String is
   begin
      return Ada.Characters.Latin_1.CR & Ada.Characters.Latin_1.LF;
   end CRLF;
end Utilities;