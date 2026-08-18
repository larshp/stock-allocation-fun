CLASS ltcl_allocation_date_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS accepts_valid_dates FOR TESTING.
    METHODS accepts_initial_date FOR TESTING.
    METHODS rejects_invalid_dates FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_date_sap IMPLEMENTATION.
  METHOD accepts_valid_dates.
    DATA lv_date TYPE d.

    lv_date = '20260228'.
    cl_abap_unit_assert=>assert_true(
      zcl_allocation_date_sap=>is_valid_or_initial( lv_date ) ).
    lv_date = '20240229'.
    cl_abap_unit_assert=>assert_true(
      zcl_allocation_date_sap=>is_valid_or_initial( lv_date ) ).
    lv_date = '20261231'.
    cl_abap_unit_assert=>assert_true(
      zcl_allocation_date_sap=>is_valid_or_initial( lv_date ) ).
  ENDMETHOD.

  METHOD accepts_initial_date.
    DATA lv_date TYPE d.

    cl_abap_unit_assert=>assert_true(
      zcl_allocation_date_sap=>is_valid_or_initial( lv_date ) ).
  ENDMETHOD.

  METHOD rejects_invalid_dates.
    DATA lv_date TYPE d.

    lv_date = '20260230'.
    cl_abap_unit_assert=>assert_false(
      zcl_allocation_date_sap=>is_valid_or_initial( lv_date ) ).
    lv_date = '20261301'.
    cl_abap_unit_assert=>assert_false(
      zcl_allocation_date_sap=>is_valid_or_initial( lv_date ) ).
    lv_date = '2026AB01'.
    cl_abap_unit_assert=>assert_false(
      zcl_allocation_date_sap=>is_valid_or_initial( lv_date ) ).
  ENDMETHOD.
ENDCLASS.
