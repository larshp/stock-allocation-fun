"! Answers with a fixed list and fixed demand.
CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_matnr TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mt_matnr TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_matnr = it_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = VALUE #(
      ( demand_id = 'D1'
        matnr     = iv_matnr
        werks     = iv_werks
        quantity  = '10'
        req_date  = '20260301'
        priority  = '01' ) ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_alive DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '9701'.
    CONSTANTS c_live  TYPE mard-matnr VALUE 'ALIVE-MAT-01'.
    CONSTANTS c_plant TYPE mard-matnr VALUE 'ALIVE-MAT-02'.
    CONSTANTS c_gone  TYPE mard-matnr VALUE 'ALIVE-MAT-03'.

    DATA mo_cut TYPE REF TO zif_demand_reader.

    METHODS setup.
    METHODS teardown.

    METHODS a_live_material_is_kept FOR TESTING RAISING cx_static_check.
    METHODS a_plant_flag_takes_it_out FOR TESTING RAISING cx_static_check.
    METHODS a_material_flag_does_too FOR TESTING RAISING cx_static_check.
    METHODS a_named_flagged_one_is_out FOR TESTING RAISING cx_static_check.
    METHODS a_named_live_one_is_read FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_demand_alive IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.

    mo_cut = NEW zcl_demand_alive(
      NEW lcl_demand_double( VALUE #( ( c_live ) ( c_plant ) ( c_gone ) ) ) ).

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_live mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_plant mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_gone mtart = 'FERT' meins = 'PC' lvorm = 'X' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_marc = VALUE #(
      ( mandt = sy-mandt matnr = c_live werks = c_werks )
      ( mandt = sy-mandt matnr = c_plant werks = c_werks lvorm = 'X' )
      ( mandt = sy-mandt matnr = c_gone werks = c_werks ) ).
    INSERT marc FROM TABLE @lt_marc.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM marc WHERE matnr IN ( @c_live, @c_plant, @c_gone ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr IN ( @c_live, @c_plant, @c_gone ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD a_live_material_is_kept.

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_live ] ) )
      msg = 'a material nobody has flagged is allocated as before' ).

  ENDMETHOD.

  METHOD a_plant_flag_takes_it_out.

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_plant ] ) )
      msg = 'a material the plant is finished with must not be earmarked' ).

  ENDMETHOD.

  METHOD a_material_flag_does_too.

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_gone ] ) )
      msg = 'the plant list only knows the plant flag' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_gone
        iv_werks = c_werks )
      msg = 'and the material flag is caught when the material is read' ).

  ENDMETHOD.

  METHOD a_named_flagged_one_is_out.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_plant
        iv_werks = c_werks )
      msg = 'a material being deleted is exactly the kind somebody types in' ).

  ENDMETHOD.

  METHOD a_named_live_one_is_read.

    cl_abap_unit_assert=>assert_not_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_live
        iv_werks = c_werks )
      msg = 'and a material nobody flagged is read as before' ).

  ENDMETHOD.

ENDCLASS.
