CLASS zcl_stock_snapshot_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        is_valid TYPE abap_bool,
        message  TYPE string,
      END OF ty_result.

    CLASS-METHODS validate
      IMPORTING
        it_requests       TYPE zcl_stock_allocator=>ty_requests
        it_stock_balances TYPE zcl_stock_allocator=>ty_stock_balances
      RETURNING
        VALUE(rs_result)  TYPE ty_result.

  PRIVATE SECTION.
    TYPES ty_persisted_quantity TYPE p LENGTH 7 DECIMALS 3.
    TYPES:
      BEGIN OF ty_domain,
        material TYPE zcl_stock_allocator=>ty_material,
        plant    TYPE zcl_stock_allocator=>ty_plant,
      END OF ty_domain.
    TYPES ty_domains TYPE SORTED TABLE OF ty_domain
      WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_material_unit,
        material  TYPE zcl_stock_allocator=>ty_material,
        base_unit TYPE zcl_stock_allocator=>ty_unit,
      END OF ty_material_unit.
    TYPES ty_material_units TYPE SORTED TABLE OF ty_material_unit
      WITH UNIQUE KEY material.
    TYPES:
      BEGIN OF ty_plant_safety,
        material         TYPE zcl_stock_allocator=>ty_material,
        plant            TYPE zcl_stock_allocator=>ty_plant,
        safety_stock_qty TYPE zcl_stock_allocator=>ty_quantity,
      END OF ty_plant_safety.
    TYPES ty_plant_safeties TYPE SORTED TABLE OF ty_plant_safety
      WITH UNIQUE KEY material plant.
ENDCLASS.

CLASS zcl_stock_snapshot_validator IMPLEMENTATION.
  METHOD validate.
    DATA lt_domains TYPE ty_domains.
    DATA lt_material_units TYPE ty_material_units.
    DATA lt_plant_safeties TYPE ty_plant_safeties.
    DATA lv_rounded_unrestricted TYPE ty_persisted_quantity.
    DATA lv_rounded_safety TYPE ty_persisted_quantity.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-material IS INITIAL OR ls_request-plant IS INITIAL.
        rs_result-message = 'Stock request scope is invalid'.
        RETURN.
      ENDIF.
      INSERT VALUE #(
        material = ls_request-material
        plant    = ls_request-plant ) INTO TABLE lt_domains.
    ENDLOOP.

    LOOP AT it_stock_balances INTO DATA(ls_stock).
      IF ls_stock-material IS INITIAL
          OR ls_stock-plant IS INITIAL
          OR ls_stock-storage_location IS INITIAL.
        rs_result-message = 'Stock snapshot identity is incomplete'.
        RETURN.
      ENDIF.
      IF NOT line_exists( lt_domains[
        material = ls_stock-material
        plant    = ls_stock-plant ] ).
        rs_result-message = 'Stock snapshot contains an unrequested domain'.
        RETURN.
      ENDIF.
      IF abs( ls_stock-unrestricted_qty )
            > zcl_stock_allocator=>gc_max_quantity
          OR ls_stock-safety_stock_qty < 0
          OR ls_stock-safety_stock_qty
            > zcl_stock_allocator=>gc_max_quantity.
        rs_result-message = 'Stock snapshot quantity is invalid'.
        RETURN.
      ENDIF.
      lv_rounded_unrestricted = ls_stock-unrestricted_qty.
      lv_rounded_safety = ls_stock-safety_stock_qty.
      IF lv_rounded_unrestricted <> ls_stock-unrestricted_qty
          OR lv_rounded_safety <> ls_stock-safety_stock_qty.
        rs_result-message = 'Stock snapshot quantity is invalid'.
        RETURN.
      ENDIF.

      READ TABLE lt_material_units INTO DATA(ls_material_unit)
        WITH TABLE KEY material = ls_stock-material.
      IF sy-subrc = 0.
        IF ls_material_unit-base_unit <> ls_stock-base_unit.
          rs_result-message = 'Stock snapshot base units conflict'.
          RETURN.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material  = ls_stock-material
          base_unit = ls_stock-base_unit ) INTO TABLE lt_material_units.
      ENDIF.

      READ TABLE lt_plant_safeties INTO DATA(ls_plant_safety)
        WITH TABLE KEY material = ls_stock-material
                       plant = ls_stock-plant.
      IF sy-subrc = 0.
        IF ls_plant_safety-safety_stock_qty
            <> ls_stock-safety_stock_qty.
          rs_result-message = 'Stock snapshot safety stock conflicts'.
          RETURN.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material         = ls_stock-material
          plant            = ls_stock-plant
          safety_stock_qty = ls_stock-safety_stock_qty )
          INTO TABLE lt_plant_safeties.
      ENDIF.
    ENDLOOP.

    rs_result-is_valid = abap_true.
  ENDMETHOD.
ENDCLASS.
