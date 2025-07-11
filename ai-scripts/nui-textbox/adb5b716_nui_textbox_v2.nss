// UUID: adb5b716
// NUI Textbox Example — fully validated layout using official Nui* API

#include "nw_inc_nui"

void main()
{
    object oPC = OBJECT_SELF;
    string sId = "textbox_window";

    // Build textbox component
    json jTextbox = NuiTextEdit(
        JsonNull(),              // placeholder (optional bind)
        NuiBind("user_input"),   // value
        255,                     // max length
        FALSE                    // multiline
    );

    // Place textbox inside a column
    json jLayout = NuiCol(JsonArray(jTextbox));

    // Build the window
    json jWindow = NuiWindow(
        jLayout,
        JsonString("Text Input"),        // title
        JsonRect(-1.0, -1.0, 0.0, 0.0),   // center window on screen
        JsonBool(TRUE),                  // resizable
        JsonBool(FALSE),                 // collapsed default
        JsonBool(TRUE),                  // closable
        JsonNull(),                      // transparent
        JsonNull()                       // border
    );

    // Open the GUI
    NuiCreate(oPC, jWindow, sId);
}
