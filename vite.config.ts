import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

// base = repo name -> served at https://whoseyci.github.io/Strideborn/
export default defineConfig({
  base: "/Strideborn/",
  plugins: [svelte()],
});
