CLASS ltcl_alloc_absorb_pool DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_absorb_pool.
    DATA mt_line TYPE zcl_alloc_absorb_pool=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name TYPE string
        iv_cost TYPE i.

    METHODS totals_pool  FOR TESTING.
    METHODS absorbs_part FOR TESTING.
    METHODS reads_unabsorbed FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_absorb_pool IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_absorb_pool( ).

    add( iv_name = 'A' iv_cost = 600 ).
    add( iv_name = 'B' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_absorb_pool=>ty_line.

    ls_line-name = iv_name.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD totals_pool.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pool_total( mt_line ) exp = 900 ).
  ENDMETHOD.

  METHOD absorbs_part.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->absorbed( iv_pool = 900 iv_percent = 80 )
      exp = 720 ).
  ENDMETHOD.

  METHOD reads_unabsorbed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->unabsorbed( iv_pool = 900 iv_percent = 80 )
      exp = 180 ).
  ENDMETHOD.

ENDCLASS.
