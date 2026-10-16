CLASS ltcl_alloc_settle_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_settle_rank.
    DATA mt_line TYPE zcl_alloc_settle_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_item   TYPE string
        iv_amount TYPE i.

    METHODS ranks_items FOR TESTING.
    METHODS picks_worst FOR TESTING.
    METHODS picks_best  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_settle_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_settle_rank( ).

    add( iv_item = 'I1' iv_amount = 50 ).
    add( iv_item = 'I2' iv_amount = -30 ).
    add( iv_item = 'I3' iv_amount = 20 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_settle_rank=>ty_line.

    ls_line-item = iv_item.
    ls_line-amount = iv_amount.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_items.
    DATA lt_ranked TYPE zcl_alloc_settle_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-amount exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-amount exp = -30 ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = 50 ).
  ENDMETHOD.

  METHOD picks_best.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_line ) exp = -30 ).
  ENDMETHOD.

ENDCLASS.
