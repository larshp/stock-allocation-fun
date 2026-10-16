CLASS zcl_alloc_usage_decision DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS decide
      IMPORTING
        iv_defect_rate TYPE i
      RETURNING
        VALUE(rv_code) TYPE string.

    METHODS is_accepted
      IMPORTING
        iv_code      TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_usage_decision IMPLEMENTATION.

  METHOD decide.
    " The defect rate is a whole percentage, and the code follows the usual
    " progression: unrestricted, restricted, rework, reject.
    IF iv_defect_rate <= 0.
      rv_code = 'A'.
    ELSEIF iv_defect_rate <= 2.
      rv_code = 'B'.
    ELSEIF iv_defect_rate <= 5.
      rv_code = 'C'.
    ELSE.
      rv_code = 'D'.
    ENDIF.
  ENDMETHOD.

  METHOD is_accepted.
    rv_ok = xsdbool( iv_code = 'A' OR iv_code = 'B' ).
  ENDMETHOD.

ENDCLASS.
