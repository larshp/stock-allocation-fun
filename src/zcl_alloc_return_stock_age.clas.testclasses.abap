CLASS ltcl_alloc_return_stock_age DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_stock_age.
    DATA mt_age TYPE zcl_alloc_return_stock_age=>ty_ages_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_age TYPE i.

    METHODS computes_age   FOR TESTING.
    METHODS age_guards     FOR TESTING.
    METHODS buckets_days   FOR TESTING.
    METHODS finds_oldest   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_stock_age IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_stock_age( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_age TO mt_age.
  ENDMETHOD.

  METHOD computes_age.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->age_days( iv_received = '20260101'
                              iv_check    = '20260104' )
      exp = 3 ).
  ENDMETHOD.

  METHOD age_guards.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->age_days( iv_received = '00000000'
                              iv_check    = '20260104' )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->age_days( iv_received = '20260104'
                              iv_check    = '20260101' )
      exp = 0 ).
  ENDMETHOD.

  METHOD buckets_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 10 ) exp = '0-30' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 45 ) exp = '31-60' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 100 ) exp = '90+' ).
  ENDMETHOD.

  METHOD finds_oldest.
    add( 10 ).
    add( 45 ).
    add( 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->oldest( mt_age ) exp = 100 ).
  ENDMETHOD.

ENDCLASS.
