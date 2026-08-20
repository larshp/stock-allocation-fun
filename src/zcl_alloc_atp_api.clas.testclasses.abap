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
    METHODS every_line_gets_an_answer FOR TESTING.
    METHODS the_lines_keep_their_numbers FOR TESTING.
    METHODS a_line_that_fails_says_so FOR TESTING.
    METHODS no_lines_is_no_answer FOR TESTING.

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

  METHOD every_line_gets_an_answer.

    given_stock( '25' ).

    DATA(lt_answer) = zcl_alloc_atp_api=>promises( VALUE #(
      ( item_no = '000010' material = c_matnr plant = c_werks quantity = '10' )
      ( item_no = '000020' material = c_matnr plant = c_werks quantity = '100' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_answer )
      exp = 2
      msg = 'a basket is answered in one call, not one round trip per line' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_answer[ 1 ]-complete
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_answer[ 2 ]-quantity
      exp = '25'
      msg = 'and each line is answered on its own merits' ).

  ENDMETHOD.

  METHOD the_lines_keep_their_numbers.

    given_stock( '25' ).

    DATA(lt_answer) = zcl_alloc_atp_api=>promises( VALUE #(
      ( item_no = '000030' material = c_matnr plant = c_werks quantity = '1' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_answer[ 1 ]-item_no
      exp = '000030'
      msg = 'the caller has to be able to tell which line it is reading' ).

  ENDMETHOD.

  METHOD a_line_that_fails_says_so.

    " no stock anywhere, and a plant the caller may not see is the same shape
    " of problem: the line carries the reason and the rest are still answered
    DATA(lt_answer) = zcl_alloc_atp_api=>promises( VALUE #(
      ( item_no = '000010' material = c_matnr plant = c_werks quantity = '5' ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_answer[ 1 ]-message
      msg = 'nothing to promise is an answer, not a failure' ).
    cl_abap_unit_assert=>assert_initial( lt_answer[ 1 ]-quantity ).

  ENDMETHOD.

  METHOD no_lines_is_no_answer.

    cl_abap_unit_assert=>assert_initial(
      act = zcl_alloc_atp_api=>promises( VALUE #( ) )
      msg = 'a caller that asked nothing is told nothing' ).

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
