CLASS ltcl_alloc_recall_notice DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recall_notice.
    DATA mt_lot TYPE zcl_alloc_recall_notice=>ty_lot_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_batch    TYPE string
        iv_quantity TYPE i.

    METHODS builds_message  FOR TESTING.
    METHODS message_text    FOR TESTING.
    METHODS recipients_list FOR TESTING.
    METHODS skips_empty     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recall_notice IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recall_notice( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_lot TYPE zcl_alloc_recall_notice=>ty_lot.

    ls_lot-material = iv_material.
    ls_lot-batch = iv_batch.
    ls_lot-quantity = iv_quantity.
    APPEND ls_lot TO mt_lot.
  ENDMETHOD.

  METHOD builds_message.
    add( iv_material = 'M1' iv_batch = 'B1' iv_quantity = 10 ).
    add( iv_material = 'M2' iv_batch = 'B2' iv_quantity = 5 ).
    add( iv_material = 'M1' iv_batch = 'B3' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( it_lots = mt_lot iv_reason = 'CONTAMINATION' )
      exp = 'Recall CONTAMINATION: 3 items, 18 units' ).
  ENDMETHOD.

  METHOD message_text.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->message( iv_reason = 'CONTAMINATION' iv_count = 3 )
      exp = 'Recall CONTAMINATION: 3 items' ).
  ENDMETHOD.

  METHOD recipients_list.
    DATA lt_rec TYPE zcl_alloc_recall_notice=>ty_recipients_tt.

    add( iv_material = 'M1' iv_batch = 'B1' iv_quantity = 10 ).
    add( iv_material = 'M2' iv_batch = 'B2' iv_quantity = 5 ).
    add( iv_material = 'M1' iv_batch = 'B3' iv_quantity = 3 ).

    lt_rec = mo_cut->recipients( mt_lot ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rec ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rec[ 1 ] exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rec[ 2 ] exp = 'M2' ).
  ENDMETHOD.

  METHOD skips_empty.
    add( iv_material = 'M1' iv_batch = 'B1' iv_quantity = 0 ).
    add( iv_material = 'M2' iv_batch = 'B2' iv_quantity = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( it_lots = mt_lot iv_reason = 'X' )
      exp = 'Recall X: 1 items, 4 units' ).
  ENDMETHOD.

ENDCLASS.
