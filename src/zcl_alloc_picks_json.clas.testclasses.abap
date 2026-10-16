CLASS ltcl_alloc_picks_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_picks_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_picks_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_picks_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_pick_sequence=>ty_item_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_items )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_items TYPE zcl_alloc_pick_sequence=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_pick_sequence=>ty_item.

    ls_item-lgort = '0001'.
    ls_item-charg = 'B1'.
    ls_item-quantity = '5'.
    APPEND ls_item TO lt_items.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_items )
      exp = '[{"lgort":"0001","charg":"B1","quantity":5.000}]' ).
  ENDMETHOD.

ENDCLASS.
