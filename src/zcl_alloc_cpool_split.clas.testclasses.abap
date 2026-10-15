CLASS ltcl_alloc_cpool_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_split.

    METHODS setup.

    METHODS splits_pool    FOR TESTING.
    METHODS computes_share FOR TESTING.
    METHODS unit_rate      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_split( ).
  ENDMETHOD.

  METHOD splits_pool.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->split( iv_total = 900 iv_parts = 3 )
      exp = 300 ).
  ENDMETHOD.

  METHOD computes_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_of( iv_part = 300 iv_total = 900 )
      exp = 33 ).
  ENDMETHOD.

  METHOD unit_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total = 900 iv_units = 300 )
      exp = 3 ).
  ENDMETHOD.

ENDCLASS.
