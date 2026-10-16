CLASS ltcl_alloc_prep_except DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_except.
    DATA mt_line TYPE zcl_alloc_prep_except=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order TYPE string
        iv_cost  TYPE i
        iv_limit TYPE i.

    METHODS exception_rule FOR TESTING.
    METHODS reads_reason   FOR TESTING.
    METHODS counts_except  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_except IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_except( ).

    add( iv_order = 'O1' iv_cost = 150 iv_limit = 100 ).
    add( iv_order = 'O2' iv_cost = 80 iv_limit = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prep_except=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-cost = iv_cost.
    ls_line-limit = iv_limit.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD exception_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exception( iv_cost = 150 iv_limit = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exception( iv_cost = 80 iv_limit = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_cost = 150 iv_limit = 100 )
      exp = 'cost over limit' ).
  ENDMETHOD.

  METHOD counts_except.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
