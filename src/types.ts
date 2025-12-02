export type AoCModule = {
  memory: WebAssembly.Memory;

  secret_entrance: (list: number, len: number) => number;
};
