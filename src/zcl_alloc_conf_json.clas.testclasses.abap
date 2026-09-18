CLASS ltcl_alloc_conf_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_conf_json.

    METHODS setup.

    METHODS empty_score FOR TESTING.
    METHODS values      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_conf_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_conf_json( ).
  ENDMETHOD.

  METHOD empty_score.
    DATA ls_conf TYPE zcl_alloc_confidence=>ty_confidence.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_conf )
      exp = '{"requirements":0,"coverage_pct":0,"fill_rate_pct":0,"score":0}' ).
  ENDMETHOD.

  METHOD values.
    DATA ls_conf TYPE zcl_alloc_confidence=>ty_confidence.

    ls_conf-requirements = 5.
    ls_conf-coverage_pct = 80.
    ls_conf-fill_rate_pct = 75.
    ls_conf-score = 78.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_conf )
      exp = '{"requirements":5,"coverage_pct":80,"fill_rate_pct":75,' &&
            '"score":78}' ).
  ENDMETHOD.

ENDCLASS.
