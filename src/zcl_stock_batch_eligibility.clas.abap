CLASS zcl_stock_batch_eligibility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_eligible
      IMPORTING
        iv_expiration_date         TYPE d
        iv_as_of_date              TYPE d
        iv_min_days                TYPE i
        iv_include_undated_batches TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rv_is_eligible)      TYPE abap_bool
      RAISING
        zcx_invalid_stock_request.
ENDCLASS.

CLASS zcl_stock_batch_eligibility IMPLEMENTATION.

  METHOD is_eligible.
    IF zcl_date_validation=>is_valid_gregorian_date(
          iv_date = iv_as_of_date ) <> abap_true
        OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_expiration_date IS INITIAL.
      rv_is_eligible = xsdbool(
        iv_min_days = 0 AND iv_include_undated_batches = abap_true ).
      RETURN.
    ENDIF.

    IF zcl_date_validation=>is_valid_gregorian_date(
        iv_date = iv_expiration_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_expiration_date < iv_as_of_date
        OR iv_expiration_date - iv_as_of_date < iv_min_days.
      RETURN.
    ENDIF.

    rv_is_eligible = abap_true.
  ENDMETHOD.

ENDCLASS.
