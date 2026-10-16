CLASS zcl_alloc_valm_threshold DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_over
      IMPORTING
        iv_value     TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS breach
      IMPORTING
        iv_value       TYPE i
        iv_threshold   TYPE i
      RETURNING
        VALUE(rv_over) TYPE i.

    METHODS level
      IMPORTING
        iv_value        TYPE i
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_level) TYPE string.

ENDCLASS.


CLASS zcl_alloc_valm_threshold IMPLEMENTATION.

  METHOD is_over.
    " The value breaches once it passes the threshold.
    rv_ok = xsdbool( iv_value > iv_threshold ).
  ENDMETHOD.

  METHOD breach.
    " The breach is how far past the threshold the value runs.
    IF iv_value <= iv_threshold.
      RETURN.
    ENDIF.

    rv_over = iv_value - iv_threshold.
  ENDMETHOD.

  METHOD level.
    " Twice the threshold is a high breach, anything past it is medium.
    IF iv_value > 2 * iv_threshold.
      rv_level = 'HIGH'.
    ELSEIF iv_value > iv_threshold.
      rv_level = 'MEDIUM'.
    ELSE.
      rv_level = 'NONE'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
