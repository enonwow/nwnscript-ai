#include "nwnx_damage"
#include "lib_nui"
#include "sql_bestiary"

const string BESTIARY_NUI_EVENT_SCRIPT = "lib_bestiary_eve";

const string BESTIARY_WINDOW = "BESTIARY_WINDOW";

const string BESTIARY_IMAGE = "BESTIARY_IMAGE";

const string BESTIARY_LEFT_LAYOUT = "BESTIARY_LEFT_LAYOUT";
const string BESTIARY_RIGHT_LAYOUT = "BESTIARY_RIGHT_LAYOUT";

const string BESTIARY_TURN_LEFT = "BESTIARY_TURN_LEFT";
const string BESTIARY_TURN_RIGHT = "BESTIARY_TURN_RIGHT";

const string BESTIARY_LOCK = "BESTIARY_LOCK";

const string BESTIARY_LEFT_ACTIVE_PAGE = "BESTIARY_LEFT_ACTIVE_PAGE";
const string BESTIARY_RIGHT_ACTIVE_PAGE = "BESTIARY_RIGHT_ACTIVE_PAGE";

const string BESTIARY_LENGTH = "BESTIARY_LENGTH";
const string BESTIARY_PORTRAITS = "BESTIARY_PORTRAITS";
const string BESTIARY_NAMES = "BESTIARY_NAMES";
const string BESTIARY_DESCRIPTIONS = "BESTIARY_DESCRIPTIONS";
const string BESTIARY_PAGES = "BESTIARY_PAGES";
const string BESTIARY_KILLS = "BESTIARY_KILLS";
const string BESTIARY_BOSSES = "BESTIARY_BOSSES";

const string BESTIARY_BESTIARY_CELL = "BESTIARY_BESTIARY_CELL";

const string BESTIARY_SCALE = "BESTIARY_SCALE";
const string BESTIARY_SCALE_WITDH = "BESTIARY_SCALE_WITDH";
const string BESTIARY_SCALE_HEIGHT = "BESTIARY_SCALE_HEIGHT";

const string BESTIARY_ELE_WIDTH = "BESTIARY_ELE_WIDTH";
const string BESTIARY_ELE_HEIGHT = "BESTIARY_ELE_HEIGHT";

const string BESTIARY_ANIMATION = "BESTIARY_ANIMATION";

const string BESTIARY_ID = "BESTIARY_ID";

const float  BESTIARY_TURN_PAGE_SPEED = 0.1;

//CONST FOR CREATURES
const string BESTIARY_CACHE = "BESTIARY_CACHE";

const string BESTIARY_LOCATION = "BESTIARY_LOCATION";
const string BESTIARY_TROPHY_1 = "BESTIARY_TROPHY_1";
const string BESTIARY_TROPHY_2 = "BESTIARY_TROPHY_2";
const string BESTIARY_TROPHY_3 = "BESTIARY_TROPHY_3";
const string BESTIARY_BOSS = "BESTIARY_BOSS";

const string BESTIARY_BOOK_CREATURE = "BESTIARY_BOOK_CREATURE";
const string BESTIARY_BOOK_KILLS = "BESTIARY_BOOK_KILLS";
const string BESTIARY_BOOK_EXP = "BESTIARY_BOOK_EXP";

void FeedBestiaryWindow(object oPC, int nToken);
void SwapBestiaryLayout(object oPC, int nToken, int nPage);
void IncreaseCache(object oPC, string sResRef, int nKills = 1);

void UseBestiaryBook(object oPC, object oBook)
{
    string sResRef = GetLocalString(oBook, BESTIARY_BOOK_CREATURE);
    int nKills = GetLocalInt(oBook, BESTIARY_BOOK_KILLS);
    int nExp = GetLocalInt(oBook, BESTIARY_BOOK_EXP);

    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(GetWaypointByTag(NW_THRASHBIN)));
    string sName = GetName(oCreature);
    int bBoss = GetLocalInt(oCreature, BESTIARY_BOSS);
    DestroyObject(oCreature);

    BestiaryInsert(oPC,
        sResRef,
        sName,
        bBoss,
        nKills);

    IncreaseCache(oPC, sResRef, nKills);

    DestroyObject(oBook);

    GiveXPToCreature(oPC, nExp);
}

