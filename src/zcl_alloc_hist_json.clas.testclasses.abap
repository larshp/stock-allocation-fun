CLASS ltcl_alloc_hist_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hist_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_bucket FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_hist_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hist_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_buckets TYPE zcl_alloc_histogram=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_buckets )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_bucket.
    DATA lt_buckets TYPE zcl_alloc_histogram=>ty_line_tt.
    DATA ls_bucket  TYPE zcl_alloc_histogram=>ty_line.

    ls_bucket-bucket_from = '0'.
    ls_bucket-bucket_to = '10'.
    ls_bucket-count = 2.
    ls_bucket-quantity = '15'.
    APPEND ls_bucket TO lt_buckets.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_buckets )
      exp = '[{"bucket_from":0.000,"bucket_to":10.000,"count":2,' &&
            '"quantity":15.000}]' ).
  ENDMETHOD.

ENDCLASS.
