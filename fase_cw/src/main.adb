with cw; use cw;
with Ada.Text_IO; use Ada.Text_IO;


procedure Main with SPARK_Mode => on
is
   tc : TrainCarriage := (Top => 0, carriages => (others => Empty));
   tr : TrainRecord := (temperature => 20.0, tempIncreaser=> 0.0, waterTank => 100.0, waterDepletion => 0.0,
                        currEnergy => 0.0, engineOnline => False, currMaxSpeed => 100.0);
   t : Train := (stats => tr, isMoving => Maintenance, carriage => tc, reactor => (others => Empty));

begin
   MaintenanceMode(t => t,n => 0);
   LoadCarriage(t => t);
   MoveTrain(t => t);




end Main;
