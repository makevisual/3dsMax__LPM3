# Adding a New Operator to LPM

Operators are the per-pass / per-shot override nodes in the tree (e.g. Camera
Overscan, Render Image, Nuke Export, V-Ray Render Elements). Adding one means
registering the same new node type in several coordinated places. Use an
existing operator as a working template — **`cameraOverscan` is the most
complete reference**; grep the codebase for `cameraOverscan` to see every
touch point in context.

In the steps below, replace `foo` / `Foo` with your operator's type string and
name (the type string is what gets stored in the node's `.type` and matched in
every `case` block).

## 1. Data model — `LPM/CA.ms`
Define the persistent custom attribute that holds the operator's settings:
```
fooPropsCA = attributes fooProps ( parameters main ( ... ) )
```
This is the only persisted piece; everything below is runtime UI/logic.

## 2. Operator logic + editor UI — `LPM/operator_foo.ms` and `LPM/rcMenus/rcMenu_fooOverride.ms`
- `operator_foo.ms`: what the operator does at render time.
- `rcMenu_fooOverride.ms`: the editor rollout (`fooPropsRoll`), its right-click
  menu (`rc_fooPropsMenu`), and the `EditFoo()` entry point.

## 3. Load the editor — `LPM/rcMenus.ms` (top of file)
```
filein @"rcMenus\rcMenu_fooOverride.ms"
```

## 4. Icons — `LPM/Treeview.ms`, `initTreeView`
Register the enabled/disabled icon pair with `getIconFromBitmap` /
`getIconFromFolder`. **Icons are referenced by positional index — always append
at the end of the list; never insert**, or every later operator's icons shift.

## 5. Icon selection — `LPM/Functions.ms`, `setIcon`
```
"foo":LPM_Fun.setImageIndex theNode theNode.tag.value.active <onIndex> <offIndex>
```

## 6. Node label — `LPM/Treeview.ms`, `createTVnode`
```
"foo": nodeName = (LPM_Fun.generateFooName theNode)
```
and add the `generateFooName` helper in `LPM/Functions.ms` next to the other
`generate*Name` functions.

## 7. Pass/shot resolution — `LPM/Functions.ms`, `passByNode`
```
"foo":theNode.parent.tag.value
```

## 8. Attach the CA on node creation — `LPM/Functions.ms`, `createNode`
```
"foo":custAttributes.add theNode fooPropsCA
```

## 9. Dialog cleanup — `LPM/Functions.ms`, `destroyAllDialogs`
```
try(destroyDialog fooPropsRoll)catch()
```

## 10. Tree menus & interaction — `LPM/Treeview.ms`
- Right-click: `"foo":popUpMenu rc_fooPropsMenu`
- Double-click: `"foo":(EditFoo())`
- Tree building: a `firstChildByType ... "foo"` branch where the node is added
  under its shot/pass.
- An `Add Foo` `menuItem` plus its `on ... picked` handler in the relevant
  right-click menu (guard with `firstChildByType` so it can't be added twice).

## 11. Render-time hook (only if it acts during rendering) — `LPM/Render.ms`
Fetch it with `firstChildByType thePass/theShot "foo"` in the pre/post-render
path, mirroring how `cameraOverscan` is handled.

---
Quick audit when finished: `grep -rni "foo" LPM/ --include="*.ms"` should show an
entry in each of the locations above. A missing `case` branch typically surfaces
as the node showing a wrong/blank icon, no right-click menu, or an
"unknown property" error when the node is clicked.
