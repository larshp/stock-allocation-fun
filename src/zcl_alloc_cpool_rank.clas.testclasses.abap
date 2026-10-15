CLASS ltcl_alloc_cpool_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_rank.
    DATA mt_line TYPE zcl_alloc_cpool_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_pool TYPE string
        iv_cost TYPE i.

    METHODS ranks_pools   FOR TESTING.
    METHODS picks_largest FOR TESTING.
    METHODS picks_smallest FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_rank( ).

    add( iv_pool = 'A' iv_cost = 600 ).
    add( iv_pool = 'B' iv_cost = 900 ).
    add( iv_pool = 'C' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cpool_rank=>ty_line.

    ls_line-pool = iv_pool.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_pools.
    DATA lt_ranked TYPE zcl_alloc_cpool_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-cost exp = 900 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-cost exp = 300 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_line ) exp = 900 ).
  ENDMETHOD.

  METHOD picks_smallest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->smallest( mt_line ) exp = 300 ).
  ENDMETHOD.

ENDCLASS.
