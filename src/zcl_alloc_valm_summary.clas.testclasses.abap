CLASS ltcl_alloc_valm_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_summary.
    DATA mt_line TYPE zcl_alloc_valm_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS computes_rate  FOR TESTING.
    METHODS reads_status   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_summary( ).

    add( iv_material = 'M1' iv_value = 1500 ).
    add( iv_material = 'M2' iv_value = 800 ).
    add( iv_material = 'M3' iv_value = 900 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_valm_summary=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_valm_summary=>ty_summary.

    ls_summary = mo_cut->build( it_lines = mt_line iv_threshold = 1000 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-line_count exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-breach_count exp = 1 ).
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->evaluate( iv_breach_count = 1 iv_line_count = 3 )
      exp = 33 ).
  ENDMETHOD.

  METHOD reads_status.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_breach_percent = 33 iv_limit_percent = 20 )
      exp = 'ALERT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_breach_percent = 10 iv_limit_percent = 20 )
      exp = 'WATCH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_breach_percent = 0 iv_limit_percent = 20 )
      exp = 'OK' ).
  ENDMETHOD.

ENDCLASS.
