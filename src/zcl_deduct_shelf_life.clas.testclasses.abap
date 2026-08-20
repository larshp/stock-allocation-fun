CLASS ltcl_deduct_shelf_life DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'SHELF-LIFE-01'.
    CONSTANTS c_plain TYPE mard-matnr VALUE 'SHELF-LIFE-02'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_today TYPE d VALUE '20260301'.

    METHODS teardown.

    "! A batch managed material whose customers are owed IV_MIN_DAYS of shelf
    "! life when the goods arrive.
    METHODS given_material
      IMPORTING
        iv_matnr    TYPE mard-matnr DEFAULT c_matnr
        iv_batches  TYPE abap_bool DEFAULT abap_true
        iv_min_days TYPE mara-mhdrz DEFAULT 0.

    METHODS given_batch
      IMPORTING
        iv_charg    TYPE mchb-charg
        iv_quantity TYPE mchb-clabs
        iv_vfdat    TYPE mch1-vfdat DEFAULT '20260401'
        iv_matnr    TYPE mard-matnr DEFAULT c_matnr
        iv_deleted  TYPE abap_bool DEFAULT abap_false.

    METHODS deducted
      IMPORTING
        iv_matnr           TYPE mard-matnr DEFAULT c_matnr
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS an_expired_batch_is_out FOR TESTING.
    METHODS a_good_batch_is_left_alone FOR TESTING.
    METHODS expiring_inside_the_minimum FOR TESTING.
    METHODS the_last_good_day_still_counts FOR TESTING.
    METHODS an_undated_batch_is_kept FOR TESTING.
    METHODS a_deleted_batch_is_ignored FOR TESTING.
    METHODS batches_add_up FOR TESTING.
    METHODS a_plain_material_loses_nothing FOR TESTING.
    METHODS an_unknown_material_is_safe FOR TESTING.

ENDCLASS.


CLASS ltcl_deduct_shelf_life IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM mchb WHERE matnr IN ( @c_matnr, @c_plain ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mch1 WHERE matnr IN ( @c_matnr, @c_plain ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr IN ( @c_matnr, @c_plain ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_material.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt
        matnr = iv_matnr
        mtart = 'FERT'
        meins = 'PC'
        xchpf = COND #( WHEN iv_batches = abap_true THEN 'X' )
        mhdrz = iv_min_days ) ).

    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'material master fixture could not be inserted' ).

  ENDMETHOD.

  METHOD given_batch.

    DATA lt_mchb TYPE STANDARD TABLE OF mchb WITH EMPTY KEY.
    DATA lt_mch1 TYPE STANDARD TABLE OF mch1 WITH EMPTY KEY.

    lt_mchb = VALUE #(
      ( mandt = sy-mandt
        matnr = iv_matnr
        werks = c_werks
        lgort = '0001'
        charg = iv_charg
        clabs = iv_quantity
        lvorm = COND #( WHEN iv_deleted = abap_true THEN 'X' ) ) ).

    lt_mch1 = VALUE #(
      ( mandt = sy-mandt
        matnr = iv_matnr
        charg = iv_charg
        vfdat = iv_vfdat ) ).

    INSERT mchb FROM TABLE @lt_mchb.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'batch stock fixture could not be inserted' ).

    INSERT mch1 FROM TABLE @lt_mch1.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'batch fixture could not be inserted' ).

  ENDMETHOD.

  METHOD deducted.

    DATA(lo_cut) = CAST zif_stock_deduction( NEW zcl_deduct_shelf_life( c_today ) ).

    rv_quantity = lo_cut->quantity(
      iv_matnr = iv_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD an_expired_batch_is_out.

    given_material( ).
    given_batch(
      iv_charg    = 'B1'
      iv_quantity = '10'
      iv_vfdat    = '20260201' ).

    cl_abap_unit_assert=>assert_equals(
      act = deducted( )
      exp = '10'
      msg = 'stock that went off last month is in MARD and cannot be sold' ).

  ENDMETHOD.

  METHOD a_good_batch_is_left_alone.

    given_material( ).
    given_batch(
      iv_charg    = 'B1'
      iv_quantity = '10'
      iv_vfdat    = '20260401' ).

    cl_abap_unit_assert=>assert_equals(
      act = deducted( )
      exp = 0
      msg = 'a batch that is good for another month is stock like any other' ).

  ENDMETHOD.

  METHOD expiring_inside_the_minimum.

    " customers are owed sixty days of shelf life, and this batch has thirty
    given_material( iv_min_days = 60 ).
    given_batch(
      iv_charg    = 'B1'
      iv_quantity = '10'
      iv_vfdat    = '20260401' ).

    cl_abap_unit_assert=>assert_equals(
      act = deducted( )
      exp = '10'
      msg = 'a batch that may not be sent is not stock to promise' ).

  ENDMETHOD.

  METHOD the_last_good_day_still_counts.

    given_material( iv_min_days = 30 ).
    given_batch(
      iv_charg    = 'B1'
      iv_quantity = '10'
      iv_vfdat    = '20260402' ).

    cl_abap_unit_assert=>assert_equals(
      act = deducted( )
      exp = 0
      msg = 'a batch expiring after the minimum is still worth allocating' ).

  ENDMETHOD.

  METHOD an_undated_batch_is_kept.

    given_material( ).
    given_batch(
      iv_charg    = 'B1'
      iv_quantity = '10'
      iv_vfdat    = '00000000' ).

    cl_abap_unit_assert=>assert_equals(
      act = deducted( )
      exp = 0
      msg = 'a batch nobody dated has no expiry to fall foul of' ).

  ENDMETHOD.

  METHOD a_deleted_batch_is_ignored.

    given_material( ).
    given_batch(
      iv_charg    = 'B1'
      iv_quantity = '10'
      iv_vfdat    = '20260201'
      iv_deleted  = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = deducted( )
      exp = 0
      msg = 'a deleted batch stock row is not in MARD either, so nothing is owed' ).

  ENDMETHOD.

  METHOD batches_add_up.

    given_material( ).
    given_batch(
      iv_charg    = 'B1'
      iv_quantity = '10'
      iv_vfdat    = '20260201' ).
    given_batch(
      iv_charg    = 'B2'
      iv_quantity = '4'
      iv_vfdat    = '20260228' ).
    given_batch(
      iv_charg    = 'B3'
      iv_quantity = '7'
      iv_vfdat    = '20261231' ).

    cl_abap_unit_assert=>assert_equals(
      act = deducted( )
      exp = '14'
      msg = 'every batch that cannot be sent counts, and the good one does not' ).

  ENDMETHOD.

  METHOD a_plain_material_loses_nothing.

    given_material(
      iv_matnr   = c_plain
      iv_batches = abap_false ).
    given_batch(
      iv_charg    = 'B1'
      iv_quantity = '10'
      iv_vfdat    = '20260201'
      iv_matnr    = c_plain ).

    cl_abap_unit_assert=>assert_equals(
      act = deducted( c_plain )
      exp = 0
      msg = 'a material without batch management has no expiry dates to read' ).

  ENDMETHOD.

  METHOD an_unknown_material_is_safe.

    cl_abap_unit_assert=>assert_equals(
      act = deducted( )
      exp = 0
      msg = 'a material nobody has heard of loses nothing rather than everything' ).

  ENDMETHOD.

ENDCLASS.
