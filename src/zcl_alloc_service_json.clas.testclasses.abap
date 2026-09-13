CLASS ltcl_alloc_service_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_service_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_service_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_service_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_levels TYPE zcl_alloc_service_level=>ty_level_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_levels )
                                        exp = '[]' ).
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

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_levels )
      exp = '[{"matnr":"MAT-1","requested_qty":20.000,' &&
            '"allocated_qty":15.000,"shortage_qty":5.000,' &&
            '"fill_rate_pct":75,"lines":2}]' ).
  ENDMETHOD.

ENDCLASS.
