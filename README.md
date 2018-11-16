# pointer.nvim

Share file references instantly

## Why

Pointer allows rapid communication within the team around a codebase by allowing
team members to share points on the codepath (file + linenumber) information.

## How it works
Pointer looks up your project directory structure and tries its best to
build an url so you can get the current line as a shareable url:

```python
...
10 def myfn(arg): # running here
11     pass
...
```

Will yield `https://github.com/owner/project/master/blob/path/to/file.py#L10`

Pointer tries to match data from its configuration, the file and its path:
`/home/user/code/owner/project/path/to/file`

It will use cwd to determine project root, so: `tcd /home/user/code/owner/project`
By convention, pointer.nvim assumes that projects follow the `owener/project` directory structure.
You can override that behavior with custom functions.

## How to set up

Create a `pointer.lua` file for configuring your pointer in your config dir

```lua
local pointer = require("pointer")

-- This configures github for all projects
pointer.config{
  url = pointer.url.github,
}

-- I'll explain mapping later. leave this to bind to default keybindings
pointer.map{}
```

and in your `init.vim`:
```vim
luafile $HOME/.config/nvim/pointer.lua
```

## A slightly more complex configuration

```lua
local pointer = require("pointer")

-- This configures github for all projects
pointer.config{
  url = pointer.url.github,
  myteam = {
    url = pointer.url.opengrok("https://opengrok.myteam.com/xref/")
  },
  mycustomproj = {
    url = pointer.urls.gitlab
  }
}

-- I'll explain mapping later. leave this to bind to default keybindings
pointer.map{}
```

it will try to match first based on the project, than on the owner, then it'll use the general rule:
`/home/user/code/myteam/mycustomproj/... -> gitlab`
`/home/user/code/myteam/second/... -> opengrok`
`/home/user/code/vigemus/pointer.nvim/... -> github`

## Mappings

If you use default mappings, it'll map:
```
yu -> As url
ypp -> As a relative path from project owner (project/path/to/file.py)
yrp -> As a relative path from your project (path/to/file.py)
yRp -> As an absolute path (/home/user/code/owner/path/to/project.py)
```

## TODO

- [ ] Write tests
- [ ] Collect git branch data
- [ ] Allow custom collectors
- [ ] Better user customization
- [ ] Allow references to Pull-Request/Merge-Request
