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

Pointer will figure out based on remote and branch name the correct URL and format it accordingly.

## Key maps

```
yU           - will get the link to the current line
yu (visual)  - will get the link for the current selection
yu(operator) - will get the link for the lines within the operator boundaries
```

## TODO

- [ ] Other remote URL formats
- [ ] Other version control systems
- [ ] Other outputs that are not remote URLs (i.e. local files relative to repository root)
