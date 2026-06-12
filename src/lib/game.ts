/**
 * Strideborn core domain model (v0).
 * Walking is the only source of progress: steps -> stride points ->
 * gathering ticks -> player-crafted economy. No NPC vendors, ever.
 */

export type ResourceId = "fiber" | "wood" | "stone" | "ore" | "essence";

export interface ResourceNode {
  id: ResourceId;
  name: string;
  /** stride points required per gathering tick */
  costPerTick: number;
  /** flavor for the biome the walker is "passing through" */
  biome: string;
}

export const NODES: ResourceNode[] = [
  { id: "fiber",   name: "Meadow Fiber",   costPerTick: 40,  biome: "Verdant Plains" },
  { id: "wood",    name: "Greenwood",      costPerTick: 60,  biome: "Whisperwood" },
  { id: "stone",   name: "Rough Stone",    costPerTick: 80,  biome: "Karst Hills" },
  { id: "ore",     name: "Copper Ore",     costPerTick: 120, biome: "Rust Ridges" },
  { id: "essence", name: "Wayfarer Essence", costPerTick: 300, biome: "Ley Crossings" },
];

export interface Recipe {
  id: string;
  name: string;
  tier: number;
  inputs: Partial<Record<ResourceId, number>>;
  /** what it unlocks / is good for, shown in UI */
  blurb: string;
}

export const RECIPES: Recipe[] = [
  { id: "cord",     name: "Twisted Cord",   tier: 1, inputs: { fiber: 4 },            blurb: "Foundation of every pack and snare." },
  { id: "haft",     name: "Greenwood Haft", tier: 1, inputs: { wood: 3 },             blurb: "A handle awaiting a purpose." },
  { id: "hammer",   name: "Stone Maul",     tier: 2, inputs: { haft: 1, stone: 5 } as any, blurb: "First crafted tool. Unlocks ore nodes." },
  { id: "ingot",    name: "Copper Ingot",   tier: 2, inputs: { ore: 4 },              blurb: "Smelted on a walker's field kiln." },
  { id: "waystone", name: "Waystone Shard", tier: 3, inputs: { ingot: 2, essence: 1 } as any, blurb: "Binds a place to your stride. Fast-travel anchor (one day)." },
];

export interface PlayerState {
  steps: number;          // lifetime steps recorded
  stride: number;         // unspent stride points (1 step = 1 point, v0)
  inventory: Record<string, number>;
  crafted: Record<string, number>;
  log: string[];
}

export function newPlayer(): PlayerState {
  return { steps: 0, stride: 0, inventory: {}, crafted: {}, log: ["You take your first step."] };
}

export function addSteps(p: PlayerState, n: number): PlayerState {
  return { ...p, steps: p.steps + n, stride: p.stride + n };
}

export function gather(p: PlayerState, node: ResourceNode): PlayerState | null {
  if (p.stride < node.costPerTick) return null;
  const inv = { ...p.inventory, [node.id]: (p.inventory[node.id] ?? 0) + 1 };
  const log = [`Gathered 1 ${node.name} (${node.biome}).`, ...p.log].slice(0, 30);
  return { ...p, stride: p.stride - node.costPerTick, inventory: inv, log };
}

export function canCraft(p: PlayerState, r: Recipe): boolean {
  return Object.entries(r.inputs).every(([k, v]) => {
    const have = (p.inventory[k] ?? 0) + (p.crafted[k] ?? 0);
    return have >= (v as number);
  });
}

export function craft(p: PlayerState, r: Recipe): PlayerState | null {
  if (!canCraft(p, r)) return null;
  const inv = { ...p.inventory };
  const crafted = { ...p.crafted };
  for (const [k, v] of Object.entries(r.inputs)) {
    let need = v as number;
    const fromInv = Math.min(inv[k] ?? 0, need);
    if (fromInv) { inv[k] = (inv[k] ?? 0) - fromInv; need -= fromInv; }
    if (need) crafted[k] = (crafted[k] ?? 0) - need;
  }
  crafted[r.id] = (crafted[r.id] ?? 0) + 1;
  const log = [`Crafted ${r.name}.`, ...p.log].slice(0, 30);
  return { ...p, inventory: inv, crafted, log };
}

const KEY = "strideborn.v0";
export function save(p: PlayerState) { localStorage.setItem(KEY, JSON.stringify(p)); }
export function load(): PlayerState {
  try { const raw = localStorage.getItem(KEY); if (raw) return JSON.parse(raw); } catch {}
  return newPlayer();
}
