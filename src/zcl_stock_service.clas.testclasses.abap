CLASS lcl_stock_uom_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_conversion
      IMPORTING
        iv_base_unit        TYPE mara-meins
        iv_alternative_unit TYPE marm-meinh
        iv_numerator        TYPE marm-umrez
        iv_denominator      TYPE marm-umren.
  PRIVATE SECTION.
    DATA mv_base_unit TYPE mara-meins.
    DATA mv_alternative_unit TYPE marm-meinh.
    DATA ms_ratio TYPE zif_material_uom_repository=>ty_alt_unit_ratio.
ENDCLASS.

CLASS lcl_stock_uom_repo_double IMPLEMENTATION.
  METHOD set_conversion.
    mv_base_unit = iv_base_unit.
    mv_alternative_unit = iv_alternative_unit.
    ms_ratio-numerator = iv_numerator.
    ms_ratio-denominator = iv_denominator.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = mv_base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_alternative_unit = mv_alternative_unit.
      rs_ratio = ms_ratio.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_repository_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    METHODS set_stock
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS set_plant_stock
      IMPORTING
        iv_material TYPE mard-matnr
        iv_plant    TYPE mard-werks
        iv_quantity TYPE mard-labst.
    METHODS set_plant_location_stock
      IMPORTING
        iv_material         TYPE mard-matnr
        iv_plant            TYPE mard-werks
        iv_storage_location TYPE mard-lgort
        iv_quantity         TYPE mard-labst.
    METHODS set_location_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_location_stocks.
    METHODS set_batch_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_batch_stocks.
    METHODS set_safety_stock
      IMPORTING
        iv_quantity TYPE marc-eisbe.
    METHODS set_stock_status
      IMPORTING
        is_status TYPE zif_stock_repository=>ty_stock_status.
    METHODS set_sales_order_reservations
      IMPORTING
        it_reservations TYPE zif_stock_repository=>ty_sales_order_reservations.
    METHODS set_location_stock_status
      IMPORTING
        it_status TYPE zif_stock_repository=>ty_stock_status_locations.
    METHODS set_batch_stock_status
      IMPORTING
        it_status TYPE zif_stock_repository=>ty_batch_stock_statuses.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_plant_stock,
        material TYPE mard-matnr,
        plant    TYPE mard-werks,
        quantity TYPE mard-labst,
      END OF ty_plant_stock.
    TYPES ty_plant_stocks TYPE STANDARD TABLE OF ty_plant_stock
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_location_stock,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        quantity         TYPE mard-labst,
      END OF ty_plant_location_stock.
    TYPES ty_plant_location_stocks TYPE STANDARD TABLE OF
      ty_plant_location_stock WITH EMPTY KEY.
    DATA mv_quantity TYPE mard-labst.
    DATA mv_safety_stock TYPE marc-eisbe.
    DATA ms_stock_status TYPE zif_stock_repository=>ty_stock_status.
    DATA mt_location_stock_status TYPE zif_stock_repository=>ty_stock_status_locations.
    DATA mt_batch_stock_status TYPE zif_stock_repository=>ty_batch_stock_statuses.
    DATA mt_sales_order_reservations TYPE
      zif_stock_repository=>ty_sales_order_reservations.
    DATA mv_read_count TYPE i.
    DATA mt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA mt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA mt_plant_stock TYPE ty_plant_stocks.
    DATA mt_plant_location_stock TYPE ty_plant_location_stocks.
ENDCLASS.

