CLASS zcl_plaf_order_read_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_planned_order_read_repo.
ENDCLASS.

CLASS zcl_plaf_order_read_repo IMPLEMENTATION.

  METHOD zif_planned_order_read_repo~read_orders.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mara-matnr,
      END OF ty_material_key,
      ty_material_keys TYPE SORTED TABLE OF ty_material_key
        WITH UNIQUE KEY material,
      BEGIN OF ty_base_unit,
        material  TYPE mara-matnr,
        base_unit TYPE mara-meins,
      END OF ty_base_unit,
      ty_base_units TYPE HASHED TABLE OF ty_base_unit
        WITH UNIQUE KEY material,
      BEGIN OF ty_unit_conversion,
        material    TYPE marm-matnr,
        unit        TYPE marm-meinh,
        numerator   TYPE marm-umrez,
        denominator TYPE marm-umren,
      END OF ty_unit_conversion,
      ty_unit_conversions TYPE HASHED TABLE OF ty_unit_conversion
        WITH UNIQUE KEY material unit.
    DATA lt_orders TYPE zif_planned_order_read_repo=>ty_order_headers.
    DATA lt_material_keys TYPE ty_material_keys.
    DATA lt_base_units TYPE ty_base_units.
    DATA lt_unit_conversions TYPE ty_unit_conversions.

    IF it_planned_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT plnum AS planned_order,
           matnr AS material,
           pwwrk AS plant,
           psttr AS start_date,
           pedtr AS finish_date,
           gsmng AS quantity,
           meins AS order_unit,
           auffx AS fixed_indicator,
           plscn AS planning_scenario,
           sobkz AS special_stock_indicator,
           kdauf AS sales_order
      FROM plaf
      FOR ALL ENTRIES IN @it_planned_orders
      WHERE plnum = @it_planned_orders-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_orders.

    IF lt_orders IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_orders INTO DATA(ls_order).
      INSERT VALUE #( material = ls_order-material )
        INTO TABLE lt_material_keys.
    ENDLOOP.

    SELECT matnr AS material,
           meins AS base_unit
      FROM mara
      FOR ALL ENTRIES IN @lt_material_keys
      WHERE matnr = @lt_material_keys-material
      INTO TABLE @lt_base_units.

    SELECT matnr AS material,
           meinh AS unit,
           umrez AS numerator,
           umren AS denominator
      FROM marm
      FOR ALL ENTRIES IN @lt_material_keys
      WHERE matnr = @lt_material_keys-material
      INTO TABLE @lt_unit_conversions.

    LOOP AT lt_orders INTO ls_order.
      READ TABLE lt_base_units INTO DATA(ls_base_unit)
        WITH TABLE KEY material = ls_order-material.
      IF sy-subrc = 0.
        ls_order-base_unit = ls_base_unit-base_unit.
      ENDIF.

      READ TABLE lt_unit_conversions INTO DATA(ls_unit_conversion)
        WITH TABLE KEY
          material = ls_order-material
          unit = ls_order-order_unit.
      IF sy-subrc = 0.
        ls_order-unit_to_base_numerator = ls_unit_conversion-numerator.
        ls_order-unit_to_base_denominator = ls_unit_conversion-denominator.
      ENDIF.

      APPEND ls_order TO rt_orders.
    ENDLOOP.

    SORT rt_orders BY planned_order.
  ENDMETHOD.

ENDCLASS.
