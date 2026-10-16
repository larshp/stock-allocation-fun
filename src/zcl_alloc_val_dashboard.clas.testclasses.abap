CLASS ltcl_alloc_val_dashboard DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_dashboard.
    DATA mt_line TYPE zcl_alloc_val_dashboard=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS builds_dashboard FOR TESTING.
    METHODS healthy_rule     FOR TESTING.
    METHODS reads_highlight  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_dashboard IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_dashboard( ).

    add( iv_material = 'M1' iv_value = 1000 ).
    add( iv_material = 'M2' iv_value = 600 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_dashboard=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_dashboard.
    DATA ls_dash TYPE zcl_alloc_val_dashboard=>ty_dash.

    ls_dash = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_dash-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_dash-total_value exp = 1600 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_dash-average_value exp = 800 ).
  ENDMETHOD.

  METHOD healthy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_line_count = 2 iv_min_lines = 1 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_line_count = 0 iv_min_lines = 1 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_highlight.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->highlight( iv_total_value = 1600 iv_threshold = 1000 )
      exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->highlight( iv_total_value = 500 iv_threshold = 1000 )
      exp = 'NORMAL' ).
  ENDMETHOD.

ENDCLASS.
