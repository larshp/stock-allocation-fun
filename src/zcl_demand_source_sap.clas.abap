CLASS zcl_demand_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_demand_source.
ENDCLASS.

CLASS zcl_demand_source_sap IMPLEMENTATION.
  METHOD zif_demand_source~get_open_demands.
    SELECT vbeln, posnr, etenr, mbdat, omeng
      FROM vbbe
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND omeng > 0
      INTO TABLE @DATA(lt_requirements).

    rt_demands = VALUE #(
      FOR ls_requirement IN lt_requirements
      ( sales_order = ls_requirement-vbeln
        sales_item = ls_requirement-posnr
        schedule_line = ls_requirement-etenr
        delivery_date = ls_requirement-mbdat
        requested_qty = ls_requirement-omeng ) ).
  ENDMETHOD.
ENDCLASS.
