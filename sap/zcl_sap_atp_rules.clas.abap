CLASS zcl_sap_atp_rules DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_stock,
        material         TYPE string,
        plant            TYPE string,
        batch            TYPE string,
        unit_of_measure  TYPE string,
        expiry_date      TYPE d,
        receipt_date     TYPE d,
        unrestricted_qty TYPE zcl_sap_uom_rules=>ty_quantity,
        quality_qty      TYPE zcl_sap_uom_rules=>ty_quantity,
        blocked_qty      TYPE zcl_sap_uom_rules=>ty_quantity,
        safety_stock     TYPE zcl_sap_uom_rules=>ty_quantity,
      END OF ty_stock,
      ty_stocks TYPE STANDARD TABLE OF ty_stock WITH EMPTY KEY,
      BEGIN OF ty_reservation,
        reservation_id TYPE string,
        material       TYPE string,
        plant          TYPE string,
        batch          TYPE string,
        reserved_qty   TYPE zcl_sap_uom_rules=>ty_quantity,
        valid_from     TYPE d,
        valid_to       TYPE d,
      END OF ty_reservation,
      ty_reservations TYPE STANDARD TABLE OF ty_reservation WITH EMPTY KEY.

    CLASS-METHODS available_quantity
      IMPORTING
        stock               TYPE ty_stock
        allocation_date     TYPE d
        minimum_expiry_date TYPE d OPTIONAL
        reserved_qty        TYPE zcl_sap_uom_rules=>ty_quantity OPTIONAL
      RETURNING
        VALUE(result)       TYPE zcl_sap_uom_rules=>ty_quantity.
    CLASS-METHODS active_reserved_quantity
      IMPORTING
        stock             TYPE ty_stock
        reservations      TYPE ty_reservations
        allocation_date   TYPE d
      RETURNING
        VALUE(result)     TYPE zcl_sap_uom_rules=>ty_quantity.
ENDCLASS.

CLASS zcl_sap_atp_rules IMPLEMENTATION.
  METHOD available_quantity.
    DATA expiry_threshold TYPE d.

    expiry_threshold = allocation_date.
    IF minimum_expiry_date > expiry_threshold.
      expiry_threshold = minimum_expiry_date.
    ENDIF.

    IF stock-expiry_date IS NOT INITIAL
        AND stock-expiry_date < expiry_threshold.
      RETURN.
    ENDIF.

    result = stock-unrestricted_qty - stock-safety_stock - reserved_qty.
    IF result < 0.
      CLEAR result.
    ENDIF.
  ENDMETHOD.

  METHOD active_reserved_quantity.
    LOOP AT reservations INTO DATA(reservation)
        WHERE material = stock-material
          AND plant = stock-plant
          AND batch = stock-batch.
      IF reservation-valid_from IS NOT INITIAL
          AND reservation-valid_from > allocation_date.
        CONTINUE.
      ENDIF.
      IF reservation-valid_to IS NOT INITIAL
          AND reservation-valid_to < allocation_date.
        CONTINUE.
      ENDIF.
      result = result + reservation-reserved_qty.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