void IncreaseBestiaryOnDeath(object oKiller, object oMonster)
{
    string sResRef = GetResRef(oMonster);
    string sName = GetName(oMonster);
    int bBoss = GetLocalInt(oMonster, BESTIARY_BOSS);

    object oPartyMember = GetFirstFactionMember(oKiller);
    while(GetIsObjectValid(oPartyMember))
    {
        if(GetIsPC(oPartyMember))
        {
            BestiaryInsert(oPartyMember, sResRef, sName, bBoss);
            IncreaseCache(oPartyMember, sResRef);
        }

        oPartyMember = GetNextFactionMember(oKiller);
    }
}

string GetCreatureEffect(object oCreature)
{
    json jCreature = ObjectToJson(oCreature);
    json jEquipItems = GffGetList(jCreature, "Equip_ItemList");

    int nLength = JsonGetLength(jEquipItems);

    string sName = "Efekty:";

    int i;
    for(i=0; i < nLength; i++)
    {
        json jItem = JsonArrayGet(jEquipItems, i);
        json jProperties = GffGetList(jItem, "PropertiesList");

        int nPropertiesLength = JsonGetLength(jProperties);

        int j;
        for(j=0; j<nPropertiesLength; j++)
        {
            json jPropertie = JsonArrayGet(jProperties, j);

            int nName = JsonGetInt(GffGetWord(jPropertie, "PropertyName"));

            int nSubtype = JsonGetInt(GffGetWord(jPropertie, "Subtype"));
            string sSub2da = Get2DAString("itempropdef", "SubTypeResRef", nName);

            sName += "\n" + GetStringByStrRef(StringToInt(Get2DAString("itempropdef", "GameStrRef", nName)));

            if(sSub2da != "")
            {
                sName += " " + GetStringByStrRef(StringToInt(Get2DAString(sSub2da, "Name", nSubtype)));
            }

            int nCostTable = JsonGetInt(GffGetByte(jPropertie, "CostTable"));
            if(nCostTable > 0)
            {
                string sCostTable2da = Get2DAString("iprp_costtable", "Name", nCostTable);
                int nCostValue = JsonGetInt(GffGetWord(jPropertie, "CostValue"));

                sName += " " + GetStringByStrRef(StringToInt(Get2DAString(sCostTable2da, "Name", nCostValue)));
            }
        }
    }

    return sName + "\n";
}

void CreateBestiaryCache(object oPC)
{
    string sQuery = "SELECT ResRef, Kills FROM bestiary WHERE uuid=? ORDER BY ResRef ASC";

    NWNX_SQL_PrepareQuery(sQuery);

    NWNX_SQL_PreparedString(0, GetObjectUUID(oPC));

    NWNX_SQL_ExecuteQuery(sQuery);

    json jCache = JsonObject();

    while (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();

        string sResRef = NWNX_SQL_ReadDataInActiveRow(0);
        string sKills = NWNX_SQL_ReadDataInActiveRow(1);

        jCache = JsonObjectSet(jCache, sResRef, JsonInt(StringToInt(sKills)));
    }

    SetLocalJson(oPC, BESTIARY_CACHE, jCache);
}

void IncreaseCache(object oPC, string sResRef, int nKills = 1)
{
    json jCache = GetLocalJson(oPC, BESTIARY_CACHE);

    json jKills = JsonObjectGet(jCache, sResRef);

    if (JsonGetType(jKills) == JSON_TYPE_NULL)
    {
        jCache = JsonObjectSet(jCache, sResRef, JsonInt(nKills)); 
    }
    else
    {
        JsonObjectSetInplace(jCache, sResRef, JsonInt(JsonGetInt(jKills) + nKills));
    }

    SetLocalJson(oPC, BESTIARY_CACHE, jCache);
}

struct NWNX_Damage_DamageEventData BestiaryAddDamageFromTrophy(object oAttacker, object oTarget, struct NWNX_Damage_DamageEventData EventDataDamage)
{
    json jKills = GetLocalJson(oAttacker, BESTIARY_CACHE);

