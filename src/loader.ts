import fs from "fs/promises";
import type { AoCModule } from "./types";

export async function loadModule(): Promise<AoCModule> {
  const res = await fs.readFile("build/aoc.wasm");
  const { instance } = await WebAssembly.instantiate(res.buffer, {});
  const mod = instance.exports as AoCModule;
  return mod;
}
