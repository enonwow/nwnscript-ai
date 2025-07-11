// UUID: 4121227d
// NUI Textbox Example — v4 with fixed JsonArrayInsert, manual rect, and global consts

#include "nw_inc_nui"

// Global constants
const string BIND_INPUT = "user_input";
const string WINDOW_ID = "textbox_window";

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetIsPC(oPC)) return;

    // Create textbox
    json jTextbox = NuiTextEdit(
        JsonString(""),         // Placeholder
        NuiBind(BIND_INPUT),    // Bound value
        255,                    // Max length
        FALSE                   // Single line
    );

    // Layout list
    json jList = JsonArray();
    jList = JsonArrayInsert(jList, jTextbox); // Corrected function

    json jLayout = NuiCol(jList);

    // Manual JSON Rect object (centered at -1.0, size 300x100)
    json jRect = JsonObject();
    jRect = JsonObjectSet(jRect, "x", JsonFloat(-1.0));
    jRect = JsonObjectSet(jRect, "y", JsonFloat(-1.0));
    jRect = JsonObjectSet(jRect, "w", JsonFloat(300.0));
    jRect = JsonObjectSet(jRect, "h", JsonFloat(100.0));

    // Build window
    json jWindow = NuiWindow(
        jLayout,
        JsonString("Text Input"),
        jRect,
        JsonBool(TRUE),     // Resizable
        JsonBool(FALSE),    // Not collapsed by default
        JsonBool(TRUE),     // Closable
        JsonBool(FALSE),    // Not transparent
        JsonBool(FALSE)     // Not borderless
    );

    // Create it
    NuiCreate(oPC, jWindow, WINDOW_ID);
}
