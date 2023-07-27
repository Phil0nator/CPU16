; #ifndef __UTIL
; #define __UTIL
#once
#include "arch.asm"

#ruledef {
    mov {d: register}, {q: i16} => asm {
        ldi {d}, {q}
    }
    mov {d: register}, [{a: u16}] => asm {
        ld {d} <- [{a}]
    }
    mov {d: register}, [{a: register}] => asm {
        ld {d} <- {a}
    }

    call {fn: u16} ({a}) => {
        asm {
            mov r0, {a} ; load arg0
            call {fn}   ; call
        }
    }

    call {fn: u16} ({a}, {b}) => {
        asm {
            mov r1, {b}     ; load arg1
            call {fn}({a})
        }
    }

    call {fn: u16} ({a}, {b}, {c}) => {
        asm {
            mov r2, {c}         ; load arg2
            call {fn}({a},{b})
        }
    }

    call {fn: u16} ({a}, {b}, {c}, {d}) => {
        asm {
            mov r3, {d}
            call {fn}({a}, {b}, {c})
        }
    }
    call {fn: u16} ({a}, {b}, {c}, {d}, {e}) => {
        asm {
            mov r4, {e}
            call {fn}({a}, {b}, {c}, {d})
        }
    }

    call {fn: u16} ([{a}]) => {
        asm {
            mov r0, [{a}] ; load arg0
            call {fn}   ; call
        }
    }
    call {fn: u16} ([{a}], {b}) => {
        asm {
            mov r1, {b}     ; load arg1
            call {fn}([{a}])
        }
    }
    call {fn: u16} ({a}, [{b}]) => {
        asm {
            mov r1, [{b}]     ; load arg1
            call {fn}({a})
        }
    }
    call {fn: u16} ([{a}], [{b}]) => {
        asm {
            mov r1, [{b}]     ; load arg1
            call {fn}([{a}])
        }
    }

}


