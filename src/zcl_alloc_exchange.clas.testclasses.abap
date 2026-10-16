CLASS ltcl_alloc_exchange DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut     TYPE REF TO zcl_alloc_exchange.
    DATA mt_ret     TYPE zcl_alloc_exchange=>ty_item_tt.
    DATA mt_replace TYPE zcl_alloc_exchange=>ty_item_tt.

    METHODS setup.

    METHODS ret_item
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS replace_item
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS pairs_by_material FOR TESTING.
    METHODS caps_at_smaller   FOR TESTING.
    METHODS skips_unmatched   FOR TESTING.
    METHODS sums_paired       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_exchange IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_exchange( ).
  ENDMETHOD.

  METHOD ret_item.
    DATA ls_item TYPE zcl_alloc_exchange=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_ret.
  ENDMETHOD.

  METHOD replace_item.
    DATA ls_item TYPE zcl_alloc_exchange=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_replace.
  ENDMETHOD.

  METHOD pairs_by_material.
    DATA lt_pairs TYPE zcl_alloc_exchange=>ty_pair_tt.

    ret_item( iv_material = 'M1' iv_quantity = 5 ).
    ret_item( iv_material = 'M2' iv_quantity = 3 ).
    replace_item( iv_material = 'M1' iv_quantity = 10 ).
    replace_item( iv_material = 'M2' iv_quantity = 2 ).

    lt_pairs = mo_cut->propose( it_returned     = mt_ret
                                it_replacements = mt_replace ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pairs ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_pairs[ 1 ]-returned_material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_pairs[ 1 ]-replacement_material exp = 'M1' ).
  ENDMETHOD.

  METHOD caps_at_smaller.
    DATA lt_pairs TYPE zcl_alloc_exchange=>ty_pair_tt.

    ret_item( iv_material = 'M1' iv_quantity = 5 ).
    ret_item( iv_material = 'M2' iv_quantity = 3 ).
    replace_item( iv_material = 'M1' iv_quantity = 10 ).
    replace_item( iv_material = 'M2' iv_quantity = 2 ).

    lt_pairs = mo_cut->propose( it_returned     = mt_ret
                                it_replacements = mt_replace ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_pairs[ 1 ]-quantity exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_pairs[ 2 ]-quantity exp = 2 ).
  ENDMETHOD.

  METHOD skips_unmatched.
    DATA lt_pairs TYPE zcl_alloc_exchange=>ty_pair_tt.

    ret_item( iv_material = 'M3' iv_quantity = 1 ).
    replace_item( iv_material = 'M1' iv_quantity = 10 ).

    lt_pairs = mo_cut->propose( it_returned     = mt_ret
                                it_replacements = mt_replace ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pairs ) exp = 0 ).
  ENDMETHOD.

  METHOD sums_paired.
    DATA lt_pairs TYPE zcl_alloc_exchange=>ty_pair_tt.

    ret_item( iv_material = 'M1' iv_quantity = 5 ).
    ret_item( iv_material = 'M2' iv_quantity = 3 ).
    replace_item( iv_material = 'M1' iv_quantity = 10 ).
    replace_item( iv_material = 'M2' iv_quantity = 2 ).

    lt_pairs = mo_cut->propose( it_returned     = mt_ret
                                it_replacements = mt_replace ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->paired( lt_pairs ) exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->quantity( it_pairs             = lt_pairs
                              iv_returned_material = 'M1' )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
