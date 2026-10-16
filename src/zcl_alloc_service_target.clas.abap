CLASS zcl_alloc_service_target DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS target_of
      IMPORTING
        iv_service_class TYPE string
      RETURNING
        VALUE(rv_target) TYPE i.

    METHODS is_met
      IMPORTING
        iv_actual_percent TYPE i
        iv_target         TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_actual_percent TYPE i
        iv_target         TYPE i
      RETURNING
        VALUE(rv_gap)     TYPE i.

ENDCLASS.


CLASS zcl_alloc_service_target IMPLEMENTATION.

  METHOD target_of.
    " The target service level follows the service class.
    CASE iv_service_class.
      WHEN 'A'.
        rv_target = 98.
      WHEN 'B'.
        rv_target = 95.
      WHEN OTHERS.
        rv_target = 90.
    ENDCASE.
  ENDMETHOD.

  METHOD is_met.
    " The target is met once the actual reaches it.
    rv_ok = xsdbool( iv_actual_percent >= iv_target ).
  ENDMETHOD.

  METHOD gap.
    " The gap is the shortfall against the target, never negative.
    IF iv_actual_percent >= iv_target.
      RETURN.
    ENDIF.

    rv_gap = iv_target - iv_actual_percent.
  ENDMETHOD.

ENDCLASS.