CLASS lcl_stock_repository_double IMPLEMENTATION.
  METHOD set_stock.
    mv_quantity = iv_quantity.
    mt_location_stock = VALUE #(
      ( storage_location   = '0001'
        available_quantity = iv_quantity ) ).
  ENDMETHOD.

  METHOD set_plant_stock.
    DELETE mt_plant_stock WHERE material = iv_material
      AND plant = iv_plant.
    APPEND VALUE #(
      material = iv_material
      plant    = iv_plant
      quantity = iv_quantity ) TO mt_plant_stock.
    DELETE mt_plant_location_stock WHERE material = iv_material
      AND plant = iv_plant.
    APPEND VALUE #(
      material         = iv_material
      plant            = iv_plant
      storage_location = '0001'
      quantity         = iv_quantity ) TO mt_plant_location_stock.
  ENDMETHOD.

  METHOD set_plant_location_stock.
    DELETE mt_plant_location_stock WHERE material = iv_material
      AND plant = iv_plant
      AND storage_location = iv_storage_location.
    APPEND VALUE #(
      material         = iv_material
      plant            = iv_plant
      storage_location = iv_storage_location
      quantity         = iv_quantity ) TO mt_plant_location_stock.
  ENDMETHOD.

  METHOD set_location_stocks.
    mt_location_stock = it_stock.
    CLEAR mv_quantity.
    LOOP AT it_stock INTO DATA(ls_stock).
      mv_quantity = mv_quantity + ls_stock-available_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_batch_stocks.
    mt_batch_stock = it_stock.
  ENDMETHOD.

  METHOD set_safety_stock.
    mv_safety_stock = iv_quantity.
  ENDMETHOD.

  METHOD set_stock_status.
    ms_stock_status = is_status.
  ENDMETHOD.

  METHOD set_sales_order_reservations.
    mt_sales_order_reservations = it_reservations.
  ENDMETHOD.

  METHOD set_location_stock_status.
    mt_location_stock_status = it_status.
  ENDMETHOD.

  METHOD set_batch_stock_status.
    mt_batch_stock_status = it_status.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    ADD 1 TO mv_read_count.
    READ TABLE mt_plant_stock INTO DATA(ls_plant_stock)
      WITH KEY material = iv_material
               plant = iv_plant.
    IF sy-subrc = 0.
      rv_quantity = ls_plant_stock-quantity.
    ELSE.
      rv_quantity = mv_quantity.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_safety_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    ADD 1 TO mv_read_count.
    rt_reservations = mt_sales_order_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    ADD 1 TO mv_read_count.
    rs_status = ms_stock_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
    ADD 1 TO mv_read_count.
    rt_status = mt_location_stock_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    ADD 1 TO mv_read_count.
    rt_status = mt_batch_stock_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
    ADD 1 TO mv_read_count.
    LOOP AT mt_plant_location_stock INTO DATA(ls_plant_location_stock)
      WHERE material = iv_material
        AND plant = iv_plant.
      APPEND VALUE #(
        storage_location   = ls_plant_location_stock-storage_location
        available_quantity = ls_plant_location_stock-quantity ) TO rt_stock.
    ENDLOOP.
    IF rt_stock IS INITIAL.
      rt_stock = mt_location_stock.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
    ADD 1 TO mv_read_count.
    rt_stock = mt_batch_stock.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS returns_available_quantity FOR TESTING.
    METHODS returns_stock_status FOR TESTING.
    METHODS returns_stock_status_in_unit FOR TESTING.
    METHODS returns_location_stock_status FOR TESTING.
    METHODS returns_location_status_unit FOR TESTING.
    METHODS returns_batch_stock_status FOR TESTING.
    METHODS returns_batch_status_in_unit FOR TESTING.
    METHODS returns_fefo_eligible_status FOR TESTING.
    METHODS returns_fefo_status_in_unit FOR TESTING.
    METHODS rejects_invalid_fefo_status FOR TESTING.
    METHODS returns_zero_when_no_stock FOR TESTING.
    METHODS allocates_requested_quantity FOR TESTING.
    METHODS reports_partial_shortfall FOR TESTING.
    METHODS negative_stock_is_unavailable FOR TESTING.
    METHODS rejects_negative_request FOR TESTING.
    METHODS allocates_demands_in_order FOR TESTING.
    METHODS keeps_plant_stock_separate FOR TESTING.
    METHODS allocates_across_plants FOR TESTING.
    METHODS protects_cross_plant_safety FOR TESTING.
    METHODS rejects_invalid_plant_sources FOR TESTING.
    METHODS allocates_plants_in_units FOR TESTING.
    METHODS rejects_unknown_plant_uom FOR TESTING.
    METHODS allocates_plants_by_expiry FOR TESTING.
    METHODS allocates_plants_fefo_units FOR TESTING.
    METHODS rejects_invalid_plant_fefo FOR TESTING.
    METHODS rejects_unknown_plant_fefo_uom FOR TESTING.
    METHODS rejects_invalid_fefo_plant_uom FOR TESTING.
    METHODS allocates_plants_by_batch FOR TESTING.
    METHODS allocates_plants_batch_units FOR TESTING.
    METHODS protects_plant_batch_buffer FOR TESTING.
    METHODS rejects_unknown_batch_uom FOR TESTING.
    METHODS rejects_missing_plant_batch FOR TESTING.
    METHODS splits_allocations_by_location FOR TESTING.
    METHODS allocates_location_units FOR TESTING.
    METHODS allocates_only_requested_batch FOR TESTING.
    METHODS allocates_batch_units FOR TESTING.
    METHODS splits_requested_batch FOR TESTING.
    METHODS prefers_batch_location_first FOR TESTING.
    METHODS rejects_missing_batch FOR TESTING.
    METHODS allocates_by_expiry_date FOR TESTING.
    METHODS allocates_fefo_units FOR TESTING.
    METHODS filters_fefo_min_days FOR TESTING.
    METHODS rejects_negative_fefo_days FOR TESTING.
    METHODS restricts_fefo_to_location FOR TESTING.
    METHODS prefers_fefo_location_first FOR TESTING.
    METHODS protects_safety_stock_in_alloc FOR TESTING.
    METHODS protects_location_safety_stock FOR TESTING.
    METHODS protects_batch_safety_stock FOR TESTING.
    METHODS protects_fefo_safety_stock FOR TESTING.
    METHODS rejects_invalid_fefo_input FOR TESTING.
    METHODS allocates_in_alternative_unit FOR TESTING.
    METHODS allocates_demands_in_units FOR TESTING.
    METHODS rejects_unknown_alloc_unit FOR TESTING.
    METHODS rejects_unknown_bulk_unit FOR TESTING.
    METHODS rejects_unknown_batch_unit FOR TESTING.
    METHODS rejects_unknown_fefo_unit FOR TESTING.
    METHODS rejects_unknown_location_unit FOR TESTING.
    METHODS rejects_unknown_status_unit FOR TESTING.
    METHODS rejects_unknown_location_units FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_service IMPLEMENTATION.
  METHOD returns_stock_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock_status(
      is_status = VALUE #(
        unrestricted_quantity       = '8.000'
        reserved_quantity           = '2.000'
        available_unrestricted_qty  = '6.000'
        safety_stock_quantity       = '2.000'
        available_after_safety_qty  = '4.000'
        quality_inspection_quantity = '2.000'
        blocked_quantity            = '1.500' ) ).

    DATA(ls_status) = lo_cut->get_stock_status(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_status-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '2.000' )
      act = ls_status-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '2.000' )
      act = ls_status-safety_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_status-available_after_safety_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-insme( '2.000' )
      act = ls_status-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-speme( '1.500' )
      act = ls_status-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_stock_status_in_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock_status(
      is_status = VALUE #(
        unrestricted_quantity       = '24.000'
        reserved_quantity           = '6.000'
        available_unrestricted_qty  = '18.000'
        safety_stock_quantity       = '12.000'
        available_after_safety_qty  = '6.000'
        quality_inspection_quantity = '12.000'
        blocked_quantity            = '6.000' ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_status) = lo_cut->get_stock_status_in_unit(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_status-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_status-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_status-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_status-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_status-safety_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_status-available_after_safety_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_status-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_status-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_location_stock_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_location_stock_status(
      it_status = VALUE #(
        ( storage_location           = '0001'
          unrestricted_quantity      = '5.000'
          available_unrestricted_qty = '3.000'
          quality_inspection_qty     = '1.000'
          blocked_quantity           = '2.000' )
        ( storage_location           = '0002'
          unrestricted_quantity      = '4.000'
          available_unrestricted_qty = '0.000'
          quality_inspection_qty     = '0.500'
          blocked_quantity           = '0.000' ) ) ).

    DATA(lt_status) = lo_cut->get_stock_status_by_location(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_status[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_status[ 1 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-speme( '2.000' )
      act = lt_status[ 1 ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-insme( '0.500' )
      act = lt_status[ 2 ]-quality_inspection_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_status[ 2 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_location_status_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stock_status(
      it_status = VALUE #(
        ( storage_location           = '0001'
          unrestricted_quantity      = '24.000'
          available_unrestricted_qty = '18.000'
          quality_inspection_qty     = '12.000'
          blocked_quantity           = '6.000' )
        ( storage_location           = '0002'
          unrestricted_quantity      = '12.000'
          available_unrestricted_qty = '6.000'
          quality_inspection_qty     = '0.000'
          blocked_quantity           = '3.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_stock_by_location_in_unit(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_status[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_status[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_status[ 1 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 1 ]-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 1 ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 2 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_batch_stock_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location      = '0001'
          batch                 = 'B-1'
          expiration_date       = '20261231'
          unrestricted_quantity = '5.000'
          available_quantity    = '2.000' )
        ( storage_location      = '0002'
          batch                 = 'B-2'
          expiration_date       = '20270131'
          unrestricted_quantity = '3.000'
          available_quantity    = '0.000' ) ) ).

    DATA(lt_status) = lo_cut->get_stock_status_by_batch(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '5.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '2.000' )
      act = lt_status[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270131'
      act = lt_status[ 2 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( 0 )
      act = lt_status[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_batch_status_in_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location      = '0001'
          batch                 = 'B-1'
          expiration_date       = '20261231'
          unrestricted_quantity = '24.000'
          available_quantity    = '12.000' )
        ( storage_location      = '0002'
          batch                 = 'B-2'
          expiration_date       = '20270131'
          unrestricted_quantity = '6.000'
          available_quantity    = '0.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_stock_by_batch_in_unit(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_status[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261231'
      act = lt_status[ 1 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_status[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 2 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_fefo_eligible_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260922'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261005'
          available_quantity = '0.000' )
        ( storage_location   = '0003'
          batch              = 'B-UNDATED'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-MINIMUM'
          expiration_date    = '20260930'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20260929'
          available_quantity = '3.000' ) ) ).

    DATA(lt_status) = lo_cut->get_fefo_batch_status(
      iv_material   = 'MAT-1'
      iv_plant      = '1000'
      iv_as_of_date = '20260923'
      iv_min_days   = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-MINIMUM'
      act = lt_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '1.000' )
      act = lt_status[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_status[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.000' )
      act = lt_status[ 2 ]-available_quantity ).

    DATA(lt_all_shelf_life_status) = lo_cut->get_fefo_batch_status(
      iv_material   = 'MAT-1'
      iv_plant      = '1000'
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_all_shelf_life_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = lt_all_shelf_life_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-MINIMUM'
      act = lt_all_shelf_life_status[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_all_shelf_life_status[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-UNDATED'
      act = lt_all_shelf_life_status[ 4 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_fefo_status_in_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location      = '0001'
          batch                 = 'B-EXPIRED'
          expiration_date       = '20260922'
          unrestricted_quantity = '12.000'
          available_quantity    = '12.000' )
        ( storage_location      = '0002'
          batch                 = 'B-LATER'
          expiration_date       = '20261005'
          unrestricted_quantity = '24.000'
          available_quantity    = '12.000' )
        ( storage_location      = '0003'
          batch                 = 'B-SOON'
          expiration_date       = '20260929'
          unrestricted_quantity = '36.000'
          available_quantity    = '24.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_fefo_batch_status_in_unit(
      iv_material   = 'MAT-1'
      iv_plant      = '1000'
      iv_unit       = 'BOX'
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = lt_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_status[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->get_fefo_batch_status(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_available_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = lo_cut->get_unrestricted_stock(
        iv_material = 'MAT-1'
        iv_plant    = '1000' ) ).
  ENDMETHOD.

  METHOD returns_zero_when_no_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lo_cut->get_unrestricted_stock(
        iv_material = 'MAT-1'
        iv_plant    = '1000' ) ).
  ENDMETHOD.

  METHOD allocates_requested_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '10.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD reports_partial_shortfall.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '20.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.750' )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD negative_stock_is_unavailable.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '-4.000' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '5.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD rejects_negative_request.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_request(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_requested_quantity = '-1.000' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
  ENDMETHOD.

  METHOD allocates_demands_in_order.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(lt_demands) = VALUE zcl_stock_service=>ty_demands(
      ( request_id         = 'SO-1/10'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '10.000' )
      ( request_id         = 'SO-2/10'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '10.000' ) ).
    DATA(lt_allocations) = lo_cut->allocate_demands(
      it_demands = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-1/10'
      act = lt_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.250' )
      act = lt_allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.250' )
      act = lt_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.750' )
      act = lt_allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD keeps_plant_stock_separate.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(lt_demands) = VALUE zcl_stock_service=>ty_demands(
      ( request_id         = 'SO-1/10'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '10.000' )
      ( request_id         = 'SO-2/10'
        material           = 'MAT-1'
        plant              = '2000'
        requested_quantity = '10.000' ) ).
    DATA(lt_allocations) = lo_cut->allocate_demands(
      it_demands = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_across_plants.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_plant_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_quantity = '4.000' ).
    lo_repository->set_plant_stock(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_quantity = '3.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '2.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '2.000' ).

    DATA(ls_result) = lo_cut->allocate_across_plants(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '6.000' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          requested_quantity = '4.000' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-1' source_plant = '1000' )
        ( request_id = 'REQ-2' source_plant = '1000' )
        ( request_id = 'REQ-2' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-plant_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-plant_allocations[ 2 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-plant_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-2'
      act = ls_result-plant_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-plant_allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-location_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-location_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-location_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-location_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-location_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-location_allocations[ 3 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-2'
      act = ls_result-location_allocations[ 4 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_plant_sources.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_across_plants(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '2.000' ) )
          it_sources = VALUE #(
            ( request_id = 'UNKNOWN' source_plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_by_expiry.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-URGENT'
          expiration_date    = '20260925'
          available_quantity = '20.000' )
        ( storage_location   = '0002'
          batch              = 'B-ELIGIBLE'
          expiration_date    = '20260928'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-UNDATED'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20260922'
          available_quantity = '10.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_plants_by_expiry(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '4.000' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 5 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-ELIGIBLE'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '3.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '1.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_fefo_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20260928'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '15.000' )
        ( storage_location   = '0001'
          batch              = 'B-TOO-SOON'
          expiration_date    = '20260927'
          available_quantity = '100.000' )
        ( storage_location   = '0001'
          batch              = 'B-UNDATED'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '1.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-1' source_plant = '1000' )
        ( request_id = 'REQ-2' source_plant = '2000' )
        ( request_id = 'REQ-2' source_plant = '1000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 5 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_result-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-batch_allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-2'
      act = ls_result-batch_allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-batch_allocations[ 4 ]-allocation-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_plant_fefo_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_in_units(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_plant_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_in_units(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_as_of_date = '20260923'
          iv_min_days   = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_plant_fefo.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_by_expiry(
          it_demands  = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000' ) )
          it_sources  = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_by_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '100.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_plants_by_batch(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '6.000' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          batch              = 'B-1'
          requested_quantity = '5.000' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-1' source_plant = '1000' )
        ( request_id = 'REQ-2' source_plant = '2000' )
        ( request_id = 'REQ-2' source_plant = '1000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-plant_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-location_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-location_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261231'
      act = ls_result-location_allocations[ 1 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-2'
      act = ls_result-location_allocations[ 4 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_plant_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_by_batch(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_batch_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '14.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_batch_in_units(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-2' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-available_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-plant_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-location_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.167' )
      act = ls_result-location_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-location_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_batch_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_batch_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD protects_plant_batch_buffer.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '5.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).

    DATA(ls_result) = lo_cut->allocate_plants_by_batch(
      it_demands              = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '5.000' ) )
      it_sources              = VALUE #(
        ( request_id = 'REQ-1' source_plant = '1000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD protects_cross_plant_safety.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_plant_stock(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_quantity = '5.000' ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).

    DATA(ls_result) = lo_cut->allocate_across_plants(
      it_demands              = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '5.000' ) )
      it_sources              = VALUE #(
        ( request_id = 'REQ-1' source_plant = '1000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-location_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_in_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '10.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '14.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_in_units(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-2' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-plant_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-location_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.167' )
      act = ls_result-location_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_plant_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD splits_allocations_by_location.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_storage_location(
      it_demands = VALUE #(
        ( request_id         = 'SO-1/10'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' )
        ( request_id         = 'SO-2/10'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-storage_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-storage_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-2/10'
      act = ls_result-storage_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 3 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-storage_allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_location_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          available_quantity = '14.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_by_location_in_units(
      it_demands = VALUE #(
        ( request_id                  = 'BOX-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '1.000'
          requested_unit              = 'BOX' )
        ( request_id         = 'EA-2'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '12.000'
          requested_unit     = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 2 ]-allocated_source_quantity ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-storage_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.167' )
      act = ls_result-storage_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-storage_allocations[ 3 ]-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-storage_allocations[ 3 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-storage_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_only_requested_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '10.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands = VALUE #(
        ( request_id         = 'SO-1/10'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '6.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 1 ]-batch ).
  ENDMETHOD.

  METHOD allocates_batch_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '14.000' )
        ( storage_location   = '0002'
          batch              = 'B-2'
          available_quantity = '99.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_by_batch_in_units(
      it_demands = VALUE #(
        ( request_id                  = 'BOX-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          batch                       = 'B-1'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '1.000'
          requested_unit              = 'BOX' )
        ( request_id         = 'EA-2'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '12.000'
          requested_unit     = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 2 ]-allocated_source_quantity ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 2 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.167' )
      act = ls_result-batch_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-batch_allocations[ 3 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-batch_allocations[ 3 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-batch_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD splits_requested_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands = VALUE #(
        ( request_id         = 'SO-1/10'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '4.000' )
        ( request_id         = 'SO-2/10'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '3.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-2/10'
      act = ls_result-batch_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prefers_batch_location_first.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '1.500' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '2.500' )
        ( storage_location   = '0002'
          batch              = 'B-2'
          available_quantity = '9.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands = VALUE #(
        ( material                    = 'MAT-1'
          plant                       = '1000'
          batch                       = 'B-1'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '3.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '2.500' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.500' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 2 ]-batch ).
  ENDMETHOD.

  METHOD rejects_missing_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_batch(
          it_demands = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_by_expiry_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260920'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-SOON'
          expiration_date    = '20260930'
          available_quantity = '5.000' )
        ( storage_location   = '0002'
          batch              = 'B-NODATE'
          available_quantity = '2.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( request_id         = 'SO-1/10'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '6.000' )
        ( request_id         = 'SO-2/10'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '5.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260930'
      act = ls_result-batch_allocations[ 1 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-NODATE'
      act = ls_result-batch_allocations[ 4 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_fefo_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261101'
          available_quantity = '14.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_by_expiry_in_units(
      it_demands    = VALUE #(
        ( request_id         = 'BOX-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EA-2'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '12.000'
          requested_unit     = 'EA' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 2 ]-allocated_source_quantity ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-batch_allocations[ 2 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.167' )
      act = ls_result-batch_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-batch_allocations[ 3 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-batch_allocations[ 3 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-batch_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD filters_fefo_min_days.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260922'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-SAME-DAY'
          expiration_date    = '20260923'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-6-DAYS'
          expiration_date    = '20260929'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-7-DAYS'
          expiration_date    = '20260930'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-12-DAYS'
          expiration_date    = '20261005'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-NO-DATE'
          available_quantity = '1.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '10.000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-7-DAYS'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-12-DAYS'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD rejects_negative_fefo_days.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_expiry(
          it_demands  = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          iv_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD restricts_fefo_to_location.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261001'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-2'
          expiration_date    = '20260925'
          available_quantity = '5.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          storage_location   = '0001'
          requested_quantity = '3.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD prefers_fefo_location_first.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-PREF'
          expiration_date    = '20261001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-EARLIEST'
          expiration_date    = '20260925'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( material                    = 'MAT-1'
          plant                       = '1000'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '4.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-PREF'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLIEST'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD protects_safety_stock_in_alloc.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock( iv_quantity = '10.000' ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_result) = lo_cut->allocate_request(
      iv_material             = 'MAT-1'
      iv_plant                = '1000'
      iv_requested_quantity   = '10.000'
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-shortfall_quantity ).
  ENDMETHOD.

  METHOD protects_location_safety_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '5.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_result) = lo_cut->allocate_by_storage_location(
      it_demands              = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-storage_allocations[ 1 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD protects_batch_safety_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '5.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands              = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '5.000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD protects_fefo_safety_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20260930'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '5.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands              = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '10.000' ) )
      iv_as_of_date           = '20260923'
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_input.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_expiry(
          it_demands    = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '-1.000' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_in_alternative_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_repository->set_stock( iv_quantity = '10.000' ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_request_in_unit(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '1.000'
      iv_requested_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_demands_in_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '30.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_results) = lo_cut->allocate_demands_in_units(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '10.000'
          requested_unit     = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ 1 ]-source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = lt_results[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '30.000' )
      act = lt_results[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = lt_results[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 2 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_results[ 2 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_results[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_results[ 2 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_alloc_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'PAL'
      iv_numerator        = 100
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_request_in_unit(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_requested_quantity = '1.000'
          iv_requested_unit     = 'BOX' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_bulk_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_demands_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'CASE' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_fefo_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_expiry_in_units(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'CSH' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_batch_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_batch_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'CSH' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_location_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_location_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'CSH' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_status_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'PAL'
      iv_numerator        = 100
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->get_stock_status_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'BOX' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_location_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_location_exception TYPE abap_bool.
    DATA lv_batch_exception TYPE abap_bool.
    DATA lv_fefo_exception TYPE abap_bool.

    TRY.
        lo_cut->get_stock_by_location_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'CSH' ).
      CATCH zcx_invalid_stock_request.
        lv_location_exception = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_stock_by_batch_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'CSH' ).
      CATCH zcx_invalid_stock_request.
        lv_batch_exception = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_fefo_batch_status_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'CSH' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_exception = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_location_exception ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_exception ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_exception ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.
ENDCLASS.
