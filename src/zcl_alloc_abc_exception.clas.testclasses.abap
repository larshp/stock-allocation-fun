CLASS ltcl_alloc_abc_exception DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_exception.
    DATA mt_value TYPE zcl_alloc_abc_exception=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS exception_rule FOR TESTING.
    METHODS reads_reason   FOR TESTING.
    METHODS counts_of      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_exception IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_exception( ).

    add( iv_value = 600 ).
    add( iv_value = 300 ).
    add( iv_value = 900 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD exception_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exception( iv_cost = 600 iv_limit = 500 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exception( iv_cost = 300 iv_limit = 500 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_cost = 600 iv_limit = 500 )
      exp = 'over limit' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_cost = 300 iv_limit = 500 )
      exp = 'none' ).
  ENDMETHOD.

  METHOD counts_of.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( it_values = mt_value iv_limit = 500 )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
