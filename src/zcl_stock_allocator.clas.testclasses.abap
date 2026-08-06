CLASS ltcl_stock_allocator DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS allocate_full FOR TESTING.
    METHODS allocate_partial FOR TESTING.
    METHODS allocate_none FOR TESTING.

ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.

  METHOD allocate_full.
    DATA lo_alloc TYPE REF TO zcl_stock_allocator.
    DATA lt_demand TYPE zif_stock_allocation=>ty_demand_tab.
    DATA lt_alloc  TYPE zif_stock_allocation=>ty_allocation_tab.
    DATA ls_demand LIKE LINE OF lt_demand.

    CREATE OBJECT lo_alloc.

    ls_demand-material = 'MAT1'.
    ls_demand-plant    = '1000'.
    ls_demand-quantity = 10.
    APPEND ls_demand TO lt_demand.

    ls_demand-material = 'MAT2'.
    ls_demand-plant    = '1000'.
    ls_demand-quantity = 5.
    APPEND ls_demand TO lt_demand.

    lt_alloc = lo_alloc->zif_stock_allocation~allocate(
      it_demand    = lt_demand
      iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_alloc ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_alloc[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lt_alloc[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD allocate_partial.
    DATA lo_alloc TYPE REF TO zcl_stock_allocator.
    DATA lt_demand TYPE zif_stock_allocation=>ty_demand_tab.
    DATA lt_alloc  TYPE zif_stock_allocation=>ty_allocation_tab.
    DATA ls_demand LIKE LINE OF lt_demand.

    CREATE OBJECT lo_alloc.

    ls_demand-material = 'MAT1'.
    ls_demand-plant    = '1000'.
    ls_demand-quantity = 10.
    APPEND ls_demand TO lt_demand.

    ls_demand-material = 'MAT2'.
    ls_demand-plant    = '1000'.
    ls_demand-quantity = 5.
    APPEND ls_demand TO lt_demand.

    lt_alloc = lo_alloc->zif_stock_allocation~allocate(
      it_demand    = lt_demand
      iv_available = 12 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_alloc ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_alloc[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_alloc[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD allocate_none.
    DATA lo_alloc TYPE REF TO zcl_stock_allocator.
    DATA lt_demand TYPE zif_stock_allocation=>ty_demand_tab.
    DATA lt_alloc  TYPE zif_stock_allocation=>ty_allocation_tab.
    DATA ls_demand LIKE LINE OF lt_demand.

    CREATE OBJECT lo_alloc.

    ls_demand-material = 'MAT1'.
    ls_demand-plant    = '1000'.
    ls_demand-quantity = 10.
    APPEND ls_demand TO lt_demand.

    lt_alloc = lo_alloc->zif_stock_allocation~allocate(
      it_demand    = lt_demand
      iv_available = 0 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_alloc ) ).
  ENDMETHOD.

ENDCLASS.