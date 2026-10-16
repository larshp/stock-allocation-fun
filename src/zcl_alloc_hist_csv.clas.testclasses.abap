CLASS ltcl_alloc_hist_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hist_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_bucket  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_hist_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hist_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_buckets TYPE zcl_alloc_histogram=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_buckets ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'BUCKET_FROM;BUCKET_TO;COUNT;QUANTITY' ).
  ENDMETHOD.

  METHOD one_bucket.
    DATA lt_buckets TYPE zcl_alloc_histogram=>ty_line_tt.
    DATA ls_bucket  TYPE zcl_alloc_histogram=>ty_line.

    ls_bucket-bucket_from = '0'.
    ls_bucket-bucket_to = '10'.
    ls_bucket-count = 2.
    ls_bucket-quantity = '15'.
    APPEND ls_bucket TO lt_buckets.

    DATA(lt_lines) = mo_cut->build( lt_buckets ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '0.000;10.000;2;15.000' ).
  ENDMETHOD.

ENDCLASS.
