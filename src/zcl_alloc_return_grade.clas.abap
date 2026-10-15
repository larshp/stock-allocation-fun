CLASS zcl_alloc_return_grade DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS grade
      IMPORTING
        iv_score        TYPE i
      RETURNING
        VALUE(rv_grade) TYPE string.

    METHODS score
      IMPORTING
        iv_grade        TYPE string
      RETURNING
        VALUE(rv_score) TYPE i.

    METHODS is_sellable
      IMPORTING
        iv_score     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_grade IMPLEMENTATION.

  METHOD grade.
    IF iv_score >= 90.
      rv_grade = 'A'.
    ELSEIF iv_score >= 75.
      rv_grade = 'B'.
    ELSEIF iv_score >= 60.
      rv_grade = 'C'.
    ELSEIF iv_score >= 40.
      rv_grade = 'D'.
    ELSE.
      rv_grade = 'F'.
    ENDIF.
  ENDMETHOD.

  METHOD score.
    " The score of a grade is the lowest score that still earns it, so the two
    " functions round-trip at the band boundaries. An unknown grade gives -1.
    CASE iv_grade.
      WHEN 'A'.
        rv_score = 90.
      WHEN 'B'.
        rv_score = 75.
      WHEN 'C'.
        rv_score = 60.
      WHEN 'D'.
        rv_score = 40.
      WHEN 'F'.
        rv_score = 0.
      WHEN OTHERS.
        rv_score = -1.
    ENDCASE.
  ENDMETHOD.

  METHOD is_sellable.
    rv_ok = xsdbool( iv_score >= 60 ).
  ENDMETHOD.

ENDCLASS.
