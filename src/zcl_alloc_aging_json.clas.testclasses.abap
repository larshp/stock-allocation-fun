CLASS ltcl_alloc_aging_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_aging_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_item   FOR TESTING.
    METHODS two_items  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_aging_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_aging_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_aging_json=>ty_item_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_items )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_item.
    DATA lt_items TYPE zcl_alloc_aging_json=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_aging_json=>ty_item.

    ls_item-id = 'REQ-1'.
    ls_item-days_overdue = 45.
    APPEND ls_item TO lt_items.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_items )
      exp = '[{"id":"REQ-1","days_overdue":45,"bucket":2}]' ).
  ENDMETHOD.

  METHOD two_items.
    DATA lt_items TYPE zcl_alloc_aging_json=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_aging_json=>ty_item.

    ls_item-id = 'REQ-1'.
    ls_item-days_overdue = -1.
    APPEND ls_item TO lt_items.

    ls_item-id = 'REQ-2'.
    ls_item-days_overdue = 200.
    APPEND ls_item TO lt_items.

    DATA(lv_json) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"bucket":4' )
      exp = -1 ).
  ENDMETHOD.

ENDCLASS.
