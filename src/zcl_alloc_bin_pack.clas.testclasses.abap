CLASS ltcl_alloc_bin_pack DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_pack.
    DATA mt_item TYPE zcl_alloc_bin_pack=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id   TYPE string
        iv_size TYPE menge_d.

    METHODS empty_items         FOR TESTING.
    METHODS zero_capacity       FOR TESTING.
    METHODS packs_single_bin    FOR TESTING.
    METHODS opens_second_bin    FOR TESTING.
    METHODS first_fit_decreasing FOR TESTING.
    METHODS skips_oversized     FOR TESTING.
    METHODS reports_oversized   FOR TESTING.
    METHODS skips_zero_sized    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_pack IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_pack( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_bin_pack=>ty_item.

    ls_item-item_id = iv_id.
    ls_item-size = iv_size.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD empty_items.
    DATA(lt_bins) = mo_cut->pack( it_items    = mt_item
                                  iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bins ) exp = 0 ).
  ENDMETHOD.

  METHOD zero_capacity.
    add( iv_id = 'A' iv_size = 5 ).

    DATA(lt_bins) = mo_cut->pack( it_items    = mt_item
                                  iv_capacity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bins ) exp = 0 ).
  ENDMETHOD.

  METHOD packs_single_bin.
    add( iv_id = 'A' iv_size = 4 ).
    add( iv_id = 'B' iv_size = 6 ).

    DATA(lt_bins) = mo_cut->pack( it_items    = mt_item
                                  iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bins ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bins[ 1 ]-load exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_bins[ 1 ]-item_ids ) exp = 2 ).
  ENDMETHOD.

  METHOD opens_second_bin.
    add( iv_id = 'A' iv_size = 8 ).
    add( iv_id = 'B' iv_size = 8 ).

    DATA(lt_bins) = mo_cut->pack( it_items    = mt_item
                                  iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bins ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bins[ 1 ]-bin_index exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bins[ 2 ]-bin_index exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bins[ 2 ]-load exp = 8 ).
  ENDMETHOD.

  METHOD first_fit_decreasing.
    add( iv_id = 'SMALL' iv_size = 3 ).
    add( iv_id = 'BIG' iv_size = 9 ).

    DATA(lt_bins) = mo_cut->pack( it_items    = mt_item
                                  iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bins ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bins[ 1 ]-item_ids[ 1 ] exp = 'BIG' ).
    cl_abap_unit_assert=>assert_equals( act = lt_bins[ 2 ]-item_ids[ 1 ] exp = 'SMALL' ).
  ENDMETHOD.

  METHOD skips_oversized.
    add( iv_id = 'TOO_BIG' iv_size = 20 ).
    add( iv_id = 'FITS' iv_size = 4 ).

    DATA(lt_bins) = mo_cut->pack( it_items    = mt_item
                                  iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bins ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bins[ 1 ]-item_ids[ 1 ] exp = 'FITS' ).
  ENDMETHOD.

  METHOD reports_oversized.
    add( iv_id = 'TOO_BIG' iv_size = 20 ).
    add( iv_id = 'FITS' iv_size = 4 ).

    DATA(lt_big) = mo_cut->oversized( it_items    = mt_item
                                      iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_big ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_big[ 1 ]-item_id exp = 'TOO_BIG' ).
  ENDMETHOD.

  METHOD skips_zero_sized.
    add( iv_id = 'ZERO' iv_size = 0 ).
    add( iv_id = 'REAL' iv_size = 2 ).

    DATA(lt_bins) = mo_cut->pack( it_items    = mt_item
                                  iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bins ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bins[ 1 ]-load exp = 2 ).
  ENDMETHOD.

ENDCLASS.
