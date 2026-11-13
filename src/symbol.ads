with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;

package Symbol is
   type Symbol_Kind is (None, Section, Variable);

   type Symbol is record
      Kind : Symbol_Kind;
      Name : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   package Symbol_Vector is new Ada.Containers.Vectors (Positive, Symbol);

   procedure Push (Sym : Symbol);
   function Find (Kind : Symbol_Kind; Name : Ada.Strings.Unbounded.Unbounded_String) return Symbol_Vector.Cursor;

private
   package SU renames Ada.Strings.Unbounded;

   Table : aliased Symbol_Vector.Vector;
end Symbol;