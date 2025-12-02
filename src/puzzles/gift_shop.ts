import type { AoCModule } from "../types";
import fs from "fs/promises";

export async function gift_shop(
  mod: AoCModule,
  arena: number
): Promise<number> {
  const res = await fs.readFile("data/gift_shop.txt");
  const txt = res.toString();

  const ranges = txt
    .split(",")
    .map((r) => r.split("-").map((id) => parseInt(id)));
  const len = ranges.length;
  const listPtr = arena;
  const rangesFlat = ranges.flatMap((x) => x).map((x) => BigInt(x));
  new BigInt64Array(mod.memory.buffer).set(rangesFlat, listPtr / 8);

  const answer = mod.gift_shop(listPtr, BigInt(len));
  console.log(`Gift Shop: ${answer}`);

  return len * 16;
}
