/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_player_target
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Runs code for player targeting - used int teleport buttons.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_database"

void DoTeleportEffects (object oPlayer, location lLocation)
{
    int nSelected = GetServerDatabaseInt (oPlayer, PLAYER_TABLE, "effects");
    if (nSelected == 0) AssignCommand (oPlayer, JumpToLocation (lLocation));
    else if (nSelected == 1)
    {
        effect eVisualStart = EffectVisualEffect (VFX_FNF_SUMMON_MONSTER_1);
        effect eVisualMiddle = EffectVisualEffect (423);
        effect eVisualEnd = EffectVisualEffect (VFX_FNF_SUMMON_MONSTER_2);
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualStart, GetLocation (oPlayer));
        DelayCommand (1.0f, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eVisualMiddle, oPlayer, 3.5f));
        DelayCommand (2.0f, AssignCommand (oPlayer, JumpToLocation (lLocation)));
        DelayCommand (1.0f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualEnd, lLocation));
    }
    else if (nSelected == 2)
    {
        effect eVisualStart = EffectVisualEffect (VFX_FNF_SUMMON_CELESTIAL);
        effect eVisualMiddle = EffectVisualEffect (VFX_DUR_AURA_PULSE_BLUE_YELLOW);
        effect eVisualEnd = EffectVisualEffect (VFX_FNF_SUMMON_GATE);
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualStart, GetLocation (oPlayer));
        DelayCommand (3.0f, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eVisualMiddle, oPlayer, 7.5f));
        DelayCommand (5.5f, AssignCommand (oPlayer, JumpToLocation (lLocation)));
        DelayCommand (2.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualEnd, lLocation));
    }
}

void DoSummonsEffects (object oPlayer, object oSummons, location lLocation)
{
    object oNewSummons;
    int nSelected = GetServerDatabaseInt (oPlayer, PLAYER_TABLE, "effects");
    if (nSelected == 0) CopyObject (oSummons, lLocation);
    else if (nSelected == 1)
    {
        effect eVisualStart = EffectVisualEffect (d4() + 32);
        effect eVisualMiddle = EffectVisualEffect (423);
        effect eVisualEnd = EffectVisualEffect (d4() + 32);
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualStart, lLocation);
        oNewSummons = CopyObject (oSummons, lLocation);
        DelayCommand (1.0f, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eVisualMiddle, oNewSummons, 3.5f));
        DelayCommand (1.0f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualEnd, lLocation));
    }
    else if (nSelected == 2)
    {
        int nVMiddle, nVStart = d6 ();
        switch (nVStart)
        {
            case 1 : nVStart = VFX_FNF_PWKILL; nVMiddle = VFX_DUR_GLOW_LIGHT_RED; break;
            case 2 : nVStart = VFX_FNF_DISPEL_DISJUNCTION; nVMiddle = VFX_DUR_GLOW_LIGHT_PURPLE; break;
            case 3 : nVStart = VFX_FNF_METEOR_SWARM; nVMiddle = VFX_DUR_GLOW_LIGHT_BROWN; break;
            case 4 : nVStart = VFX_FNF_FIRESTORM; nVMiddle = VFX_DUR_GLOW_LIGHT_ORANGE; break;
            case 5 : nVStart = VFX_FNF_IMPLOSION; nVMiddle = VFX_DUR_GLOW_LIGHT_YELLOW; break;
            case 6 : nVStart = VFX_FNF_SUMMON_GATE; nVMiddle = VFX_DUR_GLOW_LIGHT_YELLOW; break;
            case 7 : nVStart = VFX_FNF_SUMMON_CELESTIAL; nVMiddle = VFX_DUR_GLOW_LIGHT_BLUE; break;
            case 8 : nVStart = VFX_FNF_SUMMONDRAGON; nVMiddle = VFX_DUR_GLOW_LIGHT_YELLOW; break;
        }
        effect eVisualStart = EffectVisualEffect (nVStart);
        effect eVisualMiddle = EffectVisualEffect (nVMiddle);
        effect eVisualEnd = EffectVisualEffect (d6 () + 257);
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualStart, lLocation);
        oNewSummons =CopyObject (oSummons, lLocation);
        DelayCommand (1.0f, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eVisualMiddle, oNewSummons, 3.5f));
        DelayCommand (1.0f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualEnd, lLocation));
    }
}

void main ()
{
    object oPlayer = GetLastPlayerToSelectTarget ();
    object oTarget = GetTargetingModeSelectedObject ();
    // Get the target mode passed from 0e_window 1 - teleport 2 - summons
    int nTargetMode = GetLocalInt (oPlayer, "0_TARGET_MODE");
    // Teleport mode.
    if (nTargetMode == 1)
    {
        vector vVector = GetTargetingModeSelectedPosition ();
        if (vVector != Vector (0.0f, 0.0f, 0.0f))
        {
            location lLocation = Location (GetArea (oPlayer), vVector, GetFacing (oPlayer));
            DoTeleportEffects (oPlayer, lLocation);
        }
    }
    // Summons mode.
    else if (nTargetMode == 2)
    {
        // They selected a creature.
        if (GetObjectType (oTarget) == OBJECT_TYPE_CREATURE)
        {
            SetLocalObject (oPlayer, "0_SUMMONS" + IntToString (nTargetMode), oTarget);
            SendMessageToPC (oPlayer, "You have saved " + GetName (oTarget) + " to the button.");
            int nToken = GetLocalInt (oPlayer, "0_TOKEN");
            NuiSetBind (oPlayer, nToken, "btn_summons_label", JsonString (GetName (oTarget)));

        }
        // They selected the ground.
        else
        {
            oTarget = GetLocalObject (oPlayer, "0_SUMMONS" + IntToString (nTargetMode));
            object oArea = GetArea (oPlayer);
            vector vTarget = GetTargetingModeSelectedPosition ();
            location lLocation = Location (oArea, vTarget, GetFacing (oPlayer));
            DoSummonsEffects (oPlayer, oTarget, lLocation);
        }
    }
    // Broadcast mode.
    else if (nTargetMode == 3)
    {
        // Targeting yourself clears all targeting modes.
        if (oTarget != OBJECT_INVALID)
        {
            if (oTarget == oPlayer)
            {
                DeleteLocalObject (oPlayer, "0_Dice_Target");
                SendMessageToPC (oPlayer, "You have cleared your dice target and now all dice rolls will be for your character.");
                return;
            }
            if (GetIsDM (oPlayer))
            {
                SetLocalObject (oPlayer, "0_Dice_Target", oTarget);
                SendMessageToPC (oPlayer, "You set " + GetName (oTarget) + " to roll dice for.");
                SendMessageToPC (oPlayer, "Defaults to local broadcast mode, but you can change it.");
            }
            else
            {
                if (GetMaster (oTarget) == oPlayer)
                {
                    SetLocalObject (oPlayer, "0_Dice_Target", oTarget);
                    SendMessageToPC (oPlayer, "You set " + GetName (oTarget) + " to roll dice for.");
                    SendMessageToPC (oPlayer, "Defaults to DM broadcast mode, but you can change it.");
                    SendMessageToPC (oPlayer, "Target yourself to clear your dice target.");
                }
                else SendMessageToPC (oPlayer, "You can only target your associates!");
            }
        }
    }
}



