CLASS ltcl_alloc_html DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_html.

    METHODS setup.

    METHODS overview_row
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_matnr      TYPE matnr
        iv_requested  TYPE menge_d
        iv_allocated  TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_run_report=>ty_overview.

    METHODS escapes_ampersand  FOR TESTING.
    METHODS escapes_brackets   FOR TESTING.
    METHODS plain_value_kept   FOR TESTING.
    METHODS header_structure   FOR TESTING.
    METHODS empty_overview     FOR TESTING.
    METHODS row_structure      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_html IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_html( ).
  ENDMETHOD.

  METHOD overview_row.
    rs_row-run_id = iv_run_id.
    rs_row-matnr = iv_matnr.
    rs_row-werks = 'P1'.
    rs_row-status = 'D'.
    rs_row-item_count = 2.
    rs_row-requested_qty = iv_requested.
    rs_row-allocated_qty = iv_allocated.
    rs_row-shortage_qty = iv_requested - iv_allocated.
    IF iv_requested > 0.
      rs_row-coverage_pct = iv_allocated * 100 DIV iv_requested.
    ENDIF.
  ENDMETHOD.

  METHOD escapes_ampersand.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->escape( 'A&B' )
                                        exp = 'A&amp;B' ).
  ENDMETHOD.

  METHOD escapes_brackets.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->escape( '<M>' )
                                        exp = '&lt;M&gt;' ).
  ENDMETHOD.

  METHOD plain_value_kept.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->escape( 'MAT-1' )
                                        exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD header_structure.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_lines    TYPE zcl_alloc_html=>ty_lines_tt.

    lt_lines = mo_cut->run_overview( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = '<table>' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = '</table>' ).
    cl_abap_unit_assert=>assert_equals(
      act = substring( val = lt_lines[ 2 ] off = 0 len = 9 )
      exp = '<tr><th>R' ).
  ENDMETHOD.

  METHOD empty_overview.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    DATA(lt_lines) = mo_cut->run_overview( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 3 ).
  ENDMETHOD.

  METHOD row_structure.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lv_expected TYPE string.

    APPEND overview_row( iv_run_id    = 'RUN-1'
                         iv_matnr     = 'MAT<1>'
                         iv_requested = '10'
                         iv_allocated = '6' ) TO lt_overview.

    DATA(lt_lines) = mo_cut->run_overview( lt_overview ).

    lv_expected = '<tr><td>RUN-1</td><td>MAT&lt;1&gt;</td><td>P1</td><td>D</td>'.
    lv_expected = lv_expected && '<td>2</td><td>10.000</td><td>6.000</td>'.
    lv_expected = lv_expected && '<td>4.000</td><td>60</td></tr>'.

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = lv_expected ).
  ENDMETHOD.

ENDCLASS.
