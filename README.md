# Introduction

This is an unofficial port of the emacs package [symbols-overlay](https://github.com/wolray/symbol-overlay) in neovim.

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
    "baosize-bot/symbols-overlay.nvim",
    opts = {},
    keys = {
        { "<leader>ho", function() require("symbols-overlay").add() end, desc = "Overlay: add current word" },
        { "<leader>hd", function() require("symbols-overlay").remove() end, desc = "Overlay: delete current" },
        { "<leader>hn", function() require("symbols-overlay").next() end, desc = "Overlay: next" },
        { "<leader>hN", function() require("symbols-overlay").prev() end, desc = "Overlay: prev" },
        { "<leader>hr", function() require("symbols-overlay").rename() end, desc = "Overlay: rename (buffer only)" },
        { "<leader>ht", function() require("symbols-overlay").toggle() end, desc = "Overlay: toggle current word" },
        { "<leader>h]", function() require("symbols-overlay").switch_forward() end, desc = "Overlay: switch to next nearby" },
        { "<leader>h[", function() require("symbols-overlay").switch_backward() end, desc = "Overlay: switch to prev nearby" },
    },
}

```

# Configuration

```lua
require("symbol-overlay").setup{
    colors = { -- 10 preset colors
        "SymbolsOverlay1",
        "SymbolsOverlay2",
        "SymbolsOverlay3",
        "SymbolsOverlay4",
        "SymbolsOverlay5",
        "SymbolsOverlay6",
        "SymbolsOverlay7",
        "SymbolsOverlay8",
        "SymbolsOverlay9",
    },
}
```

## Todo

- [ ] Highlight pattern in a text object only
