CLASS ltcl_alloc_sort DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sort.

    METHODS setup.

    METHODS row
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_matnr      TYPE matnr
        iv_shortage   TYPE menge_d
        iv_coverage   TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_run_report=>ty_overview.

    METHODS empty_list    FOR TESTING.
    METHODS by_run_id     FOR TESTING.
    METHODS by_material   FOR TESTING.
    METHODS by_coverage   FOR TESTING.
    METHODS by_shortage   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_sort IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sort( ).
  ENDMETHOD.

  METHOD row.
    rs_row-run_id = iv_run_id.
    rs_row-matnr = iv_matnr.
    rs_row-shortage_qty = iv_shortage.
    rs_row-coverage_pct = iv_coverage.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->sort( lt_overview ) ).
  ENDMETHOD.

  METHOD by_run_id.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R2' iv_matnr = 'MAT-1'
                iv_shortage = '1' iv_coverage = 50 ) TO lt_overview.
    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                iv_shortage = '1' iv_coverage = 50 ) TO lt_overview.

    DATA(lt_sorted) = mo_cut->sort( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-run_id
                                        exp = 'R1' ).
  ENDMETHOD.

  METHOD by_material.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-2'
                iv_shortage = '1' iv_coverage = 50 ) TO lt_overview.
    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                iv_shortage = '1' iv_coverage = 50 ) TO lt_overview.

    DATA(lt_sorted) = mo_cut->sort( it_overview = lt_overview
                                    iv_mode     = 'M' ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-matnr
                                        exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD by_coverage.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                iv_shortage = '1' iv_coverage = 40 ) TO lt_overview.
    APPEND row( iv_run_id = 'R2' iv_matnr = 'MAT-1'
                iv_shortage = '1' iv_coverage = 90 ) TO lt_overview.

    DATA(lt_sorted) = mo_cut->sort( it_overview = lt_overview
                                    iv_mode     = 'C' ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-coverage_pct
                                        exp = 90 ).
  ENDMETHOD.

  METHOD by_shortage.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                iv_shortage = '2' iv_coverage = 50 ) TO lt_overview.
    APPEND row( iv_run_id = 'R2' iv_matnr = 'MAT-1'
                iv_shortage = '9' iv_coverage = 50 ) TO lt_overview.

    DATA(lt_sorted) = mo_cut->sort( it_overview = lt_overview
                                    iv_mode     = 'S' ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-run_id
                                        exp = 'R2' ).
  ENDMETHOD.

ENDCLASS.
