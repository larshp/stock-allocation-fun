CLASS zcl_alloc_absorb_under DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_under
      IMPORTING
        iv_absorbed  TYPE i
        iv_actual    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_absorbed   TYPE i
        iv_actual     TYPE i
      RETURNING
        VALUE(rv_gap) TYPE i.

    METHODS percent
      IMPORTING
        iv_absorbed       TYPE i
        iv_actual         TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_absorb_under IMPLEMENTATION.

  METHOD is_under.
    " The absorption is under once less is absorbed than was spent.
    rv_ok = xsdbool( iv_absorbed < iv_actual ).
  ENDMETHOD.

  METHOD gap.
    " The gap is only open while the absorption is under the actual cost.
    IF iv_absorbed >= iv_actual.
      RETURN.
    ENDIF.

    rv_gap = iv_actual - iv_absorbed.
  ENDMETHOD.

  METHOD percent.
    DATA lv_gap TYPE i.

    " The under-absorption is the gap as a share of the actual cost.
    IF iv_absorbed >= iv_actual OR iv_actual = 0.
      RETURN.
    ENDIF.

    lv_gap = iv_actual - iv_absorbed.
    rv_percent = lv_gap * 100 DIV iv_actual.
  ENDMETHOD.

ENDCLASS.
