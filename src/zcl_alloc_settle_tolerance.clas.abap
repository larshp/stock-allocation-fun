CLASS zcl_alloc_settle_tolerance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS within_tolerance
      IMPORTING
        iv_difference TYPE i
        iv_tolerance  TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS tolerance
      IMPORTING
        iv_amount           TYPE i
        iv_percent          TYPE i
      RETURNING
        VALUE(rv_tolerance) TYPE i.

    METHODS is_tight
      IMPORTING
        iv_tolerance TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_settle_tolerance IMPLEMENTATION.

  METHOD within_tolerance.
    DATA lv_magnitude TYPE i.

    " The difference is within tolerance once its size fits the limit.
    lv_magnitude = iv_difference.
    IF lv_magnitude < 0.
      lv_magnitude = lv_magnitude * -1.
    ENDIF.

    rv_ok = xsdbool( lv_magnitude <= iv_tolerance ).
  ENDMETHOD.

  METHOD tolerance.
    " The tolerance is a percentage of the amount.
    rv_tolerance = iv_amount * iv_percent DIV 100.
  ENDMETHOD.

  METHOD is_tight.
    " The tolerance is tight once it sits at or below the limit.
    rv_ok = xsdbool( iv_tolerance <= iv_limit ).
  ENDMETHOD.

ENDCLASS.
