(module
  (memory $memory (export "memory") 16) ;; 16K * 16 = 256K

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
)