    if (JsonGetType(jKills) == JSON_TYPE_NULL)
    {
        return EventDataDamage;
    }

    int nKills = JsonGetInt(JsonObjectGet(jKills, GetResRef(oTarget)));

    if(nKills == 0)
    {
        return EventDataDamage;
    }

    int nTrophy3 = GetLocalInt(oTarget, BESTIARY_TROPHY_3);
    int nTrophy2 = GetLocalInt(oTarget, BESTIARY_TROPHY_2);
    int nTrophy1 = GetLocalInt(oTarget, BESTIARY_TROPHY_1);

    int nExtraDamage;
    if(nTrophy3 > 0 && nKills >= nTrophy3)
    {
        nExtraDamage = 3;
    }
    else if(nTrophy2 > 0 && nKills >= nTrophy2)
    {
        nExtraDamage = 2;
    }
    else if(nTrophy1 > 0 && nKills >= nTrophy1)
    {
        nExtraDamage = 1;
    }
    else
    {
        nExtraDamage = 0;
    }

    EventDataDamage.iBase += nExtraDamage;

    return EventDataDamage;
}

//-------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------  NUI  -------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//
json CreateContentsLayout(object oPC, int nToken, int nLength)
{
    json jTamplate = JsonArray();

    json jLabelName = NuiLabel(
        NuiBind(BESTIARY_NAMES),
        JsonInt(NUI_HALIGN_CENTER),
        JsonInt(NUI_VALIGN_MIDDLE));
    jLabelName = NuiStyleForegroundColor(jLabelName, NuiColor(0, 0, 0));

    json jLabelPage = NuiLabel(
        NuiBind(BESTIARY_PAGES),
        JsonInt(NUI_HALIGN_CENTER),
        JsonInt(NUI_VALIGN_MIDDLE));
    jLabelPage = NuiStyleForegroundColor(jLabelPage, NuiColor(0, 0, 0));

    json jElements = JsonArray();
    jElements = JsonArrayInsert(jElements, jLabelName);
    jElements = JsonArrayInsert(jElements, jLabelPage);

    json jGroupCell = NuiId(NuiGroup(NuiRow(jElements), FALSE, NUI_SCROLLBARS_NONE), BESTIARY_BESTIARY_CELL);

    json jCell = NuiListTemplateCell(jGroupCell, 0.0, TRUE);

    jTamplate = JsonArrayInsert(jTamplate, jCell);

    json jList = NuiList(jTamplate, JsonInt(nLength), 50.0, FALSE, NUI_SCROLLBARS_AUTO);

    jList = NuiWidth(jList, JsonGetFloat(NuiGetBind(oPC, nToken, BESTIARY_ELE_WIDTH)));
    jList = NuiHeight(jList, JsonGetFloat(NuiGetBind(oPC, nToken, BESTIARY_ELE_HEIGHT)));

    return jList;
}

