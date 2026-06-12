# Strideborn

> A walking-born sandbox. PvE on real routes, and **everything in the world is player-crafted** — no NPC vendors, ever.

**Live:** https://whoseyci.github.io/Strideborn/

## v0 prototype
- Steps → stride points (1:1). Dev buttons simulate walking; on mobile, "use real steps" enables motion-sensor step detection.
- Stride points spend on **gathering** (5 resource tiers across biomes).
- Resources feed a **crafting chain** (T1 cord/haft → T2 maul/ingot → T3 waystone shard).
- State persists in localStorage.

## Dev
```bash
npm install
npm run dev      # local dev server
npm run build    # production build (dist/)
```

Pushes to `main` auto-deploy to GitHub Pages via Actions.

## Roadmap (discussed, not yet built)
- Map shards & route-bound PvE encounters
- Player market stalls (the only shops are player shops)
- Capacitor wrap for native pedometer + background step counting
- Multiplayer shard state
