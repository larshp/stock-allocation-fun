CLASS ltcl_alloc_receipt_net DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_receipt_net.
    DATA mt_rec TYPE zcl_alloc_receipt_net=>ty_values_tt.
    DATA mt_dem TYPE zcl_alloc_receipt_net=>ty_values_tt.

    METHODS setup.

    METHODS add_receipt
      IMPORTING
        iv_value TYPE i.

    METHODS add_demand
      IMPORTING
        iv_value TYPE i.

    METHODS sums_receipts FOR TESTING.
    METHODS sums_demands  FOR TESTING.
    METHODS nets_position FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_receipt_net IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_receipt_net( ).
  ENDMETHOD.

  METHOD add_receipt.
    APPEND iv_value TO mt_rec.
  ENDMETHOD.

  METHOD add_demand.
    APPEND iv_value TO mt_dem.
  ENDMETHOD.

  METHOD sums_receipts.
    add_receipt( 50 ).
    add_receipt( 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->receipt_total( mt_rec ) exp = 150 ).
  ENDMETHOD.

  METHOD sums_demands.
    add_demand( 30 ).
    add_demand( 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->demand_total( mt_dem ) exp = 70 ).
  ENDMETHOD.

  METHOD nets_position.
    add_receipt( 50 ).
    add_receipt( 100 ).
    add_demand( 30 ).
    add_demand( 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->net( it_receipts = mt_rec it_demands = mt_dem )
      exp = 80 ).
  ENDMETHOD.

ENDCLASS.
