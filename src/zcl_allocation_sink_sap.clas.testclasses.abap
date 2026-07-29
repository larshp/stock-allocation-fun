CLASS ltcl_allocation_sink_sap DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS c_material TYPE zif_stock_allocation=>ty_material VALUE 'ZUT-ALLOC-SINK'.
    CONSTANTS c_plant TYPE zif_stock_allocation=>ty_plant VALUE 'UT01'.
    CONSTANTS c_storage TYPE zif_stock_allocation=>ty_storage_loc VALUE 'UT01'.
    METHODS teardown.
    METHODS replaces_scope_snapshot FOR TESTING.
    METHODS clears_scope_snapshot FOR TESTING.
    METHODS rejects_corrupt_snapshot FOR TESTING.
    METHODS rejects_version_overflow FOR TESTING.
    METHODS rejects_invalid_plan_unchanged FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_sink_sap IMPLEMENTATION.
  METHOD teardown.
    DELETE FROM zstockahist
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage.
    DELETE FROM zstockphist
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage.
    DELETE FROM zstockalloc
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage.
    DELETE FROM zstockplan
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage.
  ENDMETHOD.

  METHOD replaces_scope_snapshot.
    DATA(lo_sink) = NEW zcl_allocation_sink_sap( ).
    DATA(lt_initial) = VALUE zif_stock_allocation=>tt_allocations(
      ( sales_order   = '0000000001'
        sales_item    = '000010'
        schedule_line = '0001'
        delivery_date = '20260729'
        requested_qty = '8'
        allocated_qty = '5'
        shortage_qty  = '3'
        reserve_qty   = '2'
        unit          = 'EA'
        strategy      = zif_stock_allocation=>c_strategy_fifo
        status        = zif_stock_allocation=>c_status_partial )
      ( sales_order   = '0000000002'
        sales_item    = '000010'
        schedule_line = '0001'
        delivery_date = '20260730'
        requested_qty = '4'
        allocated_qty = '0'
        shortage_qty  = '4'
        reserve_qty   = '2'
        unit          = 'EA'
        strategy      = zif_stock_allocation=>c_strategy_fifo
        status        = zif_stock_allocation=>c_status_none ) ).

    lo_sink->zif_allocation_sink~save(
      iv_material         = c_material
      iv_plant            = c_plant
      iv_storage_location = c_storage
      is_plan             = VALUE #(
        stock_qty       = '12'
        allocatable_qty = '10'
        reserve_qty     = '2'
        unit            = 'EA'
        strategy        = zif_stock_allocation=>c_strategy_fifo
        allocations     = lt_initial ) ).

    DATA(lt_replacement) = VALUE zif_stock_allocation=>tt_allocations(
      ( sales_order   = '0000000001'
        sales_item    = '000010'
        schedule_line = '0001'
        delivery_date = '20260731'
        priority      = 7
        requested_qty = '3'
        allocated_qty = '3'
        shortage_qty  = '0'
        reserve_qty   = '1'
        unit          = 'EA'
        strategy      = zif_stock_allocation=>c_strategy_proportional
        start_date    = '20260801'
        cutoff_date   = '20260831'
        status        = zif_stock_allocation=>c_status_full ) ).
    lo_sink->zif_allocation_sink~save(
      iv_material         = c_material
      iv_plant            = c_plant
      iv_storage_location = c_storage
      is_plan             = VALUE #(
        stock_qty       = '4'
        allocatable_qty = '3'
        reserve_qty     = '1'
        unit            = 'EA'
        strategy        = zif_stock_allocation=>c_strategy_proportional
        start_date      = '20260801'
        cutoff_date     = '20260831'
        allocations     = lt_replacement ) ).

    SELECT *
      FROM zstockalloc
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO TABLE @DATA(lt_saved).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_saved ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-priority exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-mbdat exp = '20260731' ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-alloc_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-reserve_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-meins exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved[ 1 ]-strategy
      exp = zif_stock_allocation=>c_strategy_proportional ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved[ 1 ]-start_date
      exp = '20260801' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved[ 1 ]-cutoff_date
      exp = '20260831' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved[ 1 ]-alloc_status
      exp = zif_stock_allocation=>c_status_full ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-created_on exp = sy-datum ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-created_at exp = sy-uzeit ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-created_by exp = sy-uname ).

    SELECT SINGLE *
      FROM zstockplan
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(ls_header).
    cl_abap_unit_assert=>assert_equals( act = sy-subrc exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_header-stock_qty exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = ls_header-version_no exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_header-available_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = ls_header-demand_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_header-start_date exp = '20260801' ).

    DATA(ls_read_back) = NEW zcl_allocation_source_sap(
      )->zif_allocation_source~get_saved(
        iv_material         = c_material
        iv_plant            = c_plant
        iv_storage_location = c_storage ).
    cl_abap_unit_assert=>assert_true( ls_read_back-found ).
    cl_abap_unit_assert=>assert_equals( act = ls_read_back-version_no exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_read_back-plan-allocations[ 1 ]-sales_order
      exp = '0000000001' ).
    SELECT COUNT( * )
      FROM zstockphist
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_history_headers).
    SELECT COUNT( * )
      FROM zstockahist
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_history_details).
    cl_abap_unit_assert=>assert_equals( act = lv_history_headers exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lv_history_details exp = 3 ).

    DATA(ls_first_version) = NEW zcl_allocation_source_sap(
      )->zif_allocation_source~get_saved(
        iv_material         = c_material
        iv_plant            = c_plant
        iv_storage_location = c_storage
        iv_version_no       = 1 ).
    cl_abap_unit_assert=>assert_true( ls_first_version-found ).
    cl_abap_unit_assert=>assert_equals( act = ls_first_version-version_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_first_version-plan-stock_qty exp = '12' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_first_version-plan-allocations )
      exp = 2 ).

    DATA(lt_versions) = NEW zcl_allocation_source_sap(
      )->zif_allocation_source~list_versions(
        iv_material         = c_material
        iv_plant            = c_plant
        iv_storage_location = c_storage
        iv_max_versions     = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_versions ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_versions[ 1 ]-version_no exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_versions[ 2 ]-version_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_versions[ 1 ]-demand_count exp = 1 ).

    DATA(lt_older_versions) = NEW zcl_allocation_source_sap(
      )->zif_allocation_source~list_versions(
        iv_material         = c_material
        iv_plant            = c_plant
        iv_storage_location = c_storage
        iv_max_versions     = 1
        iv_before_version   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_older_versions ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_older_versions[ 1 ]-version_no
      exp = 1 ).
  ENDMETHOD.

  METHOD clears_scope_snapshot.
    DATA(lo_sink) = NEW zcl_allocation_sink_sap( ).
    lo_sink->zif_allocation_sink~save(
      iv_material         = c_material
      iv_plant            = c_plant
      iv_storage_location = c_storage
      is_plan             = VALUE #(
        stock_qty       = '1'
        allocatable_qty = '1'
        unit            = 'EA'
        strategy        = zif_stock_allocation=>c_strategy_fifo
        allocations     = VALUE #(
          ( sales_order   = '0000000001'
            sales_item    = '000010'
            schedule_line = '0001'
            delivery_date = '20260729'
            requested_qty = '1'
            allocated_qty = '1'
            unit          = 'EA'
            strategy      = zif_stock_allocation=>c_strategy_fifo
            status        = zif_stock_allocation=>c_status_full ) ) ) ).
    lo_sink->zif_allocation_sink~save(
      iv_material         = c_material
      iv_plant            = c_plant
      iv_storage_location = c_storage
      is_plan             = VALUE #(
        stock_qty       = '5'
        allocatable_qty = '3'
        reserve_qty     = '2'
        unit            = 'EA'
        strategy        = zif_stock_allocation=>c_strategy_fifo
        allocations     = VALUE #( ) ) ).

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_count).

    cl_abap_unit_assert=>assert_equals( act = lv_count exp = 0 ).

    SELECT SINGLE demand_count, stock_qty, available_qty, reserve_qty
      FROM zstockplan
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(ls_empty_header).
    cl_abap_unit_assert=>assert_equals( act = sy-subrc exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_empty_header-demand_count exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_empty_header-stock_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_empty_header-available_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = ls_empty_header-reserve_qty exp = '2' ).
    SELECT SINGLE version_no
      FROM zstockplan
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_empty_version).
    cl_abap_unit_assert=>assert_equals( act = lv_empty_version exp = 2 ).

    DATA(ls_empty_read_back) = NEW zcl_allocation_source_sap(
      )->zif_allocation_source~get_saved(
        iv_material         = c_material
        iv_plant            = c_plant
        iv_storage_location = c_storage ).
    cl_abap_unit_assert=>assert_true( ls_empty_read_back-found ).
    cl_abap_unit_assert=>assert_initial( ls_empty_read_back-plan-allocations ).
    cl_abap_unit_assert=>assert_equals( act = ls_empty_read_back-version_no exp = 2 ).
    SELECT COUNT( * )
      FROM zstockphist
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_empty_history_headers).
    SELECT COUNT( * )
      FROM zstockahist
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
        AND version_no = 2
      INTO @DATA(lv_empty_history_details).
    cl_abap_unit_assert=>assert_equals( act = lv_empty_history_headers exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lv_empty_history_details exp = 0 ).
  ENDMETHOD.

  METHOD rejects_corrupt_snapshot.
    NEW zcl_allocation_sink_sap( )->zif_allocation_sink~save(
      iv_material         = c_material
      iv_plant            = c_plant
      iv_storage_location = c_storage
      is_plan             = VALUE #(
        stock_qty       = '1'
        allocatable_qty = '1'
        unit            = 'EA'
        strategy        = zif_stock_allocation=>c_strategy_fifo
        allocations     = VALUE #( ) ) ).
    UPDATE zstockplan
      SET demand_count = 1
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage.

    TRY.
        NEW zcl_allocation_source_sap(
          )->zif_allocation_source~get_saved(
            iv_material         = c_material
            iv_plant            = c_plant
            iv_storage_location = c_storage ).
        cl_abap_unit_assert=>fail( 'Corrupt persisted snapshot must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_version_overflow.
    DATA(ls_max_version) = VALUE zstockplan(
      matnr      = c_material
      werks      = c_plant
      lgort      = c_storage
      version_no = 2147483647
      meins      = 'EA' ).
    MODIFY zstockplan FROM @ls_max_version.
    DATA(ls_existing_detail) = VALUE zstockalloc(
      matnr        = c_material
      werks        = c_plant
      lgort        = c_storage
      vbeln        = '0000000001'
      posnr        = '000010'
      etenr        = '0001'
      alloc_status = zif_stock_allocation=>c_status_none ).
    MODIFY zstockalloc FROM @ls_existing_detail.

    TRY.
        NEW zcl_allocation_sink_sap( )->zif_allocation_sink~save(
          iv_material         = c_material
          iv_plant            = c_plant
          iv_storage_location = c_storage
          is_plan             = VALUE #(
            stock_qty       = '1'
            allocatable_qty = '1'
            unit            = 'EA'
            strategy        = zif_stock_allocation=>c_strategy_fifo ) ).
        cl_abap_unit_assert=>fail( 'Plan version overflow must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    SELECT SINGLE version_no
      FROM zstockplan
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_version_no).
    cl_abap_unit_assert=>assert_equals( act = lv_version_no exp = 2147483647 ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_detail_count).
    cl_abap_unit_assert=>assert_equals( act = lv_detail_count exp = 1 ).
  ENDMETHOD.

  METHOD rejects_invalid_plan_unchanged.
    DATA(lo_sink) = NEW zcl_allocation_sink_sap( ).
    lo_sink->zif_allocation_sink~save(
      iv_material         = c_material
      iv_plant            = c_plant
      iv_storage_location = c_storage
      is_plan             = VALUE #(
        stock_qty       = '1'
        allocatable_qty = '1'
        unit            = 'EA'
        strategy        = zif_stock_allocation=>c_strategy_fifo ) ).

    TRY.
        lo_sink->zif_allocation_sink~save(
          iv_material         = c_material
          iv_plant            = c_plant
          iv_storage_location = c_storage
          is_plan             = VALUE #(
            stock_qty       = '1'
            allocatable_qty = '1'
            unit            = 'EA'
            strategy        = 'X' ) ).
        cl_abap_unit_assert=>fail( 'Invalid plan must fail at the sink boundary' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    SELECT SINGLE version_no
      FROM zstockplan
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_version_no).
    cl_abap_unit_assert=>assert_equals( act = lv_version_no exp = 1 ).
    SELECT COUNT( * )
      FROM zstockphist
      WHERE matnr = @c_material
        AND werks = @c_plant
        AND lgort = @c_storage
      INTO @DATA(lv_history_count).
    cl_abap_unit_assert=>assert_equals( act = lv_history_count exp = 1 ).
  ENDMETHOD.
ENDCLASS.
