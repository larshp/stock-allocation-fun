CLASS ltcl_alloc_service_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_service_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_service_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_service_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_levels TYPE zcl_alloc_service_level=>ty_level_tt.

    DATA(lt_lines) = mo_cut->build( lt_levels ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'MATNR;REQUESTED_QTY;ALLOCATED_QTY;SHORTAGE_QTY;FILL_RATE_PCT;LINES' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_levels TYPE zcl_alloc_service_level=>ty_level_tt.
    DATA ls_level  TYPE zcl_alloc_service_level=>ty_level.

    ls_level-matnr = 'MAT-1'.
    ls_level-requested_qty = '20'.
    ls_level-allocated_qty = '15'.
    ls_level-shortage_qty = '5'.
    ls_level-fill_rate_pct = 75.
    ls_level-lines = 2.
    APPEND ls_level TO lt_levels.

    DATA(lt_lines) = mo_cut->build( lt_levels ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = 'MAT-1;20.000;15.000;5.000;75;2' ).
  ENDMETHOD.

ENDCLASS.
