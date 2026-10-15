CLASS ltcl_alloc_quota DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_quota.
    DATA mt_src TYPE zcl_alloc_quota=>ty_source_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_supplier TYPE string
        iv_quota    TYPE i.

    METHODS splits_quantity FOR TESTING.
    METHODS computes_share  FOR TESTING.
    METHODS sums_quota      FOR TESTING.
    METHODS guards_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_quota IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_quota( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_source TYPE zcl_alloc_quota=>ty_source.

    ls_source-supplier = iv_supplier.
    ls_source-quota = iv_quota.
    APPEND ls_source TO mt_src.
  ENDMETHOD.

  METHOD splits_quantity.
    DATA lt_alloc TYPE zcl_alloc_quota=>ty_alloc_tt.

    add( iv_supplier = 'S1' iv_quota = 60 ).
    add( iv_supplier = 'S2' iv_quota = 40 ).

    lt_alloc = mo_cut->split( it_sources = mt_src iv_total_quantity = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_alloc ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_alloc[ 1 ]-quantity exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = lt_alloc[ 2 ]-quantity exp = 40 ).
  ENDMETHOD.

  METHOD computes_share.
    add( iv_supplier = 'S1' iv_quota = 60 ).
    add( iv_supplier = 'S2' iv_quota = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_of( it_sources = mt_src iv_supplier = 'S1' ) exp = 60 ).
  ENDMETHOD.

  METHOD sums_quota.
    add( iv_supplier = 'S1' iv_quota = 60 ).
    add( iv_supplier = 'S2' iv_quota = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quota( mt_src ) exp = 100 ).
  ENDMETHOD.

  METHOD guards_input.
    DATA lt_alloc TYPE zcl_alloc_quota=>ty_alloc_tt.

    lt_alloc = mo_cut->split( it_sources = mt_src iv_total_quantity = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_alloc ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_of( it_sources = mt_src iv_supplier = 'S1' ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
