// UUID: 68c20e0b
// Corrected NUI textbox example using only valid Nui* functions from nw_inc_nui.

#include "nw_inc_nui"

void main()
{
    object oPC = OBJECT_SELF;
    string sId = "textbox_window";

    // Create the textbox component using NuiTextEdit
    json jTextbox = NuiTextEdit("user_input");

    // Layout: single column with the textbox inside
    json jLayout = NuiCol(JsonArray(jTextbox));

    // Create the window using NuiWindow with standard title bar
    json jWindow = NuiWindow("Text Entry Example", jLayout);
    jWindow = NuiSetClosable(jWindow, TRUE);
    jWindow = NuiSetCollapsible(jWindow, TRUE);
    jWindow = NuiSetResizable(jWindow, TRUE);

    // Open the NUI window for the player
    NuiStart(oPC, sId, jWindow);
}
