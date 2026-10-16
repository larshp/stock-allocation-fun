CLASS zcl_alloc_dock_to_stock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS elapsed_minutes
      IMPORTING
        iv_arrival    TYPE i
        iv_completion TYPE i
      RETURNING
        VALUE(rv_min) TYPE i.

    METHODS is_on_target
      IMPORTING
        iv_minutes   TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS classify
      IMPORTING
        iv_minutes      TYPE i
        iv_target       TYPE i
      RETURNING
        VALUE(rv_class) TYPE string.

ENDCLASS.


CLASS zcl_alloc_dock_to_stock IMPLEMENTATION.

  METHOD elapsed_minutes.
    " Times are minutes from a fixed reference. A completion before the arrival is
    " a data error, so the elapsed time floors at zero.
    IF iv_completion <= iv_arrival.
      RETURN.
    ENDIF.

    rv_min = iv_completion - iv_arrival.
  ENDMETHOD.

  METHOD is_on_target.
    rv_ok = xsdbool( iv_target > 0 AND iv_minutes <= iv_target ).
  ENDMETHOD.

  METHOD classify.
    IF iv_target <= 0.
      RETURN.
    ENDIF.

    IF iv_minutes <= iv_target.
      rv_class = 'ON_TARGET'.
    ELSEIF iv_minutes <= iv_target * 2.
      rv_class = 'SLOW'.
    ELSE.
      rv_class = 'LATE'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
