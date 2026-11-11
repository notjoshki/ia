with Utilities;

package body Symbol is
   procedure Push (Sym : Symbol) is
   begin
      Symbol_Vector.Append (Table, Sym);
   end Push;

   function Find (Kind : Symbol_Kind; Name : Ada.Strings.Unbounded.Unbounded_String) return Symbol is
      use type Symbol_Vector.Vector;
      use type SU.Unbounded_String;
   begin
      for I in 1 .. Symbol_Vector.Length (Table) loop
         declare
            Sym : Symbol := Table (Positive (I));
         begin
            if Sym.Kind = Kind and Sym.Name = Name then
               return Sym;
            end if;
         end;
      end loop;

      return (None, others => <>);
   end Find;
end Symbol;