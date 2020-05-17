with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
package body cw with SPARK_Mode is
   
   procedure EmptyCarriage (t : in out Train) is
   begin
      for Pos in t.carriage.carriages'Range loop
         t.carriage.carriages(Pos) := Empty;
         pragma Loop_Invariant (for all J in t.carriage.carriages'First..(Pos) => t.carriage.carriages(J) /= Loaded);
         pragma Loop_Variant (Increases => Pos);
      end loop;
      t.carriage.Top := CarriageRange'First;
   end EmptyCarriage;

   procedure UnloadCarriage (t : in out Train) is
   begin
      t.carriage.carriages(t.carriage.Top - 1) := Empty;
      t.carriage.Top := t.carriage.Top - 1;
   end UnloadCarriage;

   procedure LoadCarriage (t : in out Train) is
   begin
      t.carriage.carriages(t.carriage.Top) := Loaded;
      t.carriage.Top := t.carriage.Top + 1;
   end LoadCarriage;
   
   procedure LoadRod (t: in out Train; n: RodRange) is
   begin
      --rod 0 will always be loaded
      if(n >= 1 and then n < 5 and then t.isMoving = False)
      then
         t.reactor(n) := Loaded;
      end if;
   end LoadRod;
   
   procedure UnloadRod (t: in out Train; n: RodRange) is
   begin
      --rod 0 should never be unloaded
      if(n >= 1 and then n < 5 and then t.isMoving = False)
      then
         t.reactor(n) := Empty;
      end if;
   end UnloadRod;
   
   procedure MaintenanceModeOn (t: in out Train) is
   begin
      if t.isMoving = False then
         for r in t.reactor'Range loop
            t.reactor(r) := Loaded;
            pragma Loop_Invariant (for all J in t.reactor'First..(r) => t.reactor(J) /= Empty);
            pragma Loop_Variant (Increases => r);
         end loop;
         t.isMoving := Maintenance;
      end if;
           
   end MaintenanceModeOn;
   
   procedure MaintenanceModeOff (t: in out Train) is
   begin
      if t.isMoving = Maintenance then
         t.isMoving := False;
      end if;
   end MaintenanceModeOff;
   
   function ConnectedCarriages(t: Train) return CarriageCounter is
      count: CarriageCounter := 0;
   begin
      
      for J in t.carriage.carriages'Range loop
         if (t.carriage.carriages(J) = Loaded) then
            count := count +1;
         end if;
         
      end loop;
      
      return count;
   end ConnectedCarriages;
   
   function LoadedRods(t: Train) return RodCounter is
      count: RodCounter := 0;
   begin
      
      for J in t.reactor'Range loop
         if t.reactor(J) = Loaded then
            count := count + RodCounter(1);
         end if;
         
      end loop;
      
      return count;
   end LoadedRods;
   
   procedure UpdateStats(t: in out Train) is
      carrCount: CarriageCounter := ConnectedCarriages(t);
      rodCount: RodCounter := LoadedRods(t);
   begin
      if t.isMoving = False then
         
         t.stats.currEnergy := Energy(((Float(t.reactor'Length) +1.0) - Float(rodCount))*20.0);
         --at worst you lose 50% energy
         t.stats.currEnergy := t.stats.currEnergy - (Energy(Float(rodCount) * 0.1) * t.stats.currEnergy);
         
         t.stats.currMaxSpeed := Speed(Energy(speedMultiplier) * t.stats.currEnergy);
         --at worst you lose 40% speed
         t.stats.currMaxSpeed := t.stats.currMaxSpeed - Speed(Float(carrCount) * 0.04) *t.stats.currMaxSpeed;
         
         t.stats.temperature := Heat(((Float(t.reactor'Length) +1.0) - Float(rodCount)) * 10.0);
         t.stats.tempIncreaser := IncreaserRange(((t.reactor'Length +1) - Integer(rodCount)) * 20);
         t.stats.waterDepletion :=  DepleterRange(((t.reactor'Length +1) - Integer(rodCount))*3);
      end if;
      --Put_Line(t.stats);
   end UpdateStats;
   
   procedure RefillWater(t: in out Train)is
   begin
      t.stats.waterTank := Water'Last;
      
   end RefillWater;
   
   procedure MoveTrain(t: in out Train) is
      distanceMade: Float;
      hoursOnHeat: Float;
   begin
      if t.isMoving = False then
         UpdateStats(t);
         --distance that can be made untill running out of water (engine heat won't increase while there is water)
         distanceMade := Float(Speed(t.stats.waterTank / Water(t.stats.waterDepletion)) * t.stats.currMaxSpeed);
         t.stats.waterTank := 0.0;
         
         if t.stats.waterTank = 0.0 then
            --that's as high as it can go
            hoursOnHeat := Float(Heat'Last - t.stats.temperature) / Float(t.stats.tempIncreaser);
            distanceMade := distanceMade + hoursOnHeat * Float(t.stats.currMaxSpeed);
            --not great, not terrible
            t.stats.temperature := 500.0;
         end if;
         Put("Distance travelled (km): "); Put(distanceMade,1,4,0);
      end if;
      
   
   end MoveTrain;
   
end cw;
