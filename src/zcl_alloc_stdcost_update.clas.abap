CLASS zcl_alloc_stdcost_update DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS refresh
      IMPORTING
        iv_current    TYPE i
        iv_new        TYPE i
      RETURNING
        VALUE(rv_new) TYPE i.

    METHODS is_changed
      IMPORTING
        iv_current   TYPE i
        iv_new       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta_percent
      IMPORTING
        iv_current        TYPE i
        iv_new            TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stdcost_update IMPLEMENTATION.

  METHOD refresh.
    " The refreshed standard cost takes the new value.
    rv_new = iv_new.
  ENDMETHOD.

  METHOD is_changed.
    " The standard cost has changed once the new differs from the current.
    rv_ok = xsdbool( iv_new <> iv_current ).
  ENDMETHOD.

  METHOD delta_percent.
    DATA lv_diff TYPE i.

    " The change as a share of the current standard cost.
    IF iv_current = 0.
      RETURN.
    ENDIF.

    lv_diff = iv_new - iv_current.
    rv_percent = lv_diff * 100 DIV iv_current.
  ENDMETHOD.

ENDCLASS.
