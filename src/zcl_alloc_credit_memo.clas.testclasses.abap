CLASS ltcl_alloc_credit_memo DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_credit_memo.
    DATA mt_itm TYPE zcl_alloc_credit_memo=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_net      TYPE i.

    METHODS adds_tax        FOR TESTING.
    METHODS skips_empty     FOR TESTING.
    METHODS totals_gross    FOR TESTING.
    METHODS totals_tax      FOR TESTING.
    METHODS no_tax          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_credit_memo IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_credit_memo( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_credit_memo=>ty_item.

    ls_item-material = iv_material.
    ls_item-net = iv_net.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD adds_tax.
    DATA lt_lines TYPE zcl_alloc_credit_memo=>ty_line_tt.

    add( iv_material = 'M1' iv_net = 200 ).
    add( iv_material = 'M2' iv_net = 50 ).

    lt_lines = mo_cut->build( it_items = mt_itm iv_tax_percent = 19 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-tax exp = 38 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-gross exp = 238 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-tax exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-gross exp = 59 ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_lines TYPE zcl_alloc_credit_memo=>ty_line_tt.

    add( iv_material = 'M1' iv_net = 0 ).
    add( iv_material = 'M2' iv_net = 50 ).

    lt_lines = mo_cut->build( it_items = mt_itm iv_tax_percent = 19 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
  ENDMETHOD.

  METHOD totals_gross.
    DATA lt_lines TYPE zcl_alloc_credit_memo=>ty_line_tt.

    add( iv_material = 'M1' iv_net = 200 ).
    add( iv_material = 'M2' iv_net = 50 ).

    lt_lines = mo_cut->build( it_items = mt_itm iv_tax_percent = 19 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 297 ).
  ENDMETHOD.

  METHOD totals_tax.
    DATA lt_lines TYPE zcl_alloc_credit_memo=>ty_line_tt.

    add( iv_material = 'M1' iv_net = 200 ).
    add( iv_material = 'M2' iv_net = 50 ).

    lt_lines = mo_cut->build( it_items = mt_itm iv_tax_percent = 19 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->tax( lt_lines ) exp = 47 ).
  ENDMETHOD.

  METHOD no_tax.
    DATA lt_lines TYPE zcl_alloc_credit_memo=>ty_line_tt.

    add( iv_material = 'M1' iv_net = 200 ).

    lt_lines = mo_cut->build( it_items = mt_itm iv_tax_percent = -5 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-tax exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-gross exp = 200 ).
  ENDMETHOD.

ENDCLASS.
