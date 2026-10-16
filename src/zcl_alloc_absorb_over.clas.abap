CLASS zcl_alloc_absorb_over DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_over
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


CLASS zcl_alloc_absorb_over IMPLEMENTATION.

  METHOD is_over.
    " The absorption is over once more is absorbed than was spent.
    rv_ok = xsdbool( iv_absorbed > iv_actual ).
  ENDMETHOD.

  METHOD gap.
    " The gap is only open while the absorption is over the actual cost.
    IF iv_absorbed <= iv_actual.
      RETURN.
    ENDIF.

    rv_gap = iv_absorbed - iv_actual.
  ENDMETHOD.

  METHOD percent.
    DATA lv_gap TYPE i.

    " The over-absorption is the gap as a share of the actual cost.
    IF iv_absorbed <= iv_actual OR iv_actual = 0.
      RETURN.
    ENDIF.

    lv_gap = iv_absorbed - iv_actual.
    rv_percent = lv_gap * 100 DIV iv_actual.
  ENDMETHOD.

ENDCLASS.
