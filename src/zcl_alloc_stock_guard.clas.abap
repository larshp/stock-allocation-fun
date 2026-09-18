CLASS zcl_alloc_stock_guard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_position,
             lgort    TYPE lgort_d,
             opening  TYPE menge_d,
             movement TYPE menge_d,
           END OF ty_position.
    TYPES ty_position_tt TYPE STANDARD TABLE OF ty_position WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_finding,
             lgort   TYPE lgort_d,
             closing TYPE menge_d,
           END OF ty_finding.
    TYPES ty_finding_tt TYPE STANDARD TABLE OF ty_finding WITH DEFAULT KEY.

    METHODS check
      IMPORTING
        it_positions       TYPE ty_position_tt
      RETURNING
        VALUE(rt_findings) TYPE ty_finding_tt.

    METHODS first_negative
      IMPORTING
        it_positions    TYPE ty_position_tt
      RETURNING
        VALUE(rv_lgort) TYPE lgort_d.

    METHODS closing_of
      IMPORTING
        is_position       TYPE ty_position
      RETURNING
        VALUE(rv_closing) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_stock_guard IMPLEMENTATION.

  METHOD closing_of.
    rv_closing = is_position-opening + is_position-movement.
  ENDMETHOD.

  METHOD check.
    DATA lv_closing TYPE menge_d.
    DATA ls_finding TYPE ty_finding.

    LOOP AT it_positions INTO DATA(ls_position).
      lv_closing = closing_of( ls_position ).

      " A storage location that ends below zero means the movements were not
      " covered by the opening stock.
      IF lv_closing >= 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_finding.
      ls_finding-lgort = ls_position-lgort.
      ls_finding-closing = lv_closing.
      APPEND ls_finding TO rt_findings.
    ENDLOOP.
  ENDMETHOD.

  METHOD first_negative.
    DATA lt_findings TYPE ty_finding_tt.

    lt_findings = check( it_positions ).

    READ TABLE lt_findings INTO DATA(ls_finding) INDEX 1.
    IF sy-subrc = 0.
      rv_lgort = ls_finding-lgort.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
