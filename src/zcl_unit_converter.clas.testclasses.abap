CLASS ltcl_unit_converter DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'CONVERT-TEST-01'.

    TYPES ty_mara_tab TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    TYPES ty_marm_tab TYPE STANDARD TABLE OF marm WITH EMPTY KEY.

    DATA mo_cut TYPE REF TO zif_unit_converter.

    METHODS setup.
    METHODS teardown.

    METHODS given_material
      IMPORTING
        iv_base TYPE mara-meins
        it_marm TYPE ty_marm_tab OPTIONAL.

    METHODS base_unit_is_unchanged FOR TESTING RAISING cx_static_check.
    METHODS the_base_unit_can_be_asked FOR TESTING RAISING cx_static_check.
    METHODS no_material_has_no_unit FOR TESTING.
    METHODS alternative_unit_is_scaled FOR TESTING RAISING cx_static_check.
    METHODS fraction_keeps_decimals FOR TESTING RAISING cx_static_check.
    METHODS unknown_unit_is_refused FOR TESTING.
    METHODS unknown_material_is_refused FOR TESTING.
    METHODS zero_denominator_is_refused FOR TESTING.
    METHODS zero_numerator_is_refused FOR TESTING.
    METHODS back_to_the_base_is_unchanged FOR TESTING RAISING cx_static_check.
    METHODS back_to_the_sales_unit FOR TESTING RAISING cx_static_check.
    METHODS back_keeps_the_fraction FOR TESTING RAISING cx_static_check.
    METHODS back_and_forth_is_the_same FOR TESTING RAISING cx_static_check.
    METHODS back_refuses_an_unknown_unit FOR TESTING.
    METHODS master_data_is_read_once FOR TESTING RAISING cx_static_check.
    METHODS another_converter_reads_again FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_converter IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_unit_converter( ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_material.

    DATA lt_mara TYPE ty_mara_tab.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = iv_base ) ).

    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'material master fixture could not be inserted' ).

    IF it_marm IS NOT INITIAL.
      INSERT marm FROM TABLE @it_marm.
      cl_abap_unit_assert=>assert_equals(
        act = sy-subrc
        exp = 0
        msg = 'unit of measure fixture could not be inserted' ).
    ENDIF.

  ENDMETHOD.

  METHOD base_unit_is_unchanged.

    given_material( 'PC' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base(
        iv_matnr    = c_matnr
        iv_quantity = '7.5'
        iv_uom      = 'PC' )
      exp = '7.5' ).

  ENDMETHOD.

  METHOD alternative_unit_is_scaled.

    " one carton is twelve pieces
    given_material(
      iv_base = 'PC'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 12 umren = 1 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base(
        iv_matnr    = c_matnr
        iv_quantity = '3'
        iv_uom      = 'CAR' )
      exp = '36'
      msg = 'three cartons of twelve are thirty six pieces, not three' ).

  ENDMETHOD.

  METHOD fraction_keeps_decimals.

    " one box is 2.5 kilogram, expressed as 5 / 2
    given_material(
      iv_base = 'KG'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'BOX' umrez = 5 umren = 2 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base(
        iv_matnr    = c_matnr
        iv_quantity = '3'
        iv_uom      = 'BOX' )
      exp = '7.5'
      msg = 'the conversion must not round the quantity to whole units' ).

  ENDMETHOD.

  METHOD unknown_unit_is_refused.

    given_material( 'PC' ).

    TRY.
        mo_cut->to_base(
          iv_matnr    = c_matnr
          iv_quantity = '3'
          iv_uom      = 'CAR' ).
        cl_abap_unit_assert=>fail(
          'without a conversion the quantity means nothing, it must not pass as base units' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD unknown_material_is_refused.

    TRY.
        mo_cut->to_base(
          iv_matnr    = c_matnr
          iv_quantity = '3'
          iv_uom      = 'PC' ).
        cl_abap_unit_assert=>fail( 'a material without a material master cannot be converted' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD zero_denominator_is_refused.

    given_material(
      iv_base = 'PC'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 12 umren = 0 ) ) ).

    TRY.
        mo_cut->to_base(
          iv_matnr    = c_matnr
          iv_quantity = '3'
          iv_uom      = 'CAR' ).
        cl_abap_unit_assert=>fail( 'broken master data must be reported, not divided by' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD zero_numerator_is_refused.

    given_material(
      iv_base = 'PC'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 0 umren = 1 ) ) ).

    TRY.
        mo_cut->from_base(
          iv_matnr    = c_matnr
          iv_quantity = '12'
          iv_uom      = 'CAR' ).
        cl_abap_unit_assert=>fail( 'a carton of no pieces is broken master data, not a division' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD back_to_the_base_is_unchanged.

    given_material( 'PC' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->from_base(
        iv_matnr    = c_matnr
        iv_quantity = '7'
        iv_uom      = 'PC' )
      exp = '7'
      msg = 'a quantity already in the unit asked for needs no conversion at all' ).

  ENDMETHOD.

  METHOD back_to_the_sales_unit.

    given_material(
      iv_base = 'PC'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 12 umren = 1 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->from_base(
        iv_matnr    = c_matnr
        iv_quantity = '24'
        iv_uom      = 'CAR' )
      exp = '2'
      msg = 'twenty four pieces are two cartons of twelve' ).

  ENDMETHOD.

  METHOD back_keeps_the_fraction.

    given_material(
      iv_base = 'PC'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 4 umren = 1 ) ) ).

    " five of a material sold in fours is not a whole number of them, and a
    " converter that rounded would either promise a piece nobody has or drop
    " one that was confirmed. Which of those a plant can live with is what the
    " whole order units rule is for, and it runs before this.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->from_base(
        iv_matnr    = c_matnr
        iv_quantity = '5'
        iv_uom      = 'CAR' )
      exp = '1.250' ).

  ENDMETHOD.

  METHOD back_and_forth_is_the_same.

    given_material(
      iv_base = 'PC'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 12 umren = 1 ) ) ).

    " what a demand reader read and what a write back would put on the
    " document have to be the same number, or the run promises something the
    " order does not say
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->from_base(
        iv_matnr    = c_matnr
        iv_quantity = mo_cut->to_base(
          iv_matnr    = c_matnr
          iv_quantity = '3'
          iv_uom      = 'CAR' )
        iv_uom      = 'CAR' )
      exp = '3' ).

  ENDMETHOD.

  METHOD back_refuses_an_unknown_unit.

    given_material( 'PC' ).

    TRY.
        mo_cut->from_base(
          iv_matnr    = c_matnr
          iv_quantity = '12'
          iv_uom      = 'CAR' ).
        cl_abap_unit_assert=>fail( 'a unit with no conversion cannot be written back either' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD master_data_is_read_once.

    given_material(
      iv_base = 'PC'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 12 umren = 1 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base(
        iv_matnr    = c_matnr
        iv_quantity = '1'
        iv_uom      = 'CAR' )
      exp = '12' ).

    " taking the master data away is how a test can tell whether it is read
    " again: a converter that still answers has not gone back to the database
    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_subrc( ).
    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base(
        iv_matnr    = c_matnr
        iv_quantity = '2'
        iv_uom      = 'CAR' )
      exp = '24'
      msg = 'the material master is read once, not once per quantity' ).

  ENDMETHOD.

  METHOD another_converter_reads_again.

    given_material(
      iv_base = 'PC'
      it_marm = VALUE #(
        ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 12 umren = 1 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base(
        iv_matnr    = c_matnr
        iv_quantity = '1'
        iv_uom      = 'CAR' )
      exp = '12' ).

    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_subrc( ).

    " the buffer belongs to the instance, so it lasts as long as a run and no
    " longer. Nothing is remembered across runs, or between programs.
    TRY.
        NEW zcl_unit_converter( )->zif_unit_converter~to_base(
          iv_matnr    = c_matnr
          iv_quantity = '1'
          iv_uom      = 'CAR' ).
        cl_abap_unit_assert=>fail( 'a fresh converter must read the master data itself' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD the_base_unit_can_be_asked.

    given_material( 'KG' ).

    " a report printing a quantity has to be able to say what it is a
    " quantity of, and the converter has the master data already
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->base_unit( c_matnr )
      exp = CONV mara-meins( 'KG' ) ).

  ENDMETHOD.

  METHOD no_material_has_no_unit.

    TRY.
        mo_cut->base_unit( 'NO-SUCH-MATERIAL' ).
        cl_abap_unit_assert=>fail( 'a unit invented for a material nobody has is worse than none' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
