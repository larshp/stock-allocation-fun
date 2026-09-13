CLASS ltcl_alloc_pick_sequence DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pick_sequence.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_lgort      TYPE lgort_d
        iv_charg      TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_pick_sequence=>ty_item.

    METHODS empty_list    FOR TESTING.
    METHODS sorts_by_bin  FOR TESTING.
    METHODS batch_in_bin  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pick_sequence IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pick_sequence( ).
  ENDMETHOD.

  METHOD item.
    rs_row-lgort = iv_lgort.
    rs_row-charg = iv_charg.
    rs_row-quantity = '10'.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_pick_sequence=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->sequence( lt_items ) ).
  ENDMETHOD.

  METHOD sorts_by_bin.
    DATA lt_items TYPE zcl_alloc_pick_sequence=>ty_item_tt.

    APPEND item( iv_lgort = 'L2' iv_charg = 'A' ) TO lt_items.
    APPEND item( iv_lgort = 'L1' iv_charg = 'A' ) TO lt_items.

    DATA(lt_sorted) = mo_cut->sequence( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-lgort exp = 'L1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 2 ]-lgort exp = 'L2' ).
  ENDMETHOD.

  METHOD batch_in_bin.
    DATA lt_items TYPE zcl_alloc_pick_sequence=>ty_item_tt.

    APPEND item( iv_lgort = 'L1' iv_charg = 'B' ) TO lt_items.
    APPEND item( iv_lgort = 'L1' iv_charg = 'A' ) TO lt_items.

    DATA(lt_sorted) = mo_cut->sequence( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-charg exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 2 ]-charg exp = 'B' ).
  ENDMETHOD.

ENDCLASS.
