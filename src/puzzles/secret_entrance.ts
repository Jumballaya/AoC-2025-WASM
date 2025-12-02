import assert from "assert";
import type { AoCModule } from "../types";
import fs from "fs/promises";

export async function secret_entrance(mod: AoCModule) {
  const data = await fs.readFile("data/secret_entrance.txt");
  const txt = data.toString();
  const rotations = txt.split("\n").map((r) => {
    const char = r[0];
    assert(char === "L" || char === "R");
    const dir = char === "L" ? 0 : 1;
    const amount = parseInt(r.slice(1));
    assert(!isNaN(amount));
    return [dir, amount];
  });
  const len = rotations.length;
  const rotFlat = rotations.flatMap((x) => x);
  const listPtr = 0;

  new Int32Array(mod.memory.buffer).set(rotFlat, listPtr);

  const answer = mod.secret_entrance(listPtr, len);

  console.log(`Secret Entrance Password: ${answer}`);
}
