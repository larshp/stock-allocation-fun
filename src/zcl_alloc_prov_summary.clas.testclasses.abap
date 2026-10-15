CLASS ltcl_alloc_prov_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prov_summary.
    DATA mt_line TYPE zcl_alloc_prov_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material  TYPE matnr
        iv_provision TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS sums_total     FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prov_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prov_summary( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prov_summary=>ty_line.

    ls_line-material = iv_material.
    ls_line-provision = iv_provision.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_prov_summary=>ty_summary.

    add( iv_material = 'M1' iv_provision = 300 ).
    add( iv_material = 'M2' iv_provision = 200 ).

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 500 ).
  ENDMETHOD.

  METHOD sums_total.
    add( iv_material = 'M1' iv_provision = 300 ).
    add( iv_material = 'M2' iv_provision = 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 500 ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_material = 'M1' iv_provision = 300 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
