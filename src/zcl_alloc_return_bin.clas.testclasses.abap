CLASS ltcl_alloc_return_bin DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_bin.
    DATA mt_bin TYPE zcl_alloc_return_bin=>ty_bin_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_bin      TYPE string
        iv_capacity TYPE i
        iv_used     TYPE i.

    METHODS selects_first  FOR TESTING.
    METHODS no_fit         FOR TESTING.
    METHODS tightest_fit   FOR TESTING.
    METHODS fit_rule       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_bin IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_bin( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_bin TYPE zcl_alloc_return_bin=>ty_bin.

    ls_bin-bin = iv_bin.
    ls_bin-capacity = iv_capacity.
    ls_bin-used = iv_used.
    APPEND ls_bin TO mt_bin.
  ENDMETHOD.

  METHOD selects_first.
    DATA ls_bin TYPE zcl_alloc_return_bin=>ty_bin.

    add( iv_bin = 'A' iv_capacity = 10 iv_used = 2 ).
    add( iv_bin = 'B' iv_capacity = 5 iv_used = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_bins = mt_bin iv_quantity = 3 )
      exp = 'A' ).
  ENDMETHOD.

  METHOD no_fit.
    add( iv_bin = 'A' iv_capacity = 10 iv_used = 2 ).
    add( iv_bin = 'B' iv_capacity = 5 iv_used = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_bins = mt_bin iv_quantity = 9 )
      exp = '' ).
  ENDMETHOD.

  METHOD tightest_fit.
    add( iv_bin = 'A' iv_capacity = 10 iv_used = 2 ).
    add( iv_bin = 'B' iv_capacity = 5 iv_used = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best_bin( it_bins = mt_bin iv_quantity = 3 )
      exp = 'B' ).
  ENDMETHOD.

  METHOD fit_rule.
    DATA ls_bin TYPE zcl_alloc_return_bin=>ty_bin.

    ls_bin-bin = 'A'.
    ls_bin-capacity = 10.
    ls_bin-used = 2.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( is_bin = ls_bin iv_quantity = 8 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( is_bin = ls_bin iv_quantity = 9 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( is_bin = ls_bin iv_quantity = 0 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
