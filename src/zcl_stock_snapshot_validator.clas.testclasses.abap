CLASS ltcl_stock_snapshot_validator DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS accepts_consistent_snapshot FOR TESTING.
    METHODS rejects_unrequested_domain FOR TESTING.
    METHODS rejects_invalid_request_scope FOR TESTING.
    METHODS rejects_incomplete_identity FOR TESTING.
    METHODS rejects_invalid_quantity FOR TESTING.
    METHODS rejects_conflicting_units FOR TESTING.
    METHODS rejects_conflicting_safety FOR TESTING.

    METHODS requests
      RETURNING
        VALUE(rt_requests) TYPE zcl_stock_allocator=>ty_requests.
ENDCLASS.

CLASS ltcl_stock_snapshot_validator IMPLEMENTATION.
  METHOD accepts_consistent_snapshot.
    DATA(lt_stock) = VALUE zcl_stock_allocator=>ty_stock_balances(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 5
        safety_stock_qty = 2 )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        base_unit        = 'EA'
        unrestricted_qty = 7
        safety_stock_qty = 2 ) ).

    DATA(ls_result) = zcl_stock_snapshot_validator=>validate(
      it_requests       = requests( )
      it_stock_balances = lt_stock ).

    cl_abap_unit_assert=>assert_true( ls_result-is_valid ).
  ENDMETHOD.

  METHOD rejects_unrequested_domain.
    DATA(lt_stock) = VALUE zcl_stock_allocator=>ty_stock_balances(
      ( material         = 'MAT-2'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 5 ) ).

    DATA(ls_result) = zcl_stock_snapshot_validator=>validate(
      it_requests       = requests( )
      it_stock_balances = lt_stock ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock snapshot contains an unrequested domain' ).
  ENDMETHOD.

  METHOD rejects_invalid_request_scope.
    DATA(lt_requests) = requests( ).
    CLEAR lt_requests[ 1 ]-plant.

    DATA(ls_result) = zcl_stock_snapshot_validator=>validate(
      it_requests       = lt_requests
      it_stock_balances = VALUE #( ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock request scope is invalid' ).
  ENDMETHOD.

  METHOD rejects_incomplete_identity.
    DATA(lt_stock) = VALUE zcl_stock_allocator=>ty_stock_balances(
      ( material         = 'MAT-1'
        plant            = '1000'
        base_unit        = 'EA'
        unrestricted_qty = 5 ) ).

    DATA(ls_result) = zcl_stock_snapshot_validator=>validate(
      it_requests       = requests( )
      it_stock_balances = lt_stock ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock snapshot identity is incomplete' ).
  ENDMETHOD.

  METHOD rejects_invalid_quantity.
    DATA(lt_stock) = VALUE zcl_stock_allocator=>ty_stock_balances(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = '1.2345' ) ).

    DATA(ls_result) = zcl_stock_snapshot_validator=>validate(
      it_requests       = requests( )
      it_stock_balances = lt_stock ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock snapshot quantity is invalid' ).
  ENDMETHOD.

  METHOD rejects_conflicting_units.
    DATA(lt_stock) = VALUE zcl_stock_allocator=>ty_stock_balances(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 5 )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        base_unit        = 'KG'
        unrestricted_qty = 5 ) ).

    DATA(ls_result) = zcl_stock_snapshot_validator=>validate(
      it_requests       = requests( )
      it_stock_balances = lt_stock ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock snapshot base units conflict' ).
  ENDMETHOD.

  METHOD rejects_conflicting_safety.
    DATA(lt_stock) = VALUE zcl_stock_allocator=>ty_stock_balances(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 5
        safety_stock_qty = 1 )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        base_unit        = 'EA'
        unrestricted_qty = 5
        safety_stock_qty = 2 ) ).

    DATA(ls_result) = zcl_stock_snapshot_validator=>validate(
      it_requests       = requests( )
      it_stock_balances = lt_stock ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock snapshot safety stock conflicts' ).
  ENDMETHOD.

  METHOD requests.
    rt_requests = VALUE #(
      ( request_id       = 'REQUEST-1'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001' ) ).
  ENDMETHOD.
ENDCLASS.
