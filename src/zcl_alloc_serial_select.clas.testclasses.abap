CLASS ltcl_alloc_serial_select DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_serial_select.
    DATA mt_ser TYPE zcl_alloc_serial_select=>ty_int_tt.

    METHODS setup.

    METHODS takes_in_order  FOR TESTING.
    METHODS stops_at_qty   FOR TESTING.
    METHODS zero_quantity  FOR TESTING.
    METHODS shortfall_read FOR TESTING.
    METHODS no_shortfall   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_serial_select IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_serial_select( ).
    APPEND 10 TO mt_ser.
    APPEND 20 TO mt_ser.
    APPEND 30 TO mt_ser.
  ENDMETHOD.

  METHOD takes_in_order.
    DATA lt_sel TYPE zcl_alloc_serial_select=>ty_int_tt.

    lt_sel = mo_cut->select( it_serials = mt_ser iv_quantity = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sel ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sel[ 1 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sel[ 2 ] exp = 20 ).
  ENDMETHOD.

  METHOD stops_at_qty.
    DATA lt_sel TYPE zcl_alloc_serial_select=>ty_int_tt.

    lt_sel = mo_cut->select( it_serials = mt_ser iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sel ) exp = 3 ).
  ENDMETHOD.

  METHOD zero_quantity.
    DATA lt_sel TYPE zcl_alloc_serial_select=>ty_int_tt.

    lt_sel = mo_cut->select( it_serials = mt_ser iv_quantity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sel ) exp = 0 ).
  ENDMETHOD.

  METHOD shortfall_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( it_serials = mt_ser iv_quantity = 5 )
      exp = 2 ).
  ENDMETHOD.

  METHOD no_shortfall.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( it_serials = mt_ser iv_quantity = 3 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
