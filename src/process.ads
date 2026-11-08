with Ada.Strings.Unbounded;
with Ada.Text_IO;

package Process is
   function Compile (Filename : String) return Boolean;

private
   package TIO renames Ada.Text_IO;
   package SU renames Ada.Strings.Unbounded;
end Process;