# jb-inspect.nvim

Nvim plugin that utilizes [JetBrains.ReSharper.GlobalTools](https://www.jetbrains.com/help/resharper/InspectCode.html) `InspectCode Command-Line Tool` to view code issues for a single C# file. ([JetBrains.ReSharper.GlobalTools Installation guide](https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html#install-and-use-resharper-command-line-tools-as-net-core-tools))

## Usage

`JbInspect` user command executes `jb inspect` for current buffer and populates quickfix list with code issues

## Installation

- install using [lazy.nvim](https://github.com/folke/lazy.nvim)

```
{
    "pakhv/jb-inspect.nvim",
    config = function()
        require 'jb-inspect'
    end
}
```
