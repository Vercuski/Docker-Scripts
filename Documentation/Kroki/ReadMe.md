# Kroki
One HTTP API that renders diagrams-as-code to SVG / PNG / PDF: PlantUML, C4-PlantUML, Structurizr DSL, Graphviz, D2,
Mermaid, BPMN, Excalidraw, Ditaa, ERD, Nomnoml, Vega and more. Endpoint: http://localhost:8000
(from other containers: `http://kroki:8000`).

```sh
curl -H "Content-Type: text/plain" --data-binary @diagram.puml http://localhost:8000/plantuml/svg > diagram.svg
```

Mermaid, BPMN and Excalidraw are rendered by the companion containers (`kroki-mermaid`, `kroki-bpmn`,
`kroki-excalidraw`); everything else by the main container. Stateless, no volumes.<br>
Tools with a Kroki or PlantUML-server setting (for example Asciidoctor, MkDocs plugins and VS Code extensions)
can point at this server instead of the public kroki.io.

https://docs.kroki.io/
