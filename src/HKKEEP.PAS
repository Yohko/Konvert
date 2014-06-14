unit HKKeep;  {Bindet die wesentliche Funktion Keep-Windows-Running ein !}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

const VK_0=$30; VK_1=$31; VK_2=$32; VK_3=$33; VK_4=$34; VK_5=$35; VK_6=$36; VK_7=$37;
      VK_8=$38; VK_9=$39; VK_A=$41; VK_B=$42; VK_C=$43; VK_D=$44; VK_E=$45; VK_F=$46;
      VK_G=$47; VK_H=$48; VK_I=$49; VK_J=$4A; VK_K=$4B; VK_L=$4C; VK_M=$4D; VK_N=$4E;
      VK_O=$4F; VK_P=$50; VK_Q=$51; VK_R=$52; VK_S=$53; VK_T=$54; VK_U=$55; VK_V=$56;
      VK_W=$57; VK_X=$58; VK_Y=$59; VK_Z=$5A;

 PROCEDURE KeepWindowsRunning;
 PROCEDURE Delay(ms:LongInt);

implementation

 PROCEDURE KeepWindowsRunning;
  BEGIN
   DELAY(30);
  END;

 PROCEDURE Delay(ms:LongInt);

   VAR
    TickCount:LongInt;
    {M        :TMsg;}

  BEGIN
   TickCount := GetTickCount;
   WHILE LongInt(GetTickCount) - TickCount < ms DO
    BEGIN
     {PeekMessage(M,Self,0,0,pm_Remove);
     TranslateMessage(M); }
     {GetMessage(M,0,0,0);
     DispatchMessage(M);}
     Application.ProcessMessages;
    END;{WHILE}
  END;

end.
