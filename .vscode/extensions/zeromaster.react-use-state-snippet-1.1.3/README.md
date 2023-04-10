# React-Use-State

When we use react with useHooks and use state,
Many snippets supplying just normal snippet.

So mostly snippets make like this.
```
"const [ $1, set$1 ] = React.useState<>();"
```
but this is not good to camelCase.

So I made it like

<a><img src="https://i.ibb.co/fkNLbcX/react-use-state-example.gif" alt="react-use-state-example" border="0"></a>

Make setter to CamelCase!!
---
---

This will be help for make setter on React.useState;

When we use useState with camelCase, we need to modify setter's name toUpperCase,

But this is can not ordered with default snippet, so I made it

If you select or have clipboard, ( like hello )

this will make to "setHello"

Done.


## Will make Function
### Auto Import useState
- Current supplying "React.useState", but will be read on settings.json by autoImport boolean

### Supply useEffect, useCallback, useMemo ~~ 
- If supply other useHooks too, extension name will be change