CLASS zcl_alloc_restock_decision DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS decide
      IMPORTING
        iv_grade           TYPE string
        iv_quantity        TYPE i
        iv_min_grade       TYPE string
      RETURNING
        VALUE(rv_decision) TYPE string.

    METHODS is_restock
      IMPORTING
        iv_grade     TYPE string
        iv_min_grade TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_grade         TYPE string
        iv_quantity      TYPE i
      RETURNING
        VALUE(rv_reason) TYPE string.

  PRIVATE SECTION.
    METHODS rank
      IMPORTING
        iv_grade       TYPE string
      RETURNING
        VALUE(rv_rank) TYPE i.

ENDCLASS.


CLASS zcl_alloc_restock_decision IMPLEMENTATION.

  METHOD rank.
    CASE iv_grade.
      WHEN 'A'.
        rv_rank = 4.
      WHEN 'B'.
        rv_rank = 3.
      WHEN 'C'.
        rv_rank = 2.
      WHEN 'D'.
        rv_rank = 1.
      WHEN 'F'.
        rv_rank = 0.
      WHEN OTHERS.
        rv_rank = -1.
    ENDCASE.
  ENDMETHOD.

  METHOD is_restock.
    " Both grades must be known and the item's grade must reach the threshold.
    rv_ok = xsdbool( rank( iv_grade ) >= 0
                     AND rank( iv_min_grade ) >= 0
                     AND rank( iv_grade ) >= rank( iv_min_grade ) ).
  ENDMETHOD.

  METHOD decide.
    IF iv_quantity <= 0.
      rv_decision = 'REJECT'.
    ELSEIF is_restock( iv_grade     = iv_grade
                       iv_min_grade = iv_min_grade ) = abap_true.
      rv_decision = 'RESTOCK'.
    ELSE.
      rv_decision = 'REJECT'.
    ENDIF.
  ENDMETHOD.

  METHOD reason.
    IF iv_quantity <= 0.
      rv_reason = 'NO_QUANTITY'.
    ELSEIF iv_grade = 'A' OR iv_grade = 'B' OR iv_grade = 'C'.
      rv_reason = 'SELLABLE'.
    ELSEIF iv_grade = 'D'.
      rv_reason = 'REPAIRABLE'.
    ELSEIF iv_grade = 'F'.
      rv_reason = 'SCRAP'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
