(module
  (import "console" "log64" (func $log64 (param i64)))
  (import "console" "log32" (func $log32 (param i32)))

  
  (memory $memory (export "memory") 64) ;; 16K * 64 = 1M


  ;;
  ;;  ---- Day 1 ---- Secret Entrance 
  ;;
  ;;  JS loads the data into memory and then calls
  ;;  this function. The layout will be: [0|1, i32] for: [L|R, i32]
  ;;
  ;;  struct rotation {
  ;;    direction: i32;
  ;;    amount: i32;
  ;;  }
  ;;
  ;;  fn secret_entrance(list: rotation[], len: i32): i32 {
  ;;    let dial = 50;
  ;;    let zeros = 0;
  ;;    let ptr = list;
  ;;    for (let i = 0; i < len; i++) {
  ;;      let rot = list[ptr]
  ;;      if (rot.direction == LEFT) {
  ;;        dial -= rot.amount;
  ;;      } else {
  ;;        dial += rot.amount;
  ;;      }
  ;;      if (dial < 0) {
  ;;        dial += 100;
  ;;      } else if (dial > 99) {
  ;;        dial -= 100;
  ;;      }
  ;;      if (dial == 0) {
  ;;        zeros++;
  ;;      }
  ;;      ptr += 8;
  ;;    }
  ;;    return zeros;
  ;;  }
  ;;
  (func $secret_entrance (export "secret_entrance") (param $list i32) (param $len i32) (result i32)
    (local $dial i32)  ;; the dial we are tracking
    (local $zeros i32) ;; number of times the dial lands directly on 0
    (local $i i32)     ;; loop counter
    (local $ptr i32)   ;; current pointer in the list

    ;; ptr = list
    (local.set $ptr (local.get $list))
    ;; dial = 50
    (local.set $dial (i32.const 50))

    (block $block_main
      (loop $loop_main
        (br_if $block_main (i32.ge_u (local.get $i) (local.get $len)))

        ;; if (list[ptr].direction == 0)
        (if (i32.eqz (i32.load (local.get $ptr)))
          (then
            ;; dial -= list[i].amount;
            (local.set $dial
              (i32.sub
                (local.get $dial)
                (i32.load (i32.add (local.get $ptr) (i32.const 4)))
              )
            )
          )
          (else
            ;; dial += list[i].amount;
            (local.set $dial
              (i32.add
                (local.get $dial)
                (i32.load (i32.add (local.get $ptr) (i32.const 4)))
              )
            )
          )
        )

        ;; dial %= 100
        (local.set $dial
          (i32.rem_s (local.get $dial) (i32.const 100))
        )

        ;;  if (dial == 0)
        (if (i32.eqz (local.get $dial))
          ;; zeros++
          (local.set $zeros (i32.add (local.get $zeros) (i32.const 1)))
        )

        ;; ptr += 8
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 8)))
        ;; i += 1
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $loop_main)
      )
    )

    ;; return zeros
    (local.get $zeros)
  )

  ;;
  ;;  ---- Day 2 ---- Gift Shop
  ;;
  ;;  JS will load the data into memory then call the function
  ;;
  ;;  struct range {
  ;;    first: i64;
  ;;    last: i64;
  ;;  }
  ;;
  ;;
  ;;  This method will loop through range sets, and then loop through the actual
  ;;  range. e.g. range { 11, 22 } and go 11..22 and for each number run is_invalid
  ;;  if the number is invalid, add it to the total.
  ;;
  ;;
  ;;  fn gift_shop(list: range[], len: i32): i64 {
  ;;    let total = 0;
  ;;    for (let r = 0; r < len; r++) {
  ;;      let start = list[r].first;
  ;;      let end = list[r].last;
  ;;      for (let i = start; i <= end; i++) {
  ;;        if (is_invalid(i)) {
  ;;          total += i;
  ;;        }
  ;;      }
  ;;    }
  ;;    return total;
  ;;  }
  ;;
  (func $gift_shop (export "gift_shop") (param $list i32) (param $len i64) (result i64)
    (local $total i64)
    (local $r i64)
    (local $ptr i32)
    (local $start i64)
    (local $end i64)
    (local $i i64)

    (local.set $ptr (local.get $list))

    (block $main_block
      (loop $main_loop
        (br_if $main_block (i64.ge_u (local.get $r) (local.get $len)))

        (local.set $start (i64.load (local.get $ptr)))
        (local.set $end (i64.load (i32.add (local.get $ptr) (i32.const 8))))
        (local.set $i (local.get $start))

        (block $inner_block
          (loop $inner_loop
            (br_if $inner_block (i64.gt_u (local.get $i) (local.get $end)))
            (if (call $is_invalid (local.get $i))
              (local.set $total (i64.add (local.get $total) (local.get $i)))
            )
            (local.set $i (i64.add (local.get $i) (i64.const 1)))
            (br $inner_loop)
          )
        )

        (local.set $r (i64.add (local.get $r) (i64.const 1)))
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 16)))
        (br $main_loop)
      )
    )

    (local.get $total)
  )

  ;;
  ;;  Check if id is invalid. An id is invalid when the id
  ;;  is made only of some sequence of digits repeated twice
  ;;
  ;;    e.g. -- 55 (5 twice)
  ;;            6464 (64 twice)
  ;;            123123 (123 twice)
  ;;
  ;;
  ;;  fn is_invalid(n: i64): bool {
  ;;    let count = count_digits(n);
  ;;    if (count % 2 != 0) {
  ;;      return false;
  ;;    }
  ;;    let size = count / 2;
  ;;    let lower = extract_number(n, 0, size);
  ;;    let upper = extract_number(n, size, size);
  ;;    return lower === upper;
  ;;  }
  ;;
  (func $is_invalid (param $n i64) (result i32)
    (local $count i64)
    (local $size i64)
    (local $lower i64)
    (local $upper i64)

    (local.set $count (call $count_digits (local.get $n)))
    
    (if (i64.ne (i64.rem_u (local.get $count) (i64.const 2)) (i64.const 0))
      (return (i32.const 0))
    )
    
    (local.set $size (i64.div_u (local.get $count) (i64.const 2)))

    (local.set $lower
      (call $extract_number (local.get $n) (i64.const 0) (local.get $size))
    )

    (local.set $upper
      (call $extract_number (local.get $n) (local.get $size) (local.get $size))
    )
    
    (return (i64.eq (local.get $lower) (local.get $upper)))
  )

  ;;
  ;;  Count the number of digits of an
  ;;  i32 number
  ;;
  ;;
  ;;  fn count_digits(n: i32): i32 {
  ;;    let count = 0;
  ;;    while (n != 1) {
  ;;      count++;
  ;;      n /= 10;
  ;;    }
  ;;    return count;
  ;;  }
  ;;
  ;;
  (func $count_digits (param $n i64) (result i64)
    (local $count i64)
    (local.set $count (i64.const 0))

    (block $block_main
      (loop $loop_main
        (br_if $block_main (i64.eq (local.get $n) (i64.const 0)))

        (local.set $count (i64.add (local.get $count) (i64.const 1)))
        (local.set $n (i64.div_u (local.get $n) (i64.const 10)))

        (br $loop_main)
      )
    )

    (local.get $count)
  )

  ;;
  ;;  Extract len digits of a number n from position start
  ;;    e.g. -- n: 123456, start: 0, len: 3 -- 123
  ;;            n: 123456, start: 2, len: 4 -- 3456
  ;;
  ;;
  ;;  fn extract_number(n: i64, start: i32, len: i32): i64 {
  ;;    let tmp: i64 = 0;
  ;;    let power_start: i64 = 1;
  ;;    let power_end: i64 = 0;
  ;;
  ;;    while (start > 0) {
  ;;      power_start = power_start * 10;
  ;;      start = start - 1;
  ;;    }
  ;;
  ;;    power_end = power_start;
  ;;    while (len > 0) {
  ;;      power_end = power_end * 10;
  ;;      len = len - 1;
  ;;    }
  ;;
  ;;    tmp = n % power_end;
  ;;
  ;;    return temp / power_start;
  ;;  }
  ;;
  ;;
  (func $extract_number (param $n i64) (param $start i64) (param $len i64) (result i64)
    (local $temp i64)
    (local $power_start i64)
    (local $power_end i64)

    (local.set $power_start (i64.const 1))

    (if (i64.gt_s (local.get $start) (i64.const 0))
      (then
        (loop $loop_start
          (local.get $power_start)
          (i64.const 10)
          (i64.mul)
          (local.set $power_start)
          (local.get $start)
          (i64.const 1)
          (i64.sub)
          (local.set $start)
          (local.get $start)
          (i64.const 0)
          (i64.gt_s)
          (br_if $loop_start)
        )
      )
    )

    (local.set $power_end (local.get $power_start))
    
    (if (i64.gt_s (local.get $len) (i64.const 0))
      (then
        (loop $loop_end
          (local.get $power_end)
          (i64.const 10)
          (i64.mul)
          (local.set $power_end)
          (local.get $len)
          (i64.const 1)
          (i64.sub)
          (local.set $len)
          (local.get $len)
          (i64.const 0)
          (i64.gt_s)
          (br_if $loop_end)
        )
      )
    )

    (local.set $temp (i64.rem_s
      (local.get $n)  (local.get $power_end))
    )

    (i64.div_s (local.get $temp) (local.get $power_start))
  )

  ;;
  ;;  ---- Day 3 ---- Lobby
  ;;
  ;;  JS creates the string structs, loads the string data and the struct data
  ;;  into memory
  ;;
  ;;  struct string {
  ;;    ptr: i32;
  ;;    len: i32;
  ;;  }
  ;;
  ;;  fn lobby(banks: string[], len: i32): i32 {
  ;;    let joltage = 0;
  ;;    for (let i = 0; i < len; i++) {
  ;;      joltage += largest_joltage(banks[i]);
  ;;    }
  ;;    return joltage;
  ;;  }
  ;;
  ;;
  (func $lobby (export "lobby") (param $banks i32) (param $len i32) (result i32)
    (local $joltage i32)
    (local $i i32)
    (local $ptr i32)

    (local.set $ptr (local.get $banks))

    (block $main_block
      (loop $main_loop
        (br_if $main_block (i32.ge_u (local.get $i) (local.get $len)))

        (local.set $joltage (i32.add (local.get $joltage) (call $largest_joltage (local.get $ptr))))

        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 8)))
        (br $main_loop)
      )
    )

    (return (local.get $joltage))
  )

  ;;
  ;;
  ;;  fn largest_joltage(s: string): i32 {
  ;;    let tens = 0;
  ;;    let ones = 0;
  ;;    for (let i = 0; i < s.len - 1; ++i) {
  ;;      let n = to_number(s[i]);
  ;;      if (n > tens) {
  ;;        tens = n;
  ;;        ones = 0;
  ;;        continue;
  ;;      }
  ;;      if (n > ones) {
  ;;        ones = n;
  ;;      }
  ;;    }
  ;;
  ;;    let n = to_numbers(s[last]);
  ;;    if (n > ones) {
  ;;      ones = n;
  ;;    }
  ;;
  ;;    return (tens * 10) + ones;
  ;;  }
  ;;
  ;;
  (func $largest_joltage (param $s i32) (result i32)
    (local $tens i32)
    (local $ones i32)
    (local $i i32)
    (local $n i32)
    (local $len i32)
    (local $ptr i32)
    (local $c i32)

    (local.set $len (i32.load (i32.add (local.get $s) (i32.const 4))))
    (local.set $ptr (i32.load (local.get $s)))

    (local.set $c (i32.load8_u (local.get $ptr)))

    (block $main_block
      (loop $main_loop
        ;; for (;i < len - 1;)
        (br_if $main_block (i32.ge_u (local.get $i) (i32.sub (local.get $len) (i32.const 1))))

        ;; n = to_number(c);
        (local.set $n (call $to_number (local.get $c)))
        
        ;; if (n > tens) 
        (if (i32.gt_u (local.get $n) (local.get $tens))
          (then
            (local.set $tens (local.get $n))
            (local.set $ones (i32.const 0))

            (local.set $i (i32.add (local.get $i) (i32.const 1)))
            (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))
            (local.set $c (i32.load8_u (local.get $ptr)))
            (br $main_loop)
          )
        )

        ;; if (n > ones) 
        (if (i32.gt_u (local.get $n) (local.get $ones))
          (then
            (local.set $ones (local.get $n))
          )
        )
      
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))
        (local.set $c (i32.load8_u (local.get $ptr)))
        (br $main_loop)
      )
    )

    ;; check last number 
    (local.set $n (call $to_number (local.get $c)))
    ;; if (n > ones) 
    (if (i32.gt_u (local.get $n) (local.get $ones))
      (then
        (local.set $ones (local.get $n))
      )
    )

    (return (i32.add (i32.mul (local.get $tens) (i32.const 10)) (local.get $ones)))
  )

  ;;
  ;;
  ;;  Convert from ascii number -> number (48: 0, 57: 9)
  ;;
  ;;  fn toNumber(c: i8): i32 {
  ;;    return c - 48;
  ;;  }
  ;;
  ;;
  (func $to_number (param $c i32) (result i32)
    (return (i32.sub (local.get $c) (i32.const 48)))
  )
)