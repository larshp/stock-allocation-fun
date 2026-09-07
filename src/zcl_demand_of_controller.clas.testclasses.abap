"! Answers with a fixed list of materials, and remembers what it was asked.
CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_matnr TYPE zif_demand_reader=>ty_matnr_tab.

    METHODS get_asked_for
      RETURNING
        VALUE(rv_matnr) TYPE mard-matnr.

  PRIVATE SECTION.
    DATA mt_matnr TYPE zif_demand_reader=>ty_matnr_tab.
    DATA mv_asked TYPE mard-matnr.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_matnr = it_matnr.
  ENDMETHOD.

  METHOD get_asked_for.
    rv_matnr = mv_asked.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    mv_asked = iv_matnr.

    rt_demand = VALUE #(
      ( demand_id = 'D1'
        matnr     = iv_matnr
        werks     = iv_werks
        quantity  = '10'
        req_date  = '20260101'
        priority  = '01' ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_of_controller DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_mine  TYPE mard-matnr VALUE 'DISPO-MAT-01'.
    CONSTANTS c_yours TYPE mard-matnr VALUE 'DISPO-MAT-02'.
    CONSTANTS c_gone  TYPE mard-matnr VALUE 'DISPO-MAT-03'.

    DATA mo_inner TYPE REF TO lcl_demand_double.

    METHODS setup.
    METHODS teardown.

    METHODS materials
      IMPORTING
        it_dispo        TYPE zcl_demand_of_controller=>ty_dispo_tab OPTIONAL
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

    METHODS only_the_named_controller FOR TESTING.
    METHODS several_controllers_at_once FOR TESTING.
    METHODS no_list_is_every_controller FOR TESTING.
    METHODS a_deleted_material_is_out FOR TESTING.
    METHODS an_unknown_plant_is_nothing FOR TESTING.
    METHODS demand_itself_is_not_filtered FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_demand_of_controller IMPLEMENTATION.

  METHOD setup.

    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.

    mo_inner = NEW lcl_demand_double( VALUE #( ( c_mine ) ( c_yours ) ( c_gone ) ) ).

    lt_marc = VALUE #(
      ( mandt = sy-mandt matnr = c_mine werks = c_werks dispo = '001' )
      ( mandt = sy-mandt matnr = c_yours werks = c_werks dispo = '002' )
      ( mandt = sy-mandt matnr = c_gone werks = c_werks dispo = '001'
        lvorm = 'X' ) ).

    INSERT marc FROM TABLE @lt_marc.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'plant master fixture could not be inserted' ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM marc WHERE matnr IN ( @c_mine, @c_yours, @c_gone ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD materials.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_of_controller(
      io_demand = mo_inner
      it_dispo  = it_dispo ) ).

    rt_matnr = lo_cut->materials_with_demand( c_werks ).

  ENDMETHOD.

  METHOD only_the_named_controller.

    cl_abap_unit_assert=>assert_equals(
      act = materials( VALUE #( ( '001' ) ) )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_mine ) )
      msg = 'a planner running their own materials gets their own materials' ).

  ENDMETHOD.

  METHOD several_controllers_at_once.

    cl_abap_unit_assert=>assert_equals(
      act = materials( VALUE #( ( '001' ) ( '002' ) ) )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_mine ) ( c_yours ) )
      msg = 'a job may cover more than one controller' ).

  ENDMETHOD.

  METHOD no_list_is_every_controller.

    cl_abap_unit_assert=>assert_equals(
      act = materials( )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_mine ) ( c_yours ) ( c_gone ) )
      msg = 'a plant that never split its run must keep the run it had' ).

  ENDMETHOD.

  METHOD a_deleted_material_is_out.

    DATA(lt_matnr) = materials( VALUE #( ( '001' ) ) ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_gone ] ) )
      msg = 'a material flagged for deletion in the plant is not worth a run' ).

  ENDMETHOD.

  METHOD an_unknown_plant_is_nothing.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_of_controller(
      io_demand = mo_inner
      it_dispo  = VALUE #( ( '009' ) ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lo_cut->materials_with_demand( c_werks )
      msg = 'a controller who owns nothing here has nothing to allocate' ).

  ENDMETHOD.

  METHOD demand_itself_is_not_filtered.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_of_controller(
      io_demand = mo_inner
      it_dispo  = VALUE #( ( '001' ) ) ) ).

    DATA(lt_demand) = lo_cut->read_open_demand(
      iv_matnr = c_yours
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_not_initial(
      act = lt_demand
      msg = 'a caller naming a material outright gets its demand whoever owns it' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_inner->get_asked_for( )
      exp = c_yours ).

  ENDMETHOD.

ENDCLASS.
