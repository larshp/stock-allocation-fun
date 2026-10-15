CLASS zcl_alloc_return_limit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS within_limit
      IMPORTING
        iv_value     TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS needs_manager
      IMPORTING
        iv_value       TYPE i
        iv_clerk_limit TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

    METHODS limit_of
      IMPORTING
        iv_tier         TYPE string
      RETURNING
        VALUE(rv_limit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_limit IMPLEMENTATION.

  METHOD within_limit.
    " A value is within the limit when it is not negative and does not exceed it.
    rv_ok = xsdbool( iv_value >= 0 AND iv_limit > 0 AND iv_value <= iv_limit ).
  ENDMETHOD.

  METHOD needs_manager.
    " Anything above the clerk's limit needs a manager.
    rv_ok = xsdbool( iv_clerk_limit >= 0 AND iv_value > iv_clerk_limit ).
  ENDMETHOD.

  METHOD limit_of.
    " Each approval tier carries its own limit.
    CASE iv_tier.
      WHEN 'CLERK'.
        rv_limit = 100.
      WHEN 'MANAGER'.
        rv_limit = 1000.
      WHEN 'DIRECTOR'.
        rv_limit = 10000.
      WHEN OTHERS.
        rv_limit = 0.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
