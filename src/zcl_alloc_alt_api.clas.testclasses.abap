CLASS ltcl_alloc_alt_api DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9651'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'ALT-MAT-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'ALT-MAT-02'.

    METHODS setup.
    METHODS teardown.

    METHODS given_substitute
      IMPORTING
        iv_factor TYPE zif_allocation=>ty_quantity DEFAULT 1.

    METHODS given_stock
      IMPORTING
        iv_quantity TYPE mard-labst.

    METHODS nothing_named_is_no_answer FOR TESTING.
    METHODS a_substitute_is_asked FOR TESTING.
    METHODS the_factor_is_applied FOR TESTING.
    METHODS the_note_comes_with_it FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_alt_api IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_other mtart = 'FERT' meins = 'PC' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_sub WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM mard WHERE matnr = @c_other.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM mara WHERE matnr = @c_other.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_substitute.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_sub WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        werks      = c_werks
        matnr      = c_matnr
        substitute = c_other
        factor     = iv_factor
        note       = 'the customer has taken it before' ) ).

    INSERT zstock_alloc_sub FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD given_stock.

    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.

    lt_mard = VALUE #(
      ( mandt = sy-mandt matnr = c_other werks = c_werks
        lgort = '0001' labst = iv_quantity ) ).
    INSERT mard FROM TABLE @lt_mard.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD nothing_named_is_no_answer.

    cl_abap_unit_assert=>assert_initial(
      act = zcl_alloc_alt_api=>alternatives(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = 10 )
      msg = 'a plant that has named no substitute has no alternative to offer' ).

  ENDMETHOD.

  METHOD a_substitute_is_asked.

    given_substitute( ).
    given_stock( 40 ).

    DATA(lt_answer) = zcl_alloc_alt_api=>alternatives(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_answer )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_answer[ 1 ]-quantity
      exp = CONV zstock_alloc_promise-quantity( 10 )
      msg = 'what the substitute can promise is the same question as before' ).

  ENDMETHOD.

  METHOD the_factor_is_applied.

    " two of the substitute make one of the material, so twenty are wanted
    " and only fifteen are there
    given_substitute( 2 ).
    given_stock( 15 ).

    DATA(lt_answer) = zcl_alloc_alt_api=>alternatives(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_answer[ 1 ]-quantity
      exp = CONV zstock_alloc_promise-quantity( 15 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_answer[ 1 ]-complete
      exp = abap_false
      msg = 'a factor nobody applied would promise half of what is needed' ).

  ENDMETHOD.

  METHOD the_note_comes_with_it.

    given_substitute( ).
    given_stock( 40 ).

    DATA(lt_answer) = zcl_alloc_alt_api=>alternatives(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = 10 ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_answer[ 1 ]-note
      exp = '*taken it before*'
      msg = 'whoever is about to offer it needs to know what the plant knows' ).

  ENDMETHOD.

ENDCLASS.
