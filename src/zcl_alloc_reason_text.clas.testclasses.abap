CLASS ltcl_alloc_reason_text DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS every_reason_has_words FOR TESTING.
    METHODS a_full_line_says_nothing FOR TESTING.
    METHODS an_unknown_code_is_shown FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_reason_text IMPLEMENTATION.

  METHOD every_reason_has_words.

    cl_abap_unit_assert=>assert_not_initial(
      zcl_alloc_reason_text=>text( zif_allocation=>c_reason-no_stock ) ).
    cl_abap_unit_assert=>assert_not_initial(
      zcl_alloc_reason_text=>text( zif_allocation=>c_reason-supply_late ) ).
    cl_abap_unit_assert=>assert_not_initial(
      zcl_alloc_reason_text=>text( zif_allocation=>c_reason-customer_cap ) ).
    cl_abap_unit_assert=>assert_not_initial(
      zcl_alloc_reason_text=>text( zif_allocation=>c_reason-whole_units ) ).
    cl_abap_unit_assert=>assert_not_initial(
      zcl_alloc_reason_text=>text( zif_allocation=>c_reason-complete_only ) ).

  ENDMETHOD.

  METHOD a_full_line_says_nothing.

    cl_abap_unit_assert=>assert_initial(
      act = zcl_alloc_reason_text=>text( space )
      msg = 'a line that got everything has nothing to explain' ).

  ENDMETHOD.

  METHOD an_unknown_code_is_shown.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_reason_text=>text( 'Z' )
      exp = `Z`
      msg = 'a strategy of somebody own making may answer with its own code' ).

  ENDMETHOD.

ENDCLASS.
