CLASS ltcl_alloc_xml DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_xml.

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
    METHODS empty_document     FOR TESTING.
    METHODS document_structure FOR TESTING.
    METHODS row_fields         FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_xml IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_xml( ).
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

  METHOD empty_document.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    DATA(lt_lines) = mo_cut->run_overview( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = '<?xml version="1.0" encoding="UTF-8"?>' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = '<runs>' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ] exp = '</runs>' ).
  ENDMETHOD.

  METHOD document_structure.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND overview_row( iv_run_id    = 'RUN-1'
                         iv_matnr     = 'MAT-1'
                         iv_requested = '10'
                         iv_allocated = '6' ) TO lt_overview.

    DATA(lt_lines) = mo_cut->run_overview( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 14 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = '  <run>' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 13 ]
                                        exp = '  </run>' ).
  ENDMETHOD.

  METHOD row_fields.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND overview_row( iv_run_id    = 'RUN-1'
                         iv_matnr     = 'MAT<1>'
                         iv_requested = '10'
                         iv_allocated = '6' ) TO lt_overview.

    DATA(lt_lines) = mo_cut->run_overview( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 4 ]
                                        exp = '  <run_id>RUN-1</run_id>' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 5 ]
      exp = '  <material>MAT&lt;1&gt;</material>' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 10 ]
      exp = '  <allocated>6.000</allocated>' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 12 ]
      exp = '  <coverage>60</coverage>' ).
  ENDMETHOD.

ENDCLASS.
