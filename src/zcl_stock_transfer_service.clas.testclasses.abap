CLASS lcl_transfer_uom_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS get_ratio_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mv_ratio_read_count TYPE i.
ENDCLASS.

CLASS lcl_transfer_uom_repo_double IMPLEMENTATION.
  METHOD get_ratio_read_count.
    rv_count = mv_ratio_read_count.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = 'EA'.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    ADD 1 TO mv_ratio_read_count.
    IF iv_alternative_unit = 'BOX'.
      rs_ratio-numerator = 12.
      rs_ratio-denominator = 1.
    ELSEIF iv_alternative_unit = 'BIG'.
      rs_ratio-numerator = 1.
      rs_ratio-denominator = 99999.
    ELSEIF iv_alternative_unit = 'SML'.
      rs_ratio-numerator = 99999.
      rs_ratio-denominator = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_transfer_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_transfer_repository.
    METHODS set_balance
      IMPORTING
        is_balance TYPE zif_stock_transfer_repository=>ty_balance.
    METHODS set_batch_balances
      IMPORTING
        it_balances TYPE zif_stock_transfer_repository=>ty_batch_balances.
    METHODS set_bulk_results
      IMPORTING
        it_results TYPE zif_stock_transfer_repository=>ty_transfer_results.
    METHODS set_bulk_batch_results
      IMPORTING
        it_results TYPE zif_stock_transfer_repository=>ty_batch_transfer_results.
    METHODS set_location_results
      IMPORTING
        it_results TYPE zif_stock_transfer_repository=>ty_location_transfer_results.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_last_material
      RETURNING
        VALUE(rv_material) TYPE marc-matnr.
    METHODS get_last_plant
      RETURNING
        VALUE(rv_plant) TYPE marc-werks.
    METHODS get_last_storage_location
      RETURNING
        VALUE(rv_storage_location) TYPE mard-lgort.
  PRIVATE SECTION.
    DATA ms_balance TYPE zif_stock_transfer_repository=>ty_balance.
    DATA mt_batch_balances TYPE zif_stock_transfer_repository=>ty_batch_balances.
    DATA mt_bulk_results TYPE zif_stock_transfer_repository=>ty_transfer_results.
    DATA mt_bulk_batch_results TYPE zif_stock_transfer_repository=>ty_batch_transfer_results.
    DATA mt_location_results TYPE
      zif_stock_transfer_repository=>ty_location_transfer_results.
    DATA mv_read_count TYPE i.
    DATA mv_material TYPE marc-matnr.
    DATA mv_plant TYPE marc-werks.
    DATA mv_storage_location TYPE mard-lgort.
ENDCLASS.

