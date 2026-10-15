CLASS zcl_alloc_supplier_score DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS score
      IMPORTING
        iv_otd_percent     TYPE i
        iv_quality_percent TYPE i
        iv_price_percent   TYPE i
      RETURNING
        VALUE(rv_score)    TYPE i.

    METHODS grade
      IMPORTING
        iv_score        TYPE i
      RETURNING
        VALUE(rv_grade) TYPE string.

    METHODS is_preferred
      IMPORTING
        iv_score     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_supplier_score IMPLEMENTATION.

  METHOD score.
    " Delivery counts half, quality a third and price a fifth of the score.
    rv_score = ( iv_otd_percent * 50
                 + iv_quality_percent * 30
                 + iv_price_percent * 20 ) DIV 100.
  ENDMETHOD.

  METHOD grade.
    IF iv_score >= 90.
      rv_grade = 'A'.
    ELSEIF iv_score >= 75.
      rv_grade = 'B'.
    ELSEIF iv_score >= 60.
      rv_grade = 'C'.
    ELSE.
      rv_grade = 'D'.
    ENDIF.
  ENDMETHOD.

  METHOD is_preferred.
    " Only an A-grade supplier is preferred.
    rv_ok = xsdbool( iv_score >= 90 ).
  ENDMETHOD.

ENDCLASS.
