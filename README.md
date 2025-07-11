
# NWN NUI Iterative GUI Development Log

This repository documents an iterative development process for building and validating NUI-based GUIs in Neverwinter Nights: Enhanced Edition (NWN:EE).  
The goal is to create a structured, reproducible workflow for learning and generating NWScript GUI layouts using native functions from `nw_inc_nui`.

---

## 🧠 Project Summary

- The project is structured into iterations (`nwn_script_iterations_log.csv`)
- Each iteration includes a script (`ai-scripts/`), a UUID, and detailed notes
- GUI components are built using only valid `Nui*` functions such as `NuiTextEdit`, `NuiCol`, `NuiWindow`, `NuiCreate`
- All JSON is constructed through native functions: `JsonArrayInsert`, `JsonBool`, `JsonString`, `NuiRect`, etc.

---

## 📁 Folder Structure

```
├── ai-scripts/              # Generated NWScript files (NUI layout builders)
│   └── nui-textbox/         # GUI variations using textedit
│       └── <uuid>_*.nss
├── prompt/                  # Analytical notes, corrections, extracted insights
│   └── <uuid>_*.txt
├── data-feed/               # Source files from NWN Lexicon, NWVault, HTML docs, screenshots
├── nwn_script_iterations_log.csv  # Full iteration log with metadata
```

---

## ✅ Final GUI Result

The current final working script:
- [`ba98b9c6_nui_textbox_final.nss`](ai-scripts/nui-textbox/ba98b9c6_nui_textbox_final.nss)
- Confirmed functional via screenshot validation
- Features: centered window, title, resizable, closable, one-line textbox

---

## 🔁 Shareable Conversation Link

All decisions, feedback, corrections and generated iterations were recorded in this shared ChatGPT thread:  
📎 https://chatgpt.com/share/687052a6-7e98-8011-a260-b5ee8d39f592

---

## 📦 Setup

This repository contains all inputs and outputs required to track and understand the iterative GUI building process:
- Start from `nwn_script_iterations_log.csv`
- Explore generated scripts under `ai-scripts/`
- Check `prompt/` for design decisions and technical insights

---

## 💡 Future Features

- Bind watchers (`NuiGetBind`)
- Submit button & event handling
- DrawList integration
- Modular component generation

