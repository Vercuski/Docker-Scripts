# Structurizr (local)
C4 model architecture diagrams as code. UI: http://localhost:8112<br>
<br>
Edit `workspace.dsl` in the `workspace` volume folder (`docker/volumes/Documentation/Structurizr/workspace`) with
any editor, then refresh the browser. A starter workspace is created on the first start. Diagram layout changes made
in the browser are saved to `workspace.json` next to it.<br>
<br>
This is the `local` command of the consolidated `structurizr/structurizr` image, which replaced Structurizr Lite
(end of life). To keep diagrams with a project instead, point the volume at that repo's docs folder.<br>
Kroki (Documentation/Kroki) can also render Structurizr DSL to SVG for docs pipelines.

https://docs.structurizr.com/local
