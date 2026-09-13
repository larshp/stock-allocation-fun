CLASS ltcl_alloc_service_level DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_service_level.

    METHODS setup.

    METHODS empty_result     FOR TESTING.
    METHODS full_delivery    FOR TESTING.
    METHODS partial_delivery FOR TESTING.
    METHODS groups_material  FOR TESTING.
    METHODS two_materials    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_service_level IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_service_level( ).
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_lines TYPE zcl_alloc_service_level=>ty_input_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->summarize( lt_lines ) ).
  ENDMETHOD.

  METHOD full_delivery.
    DATA lt_lines TYPE zcl_alloc_service_level=>ty_input_tt.
    DATA ls_line  TYPE zcl_alloc_service_level=>ty_input.

    ls_line-matnr = 'MAT-1'.
    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '10'.
    APPEND ls_line TO lt_lines.

    DATA(lt_levels) = mo_cut->summarize( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_levels ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-fill_rate_pct
                                        exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD partial_delivery.
    DATA lt_lines TYPE zcl_alloc_service_level=>ty_input_tt.
    DATA ls_line  TYPE zcl_alloc_service_level=>ty_input.

    ls_line-matnr = 'MAT-1'.
    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '6'.
    APPEND ls_line TO lt_lines.

    DATA(lt_levels) = mo_cut->summarize( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-fill_rate_pct
                                        exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-shortage_qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD groups_material.
    DATA lt_lines TYPE zcl_alloc_service_level=>ty_input_tt.
    DATA ls_line  TYPE zcl_alloc_service_level=>ty_input.

    ls_line-matnr = 'MAT-1'.
    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '10'.
    APPEND ls_line TO lt_lines.

    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '5'.
    APPEND ls_line TO lt_lines.

    DATA(lt_levels) = mo_cut->summarize( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_levels ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-requested_qty
                                        exp = '20' ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-allocated_qty
                                        exp = '15' ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-fill_rate_pct
                                        exp = 75 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-lines exp = 2 ).
  ENDMETHOD.

  METHOD two_materials.
    DATA lt_lines TYPE zcl_alloc_service_level=>ty_input_tt.
    DATA ls_line  TYPE zcl_alloc_service_level=>ty_input.

    ls_line-matnr = 'MAT-B'.
    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '10'.
    APPEND ls_line TO lt_lines.

    ls_line-matnr = 'MAT-A'.
    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '0'.
    APPEND ls_line TO lt_lines.

    DATA(lt_levels) = mo_cut->summarize( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_levels ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-matnr exp = 'MAT-A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 2 ]-matnr exp = 'MAT-B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ]-fill_rate_pct
                                        exp = 0 ).
  ENDMETHOD.

ENDCLASS.