json CreatePageLayout(object oPC, int nToken, string sPortrait, string sName, string sText, string sPage)
{
    float fScaleWitdh = JsonGetFloat(NuiGetBind(oPC, nToken, BESTIARY_SCALE_WITDH));
    float fScaleHeight = JsonGetFloat(NuiGetBind(oPC, nToken, BESTIARY_SCALE_HEIGHT));

    float fNameW = 200.0 * fScaleWitdh;
    float fNameH = 35.0;

    float fOffsetW = 10 * fScaleWitdh;
    float fOffsetH = 10 * fScaleHeight;

    float fWidth = JsonGetFloat(NuiGetBind(oPC, nToken, BESTIARY_ELE_WIDTH)) - fOffsetW;
    float fHeight = JsonGetFloat(NuiGetBind(oPC, nToken, BESTIARY_ELE_HEIGHT)) - fOffsetH;

    float fImageW = 128.0;
    float fImageH = 200.0;

    float fPageW = 40.0 * fScaleWitdh;
    float fPageH = 35.0;

    json jCol = JsonArray();

    json jRow = JsonArray();
    {
        json jSpacer = NuiSpacer();
        json jLabel = NuiLabel(
            JsonString(sName),
            JsonInt(NUI_HALIGN_CENTER),
            JsonInt(NUI_VALIGN_MIDDLE));
        jLabel = NuiWidth(jLabel, fNameW);
        jLabel = NuiHeight(jLabel, fNameH);
        jLabel = NuiStyleForegroundColor(jLabel, NuiColor(0, 0, 0));

        jRow = JsonArrayInsert(jRow, jSpacer);
        jRow = JsonArrayInsert(jRow, jLabel);
        jRow = JsonArrayInsert(jRow, jSpacer);

        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    jRow = JsonArray();
    {
        json jSpacer = NuiSpacer();

        json jImage = NuiImage(
            JsonString(sPortrait + "l"),
            JsonInt(NUI_ASPECT_EXACT),
            JsonInt(NUI_HALIGN_CENTER),
            JsonInt(NUI_VALIGN_TOP));
        jImage = NuiWidth(jImage, fImageW);
        jImage = NuiHeight(jImage, fImageH);

        jRow = JsonArrayInsert(jRow, jSpacer);
        jRow = JsonArrayInsert(jRow, jImage);
        jRow = JsonArrayInsert(jRow, jSpacer);

        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    jRow = JsonArray();
    {
        json jEditText = NuiText(JsonString(sText), FALSE);
        jEditText = NuiWidth(jEditText, fWidth);
        jEditText = NuiHeight(jEditText, fHeight - fImageH - fPageH - fNameH);
        jEditText = NuiStyleForegroundColor(jEditText, NuiColor(0, 0, 0));

        jRow = JsonArrayInsert(jRow, jEditText);

        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    jRow = JsonArray();
    {
        json jSpacer = NuiSpacer();
        json jLabel = NuiLabel(
            JsonString(sPage),
            JsonInt(NUI_HALIGN_CENTER),
            JsonInt(NUI_VALIGN_MIDDLE));
        jLabel = NuiWidth(jLabel, fPageW);
        jLabel = NuiHeight(jLabel, fPageH);
        jLabel = NuiStyleForegroundColor(jLabel, NuiColor(0, 0, 0));

        jRow = JsonArrayInsert(jRow, jSpacer);
        jRow = JsonArrayInsert(jRow, jLabel);
        jRow = JsonArrayInsert(jRow, jSpacer);

        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }

    return NuiCol(jCol);
}

void CreateBestiaryWindow(object oPC, int bAnimation)
{
    float fImageW = 740.0;
    float fImageH = 472.0;

    float fScaleGui = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE) / 100.0;

    float fWindowW = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH)) / fScaleGui;
    float fWindowH = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT)) / fScaleGui;

    float fScaleW = fWindowW / fImageW;
    float fScaleH = fWindowH / fImageH;

    fScaleW = fScaleW > 2.0 ? 2.0 : fScaleW;
    fScaleH = fScaleH > 2.0 ? 2.0 : fScaleH;

    float fImageScaleW = fImageW * fScaleW;
    float fImageScaleH = fImageH * fScaleH;

    float fImageOffset = 150.0;
    float fSpacerBetween = 50.0;
    float fElementW = (fImageW - fSpacerBetween - fImageOffset) / 2 * fScaleW;
    float fElementH = 385.0 * fScaleH;

    float fWindowX = -1.0;
    float fWindowY = -1.0;

    json jCol = JsonArray();
    json jRow = JsonArray();
    {
        json jGroupRow = JsonArray();
        jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());

        json jLeftLayout = NuiId(NuiGroup(NuiRow(JsonArray()), FALSE, NUI_SCROLLBARS_NONE), BESTIARY_LEFT_LAYOUT);
        jLeftLayout = NuiWidth(jLeftLayout, fElementW);
        jLeftLayout = NuiHeight(jLeftLayout, fElementH);

        json jRightLayout = NuiId(NuiGroup(NuiRow(JsonArray()), FALSE, NUI_SCROLLBARS_NONE), BESTIARY_RIGHT_LAYOUT);
        jRightLayout = NuiWidth(jRightLayout, fElementW);
        jRightLayout = NuiHeight(jRightLayout, fElementH);

        json jGroupImageRow = JsonArray();
        jGroupImageRow = JsonArrayInsert(jGroupImageRow, NuiWidth(NuiSpacer(), 100.0 * fScaleW));
        jGroupImageRow = JsonArrayInsert(jGroupImageRow, jLeftLayout);
        jGroupImageRow = JsonArrayInsert(jGroupImageRow, NuiWidth(NuiSpacer(), 25.0 * fScaleW));
        jGroupImageRow = JsonArrayInsert(jGroupImageRow, jRightLayout);
        jGroupImageRow = JsonArrayInsert(jGroupImageRow, NuiSpacer());

        json jGroupImageCol = JsonArray();
        jGroupImageCol = JsonArrayInsert(jGroupImageCol, NuiHeight(NuiRow(jGroupRow), 22.5 * fScaleW));
        jGroupImageCol = JsonArrayInsert(jGroupImageCol, NuiRow(jGroupImageRow));
        jGroupImageCol = JsonArrayInsert(jGroupImageCol, NuiRow(jGroupRow));

        json jGroupImage = NuiGroup(NuiCol(jGroupImageCol), FALSE, NUI_SCROLLBARS_NONE);
        jGroupImage = NuiWidth(jGroupImage, fImageScaleW);
        jGroupImage = NuiHeight(jGroupImage, fImageScaleH);
        jGroupImage = NuiId(jGroupImage, BESTIARY_ID);

        json jImageBackground = NuiDrawListImage(
            JsonBool(TRUE),
            JsonString("book_bgd"),
            NuiRect(0.0,0.0, fImageScaleW, fImageScaleH),
            JsonInt(NUI_ASPECT_STRETCH),
            JsonInt(NUI_HALIGN_CENTER),
            JsonInt(NUI_VALIGN_MIDDLE),
            NUI_DRAW_LIST_ITEM_ORDER_BEFORE,
            NUI_DRAW_LIST_ITEM_RENDER_ALWAYS);

        json jImage = NuiDrawListImage(
            JsonBool(TRUE),
            NuiBind(BESTIARY_IMAGE),
            NuiRect(0.0,0.0, fImageScaleW, fImageScaleH),
            JsonInt(NUI_ASPECT_STRETCH),
            JsonInt(NUI_HALIGN_CENTER),
            JsonInt(NUI_VALIGN_MIDDLE),
            NUI_DRAW_LIST_ITEM_ORDER_BEFORE,
            NUI_DRAW_LIST_ITEM_RENDER_ALWAYS);

        json jImageList = JsonArray();
        jImageList = JsonArrayInsert(jImageList, jImageBackground);
        jImageList = JsonArrayInsert(jImageList, jImage);

        json jList = NuiDrawList(jGroupImage, JsonBool(FALSE), jImageList);

        json jGroupRow2 = JsonArray();
        jGroupRow2 = JsonArrayInsert(jGroupRow2, NuiSpacer());
        jGroupRow2 = JsonArrayInsert(jGroupRow2, jList);
        jGroupRow2 = JsonArrayInsert(jGroupRow2, NuiSpacer());

        json jElements = JsonArray();
        jElements = JsonArrayInsert(jElements, NuiRow(jGroupRow));
        jElements = JsonArrayInsert(jElements, NuiRow(jGroupRow2));
        jElements = JsonArrayInsert(jElements, NuiRow(jGroupRow));

        json jGroup = NuiGroup(NuiCol(jElements), FALSE, NUI_SCROLLBARS_NONE);

        jCol = JsonArrayInsert(jCol, jGroup);
    }

    json jRoot = NuiCol(jCol);

    json jNui = NuiWindow(
        jRoot,
        JsonBool(FALSE),
        NuiRect(fWindowX, fWindowY, fWindowW, fWindowH),
        JsonBool(FALSE),
        JsonBool(FALSE),
        JsonBool(FALSE),
        JsonBool(TRUE),
        JsonBool(FALSE),
        JsonBool(TRUE));

    int nToken = NuiCreate(oPC, jNui, BESTIARY_WINDOW, BESTIARY_NUI_EVENT_SCRIPT);

    NuiSetBind(oPC, nToken, BESTIARY_SCALE, JsonFloat(fScaleGui));
    NuiSetBind(oPC, nToken, BESTIARY_SCALE_WITDH, JsonFloat(fScaleW));
    NuiSetBind(oPC, nToken, BESTIARY_SCALE_HEIGHT, JsonFloat(fScaleH));

    NuiSetBind(oPC, nToken, BESTIARY_ELE_WIDTH, JsonFloat(fElementW));
    NuiSetBind(oPC, nToken, BESTIARY_ELE_HEIGHT, JsonFloat(fElementH));

    NuiSetBind(oPC, nToken, BESTIARY_ANIMATION, JsonBool(bAnimation));

    FeedBestiaryWindow(oPC, nToken);
    NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd"));
}

