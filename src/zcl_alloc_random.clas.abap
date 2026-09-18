CLASS zcl_alloc_random DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_seed TYPE i.

    METHODS next
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS between
      IMPORTING
        iv_from         TYPE i
        iv_to           TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS reset
      IMPORTING
        iv_seed TYPE i.

    METHODS state
      RETURNING
        VALUE(rv_state) TYPE i.

  PRIVATE SECTION.
    DATA mv_state TYPE i.

    METHODS mix
      IMPORTING
        iv_state        TYPE i
      RETURNING
        VALUE(rv_state) TYPE i.

ENDCLASS.


CLASS zcl_alloc_random IMPLEMENTATION.

  METHOD constructor.
    reset( iv_seed ).
  ENDMETHOD.

  METHOD mix.
    " 16 bit linear congruential generator: the product stays well inside the
    " 32 bit integer range, so no overflow can occur.
    rv_state = ( iv_state * 25173 + 13849 ) MOD 65536.
  ENDMETHOD.

  METHOD next.
    mv_state = mix( mv_state ).
    rv_value = mv_state.
  ENDMETHOD.

  METHOD between.
    DATA lv_span TYPE i.
    DATA lv_raw  TYPE i.

    IF iv_to <= iv_from.
      rv_value = iv_from.
      RETURN.
    ENDIF.

    lv_span = iv_to - iv_from + 1.
    lv_raw = next( ).
    rv_value = iv_from + ( lv_raw MOD lv_span ).
  ENDMETHOD.

  METHOD reset.
    mv_state = iv_seed MOD 65536.

    IF mv_state <= 0.
      mv_state = 1.
    ENDIF.
  ENDMETHOD.

  METHOD state.
    rv_state = mv_state.
  ENDMETHOD.

ENDCLASS.
