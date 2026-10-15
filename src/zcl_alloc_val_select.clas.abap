CLASS zcl_alloc_val_select DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS select
      IMPORTING
        iv_policy        TYPE string
      RETURNING
        VALUE(rv_method) TYPE string.

    METHODS is_standard
      IMPORTING
        iv_method    TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_method        TYPE string
      RETURNING
        VALUE(rv_reason) TYPE string.

ENDCLASS.


CLASS zcl_alloc_val_select IMPLEMENTATION.

  METHOD select.
    " The policy names the method, and anything unknown falls back to average.
    CASE iv_policy.
      WHEN 'STANDARD'.
        rv_method = 'STANDARD'.
      WHEN 'LOWEST'.
        rv_method = 'LOWEST'.
      WHEN OTHERS.
        rv_method = 'AVERAGE'.
    ENDCASE.
  ENDMETHOD.

  METHOD is_standard.
    " Standard valuation is its own method.
    rv_ok = xsdbool( iv_method = 'STANDARD' ).
  ENDMETHOD.

  METHOD reason.
    " The method is explained in one line, for the valuation log.
    CASE iv_method.
      WHEN 'STANDARD'.
        rv_reason = 'fixed standard cost'.
      WHEN 'LOWEST'.
        rv_reason = 'lower of cost and market'.
      WHEN OTHERS.
        rv_reason = 'weighted average cost'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
