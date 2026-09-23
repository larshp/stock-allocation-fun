CLASS ltcl_stock_batch_eligibility DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_stock_batch_eligibility.
    METHODS setup.
    METHODS accepts_minimum_date FOR TESTING.
    METHODS rejects_expired_batch FOR TESTING.
    METHODS rejects_short_shelf_life FOR TESTING.
    METHODS allows_undated_without_min FOR TESTING.
    METHODS rejects_undated_with_min FOR TESTING.
    METHODS rejects_invalid_date FOR TESTING.
    METHODS rejects_negative_min_days FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_batch_eligibility IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW zcl_stock_batch_eligibility( ).
  ENDMETHOD.

  METHOD accepts_minimum_date.
    DATA(lv_eligible) = mo_cut->is_eligible(
      iv_expiration_date = '20260930'
      iv_as_of_date      = '20260923'
      iv_min_days        = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_eligible ).
  ENDMETHOD.

  METHOD rejects_expired_batch.
    DATA(lv_eligible) = mo_cut->is_eligible(
      iv_expiration_date = '20260922'
      iv_as_of_date      = '20260923'
      iv_min_days        = 0 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lv_eligible ).
  ENDMETHOD.

  METHOD rejects_short_shelf_life.
    DATA(lv_eligible) = mo_cut->is_eligible(
      iv_expiration_date = '20260929'
      iv_as_of_date      = '20260923'
      iv_min_days        = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lv_eligible ).
  ENDMETHOD.

  METHOD allows_undated_without_min.
    DATA lv_expiration_date TYPE d.

    DATA(lv_eligible) = mo_cut->is_eligible(
      iv_expiration_date = lv_expiration_date
      iv_as_of_date      = '20260923'
      iv_min_days        = 0 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_eligible ).
  ENDMETHOD.

  METHOD rejects_undated_with_min.
    DATA lv_expiration_date TYPE d.

    DATA(lv_eligible) = mo_cut->is_eligible(
      iv_expiration_date = lv_expiration_date
      iv_as_of_date      = '20260923'
      iv_min_days        = 1 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lv_eligible ).
  ENDMETHOD.

  METHOD rejects_invalid_date.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->is_eligible(
          iv_expiration_date = '20260930'
          iv_as_of_date      = '00000000'
          iv_min_days        = 0 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
  ENDMETHOD.

  METHOD rejects_negative_min_days.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->is_eligible(
          iv_expiration_date = '20260930'
          iv_as_of_date      = '20260923'
          iv_min_days        = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
  ENDMETHOD.
ENDCLASS.
