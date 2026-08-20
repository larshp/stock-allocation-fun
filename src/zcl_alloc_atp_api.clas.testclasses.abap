CLASS ltcl_alloc_atp_api DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'ATP-API-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9301'.

    METHODS teardown.

    METHODS given_stock
      IMPORTING
        iv_quantity TYPE mard-labst
        iv_lgort    TYPE mard-lgort DEFAULT '0001'.

    METHODS what_is_there_is_promised FOR TESTING.
    METHODS an_empty_plant_says_nothing FOR TESTING.
    METHODS more_than_there_is_is_partial FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_atp_api IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM mard WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_stock.

    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.

    lt_mard = VALUE #(
      ( mandt = sy-mandt
        matnr = c_matnr
        werks = c_werks
        lgort = iv_lgort
        labst = iv_quantity ) ).

    INSERT mard FROM TABLE @lt_mard.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'stock fixture could not be inserted' ).

  ENDMETHOD.

  METHOD what_is_there_is_promised.

    given_stock( '25' ).

    DATA(ls_answer) = zcl_alloc_atp_api=>promise(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_answer-promise-quantity
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_answer-promise-complete
      exp = abap_true ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_answer-message
      msg = 'an answer and a message are never both there' ).

  ENDMETHOD.

  METHOD an_empty_plant_says_nothing.

    DATA(ls_answer) = zcl_alloc_atp_api=>promise(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = '10' ).

    cl_abap_unit_assert=>assert_initial(
      act = ls_answer-promise
      msg = 'nothing to promise is not an error, it is an answer' ).
    cl_abap_unit_assert=>assert_initial( ls_answer-message ).

  ENDMETHOD.

  METHOD more_than_there_is_is_partial.

    given_stock( '4' ).

    DATA(ls_answer) = zcl_alloc_atp_api=>promise(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_answer-promise-quantity
      exp = '4' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_answer-promise-complete
      exp = abap_false
      msg = 'a caller has to be able to tell a part answer from a whole one' ).

  ENDMETHOD.

ENDCLASS.
