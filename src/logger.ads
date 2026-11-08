package Logger is
   type Error_Kind is (Critical, Warning);

   procedure Log (Kind : Error_Kind; Message : String);
   function Logged_Errors return Natural with Inline;

private
   Error_Count : Natural := 0;
end Logger;