import type { AoCModule } from "../types";
import fs from "fs/promises";

export async function lobby(mod: AoCModule, arena: number): Promise<number> {
  const res = await fs.readFile("data/lobby.txt");
  const txt = res.toString();

  const structs: Array<number> = [];
  const banks = txt.split("\n");
  const len = banks.length;

  // Build structs
  let ptr = arena;
  for (const b of banks) {
    structs.push(ptr, b.length);
    ptr += b.length;
  }

  // strings start at 'arena'
  const stringsBuffer = new TextEncoder().encode(banks.join(""));
  new Uint8Array(mod.memory.buffer).set(stringsBuffer, arena);

  // structs start after the strings
  const structsBuffer = new Int32Array(structs);
  new Int32Array(mod.memory.buffer).set(structsBuffer, ptr / 4);

  const answer = mod.lobby(ptr, len);

  console.log(`Lobby: ${answer}`);

  return ptr + structsBuffer.byteLength - arena;
}
