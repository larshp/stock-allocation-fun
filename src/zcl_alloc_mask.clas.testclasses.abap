CLASS ltcl_alloc_mask DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mask.

    METHODS setup.

    METHODS masks_all_text    FOR TESTING.
    METHODS keeps_prefix      FOR TESTING.
    METHODS keeps_suffix      FOR TESTING.
    METHODS keeps_both_ends   FOR TESTING.
    METHODS masks_email       FOR TESTING.
    METHODS email_without_at  FOR TESTING.
    METHODS masks_last_digits FOR TESTING.
    METHODS keeps_short_text  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_mask IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mask( ).
  ENDMETHOD.

  METHOD masks_all_text.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mask_text( 'ABCD1234' )
                                        exp = '********' ).
  ENDMETHOD.

  METHOD keeps_prefix.
    DATA lv_masked TYPE string.

    lv_masked = mo_cut->mask_text( iv_text = 'ABCD1234' iv_keep_prefix = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lv_masked exp = 'AB******' ).
  ENDMETHOD.

  METHOD keeps_suffix.
    DATA lv_masked TYPE string.

    lv_masked = mo_cut->mask_text( iv_text = 'ABCD1234' iv_keep_suffix = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lv_masked exp = '******34' ).
  ENDMETHOD.

  METHOD keeps_both_ends.
    DATA lv_masked TYPE string.

    lv_masked = mo_cut->mask_text( iv_text = 'ABCD1234' iv_keep_prefix = 3 iv_keep_suffix = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lv_masked exp = 'ABC***34' ).

    lv_masked = mo_cut->mask_text( iv_text = 'ABCD1234' iv_keep_prefix = 4 iv_keep_suffix = 4 ).

    cl_abap_unit_assert=>assert_equals( act = lv_masked exp = 'ABCD1234' ).
  ENDMETHOD.

  METHOD masks_email.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mask_email( 'john.doe@example.com' )
                                        exp = 'j*******@example.com' ).
  ENDMETHOD.

  METHOD email_without_at.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mask_email( 'noatsign' )
                                        exp = 'n*******' ).
  ENDMETHOD.

  METHOD masks_last_digits.
    DATA lv_masked TYPE string.

    lv_masked = mo_cut->mask_last_digits( '1234567890' ).

    cl_abap_unit_assert=>assert_equals( act = lv_masked exp = '******7890' ).

    lv_masked = mo_cut->mask_last_digits( iv_text = '1234567890' iv_keep_last = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lv_masked exp = '**********' ).
  ENDMETHOD.

  METHOD keeps_short_text.
    DATA lv_masked TYPE string.

    lv_masked = mo_cut->mask_last_digits( iv_text = '123' iv_keep_last = 4 ).

    cl_abap_unit_assert=>assert_equals( act = lv_masked exp = '123' ).
  ENDMETHOD.

ENDCLASS.
