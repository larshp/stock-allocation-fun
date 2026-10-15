CLASS ltcl_alloc_bom_build DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_build.
    DATA mt_line TYPE zcl_alloc_bom_build=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_component TYPE string
        iv_qty       TYPE i.

    METHODS builds_components FOR TESTING.
    METHODS counts_components FOR TESTING.
    METHODS sums_qty          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_build IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_build( ).

    add( iv_component = 'C1' iv_qty = 2 ).
    add( iv_component = 'C2' iv_qty = 3 ).
    add( iv_component = 'C1' iv_qty = 1 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_bom_build=>ty_line.

    ls_line-component = iv_component.
    ls_line-qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_components.
    DATA lt_comp TYPE zcl_alloc_bom_build=>ty_comp_tt.

    lt_comp = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_comp ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_comp[ 1 ]-qty exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_comp[ 2 ]-qty exp = 3 ).
  ENDMETHOD.

  METHOD counts_components.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->component_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_qty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_qty( mt_line ) exp = 6 ).
  ENDMETHOD.

ENDCLASS.
