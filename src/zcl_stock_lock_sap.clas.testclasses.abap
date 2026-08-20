CLASS lcl_stock_lock_gateway DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_lock_gateway.
    TYPES:
      BEGIN OF ty_call,
        material      TYPE zcl_stock_allocator=>ty_material,
        plant         TYPE zcl_stock_allocator=>ty_plant,
        wait_for_lock TYPE abap_bool,
      END OF ty_call.
    TYPES ty_calls TYPE STANDARD TABLE OF ty_call WITH EMPTY KEY.
    DATA mt_acquired TYPE ty_calls.
    DATA mt_released TYPE ty_calls.
    DATA mv_fail_at TYPE i.
    DATA mv_invalid_at TYPE i.
ENDCLASS.

CLASS lcl_stock_lock_gateway IMPLEMENTATION.
  METHOD zif_stock_lock_gateway~acquire.
    APPEND VALUE #(
      material      = iv_material
      plant         = iv_plant
      wait_for_lock = iv_wait_for_lock ) TO mt_acquired.
    IF lines( mt_acquired ) = mv_fail_at.
      rs_result-acquired = abap_false.
      rs_result-message = 'Test lock collision'.
      RETURN.
    ENDIF.
    IF lines( mt_acquired ) = mv_invalid_at.
      rs_result-acquired = 'Y'.
      rs_result-message = 'Malformed test gateway state'.
      RETURN.
    ENDIF.
    rs_result-acquired = abap_true.
  ENDMETHOD.

  METHOD zif_stock_lock_gateway~release.
    APPEND VALUE #(
      material = iv_material
      plant    = iv_plant ) TO mt_released.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_lock_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_gateway TYPE REF TO lcl_stock_lock_gateway.
    DATA mo_cut TYPE REF TO zcl_stock_lock_sap.

    METHODS setup.
    METHODS locks_material_plants FOR TESTING.
    METHODS releases_after_failure FOR TESTING.
    METHODS releases_all_plants FOR TESTING.
    METHODS rejects_invalid_wait_flag FOR TESTING.
    METHODS rejects_invalid_gateway_result FOR TESTING.
    METHODS rejects_direct_gateway_wait FOR TESTING.
    METHODS allocations
      RETURNING
        VALUE(rt_allocations) TYPE zcl_stock_allocator=>ty_allocations.
ENDCLASS.

CLASS ltcl_stock_lock_sap IMPLEMENTATION.
  METHOD setup.
    mo_gateway = NEW #( ).
    mo_cut = NEW #(
      io_gateway       = mo_gateway
      iv_wait_for_lock = abap_true ).
  ENDMETHOD.

  METHOD locks_material_plants.
    DATA(ls_result) = mo_cut->zif_stock_lock~acquire( allocations( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-acquired ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_gateway->mt_acquired )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_acquired[ 1 ]-material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_acquired[ 1 ]-plant
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_acquired[ 2 ]-plant
      exp = '2000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_acquired[ 3 ]-material
      exp = 'MAT-2' ).
    cl_abap_unit_assert=>assert_true(
      mo_gateway->mt_acquired[ 1 ]-wait_for_lock ).
  ENDMETHOD.

  METHOD releases_after_failure.
    mo_gateway->mv_fail_at = 2.

    DATA(ls_result) = mo_cut->zif_stock_lock~acquire( allocations( ) ).

    cl_abap_unit_assert=>assert_false( ls_result-acquired ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Test lock collision' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_gateway->mt_released )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_released[ 1 ]-material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_released[ 1 ]-plant
      exp = '1000' ).
  ENDMETHOD.

  METHOD releases_all_plants.
    mo_cut->zif_stock_lock~acquire( allocations( ) ).
    mo_cut->zif_stock_lock~release( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_gateway->mt_released )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_released[ 3 ]-material
      exp = 'MAT-2' ).
  ENDMETHOD.

  METHOD rejects_invalid_wait_flag.
    mo_cut = NEW #(
      io_gateway       = mo_gateway
      iv_wait_for_lock = 'Y' ).

    DATA(ls_result) = mo_cut->zif_stock_lock~acquire( allocations( ) ).

    cl_abap_unit_assert=>assert_false( ls_result-acquired ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock lock wait flag must be X or blank' ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_acquired ).
  ENDMETHOD.

  METHOD rejects_invalid_gateway_result.
    mo_gateway->mv_invalid_at = 2.

    DATA(ls_result) = mo_cut->zif_stock_lock~acquire( allocations( ) ).

    cl_abap_unit_assert=>assert_false( ls_result-acquired ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock lock gateway returned invalid state' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_gateway->mt_released )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_released[ 1 ]-material
      exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD rejects_direct_gateway_wait.
    DATA(lo_gateway) = NEW zcl_stock_lock_gateway_sap( ).

    DATA(ls_result) = lo_gateway->zif_stock_lock_gateway~acquire(
      iv_material      = 'MAT-1'
      iv_plant         = '1000'
      iv_wait_for_lock = 'Y' ).

    cl_abap_unit_assert=>assert_false( ls_result-acquired ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock lock wait flag must be X or blank' ).
  ENDMETHOD.

  METHOD allocations.
    rt_allocations = VALUE #(
      ( request_id       = 'REQUEST-1'
        material         = 'MAT-2'
        plant            = '1000'
        storage_location = '0001'
        allocated_qty    = 1 )
      ( request_id       = 'REQUEST-2'
        material         = 'MAT-1'
        plant            = '2000'
        storage_location = '0001'
        allocated_qty    = 1 )
      ( request_id       = 'REQUEST-3'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        allocated_qty    = 1 )
      ( request_id       = 'REQUEST-4'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        allocated_qty    = 1 ) ).
  ENDMETHOD.
ENDCLASS.