string CreateTextDefinition(object oPC, int nToken, int nIndex)
{
    string sDefinition = "";

    json jDescriptions = NuiGetBind(oPC, nToken, BESTIARY_DESCRIPTIONS);


    string sDescription = JsonGetString(JsonArrayGet(jDescriptions, nIndex));

    return sDefinition;
}

int SwapLeftLayout(object oPC, int nToken, int nLength, int nPage)
{
    if(nPage > nLength)
    {
        NuiSetGroupLayout(oPC, nToken, BESTIARY_LEFT_LAYOUT, NuiCol(JsonArray()));
        NuiSetBind(oPC, nToken, BESTIARY_LEFT_ACTIVE_PAGE, JsonInt(-1));
        return FALSE;
    }

    json jPortraits = NuiGetBind(oPC, nToken, BESTIARY_PORTRAITS);
    json jNames = NuiGetBind(oPC, nToken, BESTIARY_NAMES);
    json jDescriptions = NuiGetBind(oPC, nToken, BESTIARY_DESCRIPTIONS);
    json jPages = NuiGetBind(oPC, nToken, BESTIARY_PAGES);

    int nIndex = nPage - 1;

    string sPortrait = JsonGetString(JsonArrayGet(jPortraits, nIndex));
    string sName = JsonGetString(JsonArrayGet(jNames, nIndex));
    string sDescription = JsonGetString(JsonArrayGet(jDescriptions, nIndex));
    string sPage = JsonGetString(JsonArrayGet(jPages, nIndex));

    NuiSetGroupLayout(oPC, nToken, BESTIARY_LEFT_LAYOUT,
        CreatePageLayout(oPC, nToken, sPortrait, sName, sDescription, sPage));
    NuiSetBind(oPC, nToken, BESTIARY_LEFT_ACTIVE_PAGE, JsonInt(nPage));

    return nPage - 1 >= 1;
}

