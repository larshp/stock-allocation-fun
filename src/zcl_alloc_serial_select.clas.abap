CLASS zcl_alloc_serial_select DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_int_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS select
      IMPORTING
        it_serials         TYPE ty_int_tt
        iv_quantity        TYPE i
      RETURNING
        VALUE(rt_selected) TYPE ty_int_tt.

    METHODS shortfall
      IMPORTING
        it_serials      TYPE ty_int_tt
        iv_quantity     TYPE i
      RETURNING
        VALUE(rv_short) TYPE i.

ENDCLASS.


CLASS zcl_alloc_serial_select IMPLEMENTATION.

  METHOD select.
    DATA lv_taken TYPE i.

    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    " Serials are consumed in the order they are offered, so the caller controls
    " the priority (for example oldest stock first).
    LOOP AT it_serials INTO DATA(lv_serial).
      IF lv_taken >= iv_quantity.
        EXIT.
      ENDIF.

      APPEND lv_serial TO rt_selected.
      lv_taken = lv_taken + 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD shortfall.
    DATA lv_available TYPE i.

    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    lv_available = lines( it_serials ).
    IF lv_available < iv_quantity.
      rv_short = iv_quantity - lv_available.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
