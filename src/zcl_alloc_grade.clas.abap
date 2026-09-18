CLASS zcl_alloc_grade DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_grade TYPE c LENGTH 1.

    TYPES: BEGIN OF ty_input,
             coverage_pct TYPE i,
             has_shortage TYPE abap_bool,
           END OF ty_input.

    METHODS grade
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rv_grade) TYPE ty_grade.

ENDCLASS.


CLASS zcl_alloc_grade IMPLEMENTATION.

  METHOD grade.
    IF is_input-has_shortage = abap_false
        AND is_input-coverage_pct >= 100.
      rv_grade = 'A'.
    ELSEIF is_input-coverage_pct >= 95.
      rv_grade = 'B'.
    ELSEIF is_input-coverage_pct >= 80.
      rv_grade = 'C'.
    ELSEIF is_input-coverage_pct >= 60.
      rv_grade = 'D'.
    ELSEIF is_input-coverage_pct >= 40.
      rv_grade = 'E'.
    ELSE.
      rv_grade = 'F'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