int SwapRightLayout(object oPC, int nToken, int nLength, int nPage)
{
    if(nPage > nLength)
    {
        NuiSetGroupLayout(oPC, nToken, BESTIARY_RIGHT_LAYOUT, NuiCol(JsonArray()));
        NuiSetBind(oPC, nToken, BESTIARY_RIGHT_ACTIVE_PAGE, JsonInt(-1));
        return FALSE;
    }

    json jPortraits = NuiGetBind(oPC, nToken, BESTIARY_PORTRAITS);
    json jNames = NuiGetBind(oPC, nToken, BESTIARY_NAMES);
    json jDescriptions = NuiGetBind(oPC, nToken, BESTIARY_DESCRIPTIONS);
    json jPages = NuiGetBind(oPC, nToken, BESTIARY_PAGES);

    int nIndex = nPage - 1;

    string sPortrait = JsonGetString(JsonArrayGet(jPortraits, nIndex));
    string sName = JsonGetString(JsonArrayGet(jNames, nIndex));
    string sDescription = JsonGetString(JsonArrayGet(jDescriptions, nIndex));
    string sPage = JsonGetString(JsonArrayGet(jPages, nIndex));

    NuiSetGroupLayout(oPC, nToken, BESTIARY_RIGHT_LAYOUT,
        CreatePageLayout(oPC, nToken, sPortrait, sName, sDescription, sPage));
    NuiSetBind(oPC, nToken, BESTIARY_RIGHT_ACTIVE_PAGE, JsonInt(nPage));

    return nPage + 1 <= nLength;
}

