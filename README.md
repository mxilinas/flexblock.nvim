# Flexblock
> Compress and decompress code blocks.

## Example

    coords = [[0, 1], [1, 2], [5, 9], [2, 7]] 

    coords = [
        [0, 1],
        [1, 2],
        [5, 9],
        [2, 7],
    ] 

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    "mxilinas/flexblock.nvim",
    config = function()
        vim.keymap.set("n", "<Leader>fl", function()
            require("flexblock").flex()
        end)
    end,
}
```
