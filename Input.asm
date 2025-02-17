;;<< INPUT FUNCTIONS
;;< INKEY, JOY, KEY (DEF). Also SPEED (WRITE/KEY/INK)
;;========================================================
;; function INKEY
function_INKEY:                   ;{{Addr=$d456 Code Calls/jump count: 0 Data use count: 1}}
        call    function_CINT     ;{{d456:cdb6fe}} 
        ld      de,$0050          ;{{d459:115000}} 
        call    compare_HL_DE     ;{{d45c:cdd8ff}}  HL=DE?
        jr      nc,_function_joy_12;{{d45f:3022}}  (+$22)
        ld      a,l               ;{{d461:7d}} 
        call    KM_TEST_KEY       ;{{d462:cd1ebb}}  firmware function: km read key
        ld      hl,$ffff          ;{{d465:21ffff}} ##LIT##;WARNING: Code area used as literal
        jr      z,_function_inkey_10;{{d468:2803}}  (+$03)
        ld      l,c               ;{{d46a:69}} 
        ld      h,$00             ;{{d46b:2600}} 
_function_inkey_10:               ;{{Addr=$d46d Code Calls/jump count: 1 Data use count: 0}}
        jp      store_HL_in_accumulator_as_INT;{{d46d:c335ff}} 

;;========================================================
;; function JOY
function_JOY:                     ;{{Addr=$d470 Code Calls/jump count: 0 Data use count: 1}}
        call    KM_GET_JOYSTICK   ;{{d470:cd24bb}}  firmware function: km get joystick
        ex      de,hl             ;{{d473:eb}} 
        call    function_CINT     ;{{d474:cdb6fe}} 
        ld      a,h               ;{{d477:7c}} 
        or      l                 ;{{d478:b5}} 
        jr      z,_function_joy_8 ;{{d479:2802}}  (+$02)
        ld      d,e               ;{{d47b:53}} 
        dec     hl                ;{{d47c:2b}} 
_function_joy_8:                  ;{{Addr=$d47d Code Calls/jump count: 1 Data use count: 0}}
        ld      a,h               ;{{d47d:7c}} 
        or      l                 ;{{d47e:b5}} 
        ld      a,d               ;{{d47f:7a}} 
        jp      z,store_A_in_accumulator_as_INT;{{d480:ca32ff}} 
_function_joy_12:                 ;{{Addr=$d483 Code Calls/jump count: 2 Data use count: 0}}
        jp      Error_Improper_Argument;{{d483:c34dcb}}  Error: Improper Argument

;;========================================================================
;; command KEY

command_KEY:                      ;{{Addr=$d486 Code Calls/jump count: 0 Data use count: 1}}
        cp      $8d               ;{{d486:fe8d}}  DEF token
        jr      z,KEY_DEF         ;{{d488:2816}}  

        call    eval_expr_as_byte_or_error;{{d48a:cdb8ce}}  get number and check it's less than 255 
        push    af                ;{{d48d:f5}} 
        call    next_token_if_comma;{{d48e:cd15de}}  check for comma
        call    eval_expr_as_string_and_get_length;{{d491:cd03cf}} 
        ld      c,b               ;{{d494:48}} 
        pop     af                ;{{d495:f1}} 
        ld      b,a               ;{{d496:47}} 
        push    hl                ;{{d497:e5}} 
        ex      de,hl             ;{{d498:eb}} 
        call    KM_SET_EXPAND     ;{{d499:cd0fbb}}  firmware function: KM SET EXPAND
        pop     hl                ;{{d49c:e1}} 
        jr      nc,_function_joy_12;{{d49d:30e4}}  (-$1c)
        ret                       ;{{d49f:c9}} 

;;========================================================================
;; KEY DEF
KEY_DEF:                          ;{{Addr=$d4a0 Code Calls/jump count: 1 Data use count: 0}}
        call    get_next_token_skipping_space;{{d4a0:cd2cde}}  get next token skipping space
        ld      b,$50             ;{{d4a3:0650}} 
        call    eval_expr_and_check_less_than_B;{{d4a5:cd69d3}} 
        ld      c,a               ;{{d4a8:4f}} 
        call    next_token_if_comma;{{d4a9:cd15de}}  check for comma
        ld      b,$02             ;{{d4ac:0602}} 
        call    eval_expr_and_check_less_than_B;{{d4ae:cd69d3}} 
        rra                       ;{{d4b1:1f}} 
        sbc     a,a               ;{{d4b2:9f}} 
        ld      b,a               ;{{d4b3:47}} 
        push    bc                ;{{d4b4:c5}} 
        push    hl                ;{{d4b5:e5}} 
        ld      a,c               ;{{d4b6:79}} 
        call    KM_SET_REPEAT     ;{{d4b7:cd39bb}}  firmware function: KM SET REPEAT
        pop     hl                ;{{d4ba:e1}} 
        pop     bc                ;{{d4bb:c1}} 
        ld      de,KM_SET_TRANSLATE;{{d4bc:1127bb}}  KM SET TRANSLATE
        call    _key_def_21       ;{{d4bf:cdcbd4}} 
        ld      de,KM_SET_SHIFT   ;{{d4c2:112dbb}}  KM SET SHIFT
        call    _key_def_21       ;{{d4c5:cdcbd4}} 
        ld      de,KM_SET_CONTROL ;{{d4c8:1133bb}}  KM SET CONTROL
