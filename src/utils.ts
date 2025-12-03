export function alignup(n: number, a: number): number {
  return n + (a - (n % a));
}
