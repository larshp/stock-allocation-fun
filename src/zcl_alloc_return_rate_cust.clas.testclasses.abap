CLASS ltcl_alloc_return_rate_cust DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_rate_cust.
    DATA mt_cus TYPE zcl_alloc_return_rate_cust=>ty_customer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_customer TYPE string
        iv_shipped  TYPE i
        iv_returned TYPE i.

    METHODS cust
      IMPORTING
        iv_customer        TYPE string
        iv_shipped         TYPE i
        iv_returned        TYPE i
      RETURNING
        VALUE(rs_customer) TYPE zcl_alloc_return_rate_cust=>ty_customer.

    METHODS computes_rate  FOR TESTING.
    METHODS finds_highest  FOR TESTING.
    METHODS ranks_worst     FOR TESTING.
    METHODS skips_unshipped FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_rate_cust IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_rate_cust( ).
  ENDMETHOD.

  METHOD add.
    APPEND cust( iv_customer = iv_customer iv_shipped = iv_shipped
                 iv_returned = iv_returned ) TO mt_cus.
  ENDMETHOD.

  METHOD cust.
    rs_customer-customer = iv_customer.
    rs_customer-shipped = iv_shipped.
    rs_customer-returned = iv_returned.
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( cust( iv_customer = 'C1' iv_shipped = 100
                                iv_returned = 10 ) )
      exp = 10 ).
  ENDMETHOD.

  METHOD finds_highest.
    add( iv_customer = 'C1' iv_shipped = 100 iv_returned = 10 ).
    add( iv_customer = 'C2' iv_shipped = 100 iv_returned = 25 ).
    add( iv_customer = 'C3' iv_shipped = 0 iv_returned = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->highest( mt_cus ) exp = 'C2' ).
  ENDMETHOD.

  METHOD ranks_worst.
    DATA lt_ranked TYPE zcl_alloc_return_rate_cust=>ty_ranked_tt.

    add( iv_customer = 'C1' iv_shipped = 100 iv_returned = 10 ).
    add( iv_customer = 'C2' iv_shipped = 100 iv_returned = 25 ).
    add( iv_customer = 'C3' iv_shipped = 0 iv_returned = 5 ).

    lt_ranked = mo_cut->rank( mt_cus ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_ranked ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ranked[ 1 ]-customer exp = 'C2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ranked[ 2 ]-customer exp = 'C1' ).
  ENDMETHOD.

  METHOD skips_unshipped.
    add( iv_customer = 'C3' iv_shipped = 0 iv_returned = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->highest( mt_cus ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
