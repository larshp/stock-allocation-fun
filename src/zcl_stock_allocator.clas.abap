CLASS zcl_stock_allocator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_demand,
        request_id      TYPE string,
        material        TYPE string,
        plant           TYPE string,
        requirement_date TYPE d,
        priority        TYPE i,
        requested_qty   TYPE i,
      END OF ty_demand,
      ty_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY,
      BEGIN OF ty_allocation,
        request_id    TYPE string,
        material      TYPE string,
        plant         TYPE string,
        batch         TYPE string,
        allocated_qty TYPE i,
        shortage_qty  TYPE i,
      END OF ty_allocation,
      ty_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

    CLASS-METHODS allocate
      IMPORTING
        demands           TYPE ty_demands
        stocks            TYPE zcl_sap_atp_rules=>ty_stocks
        allocation_date   TYPE d
      RETURNING
        VALUE(allocations) TYPE ty_allocations.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD allocate.
    DATA sorted_demands TYPE ty_demands.
    DATA remaining_stocks TYPE zcl_sap_atp_rules=>ty_stocks.
    DATA remaining TYPE i.
    DATA available TYPE i.
    DATA allocated TYPE i.

    sorted_demands = demands.
    SORT sorted_demands BY priority ASCENDING
                           requirement_date ASCENDING
                           request_id ASCENDING.

    remaining_stocks = stocks.
    SORT remaining_stocks BY material ASCENDING
                             plant ASCENDING
                             expiry_date ASCENDING
                             batch ASCENDING.

    LOOP AT sorted_demands INTO DATA(demand).
      remaining = demand-requested_qty.

      LOOP AT remaining_stocks ASSIGNING FIELD-SYMBOL(<stock>)
          WHERE material = demand-material
            AND plant = demand-plant.
        IF remaining <= 0.
          EXIT.
        ENDIF.

        available = zcl_sap_atp_rules=>available_quantity(
          stock = <stock>
          allocation_date = allocation_date ).
        IF available <= 0.
          CONTINUE.
        ENDIF.

        allocated = available.
        IF allocated > remaining.
          allocated = remaining.
        ENDIF.

        APPEND VALUE #(
          request_id = demand-request_id
          material = demand-material
          plant = demand-plant
          batch = <stock>-batch
          allocated_qty = allocated ) TO allocations.

        <stock>-unrestricted_qty = <stock>-unrestricted_qty - allocated.
        remaining = remaining - allocated.
      ENDLOOP.

      IF remaining > 0.
        APPEND VALUE #(
          request_id = demand-request_id
          material = demand-material
          plant = demand-plant
          shortage_qty = remaining ) TO allocations.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
