import fs from "fs/promises";

type AoCModule = {
  memory: WebAssembly.Memory;
};

async function loadModule(): Promise<AoCModule> {
  const res = await fs.readFile("build/aoc.wasm");
  const { instance } = await WebAssembly.instantiate(res.buffer, {});
  const mod = instance.exports as AoCModule;
  return mod;
}

async function main() {
  const mod = await loadModule();
  console.log(mod);
}
main().catch((e) => console.error(e));
