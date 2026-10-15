CLASS ltcl_alloc_bom_weight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_weight.
    DATA mt_line TYPE zcl_alloc_bom_weight=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_component   TYPE string
        iv_qty         TYPE i
        iv_unit_weight TYPE i.

    METHODS computes_weight FOR TESTING.
    METHODS sums_weight     FOR TESTING.
    METHODS heavy_rule      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_weight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_weight( ).

    add( iv_component = 'C1' iv_qty = 2 iv_unit_weight = 3 ).
    add( iv_component = 'C2' iv_qty = 1 iv_unit_weight = 4 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_bom_weight=>ty_line.

    ls_line-component = iv_component.
    ls_line-qty = iv_qty.
    ls_line-unit_weight = iv_unit_weight.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD computes_weight.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weight_of( iv_qty = 3 iv_unit_weight = 2 )
      exp = 6 ).
  ENDMETHOD.

  METHOD sums_weight.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_weight( mt_line ) exp = 10 ).
  ENDMETHOD.

  METHOD heavy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_heavy( iv_weight = 10 iv_limit = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_heavy( iv_weight = 4 iv_limit = 5 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
