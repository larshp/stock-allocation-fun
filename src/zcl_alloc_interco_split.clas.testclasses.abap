CLASS ltcl_alloc_interco_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_interco_split.

    METHODS setup.

    METHODS splits_profit  FOR TESTING.
    METHODS seller_by_rest FOR TESTING.
    METHODS buyer_by_rest  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_interco_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_interco_split( ).
  ENDMETHOD.

  METHOD splits_profit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->split( iv_total_profit = 1000 iv_seller_percent = 60 )
      exp = 600 ).
  ENDMETHOD.

  METHOD seller_by_rest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->seller_share( iv_total_profit = 1000 iv_buyer_share = 400 )
      exp = 600 ).
  ENDMETHOD.

  METHOD buyer_by_rest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->buyer_share( iv_total_profit = 1000 iv_seller_percent = 60 )
      exp = 400 ).
  ENDMETHOD.

ENDCLASS.
