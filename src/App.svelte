<script lang="ts">
  import { onMount } from "svelte";
  import {
    NODES, RECIPES, load, save, addSteps, gather, craft, canCraft,
    type PlayerState, type ResourceNode, type Recipe,
  } from "./lib/game";

  let p: PlayerState = load();
  let stepSensor: "manual" | "live" = "manual";
  let toast = "";
  let toastTimer: ReturnType<typeof setTimeout>;

  function notify(msg: string) {
    toast = msg;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => (toast = ""), 2200);
  }

  function persist() { save(p); }

  function walk(n: number) {
    p = addSteps(p, n);
    persist();
  }

  function doGather(node: ResourceNode) {
    const next = gather(p, node);
    if (!next) { notify(`Need ${node.costPerTick} stride — keep walking.`); return; }
    p = next; persist();
  }

  function doCraft(r: Recipe) {
    const next = craft(p, r);
    if (!next) { notify("Missing materials."); return; }
    p = next; persist();
    notify(`${r.name} crafted.`);
  }

  // Live step detection via device motion (works on mobile browsers as PWA).
  // v0: a simple peak detector — replaced later by Capacitor pedometer plugin.
  let motionOK = false;
  let lastMag = 0, lastStepAt = 0;
  function enableMotion() {
    const D = (window as any).DeviceMotionEvent;
    const start = () => {
      window.addEventListener("devicemotion", (e: DeviceMotionEvent) => {
        const a = e.accelerationIncludingGravity;
        if (!a) return;
        const mag = Math.sqrt((a.x ?? 0) ** 2 + (a.y ?? 0) ** 2 + (a.z ?? 0) ** 2);
        const now = performance.now();
        if (mag > 13 && lastMag <= 13 && now - lastStepAt > 350) {
          lastStepAt = now;
          walk(1);
        }
        lastMag = mag;
      });
      motionOK = true; stepSensor = "live";
      notify("Live step detection on — walk!");
    };
    if (D?.requestPermission) D.requestPermission().then((s: string) => s === "granted" && start());
    else if (D) start();
    else notify("No motion sensor here — use the walk buttons.");
  }

  $: inventoryRows = Object.entries({ ...p.inventory }).filter(([, v]) => v > 0);
  $: craftedRows = Object.entries({ ...p.crafted }).filter(([, v]) => v > 0);

  onMount(() => { document.title = `Strideborn — ${p.steps.toLocaleString()} steps`; });
  $: if (typeof document !== "undefined") document.title = `Strideborn — ${p.steps.toLocaleString()} steps`;
</script>

