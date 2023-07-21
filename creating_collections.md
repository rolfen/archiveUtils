Just create a new folder in the collections folder and drop selected previews in there to create a collection.

Use a tool such as [LinkShellExtension](https://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html#contact) to create hardlinks or run a command periodically to replace duplicates with hardlinks, for ex:

```
finddupe.exe -hardlink -ref ./previews ./collections/
```