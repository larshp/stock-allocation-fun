CLASS ltcl_alloc_priority DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_priority.

    METHODS setup.

    METHODS factors
      IMPORTING
        iv_delivery   TYPE i
        iv_days       TYPE i
        iv_weight     TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_priority=>ty_factors.

    METHODS high_and_urgent  FOR TESTING.
    METHODS far_due          FOR TESTING.
    METHODS due_today        FOR TESTING.
    METHODS customer_weight  FOR TESTING.
    METHODS all_zero         FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_priority IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_priority( ).
  ENDMETHOD.

  METHOD factors.
    rs_row-delivery_priority = iv_delivery.
    rs_row-days_until_due = iv_days.
    rs_row-customer_weight = iv_weight.
  ENDMETHOD.

  METHOD high_and_urgent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( factors( iv_delivery = 5
                                    iv_days     = 2
                                    iv_weight   = 0 ) )
      exp = 78 ).
  ENDMETHOD.

  METHOD far_due.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( factors( iv_delivery = 1
                                    iv_days     = 60
                                    iv_weight   = 0 ) )
      exp = 10 ).
  ENDMETHOD.

  METHOD due_today.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( factors( iv_delivery = 2
                                    iv_days     = 0
                                    iv_weight   = 0 ) )
      exp = 20 ).
  ENDMETHOD.

  METHOD customer_weight.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( factors( iv_delivery = 1
                                    iv_days     = 60
                                    iv_weight   = 20 ) )
      exp = 30 ).
  ENDMETHOD.

  METHOD all_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( factors( iv_delivery = 0
                                    iv_days     = 0
                                    iv_weight   = 0 ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
