CLASS ltcl_allocation_time_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS accepts_valid_times FOR TESTING.
    METHODS accepts_initial_time FOR TESTING.
    METHODS rejects_invalid_times FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_time_sap IMPLEMENTATION.
  METHOD accepts_valid_times.
    DATA lv_time TYPE t.

    lv_time = '000000'.
    cl_abap_unit_assert=>assert_true(
      zcl_allocation_time_sap=>is_valid_or_initial( lv_time ) ).
    lv_time = '235959'.
    cl_abap_unit_assert=>assert_true(
      zcl_allocation_time_sap=>is_valid_or_initial( lv_time ) ).
  ENDMETHOD.

  METHOD accepts_initial_time.
    DATA lv_time TYPE t.

    cl_abap_unit_assert=>assert_true(
      zcl_allocation_time_sap=>is_valid_or_initial( lv_time ) ).
  ENDMETHOD.

  METHOD rejects_invalid_times.
    DATA lv_time TYPE t.

    lv_time = '240000'.
    cl_abap_unit_assert=>assert_false(
      zcl_allocation_time_sap=>is_valid_or_initial( lv_time ) ).
    lv_time = '126060'.
    cl_abap_unit_assert=>assert_false(
      zcl_allocation_time_sap=>is_valid_or_initial( lv_time ) ).
    lv_time = '12AB00'.
    cl_abap_unit_assert=>assert_false(
      zcl_allocation_time_sap=>is_valid_or_initial( lv_time ) ).
  ENDMETHOD.
ENDCLASS.
