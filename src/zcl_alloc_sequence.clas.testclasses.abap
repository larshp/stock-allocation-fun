CLASS ltcl_alloc_sequence DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sequence.

    METHODS setup.

    METHODS row
      IMPORTING
        iv_charg      TYPE c
        iv_gr_date    TYPE d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_sequence=>ty_row.

    METHODS empty_list     FOR TESTING.
    METHODS fifo_order     FOR TESTING.
    METHODS lifo_order     FOR TESTING.
    METHODS unknown_last_fifo FOR TESTING.
    METHODS unknown_last_lifo FOR TESTING.
    METHODS default_is_fifo FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_sequence IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sequence( ).
  ENDMETHOD.

  METHOD row.
    rs_row-lgort = '0001'.
    rs_row-charg = iv_charg.
    rs_row-gr_date = iv_gr_date.
    rs_row-quantity = '10'.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_rows TYPE zcl_alloc_sequence=>ty_row_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->order( lt_rows ) ).
  ENDMETHOD.

  METHOD fifo_order.
    DATA lt_rows TYPE zcl_alloc_sequence=>ty_row_tt.

    APPEND row( iv_charg = 'B' iv_gr_date = '20260301' ) TO lt_rows.
    APPEND row( iv_charg = 'A' iv_gr_date = '20260101' ) TO lt_rows.

    DATA(lt_sorted) = mo_cut->order( it_rows = lt_rows
                                     iv_mode = 'F' ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-charg exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 2 ]-charg exp = 'B' ).
  ENDMETHOD.

  METHOD lifo_order.
    DATA lt_rows TYPE zcl_alloc_sequence=>ty_row_tt.

    APPEND row( iv_charg = 'A' iv_gr_date = '20260101' ) TO lt_rows.
    APPEND row( iv_charg = 'B' iv_gr_date = '20260301' ) TO lt_rows.

    DATA(lt_sorted) = mo_cut->order( it_rows = lt_rows
                                     iv_mode = 'L' ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-charg exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 2 ]-charg exp = 'A' ).
  ENDMETHOD.

  METHOD unknown_last_fifo.
    DATA lt_rows TYPE zcl_alloc_sequence=>ty_row_tt.

    APPEND row( iv_charg = 'C' iv_gr_date = '00000000' ) TO lt_rows.
    APPEND row( iv_charg = 'A' iv_gr_date = '20260101' ) TO lt_rows.

    DATA(lt_sorted) = mo_cut->order( it_rows = lt_rows
                                     iv_mode = 'F' ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-charg exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 2 ]-charg exp = 'C' ).
  ENDMETHOD.

  METHOD unknown_last_lifo.
    DATA lt_rows TYPE zcl_alloc_sequence=>ty_row_tt.

    APPEND row( iv_charg = 'C' iv_gr_date = '00000000' ) TO lt_rows.
    APPEND row( iv_charg = 'B' iv_gr_date = '20260301' ) TO lt_rows.

    DATA(lt_sorted) = mo_cut->order( it_rows = lt_rows
                                     iv_mode = 'L' ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-charg exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 2 ]-charg exp = 'C' ).
  ENDMETHOD.

  METHOD default_is_fifo.
    DATA lt_rows TYPE zcl_alloc_sequence=>ty_row_tt.

    APPEND row( iv_charg = 'B' iv_gr_date = '20260301' ) TO lt_rows.
    APPEND row( iv_charg = 'A' iv_gr_date = '20260101' ) TO lt_rows.

    DATA(lt_sorted) = mo_cut->order( lt_rows ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-charg exp = 'A' ).
  ENDMETHOD.

ENDCLASS.
