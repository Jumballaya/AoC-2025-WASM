export type AoCModule = {
  memory: WebAssembly.Memory;

  secret_entrance: (list: number, len: number) => number;
  gift_shop: (list: number, len: bigint) => number;
};

export type PuzzleFn = (mod: AoCModule, arena: number) => Promise<number>;
