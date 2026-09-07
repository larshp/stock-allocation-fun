CLASS ltcl_stock_reader DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'STOCK-READER-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_cut TYPE REF TO zif_stock_reader.

    METHODS setup.
    METHODS teardown.
    METHODS returns_one_line_per_lgort FOR TESTING.
    METHODS skips_deleted_locations FOR TESTING.
    METHODS unknown_material_is_empty FOR TESTING.

ENDCLASS.


CLASS ltcl_stock_reader IMPLEMENTATION.

  METHOD setup.

    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.

    mo_cut = NEW zcl_stock_reader( ).

    lt_mard = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_werks lgort = '0001' labst = '10' )
      ( mandt = sy-mandt matnr = c_matnr werks = c_werks lgort = '0002' labst = '5' )
      ( mandt = sy-mandt matnr = c_matnr werks = c_werks lgort = '0003' labst = '7' lvorm = 'X' )
      ( mandt = sy-mandt matnr = c_matnr werks = '2000' lgort = '0001' labst = '99' ) ).

    INSERT mard FROM TABLE @lt_mard.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'test fixture could not be inserted' ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM mard WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'test fixture could not be removed' ).

  ENDMETHOD.

  METHOD returns_one_line_per_lgort.

    DATA(lt_stock) = mo_cut->read_available_stock(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_stock )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_stock[ 1 ]-lgort
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_stock[ 1 ]-available
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_stock[ 2 ]-lgort
      exp = '0002' ).

  ENDMETHOD.

  METHOD skips_deleted_locations.

    DATA(lt_stock) = mo_cut->read_available_stock(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_not_initial( lt_stock ).
    LOOP AT lt_stock INTO DATA(ls_stock).
      cl_abap_unit_assert=>assert_differs(
        act = ls_stock-lgort
        exp = '0003'
        msg = 'storage location flagged for deletion must not be returned' ).
    ENDLOOP.

  ENDMETHOD.

  METHOD unknown_material_is_empty.

    DATA(lt_stock) = mo_cut->read_available_stock(
      iv_matnr = 'DOES-NOT-EXIST'
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_initial( lt_stock ).

  ENDMETHOD.

ENDCLASS.
