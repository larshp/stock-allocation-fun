CLASS ltcl_reservation_reader DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr   TYPE mard-matnr VALUE 'RES-READER-01'.
    CONSTANTS c_matnr_2 TYPE mard-matnr VALUE 'RES-READER-02'.
    CONSTANTS c_werks   TYPE mard-werks VALUE '1000'.

    DATA mo_cut TYPE REF TO zif_reservation_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_item
      IMPORTING
        iv_rsnum   TYPE resb-rsnum
        iv_rspos   TYPE resb-rspos
        iv_matnr   TYPE resb-matnr DEFAULT c_matnr
        iv_werks   TYPE resb-werks DEFAULT c_werks
        iv_deleted TYPE abap_bool DEFAULT abap_false.

    METHODS reservation_is_reported FOR TESTING.
    METHODS deleted_item_is_not_live FOR TESTING.
    METHODS listed_once_per_reservation FOR TESTING.
    METHODS other_material_is_unaffected FOR TESTING.
    METHODS other_plant_is_unaffected FOR TESTING.
    METHODS nothing_reserved_is_empty FOR TESTING.

ENDCLASS.


CLASS ltcl_reservation_reader IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_reservation_reader( ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM resb WHERE matnr IN ( @c_matnr, @c_matnr_2 ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_item.

    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    lt_resb = VALUE #(
      ( mandt = sy-mandt
        rsnum = iv_rsnum
        rspos = iv_rspos
        matnr = iv_matnr
        werks = iv_werks
        bdmng = '5'
        xloek = COND #( WHEN iv_deleted = abap_true THEN 'X' ) ) ).

    INSERT resb FROM TABLE @lt_resb.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'reservation fixture could not be inserted' ).

  ENDMETHOD.

  METHOD reservation_is_reported.

    given_item(
      iv_rsnum = '0000005001'
      iv_rspos = '0001' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->live_reservations(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      exp = VALUE zif_reservation_reader=>ty_reservation_tab( ( '0000005001' ) ) ).

  ENDMETHOD.

  METHOD deleted_item_is_not_live.

    given_item(
      iv_rsnum   = '0000005002'
      iv_rspos   = '0001'
      iv_deleted = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->live_reservations(
        iv_matnr = c_matnr
        iv_werks = c_werks )
      msg = 'an item flagged for deletion holds nothing any more' ).

  ENDMETHOD.

  METHOD listed_once_per_reservation.

    given_item(
      iv_rsnum = '0000005003'
      iv_rspos = '0001' ).
    given_item(
      iv_rsnum = '0000005003'
      iv_rspos = '0002' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->live_reservations(
        iv_matnr = c_matnr
        iv_werks = c_werks ) )
      exp = 1
      msg = 'two items of one reservation are still one reservation' ).

  ENDMETHOD.

  METHOD other_material_is_unaffected.

    given_item(
      iv_rsnum = '0000005004'
      iv_rspos = '0001'
      iv_matnr = c_matnr_2 ).

    cl_abap_unit_assert=>assert_initial( mo_cut->live_reservations(
      iv_matnr = c_matnr
      iv_werks = c_werks ) ).

  ENDMETHOD.

  METHOD other_plant_is_unaffected.

    given_item(
      iv_rsnum = '0000005005'
      iv_rspos = '0001'
      iv_werks = '2000' ).

    cl_abap_unit_assert=>assert_initial( mo_cut->live_reservations(
      iv_matnr = c_matnr
      iv_werks = c_werks ) ).

  ENDMETHOD.

  METHOD nothing_reserved_is_empty.

    cl_abap_unit_assert=>assert_initial( mo_cut->live_reservations(
      iv_matnr = c_matnr
      iv_werks = c_werks ) ).

  ENDMETHOD.

ENDCLASS.
