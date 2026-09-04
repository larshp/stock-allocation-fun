"! Hands out settings per plant and counts how often it is asked.
CLASS lcl_config_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_alloc_config.

    TYPES ty_config_tab TYPE STANDARD TABLE OF zif_alloc_config=>ty_config WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_config TYPE ty_config_tab.

    METHODS asked
      RETURNING
        VALUE(rv_asked) TYPE i.

  PRIVATE SECTION.
    DATA mt_config TYPE ty_config_tab.
    DATA mv_asked  TYPE i.

ENDCLASS.


CLASS lcl_config_double IMPLEMENTATION.

  METHOD constructor.
    mt_config = it_config.
  ENDMETHOD.

  METHOD asked.
    rv_asked = mv_asked.
  ENDMETHOD.

  METHOD zif_alloc_config~for_plant.

    mv_asked = mv_asked + 1.

    READ TABLE mt_config INTO rs_config
      WITH KEY werks = iv_werks.
    IF sy-subrc <> 0.
      CLEAR rs_config.
      rs_config-werks = iv_werks.
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_supply_per_plant DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'PER-PLANT-01'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.

    METHODS setup.
    METHODS teardown.

    METHODS total_of
      IMPORTING
        io_cut             TYPE REF TO zif_supply_reader
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity
      RAISING
        zcx_allocation.

    METHODS each_plant_reads_its_own FOR TESTING RAISING cx_static_check.
    METHODS the_settings_are_read_once FOR TESTING RAISING cx_static_check.
    METHODS two_plants_are_two_readers FOR TESTING RAISING cx_static_check.
    METHODS no_config_reads_customizing FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_supply_per_plant IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' ) ).

    " the same material in two plants, and in two storage locations in each of
    " them, so that a restriction to one location is visible in the total
    lt_mard = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_here lgort = '0001' labst = '10' )
      ( mandt = sy-mandt matnr = c_matnr werks = c_here lgort = '0002' labst = '5' )
      ( mandt = sy-mandt matnr = c_matnr werks = c_there lgort = '0001' labst = '20' )
      ( mandt = sy-mandt matnr = c_matnr werks = c_there lgort = '0002' labst = '10' ) ).

    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    INSERT mard FROM TABLE @lt_mard.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM mard WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD total_of.

    LOOP AT io_cut->read_supply(
        iv_matnr = c_matnr
        iv_werks = iv_werks ) INTO DATA(ls_supply).
      rv_quantity = rv_quantity + ls_supply-quantity.
    ENDLOOP.

  ENDMETHOD.

  METHOD each_plant_reads_its_own.

    DATA(lo_cut) = CAST zif_supply_reader( NEW zcl_supply_per_plant(
      NEW lcl_config_double( VALUE #(
        ( werks = c_here lgort = '0001' )
        ( werks = c_there ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = total_of( io_cut   = lo_cut
                      iv_werks = c_here )
      exp = '10'
      msg = 'the plant that allocates from one location has one location of stock' ).

    cl_abap_unit_assert=>assert_equals(
      act = total_of( io_cut   = lo_cut
                      iv_werks = c_there )
      exp = '30'
      msg = 'and the plant that has said nothing has all of its own' ).

  ENDMETHOD.

  METHOD the_settings_are_read_once.

    DATA(lo_config) = NEW lcl_config_double( VALUE #( ( werks = c_here lgort = '0001' ) ) ).
    DATA(lo_cut)    = CAST zif_supply_reader( NEW zcl_supply_per_plant( lo_config ) ).

    total_of( io_cut   = lo_cut
              iv_werks = c_here ).
    total_of( io_cut   = lo_cut
              iv_werks = c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_config->asked( )
      exp = 1
      msg = 'a plant asked about twice is Customizing read once, as feature 83 said' ).

  ENDMETHOD.

  METHOD two_plants_are_two_readers.

    DATA(lo_config) = NEW lcl_config_double( VALUE #(
      ( werks = c_here lgort = '0001' )
      ( werks = c_there ) ) ).
    DATA(lo_cut)    = CAST zif_supply_reader( NEW zcl_supply_per_plant( lo_config ) ).

    total_of( io_cut   = lo_cut
              iv_werks = c_here ).
    total_of( io_cut   = lo_cut
              iv_werks = c_there ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_config->asked( )
      exp = 2
      msg = 'the buffer is per plant, not one reader for whichever plant came first' ).

  ENDMETHOD.

  METHOD no_config_reads_customizing.

    " a caller that names no settings gets the ones in Customizing, which for
    " a plant with no row are the defaults: every storage location counts
    DATA(lo_cut) = CAST zif_supply_reader( NEW zcl_supply_per_plant( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = total_of( io_cut   = lo_cut
                      iv_werks = c_there )
      exp = '30' ).

  ENDMETHOD.

ENDCLASS.
