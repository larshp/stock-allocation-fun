CLASS ltcl_alloc_penalty DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_penalty.
    DATA mt_dev TYPE zcl_alloc_penalty=>ty_deviation_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id     TYPE string
        iv_amount TYPE menge_d
        iv_weight TYPE menge_d.

    METHODS empty_penalty     FOR TESTING.
    METHODS weights_deviation FOR TESTING.
    METHODS negative_amount   FOR TESTING.
    METHODS tracks_worst      FOR TESTING.
    METHODS cap_limits_value  FOR TESTING.
    METHODS no_cap_keeps_all  FOR TESTING.
    METHODS counts_items      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_penalty IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_penalty( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_deviation TYPE zcl_alloc_penalty=>ty_deviation.

    ls_deviation-deviation_id = iv_id.
    ls_deviation-amount = iv_amount.
    ls_deviation-weight = iv_weight.
    APPEND ls_deviation TO mt_dev.
  ENDMETHOD.

  METHOD empty_penalty.
    DATA(ls_penalty) = mo_cut->calculate( it_deviations = mt_dev
                                          iv_cap        = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_penalty-total_penalty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_penalty-item_count exp = 0 ).
  ENDMETHOD.

  METHOD weights_deviation.
    add( iv_id = 'A' iv_amount = 4 iv_weight = 5 ).

    DATA(ls_penalty) = mo_cut->calculate( it_deviations = mt_dev
                                          iv_cap        = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_penalty-total_penalty exp = 20 ).
  ENDMETHOD.

  METHOD negative_amount.
    add( iv_id = 'A' iv_amount = -6 iv_weight = 2 ).

    DATA(ls_penalty) = mo_cut->calculate( it_deviations = mt_dev
                                          iv_cap        = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_penalty-total_penalty exp = 12 ).
  ENDMETHOD.

  METHOD tracks_worst.
    add( iv_id = 'SMALL' iv_amount = 1 iv_weight = 1 ).
    add( iv_id = 'BIG' iv_amount = 9 iv_weight = 3 ).

    DATA(ls_penalty) = mo_cut->calculate( it_deviations = mt_dev
                                          iv_cap        = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_penalty-worst_id exp = 'BIG' ).
    cl_abap_unit_assert=>assert_equals( act = ls_penalty-worst_penalty exp = 27 ).
    cl_abap_unit_assert=>assert_equals( act = ls_penalty-total_penalty exp = 28 ).
  ENDMETHOD.

  METHOD cap_limits_value.
    add( iv_id = 'A' iv_amount = 10 iv_weight = 10 ).

    DATA(ls_penalty) = mo_cut->calculate( it_deviations = mt_dev
                                          iv_cap        = 25 ).

    cl_abap_unit_assert=>assert_equals( act = ls_penalty-total_penalty exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = ls_penalty-worst_penalty exp = 25 ).
  ENDMETHOD.

  METHOD no_cap_keeps_all.
    add( iv_id = 'A' iv_amount = 10 iv_weight = 10 ).

    DATA(ls_penalty) = mo_cut->calculate( it_deviations = mt_dev
                                          iv_cap        = -1 ).

    cl_abap_unit_assert=>assert_equals( act = ls_penalty-total_penalty exp = 100 ).
  ENDMETHOD.

  METHOD counts_items.
    add( iv_id = 'A' iv_amount = 1 iv_weight = 1 ).
    add( iv_id = 'B' iv_amount = 1 iv_weight = 1 ).

    DATA(ls_penalty) = mo_cut->calculate( it_deviations = mt_dev
                                          iv_cap        = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_penalty-item_count exp = 2 ).
  ENDMETHOD.

ENDCLASS.
