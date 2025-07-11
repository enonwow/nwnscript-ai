// UUID: ba98b9c6
// Final version — NUI Textbox using validated layout and NuiRect

#include "nw_inc_nui"

const string BIND_INPUT = "user_input";
const string WINDOW_ID = "textbox_window";

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetIsPC(oPC)) return;

    // Textbox component
    json jTextbox = NuiTextEdit(
        JsonString(""),         // Placeholder
        NuiBind(BIND_INPUT),    // Bound value
        255,                    // Max length
        FALSE                   // Single line
    );

    // Layout array
    json jList = JsonArray();
    jList = JsonArrayInsert(jList, jTextbox);

    json jLayout = NuiCol(jList);

    // Use NuiRect helper
    json jRect = NuiRect(-1.0, -1.0, 300.0, 100.0);

    // Build window
    json jWindow = NuiWindow(
        jLayout,
        JsonString("Text Input"),
        jRect,
        JsonBool(TRUE),
        JsonBool(FALSE),
        JsonBool(TRUE),
        JsonBool(FALSE),
        JsonBool(FALSE)
    );

    // Show it
    NuiCreate(oPC, jWindow, WINDOW_ID);
}
