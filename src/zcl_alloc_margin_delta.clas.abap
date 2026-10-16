CLASS zcl_alloc_margin_delta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS delta
      IMPORTING
        iv_old_margin   TYPE i
        iv_new_margin   TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

    METHODS is_up
      IMPORTING
        iv_old_margin TYPE i
        iv_new_margin TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_old_margin     TYPE i
        iv_new_margin     TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_margin_delta IMPLEMENTATION.

  METHOD delta.
    " The change is the new margin less the old one.
    rv_delta = iv_new_margin - iv_old_margin.
  ENDMETHOD.

  METHOD is_up.
    " The margin rose once the new one is the higher.
    rv_ok = xsdbool( iv_new_margin > iv_old_margin ).
  ENDMETHOD.

  METHOD percent.
    DATA lv_delta TYPE i.

    " The change is related to the margin it moved from.
    IF iv_old_margin = 0.
      RETURN.
    ENDIF.

    lv_delta = iv_new_margin - iv_old_margin.
    rv_percent = lv_delta * 100 DIV iv_old_margin.
  ENDMETHOD.

ENDCLASS.
