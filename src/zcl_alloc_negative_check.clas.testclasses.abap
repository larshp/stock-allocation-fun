CLASS ltcl_alloc_negative_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_negative_check.

    METHODS setup.

    METHODS add
      IMPORTING
        it_rows        TYPE zcl_alloc_negative_check=>ty_row_tt
        iv_id          TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_quantity    TYPE menge_d
      RETURNING
        VALUE(rt_rows) TYPE zcl_alloc_negative_check=>ty_row_tt.

    METHODS empty_list       FOR TESTING.
    METHODS all_positive     FOR TESTING.
    METHODS one_negative     FOR TESTING.
    METHODS two_negatives    FOR TESTING.
    METHODS zero_is_not_neg  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_negative_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_negative_check( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_row TYPE zcl_alloc_negative_check=>ty_row.

    rt_rows = it_rows.
    ls_row-id = iv_id.
    ls_row-quantity = iv_quantity.
    APPEND ls_row TO rt_rows.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->find( lt_rows ) ).
  ENDMETHOD.

  METHOD all_positive.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.

    lt_rows = add( it_rows     = lt_rows
                   iv_id       = 'REQ-1'
                   iv_quantity = '10' ).
    lt_rows = add( it_rows     = lt_rows
                   iv_id       = 'REQ-2'
                   iv_quantity = '5' ).

    cl_abap_unit_assert=>assert_initial( act = mo_cut->find( lt_rows ) ).
  ENDMETHOD.

  METHOD one_negative.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.

    lt_rows = add( it_rows     = lt_rows
                   iv_id       = 'REQ-1'
                   iv_quantity = '-3' ).

    DATA(lt_bad) = mo_cut->find( lt_rows ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bad ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bad[ 1 ]-id exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_bad[ 1 ]-quantity exp = '-3' ).
  ENDMETHOD.

  METHOD two_negatives.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.

    lt_rows = add( it_rows     = lt_rows
                   iv_id       = 'REQ-1'
                   iv_quantity = '-3' ).
    lt_rows = add( it_rows     = lt_rows
                   iv_id       = 'REQ-2'
                   iv_quantity = '5' ).
    lt_rows = add( it_rows     = lt_rows
                   iv_id       = 'REQ-3'
                   iv_quantity = '-1' ).

    DATA(lt_bad) = mo_cut->find( lt_rows ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bad ) exp = 2 ).
  ENDMETHOD.

  METHOD zero_is_not_neg.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.

    lt_rows = add( it_rows     = lt_rows
                   iv_id       = 'REQ-1'
                   iv_quantity = '0' ).

    cl_abap_unit_assert=>assert_initial( act = mo_cut->find( lt_rows ) ).
  ENDMETHOD.

ENDCLASS.
