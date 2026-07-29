CLASS zcl_sap_atp_rules DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_stock,
        material         TYPE string,
        plant            TYPE string,
        batch            TYPE string,
        expiry_date      TYPE d,
        unrestricted_qty TYPE i,
        quality_qty      TYPE i,
        blocked_qty      TYPE i,
        safety_stock     TYPE i,
      END OF ty_stock,
      ty_stocks TYPE STANDARD TABLE OF ty_stock WITH EMPTY KEY.

    CLASS-METHODS available_quantity
      IMPORTING
        stock           TYPE ty_stock
        allocation_date TYPE d
      RETURNING
        VALUE(result)   TYPE i.
ENDCLASS.

CLASS zcl_sap_atp_rules IMPLEMENTATION.
  METHOD available_quantity.
    IF stock-expiry_date IS NOT INITIAL
        AND stock-expiry_date < allocation_date.
      RETURN.
    ENDIF.

    result = stock-unrestricted_qty - stock-safety_stock.
    IF result < 0.
      CLEAR result.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
