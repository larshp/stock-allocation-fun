CLASS ltcl_alloc_cpool_merge DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_merge.
    DATA mt_line TYPE zcl_alloc_cpool_merge=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_pool TYPE string
        iv_cost TYPE i.

    METHODS merges_pools FOR TESTING.
    METHODS counts_groups FOR TESTING.
    METHODS picks_largest FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_merge IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_merge( ).

    add( iv_pool = 'B' iv_cost = 300 ).
    add( iv_pool = 'A' iv_cost = 600 ).
    add( iv_pool = 'A' iv_cost = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cpool_merge=>ty_line.

    ls_line-pool = iv_pool.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD merges_pools.
    DATA lt_pool TYPE zcl_alloc_cpool_merge=>ty_pool_tt.

    lt_pool = mo_cut->merge( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pool ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pool[ 1 ]-pool exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_pool[ 1 ]-total exp = 700 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pool[ 2 ]-total exp = 300 ).
  ENDMETHOD.

  METHOD counts_groups.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->group_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_line ) exp = 700 ).
  ENDMETHOD.

ENDCLASS.
