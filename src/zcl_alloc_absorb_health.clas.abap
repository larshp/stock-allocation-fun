CLASS zcl_alloc_absorb_health DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS is_healthy
      IMPORTING
        iv_absorbed  TYPE i
        iv_actual    TYPE i
        iv_tolerance TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS issue_count
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_actual       TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS score
      IMPORTING
        iv_absorbed     TYPE i
        iv_actual       TYPE i
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.


CLASS zcl_alloc_absorb_health IMPLEMENTATION.

  METHOD is_healthy.
    DATA lv_gap TYPE i.

    " The absorption is healthy while it stays within the tolerance.
    lv_gap = iv_absorbed - iv_actual.
    IF lv_gap < 0.
      lv_gap = -1 * lv_gap.
    ENDIF.

    rv_ok = xsdbool( lv_gap <= iv_tolerance ).
  ENDMETHOD.

  METHOD issue_count.
    " An issue is an amount that does not match the actual cost.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_value <> iv_actual.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD score.
    DATA lv_gap TYPE i.

    " The score falls with the share of the gap against the actual cost.
    IF iv_actual = 0.
      RETURN.
    ENDIF.

    lv_gap = iv_absorbed - iv_actual.
    IF lv_gap < 0.
      lv_gap = -1 * lv_gap.
    ENDIF.

    rv_score = 100 - lv_gap * 100 DIV iv_actual.
    IF rv_score < 0.
      rv_score = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