void SwapBestiaryLayout(object oPC, int nToken, int nPage)
{
    int nLength = JsonGetInt(NuiGetBind(oPC, nToken, BESTIARY_LENGTH));

    int bLeftAvailable;
    int bRightAvailable;

    if(nPage == 0 || nPage == 1)
    {
        if(nLength > 0)
        {
            json jContents = CreateContentsLayout(oPC, nToken, nLength);
            bLeftAvailable = FALSE;
            NuiSetBind(oPC, nToken, BESTIARY_LEFT_ACTIVE_PAGE, JsonInt(0));
            NuiSetGroupLayout(oPC, nToken, BESTIARY_LEFT_LAYOUT, jContents);
            bRightAvailable = SwapRightLayout(oPC, nToken, nLength, 1);
        }
        else
        {
            bLeftAvailable = FALSE;
            bRightAvailable = FALSE;
        }
    }
    else
    {
        int bNotEvenNumber = nPage % 2;

        if(!bNotEvenNumber)
        {
            bLeftAvailable = SwapLeftLayout(oPC, nToken, nLength, nPage);
            bRightAvailable = SwapRightLayout(oPC, nToken, nLength, nPage + 1);
        }
        else
        {
            bLeftAvailable = SwapLeftLayout(oPC, nToken, nLength, nPage - 1);
            bRightAvailable = SwapRightLayout(oPC, nToken, nLength, nPage);
        }
    }

    if(bLeftAvailable && !bRightAvailable)
    {
        NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_end"));
    }
    else if(bLeftAvailable && bRightAvailable)
    {
        NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_both"));
    }
    else if(!bLeftAvailable && bRightAvailable)
    {
        NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_start"));
    }
    else if(!bLeftAvailable && !bRightAvailable)
    {
        NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd"));
    }

    NuiSetBind(oPC, nToken, BESTIARY_TURN_RIGHT, JsonBool(bRightAvailable));
    NuiSetBind(oPC, nToken, BESTIARY_TURN_LEFT, JsonBool(bLeftAvailable));
}

void FeedBestiaryWindow(object oPC, int nToken)
{
    location lThrash = GetLocation(GetWaypointByTag(NW_THRASHBIN));

    json jName = JsonArray();
    json jPortraits = JsonArray();
    json jPage = JsonArray();
    json jDescription = JsonArray();

    json jKillsCache = GetLocalJson(oPC, BESTIARY_CACHE);
    json jKeys = JsonObjectKeys(jKillsCache);
    int nLength = JsonGetLength(jKeys);

    int i;
    for(i=0; i < nLength; i++)
    {
        string sResRef = JsonGetString(JsonArrayGet(jKeys, i));

        object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lThrash);
        string sDescription = "";

        jPortraits = JsonArrayInsert(jPortraits, JsonString(GetPortraitResRef(oCreature)));

        int nKills = JsonGetInt(JsonObjectGet(jKillsCache, sResRef));

        sDescription += "\n" + "Iość zabitych stworzeń: " + IntToString(nKills) + "\n";

        int bBoss = GetLocalInt(oCreature, BESTIARY_BOSS);

        sDescription += "\n" + "Boss: " + (bBoss ? "Tak" : "Nie") + "\n";

        int nTrophy1 = GetLocalInt(oCreature, BESTIARY_TROPHY_1);
        int nTrophy2 = GetLocalInt(oCreature, BESTIARY_TROPHY_2);
        int nTrophy3 = GetLocalInt(oCreature, BESTIARY_TROPHY_3);

        sDescription += "\n" + "Pierwsze trofeum: " + IntToString(nTrophy1)
            + "\n" + "Drugie trofeum: " + IntToString(nTrophy2)
            + "\n" + "Trzecie trofeum: " + IntToString(nTrophy3) + "\n";

        if(nTrophy1 <= 0)
        {
            sDescription += "\n Brak pierwszego trofeum skontaktuj się z administracją. \n";
        }
        else if(nKills > nTrophy1)
        {
            sDescription += "\n" + GetCreatureEffect(oCreature);
        }

        if(nTrophy2 <= 0)
        {
            sDescription += "\n Brak drugiego trofeum skontaktuj się z administracją. \n";
        }
        else if(nKills > nTrophy2)
        {
            sDescription += "\nWystępowanie: " + GetLocalString(oCreature, BESTIARY_LOCATION) + "\n";
        }

        sDescription += "\n" + GetDescription(oCreature);
        jDescription = JsonArrayInsert(jDescription, JsonString(sDescription));

        jPage = JsonArrayInsert(jPage, JsonString("Strona " + IntToString(i + 1)));
        jName = JsonArrayInsert(jName, JsonString(GetName(oCreature)));

        DestroyObject(oCreature);        
    }

    NuiSetBind(oPC, nToken, BESTIARY_LENGTH, JsonInt(nLength));
    NuiSetBind(oPC, nToken, BESTIARY_PORTRAITS, jPortraits);
    NuiSetBind(oPC, nToken, BESTIARY_NAMES, jName);
    NuiSetBind(oPC, nToken, BESTIARY_DESCRIPTIONS, jDescription);
    NuiSetBind(oPC, nToken, BESTIARY_PAGES, jPage);
}

