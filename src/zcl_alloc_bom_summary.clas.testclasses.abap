CLASS ltcl_alloc_bom_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_summary.
    DATA mt_line TYPE zcl_alloc_bom_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_component TYPE string
        iv_qty       TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_comps   FOR TESTING.
    METHODS sums_qty       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_summary( ).

    add( iv_component = 'C1' iv_qty = 2 ).
    add( iv_component = 'C2' iv_qty = 3 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_bom_summary=>ty_line.

    ls_line-component = iv_component.
    ls_line-qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_bom_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-component_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_qty exp = 5 ).
  ENDMETHOD.

  METHOD counts_comps.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->component_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_qty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_qty( mt_line ) exp = 5 ).
  ENDMETHOD.

ENDCLASS.
