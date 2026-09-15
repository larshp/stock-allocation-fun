CLASS ltcl_alloc_histogram DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_histogram.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_histogram=>ty_item.

    METHODS empty_result      FOR TESTING.
    METHODS first_bucket      FOR TESTING.
    METHODS boundary_bucket   FOR TESTING.
    METHODS groups_same_bucket FOR TESTING.
    METHODS sorted_buckets    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_histogram IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_histogram( ).
  ENDMETHOD.

  METHOD item.
    rs_row-matnr = iv_matnr.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_items TYPE zcl_alloc_histogram=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_items ) ).
  ENDMETHOD.

  METHOD first_bucket.
    DATA lt_items TYPE zcl_alloc_histogram=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '5' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( it_items       = lt_items
                                    iv_bucket_size = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-bucket_from exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-bucket_to exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-quantity exp = '5' ).
  ENDMETHOD.

  METHOD boundary_bucket.
    DATA lt_items TYPE zcl_alloc_histogram=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '10' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( it_items       = lt_items
                                    iv_bucket_size = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-bucket_from exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-bucket_to exp = '20' ).
  ENDMETHOD.

  METHOD groups_same_bucket.
    DATA lt_items TYPE zcl_alloc_histogram=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '5' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-2' iv_quantity = '7' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( it_items       = lt_items
                                    iv_bucket_size = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-quantity exp = '12' ).
  ENDMETHOD.

  METHOD sorted_buckets.
    DATA lt_items TYPE zcl_alloc_histogram=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '25' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-2' iv_quantity = '5' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( it_items       = lt_items
                                    iv_bucket_size = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-bucket_from exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-bucket_from exp = '20' ).
  ENDMETHOD.

ENDCLASS.
