CLASS zcl_plaf_order_read_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_planned_order_read_repo.
ENDCLASS.

CLASS zcl_plaf_order_read_repo IMPLEMENTATION.

  METHOD zif_planned_order_read_repo~read_orders.
    IF it_planned_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT plaf~plnum AS planned_order,
           plaf~matnr AS material,
           plaf~pwwrk AS plant,
           plaf~psttr AS start_date,
           plaf~pedtr AS finish_date,
           plaf~gsmng AS quantity,
           plaf~meins AS order_unit,
           material_data~meins AS base_unit,
           plaf~auffx AS fixed_indicator,
           plaf~plscn AS planning_scenario,
           plaf~sobkz AS special_stock_indicator,
           plaf~kdauf AS sales_order,
           unit_data~umrez AS unit_to_base_numerator,
           unit_data~umren AS unit_to_base_denominator
      FROM plaf
      LEFT OUTER JOIN mara AS material_data
        ON material_data~matnr = plaf~matnr
      LEFT OUTER JOIN marm AS unit_data
        ON unit_data~matnr = plaf~matnr
       AND unit_data~meinh = plaf~meins
      FOR ALL ENTRIES IN @it_planned_orders
      WHERE plaf~plnum = @it_planned_orders-table_line
      INTO CORRESPONDING FIELDS OF TABLE @rt_orders.

    SORT rt_orders BY planned_order.
  ENDMETHOD.

ENDCLASS.