void TurnRightPage(object oPC, int nToken, int nPage)
{
    int bAnimation = JsonGetInt(NuiGetBind(oPC, nToken, BESTIARY_ANIMATION));

    NuiSetBind(oPC, nToken, BESTIARY_LOCK, JsonBool(TRUE));
    NuiSetGroupLayout(oPC, nToken, BESTIARY_LEFT_LAYOUT, NuiCol(JsonArray()));
    NuiSetGroupLayout(oPC, nToken, BESTIARY_RIGHT_LAYOUT, NuiCol(JsonArray()));

    float fDelay = 0.0;

    if(bAnimation)
    {
        NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_right1"));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_right2")));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_right3")));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_left3")));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_left2")));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_left1")));
    }
    DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
        SwapBestiaryLayout(oPC, nToken, nPage));

    DelayCommand(fDelay, NuiSetBind(oPC, nToken, BESTIARY_LOCK, JsonBool(FALSE)));
}

void GoToContents(object oPC, int nToken)
{
    TurnRightPage(oPC, nToken, 0);
}

void AnimationTurnRightPage(object oPC, int nToken)
{
    int nRightPage = JsonGetInt(NuiGetBind(oPC, nToken, BESTIARY_RIGHT_ACTIVE_PAGE));

    TurnRightPage(oPC, nToken, nRightPage + 1);
}

void AnimationTurnLeftPage(object oPC, int nToken)
{
    int bAnimation = JsonGetInt(NuiGetBind(oPC, nToken, BESTIARY_ANIMATION));

    NuiSetBind(oPC, nToken, BESTIARY_LOCK, JsonBool(TRUE));
    NuiSetGroupLayout(oPC, nToken, BESTIARY_LEFT_LAYOUT, NuiCol(JsonArray()));
    NuiSetGroupLayout(oPC, nToken, BESTIARY_RIGHT_LAYOUT, NuiCol(JsonArray()));

    int nLeftPage = JsonGetInt(NuiGetBind(oPC, nToken, BESTIARY_LEFT_ACTIVE_PAGE));

    float fDelay = 0.0;

    if(bAnimation)
    {
        NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_left1"));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_left2")));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_left3")));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_right3")));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_right2")));
        DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
            NuiSetBind(oPC, nToken, BESTIARY_IMAGE, JsonString("book_bgd_right1")));
    }
    DelayCommand(fDelay += BESTIARY_TURN_PAGE_SPEED,
        SwapBestiaryLayout(oPC, nToken, nLeftPage - 1));

    DelayCommand(fDelay, NuiSetBind(oPC, nToken, BESTIARY_LOCK, JsonBool(FALSE)));
}
