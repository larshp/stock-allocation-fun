CLASS ltcl_alloc_prio_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prio_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_prio_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prio_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_items TYPE zcl_alloc_prio_csv=>ty_item_tt.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'REQUIREMENT_ID;DELIVERY_PRIORITY;DAYS_UNTIL_DUE;' &&
            'CUSTOMER_WEIGHT;SCORE' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_items TYPE zcl_alloc_prio_csv=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_prio_csv=>ty_item.

    ls_item-requirement_id = 'REQ-1'.
    ls_item-factors-delivery_priority = 5.
    ls_item-factors-days_until_due = 2.
    ls_item-factors-customer_weight = 0.
    APPEND ls_item TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;5;2;0;78' ).
  ENDMETHOD.

ENDCLASS.
