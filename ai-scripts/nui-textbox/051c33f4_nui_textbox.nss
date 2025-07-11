// UUID: 051c33f4
// NUI Textbox Example — basic window with a single textedit field.

void main()
{
    object oPC = OBJECT_SELF;
    string sWindowId = "textbox_demo";

    // Create root JSON layout
    json jRoot = Json_CreateObject();
    Json_SetString(jRoot, "id", sWindowId);
    Json_SetString(jRoot, "type", "window");
    Json_SetString(jRoot, "title", "Text Input Example");
    Json_SetBool(jRoot, "resizable", TRUE);
    Json_SetBool(jRoot, "closable", TRUE);
    Json_SetBool(jRoot, "collapsible", TRUE);

    // Layout content: a column with a single textedit component
    json jContent = Json_CreateArray();
    json jTextbox = Json_CreateObject();
    Json_SetString(jTextbox, "type", "textedit");
    Json_SetString(jTextbox, "id", "input_text");
    Json_SetString(jTextbox, "bind", "user_input");

    Json_ArrayAdd(jContent, jTextbox);
    Json_SetJson(jRoot, "children", jContent);

    NuiOpen(oPC, sWindowId, jRoot);
}
