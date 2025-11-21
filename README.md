# Introduction

This is an unofficial port of the emacs package [symbol-overlay](https://github.com/wolray/symbol-overlay) in neovim.

# Feature

- Toggle highlight pattern under cursor
- Goto next/prev highlight
- Goto next/prev same pattern
- Query and replace pattern under cursor
- Clear all patterns

# Installation

By [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "baosize-bot/symbol-overlay.nvim",
    opts = {},
    keys = {
        { "<leader>ho", function() require("symbol-overlay").add() end, desc = "Overlay: add current word" },
        { "<leader>hd", function() require("symbol-overlay").remove() end, desc = "Overlay: delete current word" },
        { "<leader>hc", function() require("symbol-overlay").clear() end, desc = "Overlay: clear all word" },
        { "<leader>hn", function() require("symbol-overlay").next() end, desc = "Overlay: next" },
        { "<leader>hN", function() require("symbol-overlay").prev() end, desc = "Overlay: prev" },
        { "<leader>hr", function() require("symbol-overlay").rename() end, desc = "Overlay: rename" },
        { "<leader>ht", function() require("symbol-overlay").toggle() end, desc = "Overlay: toggle current word" },
        { "<leader>h]", function() require("symbol-overlay").switch_forward() end, desc = "Overlay: switch to next nearby highlight" },
        { "<leader>h[", function() require("symbol-overlay").switch_backward() end, desc = "Overlay: switch to prev nearby highlight" },
    },
}

```

# Configuration

```lua
require("symbol-overlay").setup{
    colors = { -- 10 preset colors
        "SymbolOverlay1",
        "SymbolOverlay2",
        "SymbolOverlay3",
        "SymbolOverlay4",
        "SymbolOverlay5",
        "SymbolOverlay6",
        "SymbolOverlay7",
        "SymbolOverlay8",
        "SymbolOverlay9",
    },
}
```

## Todo

- [ ] Highlight pattern in a text object only
