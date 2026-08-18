CLASS zcl_stock_rechecker_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_rechecker.

    METHODS constructor
      IMPORTING
        io_stock_reader TYPE REF TO zif_stock_reader.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_required_stock,
        material         TYPE zcl_stock_allocator=>ty_material,
        plant            TYPE zcl_stock_allocator=>ty_plant,
        storage_location TYPE zcl_stock_allocator=>ty_storage_location,
        quantity         TYPE zcl_stock_allocator=>ty_quantity,
      END OF ty_required_stock.
    TYPES ty_required_stocks TYPE SORTED TABLE OF ty_required_stock
      WITH UNIQUE KEY material plant storage_location.

    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
ENDCLASS.

CLASS zcl_stock_rechecker_sap IMPLEMENTATION.
  METHOD constructor.
    mo_stock_reader = io_stock_reader.
  ENDMETHOD.

  METHOD zif_stock_rechecker~recheck.
    DATA lt_requests TYPE zcl_stock_allocator=>ty_requests.
    DATA lt_required_stocks TYPE ty_required_stocks.

    LOOP AT it_allocations INTO DATA(ls_allocation)
      WHERE allocated_qty > 0.
      APPEND VALUE #(
        request_id       = ls_allocation-request_id
        material         = ls_allocation-material
        plant            = ls_allocation-plant
        storage_location = ls_allocation-storage_location
        movement_type    = ls_allocation-movement_type
        requirement_date = ls_allocation-requirement_date
        requested_qty    = ls_allocation-allocated_qty ) TO lt_requests.

      READ TABLE lt_required_stocks ASSIGNING FIELD-SYMBOL(<ls_required>)
        WITH TABLE KEY material = ls_allocation-material
                       plant = ls_allocation-plant
                       storage_location = ls_allocation-storage_location.
      IF sy-subrc = 0.
        <ls_required>-quantity =
          <ls_required>-quantity + ls_allocation-allocated_qty.
      ELSE.
        INSERT VALUE #(
          material         = ls_allocation-material
          plant            = ls_allocation-plant
          storage_location = ls_allocation-storage_location
          quantity         = ls_allocation-allocated_qty )
          INTO TABLE lt_required_stocks.
      ENDIF.
    ENDLOOP.

    DATA(lt_stock) = mo_stock_reader->read_stock( lt_requests ).
    LOOP AT lt_required_stocks INTO DATA(ls_required_stock).
      READ TABLE lt_stock INTO DATA(ls_stock)
        WITH TABLE KEY material = ls_required_stock-material
                       plant = ls_required_stock-plant
                       storage_location = ls_required_stock-storage_location.
      IF sy-subrc <> 0.
        rs_result-is_valid = abap_false.
        rs_result-message = 'Stock disappeared during allocation posting'.
        RETURN.
      ENDIF.

      DATA(lv_available) =
        ls_stock-unrestricted_qty - ls_stock-safety_stock_qty.
      IF lv_available < ls_required_stock-quantity.
        rs_result-is_valid = abap_false.
        rs_result-message = 'Available stock changed during allocation posting'.
        RETURN.
      ENDIF.
    ENDLOOP.

    rs_result-is_valid = abap_true.
  ENDMETHOD.
ENDCLASS.
