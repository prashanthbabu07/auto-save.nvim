# auto-save.nvim

A simple Neovim plugin to automatically save files on events like `InsertLeave`, `TextChanged`, `FocusLost`, etc.

## 🔧 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "prashanthbabu07/auto-save.nvim",
  priority = 1000,
  config = function()
    require("auto-save").setup({
      delay = 500,
      delay_events = { "InsertLeave", "TextChanged" },
      instant_events = { "FocusLost", "BufLeave" },
    })
  end,
}
```

### Using [paker.nvim](https://github.com/wbthomason/packer.nvim)

```lua 
use({
  "prashanthbabu07/auto-save.nvim",
  config = function()
    require("auto-save").setup({
      delay = 500
      delay_events = { "InsertLeave", "TextChanged" },
      instant_events = { "FocusLost", "BufLeave" },
    })
  end,
})
```
