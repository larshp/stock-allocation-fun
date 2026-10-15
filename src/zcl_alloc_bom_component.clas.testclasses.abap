CLASS ltcl_alloc_bom_component DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_component.
    DATA mt_line TYPE zcl_alloc_bom_component=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_component TYPE string
        iv_qty       TYPE i.

    METHODS sums_component FOR TESTING.
    METHODS used_rule      FOR TESTING.
    METHODS counts_used    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_component IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_component( ).

    add( iv_component = 'C1' iv_qty = 2 ).
    add( iv_component = 'C2' iv_qty = 3 ).
    add( iv_component = 'C1' iv_qty = 1 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_bom_component=>ty_line.

    ls_line-component = iv_component.
    ls_line-qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD sums_component.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->qty_of( it_lines = mt_line iv_component = 'C1' )
      exp = 3 ).
  ENDMETHOD.

  METHOD used_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_used( it_lines = mt_line iv_component = 'C1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_used( it_lines = mt_line iv_component = 'C9' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_used.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
