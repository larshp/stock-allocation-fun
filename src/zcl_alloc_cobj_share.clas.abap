CLASS zcl_alloc_cobj_share DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS share_percent
      IMPORTING
        iv_part           TYPE i
        iv_whole          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS largest
      IMPORTING
        it_values         TYPE ty_values_tt
      RETURNING
        VALUE(rv_largest) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_value     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cobj_share IMPLEMENTATION.

  METHOD share_percent.
    " One object's cost as a share of the whole.
    IF iv_whole = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_part * 100 DIV iv_whole.
  ENDMETHOD.

  METHOD largest.
    " The largest cost among the objects.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_value > rv_largest.
        rv_largest = lv_value.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_zero.
    " A share at zero carries no cost.
    rv_ok = xsdbool( iv_value = 0 ).
  ENDMETHOD.

ENDCLASS.
