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
        unit_of_measure  TYPE zcl_stock_allocator=>ty_unit,
        quantity         TYPE zcl_stock_allocator=>ty_quantity,
      END OF ty_required_stock.
    TYPES ty_required_stocks TYPE SORTED TABLE OF ty_required_stock
      WITH UNIQUE KEY material plant storage_location unit_of_measure.

    TYPES:
      BEGIN OF ty_plant_quantity,
        material         TYPE zcl_stock_allocator=>ty_material,
        plant            TYPE zcl_stock_allocator=>ty_plant,
        unit_of_measure  TYPE zcl_stock_allocator=>ty_unit,
        quantity         TYPE zcl_stock_allocator=>ty_quantity,
        safety_stock_qty TYPE zcl_stock_allocator=>ty_quantity,
      END OF ty_plant_quantity.
    TYPES ty_plant_quantities TYPE SORTED TABLE OF ty_plant_quantity
      WITH UNIQUE KEY material plant unit_of_measure.

    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
ENDCLASS.

CLASS zcl_stock_rechecker_sap IMPLEMENTATION.
  METHOD constructor.
    mo_stock_reader = io_stock_reader.
  ENDMETHOD.

  METHOD zif_stock_rechecker~recheck.
    DATA lt_requests TYPE zcl_stock_allocator=>ty_requests.
    DATA lt_required_stocks TYPE ty_required_stocks.
    DATA lt_required_plants TYPE ty_plant_quantities.

    LOOP AT it_allocations INTO DATA(ls_allocation)
      WHERE allocated_qty > 0.
      APPEND VALUE #(
        request_id       = ls_allocation-request_id
        material         = ls_allocation-material
        plant            = ls_allocation-plant
        storage_location = ls_allocation-storage_location
        movement_type    = ls_allocation-movement_type
        cost_center      = ls_allocation-cost_center
        order_id         = ls_allocation-order_id
        wbs_element      = ls_allocation-wbs_element
        sales_order      = ls_allocation-sales_order
        sales_order_item = ls_allocation-sales_order_item
        asset_number     = ls_allocation-asset_number
        asset_subnumber  = ls_allocation-asset_subnumber
        network_id       = ls_allocation-network_id
        network_activity = ls_allocation-network_activity
        unit_of_measure  = ls_allocation-unit_of_measure
        requirement_date = ls_allocation-requirement_date
        requested_qty    = ls_allocation-allocated_qty ) TO lt_requests.

      READ TABLE lt_required_stocks ASSIGNING FIELD-SYMBOL(<ls_required>)
        WITH TABLE KEY material = ls_allocation-material
                       plant = ls_allocation-plant
                       storage_location = ls_allocation-storage_location
                       unit_of_measure = ls_allocation-unit_of_measure.
      IF sy-subrc = 0.
        <ls_required>-quantity =
          <ls_required>-quantity + ls_allocation-allocated_qty.
      ELSE.
        INSERT VALUE #(
          material         = ls_allocation-material
          plant            = ls_allocation-plant
          storage_location = ls_allocation-storage_location
          unit_of_measure  = ls_allocation-unit_of_measure
          quantity         = ls_allocation-allocated_qty )
          INTO TABLE lt_required_stocks.
      ENDIF.

      READ TABLE lt_required_plants ASSIGNING FIELD-SYMBOL(<ls_required_plant>)
        WITH TABLE KEY material = ls_allocation-material
                       plant = ls_allocation-plant
                       unit_of_measure = ls_allocation-unit_of_measure.
      IF sy-subrc = 0.
        <ls_required_plant>-quantity =
          <ls_required_plant>-quantity + ls_allocation-allocated_qty.
      ELSE.
        INSERT VALUE #(
          material        = ls_allocation-material
          plant           = ls_allocation-plant
          unit_of_measure = ls_allocation-unit_of_measure
          quantity        = ls_allocation-allocated_qty )
          INTO TABLE lt_required_plants.
      ENDIF.
    ENDLOOP.

    DATA(ls_stock_result) = mo_stock_reader->read_stock( lt_requests ).
    IF ls_stock_result-is_success <> abap_true.
      rs_result-message = COND #(
        WHEN ls_stock_result-is_success = abap_false
          AND ls_stock_result-message IS NOT INITIAL
        THEN ls_stock_result-message
        ELSE 'Stock reader returned invalid state during posting' ).
      RETURN.
    ENDIF.
    DATA(lt_stock) = ls_stock_result-stock.
    DATA(ls_snapshot_validation) =
      zcl_stock_snapshot_validator=>validate(
        it_requests       = lt_requests
        it_stock_balances = lt_stock ).
    IF ls_snapshot_validation-is_valid <> abap_true.
      rs_result-message = ls_snapshot_validation-message.
      RETURN.
    ENDIF.
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

      IF ls_stock-base_unit <> ls_required_stock-unit_of_measure.
        rs_result-is_valid = abap_false.
        rs_result-message = 'Material base unit changed during allocation posting'.
        RETURN.
      ENDIF.

      IF ls_stock-unrestricted_qty < ls_required_stock-quantity.
        rs_result-is_valid = abap_false.
        rs_result-message = 'Available stock changed during allocation posting'.
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA lt_stock_plants TYPE ty_plant_quantities.
    LOOP AT lt_stock INTO ls_stock.
      READ TABLE lt_stock_plants ASSIGNING FIELD-SYMBOL(<ls_stock_plant>)
        WITH TABLE KEY material = ls_stock-material
                       plant = ls_stock-plant
                       unit_of_measure = ls_stock-base_unit.
      IF sy-subrc = 0.
        <ls_stock_plant>-quantity =
          <ls_stock_plant>-quantity + ls_stock-unrestricted_qty.
        IF ls_stock-safety_stock_qty > <ls_stock_plant>-safety_stock_qty.
          <ls_stock_plant>-safety_stock_qty = ls_stock-safety_stock_qty.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material         = ls_stock-material
          plant            = ls_stock-plant
          unit_of_measure  = ls_stock-base_unit
          quantity         = ls_stock-unrestricted_qty
          safety_stock_qty = ls_stock-safety_stock_qty )
          INTO TABLE lt_stock_plants.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_required_plants INTO DATA(ls_required_plant).
      READ TABLE lt_stock_plants INTO DATA(ls_stock_plant)
        WITH TABLE KEY material = ls_required_plant-material
                       plant = ls_required_plant-plant
                       unit_of_measure = ls_required_plant-unit_of_measure.
      IF sy-subrc <> 0
          OR ls_stock_plant-quantity - ls_stock_plant-safety_stock_qty
            < ls_required_plant-quantity.
        rs_result-is_valid = abap_false.
        rs_result-message = 'Available stock changed during allocation posting'.
        RETURN.
      ENDIF.
    ENDLOOP.

    rs_result-is_valid = abap_true.
  ENDMETHOD.
ENDCLASS.
