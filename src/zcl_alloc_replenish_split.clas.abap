CLASS zcl_alloc_replenish_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS split
      IMPORTING
        iv_total          TYPE i
        iv_batch_size     TYPE i
      RETURNING
        VALUE(rt_batches) TYPE ty_values_tt.

    METHODS batch_count
      IMPORTING
        iv_total        TYPE i
        iv_batch_size   TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS covers_total
      IMPORTING
        iv_total      TYPE i
        iv_batch_size TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_replenish_split IMPLEMENTATION.

  METHOD split.
    DATA lv_remaining TYPE i.

    " A batch size of zero or less cannot split anything.
    IF iv_batch_size <= 0 OR iv_total <= 0.
      RETURN.
    ENDIF.

    lv_remaining = iv_total.

    " The order is broken into full batches with the remainder last.
    WHILE lv_remaining > 0.
      IF lv_remaining > iv_batch_size.
        APPEND iv_batch_size TO rt_batches.
        lv_remaining = lv_remaining - iv_batch_size.
      ELSE.
        APPEND lv_remaining TO rt_batches.
        lv_remaining = 0.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD batch_count.
    " The batch count rounds the total up to whole batches.
    IF iv_batch_size <= 0 OR iv_total <= 0.
      RETURN.
    ENDIF.

    rv_count = ( iv_total + iv_batch_size - 1 ) DIV iv_batch_size.
  ENDMETHOD.

  METHOD covers_total.
    " The full batches cover the total exactly when nothing remains over.
    rv_ok = xsdbool( iv_batch_size > 0
                     AND iv_total > 0
                     AND iv_total MOD iv_batch_size = 0 ).
  ENDMETHOD.

ENDCLASS.
