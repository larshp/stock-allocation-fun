CLASS ltcl_alloc_plant_list DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_plant_list.

    METHODS setup.

    METHODS overview
      IMPORTING
        iv_werks      TYPE werks_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_run_report=>ty_overview.

    METHODS empty_list   FOR TESTING.
    METHODS removes_dups FOR TESTING.
    METHODS sorted_output FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_plant_list IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_plant_list( ).
  ENDMETHOD.

  METHOD overview.
    rs_row-werks = iv_werks.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_overview ) ).
  ENDMETHOD.

  METHOD removes_dups.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND overview( '1000' ) TO lt_overview.
    APPEND overview( '1000' ) TO lt_overview.
    APPEND overview( '2000' ) TO lt_overview.

    DATA(lt_werks) = mo_cut->build( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_werks ) exp = 2 ).
  ENDMETHOD.

  METHOD sorted_output.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    APPEND overview( '2000' ) TO lt_overview.
    APPEND overview( '1000' ) TO lt_overview.

    DATA(lt_werks) = mo_cut->build( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lt_werks[ 1 ] exp = '1000' ).
  ENDMETHOD.

ENDCLASS.
