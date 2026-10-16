CLASS zcl_alloc_code128_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_int_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS checksum
      IMPORTING
        iv_start      TYPE i
        it_values     TYPE ty_int_tt
      RETURNING
        VALUE(rv_sum) TYPE i.

    METHODS is_valid
      IMPORTING
        iv_start     TYPE i
        it_values    TYPE ty_int_tt
        iv_expected  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_code128_check IMPLEMENTATION.

  METHOD checksum.
    DATA lv_index TYPE i.

    " Code 128 weights each symbol by its 1-based position and folds the total
    " modulo 103 on top of the start symbol.
    rv_sum = iv_start.

    LOOP AT it_values INTO DATA(lv_value).
      lv_index = lv_index + 1.
      rv_sum = rv_sum + lv_value * lv_index.
    ENDLOOP.

    rv_sum = rv_sum MOD 103.
  ENDMETHOD.

  METHOD is_valid.
    rv_ok = xsdbool( checksum( iv_start  = iv_start
                               it_values = it_values ) = iv_expected ).
  ENDMETHOD.

ENDCLASS.
