CLASS ltcl_alloc_deletion DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut        TYPE REF TO zcl_alloc_deletion.
    DATA mt_candidates TYPE zcl_alloc_deletion=>ty_candidate_tt.

    METHODS setup.

    METHODS proposes_expired FOR TESTING.
    METHODS protects_run     FOR TESTING.
    METHODS skips_empty      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_deletion IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_deletion( ).

    CLEAR mt_candidates.
    APPEND VALUE #( run_id = 'R1' archived_on = '20260101' ) TO mt_candidates.
    APPEND VALUE #( run_id = 'R2' archived_on = '20260601' ) TO mt_candidates.
  ENDMETHOD.

  METHOD proposes_expired.
    DATA lt_delete  TYPE zcl_alloc_deletion=>ty_run_id_tt.
    DATA ls_request TYPE zcl_alloc_deletion=>ty_request.

    ls_request-retention = 30.
    ls_request-reference = '20260701'.
    ls_request-protected = ''.

    lt_delete = mo_cut->propose( it_candidates = mt_candidates is_request = ls_request ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_delete ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_delete[ 1 ] exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_delete[ 2 ] exp = 'R2' ).
  ENDMETHOD.

  METHOD protects_run.
    DATA lt_delete  TYPE zcl_alloc_deletion=>ty_run_id_tt.
    DATA ls_request TYPE zcl_alloc_deletion=>ty_request.

    ls_request-retention = 30.
    ls_request-reference = '20260701'.
    ls_request-protected = 'R1'.

    lt_delete = mo_cut->propose( it_candidates = mt_candidates is_request = ls_request ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_delete ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_delete[ 1 ] exp = 'R2' ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_delete  TYPE zcl_alloc_deletion=>ty_run_id_tt.
    DATA lt_cand    TYPE zcl_alloc_deletion=>ty_candidate_tt.
    DATA ls_request TYPE zcl_alloc_deletion=>ty_request.

    APPEND VALUE #( run_id = '' archived_on = '20260101' ) TO lt_cand.

    ls_request-retention = 30.
    ls_request-reference = '20260701'.
    ls_request-protected = ''.

    lt_delete = mo_cut->propose( it_candidates = lt_cand is_request = ls_request ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_delete ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