_key_def_21:                      ;{{Addr=$d4cb Code Calls/jump count: 2 Data use count: 0}}
        call    next_token_if_prev_is_comma;{{d4cb:cd41de}} 
        ret     nc                ;{{d4ce:d0}} 

        push    de                ;{{d4cf:d5}} 
        call    eval_expr_as_byte_or_error;{{d4d0:cdb8ce}}  get number and check it's less than 255 
        ld      b,a               ;{{d4d3:47}} 
        ex      (sp),hl           ;{{d4d4:e3}} 
        ld      a,c               ;{{d4d5:79}} 
        call    JP_HL             ;{{d4d6:cdfbff}}  JP (HL)
        pop     hl                ;{{d4d9:e1}} 
        ret                       ;{{d4da:c9}} 

;;========================================================================
;; command SPEED WRITE, SPEED KEY, SPEED INK

command_SPEED_WRITE_SPEED_KEY_SPEED_INK:;{{Addr=$d4db Code Calls/jump count: 0 Data use count: 1}}
        cp      $d9               ;{{d4db:fed9}}  token for "WRITE"
        jr      z,SPEED_WRITE_0_SPEED_WRITE_1;{{d4dd:2826}} 

        cp      $a4               ;{{d4df:fea4}}  token for "KEY"
        ld      bc,KM_SET_DELAY   ;{{d4e1:013fbb}}  firmware function: KM SET DELAY
        jr      z,_command_speed_write_speed_key_speed_ink_8;{{d4e4:2808}}  
        cp      $a2               ;{{d4e6:fea2}}  token for "INK"
        ld      bc,SCR_SET_FLASHING;{{d4e8:013ebc}}  firmware function: SCR SET FLASHING
        jp      nz,Error_Syntax_Error;{{d4eb:c249cb}}  Error: Syntax Error

_command_speed_write_speed_key_speed_ink_8:;{{Addr=$d4ee Code Calls/jump count: 1 Data use count: 0}}
        push    bc                ;{{d4ee:c5}} 
        call    get_next_token_skipping_space;{{d4ef:cd2cde}}  get next token skipping space
        call    eval_expr_as_int_less_than_256;{{d4f2:cdc3ce}} 
        ld      c,a               ;{{d4f5:4f}} 
        call    next_token_if_comma;{{d4f6:cd15de}}  check for comma
        call    eval_expr_as_int_less_than_256;{{d4f9:cdc3ce}} 
        ld      e,a               ;{{d4fc:5f}} 
        ld      d,c               ;{{d4fd:51}} 
        pop     bc                ;{{d4fe:c1}} 
        ex      de,hl             ;{{d4ff:eb}} 
        call    JP_BC             ;{{d500:cdfcff}}  JP (BC)
        ex      de,hl             ;{{d503:eb}} 
        ret                       ;{{d504:c9}} 

;;========================================================================
;; SPEED WRITE 0, SPEED WRITE 1

SPEED_WRITE_0_SPEED_WRITE_1:      ;{{Addr=$d505 Code Calls/jump count: 1 Data use count: 0}}
        call    get_next_token_skipping_space;{{d505:cd2cde}}  get next token skipping space
        ld      b,$02             ;{{d508:0602}} 
        call    eval_expr_and_check_less_than_B;{{d50a:cd69d3}} 
        push    hl                ;{{d50d:e5}} 
        ld      hl,$00a7          ;{{d50e:21a700}} 
        dec     a                 ;{{d511:3d}} 
        ld      a,$32             ;{{d512:3e32}} 
        jr      z,_speed_write_0_speed_write_1_10;{{d514:2802}}  (+$02)
        add     hl,hl             ;{{d516:29}} 
        rrca                      ;{{d517:0f}} 
_speed_write_0_speed_write_1_10:  ;{{Addr=$d518 Code Calls/jump count: 1 Data use count: 0}}
        call    CAS_SET_SPEED     ;{{d518:cd68bc}}  firmware function: cas set speed
        pop     hl                ;{{d51b:e1}} 
        ret                       ;{{d51c:c9}} 


