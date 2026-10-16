CLASS ltcl_alloc_markdown DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_markdown.

    METHODS setup.

    METHODS overview_row
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_requested  TYPE menge_d
        iv_allocated  TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_run_report=>ty_overview.

    METHODS header_has_two_lines FOR TESTING.
    METHODS empty_overview       FOR TESTING.
    METHODS row_is_markdown      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_markdown IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_markdown( ).
  ENDMETHOD.

  METHOD overview_row.
    rs_row-run_id = iv_run_id.
    rs_row-matnr = 'MAT-1'.
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

  METHOD header_has_two_lines.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_lines    TYPE zcl_alloc_markdown=>ty_lines_tt.

    lt_lines = mo_cut->run_overview( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = '| Run | Material | Plant | Status | Items | Requested | Allocated | Shortage | Coverage |' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = '| --- | --- | --- | --- | --- | --- | --- | --- | --- |' ).
  ENDMETHOD.

  METHOD empty_overview.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    DATA(lt_lines) = mo_cut->run_overview( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 2 ).
  ENDMETHOD.

  METHOD row_is_markdown.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND overview_row( iv_run_id    = 'RUN-1'
                         iv_requested = '10'
                         iv_allocated = '6' ) TO lt_overview.

    DATA(lt_lines) = mo_cut->run_overview( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 3 ]
      exp = '| RUN-1 | MAT-1 | P1 | D | 2 | 10.000 | 6.000 | 4.000 | 60 |' ).
  ENDMETHOD.

ENDCLASS.
