import { loadModule } from "./loader.ts";
import { secret_entrance } from "./puzzles/secret_entrance.ts";

async function main() {
  const mod = await loadModule();
  await secret_entrance(mod);
}
main().catch((e) => console.error(e));
