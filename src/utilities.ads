with Ada.Strings.Unbounded;

package Utilities is
   function Compare_Unbounded_String_To_String (LHS : Ada.Strings.Unbounded.Unbounded_String; RHS : String) return Boolean;
   function CRLF return String;

private
   package SU renames Ada.Strings.Unbounded;
end Utilities;