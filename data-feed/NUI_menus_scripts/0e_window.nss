/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_menu_pc
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Menu event script
    sEvent: close, click, mousedown, mouseup, watch (if bindwatch is set).
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_win_layouts"

void main()
{
  // Let the inspector handle what it wants.
  //HandleWindowInspectorEvent ();
  object oPlayer = NuiGetEventPlayer();
  int    nToken  = NuiGetEventWindow();
  string sEvent  = NuiGetEventType();
  string sElem   = NuiGetEventElement();
  int    nIdx    = NuiGetEventArrayIndex();
  string sWndId  = NuiGetWindowId (oPlayer, nToken);
  int bNumberRolls;
  // This is a "menu has been moved event".
  if (sEvent == "watch" && sElem == "window_geometry")
  {
      // Saves the location of the window so we can restore it to the last used location.
      if (!GetLocalInt (oPlayer, "0_No_Win_Save"))
      {
          // Get the x position, and y position of the window.
          // Specific binds are used by the engine.
          // 0th Bind is window_geometry,
          string sBind = NuiGetNthBind (oPlayer, nToken, FALSE, 0);
          json jGeometry = NuiGetBind (oPlayer, nToken, sBind);
          float fX = JsonGetFloat (JsonObjectGet (jGeometry, "x"));
          float fY = JsonGetFloat (JsonObjectGet (jGeometry, "y"));
          PrintString ("fX & fY");
          PrintFloat (fX, 0, 2);
          PrintFloat (fY, 0, 2);
          JsonDump (jGeometry);
          SetServerDatabaseFloat (oPlayer, PLAYER_TABLE, sWndId + "x", fX);
          SetServerDatabaseFloat (oPlayer, PLAYER_TABLE, sWndId + "y", fY);
      }
  }
  // This is a player menu event.
  if (sWndId == "pcplayerwin")
  {
    // Which button was "clicked" in the player menu event.
    if (sEvent == "click" && sElem == "btn_options") PopUpPlayerOptionsGUIPanel (oPlayer);
    if (sEvent == "click" && sElem == "btn_bug_report") PopUpBugReportGUIPanel (oPlayer, "pcbugwin");
    if (sEvent == "click" && sElem == "btn_teleport")
    {
        SetLocalInt (oPlayer, "0_TARGET_MODE", 1);
        EnterTargetingMode (oPlayer, OBJECT_TYPE_INVALID);
    }
      if (sEvent == "click" && sElem == "btn_summons")
      {
          SetLocalInt (oPlayer, "0_TARGET_MODE", 2);
          SetLocalInt (oPlayer, "0_TOKEN", nToken);
          int bDontShowMessage = GetLocalInt (oPlayer, "0_DONT_SHOW_MESSAGE");
          if (!bDontShowMessage)
          {
              SendMessageToPC (oPlayer, "Select a creature to save them to the button.");
              SendMessageToPC (oPlayer, "Select the ground to copy the creature.");
              SetLocalInt (oPlayer, "0_DONT_SHOW_MESSAGE", TRUE);
          }
          EnterTargetingMode (oPlayer, OBJECT_TYPE_CREATURE | OBJECT_TYPE_INVALID);
      }
    if (sEvent == "click" && sElem == "btn_desc") PopUpCharacterDescriptionGUIPanel (oPlayer);
    if (sEvent == "click" && sElem == "btn_dice") PopUpDiceGUIPanel (oPlayer, "pcdicewin");
  }
  // This is a player option event.
  else if (sWndId == "pcoptionwin")
  {
    // The credit button was hit so lets pull up the CREDITS!
    if (sEvent == "click" && sElem == "btn_credits") PopUpCreditsGUIPanel (oPlayer, "pccreditwin");
    // The combo button has been changed so lets either make it vertical or horizontal.
    else if (sEvent == "watch" && sElem == "menu_opt_selected")
    {
        int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
        SetServerDatabaseInt (oPlayer, PLAYER_TABLE, "pcplayerwinhv", nSelected);
        NuiDestroy (oPlayer, GetLocalInt (oPlayer, "0_Menu_Token"));
        if (nSelected == 0) PopUpPlayerHorGUIPanel (oPlayer);
        else PopUpPlayerVerGUIPanel (oPlayer);
    }
    else if (sEvent == "watch" && sElem == "effect_opt_selected")
    {
        int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
        SetServerDatabaseInt (oPlayer, PLAYER_TABLE, "effects", nSelected);
        if (nSelected == 0) SendMessageToPC (oPlayer, "Fine! We will not show any flashy cool effects!");
        else if (nSelected == 1) SendMessageToPC (oPlayer, "Now were talking, lets do some nice effects!");
        else if (nSelected == 2) SendMessageToPC (oPlayer, "Now we are cooking! Bring on the massive effects!");
    }
  }
  // This is the bug report event.
  else if (sWndId == "pcbugwin")
  {
    // Watches the bug report text window and changes the save button status to on/off.
    if (sEvent == "watch" && sElem == "bug_value")
    {
        string sMessage = JsonGetString (NuiGetBind (oPlayer, nToken, "bug_value"));
        if (sMessage != "") NuiSetBind (oPlayer, nToken, "btn_bug_save_event", JsonBool (TRUE));
        else NuiSetBind (oPlayer, nToken, "btn_bug_save_event", JsonBool (FALSE));
    }
    // Hitting the bug report save button... reports bug.
    if (sEvent == "click" && sElem == "btn_bug_save")
    {
        // Get location so we can report it.
        string sLocation;
        object oArea;
        vector vPosition;
        float fFacing;
        location lLocation = GetLocation (oPlayer);
        oArea = GetAreaFromLocation (lLocation);
        vPosition = GetPositionFromLocation (lLocation);
        fFacing = GetFacingFromLocation (lLocation);
        sLocation = "(Tag: " + GetTag (oArea) + ", X: " + FloatToString(vPosition.x, 0, 2) + ", Y: " +
        FloatToString(vPosition.y, 0, 2) + ", Z: " + FloatToString(vPosition.z, 0, 2) + ", Face: " +
        FloatToString (fFacing, 0, 2) + ")";
        // Send bug report.
        string sMessage = JsonGetString (NuiGetBind (oPlayer, nToken, "bug_value"));
        WriteTimestampedLogEntry ("!!!BUG REPORT!!! [" + GetName (GetArea (oPlayer)) + "] Location: " + sLocation);
        WriteTimestampedLogEntry ("!!!BUG REPORT!!! [" + GetPCPlayerName (oPlayer) + " : " + GetName (oPlayer) + "] " + sMessage);
        // Thank the player for the report.
        SendMessageToPC (oPlayer, "Your report has been sent, Thank you!");
        NuiDestroy (oPlayer, nToken);
    }
  }
  // This is the player description event.
  else if (sWndId == "pcdescwin")
  {
    int nChange = 0;
    int nID;
    string sResRef;
    // Portrait text name event. You can type in a custom portait!
    if (sEvent == "watch" && sElem == "port_name")
    {
        nID = JsonGetInt (NuiGetUserData (oPlayer, nToken));
        string sBaseResRef = "po_" + Get2DAString ("portraits", "BaseResRef", nID);
        sResRef = JsonGetString (NuiGetBind (oPlayer, nToken, "port_name"));
        if (sBaseResRef != sResRef) NuiSetBind (oPlayer, nToken, "port_id", JsonString ("Custom Portrait"));
        else NuiSetBind (oPlayer, nToken, "port_id", JsonString (IntToString (nID)));

        NuiSetBind (oPlayer, nToken, "port_resref", JsonString (sResRef + "l"));
    }
    // Save button to save the description to the player.
    if (sEvent == "click" && sElem == "btn_desc_save")
    {
        string sDescription = JsonGetString (NuiGetBind (oPlayer, nToken, "desc_value"));
        SetDescription (oPlayer, sDescription);
    }
    // Portrait next button.
    if (sEvent == "click" && (sElem == "btn_portrait_next"))
    {
      nID = JsonGetInt (NuiGetUserData (oPlayer, nToken)) + 1;
      nChange = 1;
    }
    // Portait previous button.
    if (sEvent == "click" && (sElem == "btn_portrait_prev"))
    {
      nID = JsonGetInt (NuiGetUserData (oPlayer, nToken)) - 1;
      nChange = -1;
    }
    if (nChange != 0)
    {
        int nPRace, nPGender;
        if (nID > 1317) nID = 1;
        if (nID < 1) nID = 1317;
        int nGender = GetGender (oPlayer);
        int nRace = GetRacialType (oPlayer);
        string sPRace = Get2DAString ("portraits", "Race", nID);
        if (sPRace != "") nPRace = StringToInt (sPRace);
        else nPRace = -1;
        string sPGender = Get2DAString ("portraits", "Sex", nID);
        if (sPGender != "") nPGender = StringToInt (sPGender);
        else nPGender = -1;
        while ((nRace != nPRace && (nRace != 4 || (nPRace != 1 && nPRace != 6))) || nGender != nPGender)
        {
            nID += nChange;
            if (nID > 1317) nID = 1;
            if (nID < 1) nID = 1317;
            sPRace = Get2DAString ("portraits", "Race", nID);
            if (sPRace != "") nPRace = StringToInt (sPRace);
            else nPRace = -1;
            sPGender = Get2DAString ("portraits", "Sex", nID);
            if (sPGender != "") nPGender = StringToInt (sPGender);
            else nPGender = -1;
        }
        string sResRef = "po_" + Get2DAString("portraits", "BaseResRef", nID);
        NuiSetUserData (oPlayer, nToken, JsonInt (nID));
        NuiSetBind (oPlayer, nToken, "port_name", JsonString (sResRef));
    }
    // Save portrait button.
    if (sEvent == "click" && sElem == "btn_portrait_ok")
    {
      sResRef = JsonGetString (NuiGetBind (oPlayer, nToken, "port_name"));
      string sID = JsonGetString (NuiGetBind (oPlayer, nToken, "port_id"));
      if (sID != "Custom Portrait") SetPortraitId (oPlayer, StringToInt (sID));
      else SetPortraitResRef (oPlayer, sResRef);
    }
  }
  // This is the dice event.
  else if (sWndId == "pcdicewin")
  {
    // Roll the dice button.
    if (sEvent == "click" && sElem == "btn_roll")
    {
        int nRoll;
        string sText = JsonGetString (NuiGetBind (oPlayer, nToken, "roll_text"));
        string sRoll = CheckDiceRollText (oPlayer, sText);
        if (sRoll == "")
        {
            nRoll = RollDiceString (sText);
            // Check for target.
            object oTarget = GetLocalObject (oPlayer, "0_Dice_Target");
            if (oTarget != OBJECT_INVALID) sRoll = GetName (oTarget) + " rolls a " + sText + " and the result is " + IntToString (nRoll);
            else sRoll = GetName (oPlayer) + " rolls a " + sText + " and the result is " + IntToString (nRoll);
            SendDiceMessage (oPlayer, sRoll);
        }
        else
        {
            int i = 1;
            int iNumOfDice = GetLocalInt (oPlayer, "0_NumDice") + 1;
            if (iNumOfDice > 1) bNumberRolls = TRUE;
            while (iNumOfDice > 0)
            {
                if (bNumberRolls)
                {
                    sRoll = IntToString (i++) + ") " + sRoll;
                }
                SendDiceMessage (oPlayer, sRoll);
                sRoll = CheckDiceRollText (oPlayer, sText);
                iNumOfDice --;
            }
        }
    }
    // Dice number combo box has changed.
    else if (sEvent == "watch" && sElem == "num_dice_combo_selected")
    {
        int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
        SetLocalInt (oPlayer, "0_NumDice", nSelected);
        NuiSetBind (oPlayer, nToken, "roll_text", JsonString (GetRollText (oPlayer)));
        //Debug ("0e_window", "237", "nSelected: " + IntToString (nSelected));
    }
    // Dice type combo box has changed.
    else if (sEvent == "watch" && sElem == "type_roll_combo_selected")
    {
        int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
        SetLocalInt (oPlayer, "0_TypeRoll", nSelected);
        NuiSetBind (oPlayer, nToken, "roll_text", JsonString (GetRollText (oPlayer)));
    }
    // Dice bonus combo box has changed.
    else if (sEvent == "watch" && sElem == "die_bonus_combo_selected")
    {
        int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
        if (nSelected > 20) nSelected = 20 - nSelected;
        SetLocalInt (oPlayer, "0_DieBonus", nSelected);
        NuiSetBind (oPlayer, nToken, "roll_text", JsonString (GetRollText (oPlayer)));
    }
    // Dice broadcast combo box has changed.
    else if (sEvent == "watch" && sElem == "broadcast_combo_selected")
    {
        int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
        if (nSelected == 4)
        {
            SetLocalInt (oPlayer, "0_TARGET_MODE", 3);
            // Default the broad cast mode to DM.
            nSelected = 0;
            NuiSetBind (oPlayer, nToken, "broadcast_combo_selected", JsonInt (0));
            EnterTargetingMode (oPlayer, OBJECT_TYPE_CREATURE);
        }
        SetLocalInt (oPlayer, "0_Broadcast", nSelected);
    }
  }
  // This is the credits event.
  else if (sWndId == "pccreditwin")
  {
    // Close the Credits window.
    if (sEvent == "click" && sElem == "btn_credits_close")
    {
        NuiDestroy (oPlayer, nToken);
    }
  }
}
