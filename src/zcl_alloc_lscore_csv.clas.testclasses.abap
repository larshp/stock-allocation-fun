CLASS ltcl_alloc_lscore_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lscore_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_lscore_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lscore_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_items TYPE zcl_alloc_lscore_csv=>ty_item_tt.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'LGORT;FILL_PCT;DISTANCE;PICKS;SCORE' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_items TYPE zcl_alloc_lscore_csv=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_lscore_csv=>ty_item.

    ls_item-lgort = '0001'.
    ls_item-fill_pct = 90.
    ls_item-distance = 0.
    ls_item-picks = 0.
    APPEND ls_item TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '0001;90;0;0;180' ).
  ENDMETHOD.

ENDCLASS.
