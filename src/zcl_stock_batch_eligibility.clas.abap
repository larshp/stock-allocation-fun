CLASS zcl_stock_batch_eligibility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_eligible
      IMPORTING
        iv_expiration_date    TYPE d
        iv_as_of_date         TYPE d
        iv_min_days           TYPE i
      RETURNING
        VALUE(rv_is_eligible) TYPE abap_bool
      RAISING
        zcx_invalid_stock_request.
ENDCLASS.

CLASS zcl_stock_batch_eligibility IMPLEMENTATION.

  METHOD is_eligible.
    IF iv_as_of_date IS INITIAL OR iv_min_days < 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_expiration_date IS INITIAL.
      rv_is_eligible = xsdbool( iv_min_days = 0 ).
      RETURN.
    ENDIF.

    IF iv_expiration_date < iv_as_of_date
        OR iv_expiration_date - iv_as_of_date < iv_min_days.
      RETURN.
    ENDIF.

    rv_is_eligible = abap_true.
  ENDMETHOD.

ENDCLASS.
