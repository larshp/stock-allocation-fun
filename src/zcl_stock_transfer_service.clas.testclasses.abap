CLASS lcl_transfer_uom_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
ENDCLASS.

CLASS lcl_transfer_uom_repo_double IMPLEMENTATION.
  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = 'EA'.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_alternative_unit = 'BOX'.
      rs_ratio-numerator = 12.
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
    DATA mv_read_count TYPE i.
    DATA mv_material TYPE marc-matnr.
    DATA mv_plant TYPE marc-werks.
    DATA mv_storage_location TYPE mard-lgort.
ENDCLASS.

CLASS lcl_stock_transfer_repo_double IMPLEMENTATION.
  METHOD set_balance.
    ms_balance = is_balance.
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
ENDCLASS.

CLASS ltcl_stock_transfer_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_stock_transfer_repo_double.
    DATA mo_cut TYPE REF TO zcl_stock_transfer_service.
    METHODS setup.
    METHODS returns_transfer_balances FOR TESTING.
    METHODS returns_transfer_in_unit FOR TESTING.
    METHODS aggregates_without_location FOR TESTING.
    METHODS rejects_missing_material_key FOR TESTING.
    METHODS rejects_unknown_transfer_unit FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_transfer_service IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_stock_transfer_repo_double( ).
    mo_repository->set_balance(
      is_balance = VALUE #(
        plant_transfer_quantity = '12.000'
        sloc_transfer_quantity  = '3.500' ) ).
    DATA(lo_uom_repository) = NEW lcl_transfer_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
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
ENDCLASS.
