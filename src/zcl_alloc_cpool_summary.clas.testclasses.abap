CLASS ltcl_alloc_cpool_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_summary.
    DATA mt_line TYPE zcl_alloc_cpool_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_pool TYPE string
        iv_cost TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_pools   FOR TESTING.
    METHODS sums_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_summary( ).

    add( iv_pool = 'A' iv_cost = 600 ).
    add( iv_pool = 'B' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cpool_summary=>ty_line.

    ls_line-pool = iv_pool.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_cpool_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-pool_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 900 ).
  ENDMETHOD.

  METHOD counts_pools.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pool_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 900 ).
  ENDMETHOD.

ENDCLASS.
