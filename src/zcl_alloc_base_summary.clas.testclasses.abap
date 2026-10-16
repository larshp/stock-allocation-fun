CLASS ltcl_alloc_base_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_summary.
    DATA mt_line TYPE zcl_alloc_base_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_base  TYPE string
        iv_value TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS sums_total     FOR TESTING.
    METHODS counts_bases   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_summary( ).

    add( iv_base = 'UNITS' iv_value = 100 ).
    add( iv_base = 'VALUE' iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_base_summary=>ty_line.

    ls_line-base = iv_base.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_base_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-base_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 300 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 300 ).
  ENDMETHOD.

  METHOD counts_bases.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->base_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
