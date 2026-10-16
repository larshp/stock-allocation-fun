CLASS zcl_alloc_drv_share DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS percent
      IMPORTING
        iv_part           TYPE i
        iv_whole          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS share
      IMPORTING
        it_values         TYPE ty_values_tt
        iv_index          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS largest
      IMPORTING
        it_values         TYPE ty_values_tt
      RETURNING
        VALUE(rv_largest) TYPE i.

ENDCLASS.


CLASS zcl_alloc_drv_share IMPLEMENTATION.

  METHOD percent.
    " The share relates one driver to the whole driver quantity.
    IF iv_whole = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_part * 100 DIV iv_whole.
  ENDMETHOD.

  METHOD share.
    DATA lv_total TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_at    TYPE i.

    " The share of one driver is its quantity against the total.
    IF iv_index < 1.
      RETURN.
    ENDIF.

    LOOP AT it_values INTO DATA(lv_value).
      lv_total = lv_total + lv_value.
      lv_idx = lv_idx + 1.
      IF lv_idx = iv_index.
        lv_at = lv_value.
      ENDIF.
    ENDLOOP.

    IF lv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = lv_at * 100 DIV lv_total.
  ENDMETHOD.

  METHOD largest.
    DATA lv_first TYPE abap_bool.

    " The largest driver carries the most quantity.
    lv_first = abap_true.

    LOOP AT it_values INTO DATA(lv_value).
      IF lv_first = abap_true OR lv_value > rv_largest.
        rv_largest = lv_value.
        lv_first = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
