CLASS ltcl_alloc_picks_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_picks_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_picks_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_picks_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_items TYPE zcl_alloc_pick_sequence=>ty_item_tt.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'LGORT;CHARG;QUANTITY' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_items TYPE zcl_alloc_pick_sequence=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_pick_sequence=>ty_item.

    ls_item-lgort = '0001'.
    ls_item-charg = 'B1'.
    ls_item-quantity = '5'.
    APPEND ls_item TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '0001;B1;5.000' ).
  ENDMETHOD.

ENDCLASS.
