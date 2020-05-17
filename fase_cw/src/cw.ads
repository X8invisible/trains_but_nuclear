package cw with SPARK_Mode is

   

   type CarriageSlot is (Empty, Loaded);
   type Moving is (True, False, Maintenance);

   type Rod is (Empty, Loaded);
   
   type Energy is new Float range 0.0..100.0;
   type Heat is new Float range 0.0..500.0;
   type Water is new Float range 0.0..100.0;
   type Speed is new Float range 0.0..500.0;
   
   type CarriageRange is range 0..10;
   type CarriageCounter is range 0..11;
   type RodRange is range 0..4;
   type RodCounter is range 0..5;
   type IncreaserRange is range 0..100;
   type DepleterRange is range 0..15;
   
   type CarriageArr is array (CarriageRange) of CarriageSlot;
   type ReactorArr is array (RodRange) of Rod;
   
   speedMultiplier : constant Float := 5.0;
   
   type TrainRecord is record
      temperature: Heat;
      --how much temp increases per hour
      tempIncreaser : IncreaserRange; 
      waterTank: Water;
      --how much water depletes per hr
      waterDepletion : DepleterRange;
      currEnergy: Energy;
      currMaxSpeed : Speed;
      --speed
   end record;

   --acts like a stack
   type TrainCarriage is record
      carriages : CarriageArr;
      Top : CarriageRange := CarriageRange'First;
   end record;

   type Train is record
      stats : TrainRecord;
      isMoving : Moving;
      carriage : TrainCarriage;
      reactor : ReactorArr;
   end record;
   
   procedure EmptyCarriage (t : in out Train) with
     Pre => isTrainMoving(t) = False and t.carriage.Top > 0,
     Post => t.carriage.Top = CarriageRange'First and (for all J in t.carriage.carriages'First..t.carriage.carriages'Last => t.carriage.carriages(J) /= Loaded);
   procedure UnloadCarriage (t : in out Train) with
     Pre => isTrainMoving(t) = False and t.carriage.Top > 0,
     Post => t.carriage.Top = t.carriage.Top'Old - 1 and t.carriage.carriages(t.carriage.Top'Old - 1) = Empty;
   procedure LoadCarriage (t : in out Train) with
     Pre => isTrainMoving(t) = False and t.carriage.Top < CarriageRange'Last,
     Post => t.carriage.Top = t.carriage.Top'Old + 1 and t.carriage.carriages(t.carriage.Top'Old) = Loaded;
   procedure LoadRod (t: in out Train; n: RodRange) with
     Pre => n >= RodRange'First +1 and n <= RodRange'Last and t.isMoving = False and LoadedRods(t) < RodCounter'Last and t.reactor(n) = Empty,
     Post =>  t.reactor(n) = Loaded;
   procedure UnloadRod (t: in out Train; n: RodRange) with
     Pre => n >= RodRange'First +1 and n <= RodRange'Last and t.isMoving = False and LoadedRods(t) > RodCounter'First+1 and t.reactor(n) = Loaded,
     Post =>  t.reactor(n) = Empty;
   procedure MaintenanceModeOn (t: in out Train) with
     Pre => t.isMoving = False,
     Post => t.isMoving = Maintenance and (for all J in t.reactor'First..t.reactor'Last => t.reactor(J) /= Empty);
   procedure MaintenanceModeOff (t: in out Train) with
     Pre => t.isMoving = Maintenance,
     Post => t.isMoving = False;
   procedure UpdateStats(t: in out Train) with
     Pre => t.isMoving = False and LoadedRods(t) > 0 and speedMultiplier = 5.0,
     Post => t.stats.temperature > 0.0 and t.stats.tempIncreaser > 0 and t.stats.waterDepletion > 0;
   procedure RefillWater(t: in out Train) with
     Pre => t.isMoving = False,
     Post => t.stats.waterTank = Water'Last;
   procedure MoveTrain(t:in out Train) with
     Pre => t.isMoving = False and LoadedRods(t) >0;
   
   function ConnectedCarriages(t: Train) return CarriageCounter;
   function LoadedRods(t: Train) return RodCounter;
   --this is used for pre conditions that can happen when the train isn't moving (includes train in maintenance)
   function IsTrainMoving(t: Train) return Boolean is
     (t.isMoving = True);
   
end cw;
