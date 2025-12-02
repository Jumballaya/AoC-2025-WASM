import fs from "fs/promises";
import type { AoCModule } from "./types";

export async function loadModule(): Promise<AoCModule> {
  const res = await fs.readFile("build/aoc.wasm");
  const { instance } = await WebAssembly.instantiate(res.buffer, {
    console: {
      log64: (n: number) => {
        console.log(n);
      },
    },
  });
  const mod = instance.exports as AoCModule;
  return mod;
}
