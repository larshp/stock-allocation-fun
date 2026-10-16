CLASS ltcl_alloc_writedown DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_writedown.
    DATA mt_line TYPE zcl_alloc_writedown=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material     TYPE matnr
        iv_book_value   TYPE i
        iv_market_value TYPE i.

    METHODS computes_amount FOR TESTING.
    METHODS needed_rule     FOR TESTING.
    METHODS builds_proposal FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_writedown IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_writedown( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_writedown=>ty_line.

    ls_line-material = iv_material.
    ls_line-book_value = iv_book_value.
    ls_line-market_value = iv_market_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD computes_amount.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->amount( iv_book_value = 110 iv_market_value = 100 )
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->amount( iv_book_value = 90 iv_market_value = 100 )
      exp = 0 ).
  ENDMETHOD.

  METHOD needed_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_needed( iv_book_value = 110 iv_market_value = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_needed( iv_book_value = 90 iv_market_value = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD builds_proposal.
    DATA lt_writedown TYPE zcl_alloc_writedown=>ty_writedown_tt.

    add( iv_material = 'M1' iv_book_value = 110 iv_market_value = 100 ).
    add( iv_material = 'M2' iv_book_value = 90 iv_market_value = 100 ).

    lt_writedown = mo_cut->proposal( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_writedown ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_writedown[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_writedown[ 1 ]-amount exp = 10 ).
  ENDMETHOD.

ENDCLASS.
