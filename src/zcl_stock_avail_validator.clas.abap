CLASS zcl_stock_avail_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS validate
      IMPORTING
        iv_include_reservations TYPE abap_bool
        is_available            TYPE zif_stock_allocation=>ty_available
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    CLASS-METHODS raise_error
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_avail_validator IMPLEMENTATION.
  METHOD validate.
    IF ( iv_include_reservations <> abap_true
          AND iv_include_reservations <> abap_false )
        OR ( is_available-reservations_included <> abap_true
          AND is_available-reservations_included <> abap_false )
        OR is_available-quantity < 0
        OR is_available-unrestricted_quantity < 0
        OR is_available-quality_inspection_qty < 0
        OR is_available-restricted_use_qty < 0
        OR is_available-blocked_stock_qty < 0
        OR is_available-transfer_stock_qty < 0
        OR is_available-reservation_quantity < 0
        OR is_available-batch_reservation_quantity < 0
        OR is_available-unassigned_resv_quantity < 0.
      raise_error( ).
    ENDIF.

    IF is_available-unassigned_resv_quantity
        > is_available-reservation_quantity.
      raise_error( ).
    ENDIF.
    IF is_available-batch_reservation_quantity
        <> is_available-reservation_quantity
          - is_available-unassigned_resv_quantity.
      raise_error( ).
    ENDIF.

    IF iv_include_reservations = abap_true.
      IF is_available-reservations_included <> abap_true.
        raise_error( ).
      ENDIF.
      IF is_available-reservation_quantity
          >= is_available-unrestricted_quantity.
        IF is_available-quantity <> 0.
          raise_error( ).
        ENDIF.
      ELSEIF is_available-quantity
          <> is_available-unrestricted_quantity
            - is_available-reservation_quantity.
        raise_error( ).
      ENDIF.
    ELSE.
      IF is_available-reservations_included <> abap_false
          OR is_available-reservation_quantity <> 0
          OR is_available-batch_reservation_quantity <> 0
          OR is_available-unassigned_resv_quantity <> 0
          OR is_available-quantity
            <> is_available-unrestricted_quantity.
        raise_error( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Stock reservation result is invalid'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
