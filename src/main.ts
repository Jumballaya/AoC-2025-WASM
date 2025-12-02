import { loadModule } from "./loader.ts";
import { gift_shop } from "./puzzles/gift_shop.ts";
import { secret_entrance } from "./puzzles/secret_entrance.ts";
import type { PuzzleFn } from "./types.ts";

const puzzles: PuzzleFn[] = [secret_entrance, gift_shop];

function alignup(n: number, a: number): number {
  return n + (a - (n % a));
}

async function main() {
  const mod = await loadModule();

  let arena = 0;
  for (const puzzle of puzzles) {
    const size = await puzzle(mod, arena);
    arena = alignup(arena + size, 64);
  }
}
main().catch((e) => console.error(e));
