CLASS ltcl_alloc_interco_price DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_interco_price.
    DATA mt_component TYPE zcl_alloc_interco_price=>ty_component_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_amount TYPE i.

    METHODS builds_price FOR TESTING.
    METHODS sums_total   FOR TESTING.
    METHODS positive_rule FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_interco_price IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_interco_price( ).

    add( iv_name = 'COST' iv_amount = 1000 ).
    add( iv_name = 'MARKUP' iv_amount = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_component TYPE zcl_alloc_interco_price=>ty_component.

    ls_component-name = iv_name.
    ls_component-amount = iv_amount.
    APPEND ls_component TO mt_component.
  ENDMETHOD.

  METHOD builds_price.
    DATA ls_price TYPE zcl_alloc_interco_price=>ty_price.

    ls_price = mo_cut->build( mt_component ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_price-component_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_price-total exp = 1100 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_component ) exp = 1100 ).
  ENDMETHOD.

  METHOD positive_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_positive( mt_component ) exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
