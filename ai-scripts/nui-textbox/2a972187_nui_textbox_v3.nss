// UUID: 2a972187
// NUI Textbox Example — strict version using only verified and properly typed NUI APIs

#include "nw_inc_nui"

void main()
{
    object oPC = GetLastUsedBy(); // safer than OBJECT_SELF
    if (!GetIsPC(oPC)) return;

    const string BIND_INPUT = "user_input";
    const string WINDOW_ID = "textbox_window";

    // Create textbox component
    json jTextbox = NuiTextEdit(
        JsonString(""),         // Placeholder
        NuiBind(BIND_INPUT),    // Value bind
        255,                    // Max length
        FALSE                   // Multiline
    );

    // Add textbox to layout array
    json jLayoutList = JsonArray();
    jLayoutList = JsonArraySet(jLayoutList, 0, jTextbox);

    json jLayout = NuiCol(jLayoutList);

    // Define window geometry (centered, 300x100)
    json jRect = JsonRect(-1.0, -1.0, 300.0, 100.0);

    // Create window
    json jWindow = NuiWindow(
        jLayout,
        JsonString("Text Input"),
        jRect,
        JsonBool(TRUE),     // Resizable
        JsonBool(FALSE),    // Collapsed default
        JsonBool(TRUE),     // Closable
        JsonBool(FALSE),    // Not transparent
        JsonBool(FALSE)     // With border
    );

    // Show it
    NuiCreate(oPC, jWindow, WINDOW_ID);
}
