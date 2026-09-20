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


CLASS ltcl_demand_per_plant DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'PER-PLANT-D1'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.
    CONSTANTS c_soon  TYPE vbak-vbeln VALUE '0000009911'.
    CONSTANTS c_later TYPE vbak-vbeln VALUE '0000009912'.

    METHODS setup.
    METHODS teardown.

    METHODS total_of
      IMPORTING
        io_cut             TYPE REF TO zif_demand_reader
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity
      RAISING
        zcx_allocation.

    METHODS each_plant_looks_its_own_way FOR TESTING RAISING cx_static_check.
    METHODS the_settings_are_read_once FOR TESTING RAISING cx_static_check.
    METHODS two_plants_are_two_readers FOR TESTING RAISING cx_static_check.
    METHODS the_material_list_is_per_plant FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_demand_per_plant IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_vbak TYPE STANDARD TABLE OF vbak WITH EMPTY KEY.
    DATA lt_vbap TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' ) ).

    " one line wanted in a week and one in a year, in both plants: a horizon
    " of a month keeps the first and drops the second
    lt_vbak = VALUE #(
      ( mandt = sy-mandt vbeln = c_soon auart = 'TA' vkorg = '1000'
        vdatu = sy-datum + 7 )
      ( mandt = sy-mandt vbeln = c_later auart = 'TA' vkorg = '1000'
        vdatu = sy-datum + 365 ) ).

    lt_vbap = VALUE #(
      ( mandt = sy-mandt vbeln = c_soon posnr = '000010'
        matnr = c_matnr werks = c_here vrkme = 'PC' kwmeng = '10' lprio = '01' )
      ( mandt = sy-mandt vbeln = c_later posnr = '000010'
        matnr = c_matnr werks = c_here vrkme = 'PC' kwmeng = '90' lprio = '01' )
      ( mandt = sy-mandt vbeln = c_soon posnr = '000020'
        matnr = c_matnr werks = c_there vrkme = 'PC' kwmeng = '10' lprio = '01' )
      ( mandt = sy-mandt vbeln = c_later posnr = '000020'
        matnr = c_matnr werks = c_there vrkme = 'PC' kwmeng = '90' lprio = '01' ) ).

    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    INSERT vbak FROM TABLE @lt_vbak.
    cl_abap_unit_assert=>assert_subrc( ).

    INSERT vbap FROM TABLE @lt_vbap.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM vbap WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM vbak WHERE vbeln IN ( @c_soon, @c_later ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD total_of.

    LOOP AT io_cut->read_open_demand(
        iv_matnr = c_matnr
        iv_werks = iv_werks ) INTO DATA(ls_demand).
      rv_quantity = rv_quantity + ls_demand-quantity.
    ENDLOOP.

  ENDMETHOD.

  METHOD each_plant_looks_its_own_way.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_per_plant(
      NEW lcl_config_double( VALUE #(
        ( werks = c_here horizon_days = 30 )
        ( werks = c_there ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = total_of( io_cut   = lo_cut
                      iv_werks = c_here )
      exp = '10'
      msg = 'the plant that looks a month ahead is waiting for one of the two lines' ).

    cl_abap_unit_assert=>assert_equals(
      act = total_of( io_cut   = lo_cut
                      iv_werks = c_there )
      exp = '100'
      msg = 'and the plant that has set no horizon is waiting for both' ).

  ENDMETHOD.

  METHOD the_settings_are_read_once.

    DATA(lo_config) = NEW lcl_config_double( VALUE #( ( werks = c_here horizon_days = 30 ) ) ).
    DATA(lo_cut)    = CAST zif_demand_reader( NEW zcl_demand_per_plant( lo_config ) ).

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
      ( werks = c_here horizon_days = 30 )
      ( werks = c_there ) ) ).
    DATA(lo_cut)    = CAST zif_demand_reader( NEW zcl_demand_per_plant( lo_config ) ).

    total_of( io_cut   = lo_cut
              iv_werks = c_here ).
    total_of( io_cut   = lo_cut
              iv_werks = c_there ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_config->asked( )
      exp = 2
      msg = 'the buffer is per plant, not one reader for whichever plant came first' ).

  ENDMETHOD.

  METHOD the_material_list_is_per_plant.

    " the other half of the interface goes through the same reader, so a
    " caller that asks which materials are waiting gets the plant it asked
    " about rather than the plant the reader was built for
    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_per_plant(
      NEW lcl_config_double( VALUE #( ( werks = c_there ) ) ) ) ).

    DATA(lt_matnr) = lo_cut->materials_with_demand( c_there ).

    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( lt_matnr[ table_line = c_matnr ] ) ) ).

  ENDMETHOD.

ENDCLASS.
