with Utilities;

package body Symbol is
   procedure Push (Sym : Symbol) is
   begin
      Symbol_Vector.Append (Table, Sym);
   end Push;

   function Find (Kind : Symbol_Kind; Name : Ada.Strings.Unbounded.Unbounded_String) return Symbol_Vector.Cursor is
      use type Symbol_Vector.Vector;
      use type SU.Unbounded_String;
   begin
      for Position in Table.Iterate loop
         declare
            Sym : constant Symbol := Symbol_Vector.Element (Position);
         begin
            if Sym.Kind = Kind and Sym.Name = Name then
               return Position;
            end if;
         end;
      end loop;

      return Symbol_Vector.No_Element;
   end Find;
end Symbol;