CLASS zcl_alloc_val_diff DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS difference
      IMPORTING
        iv_old_value    TYPE i
        iv_new_value    TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

    METHODS is_up
      IMPORTING
        iv_old_value TYPE i
        iv_new_value TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_old_value      TYPE i
        iv_new_value      TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_diff IMPLEMENTATION.

  METHOD difference.
    " The difference is the new value less the old one.
    rv_delta = iv_new_value - iv_old_value.
  ENDMETHOD.

  METHOD is_up.
    " The value is written up once the new one is the higher.
    rv_ok = xsdbool( iv_new_value > iv_old_value ).
  ENDMETHOD.

  METHOD percent.
    DATA lv_delta TYPE i.

    " The difference is related to the old value it moved from.
    IF iv_old_value = 0.
      RETURN.
    ENDIF.

    lv_delta = difference( iv_old_value = iv_old_value
                           iv_new_value = iv_new_value ).
    rv_percent = lv_delta * 100 DIV iv_old_value.
  ENDMETHOD.

ENDCLASS.
