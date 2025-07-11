#include "nw_inc_nui"

const string WINDOW_ID = "20250711_1217_nui_label";
const string LABEL_BIND = "label_message";

void main()
{
    object oPC = OBJECT_SELF;

    json jLabel = NuiLabel(JsonString("Hello from NUI Label"));
    json jLayout = JsonArray();
    jLayout = JsonArrayInsert(jLayout, 0, jLabel);

    json jWindow = NuiWindow(
        NuiCol(jLayout),
        NuiRect(-1.0, -1.0, 300.0, 80.0),
        JsonString("Label Example"),
        JsonBool(TRUE), // closable
        JsonBool(TRUE), // collapsible
        JsonBool(TRUE)  // resizable
    );

    NuiCreate(oPC, jWindow, WINDOW_ID);
}
