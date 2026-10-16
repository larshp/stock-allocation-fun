CLASS ltcl_alloc_prio_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prio_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_prio_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prio_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_prio_json=>ty_item_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_items )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_items TYPE zcl_alloc_prio_json=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_prio_json=>ty_item.

    ls_item-requirement_id = 'REQ-1'.
    ls_item-factors-delivery_priority = 5.
    ls_item-factors-days_until_due = 2.
    ls_item-factors-customer_weight = 0.
    APPEND ls_item TO lt_items.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_items )
      exp = '[{"requirement_id":"REQ-1","delivery_priority":5,' &&
            '"days_until_due":2,"customer_weight":0,"score":78}]' ).
  ENDMETHOD.

ENDCLASS.
