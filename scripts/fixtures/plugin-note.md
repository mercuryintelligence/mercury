---
product: plugins
title: "Market Data 1.12: how regimes are measured, and how fresh each layer is"
date: 2026-09-30
version: 0.4.0
kind: release
summary: "Regime readings now show how they are built and how fresh each layer is."
highlight: true
docs:
  - /docs/plugins/methodology
source:
  repo: plugins
  tag: v0.4.0
  range: v1.11.0..v1.12.0
  bundle: plugins/1.12.0
---

The regime view now shows how each measure is built, from the raw observations to the label you see, and it says how fresh every layer is. We chose to publish the method next to the result so that an assistant can explain a reading instead of only repeating it.

Every layer carries its own delay. The beta data is delayed by ten minutes, and the slowest layer sets the pace of the label. Regimes describe the recent past; they do not forecast anything and they do not cover instruments outside the documented universe. See [the methodology](/docs/plugins/methodology) for the full definitions.
