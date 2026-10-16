CLASS ltcl_alloc_recall_return DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recall_return.
    DATA mt_lot TYPE zcl_alloc_recall_return=>ty_lot_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_batch    TYPE string
        iv_quantity TYPE i.

    METHODS scopes_lots    FOR TESTING.
    METHODS sums_affected  FOR TESTING.
    METHODS affects_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recall_return IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recall_return( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_lot TYPE zcl_alloc_recall_return=>ty_lot.

    ls_lot-material = iv_material.
    ls_lot-batch = iv_batch.
    ls_lot-quantity = iv_quantity.
    APPEND ls_lot TO mt_lot.
  ENDMETHOD.

  METHOD scopes_lots.
    DATA lt_hits TYPE zcl_alloc_recall_return=>ty_hit_tt.

    add( iv_material = 'M1' iv_batch = 'B1' iv_quantity = 10 ).
    add( iv_material = 'M2' iv_batch = 'B2' iv_quantity = 5 ).
    add( iv_material = 'M1' iv_batch = 'B3' iv_quantity = 3 ).

    lt_hits = mo_cut->scope( it_lots = mt_lot iv_material = 'M1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-batch exp = 'B1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 2 ]-batch exp = 'B3' ).
  ENDMETHOD.

  METHOD sums_affected.
    add( iv_material = 'M1' iv_batch = 'B1' iv_quantity = 10 ).
    add( iv_material = 'M2' iv_batch = 'B2' iv_quantity = 5 ).
    add( iv_material = 'M1' iv_batch = 'B3' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->affected_quantity( it_lots = mt_lot iv_material = 'M1' )
      exp = 13 ).
  ENDMETHOD.

  METHOD affects_rule.
    DATA ls_lot TYPE zcl_alloc_recall_return=>ty_lot.

    ls_lot-material = 'M1'.
    ls_lot-batch = 'B1'.
    ls_lot-quantity = 10.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_affected( is_lot = ls_lot iv_material = 'M1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_affected( is_lot = ls_lot iv_material = 'M2' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