<main>
  <header>
    <div class="brand">
      <svg viewBox="0 0 64 64" width="34" height="34" aria-hidden="true">
        <rect width="64" height="64" rx="14" fill="#16201a"/>
        <path d="M22 46c0-10 6-12 6-20 0-4-2-6-2-6s8 2 8 12c0 7-4 9-4 14" fill="none" stroke="#7dc98f" stroke-width="3.5" stroke-linecap="round"/>
        <circle cx="38" cy="18" r="3" fill="#e8b54a"/>
      </svg>
      <div>
        <h1>Strideborn</h1>
        <p class="tag">everything here was carried by someone's legs</p>
      </div>
    </div>
    <div class="stride-meter" aria-live="polite">
      <span class="big">{p.stride.toLocaleString()}</span>
      <span class="lbl">stride points</span>
      <span class="sub">{p.steps.toLocaleString()} lifetime steps</span>
    </div>
  </header>

  <section class="walk-bar">
    {#if stepSensor === "manual"}
      <button class="walk" on:click={() => walk(100)}>+100 steps <small>(dev)</small></button>
      <button class="walk" on:click={() => walk(1000)}>+1,000 steps <small>(dev)</small></button>
      <button class="sensor" on:click={enableMotion}>📍 use real steps</button>
    {:else}
      <div class="live">● live — phone in pocket, go walk</div>
    {/if}
  </section>

  <div class="cols">
    <section>
      <h2>Gather <span class="hint">spend stride while “passing through”</span></h2>
      <ul class="nodes">
        {#each NODES as n}
          <li>
            <button class="node" disabled={p.stride < n.costPerTick} on:click={() => doGather(n)}>
              <span class="n-name">{n.name}</span>
              <span class="n-biome">{n.biome}</span>
              <span class="n-cost">{n.costPerTick} sp</span>
            </button>
          </li>
        {/each}
      </ul>
    </section>

    <section>
      <h2>Craft <span class="hint">no NPC shops — ever</span></h2>
      <ul class="recipes">
        {#each RECIPES as r}
          <li class="recipe" class:ok={canCraft(p, r)}>
            <div class="r-head">
              <span class="r-name">T{r.tier} · {r.name}</span>
              <button disabled={!canCraft(p, r)} on:click={() => doCraft(r)}>craft</button>
            </div>
            <div class="r-inputs">
              {#each Object.entries(r.inputs) as [k, v]}
                <span class="chip">{v}× {k}</span>
              {/each}
            </div>
            <p class="r-blurb">{r.blurb}</p>
          </li>
        {/each}
      </ul>
    </section>

    <section>
      <h2>Pack</h2>
      {#if inventoryRows.length === 0 && craftedRows.length === 0}
        <p class="empty">Empty. Walk, then gather.</p>
      {/if}
      <ul class="inv">
        {#each inventoryRows as [k, v]}<li><b>{v}</b> {k}</li>{/each}
        {#each craftedRows as [k, v]}<li class="crafted"><b>{v}</b> {k}</li>{/each}
      </ul>
      <h2 class="log-h">Trail log</h2>
      <ul class="log">
        {#each p.log.slice(0, 8) as line}<li>{line}</li>{/each}
      </ul>
    </section>
  </div>

  {#if toast}<div class="toast">{toast}</div>{/if}

  <footer>
    v0 prototype · stride economy + crafting chain · next: map shards, PvE encounters on routes, player markets
  </footer>
</main>

<style>
  :global(*) { margin: 0; padding: 0; box-sizing: border-box; }
  :global(body) {
    background: #0e1410; color: #d9e6dc;
    font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
  }
  main { max-width: 1080px; margin: 0 auto; padding: 1.2rem 1rem 3rem; }
  header { display: flex; justify-content: space-between; align-items: center; gap: 1rem; flex-wrap: wrap; }
  .brand { display: flex; gap: .8rem; align-items: center; }
  h1 { font-size: 1.5rem; letter-spacing: .02em; }
  .tag { font-size: .72rem; color: #6f8577; }
  .stride-meter { text-align: right; }
  .stride-meter .big { font-size: 2rem; font-weight: 700; color: #7dc98f; display: block; line-height: 1; }
  .stride-meter .lbl { font-size: .7rem; text-transform: uppercase; letter-spacing: .15em; color: #6f8577; }
  .stride-meter .sub { display: block; font-size: .72rem; color: #4d5f54; margin-top: .2rem; }

  .walk-bar { display: flex; gap: .6rem; margin: 1.2rem 0 1.6rem; flex-wrap: wrap; }
  button { font: inherit; cursor: pointer; border: 0; border-radius: 8px; }
  .walk { background: #1d2b22; color: #d9e6dc; padding: .65rem 1rem; }
  .walk:hover { background: #25382c; }
  .walk small { color: #6f8577; }
  .sensor { background: #2b3a22; color: #cfe8b0; padding: .65rem 1rem; }
  .live { color: #7dc98f; font-size: .9rem; padding: .65rem 0; }

  .cols { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.4rem; }
  h2 { font-size: .95rem; margin-bottom: .7rem; color: #a9c4b0; }
  .hint { font-size: .68rem; color: #5c7263; font-weight: 400; margin-left: .4rem; }

  .nodes { list-style: none; display: flex; flex-direction: column; gap: .5rem; }
  .node { width: 100%; display: grid; grid-template-columns: 1fr auto; gap: .1rem .6rem;
    background: #141d17; padding: .7rem .9rem; text-align: left; color: inherit;
    border: 1px solid #1f2d24; }
  .node:disabled { opacity: .45; cursor: default; }
  .node:not(:disabled):hover { border-color: #35543f; }
  .n-name { font-weight: 600; }
  .n-biome { grid-row: 2; font-size: .7rem; color: #5c7263; }
  .n-cost { grid-row: 1 / span 2; align-self: center; color: #e8b54a; font-size: .85rem; }

  .recipes { list-style: none; display: flex; flex-direction: column; gap: .6rem; }
  .recipe { background: #141d17; border: 1px solid #1f2d24; border-radius: 8px; padding: .7rem .9rem; opacity: .75; }
  .recipe.ok { opacity: 1; border-color: #35543f; }
  .r-head { display: flex; justify-content: space-between; align-items: center; }
  .r-name { font-weight: 600; font-size: .92rem; }
  .r-head button { background: #2b3a22; color: #cfe8b0; padding: .35rem .8rem; font-size: .8rem; }
  .r-head button:disabled { opacity: .4; cursor: default; }
  .r-inputs { display: flex; gap: .4rem; margin: .45rem 0; flex-wrap: wrap; }
  .chip { font-size: .7rem; background: #1d2b22; padding: .2rem .5rem; border-radius: 99px; color: #a9c4b0; }
  .r-blurb { font-size: .75rem; color: #5c7263; }

  .inv { list-style: none; display: flex; flex-wrap: wrap; gap: .5rem; }
  .inv li { background: #141d17; border: 1px solid #1f2d24; padding: .35rem .7rem; border-radius: 99px; font-size: .8rem; }
  .inv li.crafted { border-color: #4d4324; color: #e8d9a8; }
  .empty { color: #4d5f54; font-size: .85rem; }
  .log-h { margin-top: 1.2rem; }
  .log { list-style: none; font-size: .78rem; color: #6f8577; display: flex; flex-direction: column; gap: .25rem; }

  .toast { position: fixed; bottom: 4.4rem; left: 50%; transform: translateX(-50%);
    background: #1d2b22; color: #cfe8b0; padding: .6rem 1.1rem; border-radius: 8px;
    font-size: .85rem; box-shadow: 0 4px 18px rgba(0,0,0,.4); }
  footer { margin-top: 2.4rem; font-size: .72rem; color: #4d5f54; text-align: center; }
</style>
