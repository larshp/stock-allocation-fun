CLASS ltcl_alloc_cpool_build DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_build.
    DATA mt_line TYPE zcl_alloc_cpool_build=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_pool TYPE string
        iv_cost TYPE i.

    METHODS builds_pools FOR TESTING.
    METHODS counts_pools FOR TESTING.
    METHODS sums_total   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_build IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_build( ).

    add( iv_pool = 'A' iv_cost = 600 ).
    add( iv_pool = 'B' iv_cost = 300 ).
    add( iv_pool = 'A' iv_cost = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cpool_build=>ty_line.

    ls_line-pool = iv_pool.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_pools.
    DATA lt_pool TYPE zcl_alloc_cpool_build=>ty_pool_tt.

    lt_pool = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pool ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pool[ 1 ]-pool exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_pool[ 1 ]-total exp = 700 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pool[ 2 ]-total exp = 300 ).
  ENDMETHOD.

  METHOD counts_pools.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pool_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 1000 ).
  ENDMETHOD.

ENDCLASS.
