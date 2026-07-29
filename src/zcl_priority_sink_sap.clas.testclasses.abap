CLASS ltcl_priority_sink_sap DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS c_material TYPE zif_stock_allocation=>ty_material VALUE 'ZUT-PRIO-SINK'.
    CONSTANTS c_plant TYPE zif_stock_allocation=>ty_plant VALUE 'UT01'.
    CONSTANTS c_storage TYPE zif_stock_allocation=>ty_storage_loc VALUE 'UT01'.
    CONSTANTS c_order TYPE zif_stock_allocation=>ty_sales_order VALUE '0099999999'.
    CONSTANTS c_item TYPE zif_stock_allocation=>ty_sales_item VALUE '000010'.
    METHODS teardown.
    METHODS saves_and_removes_priority FOR TESTING.
ENDCLASS.

CLASS ltcl_priority_sink_sap IMPLEMENTATION.
  METHOD teardown.
    DELETE FROM zstockprio
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
        AND vbeln = @c_order
        AND posnr = @c_item.
  ENDMETHOD.

  METHOD saves_and_removes_priority.
    DATA(lo_sink) = NEW zcl_priority_sink_sap( ).
    lo_sink->zif_priority_sink~save(
      iv_material         = c_material
      iv_plant            = c_plant
      iv_storage_location = c_storage
      iv_sales_order      = c_order
      iv_sales_item       = c_item
      iv_priority         = 11 ).

    SELECT SINGLE *
      FROM zstockprio
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
        AND vbeln = @c_order
        AND posnr = @c_item
      INTO @DATA(ls_saved).

    cl_abap_unit_assert=>assert_equals( act = ls_saved-priority exp = 11 ).
    cl_abap_unit_assert=>assert_equals( act = ls_saved-changed_on exp = sy-datum ).
    cl_abap_unit_assert=>assert_equals( act = ls_saved-changed_at exp = sy-uzeit ).
    cl_abap_unit_assert=>assert_equals( act = ls_saved-changed_by exp = sy-uname ).

    lo_sink->zif_priority_sink~remove(
      iv_material         = c_material
      iv_plant            = c_plant
      iv_storage_location = c_storage
      iv_sales_order      = c_order
      iv_sales_item       = c_item ).

    SELECT COUNT( * )
      FROM zstockprio
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
        AND vbeln = @c_order
        AND posnr = @c_item
      INTO @DATA(lv_count).
    cl_abap_unit_assert=>assert_equals( act = lv_count exp = 0 ).
  ENDMETHOD.
ENDCLASS.
