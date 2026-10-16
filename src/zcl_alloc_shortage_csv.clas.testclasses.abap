CLASS ltcl_alloc_shortage_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_shortage_csv.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_id          TYPE zcl_alloc_shortage_report=>ty_line-requirement_id
        iv_requested   TYPE menge_d
        iv_allocated   TYPE menge_d
        iv_covered     TYPE abap_bool
      RETURNING
        VALUE(rs_line) TYPE zcl_alloc_shortage_report=>ty_line.

    METHODS header_only       FOR TESTING.
    METHODS row_values        FOR TESTING.
    METHODS covered_flags     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_shortage_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_shortage_csv( ).
  ENDMETHOD.

  METHOD line.
    rs_line-requirement_id = iv_id.
    rs_line-requested_qty = iv_requested.
    rs_line-allocated_qty = iv_allocated.
    rs_line-shortage_qty = iv_requested - iv_allocated.
    IF iv_requested > 0.
      rs_line-coverage_pct = iv_allocated * 100 DIV iv_requested.
    ENDIF.
    rs_line-covered = iv_covered.
  ENDMETHOD.

  METHOD header_only.
    DATA ls_report TYPE zcl_alloc_shortage_report=>ty_report.

    DATA(lt_lines) = mo_cut->build( ls_report ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'REQUIREMENT_ID;REQUESTED;ALLOCATED;SHORTAGE;COVERAGE;COVERED' ).
  ENDMETHOD.

  METHOD row_values.
    DATA ls_report TYPE zcl_alloc_shortage_report=>ty_report.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '6'
                 iv_covered   = abap_false ) TO ls_report-lines.

    DATA(lt_lines) = mo_cut->build( ls_report ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = 'REQ-1;10.000;6.000;4.000;60;N' ).
  ENDMETHOD.

  METHOD covered_flags.
    DATA ls_report TYPE zcl_alloc_shortage_report=>ty_report.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '10'
                 iv_covered   = abap_true ) TO ls_report-lines.

    DATA(lt_lines) = mo_cut->build( ls_report ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = 'REQ-1;10.000;10.000;0.000;100;Y' ).
  ENDMETHOD.

ENDCLASS.
