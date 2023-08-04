Just create a new folder in the collections folder and copy selected previews in there to create a new collection.

Run a tool periodically to replace copies with hardlinks, for ex:

```
finddupe.exe -hardlink -ref ./previews ./collections/
```