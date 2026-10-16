CLASS ltcl_alloc_return_margin DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_margin.
    DATA mt_lin TYPE zcl_alloc_return_margin=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_refund TYPE i
        iv_cost   TYPE i.

    METHODS impact_value   FOR TESTING.
    METHODS impact_negative FOR TESTING.
    METHODS margin_percent FOR TESTING.
    METHODS percent_guard  FOR TESTING.
    METHODS totals_net     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_margin IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_margin( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_return_margin=>ty_line.

    ls_line-refund = iv_refund.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD impact_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->impact( iv_refund = 200 iv_cost = 150 )
      exp = 50 ).
  ENDMETHOD.

  METHOD impact_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->impact( iv_refund = 100 iv_cost = 150 )
      exp = -50 ).
  ENDMETHOD.

  METHOD margin_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->margin_percent( iv_refund = 200 iv_cost = 150 )
      exp = 25 ).
  ENDMETHOD.

  METHOD percent_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->margin_percent( iv_refund = 0 iv_cost = 150 )
      exp = 0 ).
  ENDMETHOD.

  METHOD totals_net.
    add( iv_refund = 200 iv_cost = 150 ).
    add( iv_refund = 100 iv_cost = 150 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_lin ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
