CLASS ltcl_alloc_material_list DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_material_list.

    METHODS setup.

    METHODS overview
      IMPORTING
        iv_matnr      TYPE matnr
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_run_report=>ty_overview.

    METHODS empty_list    FOR TESTING.
    METHODS single_entry  FOR TESTING.
    METHODS removes_dups  FOR TESTING.
    METHODS sorted_output FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_material_list IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_material_list( ).
  ENDMETHOD.

  METHOD overview.
    rs_row-matnr = iv_matnr.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_overview ) ).
  ENDMETHOD.

  METHOD single_entry.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND overview( 'MAT-1' ) TO lt_overview.

    DATA(lt_matnr) = mo_cut->build( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_matnr ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_matnr[ 1 ] exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD removes_dups.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND overview( 'MAT-1' ) TO lt_overview.
    APPEND overview( 'MAT-1' ) TO lt_overview.
    APPEND overview( 'MAT-2' ) TO lt_overview.

    DATA(lt_matnr) = mo_cut->build( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_matnr ) exp = 2 ).
  ENDMETHOD.

  METHOD sorted_output.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND overview( 'MAT-2' ) TO lt_overview.
    APPEND overview( 'MAT-1' ) TO lt_overview.

    DATA(lt_matnr) = mo_cut->build( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lt_matnr[ 1 ] exp = 'MAT-1' ).
  ENDMETHOD.

ENDCLASS.
