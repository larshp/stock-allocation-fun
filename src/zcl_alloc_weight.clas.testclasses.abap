CLASS ltcl_alloc_weight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_weight.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_factor     TYPE i
        iv_weight     TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_weight=>ty_item.

    METHODS empty_list   FOR TESTING.
    METHODS single_item  FOR TESTING.
    METHODS equal_weights FOR TESTING.
    METHODS weighted_avg FOR TESTING.
    METHODS zero_weight  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_weight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_weight( ).
  ENDMETHOD.

  METHOD item.
    rs_row-factor = iv_factor.
    rs_row-weight = iv_weight.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_weight=>ty_item_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->score( lt_items )
                                        exp = 0 ).
  ENDMETHOD.

  METHOD single_item.
    DATA lt_items TYPE zcl_alloc_weight=>ty_item_tt.

    APPEND item( iv_factor = 80 iv_weight = 1 ) TO lt_items.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->score( lt_items )
                                        exp = 80 ).
  ENDMETHOD.

  METHOD equal_weights.
    DATA lt_items TYPE zcl_alloc_weight=>ty_item_tt.

    APPEND item( iv_factor = 10 iv_weight = 1 ) TO lt_items.
    APPEND item( iv_factor = 20 iv_weight = 1 ) TO lt_items.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->score( lt_items )
                                        exp = 15 ).
  ENDMETHOD.

  METHOD weighted_avg.
    DATA lt_items TYPE zcl_alloc_weight=>ty_item_tt.

    APPEND item( iv_factor = 10 iv_weight = 3 ) TO lt_items.
    APPEND item( iv_factor = 30 iv_weight = 1 ) TO lt_items.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->score( lt_items )
                                        exp = 15 ).
  ENDMETHOD.

  METHOD zero_weight.
    DATA lt_items TYPE zcl_alloc_weight=>ty_item_tt.

    APPEND item( iv_factor = 10 iv_weight = 0 ) TO lt_items.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->score( lt_items )
                                        exp = 0 ).
  ENDMETHOD.

ENDCLASS.
