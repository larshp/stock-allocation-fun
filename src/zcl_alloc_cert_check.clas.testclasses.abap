CLASS ltcl_alloc_cert_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cert_check.
    DATA mt_req TYPE zcl_alloc_cert_check=>ty_text_tt.
    DATA mt_hel TYPE zcl_alloc_cert_check=>ty_text_tt.

    METHODS setup.

    METHODS nothing_missing FOR TESTING.
    METHODS one_missing     FOR TESTING.
    METHODS extra_held_ok   FOR TESTING.
    METHODS complete_flag   FOR TESTING.
    METHODS empty_required  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cert_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cert_check( ).
    APPEND 'CERT_A' TO mt_req.
    APPEND 'CERT_B' TO mt_req.
  ENDMETHOD.

  METHOD nothing_missing.
    DATA lt_missing TYPE zcl_alloc_cert_check=>ty_text_tt.

    APPEND 'CERT_A' TO mt_hel.
    APPEND 'CERT_B' TO mt_hel.

    lt_missing = mo_cut->missing( it_required = mt_req
                                  it_held     = mt_hel ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_missing ) exp = 0 ).
  ENDMETHOD.

  METHOD one_missing.
    DATA lt_missing TYPE zcl_alloc_cert_check=>ty_text_tt.

    APPEND 'CERT_A' TO mt_hel.

    lt_missing = mo_cut->missing( it_required = mt_req
                                  it_held     = mt_hel ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_missing ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_missing[ 1 ] exp = 'CERT_B' ).
  ENDMETHOD.

  METHOD extra_held_ok.
    DATA lt_missing TYPE zcl_alloc_cert_check=>ty_text_tt.

    APPEND 'CERT_A' TO mt_hel.
    APPEND 'CERT_B' TO mt_hel.
    APPEND 'CERT_Z' TO mt_hel.

    lt_missing = mo_cut->missing( it_required = mt_req
                                  it_held     = mt_hel ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_missing ) exp = 0 ).
  ENDMETHOD.

  METHOD complete_flag.
    APPEND 'CERT_A' TO mt_hel.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( it_required = mt_req it_held = mt_hel )
      exp = abap_false ).
  ENDMETHOD.

  METHOD empty_required.
    DATA lt_empty TYPE zcl_alloc_cert_check=>ty_text_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( it_required = lt_empty it_held = mt_hel )
      exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
