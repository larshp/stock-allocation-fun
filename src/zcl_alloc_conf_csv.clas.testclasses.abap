CLASS ltcl_alloc_conf_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_conf_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS values_row  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_conf_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_conf_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA ls_conf TYPE zcl_alloc_confidence=>ty_confidence.

    DATA(lt_lines) = mo_cut->build( ls_conf ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'REQUIREMENTS;COVERAGE_PCT;FILL_RATE_PCT;SCORE' ).
  ENDMETHOD.

  METHOD values_row.
    DATA ls_conf TYPE zcl_alloc_confidence=>ty_confidence.

    ls_conf-requirements = 5.
    ls_conf-coverage_pct = 80.
    ls_conf-fill_rate_pct = 75.
    ls_conf-score = 78.

    DATA(lt_lines) = mo_cut->build( ls_conf ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '5;80;75;78' ).
  ENDMETHOD.

ENDCLASS.
