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


CLASS ltcl_demand_not_held DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '9801'.
    CONSTANTS c_free  TYPE mard-matnr VALUE 'HOLD-MAT-01'.
    CONSTANTS c_held  TYPE mard-matnr VALUE 'HOLD-MAT-02'.
    CONSTANTS c_over  TYPE mard-matnr VALUE 'HOLD-MAT-03'.
    CONSTANTS c_today TYPE d VALUE '20260301'.

    DATA mo_cut TYPE REF TO zif_demand_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_hold
      IMPORTING
        iv_matnr TYPE mard-matnr
        iv_until TYPE zstock_alloc_hld-until_date DEFAULT '00000000'.

    METHODS a_free_material_is_kept FOR TESTING RAISING cx_static_check.
    METHODS a_held_material_is_out FOR TESTING RAISING cx_static_check.
    METHODS a_hold_can_lift_by_itself FOR TESTING RAISING cx_static_check.
    METHODS a_hold_holds_until_its_day FOR TESTING RAISING cx_static_check.
    METHODS a_named_held_one_is_out FOR TESTING RAISING cx_static_check.
    METHODS the_list_is_read_once FOR TESTING RAISING cx_static_check.
    METHODS another_plant_is_read_again FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_demand_not_held IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW zcl_demand_not_held(
      io_demand = NEW lcl_demand_double( VALUE #( ( c_free ) ( c_held ) ( c_over ) ) )
      iv_today  = c_today ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_hld WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_hold.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_hld WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        werks      = c_werks
        matnr      = iv_matnr
        reason     = 'quality are looking at it'
        until_date = iv_until ) ).

    INSERT zstock_alloc_hld FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'hold fixture could not be inserted' ).

  ENDMETHOD.

  METHOD the_list_is_read_once.

    given_hold( c_held ).

    " asked once, so the answer is read; asked again after the row has gone,
    " so an answer that changed would mean it had been read twice
    mo_cut->materials_with_demand( c_werks ).

    DELETE FROM zstock_alloc_hld WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_held
        iv_werks = c_werks )
      msg = 'a plant wide run asks once per material and must not read once per material' ).

  ENDMETHOD.

  METHOD another_plant_is_read_again.

    given_hold( c_held ).

    mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_not_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_held
        iv_werks = '9802' )
      msg = 'a hold in one plant is not a hold in another, buffered or not' ).

  ENDMETHOD.

  METHOD a_free_material_is_kept.

    given_hold( c_held ).

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_free ] ) )
      msg = 'a hold is about one material, not about the plant' ).

  ENDMETHOD.

  METHOD a_held_material_is_out.

    given_hold( c_held ).

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_held ] ) )
      msg = 'do not give this away tonight has to be sayable somewhere' ).

  ENDMETHOD.

  METHOD a_hold_can_lift_by_itself.

    given_hold(
      iv_matnr = c_over
      iv_until = '20260228' ).

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_over ] ) )
      msg = 'a hold put on for a stock count should not outlive the count' ).

  ENDMETHOD.

  METHOD a_hold_holds_until_its_day.

    given_hold(
      iv_matnr = c_held
      iv_until = c_today ).

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_held ] ) )
      msg = 'held until the first means held on the first' ).

  ENDMETHOD.

  METHOD a_named_held_one_is_out.

    given_hold( c_held ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand(
        iv_matnr = c_held
        iv_werks = c_werks )
      msg = 'a hold a run honours and a report ignores is no hold at all' ).

  ENDMETHOD.

ENDCLASS.
