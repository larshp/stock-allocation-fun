CLASS ltcl_alloc_run_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_run_compare.

    METHODS setup.

    METHODS row
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_matnr      TYPE matnr
        iv_coverage   TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_run_report=>ty_overview.

    METHODS input
      IMPORTING
        it_old        TYPE zcl_alloc_run_report=>ty_overview_tt
        it_new        TYPE zcl_alloc_run_report=>ty_overview_tt
        iv_include    TYPE abap_bool
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_run_compare=>ty_input.

    METHODS empty_lists    FOR TESTING.
    METHODS added_run      FOR TESTING.
    METHODS removed_run    FOR TESTING.
    METHODS changed_run    FOR TESTING.
    METHODS unchanged_hidden FOR TESTING.
    METHODS include_unchanged FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_run_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_run_compare( ).
  ENDMETHOD.

  METHOD row.
    rs_row-run_id = iv_run_id.
    rs_row-matnr = iv_matnr.
    rs_row-coverage_pct = iv_coverage.
  ENDMETHOD.

  METHOD input.
    rs_row-old = it_old.
    rs_row-new = it_new.
    rs_row-include_unchanged = iv_include.
  ENDMETHOD.

  METHOD empty_lists.
    DATA lt_old TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_new TYPE zcl_alloc_run_report=>ty_overview_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->compare( input( it_old     = lt_old
                                    it_new     = lt_new
                                    iv_include = abap_false ) ) ).
  ENDMETHOD.

  METHOD added_run.
    DATA lt_old TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_new TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_coverage = 50 )
      TO lt_new.

    DATA(lt_lines) = mo_cut->compare( input( it_old     = lt_old
                                             it_new     = lt_new
                                             iv_include = abap_false ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-change_type
                                        exp = '+' ).
  ENDMETHOD.

  METHOD removed_run.
    DATA lt_old TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_new TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_coverage = 50 )
      TO lt_old.

    DATA(lt_lines) = mo_cut->compare( input( it_old     = lt_old
                                             it_new     = lt_new
                                             iv_include = abap_false ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-change_type
                                        exp = '-' ).
  ENDMETHOD.

  METHOD changed_run.
    DATA lt_old TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_new TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_coverage = 50 )
      TO lt_old.
    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_coverage = 80 )
      TO lt_new.

    DATA(lt_lines) = mo_cut->compare( input( it_old     = lt_old
                                             it_new     = lt_new
                                             iv_include = abap_false ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-change_type
                                        exp = '~' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-old_coverage
                                        exp = 50 ).
  ENDMETHOD.

  METHOD unchanged_hidden.
    DATA lt_old TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_new TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_coverage = 50 )
      TO lt_old.
    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_coverage = 50 )
      TO lt_new.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->compare( input( it_old     = lt_old
                                    it_new     = lt_new
                                    iv_include = abap_false ) ) ).
  ENDMETHOD.

  METHOD include_unchanged.
    DATA lt_old TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_new TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_coverage = 50 )
      TO lt_old.
    APPEND row( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_coverage = 50 )
      TO lt_new.

    DATA(lt_lines) = mo_cut->compare( input( it_old     = lt_old
                                             it_new     = lt_new
                                             iv_include = abap_true ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-change_type
                                        exp = '=' ).
  ENDMETHOD.

ENDCLASS.