CLASS lcl_stock_transfer_repo_double IMPLEMENTATION.
  METHOD set_balance.
    ms_balance = is_balance.
  ENDMETHOD.

  METHOD set_batch_balances.
    mt_batch_balances = it_balances.
  ENDMETHOD.

  METHOD set_bulk_results.
    mt_bulk_results = it_results.
  ENDMETHOD.

  METHOD set_bulk_batch_results.
    mt_bulk_batch_results = it_results.
  ENDMETHOD.

  METHOD set_location_results.
    mt_location_results = it_results.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD get_last_material.
    rv_material = mv_material.
  ENDMETHOD.

  METHOD get_last_plant.
    rv_plant = mv_plant.
  ENDMETHOD.

  METHOD get_last_storage_location.
    rv_storage_location = mv_storage_location.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_stock_in_transfer.
    ADD 1 TO mv_read_count.
    mv_material = iv_material.
    mv_plant = iv_plant.
    mv_storage_location = iv_storage_location.
    rs_balance = ms_balance.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_stock_in_transfer_bulk.
    ADD 1 TO mv_read_count.
    rt_results = mt_bulk_results.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_transfer_batches_bulk.
    ADD 1 TO mv_read_count.
    rt_results = mt_bulk_batch_results.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_transfer_locations_bulk.
    ADD 1 TO mv_read_count.
    rt_results = mt_location_results.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_stock_in_transfer_by_batch.
    ADD 1 TO mv_read_count.
    mv_material = iv_material.
    mv_plant = iv_plant.
    rt_balances = mt_batch_balances.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_transfer_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_stock_transfer_repo_double.
    DATA mo_uom_repository TYPE REF TO lcl_transfer_uom_repo_double.
    DATA mo_cut TYPE REF TO zcl_stock_transfer_service.
    METHODS setup.
    METHODS returns_transfer_balances FOR TESTING.
    METHODS returns_bulk_transfer_balances FOR TESTING.
    METHODS rejects_blank_bulk_key FOR TESTING.
    METHODS rejects_dup_bulk_ids FOR TESTING.
    METHODS rejects_short_bulk_response FOR TESTING.
    METHODS rejects_mismatch_bulk_row FOR TESTING.
    METHODS empty_bulk_skips_read FOR TESTING.
    METHODS converts_bulk_transfer_uom FOR TESTING.
    METHODS rejects_bad_bulk_uom FOR TESTING.
    METHODS rejects_dup_bulk_uom FOR TESTING.
    METHODS empty_bulk_uom_skips_reads FOR TESTING.
    METHODS converts_bulk_batch_uom FOR TESTING.
    METHODS rejects_bad_batch_uom FOR TESTING.
    METHODS rejects_dup_batch_uom FOR TESTING.
    METHODS empty_batch_uom_skips_reads FOR TESTING.
    METHODS returns_transfer_in_unit FOR TESTING.
    METHODS rejects_transfer_uom_limits FOR TESTING.
    METHODS returns_batch_transfer FOR TESTING.
    METHODS returns_batch_transfer_in_unit FOR TESTING.
    METHODS aggregates_without_location FOR TESTING.
    METHODS rejects_missing_material_key FOR TESTING.
    METHODS rejects_unknown_transfer_unit FOR TESTING.
    METHODS rejects_missing_batch_key FOR TESTING.
    METHODS rejects_unknown_batch_unit FOR TESTING.
    METHODS returns_batch_transfer_bulk FOR TESTING.
    METHODS rejects_batch_bulk_input FOR TESTING.
    METHODS rejects_batch_bulk_row FOR TESTING.
    METHODS empty_batch_bulk_skips_read FOR TESTING.
    METHODS returns_transfer_locations FOR TESTING.
    METHODS converts_location_bulk_uom FOR TESTING.
    METHODS converts_transfer_location_uom FOR TESTING.
    METHODS rejects_location_transfer_row FOR TESTING.
    METHODS empty_location_bulk_skips_read FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_transfer_service IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_stock_transfer_repo_double( ).
    mo_repository->set_balance(
      is_balance = VALUE #(
        plant_transfer_quantity = '12.000'
        sloc_transfer_quantity  = '3.500' ) ).
    mo_uom_repository = NEW lcl_transfer_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = mo_uom_repository ).
    mo_cut = NEW zcl_stock_transfer_service(
      io_repository    = mo_repository
      io_uom_converter = lo_converter ).
  ENDMETHOD.

  METHOD returns_transfer_balances.
    DATA(ls_result) = mo_cut->get_stock_in_transfer(
      iv_material         = 'MAT-1'
      iv_plant            = '1000'
      iv_storage_location = '0002' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = ls_result-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '12.000'
      act = ls_result-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.500'
      act = ls_result-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_repository->get_last_storage_location( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_bulk_transfer_balances.
    DATA lt_requests TYPE zif_stock_transfer_repository=>ty_transfer_requests.
    DATA ls_request TYPE zif_stock_transfer_repository=>ty_transfer_request.
    DATA lt_results TYPE zif_stock_transfer_repository=>ty_transfer_results.
    mo_repository->set_bulk_results(
      it_results = VALUE #(
        ( request_id              = 'R-1'
          material                = 'MAT-1'
          plant                   = '1000'
          storage_location        = '0002'
          plant_transfer_quantity = '12.000'
          sloc_transfer_quantity  = '3.500' )
        ( request_id              = 'R-2'
          material                = 'MAT-2'
          plant                   = '2000'
          plant_transfer_quantity = '8.000'
          sloc_transfer_quantity  = '5.000' ) ) ).

    ls_request-request_id = 'R-2'.
    ls_request-material = 'MAT-2'.
    ls_request-plant = '2000'.
    APPEND ls_request TO lt_requests.
    CLEAR ls_request.
    ls_request-request_id = 'R-1'.
    ls_request-material = 'MAT-1'.
    ls_request-plant = '1000'.
    ls_request-storage_location = '0002'.
    APPEND ls_request TO lt_requests.
    lt_results = mo_cut->get_stock_in_transfer_bulk(
      it_requests = lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R-2'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '8.000'
      act = lt_results[ 1 ]-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = lt_results[ 1 ]-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R-1'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_results[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.500'
      act = lt_results[ 2 ]-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_dup_bulk_ids.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_stock_in_transfer_bulk(
          it_requests = VALUE #(
            ( request_id = 'DUP'
              material   = 'MAT-1'
              plant      = '1000' )
            ( request_id = 'DUP'
              material   = 'MAT-2'
              plant      = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_blank_bulk_key.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_stock_in_transfer_bulk(
          it_requests = VALUE #(
            ( request_id = 'R-1'
              material   = space
              plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_bulk_response.
    DATA lv_exception_raised TYPE abap_bool.
    mo_repository->set_bulk_results(
      it_results = VALUE #(
        ( request_id = 'R-1'
          material   = 'MAT-1'
          plant      = '1000' ) ) ).

    TRY.
        mo_cut->get_stock_in_transfer_bulk(
          it_requests = VALUE #(
            ( request_id = 'R-1'
              material   = 'MAT-1'
              plant      = '1000' )
            ( request_id = 'R-2'
              material   = 'MAT-2'
              plant      = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_mismatch_bulk_row.
    DATA lv_exception_raised TYPE abap_bool.
    mo_repository->set_bulk_results(
      it_results = VALUE #(
        ( request_id = 'R-1'
          material   = 'MAT-2'
          plant      = '1000' ) ) ).

    TRY.
        mo_cut->get_stock_in_transfer_bulk(
          it_requests = VALUE #(
            ( request_id = 'R-1'
              material   = 'MAT-1'
              plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_bulk_skips_read.
    DATA(lt_results) = mo_cut->get_stock_in_transfer_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD converts_bulk_transfer_uom.
    mo_repository->set_bulk_results(
      it_results = VALUE #(
        ( request_id              = 'R-1'
          material                = 'MAT-1'
          plant                   = '1000'
          storage_location        = '0002'
          plant_transfer_quantity = '24.000'
          sloc_transfer_quantity  = '6.000' )
        ( request_id              = 'R-2'
          material                = 'MAT-1'
          plant                   = '2000'
          plant_transfer_quantity = '12.000'
          sloc_transfer_quantity  = '9.000' ) ) ).

    DATA(lt_results) = mo_cut->get_stock_in_transfer_bulk_uom(
      it_requests = VALUE #(
        ( request_id       = 'R-1'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0002'
          unit             = 'BOX' )
        ( request_id       = 'R-2'
          material         = 'MAT-1'
          plant            = '2000'
          storage_location = space
          unit             = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-umlmc( '24.000' )
      act = lt_results[ 1 ]-base_plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ 1 ]-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '6.000' )
      act = lt_results[ 1 ]-base_sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_results[ 1 ]-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_results[ 2 ]-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.750' )
      act = lt_results[ 2 ]-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_bulk_uom.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_stock_in_transfer_bulk_uom(
          it_requests = VALUE #(
            ( request_id       = 'R-1'
              material         = 'MAT-1'
              plant            = '1000'
              storage_location = space
              unit             = 'CSH' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_dup_bulk_uom.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_stock_in_transfer_bulk_uom(
          it_requests = VALUE #(
            ( request_id       = 'DUP'
              material         = 'MAT-1'
              plant            = '1000'
              storage_location = space
              unit             = 'BOX' )
            ( request_id       = 'DUP'
              material         = 'MAT-1'
              plant            = '2000'
              storage_location = space
              unit             = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_bulk_uom_skips_reads.
    DATA(lt_results) = mo_cut->get_stock_in_transfer_bulk_uom(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD converts_bulk_batch_uom.
    DATA lt_requests TYPE zcl_stock_transfer_service=>ty_bulk_batch_unit_requests.
    DATA ls_request TYPE zcl_stock_transfer_service=>ty_bulk_batch_unit_request.
    DATA lt_results TYPE zcl_stock_transfer_service=>ty_bulk_batch_unit_results.
    mo_repository->set_bulk_batch_results(
      it_results = VALUE #(
        ( request_id        = 'R-1'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0002'
          batch             = 'B-2'
          transfer_quantity = '6.000' )
        ( request_id        = 'R-1'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0001'
          batch             = 'B-1'
          transfer_quantity = '12.000' )
        ( request_id        = 'R-2'
          material          = 'MAT-1'
          plant             = '2000'
          storage_location  = '0001'
          batch             = 'B-3'
          transfer_quantity = '24.000' ) ) ).

    ls_request-request_id = 'R-2'.
    ls_request-material = 'MAT-1'.
    ls_request-plant = '2000'.
    ls_request-unit = 'BOX'.
    APPEND ls_request TO lt_requests.
    CLEAR ls_request.
    ls_request-request_id = 'R-1'.
    ls_request-material = 'MAT-1'.
    ls_request-plant = '1000'.
    ls_request-unit = 'BOX'.
    APPEND ls_request TO lt_requests.

    lt_results = mo_cut->get_transfer_batches_bulk_uom(
      it_requests = lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R-2'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ 1 ]-transfers[ 1 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_results[ 2 ]-transfers[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cumlm( '12.000' )
      act = lt_results[ 2 ]-transfers[ 1 ]-base_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_results[ 2 ]-transfers[ 1 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_results[ 2 ]-transfers[ 2 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_batch_uom.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_transfer_batches_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'R-1'
              material   = 'MAT-1'
              plant      = '1000'
              unit       = 'CSH' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_dup_batch_uom.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_transfer_batches_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'DUP'
              material   = 'MAT-1'
              plant      = '1000'
              unit       = 'BOX' )
            ( request_id = 'DUP'
              material   = 'MAT-1'
              plant      = '2000'
              unit       = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_batch_uom_skips_reads.
    DATA(lt_results) = mo_cut->get_transfer_batches_bulk_uom(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_transfer_in_unit.
    mo_repository->set_balance(
      is_balance = VALUE #(
        plant_transfer_quantity = '24.000'
        sloc_transfer_quantity  = '6.000' ) ).

    DATA(ls_result) = mo_cut->get_stock_in_transfer_in_unit(
      iv_material         = 'MAT-1'
      iv_plant            = '1000'
      iv_storage_location = '0002'
      iv_unit             = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_result-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_transfer_uom_limits.
    DATA lv_exception_raised TYPE abap_bool.
    mo_repository->set_balance(
      is_balance = VALUE #(
        plant_transfer_quantity = '9999999.999' ) ).
    TRY.
        mo_cut->get_stock_in_transfer_in_unit(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = space
          iv_unit             = 'BIG' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    mo_repository->set_balance(
      is_balance = VALUE #(
        plant_transfer_quantity = '1.000' ) ).
    TRY.
        mo_cut->get_stock_in_transfer_in_unit(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = space
          iv_unit             = 'SML' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
  ENDMETHOD.

  METHOD returns_batch_transfer.
    mo_repository->set_batch_balances(
      it_balances = VALUE #(
        ( storage_location  = '0001'
          batch             = 'B-1'
          transfer_quantity = '12.000' )
        ( storage_location  = '0002'
          batch             = 'B-2'
          transfer_quantity = '3.500' ) ) ).

    DATA(lt_results) = mo_cut->get_stock_in_transfer_by_batch(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = lt_results[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_results[ 1 ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_results[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_results[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cumlm( '12.000' )
      act = lt_results[ 1 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = lt_results[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cumlm( '3.500' )
      act = lt_results[ 2 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = mo_repository->get_last_material( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = mo_repository->get_last_plant( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_batch_transfer_in_unit.
    mo_repository->set_batch_balances(
      it_balances = VALUE #(
        ( storage_location  = '0001'
          batch             = 'B-1'
          transfer_quantity = '12.000' )
        ( storage_location  = '0002'
          batch             = 'B-2'
          transfer_quantity = '6.000' ) ) ).

    DATA(lt_results) = mo_cut->get_batch_transfer_in_unit(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_results[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_results[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cumlm( '12.000' )
      act = lt_results[ 1 ]-base_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_results[ 1 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cumlm( '6.000' )
      act = lt_results[ 2 ]-base_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_results[ 2 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD aggregates_without_location.
    DATA(ls_result) = mo_cut->get_stock_in_transfer(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = space
      act = ls_result-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = space
      act = mo_repository->get_last_storage_location( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.500'
      act = ls_result-sloc_transfer_quantity ).
  ENDMETHOD.

  METHOD rejects_missing_material_key.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_stock_in_transfer(
          iv_material = space
          iv_plant    = '1000' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_transfer_unit.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_stock_in_transfer_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'CSH' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_batch_key.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_stock_in_transfer_by_batch(
          iv_material = 'MAT-1'
          iv_plant    = space ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_batch_unit.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_batch_transfer_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'CSH' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_batch_transfer_bulk.
    DATA lt_requests TYPE zif_stock_transfer_repository=>ty_batch_transfer_requests.
    DATA ls_request TYPE zif_stock_transfer_repository=>ty_batch_transfer_request.
    DATA lt_results TYPE zcl_stock_transfer_service=>ty_bulk_batch_transfer_results.

    mo_repository->set_bulk_batch_results(
      it_results = VALUE #(
        ( request_id        = 'R-1'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0002'
          batch             = 'B-2'
          transfer_quantity = '2.000' )
        ( request_id        = 'R-2'
          material          = 'MAT-2'
          plant             = '2000'
          storage_location  = '0001'
          batch             = 'B-1'
          transfer_quantity = '5.000' )
        ( request_id        = 'R-1'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0001'
          batch             = 'B-1'
          transfer_quantity = '3.000' ) ) ).

    ls_request-request_id = 'R-2'.
    ls_request-material = 'MAT-2'.
    ls_request-plant = '2000'.
    APPEND ls_request TO lt_requests.
    CLEAR ls_request.
    ls_request-request_id = 'R-1'.
    ls_request-material = 'MAT-1'.
    ls_request-plant = '1000'.
    APPEND ls_request TO lt_requests.

    lt_results = mo_cut->get_transfer_batches_bulk(
      it_requests = lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R-2'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-transfers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R-1'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ 2 ]-transfers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_results[ 2 ]-transfers[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_results[ 2 ]-transfers[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = lt_results[ 2 ]-transfers[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_batch_bulk_input.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->get_transfer_batches_bulk(
          it_requests = VALUE #(
            ( request_id = 'DUP'
              material   = 'MAT-1'
              plant      = '1000' )
            ( request_id = 'DUP'
              material   = 'MAT-2'
              plant      = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_batch_bulk_row.
    DATA lv_exception_raised TYPE abap_bool.
    mo_repository->set_bulk_batch_results(
      it_results = VALUE #(
        ( request_id        = 'R-1'
          material          = 'MAT-2'
          plant             = '1000'
          storage_location  = '0001'
          batch             = 'B-1'
          transfer_quantity = '2.000' ) ) ).

    TRY.
        mo_cut->get_transfer_batches_bulk(
          it_requests = VALUE #(
            ( request_id = 'R-1'
              material   = 'MAT-1'
              plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_batch_bulk_skips_read.
    DATA(lt_results) = mo_cut->get_transfer_batches_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_transfer_locations.
    mo_repository->set_location_results(
      it_results = VALUE #(
        ( request_id        = 'SINGLE'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0002'
          transfer_quantity = '3.500' )
        ( request_id        = 'SINGLE'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0001'
          transfer_quantity = '12.000' ) ) ).

    DATA(lt_results) = mo_cut->get_transfer_locations(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_results[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '12.000' )
      act = lt_results[ 1 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_results[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD converts_location_bulk_uom.
    mo_repository->set_location_results(
      it_results = VALUE #(
        ( request_id        = 'R-1'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0002'
          transfer_quantity = '12.000' )
        ( request_id        = 'R-2'
          material          = 'MAT-1'
          plant             = '2000'
          storage_location  = '0001'
          transfer_quantity = '6.000' )
        ( request_id        = 'R-1'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0001'
          transfer_quantity = '24.000' ) ) ).

    DATA(lt_results) = mo_cut->get_transfer_location_bulk_uom(
      it_requests = VALUE #(
        ( request_id = 'R-2'
          material   = 'MAT-1'
          plant      = '2000'
          unit       = 'BOX' )
        ( request_id = 'R-1'
          material   = 'MAT-1'
          plant      = '1000'
          unit       = 'BOX' )
        ( request_id = 'R-3'
          material   = 'MAT-1'
          plant      = '3000'
          unit       = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R-2'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '6.000' )
      act = lt_results[ 1 ]-transfers[ 1 ]-base_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_results[ 1 ]-transfers[ 1 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_results[ 2 ]-transfers[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ 2 ]-transfers[ 1 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R-3'
      act = lt_results[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results[ 3 ]-transfers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD converts_transfer_location_uom.
    mo_repository->set_location_results(
      it_results = VALUE #(
        ( request_id        = 'SINGLE'
          material          = 'MAT-1'
          plant             = '1000'
          storage_location  = '0001'
          transfer_quantity = '12.000' ) ) ).

    DATA(lt_results) = mo_cut->get_transfer_locations_in_unit(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '12.000' )
      act = lt_results[ 1 ]-base_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_results[ 1 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_location_transfer_row.
    DATA lv_exception_raised TYPE abap_bool.
    mo_repository->set_location_results(
      it_results = VALUE #(
        ( request_id        = 'R-1'
          material          = 'MAT-2'
          plant             = '1000'
          storage_location  = '0001'
          transfer_quantity = '2.000' ) ) ).

    TRY.
        mo_cut->get_transfer_locations_bulk(
          it_requests = VALUE #(
            ( request_id = 'R-1'
              material   = 'MAT-1'
              plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_location_bulk_skips_read.
    DATA(lt_results) = mo_cut->get_transfer_location_bulk_uom(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_uom_repository->get_ratio_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_read_count( ) ).
  ENDMETHOD.
ENDCLASS.
