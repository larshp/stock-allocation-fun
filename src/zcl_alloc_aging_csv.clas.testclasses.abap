CLASS ltcl_alloc_aging_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_aging_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS current_row FOR TESTING.
    METHODS oldest_row  FOR TESTING.
    METHODS two_rows    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_aging_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_aging_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_items TYPE zcl_alloc_aging_csv=>ty_item_tt.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'ID;DAYS_OVERDUE;BUCKET' ).
  ENDMETHOD.

  METHOD current_row.
    DATA lt_items TYPE zcl_alloc_aging_csv=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_aging_csv=>ty_item.

    ls_item-id = 'REQ-1'.
    ls_item-days_overdue = 5.
    APPEND ls_item TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;5;1' ).
  ENDMETHOD.

  METHOD oldest_row.
    DATA lt_items TYPE zcl_alloc_aging_csv=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_aging_csv=>ty_item.

    ls_item-id = 'REQ-2'.
    ls_item-days_overdue = 120.
    APPEND ls_item TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-2;120;4' ).
  ENDMETHOD.

  METHOD two_rows.
    DATA lt_items TYPE zcl_alloc_aging_csv=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_aging_csv=>ty_item.

    ls_item-id = 'REQ-1'.
    ls_item-days_overdue = -3.
    APPEND ls_item TO lt_items.

    ls_item-id = 'REQ-2'.
    ls_item-days_overdue = 45.
    APPEND ls_item TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;-3;0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'REQ-2;45;2' ).
  ENDMETHOD.

ENDCLASS.
